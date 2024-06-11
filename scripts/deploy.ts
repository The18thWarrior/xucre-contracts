
import { ethers, upgrades } from "hardhat";
import { ERC20__factory } from "../typechain-types";
import '@openzeppelin/hardhat-upgrades';
import { JsonRpcSigner } from "@ethersproject/providers";
import { BigNumber } from "ethers";

const SWAP_ROUTER_ADDRESS = "0xE592427A0AEce92De3Edee1F18E0157C05861564";
const DEV_ACCOUNT_ADDRESS = "0x19316109C70084D0E34C6b28AD5b6298aFB2dB3c";
const OWNER_ADDRESS = "0x19316109C70084D0E34C6b28AD5b6298aFB2dB3c";
const DAI = "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063";
const USDT = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";
const WBTC = "0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6";
const UNI = async (signer: JsonRpcSigner) => {
  return await ERC20__factory.connect("0xb33EaAd8d922B1083446DC23f610c2567fB5180f", signer);
}
const XUCRE = async (signer: JsonRpcSigner) => {
  return await ERC20__factory.connect("0x924442A46EAC25646b520Da8D78218Ae8FF437C2", signer);
}

async function main() {
  const signer = ethers.provider.getSigner();
  const signerAddress = await signer.getAddress();
  const poolFee = BigNumber.from(10000);
  console.log(signerAddress)

  const USDT_CONTRACT = await ERC20__factory.connect(USDT, signer);
  const DAI_CONTRACT = await ERC20__factory.connect(DAI, signer);
  const WBTC_CONTRACT = await ERC20__factory.connect(WBTC, signer);
  const XUCRE_CONTRACT = await XUCRE(signer);
  const UNI_CONTRACT = await UNI(signer);
  const balance = await DAI_CONTRACT.balanceOf(signerAddress);
  console.log('initial DAI balance', balance.toString());
  const wbtcbalance = await WBTC_CONTRACT.balanceOf(signerAddress);
  console.log('initial WBTC balance', wbtcbalance.toString());
  const unibalance = await UNI_CONTRACT.balanceOf(signerAddress);
  console.log('initial UNI balance', unibalance.toString());

  const balanceUSDT = await USDT_CONTRACT.balanceOf(signerAddress);
  console.log('usdt initial balance', balanceUSDT.toString());
  const Xucre = await ethers.getContractFactory("XucreETF");
  //const xucre = await upgrades.deployProxy(Xucre, [ethers.utils.getAddress('0xee637cBC48e42ce104E2BB42cbd26C407A867119'), 'Xucre', 'XRE']);
  //console.log('waiting for deployProxy', xucre);
  //const estimatedGas = await ethers.provider.estimateGas(xucre);
  
  // const xucre2 = await Xucre.interface.encodeDeploy([ethers.utils.getAddress(OWNER_ADDRESS), ethers.utils.getAddress(SWAP_ROUTER_ADDRESS)]);
  // const estimatedGas = await ethers.provider.estimateGas({ data: xucre2 });
  // console.log('gas estimate', estimatedGas);

  const xucre = await Xucre.deploy(ethers.utils.getAddress(OWNER_ADDRESS), ethers.utils.getAddress(SWAP_ROUTER_ADDRESS), XUCRE_CONTRACT.address,poolFee);
  await xucre.deployed();
  console.log("XucreETF deployed to:", xucre.address);
  
  const result = await USDT_CONTRACT.approve(xucre.address, ethers.utils.parseEther('100'));

  console.log('approved', result.hash);
  try {
    const runSwap = await xucre.spotExecution(signerAddress, [ethers.utils.getAddress(DAI), ethers.utils.getAddress(WBTC), UNI_CONTRACT.address], [6000, 2000, 2000], [3000, 3000, 3000], USDT_CONTRACT.address, balanceUSDT.div(100));
    const res2 = await runSwap.wait();
    //const events = res2["events"] as unknown as Event[];
    //console.log(JSON.stringify(events, null, 2))
  } catch (err) {
    console.log('error thrown');
  }

  const final_balance = await DAI_CONTRACT.balanceOf(signerAddress);
  console.log('final DAI balance', final_balance.toString());

  const final_wbtcbalance = await WBTC_CONTRACT.balanceOf(signerAddress);
  console.log('final WBTC balance', final_wbtcbalance.toString());

  const final_unibalance = await UNI_CONTRACT.balanceOf(signerAddress);
  console.log('final UNI balance', final_unibalance.toString());
  
  return;
  //const name = await xucre.name();
  //console.log('token name', name);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  //console.log('error thrown', error.message)
  process.exitCode = 1;
});
//0xee637cBC48e42ce104E2BB42cbd26C407A867119