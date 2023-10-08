// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;


import "../node_modules/@chainlink/contracts/src/v0.8/vrf/VRFV2WrapperConsumerBase.sol";

contract CoinFlip is VRFV2WrapperConsumerBase {

    event CoinFlipRequest(uint256 requestId);
    event CoinFlipResult(uint256 requestId, bool didWin);

    struct CoinFlipStatus {
        uint256 fees;
        uint256 randomWord;
        address player;
        bool didWin;
        bool fulfilled;
        CoinFlipSelection choice;
    }

    mapping(uint256 => CoinFlipStatus) public statuses;

    address constant linkAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    address constant vrfWrapperAddress = 0x2bce784e69d2Ff36c71edcB9F88358dB0DfB55b4;

    uint128 constant entryFees = 0.001 ether;
    uint32 constant callbackGasLimit = 1_000_000;
    uint32 constant numWords = 1;
    uint16 constant requestConfirmations = 3;

    constructor() 
        payable
        VRFV2WrapperConsumerBase(linkAddress, vrfWrapperAddress) 
    {}

    enum CoinFlipSelection {
        HEADS,
        TAILS
    }
    function flip(CoinFlipSelection choice) 
    external payable 
    returns (uint256)
    {
        require(msg.value == entryFees, "Entry fees not sent");
        uint256 requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
        statuses[requestId] = CoinFlipStatus({
            fees: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWord: 0,
            player: msg.sender,
            didWin: false,
            fulfilled: false,
            choice: choice
        });

        emit CoinFlipRequest(requestId);
        return requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        require(statuses[requestId].fees > 0, "Request not found");

        statuses[requestId].fulfilled = true;
        statuses[requestId].randomWord = randomWords[0];

        CoinFlipSelection result = CoinFlipSelection.HEADS;
        if(randomWords[0] % 2 == 0) {
            result = CoinFlipSelection.TAILS;
        }
        if(statuses[requestId].choice == result) {
            statuses[requestId].didWin = true;
            payable(statuses[requestId].player).transfer(entryFees * 2);
        }

        emit CoinFlipResult(requestId, statuses[requestId].didWin);
    }

    function getStatus(uint256 requestId)
        public
        view
        returns (CoinFlipStatus memory) 
    {
        return statuses[requestId];
    }
}
