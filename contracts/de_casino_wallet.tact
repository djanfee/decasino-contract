import "@stdlib/deploy";
import "@stdlib/ownable";
import "./messages.tact";
import "./error.tact";
import "./constants.tact";
import "./types.tact";

contract DeCasinoWalletContract with Deployable,Ownable,WalletExitcodes {
    const gasConsumption: Int = ton("0.02");
    const minTonsForStorage: Int = ton("0.02");
    const minTonDepositAmount: Int = ton("1");
    master: Address;
    owner: Address;
    tonDepositAmount: Int as coins = 0;
    tonOngoing: Bool = false;
    tonBeginRound: Int as uint64 = 0;

    init(owner: Address, master: Address) {
        self.owner = owner;
        self.master = master;
    }

    receive(msg: DepositWithTonInternal) {
        nativeThrowUnless(self.IncorrectSender, self.master == sender());
        if (self.tonOngoing) {
            self.userRefund(msg, self.AlreadyDeposited);
            return;
        }
        let ctx: Context = context();
        let msgValue: Int = ctx.value;
        let tonBalanceBeforeMsg = myBalance() - msgValue;
        let storageFee = self.minTonsForStorage - min(tonBalanceBeforeMsg, self.minTonsForStorage);
        let totalFees: Int = (2*ctx.readForwardFee() + 2 * self.gasConsumption) + self.minTonsForStorage + msg.tonAmount + storageFee;
        if (msgValue <= totalFees) {
            self.userRefund(msg, self.UnsufficientAmountOfTonAttached);
            return;
        }
        send(SendParameters{
            to: self.master,
            value: 0,
            bounce: true,
            mode: SendRemainingValue,
            body: DepositWithTonCommit{
                id: msg.id,
                user: sender(),
                tonAmount: msg.tonAmount
            }.toCell(),
        });
        let timestamp = now();
        self.tonBeginRound = timestamp/(60*60*24*7)+1;
        self.tonOngoing = true;
        self.tonDepositAmount = msg.tonAmount;
    }

    inline fun userRefund(msg: DepositWithTonInternal, code: Int) {
        send(SendParameters{
            to: msg.user,
            value: 0,
            bounce: false,
            mode: SendRemainingValue | SendIgnoreErrors,
            body: UserRefundInfo{
                code: code
            }.toCell()
        });
    }
}