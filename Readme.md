This set of intentionally vulnerable contracts is designed to explore 
accessing private data and commit-reveal process. 
By design, we have two users (buyer and seller). They exchange 'deliveryCode' somehow 
outside blockchain. Now, buyer send some amount of ETH to seller. To recieve funds, seller 
need to submit 'deliveryCode' as a confirmation of his intentions/identity. If code is correct, 
seller recieves funds.  

Technical process:  Address1 == buyer, Address2 == seller 

Buyer deploys contract DeliveryCodeN with value, address, and code 

Contract holds this amount 

Seller calls releaseFunds() function with code as an argument 

If code is correct, contract release funds to seller. 

DeliveryCode1 contract : deliveryCode is stored in prrivate variable 
as soon as buyer sumbit seller address and code, deliveryCode value will be visible on-chain 


To run codes, we connect to local anvil network to test.  
Buyer deploys DeliveryCode1 from account (0) with code ‘tst’.  As soon as deployed: 

1 Blockchain stores transaction record , including created contract address 

2 contract bytecode – blockchain stores deployed smart contract code, with all data belong to contract.
Now this contract does not belong to buyer, seller or any other identity, it is a separate unit on blockchain. 
In this stage, eth locked inside smart contract. 

We inspection transaction record with following command in Git Bash: 
cast tx 0x8d6df68b23dc82f148f773248c8b5fd683eaf9f124ca2ef403e2807da840be8b --rpc-url http://127.0.0.1:8545

and see raw tx data. Constructor arguments are  ABI-encoded into deployment calldata. 
We only can see contract address there which is 
0x4178a206fd5bE223c86E9C5B552ff3D11B9a3c20

Now, we inspect contract itself, and call for each slot: 

$ cast storage 0x4178a206fd5bE223c86E9C5B552ff3D11B9a3c20 3 --rpc-url http://127.0.0.1:8545

returns: 0x7473740000000000000000000000000000000000000000000000000000000006
 
Slots are in the order it appears in contract, so
 slot 0 is buyer, slot 1 is seller, slot 2 is amount, slot 3 is – code. 
 Addresses appear in form they are, amount and code are ABI encoded. 
Now we know – code is 0x7473740000000000000000000000000000000000000000000000000000000006
And it is encoded, not encrypted, we use: 

$ cast parse-bytes32-string 0x7473740000000000000000000000000000000000000000000000000000000006

to recieve: tst

We also can call 
cast call CONTRACT_ADDRESS "amount()(uint256)" --rpc-url http://127.0.0.1:8545 
for public variables like amount; it will not work for private var like deliveryCode, 
but still it is stored in contract – so we can easily to get its value. 

Now contract keeps living on-chain with some values in its slots and exposed deliveryCode…


If payable(msg.sender) used, when funds are received by whoever called releaseFunds() function first, 
it does not pay to seller if it was not seller. 
Pretending to be attacker from account (3), submit the code obtained from contract storage. 
As account (3) is calling, eth goes to account (3) – attacker.  Done.




DeliveryCode2 contract : the issue of DeliveryCode1 can be solved by implementing the process we call 
commit-reveal. 

In this case, buyer and seller do not start from sharing 'deliveryCode'. Instead, the first step will 
be like follow: seller creates deliveryCode and nonce only seller knows. When seller encrypts it
and he can send resulting hash to buyer in any form he wish. 

Buyer deploys contract with hash seller gave him. Now, even if this hash published on blockchain, 
all data is encrypted, and potential attacker will have a hard time to decrypt it. 
Say, if only code was encrypted, and code is simple word like "code", or "delivery" or something, 
hash can be brute-forced. But with nonce, brute-force become harder, if not possible in feasible time. 

Next step as buyer deploys and coins are locked inside contract, 
seller calls releaseFunds() with code and nonce he only knows. It will be accepted, as hash is same as 
deliveryCommitment, and funds will reach supposed reciever. 

