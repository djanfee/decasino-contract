import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { Cell, toNano } from '@ton/core';
import { DeCasinoWalletContract } from '../wrappers/DeCasinoWalletContract';
import '@ton/test-utils';

describe('DeCasinoWalletContract', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let owner: SandboxContract<TreasuryContract>;
    let master: SandboxContract<TreasuryContract>;
    let deCasinoWalletContract: SandboxContract<DeCasinoWalletContract>;
    beforeEach(async () => {
        blockchain = await Blockchain.create();
        
        deployer = await blockchain.treasury('deployer');
        owner = await blockchain.treasury('owner');
        master = await blockchain.treasury('master');

        deCasinoWalletContract = blockchain.openContract(await DeCasinoWalletContract.fromInit(owner.address,master.address));

        const deployResult = await deCasinoWalletContract.send(
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
            to: deCasinoWalletContract.address,
            deploy: true,
            success: true,
        });
    });

    it('should accept counter', async () => {
        
    });
});