// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "./interfaces/IOracleClient.sol";
import "./AwardCertificate.sol";
import "./Staking.sol";

contract Award is Ownable {
    // oracleClient to get to off chain HR
    IOracleClient public hrAdapter;

    IOracleClient public amlAdapter;

    // Owner of this contract
    address _owner;

    // This is the total balance/overall budget for all Awards.
    uint256 totalAwardBudget = 0;

    // 1 ETH for single award 1 * 10**18;
    uint256 singleAwardAmount = 100;

    // 10 days award vesting - we are so generous!
    uint256 awardVestingTime = 10;

    address awardCertificateContract =
        0x5A510a87A6769b9205DbD52A8AA94D6b6f238760;

    address stakingToken = 0x8AD480A0f14aa1E4e79Bc767D5A2f48D49172abB;

    address rewardToken = 0xbe3b60170D7d86776e6C8d350685d16e32477952;

    // date until when will this award run

    uint awardCycleLength = 52 weeks; 
    
    uint public awardDate = 0; 


    // call pre-deployed contract
    // awardCertificate public awardCertificate = awardCertificate(awardCertificateContract);

    // deploy on the fly
    AwardCertificate public awardCertificate;
    Staking public awardStaking;


    // Winner can have mutiple awards, concurrently
    mapping(address => mapping(uint256 => uint256)) public wonAwards;

    // Manage when the user won, to enable vesting
    mapping(address => mapping(uint256 => uint256)) public wonTimestamps;

    // Keep track of mintend NFTs - winner - awardIdx - itemId on the NFT contract
    mapping(address => mapping(uint256 => uint256)) public mintedCertificates;

    // Number of wins for each winner
    mapping(address => uint256) public winerAwardCount;

    // Unique hash representing the winner in off-chain systems
    mapping(address => bytes32) public winnerOffChain;

    // Manage the AML pass
    mapping(address => bool) public winnerAMLCheck;

    constructor(address _hrAdapter, address _amlAdapter) {
        _owner = msg.sender;

        awardDate = block.timestamp + awardCycleLength;
        awardCertificate = new AwardCertificate();

        awardStaking = new Staking(stakingToken, rewardToken);
        hrAdapter = IOracleClient(_hrAdapter);
        amlAdapter = IOracleClient(_amlAdapter);
    }

    function getTotalAwardBudget() public view returns (uint256) {
        return totalAwardBudget;
    }

    // Contract owner can add to the overall Award balance budget
    function addToAwardsBudget() public payable onlyOwner {
        totalAwardBudget = totalAwardBudget + msg.value;
    }

    function setCertificateContract(address nftContractAddress)
        public
        onlyOwner
    {
        awardCertificateContract = nftContractAddress;
    }

    // Minting will create a certificare, move some money from the budget to winner's balance where we'll stake it for a bit
    // Minting will also update the AwardToken distribution in awardStaking contract, rewarding those who staked the right winner
    // This is where we can eventually make the whole process Smart Contract based, incl. deciding who won in another contract through DAO voting!
    // For now, we'll select an arbitrary winner
    function mintWinner(address winner, string memory tokenURI)
        public
        onlyOwner
    {
        require(winner != _owner, "Sorry, the organizers cannot win awards!");
        require(
            (totalAwardBudget > singleAwardAmount),
            "Award budget low on funds."
        );

        uint256 nftItemId = awardCertificate.mintNFT(winner, tokenURI);
        winerAwardCount[winner] = winerAwardCount[winner] + 1;

        uint256 awardNumberForWinner = winerAwardCount[winner];

        hrAdapter.requestEligibilityOffChain(winner);
        amlAdapter.requestAMLCheck(winner);

        wonAwards[winner][awardNumberForWinner] = singleAwardAmount;
        wonTimestamps[winner][awardNumberForWinner] = block.timestamp;
        mintedCertificates[winner][awardNumberForWinner] = nftItemId;
        winnerOffChain[winner] = keccak256(abi.encodePacked(winner));

        awardStaking.rebalanceStakes(winner);

        totalAwardBudget = totalAwardBudget - singleAwardAmount;
    }

    // Withdraw the monetary award, but only if vested ...
    function withdrawAwardETH(uint256 awardNumber) public payable {
        require(
            isAwardVested(msg.sender, awardNumber),
            "This award still needs to vest."
        );
        address payable withdrawTo = payable(msg.sender);
        uint256 amountToTransfer = getAwardETHBalance(msg.sender, awardNumber);

        withdrawTo.transfer(amountToTransfer);
        totalAwardBudget = totalAwardBudget - amountToTransfer;

        wonAwards[msg.sender][awardNumber] = 0;
    }

    function getAwardETHBalance(address winnerAddress, uint256 awardNumber)
        public
        view
        returns (uint256)
    {
        return wonAwards[winnerAddress][awardNumber];
    }

    // Some funky Solidity stuff to return the mapping value ...
    function getAllAwards(address winnerAddress)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory ret = new uint256[](winerAwardCount[winnerAddress]);
        for (uint256 i = 0; i < winerAwardCount[winnerAddress]; i++) {
            ret[i] = wonAwards[winnerAddress][i];
        }
        return ret;
    }

    function getAllVestedAwards(address winnerAddress)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory ret = new uint256[](winerAwardCount[winnerAddress]);
        for (uint256 i = 0; i < winerAwardCount[winnerAddress]; i++) {
            //check the original timestamp, make sure it is older than vesting period
            if (
                block.timestamp >
                wonTimestamps[winnerAddress][i] + awardVestingTime
            ) {
                ret[i] = wonAwards[winnerAddress][i];
            }
        }
        return ret;
    }

    function isAwardVested(address winnerAddress, uint256 awardNumber)
        public
        view
        returns (bool)
    {
        if (
            block.timestamp >
            (wonTimestamps[winnerAddress][awardNumber] +
                awardVestingTime *
                1 days)
        ) {
            return true;
        }
        return false;
    }

    function getAwardCertificateItemId(
        address winnerAddress,
        uint256 awardNumber
    ) public view returns (uint256) {
        return mintedCertificates[winnerAddress][awardNumber];
    }

    function getAwardCertificateContrat() public view returns (address) {
        return awardCertificateContract;
    }

    // Award amount in Wei
    function setAwardAmountETH(uint256 amount) public onlyOwner {
        singleAwardAmount = amount;
    }

    function setAwardVestingTime(uint256 vestingTimeInDays) public onlyOwner {
        awardVestingTime = vestingTimeInDays;
    }
}
