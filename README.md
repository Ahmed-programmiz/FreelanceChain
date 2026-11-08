# FreelanceChain — Freelancer Escrow dApp (Sepolia Testnet)

**Assignment:** Solidity smart contract and HTML/CSS/JavaScript frontend with MetaMask on Ethereum Sepolia.

FreelanceChain allows a client to create and fund a freelancer job, a freelancer to accept it, and the client to release milestone payments from a Solidity smart contract. It also includes a clearly labelled browser-only demonstration of messages, evidence, pause requests, simulated voting, proposed penalties/refunds, and an appeal.

> **Educational software only.** No Solidity security audit has been performed. **Never deploy to Ethereum mainnet or use real-value ETH.** Sepolia ETH is test currency. The browser's localStorage is not shared data storage and is not suitable for confidential information.

## Files

```
FreelanceChain/
├── SmartContract.sol    # Solidity contract; exactly 5 external functions
├── index.html           # Single-page frontend; JavaScript in <script> tag
├── style.css            # Responsive dark dashboard styling
├── README.md            # Documentation and setup
└── screenshots/
    └── README.md        # Instructions; add 3 genuine screenshots after deployment
```

## Contract details

- **Contract name:** `FreelanceChain`
- **Blockchain:** Ethereum Sepolia
- **Chain ID:** `11155111` (`0xaa36a7` in hex)
- **Token:** Sepolia **test ETH** (not real SOL, not mainnet ETH)
- **Sepolia contract address:** **PENDING DEPLOYMENT — replace with your actual 0x... address**
- **Block explorer:** https://sepolia.etherscan.io/
- **Public GitHub repository:** **PENDING — add your repository URL**

### Five public/external functions

| Solidity function | Read / write | Who can call it? | Purpose |
|---|---|---|---|
| `createJob(freelancer, description, disputeRules, amounts, deadlines)` | Write, payable | Client | Create job and send total milestone test ETH as escrow. |
| `acceptJob(jobId)` | Write | Named freelancer | Move job from Open to Active. |
| `releaseMilestone(jobId)` | Write | Client | Pay the next milestone to freelancer. |
| `cancelJob(jobId)` | Write | Client | Refund escrow **only before acceptance**. |
| `getJob(jobId)` | Read | Anyone | Fetch all on-chain job details. |

A job has four statuses: `0=Open`, `1=Active`, `2=Completed`, `3=Cancelled`.

**Limits of version 1:** Dispute rules and deadlines are text/data, not enforced on-chain. The contract has **no on-chain pause, no cancellation after acceptance, no juror voting, no appeal logic, and no penalty collection**. Accepted jobs can remain locked if the client never releases milestones. Messages/evidence and dispute simulations are in **localStorage**, not Ethereum. Job IDs are remembered in the same browser; there is no global on-chain list function because the assignment limits the contract to five functions. Users can import any known job ID and read it from the chain.

## 1. Requirements

