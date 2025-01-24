// ---------------------main contract types-------------------
struct DecasinoMainContractStateInit {
    walletCode: Cell;
    revenueCode: Cell;
    usdtWalletCode: Cell;
    betcoinWalletCode: Cell;
}


// ---------------------wallet contract types-------------------
struct DecasinoWalletContractStateInit {
    master: Address;
    owner: Address;
}

// ---------------------revenue contract types-------------------
struct DecasinoRevenueContractStateInit {
    round: Int as uint64;
    unitTonRevenue: Int as coins;
    master: Address;
    walletCode: Cell;
}
