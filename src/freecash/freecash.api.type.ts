export type FreecashOfferTaskAPI = {
    __typename?: string;
    alwaysDisplay: boolean;
    coins: number;
    id: number;
    isInstallTask: boolean;
    maxCompleteDays: number | null;
    offerId: number;
    priority: number;
    requirementValue: number | null;
    hint: string | null;
    status: {
        releaseOn: string | null;
        completedAt: string | null;
        status: string | null;
        progress: {
            value: number | null;
        };
        completionCount: number | null;
        lastCompletionDate: string | null;
    } | null;
    maxCompletions: number;
    title: string | null;
    type: string | null;
    assignedAt: string | null;
    payoutStructureId: number;
};

type GameRating = {
    reviewsCount: number;
    score: number;
};

export type FreecashOfferAPI = {
    __typename?: string;
    id: number;
    name: string;
    slug: string;
    status: string;
    popularity: number;
    requirements: string | null;
    gameId: number | null;
    description: string | null;
    thumbnail: string;
    thumbnailLarge: string | null;
    isAndroid: boolean;
    isDesktop: boolean;
    isIos: boolean;
    category: string | null;
    coins: number;
    token: string | null;
    url: string | null;
    wallName: string | null;
    countries: string[];
    images: {
        url: string;
    }[];
    boost: {
        level: number;
        multiplier: number;
    } | null;
    tasks: FreecashOfferTaskAPI[];
    game: {
        id: number | null;
        name: string | null;
        ratings: {
            android: GameRating;
            ios: GameRating;
        };
    } | null;
};

export type FetchFreecashOffersResponse = {
    getOffers: {
        items: FreecashOfferAPI[];
        meta: {
            itemCount: number;
            totalItems: number;
            totalPages: number;
            itemsPerPage: number;
            currentPage: number;
        };
    };
};
