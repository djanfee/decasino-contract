import { toNano,Cell } from '@ton/core';
import { DeCasinoMainContract } from '../wrappers/DeCasinoMainContract';
import { NetworkProvider } from '@ton/blueprint';
import {DecasinoMainContractStateInit} from '../build/DeCasinoMainContract/tact_DeCasinoMainContract';
import fs from 'fs';

export async function run(provider: NetworkProvider) {
    let initData:DecasinoMainContractStateInit = {
        $$type: 'DecasinoMainContractStateInit',
        walletCode: Cell.fromBoc(Buffer.from(await fs.readFileSync('./build/DeCasinoMainContract/tact_DeCasinoMainContract.code.fc')))[0],
        revenueCode: Cell.fromBoc(Buffer.from(await fs.readFileSync('./build/DeCasinoMainContract/tact_DeCasinoMainContract.code.fc')))[0],
    };
    const deCasinoMainContract = provider.open(await DeCasinoMainContract.fromInit(initData));

    await deCasinoMainContract.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(deCasinoMainContract.address);

    console.log('ID', await deCasinoMainContract.getId());
}
