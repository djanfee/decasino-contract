import "@stdlib/deploy";
import "@stdlib/ownable";
import "./messages.tact";
contract DeCasinoMainContract with Deployable,Ownable {
    owner: Address;
    beginRound: Int;

    init(owner: Address, _beginRound: Int) {
        self.owner = owner;
        self.beginRound = _beginRound;
    }

    receive(msg: Withdraw) {
        self.requireOwner();
        

    }
}