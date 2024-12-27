import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/de_casino_main_contract.tact',
    options: {
        debug: true,
    },
};
