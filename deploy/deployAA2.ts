import { ContractFactory, Provider, Wallet } from "zksync-ethers";
import { ethers } from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
// load env file
import dotenv from "dotenv";
dotenv.config();

const DEPLOYER_PRIVATE_KEY = process.env.WALLET_PRIVATE_KEY || "";

export default async function (hre: HardhatRuntimeEnvironment) {
  // @ts-ignore target zkSyncSepoliaTestnet in config file which can be testnet or local
  const provider = new Provider(hre.config.networks.zkSyncSepoliaTestnet.url);
  console.log(provider);
  const wallet = new Wallet(DEPLOYER_PRIVATE_KEY, provider);
  const deployer = new Deployer(hre, wallet);
  const aaArtifact = await deployer.loadArtifact("Account");
  const accountAbi = aaArtifact.abi;
  
//   console.log(accountAbi);
//   console.log(aaArtifact.bytecode);

  const accountFactory = new ContractFactory(accountAbi, aaArtifact.bytecode, wallet);   
  console.log(accountFactory);
//   const accountAbi = [ /* account contract ABI */ ];
// const accountBytecode = "0x..."; // account contract bytecode

// const accountFactory = new ContractFactory(accountAbi, accountBytecode, wallet)
  
  const owner = Wallet.createRandom();
  console.log("SC Account owner pk: ", owner.privateKey);
  console.log("SC Account owner address: ", owner.address);
  
  // const factory = new ContractFactory(artifact.abi, artifact.bytecode, wallet);

  // Deploy the contract
  // const contract = await accountFactory.deploy();

  // console.log("Contract deployed to:", contract.address);
  await createAccountWithCreate2(accountFactory, owner.address);
}

// const salt = ethers.utils.id("another unique salt");

async function createAccountWithCreate2(accountFactory: any, owner: any) {
    console.log('createAccountWithCreate2');

    const contract = await accountFactory.deploy(owner);

    // console.log(contract);

    console.log("Contract deployed to:", contract.target);

    // const account = await accountFactory.getDeployTransaction(ethers.ZeroHash);
    // console.log('account: ');
    // console.log(account);
    // await account.deployed();
    // console.log("Account contract deployed at address:", account.address);
}