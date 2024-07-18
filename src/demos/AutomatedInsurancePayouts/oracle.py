import os
import json
from dotenv import load_dotenv
from web3 import Web3

# Load environment variables from .env file
load_dotenv()

# Constants from .env
INFURA_PROJECT_ID = os.getenv("INFURA_PROJECT_ID")
TOP_SECURE_CONTRACT_ADDR = os.getenv("TOP_SECURE_CONTRACT_ADDR")
HONEST_ORACLE_ADDR = os.getenv("HONEST_ORACLE_ADDR")
WHATEVER_INSURANCE_PRIVATE_KEY = os.getenv("WHATEVER_INSURANCE_PRIVATE_KEY")

# Connect to SepoliaETH via Infura
web3 = Web3(Web3.HTTPProvider(f'https://sepolia.infura.io/v3/{INFURA_PROJECT_ID}'))

# Check if connected
if not web3.is_connected():
    raise Exception("Failed to connect to SepoliaETH network")
else:
    print("Successfully connected to SepoliaETH network")

# ABI of the TopSecureContract.sol as a JSON string
top_secure_contract_abi_json = '''
[
    {
        "inputs": [],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "initiator",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "value",
                "type": "uint256"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "recipient",
                "type": "address"
            }
        ],
        "name": "EthTransferred",
        "type": "event"
    },
    {
        "stateMutability": "payable",
        "type": "fallback"
    },
    {
        "inputs": [],
        "name": "geniusDeveloper",
        "outputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address payable",
                "name": "recipient",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "name": "transferEth",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "stateMutability": "payable",
        "type": "receive"
    }
]
'''

# Parse the TopSecureContract.sol ABI JSON string to a Python dictionary
top_secure_contract_abi = json.loads(top_secure_contract_abi_json)

# ABI of the HonestOracle.sol contract as a JSON string
honest_oracle_abi_json = '''
[
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "sender",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "name": "TransactionEvent",
        "type": "event"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_sender",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_amount",
                "type": "uint256"
            }
        ],
        "name": "emitEvent",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
]
'''

# Parse the HonestOracle.sol ABI JSON string to a Python dictionary
honest_oracle_abi = json.loads(honest_oracle_abi_json)

# Initialize contract instances
monitored_contract = web3.eth.contract(address=TOP_SECURE_CONTRACT_ADDR, abi=top_secure_contract_abi)
oracle_contract = web3.eth.contract(address=HONEST_ORACLE_ADDR, abi=honest_oracle_abi)

# Get the Whatever Insurance account from private key
account = web3.eth.account.from_key(WHATEVER_INSURANCE_PRIVATE_KEY)
sender_address = account.address

# Function to handle detected transactions
def handle_transaction(event):
    transaction = event['args']
    sender = transaction['initiator']
    amount = transaction['value']
    
    print(f'Handling transaction from {sender} with amount {amount}')

    # Prepare transaction to emit event via HonestOracle.sol
    try:
        txn = oracle_contract.functions.emitEvent(sender, amount).build_transaction({
            'chainId': 11155111, # SepoliaETH chain ID
            'gas': 2000000,
            'gasPrice': web3.to_wei('10', 'gwei'),
            'nonce': web3.eth.get_transaction_count(sender_address),
        })

        # Sign the transaction
        signed_txn = web3.eth.account.sign_transaction(txn, private_key=WHATEVER_INSURANCE_PRIVATE_KEY)

        # Send the transaction
        tx_hash = web3.eth.send_raw_transaction(signed_txn.rawTransaction)
        print(f'Transaction sent with hash: {web3.to_hex(tx_hash)}')
    except Exception as e:
        print(f'Error building or sending transaction: {str(e)}')

# Subscribe to the TopSecureContract.sol events
def monitor_events():
    event_filter = monitored_contract.events.EthTransferred.create_filter(fromBlock='latest')
    while True:
        for event in event_filter.get_new_entries():
            print(f'Event detected: {event}')
            handle_transaction(event)

if __name__ == '__main__':
    print("Starting TopSecureContract.sol event monitoring script...")
    monitor_events()
