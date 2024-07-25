// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MultiSigWallet {

    struct Shareholder {
        uint256 shares;
        bool exists;
    }

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
        uint256 confirmedShares;
    }

    struct ShareholderProposal {
        address shareholder;
        uint256 shares;
        bool add; // true for add, false for remove
        bool executed;
        uint256 confirmations;
        uint256 confirmedShares;
    }

    mapping(address => Shareholder) public shareholders;
    address[] public shareholderAddresses;
    uint256 public totalShares;
    uint256 public requiredPercentage; // e.g., 60 means 60%
    address public REACTIVE_CALLBACK;

    bool locked;

    

    mapping(uint256 => mapping(address => bool)) public confirmations;
    mapping(uint256 => mapping(address => bool)) public shareholderProposalConfirmations;
    Transaction[] public transactions;
    ShareholderProposal[] public shareholderProposals;


    event SubmitTransaction(address indexed shareholder, uint256 indexed txIndex, address indexed to, uint256 value, bytes data);
    event ConfirmTransaction(address indexed shareholder, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed shareholder, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed shareholder, uint256 indexed txIndex);
    
    event SubmitShareholderProposal(address indexed proposer, uint256 indexed proposalIndex, address indexed shareholder, uint256 shares, bool add);
    event ConfirmShareholderProposal(address indexed shareholder, uint256 indexed proposalIndex);
    event ExecuteShareholderProposal(address indexed shareholder, uint256 indexed proposalIndex);
    event RevokeShareholderProposalConfirmation(address indexed shareholder, uint256 indexed proposalIndex);
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    // 0x356bc9241f9b004323fE0Fe75C3d75DD946cF15c
    constructor(address[] memory initialShareholders, uint256[] memory initialShares, uint256 _requiredPercentage,address _reactive_callback) {
        require(_requiredPercentage > 0 && _requiredPercentage <= 100, "Invalid percentage");
        require(initialShareholders.length == initialShares.length, "Shareholders and shares length mismatch");

        for (uint256 i = 0; i < initialShareholders.length; i++) {
            require(initialShareholders[i] != address(0), "Invalid shareholder address");
            require(initialShares[i] > 0, "Shares must be greater than 0");
            require(!shareholders[initialShareholders[i]].exists, "Shareholder already exists");

            shareholders[initialShareholders[i]] = Shareholder({
                shares: initialShares[i],
                exists: true
            });
            shareholderAddresses.push(initialShareholders[i]);
            totalShares += initialShares[i];
        }

        requiredPercentage = _requiredPercentage;
        REACTIVE_CALLBACK=_reactive_callback;
    }
    
    /**
     * @dev Submit a transaction to be confirmed by shareholders. Only shareholders can call this function.
     *      Emits a 'SubmitTransaction' event after successful submission.
     *
     * Requirements:
     * - The caller (msg.sender) must be a shareholder.
     * - The transaction to be submitted cannot already have been executed.
     * - The transaction to be submitted must not have been previously confirmed by the submitter.
     * 
     * @param to The address of the recipient of the transaction.
     * @param value The amount of Ether (in wei) to send.
     * @param data Additional data to include with the transaction, e.g., a method signature and parameters.
     */
    function submitTransaction(address to, uint256 value, bytes memory data) public onlyShareholder {
        uint256 txIndex = transactions.length;

        transactions.push(Transaction({
            to: to,
            value: value,
            data: data,
            executed: false,
            confirmations: 0,
            confirmedShares: 0
        }));

        emit SubmitTransaction(msg.sender, txIndex, to, value, data);
    }

    function confirmTransaction(uint256 txIndex) public onlyShareholder txExists(txIndex) notExecuted(txIndex) notConfirmed(txIndex) {
        confirmations[txIndex][msg.sender] = true;
        transactions[txIndex].confirmations += 1;
        transactions[txIndex].confirmedShares += shareholders[msg.sender].shares;

        emit ConfirmTransaction(msg.sender, txIndex);

        if ((transactions[txIndex].confirmedShares * 100) / totalShares >= requiredPercentage) {
            executeTransaction(txIndex);
        }
    }

    function executeTransaction(uint256 txIndex) internal onlyShareholder txExists(txIndex) notExecuted(txIndex) ReentrancyGuard {
        require((transactions[txIndex].confirmedShares * 100) / totalShares >= requiredPercentage, "Not enough confirmed shares");

        Transaction storage transaction = transactions[txIndex];
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "Transaction failed");

        emit ExecuteTransaction(msg.sender, txIndex);
    }

    function revokeConfirmation(uint256 txIndex) public onlyShareholder txExists(txIndex) notExecuted(txIndex) {
        require(confirmations[txIndex][msg.sender], "Transaction not confirmed");

        confirmations[txIndex][msg.sender] = false;
        transactions[txIndex].confirmations -= 1;
        transactions[txIndex].confirmedShares -= shareholders[msg.sender].shares;

        emit RevokeConfirmation(msg.sender, txIndex);
    }

    function submitShareholderProposal(address shareholder, uint256 shares, bool add) public onlyShareholder {
        require(shareholder != address(0), "Invalid address");
        require(shares > 0, "Shares must be greater than 0");
        require(add||shareholders[shareholder].shares>shares,"cannot Withdraw more that current Shares");

        uint256 proposalIndex = shareholderProposals.length;

        shareholderProposals.push(ShareholderProposal({
            shareholder: shareholder,
            shares: shares,
            add: add,
            executed: false,
            confirmations: 0,
            confirmedShares: 0
        }));

        emit SubmitShareholderProposal(msg.sender, proposalIndex, shareholder, shares, add);
    }

    function confirmShareholderProposal(uint256 proposalIndex) public onlyShareholder proposalExists(proposalIndex) proposalNotExecuted(proposalIndex) proposalNotConfirmed(proposalIndex) {
        shareholderProposalConfirmations[proposalIndex][msg.sender] = true;
        shareholderProposals[proposalIndex].confirmations += 1;
        shareholderProposals[proposalIndex].confirmedShares += shareholders[msg.sender].shares;

        emit ConfirmShareholderProposal(msg.sender, proposalIndex);

        if ((shareholderProposals[proposalIndex].confirmedShares * 100) / totalShares >= requiredPercentage) {
            executeShareholderProposal(proposalIndex);
        }
    }

    function executeShareholderProposal(uint256 proposalIndex) internal onlyShareholder proposalExists(proposalIndex) proposalNotExecuted(proposalIndex) ReentrancyGuard{
        require((shareholderProposals[proposalIndex].confirmedShares * 100) / totalShares >= requiredPercentage, "Not enough confirmed shares");

        ShareholderProposal storage proposal = shareholderProposals[proposalIndex];
        proposal.executed = true;

        if (proposal.add) {
            require(!shareholders[proposal.shareholder].exists, "Shareholder already exists");

            shareholders[proposal.shareholder] = Shareholder({
                shares: proposal.shares,
                exists: true
            });
            shareholderAddresses.push(proposal.shareholder);
            totalShares += proposal.shares;
        } else {
            require(shareholders[proposal.shareholder].exists, "Shareholder does not exist");

            totalShares -= shareholders[proposal.shareholder].shares;
            shareholders[proposal.shareholder].exists = false;
            shareholders[proposal.shareholder].shares = 0;

            for (uint256 i = 0; i < shareholderAddresses.length; i++) {
                if (shareholderAddresses[i] == proposal.shareholder) {
                    shareholderAddresses[i] = shareholderAddresses[shareholderAddresses.length - 1];
                    shareholderAddresses.pop();
                    break;
                }
            }
        }

        emit ExecuteShareholderProposal(msg.sender, proposalIndex);
    }

    function revokeShareholderProposalConfirmation(uint256 proposalIndex) public onlyShareholder proposalExists(proposalIndex) proposalNotExecuted(proposalIndex) {
        require(shareholderProposalConfirmations[proposalIndex][msg.sender], "Proposal not confirmed");

        shareholderProposalConfirmations[proposalIndex][msg.sender] = false;
        shareholderProposals[proposalIndex].confirmations -= 1;
        shareholderProposals[proposalIndex].confirmedShares -= shareholders[msg.sender].shares;

        emit RevokeShareholderProposalConfirmation(msg.sender, proposalIndex);
    }

    function distributeFunds(address ,address tokenAddress) public onlyReactiveCallback ReentrancyGuard {
        if(tokenAddress!=address(0)){
            IERC20 token = IERC20(tokenAddress);
            uint256 totalBalance = token.balanceOf(address(this));
            require(totalBalance > 0, "No tokens to distribute");

            for (uint256 i = 0; i < shareholderAddresses.length; i++) {
                address shareholder = shareholderAddresses[i];
                uint256 shareholderShare = (totalBalance * shareholders[shareholder].shares) / totalShares;
                require(token.transfer(shareholder, shareholderShare), "Token transfer failed");
            }
        }else{
            uint256 totalBalance=address(this).balance;

            for (uint256 i = 0; i < shareholderAddresses.length; i++) {
                address shareholder = shareholderAddresses[i];
                uint256 shareholderShare = (totalBalance * shareholders[shareholder].shares) / totalShares;
                payable(shareholder).transfer( shareholderShare);
            }
        }
    }

    modifier onlyShareholder() {
        require(shareholders[msg.sender].exists, "Not a shareholder");
        _;
    }

    modifier txExists(uint256 txIndex) {
        require(txIndex < transactions.length, "Transaction does not exist");
        _;
    }

    modifier proposalExists(uint256 proposalIndex) {
        require(proposalIndex < shareholderProposals.length, "Proposal does not exist");
        _;
    }

    modifier notExecuted(uint256 txIndex) {
        require(!transactions[txIndex].executed, "Transaction already executed");
        _;
    }

    modifier proposalNotExecuted(uint256 proposalIndex) {
        require(!shareholderProposals[proposalIndex].executed, "Proposal already executed");
        _;
    }

    modifier notConfirmed(uint256 txIndex) {
        require(!confirmations[txIndex][msg.sender], "Transaction already confirmed");
        _;
    }

    modifier proposalNotConfirmed(uint256 proposalIndex) {
        require(!shareholderProposalConfirmations[proposalIndex][msg.sender], "Proposal already confirmed");
        _;
    }

    modifier onlyReactiveCallback() {
        require(msg.sender == REACTIVE_CALLBACK, "Caller is not REACTIVE_CALLBACK");
        _;  
    }

    modifier ReentrancyGuard(){
        require(!locked ,"you are trying for a Reentrancy attack");
        locked=true;
        _;
        locked=false;
    }

    receive() external payable {
        emit Transfer(msg.sender,address(this),msg.value);
    }
}

// ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
// [1,5,7]
// [76,384,538]

// 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
// 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef