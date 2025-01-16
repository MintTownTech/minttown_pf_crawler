import { fetchOffers } from './freecash.api';

it('fetchOffers', async () => {
    try {
        const offers = await fetchOffers();
        expect(offers).toBeDefined();
    } catch (error) {
        debugger;
        throw error;
    }
});
