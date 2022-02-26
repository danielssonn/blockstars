# NFT based Awards

![](../assets/Award%20Contract.png)


## Details

- [x] Awards contract has an overall budget, that can be augmented by addToAwardsBudget()
- [x] This will be a real transfer of ETH, the sender must be valid and have the amount of ETH in their account
- [x] Awards can then be minted
- [x] NFT will be created for the award by the minting process.
- [x] ETH will be moved from the Award budget, and vested for the winner for a vesting period (1 ETH currently for 10 days)
- [x] ETH in the individual award can be withdrawn, if vesting period has passed by withdrawAwardETH
- [x] Award will only be minted if there is available budget
- [x] Award will not be minted for organizers
- [ ] Think of the minting process and winner having the ability to configure
- [ ] Currently the minting makes someone a winner and also sets the NFT and monetary reward. We might want to split the **win** and **mint**
- [x] Utility methods for the UI created to display awards, display vested awards, enable the withdrawal via dApp
- [x] Winner can have multiple awards in parallel, each with its own reward and vesting
- [x] The NFT in the Award should be more independent from the Award - and possible to trade/move independently
- [x] Compose the NFT into the Award, vs. have the Award be a NFT itself
- [ ] On-chan AML check will be performed on winner's wallet to ensure it is not on a 'bad list'
- [x] test: basic unit tests for the Award contract
- [ ] test, test!
- [ ] Figure out the on and off-chain identity matching / DID 
![](../assets/Identity%20Mapping.png) 
- [ ] hook up and optimize Oracles interactions


Contract: [Kovan Etherscan](https://kovan.etherscan.io/address/0x29B746f28114a2D91eF4DF9315d16CE5e0C267Ae)

## Do you want to play a game?

- [x] Go to the Contract address on Etherscan, above
- [x] Find Contract tab, you should see verified checkmark
- [x] Select Write Contract
- [x] Connect your Metamask on Kovan testnet, make sure you have some test ETH (https://faucets.chain.link/)
- [x] Fund your Award contract to set the Award budget via addToAwardsBudget()
- [x] Set how much each award will be via setAwardAmountETH (in Wei). 
- [x] Default is 1ETH (1+ 18 zeros), it might be a challenge to get this much test ETH - so lower this.
- [x] Create an award by mintWinner(), use https://gateway.pinata.cloud/ipfs/QmXreJ8rdSBihsDSVKkNG4J44VDJ8Et6bDsKdmBdfGyXH1 as tokenURI to test
- [ ] Will need to generate the Award metadata and tokenURI - and push it to IPFS as part of the minting process
- [ ] POAP business is TBD, follow the same split/composition rationale with NFTs?
- [x] Award should be vesting
- [x] In 10 days, the award ETH has vested and can be withdrawn to winner's wallet
- [ ] **Withdrawal should only work if the winner is still an employee**

