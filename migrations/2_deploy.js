const InitialRug = artifacts.require("./InitialRug.sol");
const FinalRug = artifacts.require("./FinalRug.sol");
const RealityRugs = artifacts.require("./RealityRugs.sol");

module.exports = async (deployer, network) => {
  // OpenSea proxy registry addresses for rinkeby and mainnet.
  let proxyRegistryAddress = "";
  if (network === 'rinkeby') {
    //proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
    proxyRegistryAddress = '0x1e525eeaf261ca41b809884cbde9dd9e1619573a';
  } else {
    proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  }
  proxyRegistryAddress = '0x1e525eeaf261ca41b809884cbde9dd9e1619573a';

  await deployer.deploy(FinalRug, proxyRegistryAddress, {gas: 5000000})
  await deployer.deploy(RealityRugs, proxyRegistryAddress, FinalRug.address);

  const finalRug = await FinalRug.deployed();
  const factory = await RealityRugs.deployed();
  const initialNftAddress = await factory.initialAddress();
  await finalRug.setInitialAddress(initialNftAddress);

  //const owner = '0x0b826bb8634660752cc679e9bdb90cb3642020bd';
    const owner = "0x6b9908e59abbc640cfaaa049f418fea24657c4ac";
  await finalRug.transferOwnership(owner);
  await factory.transferOwnership(owner);
    

};
