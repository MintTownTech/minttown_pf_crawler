import { prisma } from '../prisma';
import {
    updateOffersAsNotAvailable,
    getOfferBySlug,
    createFreecashOffer,
    updateFreecashOffer,
    getOfferById,
    deleteFreecashOffer,
} from './freecash-offer.service';

it('updateAllOffersAsNotAvailable', async () => {
    try {
        await updateOffersAsNotAvailable();
    } catch (error) {
        debugger;
        throw error;
    }
});

it('getOfferBySlug', async () => {
    try {
        const offer = await getOfferBySlug('star-trek-fleet-command-eeu9wy');
        expect(offer?.id).toBe('cm5pr6jl800025w5zysd8u0ru');
    } catch (error) {
        debugger;
        throw error;
    }
});

it('createFreecashOffer', async () => {
    try {
        const existingOffer = await getOfferBySlug('star-trek-fleet-command-eeu9wy')!;
        // @ts-expect-error: Ignore
        const { id, slug, tasks, ...rest } = existingOffer;
        const offer = await createFreecashOffer(
            // @ts-expect-error: Ignore
            {
                ...rest,
                id: 'abc',
                slug: 'xyz',
                tasks: {
                    create: tasks.map((t: any) => {
                        const { __typename, freecashOfferId, id, offerId, coins: taskCoins, ...cleanedTask } = t;
                        return {
                            ...cleanedTask,
                            taskId: id.toString(),
                            usdAmount: 3.14,
                            status: 'safeStringify(task.status)',
                        };
                    }),
                },
            },
        );
        await deleteFreecashOffer(offer.id);
    } catch (error) {
        debugger;
        throw error;
    }
});

it('ababab', async () => {
    try {
        await prisma.$transaction(async (tx) => {
            await updateOffersAsNotAvailable(tx);
            const available = await tx.freecashOffer.findMany({ where: { isAvailable: true } });
            debugger;
        });
    } catch (error) {
        debugger;
        throw error;
    }
});
