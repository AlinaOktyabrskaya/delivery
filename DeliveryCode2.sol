// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DeliveryCode2 {
    address public buyer;
    address payable public seller;

    uint256 public amount;
    bytes32 public deliveryCommitment;

    bool public released;

    constructor(
        address payable _seller,
        bytes32 _deliveryCommitment
    ) payable {
        require(msg.value > 0, "Need ETH deposit");

        buyer = msg.sender;
        seller = _seller;
        amount = msg.value;
        deliveryCommitment = _deliveryCommitment;
    }

    function releaseFunds(
        string calldata deliveryCode,
        string calldata nonce
    ) external {
        require(!released, "Already released");
        require(msg.sender == seller, "Only seller can claim");

        bytes32 computedCommitment = keccak256(
            abi.encode(
                seller,
                deliveryCode,
                nonce
            )
        );

        require(
            computedCommitment == deliveryCommitment,
            "Invalid delivery proof"
        );

        released = true;

        (bool success, ) = seller.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
}