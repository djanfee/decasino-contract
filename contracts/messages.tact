// ---------------------main contract messages-------------------
message DepositWithTon {
    id: Int as uint64;
    tonAmount: Int as coins;
}
message DepositWithTonInternal {
    id: Int as uint64;
    user: Address;
    tonAmount: Int as coins;
}
message DepositWithTonCommit {
    id: Int as uint64;
    user: Address;
    tonAmount: Int as coins;
}
message DepositWithBetCoin {
    id: Int as uint64;
    amount: Int as uint64;
}
message DepositWithUsdt {
    id: Int as uint64;
    amount: Int as uint64;
}

// ---------------------wallet messages-------------------
message Withdraw {
    id: Int as uint64;
}
message WithdrawBetCoin {
    id: Int as uint64;
}
message WithdrawUsdt {
    id: Int as uint64;
}

message CommitDeposit {
    usdtAmount: Int as uint64;
    btcAmount: Int as uint64;
    sender: Address;
    tonOngoing: Bool;
    usdtOngoing: Bool;
    btcOngoing: Bool;
    tonBeginRound: Int as uint64;
    usdtBeginRound: Int as uint64;
    btcBeginRound: Int as uint64;
}