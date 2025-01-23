trait MainExitcodes {
    const IncorrectId: Int = 301;
    const InvalidWorkchain: Int = 302;
    const IncorrectSender: Int = 303;
    const UnsufficientAmountOfTonAttached: Int = 304;
}

trait WalletExitcodes {
    const IncorrectSender: Int = 401;
    const AlreadyDeposited: Int = 402;
    const UnsufficientAmountOfTonAttached: Int = 403;
}