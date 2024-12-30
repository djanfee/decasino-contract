import "@stdlib/deploy";
import "./types.tact";
import "./messages.tact";
import "./error.tact";


contract DeCasinoMainContract with Deployable {
    id: Int as uint64;
    usdtJettonAddress: Address = address("EQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id_sDs");
    walletCode: Cell;
    betCoinJettonAddress: Address = address("EQC_ruuOaFYpr1BC9HX6vJCjdZtmB-gvK3-Jg4jT127-GUbB");
    minDeposit: Int = ton("1");
    calculatedRoundTime: Int as uint32 = 0;
    tonRevenue: Int = 0;
    tonUserCount: Int = 0;
    gasBuffer: Int = ton("0.1");
    newDepositAmount: Int = 0;
    newCount: Int = 0;


    init(initData:DecasinoMainContractStateInit) {
        self.id = 0; 
        self.walletCode = initData.walletCode;
    }

    receive(msg: DepositWithTon) {
        if msg.queryId!=self.id {
            throw(invalidQueryId);
        }

        let ctx: Context = context();
        if ctx.value<self.minDeposit+self.gasBuffer {
            throw(invalidDepositAmount);
        }

        let effectiveAmount = (ctx.value - self.gasBuffer)/ton("1");
        self.newDepositAmount += effectiveAmount;
        
        let walletAddress: Address = contractAddress(StateInit{
            code: self.walletCode,
            data: DecasinoWalletStateInit{
                usdtJettonAddress: self.usdtJettonAddress,
            }.toCell(),
        });

        nativeReserve(effectiveAmount*1_000_000_000, ReserveExact | ReserveBounceIfActionFail);
        send(SendParameters{
            bounce: false,
            to: walletAddress,
            value: 0,
            mode: SendRemainingValue | SendIgnoreErrors,
            body: CommitDeposit{
                amount: effectiveAmount,
            }.toCell(),
            code: self.walletCode,
            data: DecasinoWalletStateInit{
                usdtJettonAddress: self.usdtJettonAddress,
            }.toCell(),
        });
        
    }



    get fun id(): Int {
        return self.id;
    }
}
