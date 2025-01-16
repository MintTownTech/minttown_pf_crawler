import { Prisma } from 'minttown_pf_community/prisma/client';

import { prisma } from '../prisma';

type ComparisonNamePair = {
    comparisonName: string;
    baseComparisonName: string;
};

export const convertFreecashOfferTaskToComparisonName = async (
    title: string | null,
    tx: Prisma.TransactionClient = prisma,
) => {
    const baseComparisonName = (title ?? '(no title)')
        .toLowerCase()
        .replace(/\(.+$/, '')
        .replace(/(?<number>\d)k/, '$<number>000')
        .replace(/(\d)(st|nd|rd|th)/g, '$1')
        .replace(/(\d+),(?=\d{3})/g, '$1')
        .replace(/[^a-z0-9-]/g, '-')
        .replace(
            /(^|-)(complete|achieved|achieve|collect|reaches|make-any|make-a|reach-user-experience-to|reach|meters|the)-/g,
            '$1',
        )
        .replace(/challenges/g, 'challenge')
        .replace(/(^|-)(\d+)-(coins|restaurant|challenge|depth)/, '$1$3-$2')
        .replace(/-+/g, '-')
        .replace(/^-+|-+$/g, '')
        .substring(0, 190);

    const predefinedFreecashOfferTaskComparisonName = await tx.predefinedFreecashOfferTaskComparisonName.findFirst({
        where: { baseComparisonName },
    });
    const comparisonName = predefinedFreecashOfferTaskComparisonName?.comparisonName ?? baseComparisonName;
    return <ComparisonNamePair>{ comparisonName, baseComparisonName };
};
