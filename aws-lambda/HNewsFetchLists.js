const https = require("https");
const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB();
const docClient = new AWS.DynamoDB.DocumentClient();

AWS.config.update({region: 'us-west-2'});

const topStoriesUrl = "https://hacker-news.firebaseio.com/v0/topstories.json";
const newStoriesUrl = "https://hacker-news.firebaseio.com/v0/newstories.json";
const askStoriesUrl = "https://hacker-news.firebaseio.com/v0/askstories.json";
const jobStoriesUrl = "https://hacker-news.firebaseio.com/v0/jobstories.json";

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

async function deleteItemsBatchAsync(itemIds, pkey) {

    var deleteRequests = [];
    itemIds.forEach(function (itemId) {
        deleteRequests.push({
            DeleteRequest: {
                Key: {
                    pkey: getDynamoDBValueObject(pkey, "S"),
                    id: getDynamoDBValueObject(itemId, "N")
                }
            }
        });
    });

    var params = {
        RequestItems: {
            "hnews": deleteRequests
        }
    };

    const promise = new Promise(function (resolve, reject) {
        dynamodb.batchWriteItem(params, function (err, data) {
            if (err) {
                reject(err);
            } else {
                resolve(true);
            }
        });
    });
    return promise;
}

async function deleteItemsAsync(itemIds, pkey) {
    const itemIdsBatches = batches(itemIds, 25);
    var promises = [];
    itemIdsBatches.forEach(function (itemIdsBatch) {
        promises.push(deleteItemsBatchAsync(itemIdsBatch, pkey));
    });
    await Promise.all(promises);
}

async function queryItemAsync(pkey, id) {
    const params = {
        TableName: "hnews",
        ProjectionExpression: "id",
        KeyConditionExpression: "pkey = :pkey and id = :id",
        ExpressionAttributeValues: {
            ":pkey": pkey,
            ":id": id
        }
    };
    const promise = new Promise(function (resolve, reject) {
        docClient.query(params, function (err, data) {
            if (err) {
                reject(err);
            } else {
                if (data.Items.length > 0) {
                    resolve(data.Items[0]);
                } else {
                    resolve(null);
                }
            }
        });
    });
    return promise;
}

async function queryItemsIdsAsync(pkey) {
    const params = {
        TableName: "hnews",
        ProjectionExpression: "id",
        KeyConditionExpression: "pkey = :pkey",
        ExpressionAttributeValues: {
            ":pkey": pkey
        }
    };
    const promise = new Promise(function (resolve, reject) {
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

async function deleteItemsNotFoundInAsync(itemIds, pkey) {

    const foundItemIds = await queryItemsIdsAsync(pkey);

    var itemIdsMap = {};
    itemIds.forEach(itemId => itemIdsMap[itemId] = true);

    var itemIdsToDelete = [];
    foundItemIds.forEach(function (foundItemId) {
        if (!(foundItemId in itemIdsMap)) {
            itemIdsToDelete.push(foundItemId);
        }
    });

    console.info("--- Deleting " + itemIdsToDelete.length + " items in pkey:" + pkey + ".");
    await deleteItemsAsync(itemIdsToDelete, pkey);
}

async function fetchAndSaveItem(itemId, pkey) {

    const url = getItemUrl(itemId);
    const item = await fetchAsync(url);

    if (!item.id || !item.type) {
        throw Error("Invalid item received");
    }

    await saveItemAsync(item, pkey);

    return true;
}

// Used to log the error and avoid Promise.all() to fail if any invocation fails.
function errorHandler(error) {
    console.error("Error: " + error)
    return null;
}

async function fetchIdsAndItemsAsync(url, pkey) {

    const batchSize = 10;
    const ids = await fetchAsync(url);

    if (!Array.isArray(ids)) {
        throw Error("Unexpected result");
    }

    console.info("--- Fetching " + ids.length + " items in batches of " + batchSize + ".");
    var successCount = 0;

    var idsBatches = batches(ids, batchSize);
    var idsBatch;
    for (idsBatch of idsBatches) {
        var promises = [];
        var id;
        for (id of idsBatch) {
            promises.push(fetchAndSaveItem(id, pkey).catch(errorHandler));
        }
        const results = await Promise.all(promises);
        successCount += results.filter(r => r).length;
    }

    console.info("--- Fetched and saved " + successCount + " items successfuly.");
    await deleteItemsNotFoundInAsync(ids, pkey);
}

exports.handler = async (event, context) => {

    await fetchIdsAndItemsAsync(topStoriesUrl, "topstories");
    await fetchIdsAndItemsAsync(newStoriesUrl, "newstories");
    await fetchIdsAndItemsAsync(askStoriesUrl, "askstories");
    await fetchIdsAndItemsAsync(jobStoriesUrl, "jobstories");

    const response = {
        statusCode: 200,
        body: "ok",
    };
    return response;
};
