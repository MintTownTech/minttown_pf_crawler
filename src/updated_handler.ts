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
    const snsEvent = event['Records'][0]['Sns'];
    console.log(JSON.stringify(snsEvent));

    // Parse the SNS message
    const message = JSON.parse(snsEvent.Message);
    const s3Record = message.Records[0];
    const bucketName = s3Record.s3.bucket.name;
    const key = s3Record.s3.object.key;

    console.log(`Bucket: ${bucketName}, Key: ${key}`);

    const s3Client = new S3Client({ region: 'us-west-2' });

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
            console.log(jsonData['data']['getOffers']['items'][0]['id']);
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
