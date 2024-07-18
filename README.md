# vv-zksync-contract

### Vision
* On-chain Autonomous Sandbox games. Players can explore, craft, combat, and compete to win prizes.

### Description
* We are building On-chain Autonomous Sandbox games. Players can explore, craft, combat, and compete to win prizes.

### Problem
-Lack of True Ownership: Players do not genuinely own in-game assets. \
-Centralized Control: Game companies have complete control, limiting player autonomy. \
-Content Limitations: Restricted game content reduces long-term engagement. \
-Unsustainable Game Economics: Games often fail to maintain a sustainable economy, leading to short-lived experiences.


### Technologies Used:
1. Smart Contract(Autonomous World) \
     1.1 On-chain in-game Items, Token, and NFTs \
     1.2 Game Logic
2. WebGL to render game on browser
3. Game Engine(Real-time Open World, Indexer) utilizes an entire data stored on-chain. 
4. AI-generated content & LLM

### Key Features:
1. On-chain Game Logic eg. Quest(Daily Check-in, Raffle, Mini game), Craft, Item, Token, Profile, Vault, and World.
2. Multiplayer
3. Supported Multi-Platform on browser
4. Paymaster

### How it works:
![How it works](/howitwork.png "How it works")

### Demo:
https://zksync.voxelverses.xyz


### How to deploy vv-zksync-contract
* npm run deploy
* npm run setup

### Deployed Smart Contract
1. Profile - NFT Profile to identify unique user https://sepolia.explorer.zksync.io/address/0x3c6843A3c8cAa69e843d82617de46A4883a0B4F7
2. Token - ERC20 In-game token https://sepolia.explorer.zksync.io/address/0x3cA22Bd7d7699340fC12e4B56F6d1b182038bfE6
3. Item - ERC1155 game item https://sepolia.explorer.zksync.io/address/0xecfA6096A6c35d19933Ea9D0126C81568e4B7f95
4. World - On-chain game logic https://sepolia.explorer.zksync.io/address/0xE2F279dF93d6C9e991115c281F7733f0d67e3406
5. Raffle - Raffle Module for mini game https://sepolia.explorer.zksync.io/address/0xE2F279dF93d6C9e991115c281F7733f0d67e3406
8. CraftSystem - Craft system module https://sepolia.explorer.zksync.io/address/0x6135BEAb54A539b73C552fcaBd97bb44dc5c56c0
9. Paymaster - Paymaster module https://sepolia.explorer.zksync.io/address/0x47e31CbF55CfcdEE01abeF3153EBDCfBB4a8658B