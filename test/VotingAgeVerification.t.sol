// test/VotingAgeVerification.t.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {VotingAgeVerification} from "../src/VotingAgeVerification.sol";

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

contract VotingAgeVerificationTest is Test {
    VotingAgeVerification votingAgeVerification;
    MockAVSService mockAVSService;

    function setUp() public {
        // Deploy the mock AVS service and set eligibility
        mockAVSService = new MockAVSService();
        votingAgeVerification = new VotingAgeVerification(
            address(mockAVSService)
        );

        // Set the current test address as eligible
        mockAVSService.setMockUserEligibility(address(this), true);
    }

    function testRegisterVoterSuccess() public {
        uint256 eighteenYearsAgo = 18 * 365 days;
        vm.warp(block.timestamp + eighteenYearsAgo); // Simulate an 18-year-old birthdate
        uint256 birthDate = block.timestamp - eighteenYearsAgo;

        votingAgeVerification.registerVoter(birthDate);

        (uint256 storedBirthDate, bool hasVoted) = votingAgeVerification.voters(
            address(this)
        );
        assertEq(storedBirthDate, birthDate);
        assertFalse(hasVoted);
    }

    function testRegisterVoterUnderage() public {
        uint256 sixteenYearsAgo = 16 * 365 days;
        vm.warp(block.timestamp + sixteenYearsAgo); // Simulate a 16-year-old birthdate
        uint256 birthDate = block.timestamp - sixteenYearsAgo;

        // Expect the Underage error with specific parameter (16 years)
        vm.expectRevert(
            abi.encodeWithSelector(VotingAgeVerification.Underage.selector, 16)
        );
        votingAgeVerification.registerVoter(birthDate);
    }

    function testIneligibleVoterCannotRegister() public {
        // Make the test address ineligible
        mockAVSService.setMockUserEligibility(address(this), false);

        uint256 eighteenYearsAgo = 18 * 365 days;
        vm.warp(block.timestamp + eighteenYearsAgo);
        uint256 birthDate = block.timestamp - eighteenYearsAgo;

        // Expect the NotEligible error since the user is marked ineligible
        vm.expectRevert(VotingAgeVerification.NotEligible.selector);
        votingAgeVerification.registerVoter(birthDate);
    }

    function testVoteSuccess() public {
        uint256 eighteenYearsAgo = 18 * 365 days;
        vm.warp(block.timestamp + eighteenYearsAgo);
        uint256 birthDate = block.timestamp - eighteenYearsAgo;

        votingAgeVerification.registerVoter(birthDate);
        votingAgeVerification.vote();

        (, bool hasVoted) = votingAgeVerification.voters(address(this));
        assertTrue(hasVoted);
    }

    function testDoubleVoteNotAllowed() public {
        uint256 eighteenYearsAgo = 18 * 365 days;
        vm.warp(block.timestamp + eighteenYearsAgo);
        uint256 birthDate = block.timestamp - eighteenYearsAgo;

        votingAgeVerification.registerVoter(birthDate);
        votingAgeVerification.vote();

        vm.expectRevert(VotingAgeVerification.AlreadyVoted.selector);
        votingAgeVerification.vote();
    }
}
