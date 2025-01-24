import "@stdlib/deploy";
import "@stdlib/ownable";
import "./types.tact";
import "./messages.tact";
import "./error.tact";
import "./de_casino_wallet.tact";
import "./constants.tact";
import "./de_casino_revenue.tact";

struct DeCasinoMainContractState {
    id: Int as uint64 = 0;
    walletCode: Cell;
    revenueCode: Cell;
}

contract DeCasinoMainContract with Deployable, MainExitcodes,CommonConstants {
    id: Int as uint64 = 1;
    walletCode: Cell;
    revenueCode: Cell;
    usdtWalletCode: Cell;
    betcoinWalletCode: Cell;
    depositTonAmount: Int as coins = 0;
    nextRoundDepositTonAmount: Int as coins = 0;
    tonRevenue: Int as int64 = 0;
    currentRound: Int as uint64 = 0;
    currentRoundTimestamp: Int as uint32 = 0;

    init(initData:DecasinoMainContractStateInit) {
        self.walletCode = initData.walletCode;
        self.revenueCode = initData.revenueCode;
        self.usdtWalletCode = initData.usdtWalletCode;
        self.betcoinWalletCode = initData.betcoinWalletCode;
    }

    // ton
    receive(msg: DepositWithTon) {
        self.calculateRevenue();

        let ctx: Context = context();
        let winit: StateInit = self.getCasinoWalletInit(sender());
        let wAddress: Address = contractAddress(winit);

        let msgValue: Int = ctx.value;
        let tonBalanceBeforeMsg = myBalance() - msgValue;
        let totalFees: Int = (3 * ctx.readForwardFee() + 3 * self.gasConsumption) + 2 * self.minTonsForStorage + msg.tonAmount;
        nativeThrowUnless(self.UnsufficientAmountOfTonAttached, msgValue <= totalFees);

        send(SendParameters{
            to: wAddress,
            value: 0,
            bounce: true,
            mode: SendRemainingValue,
            body: DepositWithTonPrepare{
                id: msg.id,
                user: sender(),
                tonAmount: msg.tonAmount
            }.toCell(),
            code: winit.code,
            data: winit.data
        });
    }

    receive(msg: DepositWithTonCommit) {
        nativeThrowUnless(self.IncorrectId, msg.id <= self.id);
        let workchain: Int = parseStdAddress(msg.user.asSlice()).workchain;
        nativeThrowUnless(self.InvalidWorkchain, workchain == 0);
        let winit: StateInit = self.getCasinoWalletInit(msg.user);
        let wAddress: Address = contractAddress(winit);
        nativeThrowUnless(self.IncorrectSender, sender() == wAddress);

        self.nextRoundDepositTonAmount += msg.tonAmount;
         send(SendParameters{
            to: sender(),
            value: self.minTonsForStorage,
            bounce: true,
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: DepositWithTonCommit{
                id: msg.id,
                user: sender(),
                tonAmount: msg.tonAmount,
                beginRound: self.currentRound + 1
            }.toCell()
        });
    }

    receive(msg: BetWithTon){
        nativeThrowUnless(self.IncorrectPercentage, msg.percentage <= 45 && msg.percentage >= 1);
        nativeThrowUnless(self.IncorrectId, msg.id == self.id);

        let expectedProfit: Int = self.userWinPercentage*2;
        let winAmount: Int = expectedProfit*msg.tonAmount/msg.percentage;
        nativeThrowUnless(self.IncorrectExpectedProfit, winAmount < (self.depositTonAmount + self.tonRevenue));

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
        self.id += 1;
    }

    receive(msg: BetWithTonCommit) {
        nativeThrowUnless(self.IncorrectSender, sender() == myAddress());
        nativeRandomizeLt(); 
        let expectedProfit: Int = self.userWinPercentage*2;
        let winAmount: Int = expectedProfit*msg.tonAmount/msg.percentage;
        let randomResult: Int = random(0,100);
        let win: Bool = randomResult < msg.percentage;
        if win {
            send(SendParameters{
                to: msg.user,
                value: winAmount,
                bounce: true,
                mode: SendPayGasSeparately,
                body: emptyCell(),
            });
            self.tonRevenue -= msg.tonAmount;
        } else {
            self.depositTonAmount += msg.tonAmount;
        }
        self.calculateRevenue();
    }

    get fun id(): Int {
        return self.id;
    }

    inline fun getCasinoWalletInit(address: Address): StateInit {
        let initData: DecasinoWalletContractStateInit = DecasinoWalletContractStateInit{
            master: myAddress(),
            owner: address
        };
        return initOf DeCasinoWalletContract(initData);
    }

    inline fun calculateRevenue() {
        let currentTimestamp: Int = now();
        if (currentTimestamp - self.currentRoundTimestamp >= 7*24*60*60) {
            let tmpTonRevenueUnit: Int = self.tonRevenue/self.depositTonAmount;
            let initData: DecasinoRevenueContractStateInit = DecasinoRevenueContractStateInit{
                round: self.currentRound,
                unitTonRevenue: tmpTonRevenueUnit,
                master: myAddress(),
                walletCode: self.walletCode
            };
            let revenueInit: StateInit = initOf DeCasinoRevenueContract(initData);
            let revenueAddress: Address = contractAddress(revenueInit);
            send(SendParameters{
                to: revenueAddress,
                value: self.minTonsForStorage,
                bounce: true,
                mode: SendPayGasSeparately,
                body: emptyCell(),
                code: revenueInit.code,
                data: revenueInit.data
            });
            self.currentRound += 1;
            self.currentRoundTimestamp = currentTimestamp/(7*24*60*60)*(7*24*60*60);
            self.depositTonAmount += self.nextRoundDepositTonAmount;
            self.nextRoundDepositTonAmount = 0;
        }
    }
}

