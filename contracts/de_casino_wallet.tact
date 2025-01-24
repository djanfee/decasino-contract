import "@stdlib/deploy";
import "@stdlib/ownable";
import "./messages.tact";
import "./error.tact";
import "./constants.tact";
import "./types.tact";

contract DeCasinoWalletContract with Ownable,WalletExitcodes,CommonConstants {
    id: Int as uint64 = 1;
    master: Address;
    owner: Address;
    tonDepositAmount: Int as coins = 0;
    tonOngoing: Bool = false;
    tonBeginRound: Int as uint64 = 0;

    init(initData: DecasinoWalletContractStateInit) {
        self.owner = initData.owner;
        self.master = initData.master;
    }

    receive(msg: DepositWithTonPrepare) {
        nativeThrowUnless(self.IncorrectSender, self.master == sender());
        if (self.tonOngoing) {
            send(SendParameters{
                to: msg.user,
                value: 0,
                bounce: false,
                mode: SendRemainingValue,
                body: emptyCell()
            });
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
                tonAmount: msg.tonAmount,
                beginRound: 0
            }.toCell(),
        });
    }

    receive(msg: DepositWithTonCommit) {
        nativeThrowUnless(self.IncorrectSender, self.master == sender());
        self.tonOngoing = true;
        self.tonBeginRound = msg.beginRound;
        self.tonDepositAmount = msg.tonAmount;
    }

    receive(msg: BetWithTon) {
        nativeThrowUnless(self.IncorrectId, msg.id == self.id);
        let ctx: Context = context();
        let msgValue: Int = ctx.value;
        let tonBalanceBeforeMsg = myBalance() - msgValue;
        let totalFees: Int = (2 * ctx.readForwardFee() + 2 * self.gasConsumption) + self.minTonsForStorage + msg.tonAmount;
        nativeThrowUnless(self.UnsufficientAmountOfTonAttached, msgValue <= totalFees);


    }
}