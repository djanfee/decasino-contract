import { toNano } from '@ton/core';
import { DeCasinoMainContract } from '../wrappers/DeCasinoMainContract';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const deCasinoMainContract = provider.open(await DeCasinoMainContract.fromInit(BigInt(Math.floor(Math.random() * 10000))));

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
