import Decimal from 'decimal.js';
import { Prisma, FreecashOffer } from 'minttown_pf_community/prisma/client';

import { prisma } from '../prisma';
import { toDecimalFixed, FREECASH_COIN_CONVERSION_RATE } from './freecash.utils';
import { FreecashOfferAPI } from './freecash.api.type';

export const updateOffersAsNotAvailable = async (tx: Prisma.TransactionClient = prisma) => {
    return await tx.freecashOffer.updateMany({ data: { isAvailable: false } });
};

export type FreecashOfferWithTasks = Prisma.FreecashOfferGetPayload<{ include: { tasks: true } }>;

export const getOfferBySlug = async (slug: string, tx: Prisma.TransactionClient = prisma) => {
    return await tx.freecashOffer.findFirst({
        where: { slug },
        orderBy: { updatedAt: 'desc' },
        include: { tasks: true },
    });
};

export const createFreecashOffer = async (
    data: Prisma.FreecashOfferCreateInput,
    tx: Prisma.TransactionClient = prisma,
) => {
    return await tx.freecashOffer.create({ data });
};

export const updateFreecashOffer = async (
    id: string,
    data: Prisma.FreecashOfferUpdateInput,
    tx: Prisma.TransactionClient = prisma,
) => {
    return await tx.freecashOffer.update({ where: { id }, data });
};

export const compareFreecashOfferKeyInfo = (oldOffer: FreecashOffer, newOffer: FreecashOfferAPI) => {
    const hasDifferentCoins = !new Decimal(oldOffer.usdAmount).equals(
        toDecimalFixed(newOffer.coins / FREECASH_COIN_CONVERSION_RATE),
    );
    const hasDifferentName = oldOffer.name !== newOffer.name;
    const hasDifferentIsDesktop = oldOffer.isDesktop !== newOffer.isDesktop;
    const hasDifferentIsAndroid = oldOffer.isAndroid !== newOffer.isAndroid;
    const hasDifferentIsIos = oldOffer.isIos !== newOffer.isIos;
    return hasDifferentCoins || hasDifferentName || hasDifferentIsDesktop || hasDifferentIsAndroid || hasDifferentIsIos;
};

export const compareFreecashOfferDisplayInfo = (oldOffer: FreecashOffer, newOffer: FreecashOfferAPI) => {
    const hasDifferentDescription = oldOffer.description !== newOffer.description;
    const hasDifferentThumbnail = oldOffer.thumbnail !== newOffer.thumbnail;
    const hasDifferentUrl = oldOffer.url !== newOffer.url;
    return hasDifferentDescription || hasDifferentThumbnail || hasDifferentUrl;
};

export const getOfferById = async (id: string, tx: Prisma.TransactionClient = prisma) => {
    return await tx.freecashOffer.findFirst({ where: { id } });
};

export const deleteFreecashOffer = async (id: string, tx: Prisma.TransactionClient = prisma) => {
    await tx.freecashOfferTask.deleteMany({ where: { freecashOfferId: id } });
    return await tx.freecashOffer.delete({ where: { id } });
};
