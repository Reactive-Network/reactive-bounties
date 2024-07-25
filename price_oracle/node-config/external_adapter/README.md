# External Adapter

## Directory Overview

This directory contains the code for a Chainlink external adapter. The adapter provides endpoints to fetch cryptocurrency prices from external APIs and to get cross-chain price data using Chainlink oracles. 

### Important Note

This is a very basic demo implementation of the external adapter. For a production-ready adapter, ensure to implement all web2 best practices. For more information and detailed guidelines, refer to the official Chainlink external adapter GitHub page: [Chainlink External Adapters JS](https://github.com/smartcontractkit/external-adapters-js).


## Endpoints

- `/data/log`: Fetches the current price of a specified cryptocurrency.
- `/data/crossChainPrice`: Fetches prices from different blockchains and returns the prices along with their corresponding chain IDs.

## Setup

### Prerequisites

- Node.js
- npm (Node Package Manager)
- Hardhat
- Chainlink node

### Installation


1. **Install dependencies**:

   ```sh
   npm install
   ```

2. **Set up environment variables**:

   Create a `.env` file in the root directory and add your environment variables. Example:

   ```env
   PORT=8080
   ```

### Starting the Server

1. **Start the server**:

   ```sh
   node ./server.js
   ```

## Adding the External Adapter to the Chainlink Node

1. **Run the External Adapter**: Ensure your external adapter server is running.

2. **Add the External Adapter as a Bridge on the Chainlink Node**:
    - Log in to your Chainlink node operator UI.
    - Navigate to the "Bridges" section.
    - Click on "New Bridge".
    - Fill out the form:
        - **Name**: A unique name for your external adapter (e.g., `cross_chain_price`).
        - **URL**: The URL of your running external adapter (e.g., `http://your-server-ip:8080/data/crossChainPrice`).
        - **Minimum Contract Payment**: The minimum payment required for using this bridge.
    - Click "Create Bridge" to save the new bridge.

## Usage

### Endpoints

- **/data/log**

  This endpoint accepts a POST request with a JSON body containing a `coin` field. It fetches the current price of the specified cryptocurrency from the CryptoCompare API.

**Example Request**:

  ```sh
  curl -X POST http://localhost:8080/data/log -H "Content-Type: application/json" -d '{"coin": "ETH"}'
  ```

**Example Response**:

  ```json
  {
    "USD": 3000
  }
  ```

- **/data/crossChainPrice**

  This endpoint accepts a POST request with a JSON body containing `chain1Contract`, `chain1RPC`, `chain2Contract`, `chain2RPC`, `chain3Contract`, and `chain3RPC` fields. It fetches the prices from the specified blockchains and returns the prices along with their corresponding chain IDs.

**Example Request**:

  ```sh
  curl -X POST http://localhost:8080/data/crossChainPrice -H "Content-Type: application/json" -d '{
    "chain1Contract": "0x...",
    "chain1RPC": "https://...",
    "chain2Contract": "0x...",
    "chain2RPC": "https://...",
    "chain3Contract": "0x...",
    "chain3RPC": "https://..."
  }'
  ```

**Example Response**:

  ```json
  {
    "priceArray": [3000, 3100, 3200],
    "chainArray": [1, 56, 137]
  }
  ```