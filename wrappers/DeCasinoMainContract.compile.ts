import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/de_casino_main.tact',
    // target: 'contracts/de_casino_wallet.tact',
    options: {
        debug: true,
    },
};
