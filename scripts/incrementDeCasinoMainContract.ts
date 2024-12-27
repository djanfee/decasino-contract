import { Address, toNano } from '@ton/core';
import { DeCasinoMainContract } from '../wrappers/DeCasinoMainContract';
import { NetworkProvider, sleep } from '@ton/blueprint';

export async function run(provider: NetworkProvider, args: string[]) {
    const ui = provider.ui();

    const address = Address.parse(args.length > 0 ? args[0] : await ui.input('DeCasinoMainContract address'));

    if (!(await provider.isContractDeployed(address))) {
        ui.write(`Error: Contract at address ${address} is not deployed!`);
        return;
    }

    const deCasinoMainContract = provider.open(DeCasinoMainContract.fromAddress(address));

    const counterBefore = await deCasinoMainContract.getCounter();

    await deCasinoMainContract.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Add',
            queryId: 0n,
            amount: 1n,
        }
    );

    ui.write('Waiting for counter to increase...');

    let counterAfter = await deCasinoMainContract.getCounter();
    let attempt = 1;
    while (counterAfter === counterBefore) {
        ui.setActionPrompt(`Attempt ${attempt}`);
        await sleep(2000);
        counterAfter = await deCasinoMainContract.getCounter();
        attempt++;
    }

    ui.clearActionPrompt();
    ui.write('Counter increased successfully!');
}
