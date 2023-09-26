
import { ethers, upgrades } from "hardhat";
import '@openzeppelin/hardhat-upgrades';


async function main() {

  const Xucre = await ethers.getContractFactory("Xucre");
  //const xucre = await upgrades.deployProxy(Xucre, [ethers.utils.getAddress('0xee637cBC48e42ce104E2BB42cbd26C407A867119'), 'Xucre', 'XRE']);
  //console.log('waiting for deployProxy', xucre);
  //const estimatedGas = await ethers.provider.estimateGas(xucre);
  
  const xucre2 = await Xucre.interface.encodeDeploy([ethers.utils.getAddress('0x358eB621894B55805CE16225b2504523d421d3A6'), 'Xucre', 'XRE']);
  const estimatedGas = await ethers.provider.estimateGas({ data: xucre2 });
  console.log('gas estimate', estimatedGas);

  const xucre = await Xucre.deploy(ethers.utils.getAddress('0x358eB621894B55805CE16225b2504523d421d3A6'), 'Xucre', 'XRE', {gasPrice: 70389863643});
  await xucre.deployed();
  console.log("Xucre deployed to:", xucre.address);
  
  //const init = await xucre.initialize(ethers.utils.getAddress('0x19316109C70084D0E34C6b28AD5b6298aFB2dB3c'), 'Xucre', 'XRE')
  //await init.wait();

  //const name = await xucre.name();
  //console.log('token name', name);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
//0xee637cBC48e42ce104E2BB42cbd26C407A867119