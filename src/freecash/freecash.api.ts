import axios from 'axios';

import { getLogger } from '../logging';
import { FetchFreecashOffersResponse } from './freecash.api.type';

const logger = getLogger(__filename);

const client = axios.create({
    baseURL: 'https://freecash.com/fc-api/graphql',
    headers: { Cookie: `session_id=${process.env.FREECASH_SESSION_ID}` },
});
client.interceptors.response.use(undefined, (error) => {
    logger.error(`Freecash ${axios.isAxiosError(error) ? 'API' : 'Unknown'} Error`, error);
    throw error;
});

export const fetchOffers = async () => {
    const itemCountThreshold = 400;

    const query = `
        query getOffers(
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
        }
    `;

    const variables = {
        limit: 10000,
        page: 1,
        isAndroid: true,
        isIos: true,
        isDesktop: true,
        isLiteMode: false,
        sort: 'MOST_POPULAR',
        category: null,
    };

    const response = await client.request<{ data: FetchFreecashOffersResponse }>({
        method: 'POST',
        data: { query, variables },
    });

    const { items, meta } = response.data.data.getOffers;
    if (meta.itemCount < itemCountThreshold) {
        const error = new Error('FREECASH_SESSION_ID is expired');
        logger.error(error);
        throw error;
    }
    return items;
};
