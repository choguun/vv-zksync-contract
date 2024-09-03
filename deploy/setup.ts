import * as hre from "hardhat";
import { getWallet } from "./utils";
import { ethers } from "ethers";

// Address of the contract to interact with
// const CONTRACT_ADDRESS = "";
// if (!CONTRACT_ADDRESS) throw "⛔️ Provide address of the contract to interact with!";

// An example of a script to interact with the contract
export default async function () {
  // console.log(`Running script to interact with contract ${CONTRACT_ADDRESS}`);
  const world = "0x9d629C9aCb519CD8b1eaa06C9654D3a12F6B0e3c";
  const item = "0x9ab50Bb2A46948dC500ad94eEbC907c8082b5E86";
  const token = "0xB7fF27A62b27fBf3f347fa0289d2c4E595B078D7";
  const profile = "0xb49b523cFfa02d98ddd7f115ef96D75116cad260";
  const craft = "0x140aC38baa69734D51215A064Fa9223C8F8C78f4";
  const vault = "0x581639b57B0843c1F9B988811259FDb9e1E70281";

  // Load compiled contract info
  const WorldcontractArtifact = await hre.artifacts.readArtifact("World");
  const TokencontractArtifact = await hre.artifacts.readArtifact("Token");
  const CraftcontractArtifact = await hre.artifacts.readArtifact("CraftSystem");

  // Initialize contract instance for interaction
  const Worldcontract = new ethers.Contract(
    world,
    WorldcontractArtifact.abi,
    getWallet() // Interact with the contract on behalf of this wallet
  );

  const Tokencontract = new ethers.Contract(
    token,
    TokencontractArtifact.abi,
    getWallet() // Interact with the contract on behalf of this wallet
  );

  const Craftcontract = new ethers.Contract(
    craft,
    CraftcontractArtifact.abi,
    getWallet() // Interact with the contract on behalf of this wallet
  );

  const tx0 = await Tokencontract.setWorld(world);
  console.log(`Tx0: ${tx0.hash}`);
  await tx0.wait();

  // Run contract write function
  const tx1 = await Worldcontract.setProfile(profile);
  console.log(`Tx1: ${tx1.hash}`);
  await tx1.wait();

  const tx2 = await Worldcontract.setToken(token);
  console.log(`Tx2: ${tx2.hash}`);
  await tx2.wait();

  const tx3 = await Worldcontract.setItem(item);
  console.log(`Tx3: ${tx3.hash}`);
  await tx3.wait();

  const tx4 = await Worldcontract.setCraft(craft);
  console.log(`Tx4: ${tx4.hash}`);
  await tx4.wait();

  const tx5 = await Craftcontract.setItem(item);
  console.log(`Tx5: ${tx5.hash}`);
  await tx5.wait();

  const tx6 = await Worldcontract.createQuest("dailyCheckIn", "Daily Check In", 250, 0);
  console.log(`Tx6: ${tx6.hash}`);
  await tx6.wait();

  // 2. daily play mini game
  const tx7 = await Worldcontract.createQuest("miniGame", "Play mini game", 500, 1);
  console.log(`Tx7: ${tx7.hash}`);
  await tx7.wait();

  // 3. daily do craft item
  const tx8 = await Worldcontract.createQuest("doCraft", "Do Craft", 300, 2);
  console.log(`Tx8: ${tx8.hash}`);
  await tx8.wait();

  const tx9 = await Worldcontract.addItems(0, 0);
  console.log(`Tx9: ${tx9.hash}`);
  await tx9.wait();

  const tx10 = await Worldcontract.addItems(1, 1);
  console.log(`Tx10: ${tx10.hash}`);
  await tx10.wait();

  const tx11 = await Worldcontract.addItems(2, 2);
  console.log(`Tx11: ${tx11.hash}`);
  await tx11.wait();

  // 2 PICKAXE = 1 METAL PICKAXE
  const tx12 = await Worldcontract.addRecipe([0], [2], 1);
  console.log(`Tx12: ${tx12.hash}`);
  await tx12.wait();

  // 2 METAL PICKAXE = 1 GOLDEN PICKAXE
  const tx13 = await Worldcontract.addRecipe([1], [2], 2);
  console.log(`Tx13: ${tx13.hash}`);
  await tx13.wait();

  const tx14 = await Worldcontract.createItem(0, "NORMAL PICKAXE", "NORMAL PICKAXE", 100);
  console.log(`Tx14: ${tx14.hash}`);
  await tx14.wait();

  const tx15 = await Worldcontract.createItem(1, "METAL PICKAXE", "METAL PICKAXE", 250);
  console.log(`Tx15: ${tx15.hash}`);
  await tx15.wait();

  const tx16 = await Worldcontract.createItem(2, "GOLDEN PICKAXE", "GOLDEN PICKAXE", 600);
  console.log(`Tx16: ${tx16.hash}`);
  await tx16.wait();

  const tx17 = await Worldcontract.setVault(vault);
  console.log(`Tx17: ${tx17.hash}`);
  await tx17.wait();
}
