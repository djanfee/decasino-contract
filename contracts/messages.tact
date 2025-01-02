// ---------------------main contract messages-------------------
message Deposit {
    queryId: Int as uint64;
    usdtAmount: Int as uint64;
    btcAmount: Int as uint64;
}
message DepositWithBetCoin {
    queryId: Int as uint64;
    amount: Int as uint64;
}
message DepositWithUsdt {
    queryId: Int as uint64;
    amount: Int as uint64;
}

// ---------------------wallet messages-------------------
message Withdraw {
    queryId: Int as uint64;
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