import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import * as AWS from 'aws-sdk';

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    console.log(event);
    const s3 = new AWS.S3();
    const bucketName = 'minttown-pf-crawler-data-bucket-test';
    const key = 'freecash/data.json';

    try {
        const params = {
            Bucket: bucketName,
            Key: key,
        };

        const data = await s3.getObject(params).promise();
        if (data.Body) {
            const jsonData = JSON.parse(data.Body.toString('utf-8'));
            if (Array.isArray(jsonData)) {
                console.log(jsonData.slice(0, 2));
            } else {
                console.error('Error: jsonData is not an array');
            }
        } else {
            console.error('Error: data.Body is undefined');
        }
    } catch (error) {
        console.error('Error reading from S3:', error);
    }

    return {
        statusCode: 200,
        body: JSON.stringify({ message: 'Hello from update' }),
    };
};
