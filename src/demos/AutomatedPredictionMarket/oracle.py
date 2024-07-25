import os
import json
import time
import requests
from dotenv import load_dotenv
from web3 import Web3

# Load environment variables from .env file and set current directory
load_dotenv()
current_dir = os.path.dirname(__file__)

# Constants from .env
INFURA_PROJECT_ID = os.getenv("INFURA_PROJECT_ID")
MARKET_CREATOR_PRIVATE_KEY = os.getenv("MARKET_CREATOR_PRIVATE_KEY")
PRICE_ORACLE_ADDR = os.getenv("PRICE_ORACLE_ADDR")
API_DATA_SOURCE = os.getenv("API_DATA_SOURCE")
API_DATA_CRYPTOCURRENCY=os.getenv("API_DATA_CRYPTOCURRENCY")
API_DATA_VS_CURRENCY=os.getenv("API_DATA_VS_CURRENCY")
ROUND_DURATION = int(os.getenv("ROUND_DURATION"))

# Connect to SepoliaETH via Infura
web3 = Web3(Web3.HTTPProvider(f'https://sepolia.infura.io/v3/{INFURA_PROJECT_ID}'))

# Check if connected
if not web3.is_connected():
    raise Exception(f"Failed to connect to SepoliaETH network\n")
else:
    print(f"Successfully connected to SepoliaETH network\n")

# Parse the PriceOracle.sol ABI JSON string to a Python dictionary
price_oracle_abi_path = os.path.join(current_dir, '..', '..', '..', 'out', 'PriceOracle.sol', 'PriceOracle.json')
try:
    with open(price_oracle_abi_path, 'r') as file:
        price_oracle_abi = json.load(file)
except FileNotFoundError:
    print(f"File not found: {price_oracle_abi_path}")
except json.JSONDecodeError:
    print(f"Error decoding JSON from the file: {price_oracle_abi_path}")
except Exception as e:
    print(f"An unexpected error occurred: {e}")

# Initialize contract instance
oracle_contract = web3.eth.contract(address=PRICE_ORACLE_ADDR, abi=price_oracle_abi['abi'])

# Get the MARKET_CREATOR account from private key
account = web3.eth.account.from_key(MARKET_CREATOR_PRIVATE_KEY)
sender_address = account.address

# Function to handle price update at API data source
def monitor_price_update():
    while True:
        api_params = {
            "ids": f"{API_DATA_CRYPTOCURRENCY}", # Specify cryptocurrency
            "vs_currencies": f"{API_DATA_VS_CURRENCY}" # Specify currency for conversion
        }

        api_response = requests.get(API_DATA_SOURCE, params=api_params)
        api_data = api_response.json()

        timestamp = int(time.time())
        price = api_data[f'{API_DATA_CRYPTOCURRENCY}'][f'{API_DATA_VS_CURRENCY}']
        print(f"New price update received!")
        print(f"timestamp: {timestamp}")
        print(f"{API_DATA_CRYPTOCURRENCY}/{API_DATA_VS_CURRENCY}: {price}\n")

        try: # Prepare transaction to emit event via PriceOracle.sol
            txn = oracle_contract.functions.emitEvent(timestamp, price).build_transaction({
                'chainId': 11155111, # SepoliaETH chain ID
                'gas': 2000000,
                'gasPrice': web3.eth.gas_price,
                'nonce': web3.eth.get_transaction_count(sender_address),
            })

            # Sign the transaction
            signed_txn = web3.eth.account.sign_transaction(txn, private_key=MARKET_CREATOR_PRIVATE_KEY)

            # Send the transaction
            tx_hash = web3.eth.send_raw_transaction(signed_txn.rawTransaction)
            print(f'Transaction sent with hash: {web3.to_hex(tx_hash)}\n')
        except Exception as e:
            print(f'Error building or sending transaction: {str(e)}\n')
        
        # Update price with delay of round duration
        countdown(ROUND_DURATION)
        print()

def countdown(seconds):
    for i in range(seconds, 0, -1):
        mins, secs = divmod(i, 60)
        time_format = f'{mins:02}:{secs:02}'
        print(f'\rCountdown to next update: {time_format}', end='', flush=True)
        time.sleep(1)
    print()  # New line after countdown completes

if __name__ == '__main__':
    monitor_price_update()