1. Google Chrome or another MetaMask-compatible browser with the MetaMask extension installed.
2. [Remix IDE](https://remix.ethereum.org/) for deploying the Solidity contract.
3. [Visual Studio Code](https://code.visualstudio.com/) or another editor.
4. Free **Sepolia test ETH** from a reputable faucet to cover deployment and transactions (availability, eligibility, and limits may vary). For example, [Alchemy's Ethereum Sepolia faucet](https://www.alchemy.com/faucets/ethereum-sepolia) or the [MetaMask Help Center faucet instructions](https://support.metamask.io/develop/blockchain-networks/testnets/using-the-testnet-faucet/).
5. Internet to load **ethers.js v6** from jsDelivr for MetaMask/contract interaction.

Never share your MetaMask password, private key, or recovery phrase. Never pay anyone for test ETH.

## 2. Deploy the smart contract to Sepolia

1. Enable **Show test networks** in MetaMask and choose Ethereum Sepolia (chain ID `11155111`).
2. Obtain enough free Sepolia test ETH for deployment, transaction gas, and the intended milestone escrow.
3. Open [Remix IDE](https://remix.ethereum.org/); open the Solidity file `SmartContract.sol` from this project in a Remix workspace.
4. Open **Solidity Compiler**; choose Solidity `0.8.20` or a compatible newer `0.8.x` version; compile `SmartContract.sol`.
5. Open **Deploy & Run Transactions**. In **Environment**, select **Browser Extension** (older Remix versions may say **Injected Provider - MetaMask**).
6. Approve the MetaMask connection if prompted. Verify Remix's account matches your MetaMask account and that MetaMask's selected network is **Sepolia**, **not Ethereum Mainnet**. If the wallet is on a different network, switch in MetaMask and reconnect.
7. Select the compiled **FreelanceChain** contract. The deployment transaction **Value must be 0** because the contract has no payable constructor.
8. Click **Deploy**. Confirm the deployment transaction in MetaMask. Deployment costs only *test ETH* gas.
9. Once it confirms, copy the contract **0x... address** from Remix's **Deployed Contracts** section and inspect it at `https://sepolia.etherscan.io/address/YOUR_ADDRESS`.
10. Replace the **PENDING DEPLOYMENT** line in this README with the actual address. Do not claim deployment until it succeeds.

This Sepolia deployment is separate from Remix VM. Old Remix VM Job #1 does not exist on Sepolia.

## 3. Open the website

**Recommended:** Open the folder in VS Code and run `index.html` through a local server, such as VS Code Live Server, or run:

```bash
# In the FreelanceChain folder, with Python installed:
python -m http.server 8000
```

Open `http://localhost:8000/` in the browser that has MetaMask. Do not deploy using a private wallet key or hardcode keys into source files.

Alternatively, upload `index.html` and `style.css` to a GitHub Pages repository. Ethers.js is loaded from the script tag in `index.html`.

### Configure the site for live transactions

1. By default, the website opens in **Demo preview** mode. Browse the dashboard and sample agreement without MetaMask.
2. Open **Sepolia setup** on the sidebar.
3. Click **Connect MetaMask** and approve access to your chosen account and the Sepolia network.
4. Paste the deployed **FreelanceChain** contract address and click **Save contract address**.
5. Switch to **Live Sepolia** (in Overview or Setup).
6. For creating a live job, enter the freelancer's **actual Sepolia wallet address** (a different wallet from the client; never use the prefilled public Remix VM sample accounts as Sepolia payout addresses) and create one or more milestone amounts and future deadlines. Click **Create job & lock test ETH**. Approve the test ETH and gas in MetaMask, then wait for confirmation.
7. Change the active MetaMask account to the freelancer's wallet; use **Jobs & escrow → Import job by ID** (for example, `1`) if the job does not appear. Click **Accept agreement** and confirm the transaction.
8. Switch MetaMask to the client wallet and call **Release next milestone**. Confirm in MetaMask, then repeat for remaining milestones. Transaction links open on Sepolia Etherscan.
9. To test the real cancellation logic, create a **new Open job**, then cancel it **before** the freelancer accepts. You cannot cancel an Active job with this version.

**MetaMask test:** If changing accounts clears the job list, import the on-chain job ID again. The website saves IDs in localStorage, but the *real* job details come from `getJob` on Sepolia.

## 4. Demonstration-only features

- **Client / Freelancer dashboard:** the app shows the current role in Demo mode; in Live mode it compares your MetaMask address to each job's client/freelancer address.
- **Messages and evidence:** description and optional http(s) evidence URL, stored in this browser only. These records are not shared between participants.
- **Pause / active-job cancellation requests:** UI-only local indicators or browser notes. **They do not stop transactions and do not change a live contract.**
- **Dispute voting and appeals:** manually click three mock juror votes; the majority picks a proposed outcome. A tie produces Split. An appeal starts a second round. **This does not pay, refund, penalize, or freeze any real Sepolia escrow.**
- **Proposed settlements:** for learning, the app calculates possible client/freelancer portions of remaining escrow. Any 5% stake penalty is hypothetical; the contract has no staked collateral and cannot charge it.

The first Solidity contract is intentionally small to match the course requirements. Real juror selection, independent votes, verifiable off-chain evidence, binding refunds, funds recovery, appeal periods, and abuse prevention require future Solidity features and testing.

## 5. Suggested classroom test

1. In **Demo** mode, show the sample job, switch roles, create another job, accept it, release milestones, record a message/evidence URL, and simulate a dispute plus an appeal.
2. In **Live Sepolia**, show MetaMask connected and the contract address saved.
3. Use **Client account A** to fund a small Sepolia job (e.g., `0.001` + `0.001` Sepolia ETH; adjust to your faucet balance).
4. Use **Freelancer account B** to accept the job; wallet transaction should succeed.
5. Use **Client account A** to release payments; `getJob` returns statuses and escrow changes.
6. Show the transaction confirmation link on Sepolia Etherscan.

> In Remix, sending 0.01 ether is `10000000000000000 Wei`. On the website, you type a decimal ETH amount and the JavaScript converts it to Wei automatically. The **VALUE** for `acceptJob`, `releaseMilestone`, and `cancelJob` is **zero**.

## 6. Required screenshot evidence

Capture **real** screenshots from your Remix and website sessions and place them in `screenshots/`:

- `screenshots/01-metamask-connection.png` — website showing MetaMask connected to Ethereum Sepolia.
- `screenshots/02-contract-deployment.png` — Remix successful Sepolia deployment showing contract address.
- `screenshots/03-transaction-result.png` — successful Create / Accept / Release transaction (website plus MetaMask confirmation or Etherscan link).

Do not fabricate screenshot evidence. No screenshot images are included in the starter ZIP because live deployment and actual wallet approval must happen in your browser.

## 7. Submit the assignment

1. Replace this README's `PENDING DEPLOYMENT` placeholders with your *real* Sepolia address and public GitHub URL.
2. Add the three genuine screenshots to `screenshots/`.
3. Create a **public** GitHub repository (e.g., `FreelanceChain-Sepolia`), and upload `SmartContract.sol`, `index.html`, `style.css`, `README.md` and `screenshots/`.
4. Optional: enable **GitHub Pages** in **Settings → Pages**, deploy from the main branch, and use the published site link for demonstration.
5. Download or create a **ZIP of the completed folder** including the three images.
6. Submit the ZIP, public GitHub repository link, and deployed contract address to Google Classroom.
7. Optional bonus: use Remix's **Contract Verification** plugin to verify your deployed Solidity source on Sepolia Etherscan.

## Resources

- Remix Deploy & Run: https://remix-ide.readthedocs.io/en/latest/run.html
- ethers.js v6: https://docs.ethers.org/v6/getting-started/
- Ethereum Sepolia explorer: https://sepolia.etherscan.io/
- MetaMask testnet faucet guide: https://support.metamask.io/develop/blockchain-networks/testnets/using-the-testnet-faucet/

## Technology

- Solidity `^0.8.20`
- HTML5, CSS3, vanilla JavaScript
- ethers.js v6.15.0 loaded from jsDelivr
- MetaMask injected provider (`window.ethereum`)
- Ethereum Sepolia testnet, chain ID `11155111`
- Browser localStorage for demonstrative records and saved contract/job IDs

---

**Author:** [Enter student name]  
**University / course:** [Enter course]  
**Contract address:** [Paste after Sepolia deployment]

## FreelanceChain — Sepolia Deployment

**Project:** Decentralized Freelancer Hiring Platform

**Blockchain:** Ethereum Sepolia Testnet

**Smart Contract:** FreelanceChain

**Contract Address:** `0xA90212E7e3Dabea09B919938E4E377085e89cc0e`

**Contract Explorer:** https://sepolia.etherscan.io/address/0xA90212E7e3Dabea09B919938E4E377085e89cc0e

### Technologies Used

- Solidity for smart contract development
- Remix IDE for compilation, testing, and deployment
- MetaMask for wallet authentication and transactions
- Ethereum Sepolia for blockchain testing
- HTML, CSS, and JavaScript for the frontend
- ethers.js for blockchain integration

### Smart Contract Functions

1. `createJob()` — Creates a job and deposits Sepolia ETH into escrow.
2. `acceptJob()` — Allows the assigned freelancer to accept the job.
3. `releaseMilestone()` — Releases a milestone payment to the freelancer.
4. `cancelJob()` — Cancels an unaccepted job and refunds the client.
5. `getJob()` — Retrieves job details from the blockchain.

### How to Run

1. Download or clone the repository.
2. Open the project folder in Visual Studio Code.
3. Install the Live Server extension.
4. Open `index.html` using Live Server.
5. Connect MetaMask and select Ethereum Sepolia.
6. Open Sepolia setup and enter the deployed contract address.
7. Activate Live Sepolia mode to interact with the smart contract.

### Features

The application supports real blockchain-based job creation, freelancer acceptance, milestone escrow, payment release, and cancellation before acceptance.

It also includes demonstration interfaces for messages, evidence, dispute voting, penalties, refunds, and appeals. These demonstration features use browser storage and do not execute blockchain transactions.

### Screenshots

The `screenshots/` folder contains:

- `wallet-connection.png`
- `contract-deployment.png`
- `transaction-result.png`
- "it also contains additional screenshots"

### Testing

Two freelancer agreements were completed during testing. Job #2 was created, accepted, and completed through the FreelanceChain website using MetaMask and Sepolia test ETH.

**Disclaimer:** This is an educational dApp using test cryptocurrency with no real monetary value. It is not intended for production use.