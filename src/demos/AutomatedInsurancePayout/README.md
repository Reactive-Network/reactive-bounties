


## Implement automated insurance Payouts

Target Bounty  : [Automated Insurance Payouts](https://github.com/Reactive-Network/reactive-bounties/issues/6)


## Contact me

linkedin : [Aditya Chaurasia](https://www.linkedin.com/in/aditya-chaurasia-10998622b/?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app)

email: 1212aditya11@gmail.com




## overview of submission 

our submission enables user to auto pay the Insurance when ever the insurance company announces that the new installment day is arrived so when ever the installment is arrived the user will automatically pay their amount 

## flow of our submission

when ever user registerForInsurance then for every installment the `INSURANCE_MANAGER` triggers `triggerNewInstallment` function it emits event for user to pay insurance here reactive network comes into play where reactive network monitor's Insurance contract and when ever it emits `Payout` event for user it triggers back the `UserPayoutWallet` to pay for the insurace of the user so that user's insurance will be paid automatically


## DEPLOYMENT AND STEP BY STEP EXPLANATION 


To deploy testnet contracts to Sepolia, follow these steps, making sure you substitute the appropriate keys, addresses, and endpoints where necessary. You will need the following environment variables configured appropriately to follow this script:

```bash 
export SEPOLIA_RPC=
export SEPOLIA_PRIVATE_KEY=
export SEPOLIA_MANAGER_PRIVATE_KEY=
export SEPOLIA_MANAGER_PUBLIC_ADDR=
export REACTIVE_RPC=
export REACTIVE_PRIVATE_KEY=
export SYSTEM_CONTRACT_ADDR=
export CALLBACK_SENDER=
```


You can use the recommended Sepolia RPC URL: `https://rpc2.sepolia.org`.

```bash
forge install openzeppelin/openzeppelin-contracts
```

## Step 1 

MANAGER will deploy the Insurance contract which has all functionalities of insurance and assign the deployed contract address to `INSURANCE_CONTRACT_ADDR`

```bash
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_MANAGER_PRIVATE_KEY src/demos/AutomatedInsurancePayout/InsuranceContract.sol:Insurance --constructor-args $SEPOLIA_MANAGER_PUBLIC_ADDR --legacy

```
transaction hash : [0x38a6f759ff8085b24e3e15661209fa8a68bcbeec80fc96d5ae1b0ad5dd5f0f74](https://sepolia.etherscan.io/tx/0x38a6f759ff8085b24e3e15661209fa8a68bcbeec80fc96d5ae1b0ad5dd5f0f74)


## Step 2 

MANAGER Will add plans of insurance 

```bash
cast send $INSURANCE_CONTRACT_ADDR 'addPlans(string,uint256,uint256,uint256,uint256)' --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_MANAGER_PRIVATE_KEY  <plan name> <total_pay> <installment amount> <no of installments> < no of months>  --legacy 

```

transaction hash :[0xd100aae59b673bdd41b78c5750f1cc78ab68c68f7e366a065366a2e408896b30](https://sepolia.etherscan.io/tx/0xd100aae59b673bdd41b78c5750f1cc78ab68c68f7e366a065366a2e408896b30)


## Step 3 

user registers for insurance 

```bash
cast send $INSURANCE_CONTRACT_ADDR 'registerForInsurance(string)' --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY  <plan name>  --legacy 
```
Transaction Hash : [0x3eba59c5d3bd14d51f00ef5cd68af62a7dfb46e156f922daae9797a4ee7caba0](https://sepolia.etherscan.io/tx/0x3eba59c5d3bd14d51f00ef5cd68af62a7dfb46e156f922daae9797a4ee7caba0)

## step 4 

user creates a wallet for making automated payouts and assign wallet deployed address to `USER_PAYOUT_WALLET_ADDR`

```bash 
forge create --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/demos/AutomatedInsurancePayout/UserPayoutWallet.sol:UserPayoutWallet --constructor-args $CALLBACK_SENDER  $INSURANCE_CONTRACT_ADDR --legacy 

```
transaction hash :[0x11e513a9ad64a679b56f158726387089808ba7205779218b05e88a18d199a1b7](https://sepolia.etherscan.io/tx/0x11e513a9ad64a679b56f158726387089808ba7205779218b05e88a18d199a1b7)

## Step 5 

user adds funds to wallet 
```bash 
cast send $USER_PAYOUT_WALLET_ADDR --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY --value 0.01ether --legacy 
```
transaction hash :[0xff950c95c6028254156c65138229403704f2e5de966899bf4b31c133cbca53aa](https://sepolia.etherscan.io/tx/0xff950c95c6028254156c65138229403704f2e5de966899bf4b31c133cbca53aa)

## Step 6 

now user will create a reactive Contract which subscribes to insurance contract and will be monitoreing event emited by Insurance contract for user to make a pay out 

- when ever the event is emited it automatically trigger UserPayoutWallet to payback the insurance 


```bash

forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/demos/AutomatedInsurancePayout/reactive.sol:Reactive --constructor-args $SYSTEM_CONTRACT_ADDR $INSURANCE_CONTRACT_ADDR $USER_PAYOUT_WALLET_ADDR --legacy
```
    transaction hash :[12](https://kopli.reactscan.net/rvm/0xcbfa155b74ad8abb3b0303c2ef2a55af9c3fb5bb/12)


## Step 7 

when ever MANAGER trigers payout our wallet automaticallypays the amount make sure you have necessary funds in wallet

```bash 
cast send $INSURANCE_CONTRACT_ADDR 'triggerNewInstallment(string)' --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_MANAGER_PRIVATE_KEY  <plan name>  --legacy 
```

transaction hash : [0x69c946d569d8a547d958ebb02343c8c863399a451bc0f6ddec3d8abdabe91d16](https://sepolia.etherscan.io/tx/0x69c946d569d8a547d958ebb02343c8c863399a451bc0f6ddec3d8abdabe91d16)

this transaction emitted an `payout event` which is monitered by reactive network and triggered or reactive contract 
transaction hash :[13](https://kopli.reactscan.net/rvm/0xcbfa155b74ad8abb3b0303c2ef2a55af9c3fb5bb/13)

this reactive network triggered userPayoutWallet to pay the insurance 
transaction hash : [0x28ddeeef13f98769101b7142cfae90ac2c9bae0eeacc867fc22f132b7cf3e592](https://sepolia.etherscan.io/tx/0x28ddeeef13f98769101b7142cfae90ac2c9bae0eeacc867fc22f132b7cf3e592)
