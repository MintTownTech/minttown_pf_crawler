import axios from 'axios';
import AWS from 'aws-sdk';
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    const sessionId = process.env.FREECASH_SESSION_ID;
    if (!sessionId) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'FREECASH_SESSION_ID is not set' }),
        };
    }

    const options = {
        method: 'POST',
        url: 'https://freecash.com/fc-api/graphql',
        headers: {
            cookie: `session_id=${sessionId}`,
            'user-agent': 'vscode-restclient',
            'content-type': 'application/json',
        },
        data: {
            query: `query getOffers(
                $limit: Int
                $page: Int
                $category: OfferCategory
                $isAndroid: Boolean
                $isIos: Boolean
                $isDesktop: Boolean
                $searchTerm: String
                $sort: GetOffersSort!
                $isLiteMode: Boolean
            ) {
                getOffers(
                    limit: $limit
                    page: $page
                    category: $category
                    isAndroid: $isAndroid
                    isIos: $isIos
                    isDesktop: $isDesktop
                    searchTerm: $searchTerm
                    sort: $sort
                    isLiteMode: $isLiteMode
                ) {
                    items {
                        id
                        name
                        slug
                        status
                        popularity
                        requirements
                        gameId
                        description
                        thumbnail
                        thumbnailLarge
                        isAndroid
                        isDesktop
                        isIos
                        category
                        coins
                        token
                        url
                        wallName
                        countries
                        images {
                            url
                        }
                        boost {
                            level
                            multiplier
                        }
                        tasks {
                            alwaysDisplay
                            coins
                            id
                            isInstallTask
                            maxCompleteDays
                            offerId
                            priority
                            requirementValue
                            hint
                            status {
                                releaseOn
                                completedAt
                                status
                                progress {
                                    value
                                }
                                completionCount
                                lastCompletionDate
                            }
                            maxCompletions
                            title
                            type
                            assignedAt
                            payoutStructureId
                        }
                        game {
                            id
                            name
                            ratings {
                                android {
                                    reviewsCount
                                    score
                                }
                                ios {
                                    reviewsCount
                                    score
                                }
                            }
                        }
                    }
                    meta {
                        itemCount
                        totalItems
                        totalPages
                        itemsPerPage
                        currentPage
                    }
                }
            }`,
            variables: {
                limit: 10000,
                page: 1,
                isAndroid: true,
                isIos: true,
                isDesktop: true,
                isLiteMode: false,
                sort: 'MOST_POPULAR',
                category: null,
            },
        },
    };

    try {
        const ipResponse = await axios.get('https://api.ipify.org?format=json');
        console.log(`Public IP Address: ${ipResponse.data.ip}`);
        const response = await axios.request(options);
        const s3 = new AWS.S3();
        const bucketName = process.env.S3_BUCKET;
        if (!bucketName) {
            throw new Error('S3_BUCKET is not set');
        }
        const params = {
            Bucket: bucketName,
            Key: `freecash/data-${process.env.COUNTRY}.json`,
            Body: JSON.stringify(response.data),
            ContentType: 'application/json',
        };

        await s3.putObject(params).promise();

        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Data written to S3 successfully' }),
        };
    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Failed to fetch offers' }),
        };
    }
};
