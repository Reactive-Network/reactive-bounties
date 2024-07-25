## Contact Information
- Name: Mohsin Mumtaz
- Email: mhsnmk3@gmail.com
- Address: 0x0ECbE30790B6a690D4088B70dCC27664ca530D55

I am excited to share with you my latest project, an automated prediction market that leverages blockchain technology and reactive networks to reward users based on the Fear and Greed Index (FGI). This project addresses the need for a transparent and fair prediction market system.

**Project Overview:**
The core of this project is the `PredictionMarket` contract, which works in conjunction with a `ReactiveListener` contract to automate the payout process. Users place bets on the FGI, and the oracle updates the FGI to determine the market outcome. The Reactive Network monitors these events and triggers payouts automatically.

**Technique Used:**
1. **Bet Placement:** Users place bets on the `PredictionMarket` contract, choosing between Fear and Greed options.
2. **Oracle Update:** The oracle updates the FGI, which determines the market outcome and closes the market.
3. **Reactive Network:** The Reactive Network listens for the FGI update event and triggers the payout process.
4. **Automated Payouts:** The `ReactiveListener` contract calls the `payout` function on the `PredictionMarket` contract, distributing rewards to the users based on the market result.

**Problem Solved:**
This automated prediction system ensures a transparent and fair distribution of rewards based on the FGI, fetched from an unbiased oracle. By leveraging a reactive network, the system automates the payout process, reducing the need for manual intervention and ensuring timely rewards.

**Deployment and Testing:**
The deployment involves setting up environment variables for both Sepolia and Reactive networks, deploying the contracts, and testing the workflow by placing bets and updating the FGI. The entire process is designed to be straightforward and efficient, with comprehensive logs available for verification.

I am confident that this project will be a valuable addition to any decentralized application requiring a transparent and automated prediction market. I look forward to discussing this further and exploring potential collaborations.

