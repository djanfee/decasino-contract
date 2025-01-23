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

    receive(msg: DepositWithTonPrepare) {
        nativeThrowUnless(self.IncorrectSender, self.master == sender());
        if (self.tonOngoing) {
            self.userRefund(msg.user, self.AlreadyDeposited);
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

    inline fun userRefund(user: Address, code: Int) {
        send(SendParameters{
            to: user,
            value: 0,
            bounce: false,
            mode: SendRemainingValue | SendIgnoreErrors,
            body: UserRefundInfo{
                code: code
            }.toCell()
        });
    }
}