import "@stdlib/deploy";
import "@stdlib/ownable";
import "./messages.tact";
import "./error.tact";
contract DeCasinoMainContract with Deployable,Ownable {
    owner: Address;
    gasBuffer: Int = ton("0.1");
    tonDepositAmount: Int = 0;
    usdtDepositAmount: Int = 0;
    btcDepositAmount: Int = 0;
    tonOngoing: Bool = false;
    usdtOngoing: Bool = false;
    btcOngoing: Bool = false;
    tonBeginRound: Int = 0;
    usdtBeginRound: Int = 0;
    btcBeginRound: Int = 0;
    minTonDepositAmount: Int = ton("1");
    minUsdtDepositAmount: Int = ton("1");
    minBtcDepositAmount: Int = ton("1");

    init(owner: Address) {
        self.owner = owner;
    }

    receive(msg: CommitDeposit) {
        let ctx: Context = context();
        if ctx.value > 0 {
            if msg.tonOngoing {
                msg.tonOngoing = true;
            } else {
                if ctx.value<self.minTonDepositAmount+self.gasBuffer {
                    throw(invalidDepositAmount);
                }
                let effectiveTonAmount = (ctx.value - self.gasBuffer)/ton("1");
                self.tonDepositAmount += effectiveTonAmount;
                self.tonBeginRound = msg.tonBeginRound;
                self.tonOngoing = true;
                msg.tonOngoing = false;
            }
        }
        if msg.usdtAmount>0 {
            if msg.usdtAmount<self.minUsdtDepositAmount {
                throw(invalidDepositAmount);
            }
            let effectiveUsdtAmount = msg.usdtAmount/ton("1");
            self.usdtDepositAmount += effectiveUsdtAmount;
            self.usdtBeginRound = msg.usdtBeginRound;
            self.usdtOngoing = true;
            msg.usdtOngoing = false;
        }
        if msg.btcAmount>0 {
            if msg.btcAmount<self.minBtcDepositAmount {
                throw(invalidDepositAmount);
            }
            let effectiveBtcAmount = msg.btcAmount/ton("1");
            self.btcDepositAmount += effectiveBtcAmount;
            self.btcBeginRound = msg.btcBeginRound;
            self.btcOngoing = true;
            msg.btcOngoing = false;
        }
       
        send(SendParameters{
            bounce: false,
            to: sender(),
            value: 0,
            mode: SendIgnoreErrors,
            body: msg.toCell(),
        });
    }
}