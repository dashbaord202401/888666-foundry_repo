//SPDX-Indentifier-Indentifier: MIT


pragma solidity ^0.8.18;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test,console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract RaffleTest is Test {
    /*EVENT*/
    event EnteredRaffle(address indexed player); //0 - expectEmit - Redefine event

    Raffle raffle;
    HelperConfig helperConfig;
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionID;
    uint32 callbackGasLimit;
    address link;    


    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;


    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();
        (   entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionID,
            callbackGasLimit,
            link
        ) = helperConfig.activeNetworkConfig();

        vm.deal(PLAYER,STARTING_USER_BALANCE);  //funding PLAYER with a balance

    }

    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }


    ////Enter Raffle////

    function testRaffleRevertWhenYoudontPayEnough() public {
        vm.prank(PLAYER); 
        vm.expectRevert(Raffle.Raffle__NotEnoughEthSent.selector);
        raffle.enterRaffle();

    }
    
    function testRaffleRecordsPlayerWhenTheyEnter() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value:entranceFee}();
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);

    }

    function testRaffleEmitOnEntrance () public {
        vm.prank(PLAYER);  //set msg.sender for the next call to anyvalue
        vm.expectEmit(true, false, false, false, address (raffle)); // expectedEmit () - tell Foundry which data to check: check index 1 & data (raffle contract addr)
        emit EnteredRaffle(PLAYER); // Emit the expected event
        raffle.enterRaffle{value: entranceFee}; // call the function that emits the event
    }

    function testCantEnterWhenRaffleIsCalculating () public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value:entranceFee}();
    }
}