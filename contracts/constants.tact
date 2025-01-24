trait MainExitcodes {
    const IncorrectId: Int = 301;
    const InvalidWorkchain: Int = 302;
    const IncorrectSender: Int = 303;
    const UnsufficientAmountOfTonAttached: Int = 304;
    const IncorrectPercentage: Int = 305;
    const IncorrectExpectedProfit: Int = 306;
}

trait WalletExitcodes {
    const IncorrectSender: Int = 401;
    const AlreadyDeposited: Int = 402;
    const UnsufficientAmountOfTonAttached: Int = 403;
    const IncorrectId: Int = 404;
}

trait CommonConstants {
    const minTonsForStorage: Int = ton("0.015"); // 0.01 TON in original funC implementation. Increased as we have approx. x2 code size
    const gasConsumption: Int = ton("0.015"); // 0.015 TON in original funC implementation.
    const minTonDepositAmount: Int = ton("1");
    const userWinPercentage: Int = 48;
}