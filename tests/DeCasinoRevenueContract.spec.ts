import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { Cell, toNano } from '@ton/core';
import { DeCasinoRevenueContract } from '../wrappers/DeCasinoRevenueContract';
import '@ton/test-utils';

describe('DeCasinoRevenueContract', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let owner: SandboxContract<TreasuryContract>;
    let master: SandboxContract<TreasuryContract>;
    let deCasinoRevenueContract: SandboxContract<DeCasinoRevenueContract>;
    beforeEach(async () => {
        blockchain = await Blockchain.create();
        
        deployer = await blockchain.treasury('deployer');
        owner = await blockchain.treasury('owner');
        master = await blockchain.treasury('master');

        deCasinoRevenueContract = blockchain.openContract(await DeCasinoRevenueContract.fromInit(owner.address));

        const deployResult = await deCasinoRevenueContract.send(
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
            to: deCasinoRevenueContract.address,
            deploy: true,
            success: true,
        });
    });

    it('should accept counter', async () => {
        
    });
});