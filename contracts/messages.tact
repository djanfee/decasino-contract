// ---------------------main contract messages-------------------
message DepositWithTon {
    queryId: Int as uint64;
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