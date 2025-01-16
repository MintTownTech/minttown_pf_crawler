import Decimal from 'decimal.js';
import { Prisma, FreecashOfferTask } from 'minttown_pf_community/prisma/client';

import { prisma } from '../prisma';
import { toDecimalFixed, FREECASH_COIN_CONVERSION_RATE } from './freecash.utils';
import { FreecashOfferTaskAPI } from './freecash.api.type';

export const updateFreecashOfferTask = async (
    id: string,
    data: Prisma.FreecashOfferTaskUpdateInput,
    tx: Prisma.TransactionClient = prisma,
) => {
    return await tx.freecashOfferTask.update({ where: { id }, data });
};

export const compareFreecashTaskKeyInfo = (oldTasks: FreecashOfferTask[], newTasks: FreecashOfferTaskAPI[]) => {
    if (oldTasks.length !== newTasks.length) {
        return true;
    }
    for (const oldTask of oldTasks) {
        const newTask = newTasks.find((item) => item.id.toString() === oldTask.taskId);
        if (!newTask) {
            return true;
        }
        const newUsdAmount = toDecimalFixed(newTask.coins / FREECASH_COIN_CONVERSION_RATE);
        const oldUsdAmount = new Decimal(oldTask.usdAmount);
        const hasDifferentUsdAmount = !newUsdAmount.equals(oldUsdAmount);
        if (hasDifferentUsdAmount) {
            return true;
        }
    }
    return false;
};
