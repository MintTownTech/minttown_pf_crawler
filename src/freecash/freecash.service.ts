import { Prisma } from 'minttown_pf_community/prisma/client';

import { getLogger } from '../logging';
import { prisma } from '../prisma';
import { fetchOffers } from './freecash.api';
import { FreecashOfferAPI } from './freecash.api.type';
import {
    FreecashOfferWithTasks,
    compareFreecashOfferDisplayInfo,
    compareFreecashOfferKeyInfo,
    createFreecashOffer,
    getOfferBySlug,
    updateFreecashOffer,
    updateOffersAsNotAvailable,
} from './freecash-offer.service';
import { transformFreecashOfferAPI } from './freecash.transformer';
import { compareFreecashTaskKeyInfo, updateFreecashOfferTask } from './freecash-offer-task.service';

const logger = getLogger(__filename);

const processNewOffer = async (offer: FreecashOfferAPI, tx: Prisma.TransactionClient) => {
    logger.info(`Creating new offer`, { offer });
    const transformedOffer = await transformFreecashOfferAPI(offer);
    await createFreecashOffer(transformedOffer as unknown as Prisma.FreecashOfferCreateInput);
    return;
};

const processExistingOfferWithNewVersion = async (
    offer: FreecashOfferAPI,
    existingOffer: FreecashOfferWithTasks,
    tx: Prisma.TransactionClient,
) => {
    logger.info(`Creating new offer version`, { offer, existingOffer });
    const transformedOffer = await transformFreecashOfferAPI(offer);
    const transformedOfferWithReference = { ...transformedOffer, lastOfferId: existingOffer.id };
    await createFreecashOffer(transformedOfferWithReference as unknown as Prisma.FreecashOfferCreateInput);
    return;
};

const processExistingOfferWithUpdates = async (
    offer: FreecashOfferAPI,
    existingOffer: FreecashOfferWithTasks,
    tx: Prisma.TransactionClient,
) => {
    logger.info(`Updating existing offer & its tasks`, { offer, existingOffer });
    const { tasks, ...transformedOfferWithoutTasks } = await transformFreecashOfferAPI(offer);
    const updateTaskTasks = existingOffer.tasks.map(async (oldTask) => {
        const newTask = tasks.create.find((item) => item.taskId.toString() === oldTask.taskId);
        if (newTask) {
            return await updateFreecashOfferTask(oldTask.id, newTask);
        }
    });
    await Promise.all(updateTaskTasks);
    await updateFreecashOffer(existingOffer.id, transformedOfferWithoutTasks);
    return;
};

const processExistingOfferWithNoChanges = async (
    offer: FreecashOfferAPI,
    existingOffer: FreecashOfferWithTasks,
    tx: Prisma.TransactionClient,
) => {
    logger.info(`Updating existing offer to be available`, { offer, existingOffer });
    const { tasks, ...transformedOfferWithoutTasks } = await transformFreecashOfferAPI(offer);
    await updateFreecashOffer(existingOffer.id, transformedOfferWithoutTasks);
};

const processExistingOffer = async (
    offer: FreecashOfferAPI,
    existingOffer: FreecashOfferWithTasks,
    tx: Prisma.TransactionClient,
) => {
    const hasOfferKeyDifference = compareFreecashOfferKeyInfo(existingOffer, offer);
    const hasTaskKeyDifference = compareFreecashTaskKeyInfo(existingOffer.tasks, offer.tasks);
    if (hasOfferKeyDifference || hasTaskKeyDifference) {
        return await processExistingOfferWithNewVersion(offer, existingOffer, tx);
    }
    const hasDisplayDifference = compareFreecashOfferDisplayInfo(existingOffer, offer);
    if (hasDisplayDifference) {
        return processExistingOfferWithUpdates(offer, existingOffer, tx);
    }
    return processExistingOfferWithNoChanges(offer, existingOffer, tx);
};

const processOffer = async (offer: FreecashOfferAPI, tx: Prisma.TransactionClient) => {
    const existingOffer = await getOfferBySlug(offer.slug);
    if (!existingOffer) {
        return await processNewOffer(offer, tx);
    }
    return await processExistingOffer(offer, existingOffer, tx);
};

const processOffers = async () => {
    const offers = await fetchOffers();
    logger.info('Begin Processing');
    await prisma.$transaction(async (tx) => {
        logger.info('Updating all records to be not available');
        await updateOffersAsNotAvailable(tx);
        await Promise.all(offers.map((o) => processOffer(o, tx)));
    });
};
