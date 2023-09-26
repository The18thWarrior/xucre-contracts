
import { ethers, upgrades } from "hardhat";
import '@openzeppelin/hardhat-upgrades';


async function main() {

  const abiCoder = ethers.utils.defaultAbiCoder;
  const data = abiCoder.encode([ "address", "string", "string" ], [ ethers.utils.getAddress('0x358eB621894B55805CE16225b2504523d421d3A6'), 'Xucre', 'XRE' ]);
  console.log(data);
  
  

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
//0xee637cBC48e42ce104E2BB42cbd26C407A867119