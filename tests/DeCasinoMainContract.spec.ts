import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { DeCasinoMainContract } from '../wrappers/DeCasinoMainContract';
import '@ton/test-utils';

describe('DeCasinoMainContract', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let deCasinoMainContract: SandboxContract<DeCasinoMainContract>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        deCasinoMainContract = blockchain.openContract(await DeCasinoMainContract.fromInit(0n));

        deployer = await blockchain.treasury('deployer');

        const deployResult = await deCasinoMainContract.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: deCasinoMainContract.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and deCasinoMainContract are ready to use
    });

    it('should increase counter', async () => {
        const increaseTimes = 3;
        for (let i = 0; i < increaseTimes; i++) {
            console.log(`increase ${i + 1}/${increaseTimes}`);

            const increaser = await blockchain.treasury('increaser' + i);

            const counterBefore = await deCasinoMainContract.getCounter();

            console.log('counter before increasing', counterBefore);

            const increaseBy = BigInt(Math.floor(Math.random() * 100));

            console.log('increasing by', increaseBy);

            const increaseResult = await deCasinoMainContract.send(
                increaser.getSender(),
                {
                    value: toNano('0.05'),
                },
                {
                    $$type: 'Add',
                    queryId: 0n,
                    amount: increaseBy,
                }
            );

            expect(increaseResult.transactions).toHaveTransaction({
                from: increaser.address,
                to: deCasinoMainContract.address,
                success: true,
            });

            const counterAfter = await deCasinoMainContract.getCounter();

            console.log('counter after increasing', counterAfter);

            expect(counterAfter).toBe(counterBefore + increaseBy);
        }
    });
});
