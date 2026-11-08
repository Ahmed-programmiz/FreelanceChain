// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title FreelanceChain (educational Sepolia testnet contract)
 * @notice Five-function, milestone escrow demonstration. NOT AUDITED.
 * @dev Disputes, active-job cancellations, and pauses are NOT enforced on-chain.
 */
contract FreelanceChain {
    enum Status { Open, Active, Completed, Cancelled }

    struct Job {
        address client;
        address payable freelancer;
        string description;
        string disputeRules;
        uint256[] milestoneAmounts;
        uint256[] milestoneDeadlines;
        uint256 currentMilestone;
        uint256 escrowRemaining;
        Status status;
    }

    uint256 private nextJobId;
    mapping(uint256 => Job) private jobs;

    event JobCreated(uint256 indexed jobId);
    event JobAccepted(uint256 indexed jobId);
    event MilestoneReleased(uint256 indexed jobId, uint256 amount);
    event JobCancelled(uint256 indexed jobId);

    // 1. Client creates a job and locks exactly the sum of its milestones.
    function createJob(
        address payable freelancer,
        string calldata description,
        string calldata disputeRules,
        uint256[] calldata amounts,
        uint256[] calldata deadlines
    ) external payable returns (uint256) {
        require(freelancer != address(0), "Invalid freelancer");
        require(freelancer != msg.sender, "Use another wallet");
        require(bytes(description).length > 0, "Description required");
        require(amounts.length > 0, "Add milestones");
        require(amounts.length <= 10, "Maximum 10 milestones");
        require(amounts.length == deadlines.length, "Length mismatch");

        uint256 total = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            require(amounts[i] > 0, "Invalid payment");
            require(deadlines[i] > block.timestamp, "Past deadline");
            if (i > 0) {
                require(deadlines[i] >= deadlines[i - 1], "Deadlines out of order");
            }
            total += amounts[i];
        }
        require(msg.value == total, "Incorrect escrow amount");

        nextJobId++;
        uint256 jobId = nextJobId;
        Job storage job = jobs[jobId];
        job.client = msg.sender;
        job.freelancer = freelancer;
        job.description = description;
        job.disputeRules = disputeRules;
        job.escrowRemaining = msg.value;
        job.status = Status.Open;

        for (uint256 i = 0; i < amounts.length; i++) {
            job.milestoneAmounts.push(amounts[i]);
            job.milestoneDeadlines.push(deadlines[i]);
        }

        emit JobCreated(jobId);
        return jobId;
    }

    // 2. Only the named freelancer can accept an open agreement.
    function acceptJob(uint256 jobId) external {
        Job storage job = jobs[jobId];
        require(job.client != address(0), "Job not found");
        require(msg.sender == job.freelancer, "Not freelancer");
        require(job.status == Status.Open, "Job unavailable");
        job.status = Status.Active;
        emit JobAccepted(jobId);
    }

    // 3. Only the client can release the next unpaid milestone.
    function releaseMilestone(uint256 jobId) external {
        Job storage job = jobs[jobId];
        require(msg.sender == job.client, "Not client");
        require(job.status == Status.Active, "Job not active");
        require(job.currentMilestone < job.milestoneAmounts.length, "All milestones paid");

        uint256 amount = job.milestoneAmounts[job.currentMilestone];
        job.currentMilestone++;
        job.escrowRemaining -= amount;
        if (job.currentMilestone == job.milestoneAmounts.length) {
            job.status = Status.Completed;
        }

        (bool success, ) = job.freelancer.call{value: amount}("");
        require(success, "Payment failed");
        emit MilestoneReleased(jobId, amount);
    }

    // 4. Only an OPEN job can be cancelled/refunded by its client.
    function cancelJob(uint256 jobId) external {
        Job storage job = jobs[jobId];
        require(msg.sender == job.client, "Not client");
        require(job.status == Status.Open, "Cannot cancel");
        uint256 refund = job.escrowRemaining;
        job.escrowRemaining = 0;
        job.status = Status.Cancelled;

        (bool success, ) = payable(job.client).call{value: refund}("");
        require(success, "Refund failed");
        emit JobCancelled(jobId);
    }

    // 5. Anyone can view a job; read-only, no MetaMask signature needed.
    function getJob(uint256 jobId) external view returns (Job memory) {
        require(jobs[jobId].client != address(0), "Job not found");
        return jobs[jobId];
    }
}
