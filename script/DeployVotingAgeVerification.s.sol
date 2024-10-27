// script/DeployVotingAgeVerification.s.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {VotingAgeVerification} from "../src/VotingAgeVerification.sol";
import {MockAVSService} from "../test/VotingAgeVerification.t.sol";
import {console} from "forge-std/console.sol";

contract DeployVotingAgeVerification is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy the MockAVSService
        MockAVSService mockAVSService = new MockAVSService();

        // Deploy the VotingAgeVerification contract with the MockAVSService address
        VotingAgeVerification votingAgeVerification = new VotingAgeVerification(
            address(mockAVSService)
        );

        // Log the address of the deployed VotingAgeVerification contract
        console.log(
            "VotingAgeVerification deployed to:",
            address(votingAgeVerification)
        );

        vm.stopBroadcast();
    }
}
