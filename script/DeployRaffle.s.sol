//SPDX-License-Identifier: MIT


pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription,FundSubscription,AddConsumer} from "./Interaction.s.sol";

contract DeployRaffle is Script{
    function run() external returns (Raffle, HelperConfig){
        HelperConfig helperConfig = new HelperConfig();
       (uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionID,
        uint32 callbackGasLimit,
        address link)
        = helperConfig.activeNetworkConfig();
    
    if (subscriptionID == 0){
        //create subscription
        CreateSubscription createSubscription = new CreateSubscription();
        subscriptionID = createSubscription.createSubscription(vrfCoordinator);
    }
        //Fund it!
        FundSubscription fundSubscription = new FundSubscription();
        fundSubscription.fundSubscription(vrfCoordinator, subscriptionID,link);

        


        vm.startBroadcast();
        Raffle raffle = new Raffle(
        entranceFee,
        interval,
        vrfCoordinator,
        gasLane,
        subscriptionID,
        callbackGasLimit);
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            vrfCoordinator,
            subscriptionID
        );
        return (raffle,helperConfig);
        
    }

}