trait MainExitcodes {
    const IncorrectId: Int = 301;
}

trait WalletExitcodes {
    const IncorrectSender: Int = 401;
    const InvalidDestinationWorkchain: Int = 402;
    const AlreadyDeposited: Int = 403;
    const UnsufficientAmountOfTonAttached: Int = 404;
}