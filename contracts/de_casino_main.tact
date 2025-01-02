import "@stdlib/deploy";
import "./types.tact";
import "./messages.tact";
import "./error.tact";


contract DeCasinoMainContract with Deployable {
    id: Int as uint64;
    usdtJettonAddress: Address = address("EQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id_sDs");
    walletCode: Cell;
    betCoinJettonAddress: Address = address("EQC_ruuOaFYpr1BC9HX6vJCjdZtmB-gvK3-Jg4jT127-GUbB");
    calculatedRound: Int as uint64 = 0;
    tonRevenue: Int = 0;
    tonUserCount: Int = 0;
    gasBuffer: Int = ton("0.1");
    newTonDepositAmount: Int = 0;
    newUsdtDepositAmount: Int = 0;
    newBtcDepositAmount: Int = 0;
    minTonDepositAmount: Int = ton("1");
    minUsdtDepositAmount: Int = ton("1");
    minBtcDepositAmount: Int = ton("1");
    newCount: Int = 0;


    init(initData:DecasinoMainContractStateInit) {
        self.id = 0; 
        self.walletCode = initData.walletCode;
    }

    receive(msg: Deposit) {
        if msg.queryId!=self.id {
            throw(invalidQueryId);
        }

        let ctx: Context = context();
        if ctx.value<self.minTonDepositAmount+self.gasBuffer {
            throw(invalidDepositAmount);
        }

        let walletAddress: Address = contractAddress(StateInit{
            code: self.walletCode,
            data: beginCell().endCell(),
        });

        send(SendParameters{
            bounce: false,
            to: walletAddress,
            value: 0,
            mode: SendRemainingValue | SendIgnoreErrors,
            body: CommitDeposit{
                usdtAmount: msg.usdtAmount,
                btcAmount: msg.btcAmount,
                beginRound: self.calculatedRound+1,
                sender: sender(),
                tonOngoing: false,
                usdtOngoing: false,
                btcOngoing: false,
            }.toCell(),
            code: self.walletCode,
            data: beginCell().endCell(),
        });
        
    }

    receive(msg: CommitDeposit) {
        // if msg.ongoing {
        //     send(SendParameters{
        //         bounce: false,
        //         to: msg.sender,
        //         value: 0,
        //         mode: SendIgnoreErrors,
        //         body: msg.toCell(),
        //     });
        //     return;
        // }
        // let ctx: Context = context();
        // let effectiveTonAmount = (ctx.value - self.gasBuffer)/ton("1");
        // self.newTonDepositAmount += effectiveTonAmount;
        // let effectiveUsdtAmount = msg.usdtAmount/ton("1");
        // self.newUsdtDepositAmount += effectiveUsdtAmount;
        // let effectiveBtcAmount = msg.btcAmount/ton("1");
        // self.newBtcDepositAmount += effectiveBtcAmount;
    }


    get fun id(): Int {
        return self.id;
    }
}
