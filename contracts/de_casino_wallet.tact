import "@stdlib/deploy";
import "@stdlib/ownable";
import "./messages.tact";
contract DeCasinoMainContract with Deployable,Ownable {
    owner: Address;
    beginRound: Int;
    depositAmount: Int;
    ongoing: Bool;

    init(owner: Address, _beginRound: Int) {
        self.owner = owner;
        self.beginRound = _beginRound;
        self.depositAmount = 0;
        self.ongoing = false;
    }

    receive(msg: CommitDeposit) {
        if (self.ongoing) {
            send(SendParameters{
                bounce: false,
                to: self.owner,
                value: 0,
                mode: SendPayGasSeparately,
                body: ,
                code: ,
                data: ,
            });
        }
        self.ongoing = true;
    }

    
}