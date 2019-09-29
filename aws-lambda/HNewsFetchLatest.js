const https = require("https");
const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB();
const docClient = new AWS.DynamoDB.DocumentClient();

AWS.config.update({region: 'us-west-2'});

const maxItemUrl = "https://hacker-news.firebaseio.com/v0/maxitem.json";

function getItemUrl(itemId) {
    return "https://hacker-news.firebaseio.com/v0/item/" + itemId + ".json";
}

function batches(arr, batchSize) {
    var batches = [];
    var i = 0;
    while (i < arr.length) {
        var batch = arr.slice(i, i + batchSize);
        batches.push(batch);
        i += batchSize;
    }
    return batches;
}

async function fetchAsync(url) {
    const promise = new Promise(function (resolve, reject) {
        https.get(url, res => {

            var body = "";

            res.on("data", chunk => {
                body += chunk;
            });

            res.on("end", () => {
                try {
                    const parsed = JSON.parse(body);
                    resolve(parsed);
                } catch (error) {
                    reject(error);
                }
            });

        }).on("error", (error) => {
            reject(error);
        });
    });
    return promise;
}

function getDynamoDBValueObject(value, type, useDefaultValueIfNull = false) {

    const isNull = (typeof value === 'undefined') || (value == null);

    if (isNull && !useDefaultValueIfNull) {
        return null;
    }

    if (type == "S") {
        return { S: isNull || value == "" ? null : value.toString() };
    } else if (type == "N") {
        return { N: isNull ? "0" : value.toString() };
    } else if (type == "NS") {
        return { NS: isNull ? [] : value.map(String) };
    } else if (type == "BOOL") {
        return { BOOL: isNull ? false : value };
    } else {
        throw Error("Invalid type: " + type);
    }
}

async function saveItemAsync(item, pkey) {
    const promise = new Promise(function (resolve, reject) {

        if (!item.id || !item.type) {
            reject(Error("Invalid item"));
            return;
        }

        dynamodb.putItem({
            TableName: "hnews",
            Item: {
                pkey: getDynamoDBValueObject(pkey, "S"),
                id: getDynamoDBValueObject(item.id, "N"),
                deleted: getDynamoDBValueObject(item.deleted, "BOOL"),
                type: getDynamoDBValueObject(item.type, "S"),
                by: getDynamoDBValueObject(item.by, "S"),
                time: getDynamoDBValueObject(item.time, "N"),
                text: getDynamoDBValueObject(item.text, "S"),
                dead: getDynamoDBValueObject(item.dead, "BOOL"),
                parent: getDynamoDBValueObject(item.parent, "N"),
                poll: getDynamoDBValueObject(item.poll, "N"),
                kids: getDynamoDBValueObject(item.kids, "NS"),
                url: getDynamoDBValueObject(item.url, "S"),
                score: getDynamoDBValueObject(item.score, "N"),
                title: getDynamoDBValueObject(item.title, "S"),
                parts: getDynamoDBValueObject(item.parts, "NS"),
                descendants: getDynamoDBValueObject(item.descendants, "N"),
                root: getDynamoDBValueObject(item.root, "N"),
            }
        }, function (error, data) {
            if (error) {
                reject(error);
            } else {
                resolve(true);
            }
        });
    });
    return promise;
}

async function fetchMaxItemIdAsync() {
    return await fetchAsync(maxItemUrl);
}

async function queryLastNItemIdsAsync(count) {
    const params = {
        TableName: "hnews",
        ProjectionExpression: "id",
        KeyConditionExpression: "pkey = :pkey",
        ExpressionAttributeValues: {
            ":pkey": "all"
        },
        ScanIndexForward: false,
        Limit: count
    };
    const promise = new Promise(function (resolve, reject) {
        docClient.query()
        docClient.query(params, function (err, data) {
            if (err) {
                reject(err);
            } else {
                var itemIds = [];
                data.Items.forEach(function (item) {
                    if (item.id) {
                        itemIds.push(item.id);
                    }
                });
                resolve(itemIds);
            }
        });
    });
    return promise;
}

