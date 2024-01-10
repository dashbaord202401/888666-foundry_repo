//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/Mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";


contract CreateSubscription is Script{
    function createSubscriptionUsingConfig() public returns (uint64){
        HelperConfig helperConfig = new HelperConfig();
        ( ,, address vrfCoordinatorV2,,,,) = helperConfig.activeNetworkConfig();
        return createSubscription(vrfCoordinatorV2);

        
    }

    function createSubscription(
        address vrfCoordinatorV2
        
    ) public returns (uint64) {
        console.log("Creating subscription on chainId: ", block.chainid);
        vm.startBroadcast();
        uint64 subId = VRFCoordinatorV2Mock(vrfCoordinatorV2)
            .createSubscription();
        vm.stopBroadcast();
        console.log("Your subscription Id is: ", subId);
        console.log("Please update the subscriptionId in HelperConfig.s.sol");
        return subId;
    }


    function run() external returns (uint64){
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script{
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public{
        HelperConfig helperConfig = new HelperConfig();
        ( ,, address vrfCoordinator2,,, uint64 subId, address link) = helperConfig.activeNetworkConfig();
        fundSubscription(vrfCoordinator2, subId, link);
    }

    function fundSubscription(address vrfCoordinatorV2, uint64 subId, address link) public {
        console.log ("Funding subscription:", subId);
        console.log ("Using vrfCoordinator:", vrfCoordinatorV2);
        console.log ("On chainID:", subId);
        if(block.chainid == 31337){
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCoordinatorV2).fundSubscription(
                subId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(link).transferAndCall(vrfCoordinatorV2, FUND_AMOUNT, abi.encode(subId));
            vm.stopBroadcast();
        }

    }

    function run()external {
        
    }
}

contract AddConsumer is Script {
    function addConsumer(
        address raffle,
        address vrfCoordinator,
        uint64 subId
      
    ) public {
        console.log("Adding consumer contract: ", raffle);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);
        vm.startBroadcast();
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(
            subId,
            raffle
        );
        vm.stopBroadcast();
    }

    function addConsumerUsingConfig(address raffle) public{
        HelperConfig helperConfig = new HelperConfig();
        ( ,, address vrfCoordinator2,,, uint64 subId,) = helperConfig
            .activeNetworkConfig();
        addConsumer(raffle,vrfCoordinator2, subId);
    }

    function run() external{
        address raffle = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        addConsumerUsingConfig(raffle);
    }

}