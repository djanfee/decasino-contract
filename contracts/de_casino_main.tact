import "@stdlib/deploy";
import "./types.tact";
import "./messages.tact";
import "./error.tact";


contract DeCasinoMainContract with Deployable {
    id: Int as uint64;
    usdtJettonAddress: Address = address("EQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id_sDs");
    subContractCode: Cell;
    betCoinJettonAddress: Address = address("EQC_ruuOaFYpr1BC9HX6vJCjdZtmB-gvK3-Jg4jT127-GUbB");
    minDeposit: Int = ton("1");
    calculatedRoundTime: Int as uint32 = 0;
    tonRevenue: Int = 0;
    tonUserCount: Int = 0;


    init(initData:DecasinoMainContractStateInit) {
        self.id = 0; 
        self.subContractCode = initData.subContractCode;
    }

    receive(msg: DepositWithTon) {
        if msg.queryId!=self.id {
            throw(invalidQueryId);
        }

        let ctx: Context = context();
        if ctx.value<self.minDeposit {
            throw(invalidDepositAmount);
        }

        // check if it can begin new round
        let timeNow: Int = now();
        if timeNow>self.calculatedRoundTime {
            if timeNow%60*60*24==0 {
                
            }
        }


        // Notify the caller that the receiver was executed and forward remaining value back
        self.notify("Cashback".asComment()); 
        
    }



    get fun id(): Int {
        return self.id;
    }
}
