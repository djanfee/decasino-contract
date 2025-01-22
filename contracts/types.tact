// ---------------------main contract types-------------------
struct DecasinoMainContractStateInit {
    walletCode: Cell;
    revenueCode: Cell;
    usdtWalletCode: Cell;
    betcoinWalletCode: Cell;
}


// ---------------------wallet contract types-------------------
struct UserRefundInfo {
    code: Int;
}