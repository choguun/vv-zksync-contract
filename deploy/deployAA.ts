import { Deployer } from "@matterlabs/hardhat-zksync";
import { getProvider, getWallet, verifyContract } from "./utils";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { EIP712Signer, types, utils } from "zksync-ethers";
import {
  AbiCoder,
  Contract,
  Signature,
  ZeroHash,
  concat,
  parseEther,
} from "ethers";

export default async function (hre: HardhatRuntimeEnvironment) {
  const provider = getProvider();
  const wallet = getWallet();
  const deployer = new Deployer(hre, wallet);

  const factoryArtifact = await deployer.loadArtifact("AAFactory");
  const accountArtifact = await deployer.loadArtifact("Account");

  const aaBytecodeHash = utils.hashBytecode(accountArtifact.bytecode);

  const factory = await deployer.deploy(
    factoryArtifact,
    [aaBytecodeHash],
    undefined,
    undefined,
    [accountArtifact.bytecode]
  );

  const factoryAddress = await factory.getAddress();

  console.log(`Factory address: ${factoryAddress}`);

  const abiCoder = new AbiCoder();

  await verifyContract({
    address: factoryAddress,
    contract: "contracts/AAFactory.sol:AAFactory",
    constructorArguments: abiCoder.encode(["bytes32"], [aaBytecodeHash]),
    bytecode: factoryArtifact.bytecode,
  });

  const salt = ZeroHash;
  const owner = wallet.address;

  // const tx = await factory.deployAccount(salt, owner, { gasLimit: 5000000 });
  // await tx.wait();

  // const accountAddress = await factory.getAccountAddress(salt, owner);

  // console.log(`Account address: ${accountAddress}`);

  // await verifyContract({
  //   address: accountAddress,
  //   contract: "contracts/Account.sol:Account",
  //   constructorArguments: abiCoder.encode(["address"], [owner]),
  //   bytecode: accountArtifact.bytecode,
  // });

  console.log("Done!");
}
