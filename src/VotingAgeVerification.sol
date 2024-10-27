// src/VotingAgeVerification.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Define the AVS interface
interface IAVSService {
    function isEligible(address user) external view returns (bool);
}

contract MockAVSService {
    mapping(address => bool) public eligibleUsers;

    function setMockUserEligibility(
        address user,
        bool eligibilityStatus
    ) external {
        eligibleUsers[user] = eligibilityStatus;
    }

    function isEligible(address user) external view returns (bool) {
        return eligibleUsers[user];
    }
}

contract VotingAgeVerification {
    uint256 constant MIN_AGE = 17 * 365 days;

    struct Voter {
        uint256 birthDate;
        bool hasVoted;
    }

    mapping(address => Voter) public voters;
    IAVSService public avsService;

    error Underage(uint256 age);
    error AlreadyRegistered();
    error NotRegistered();
    error AlreadyVoted();
    error NotEligible();

    // Constructor to initialize the AVS contract address
    constructor(address _avsServiceAddress) {
        avsService = IAVSService(_avsServiceAddress);
    }

    function registerVoter(uint256 _birthDate) public {
        // Check with AVS service for eligibility
        if (!avsService.isEligible(msg.sender)) revert NotEligible();

        require(_birthDate <= block.timestamp, "Tanggal lahir tidak valid");

        unchecked {
            uint256 ageCheck = block.timestamp - _birthDate;
            if (ageCheck < MIN_AGE) revert Underage(ageCheck / 365 days);
        }

        if (voters[msg.sender].birthDate != 0) revert AlreadyRegistered();

        voters[msg.sender] = Voter(_birthDate, false);
    }

    function vote() public {
        // Check eligibility with AVS before allowing voting
        if (!avsService.isEligible(msg.sender)) revert NotEligible();

        if (voters[msg.sender].birthDate == 0) revert NotRegistered();
        if (voters[msg.sender].hasVoted) revert AlreadyVoted();

        voters[msg.sender].hasVoted = true;
    }

    function getVoterAge(address _voter) public view returns (uint256) {
        if (voters[_voter].birthDate == 0) revert NotRegistered();

        unchecked {
            uint256 age = (block.timestamp - voters[_voter].birthDate) /
                365 days;
            return age;
        }
    }
}
