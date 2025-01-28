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

message(0xf8a7ea5) JettonTransfer {
    queryId: Int as uint64;
    amount: Int as coins;
    destination: Address;
    responseDestination: Address?;
    customPayload: Cell? = null;
    forwardTonAmount: Int as coins;
    forwardPayload: Slice as remaining;
}
// ---------------------lp contract messages-------------------
