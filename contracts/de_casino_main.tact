import "@stdlib/deploy";
import "@stdlib/ownable";
import "./types.tact";
import "./messages.tact";
import "./error.tact";
import "./de_casino_wallet.tact";
import "./constants.tact";

struct DeCasinoMainContractState {
    id: Int as uint64 = 0;
    walletCode: Cell;
    revenueCode: Cell;
}

contract DeCasinoMainContract with Deployable, MainExitcodes {
    const minTonsForStorage: Int = ton("0.015"); // 0.01 TON in original funC implementation. Increased as we have approx. x2 code size
    const gasConsumption: Int = ton("0.015"); // 0.015 TON in original funC implementation.
    id: Int as uint64 = 1;
    walletCode: Cell;
    revenueCode: Cell;
    usdtWalletCode: Cell;
    betcoinWalletCode: Cell;
    depositTonAmount: Int as coins = 0;

    init(initData:DecasinoMainContractStateInit) {
        self.walletCode = initData.walletCode;
        self.revenueCode = initData.revenueCode;
        self.usdtWalletCode = initData.usdtWalletCode;
        self.betcoinWalletCode = initData.betcoinWalletCode;
    }

    receive(msg: DepositWithTon) {
        nativeThrowUnless(self.IncorrectId, msg.id == self.id);

        let ctx: Context = context();

        let winit: StateInit = self.getCasinoWalletInit(sender());
        let wAddress: Address = contractAddress(winit);
        //We shouldn't send transfers to masterchain due to higher gas price
        nativeThrowUnless(self.InvalidDestinationWorkchain, wAddress.workchain == 0);

        send(SendParameters{
            to: wAddress,
            value: 0,
            bounce: false,
            mode: SendRemainingValue | SendIgnoreErrors,
            body: DepositWithTonInternal{
                id: msg.id,
                user: sender()
            }.toCell(),
            code: winit.code,
            data: winit.data
        });
        self.id += 1;
    }


    get fun id(): Int {
        return self.id;
    }

    inline fun getCasinoWalletInit(address: Address): StateInit {
        return initOf DeCasinoWalletContract(address, myAddress());
    }
}
