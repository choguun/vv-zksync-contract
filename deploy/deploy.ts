import { deployContract } from "./utils";
import { getWallet } from "./utils";
// An example of a basic deploy script
// It will deploy a Greeter contract to selected network
// as well as verify it on Block Explorer if possible for the network
export default async function () {
  // const contractArtifactName = "Greeter";
  // const constructorArguments = ["Hi there!"];
  // await deployContract(contractArtifactName, constructorArguments);
  const ownerX = getWallet();
  const owner = await ownerX.address;

  const profile = await deployContract("Profile", [owner]);
  const world = await deployContract("World", [owner]);
  const token = await deployContract("Token", [owner, await world.getAddress(), await profile.getAddress()]);
  const craft = await deployContract("CraftSystem", [owner, await world.getAddress()]);
  const item = await deployContract("Item", [owner, await world.getAddress(), await craft.getAddress(), ""]);
  const vault = await deployContract("ERC4626Vault", [await token.getAddress()]);

  await token.setWorld([await world.getAddress()]);
  
  console.log(
    `item address: ${await item.getAddress()}`
  );
  console.log(
    `token address: ${await token.getAddress()}`
  );
  console.log(
    `profile address: ${await profile.getAddress()}`
  );
  console.log(
    `world address: ${await world.getAddress()}`
  )
  console.log(
    `craft address: ${await craft.getAddress()}`
  );
  console.log(
    `vault address: ${await vault.getAddress()}`
  )
}
