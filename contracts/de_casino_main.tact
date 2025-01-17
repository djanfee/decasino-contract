import "@stdlib/deploy";
import "./types.tact";
import "./messages.tact";
import "./error.tact";

const USDT_JETTON_ADDRESS:Address = address("EQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id_sDs");
const BTC_JETTON_ADDRESS:Address = address("EQC_ruuOaFYpr1BC9HX6vJCjdZtmB-gvK3-Jg4jT127-GUbB");

contract DeCasinoMainContract with Deployable {
    id: Int as uint64 = 0;
    walletCode: Cell;
    revenueCode: Cell;

    init(initData:DecasinoMainContractStateInit) {
        self.walletCode = initData.walletCode;
        self.revenueCode = initData.revenueCode;
    }

    receive(msg: Deposit) {
       
        
    }


    get fun id(): Int {
        return self.id;
    }
}
