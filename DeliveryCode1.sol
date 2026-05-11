// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DeliveryCode1 {
    address public buyer;
    address public seller;

    uint256 public amount;

    string private deliveryCode;

    constructor(
        address _seller,
        string memory _deliveryCode
    ) payable {
        buyer = msg.sender;
        seller = _seller;
        amount = msg.value;

        deliveryCode = _deliveryCode;
    }

    function releaseFunds(string calldata code) external {
        require(
            keccak256(bytes(code)) ==
            keccak256(bytes(deliveryCode)),
            "Wrong code"
        ); 

        // to make it more dramatic, i intentionally use msg.sender.
        // payable(seller) can be used instead, when attacker cannot hijeck seller's address 
        payable(msg.sender).transfer(amount);
    }

}