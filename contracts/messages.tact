// ---------------------main contract messages-------------------
message Deposit {
    id: Int as uint64;
    tonAmount: Int as coins;
}

message BetWithTon {
    id: Int as uint64;
    tonAmount: Int as coins;
    percentage: Int as uint16;
}
message BetWithTonCommit {
    id: Int as uint64;
    user: Address;
    tonAmount: Int as coins;
    percentage: Int as uint16;
}

// ---------------------lp contract messages-------------------