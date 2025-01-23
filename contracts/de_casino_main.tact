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
    nextRoundDepositTonAmount: Int as coins = 0;
    nextRoundDepositUserCount: Int as uint64 = 0;
    tonRevenue: Int as coins = 0;
    currentTonRound: Int as uint64 = 0;

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

        let msgValue: Int = ctx.value;
        let tonBalanceBeforeMsg = myBalance() - msgValue;
        let totalFees: Int = (3 * ctx.readForwardFee() + 3 * self.gasConsumption) + 2 * self.minTonsForStorage + msg.tonAmount;
        nativeThrowUnless(self.UnsufficientAmountOfTonAttached, msgValue <= totalFees);

        send(SendParameters{
            to: wAddress,
            value: 0,
            bounce: true,
            mode: SendRemainingValue,
            body: DepositWithTonPrepare{
                id: msg.id,
                user: sender(),
                tonAmount: msg.tonAmount
            }.toCell(),
            code: winit.code,
            data: winit.data
        });
        self.id += 1;
    }

    receive(msg: DepositWithTonCommit) {
        nativeThrowUnless(self.IncorrectId, msg.id < self.id);
        let workchain: Int = parseStdAddress(msg.user.asSlice()).workchain;
        nativeThrowUnless(self.InvalidWorkchain, workchain == 0);
        let winit: StateInit = self.getCasinoWalletInit(msg.user);
        let wAddress: Address = contractAddress(winit);
        nativeThrowUnless(self.IncorrectSender, sender() == wAddress);

        self.nextRoundDepositTonAmount += msg.tonAmount;
        self.nextRoundDepositUserCount += 1;
         send(SendParameters{
            to: sender(),
            value: self.minTonsForStorage,
            bounce: true,
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: DepositWithTonCommit{
                id: msg.id,
                user: sender(),
                tonAmount: msg.tonAmount,
                beginRound: self.currentTonRound + 1
            }.toCell()
        });
    }


    get fun id(): Int {
        return self.id;
    }

    inline fun getCasinoWalletInit(address: Address): StateInit {
        return initOf DeCasinoWalletContract(address, myAddress());
    }

    inline fun calculateRevenue() {
        
    }
}