async function queryRootIdAsync(itemId) {
    const params = {
        TableName: "hnews",
        ProjectionExpression: "root",
        KeyConditionExpression: "pkey = :pkey AND id = :id",
        ExpressionAttributeValues: {
            ":pkey": "all",
            ":id": itemId
        }
    };
    const promise = new Promise(function (resolve, reject) {
        docClient.query(params, function (err, data) {
            if (err) {
                reject(err);
            } else {
                if (data.Items.length > 0) {
                    if (data.Items[0].root > 0) {
                        resolve(data.Items[0].root);
                    } else {
                        resolve(-1);
                    }
                } else {
                    resolve(-1);
                }
            }
        });
    });
    return promise;
}

var fetchedItemsMap = {};

async function fetchItemAsync(itemId) {
    const item = fetchAsync(getItemUrl(itemId));
    fetchedItemsMap[item.id] = item;
    return item;
}

async function resolveRootAndSaveAsync(item) {
    if (item.parent > 0) {
        const parentId = item.parent;
        if (parentId in fetchedItemsMap) {
            item.root = fetchedItemsMap[parentId].root;
        } else {
            var rootId = await queryRootIdAsync(parentId)
            item.root = rootId;
        }
    } else {
        item.root = item.id;
    }
    
    if (item.root > 0) {
        await saveItemAsync(item, "all");
            if (item.root > 0 && item.root != item.id) {
                await saveItemAsync(item, item.root.toString());
            }
    }

    return true;
}

async function fetchLatestItemsAsync() {

    const maxItemCount = 250;
    const batchSize = 200;
    const results = await Promise.all([fetchMaxItemIdAsync(), queryLastNItemIdsAsync(maxItemCount*2)]);
    const maxItemRemote = results[0];
    const lastNItemIds = results[1];

    var firstItemId = null;
    var itemIdsSet = {};
    for (var i = 0; i < lastNItemIds.length; i++) {
        const itemId = lastNItemIds[i];
        itemIdsSet[itemId] = true;
        if (!firstItemId || (itemId < firstItemId)) {
            firstItemId = itemId;
        }
    }

    if (!firstItemId) {
        firstItemId = 21047795;
    }

    var itemIds = [];
    for (var itemId = firstItemId+1; itemId <= maxItemRemote; itemId++) {
        if (!(itemId in itemIdsSet)) {
            itemIds.push(itemId);
            if (itemIds.length >= maxItemCount) {
                break;
            }
        }
    }
    
    console.info("--- Max Remote Item: " + maxItemRemote + " Items to fetch and save: " + itemIds.length + " First Id: " + (itemIds.length > 0 ? itemIds[0] : 0) + " Last Id: " + (itemIds.length > 0 ? itemIds[itemIds.length-1] : 0));

    // Used to log the error and avoid Promise.all() to fail if any invocation fails.
    const errorHandler = function(error) {
        console.error("Error: " + error)
        return null;
    }

    var itemIdsBatches = batches(itemIds, batchSize);
    var idsBatch;
    var successCount = 0;
    for (idsBatch of itemIdsBatches) {
        
        // 1. Fetch items
        const fetchItemPromises = idsBatch.map(id => fetchItemAsync(id).catch(errorHandler));
        const itemsAndErrors = await Promise.all(fetchItemPromises);
        const items = itemsAndErrors.filter(itemOrError => itemOrError);

        // 2. resolve roots and save
        const savePromises = items.map(item => resolveRootAndSaveAsync(item).catch(errorHandler));
        const saveResults = await Promise.all(savePromises);

        successCount += saveResults.filter(r => r).length;
    }

    console.info("--- Done. Successfuly saved " + successCount + " items.");
}

exports.handler = async (event, context) => {

    await fetchLatestItemsAsync();

    const response = {
        statusCode: 200,
        body: "ok",
    };
    return response;
};
