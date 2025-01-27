// ---------------------main contract types-------------------
struct DecasinoMainContractStateInit {
    lpMinterAddress: Address;
    lpWalletCode: Cell;
}

// ---------------------lp contract types-------------------
struct DecasinoLpContractStateInit {
    owner: Address;
    jettonContent: Cell;
}