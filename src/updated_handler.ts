import { S3Client, GetObjectCommand } from '@aws-sdk/client-s3';
import { Readable } from 'stream';

const streamToString = (stream: Readable): Promise<string> => {
    const chunks: any[] = [];
    return new Promise((resolve, reject) => {
        stream.on('data', (chunk) => chunks.push(chunk));
        stream.on('error', reject);
        stream.on('end', () => resolve(Buffer.concat(chunks).toString('utf-8')));
    });
};

export const handler = async (event: any): Promise<any> => {
    console.log(JSON.stringify(event));
    const snsEvent = event['Records'][0]['Sns'];
    console.log(JSON.stringify(snsEvent));

    const s3Client = new S3Client({ region: 'us-east-1' });
    const bucketName = 'minttown-pf-crawler-data-bucket-test';
    const key = 'freecash/data.json';

    try {
        const params = {
            Bucket: bucketName,
            Key: key,
        };

        const command = new GetObjectCommand(params);
        const data = await s3Client.send(command);
        if (data.Body) {
            const bodyString = await streamToString(data.Body as Readable);
            const jsonData = JSON.parse(bodyString);
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