# Workflow and Transaction Hashes

## Overview
This document provides step-by-step instructions and transaction hashes for deploying and interacting with the `MultiPartyWallet` contract on the kopli testnet.

## Deployment
1. Deploy `MultiPartyWallet`:
   - Command: `forge script script/DeployReactiveMultiPartyWallet.s.sol --rpc-url $kopli_RPC_URL --private-key $PRIVATE_KEY --gas-price 20000000000 --broadcast --legacy -vvvv`
   - Contract Address: `0xea7a667800ac855d739e2396ec12f67dbb144cc8` 
   - Transaction Hash: `https://kopli.reactscan.net/tx/0x567bcb256d03af21bd8cb4290f87b1066058ebb8346b47cec8f2ceae7157a252`

## Interaction Steps
1. Add Shareholder:
   - Command: `await wallet.addShareholder("0x003fdB58f24Cc1a46847ACD13bC83CD5D7c3E6EB", 25);`
   - Transaction Hash: `https://kopli.reactscan.net/tx/0x5a670c77f39688b47670ad4d0d61e2f63c5f71741f2cb449d9efd195fe767a5c`

2. Distribute Funds(Native Token - REACT):
   - Transfer REACT to contract:`https://kopli.reactscan.net/tx/0xae403a1e05e2e151de92438d6632566bb720dedab0136eb7efcbc814a7b478f2`
   - Command: `await wallet.distributeFunds();`
   - Transaction Hash: `https://kopli.reactscan.net/tx/0xfc2a5c53da1b4fd8e6ae5920328c3eb1991b772296db846c894c412fc341f58f`

## Additional Functionality
1. Distribute Token Funds:
   - Transfer Test tokens to contract: `https://kopli.reactscan.net/tx/0x4bba3cc7d27364d80af2a1883165fd6ff74b816d15ff64f724132bc9ea805d0a`
   - Command: `await wallet.distributeTokenFunds(0x867Fc8C285fDDDc1A5FfB04ce9B0685AE2718A20);`
   - Transaction Hash: `https://kopli.reactscan.net/tx/0x979698029cb89b3a0e600eb1e16f949e5a0c76fb079d39e2c8b81531525173bd`

## Explanation
Reactive Smart Contracts allow for seamless and automated fund distribution among multiple shareholders, ensuring transparency and efficiency.
