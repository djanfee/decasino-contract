import "@stdlib/deploy";
import "@stdlib/ownable";
import "./types.tact";
import "./messages.tact";
import "./constants.tact";

struct DeCasinoMainContractState {
    id: Int as uint64 = 0;
    walletCode: Cell;
    revenueCode: Cell;
}

contract DeCasinoMainContract with Deployable, MainExitcodes,CommonConstants {
    id: Int as uint64 = 1;
    lpMinterAddress: Address;
    lpWalletCode: Cell;
    depositAmount: Int as coins = 0;
    revenue: Int as coins = 0;
    lpAmount: Int as coins = 0;


    init(initData:DecasinoMainContractStateInit) {
        self.lpMinterAddress = initData.lpMinterAddress;
        self.lpWalletCode = initData.lpWalletCode;
    }

    receive(msg: Deposit) {
        let tonAmount: Int = msg.tonAmount / ton("1");
        nativeThrowUnless(self.InvalidParams, tonAmount <= 0);
        let ctx: Context = context();
        let fwdFee: Int = ctx.readForwardFee();
        let totalFees: Int = (2 * fwdFee + 2 * self.gasConsumption) + self.minTonsForStorage + msg.tonAmount;
        nativeThrowUnless(self.UnsufficientAmountOfTonAttached, ctx.value <= totalFees);

        self.depositAmount += msg.tonAmount;

        let lpAmount: Int = 0;
        let lpPreice = (msg.tonAmount + self.depositAmount + self.revenue) / self.lpAmount;

        let masterCell: Cell = beginCell().storeUint(0x178d4519, 32).storeUint(self.id, 64).storeCoins(msg.tonAmount).storeAddress(sender()).endCell();

        send(SendParameters{
            to: self.lpMinterAddress,
            value: 0,
            bounce: true,
            mode: SendPayGasSeparately,
            body: beginCell().storeInt(21, 32).storeUint(self.id, 64).storeAddress(sender()).storeCoins(msg.tonAmount).storeRef(masterCell).endCell(),
        });
    }

     receive(msg: BetWithTon){
        nativeThrowUnless(self.IncorrectPercentage, msg.percentage <= 45 && msg.percentage >= 1);

        let expectedWinAmount: Int = self.userWinPercentage * 2 * msg.tonAmount / msg.percentage;
        nativeThrowUnless(self.IncorrectExpectedProfit, expectedWinAmount < (self.depositAmount + self.revenue));

        let ctx: Context = context();
        let msgValue: Int = ctx.value;
        let tonBalanceBeforeMsg = myBalance() - msgValue;
        let totalFees: Int = (ctx.readForwardFee() + self.gasConsumption) + self.minTonsForStorage + msg.tonAmount;
        nativeThrowUnless(self.UnsufficientAmountOfTonAttached, msgValue <= totalFees);


        send(SendParameters{
            to: myAddress(),
            value: 0,
            bounce: true,
            mode: SendRemainingValue,
            body: BetWithTonCommit{
                id: msg.id,
                user: sender(),
                tonAmount: msg.tonAmount,
                percentage: msg.percentage
            }.toCell(),
        });
    }

    receive(msg: BetWithTonCommit) {
        nativeThrowUnless(self.IncorrectSender, sender() == myAddress());
        nativeRandomizeLt(); 
        let expectedWinAmount: Int = self.userWinPercentage * 2 * msg.tonAmount / msg.percentage;
        let randomResult: Int = random(0,100);
        let win: Bool = randomResult < msg.percentage;
        if win {
            send(SendParameters{
                to: msg.user,
                value: expectedWinAmount,
                bounce: true,
                mode: SendPayGasSeparately,
                body: emptyCell(),
            });
            self.revenue -= msg.tonAmount;
        } else {
            self.revenue += msg.tonAmount;
        }
    }

    get fun id(): Int {
        return self.id;
    }
}

