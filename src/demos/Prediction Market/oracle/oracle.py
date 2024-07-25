# fgi_listener.py
import requests
from web3 import Web3
import time
import os
API_URL = 'https://api.coin-stats.com/v2/fear-greed?type=all'
CONTRACT_ADDRESS = os.getenv("CONTRACT_ADDRESS")
PRIVATE_KEY = os.getenv("PRIVATE_KEY")
INFURA_URL = os.getenv("INFURA_URL")
CHECK_INTERVAL = os.getenv("CHECK_INTERVAL")  # Interval to check the API (in seconds)
gwei= os.getenv("gwei")


#Reactive 0xAeAd482f1a974B6b59D268b141d173Faf488FE93
# Initialize Web3
web3 = Web3(Web3.HTTPProvider(INFURA_URL))
# Smart Contract ABI (Replace with your actual ABI)
CONTRACT_ABI = [
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": False,
				"internalType": "uint256",
				"name": "marketId",
				"type": "uint256"
			},
			{
				"indexed": False,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": False,
				"internalType": "enum MultiMarketPrediction.BetOption",
				"name": "option",
				"type": "uint8"
			},
			{
				"indexed": False,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "BetPlaced",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": False,
				"internalType": "uint256",
				"name": "marketId",
				"type": "uint256"
			},
			{
				"indexed": False,
				"internalType": "uint256",
				"name": "FGI",
				"type": "uint256"
			}
		],
		"name": "FGISet",
		"type": "event"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": False,
				"internalType": "uint256",
				"name": "marketId",
				"type": "uint256"
			}
		],
		"name": "MarketCreated",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_marketId",
				"type": "uint256"
			}
		],
		"name": "payout",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": False,
		"inputs": [
			{
				"indexed": False,
				"internalType": "uint256",
				"name": "marketId",
				"type": "uint256"
			},
			{
				"indexed": False,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": False,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "Payout",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_marketId",
				"type": "uint256"
			},
			{
				"internalType": "enum MultiMarketPrediction.BetOption",
				"name": "_option",
				"type": "uint8"
			}
		],
		"name": "placeBet",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_marketId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_fgi",
				"type": "uint256"
			}
		],
		"name": "setFGI",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_marketId",
				"type": "uint256"
			}
		],
		"name": "getUserBalance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "marketCount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "markets",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "totalBetFear",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "totalBetGreed",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "totalBalance",
				"type": "uint256"
			},
			{
				"internalType": "bool",
				"name": "resultSet",
				"type": "bool"
			},
			{
				"internalType": "enum MultiMarketPrediction.BetOption",
				"name": "result",
				"type": "uint8"
			},
			{
				"internalType": "uint256",
				"name": "FGI",
				"type": "uint256"
			},
			{
				"internalType": "enum MultiMarketPrediction.MarketStatus",
				"name": "status",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]

contract = web3.eth.contract(address=CONTRACT_ADDRESS, abi=CONTRACT_ABI)

def fetch_fgi():
    try:
        response = requests.get(API_URL)
        fgi_data = response.json()
        fgi_value = fgi_data['data'][0]['value']
        return int(fgi_value)
    except requests.RequestException as e:
        print(f"Error fetching FGI data: {e}")
        return None

def set_fgi(fgi_value):
    account = web3.eth.account.from_key(PRIVATE_KEY)
    web3.eth.defaultAccount = account.address
    
    nonce = web3.eth.get_transaction_count(account.address)
    market_id= contract.functions.marketCount().call()
    # Manually build the transaction dictionary
    txn = {
        'chainId': 11155111,  # Replace with your chain ID
        'gasPrice': web3.to_wei(gwei, 'gwei'),  # Adjust gas price as needed
        'nonce': nonce,
        'to': contract.address,
        'data': contract.encodeABI(fn_name='setFGI', args=[market_id, fgi_value])
    }

    # Estimate the gas
    txn['gas'] = 3000000
    # Sign the transaction
    signed_txn = web3.eth.account.sign_transaction(txn, private_key=PRIVATE_KEY)
    
    # Send the transaction
    tx_hash = web3.eth.send_raw_transaction(signed_txn.rawTransaction)
    
    print(f"Transaction sent: {web3.to_hex(tx_hash)}")


def main():
      # Replace with your logic to determine market ID
    while True:
        fgi_value = fetch_fgi()
        print(fgi_value)
        if fgi_value is not None:
            set_fgi(fgi_value)
        time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    main()
