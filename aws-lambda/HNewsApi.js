const https = require("https");
const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB();
const docClient = new AWS.DynamoDB.DocumentClient();

AWS.config.update({region: 'us-west-2'});

async function queryItemsAsync(pkey) {
    const params = {
        TableName: "hnews",
        ProjectionExpression: "#id, #deleted, #type, #by, #time, #text, #dead, #poll, #kids, #url, #score, #title, #parts, #descendants",
        KeyConditionExpression: "pkey = :pkey",
        ExpressionAttributeNames: {
            "#id": "id",
            "#deleted": "deleted",
            "#type": "type",
            "#by": "by",
            "#time": "time",
            "#text": "text",
            "#dead": "dead",
            "#poll": "poll",
            "#kids": "kids",
            "#url": "url",
            "#score": "score",
            "#title": "title",
            "#parts": "parts",
            "#descendants": "descendants"
        },
        ExpressionAttributeValues: {
            ":pkey": pkey
        }
    };
    const promise = new Promise(function (resolve, reject) {
        docClient.query(params, function (err, data) {
            if (err) {
                reject(err);
            } else {
                resolve(data.Items);
            }
        });
    });
    return promise;
}

exports.handler = async (event, context) => {

    if (typeof event.id !== 'string') {
        throw Error("Invalid id");
    }

    const items = await queryItemsAsync(event.id);
    return items;
};
