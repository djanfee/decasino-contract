trait MainExitcodes {
    const IncorrectId: Int = 301;
    const InvalidDestinationWorkchain: Int = 302;
}

trait WalletExitcodes {
    const IncorrectSender: Int = 401;
    const AlreadyDeposited: Int = 402;
    const UnsufficientAmountOfTonAttached: Int = 403;
}