import { Decimal } from 'decimal.js';
import stringify from 'safe-stable-stringify';

import { FreecashOfferAPI } from './freecash.api.type';
import { convertFreecashOfferSlugToOfferAppName } from './predefined-freecash-offer-offer-app-name.service';
import { convertFreecashOfferTaskToComparisonName } from './predefined-freecash-offer-task-comparison-name.service';

const FREECASH_COIN_CONVERSION_RATE = 1000;

const toDecimalFixed = (value: number | string | Decimal) => {
    return new Decimal(value).toDecimalPlaces(10);
};

export const transformFreecashOfferAPI = async (offer: FreecashOfferAPI) => {
    const { baseOfferAppName, offerAppName } = await convertFreecashOfferSlugToOfferAppName(offer.slug);
    const transformedTasks = await Promise.all(
        offer.tasks
            .filter((task) => task?.coins > 0 && task?.type !== 'PURCHASE_BONUS_REWARD')
            .map(async (task) => {
                const results = await convertFreecashOfferTaskToComparisonName(task.title);
                const { baseComparisonName, comparisonName } = results;
                return {
                    taskId: task.id.toString(),
                    usdAmount: toDecimalFixed(task.coins / FREECASH_COIN_CONVERSION_RATE),
                    status: stringify(task.status),
                    baseComparisonName,
                    comparisonName,
                };
            }),
    );
    const game = offer.game
        ? {
              name: offer.game.name,
              iosRating: offer.game.ratings?.ios?.score,
              androidRating: offer.game.ratings?.android?.score,
          }
        : '';
    const { __typename, id, token, coins: offerCoins, ...cleanedOffer } = offer;
    return {
        ...cleanedOffer,
        tasks: { create: transformedTasks },
        usdAmount: toDecimalFixed(offerCoins / FREECASH_COIN_CONVERSION_RATE),
        images: JSON.parse(stringify(offer.images)!),
        boost: JSON.parse(stringify(offer.boost)!),
        game: JSON.parse(stringify(game)),
        isAvailable: true,
        baseOfferAppName,
        offerAppName,
    };
};
