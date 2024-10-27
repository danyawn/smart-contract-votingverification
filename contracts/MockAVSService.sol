// contracts/MockAVSService.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MockAVSService {
    // Mapping to store the eligibility status of each address
    mapping(address => bool) public eligibleUsers;

    // Function to set the eligibility status of a user
    function setMockUserEligibility(address user, bool eligibilityStatus) external {
        eligibleUsers[user] = eligibilityStatus;
    }

    // Function to check if a user is eligible
    function isEligible(address user) external view returns (bool) {
        return eligibleUsers[user];
    }
}
