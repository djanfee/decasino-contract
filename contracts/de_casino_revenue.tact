import "@stdlib/deploy";
import "@stdlib/ownable";
import "./constants.tact";
import "./types.tact";

contract Contract3 with CommonConstants {
    round: Int as uint64;
    unitTonRevenue: Int as coins;
    master: Address;
    walletCode: Cell;
    
    init(initData: DecasinoRevenueContractStateInit) {
        self.round = initData.round;
        self.unitTonRevenue = initData.unitTonRevenue;
        self.master = initData.master;
        self.walletCode = initData.walletCode;
    }
}