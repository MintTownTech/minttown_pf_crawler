import Decimal from 'decimal.js';

export const FREECASH_COIN_CONVERSION_RATE = 1000;

export const toDecimalFixed = (value: number | string | Decimal) => {
    return new Decimal(value).toDecimalPlaces(10);
};
