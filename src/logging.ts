import path from 'node:path';

import { createLogger, format, transports } from 'winston';
import stringify from 'safe-stable-stringify';

const { combine, errors, printf } = format;

export const getLogger = (moduleName = __filename) => {
    return createLogger({
        level: 'debug',
        defaultMeta: { module: path.basename(moduleName) },
        format: combine(
            errors({ stack: true }),
            printf(({ level, ...entry }) => stringify({ severify: level, ...entry })!),
        ),
        transports: [new transports.Console()],
    });
};
