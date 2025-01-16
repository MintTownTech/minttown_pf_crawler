import { Prisma } from 'minttown_pf_community/prisma/client';

import { prisma } from '../prisma';

type OfferAppNamePair = {
    offerAppName: string;
    baseOfferAppName: string;
};

export const convertFreecashOfferSlugToOfferAppName = async (slug: string, tx: Prisma.TransactionClient = prisma) => {
    const baseOfferAppName = slug
        .replace(/-[a-zA-Z0-9]+$/, '')
        .replace(/-(ios|android|us)($|-.*$)/, '')
        .replace(/-+$/, '');
    const predefinedFreecashOfferOfferAppName = await tx.predefinedFreecashOfferOfferAppName.findFirst({
        where: { baseOfferAppName },
    });
    const offerAppName = predefinedFreecashOfferOfferAppName?.offerAppName
        ? predefinedFreecashOfferOfferAppName.offerAppName
        : baseOfferAppName;
    return <OfferAppNamePair>{ offerAppName, baseOfferAppName };
};
