## Overview

This directory contains the TOML configuration files for Chainlink node jobs. These files can be used to create new jobs on a Chainlink node to reproduce development behavior and test cross-chain price fetching functionalities.

## Job Definition Files

- `cross_chain_price_job.toml`: This file contains the job definition for fetching cross-chain prices using Chainlink oracles. The job is configured to parse logs, fetch data from a bridge, and fulfill the request by encoding the data and submitting a transaction.

## Usage

To use the TOML job definition file, follow these steps:

1. **Navigate to the Directory**: Ensure you are in the directory containing the job definition file.

2. **Create a New Job on the Chainlink Node**:
    - Log in to your Chainlink node operator UI.
    - Navigate to the "Jobs" section.
    - Click on "New Job" and select the "TOML" option.
    - Copy the contents of the `cross_chain_price_job.toml` file and paste it into the job creation form.
    - Click "Create Job" to save the new job on your Chainlink node.
