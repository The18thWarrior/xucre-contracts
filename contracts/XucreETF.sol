// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.20;

/// @title An ETF contract leveraging Uniswap V3
/// @author Jordan Paul
/// @dev All function calls are currently implemented without side effects

pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract XucreETF is ERC721, ERC721Pausable, AccessControl {
    struct ETFDefinition {
        address[] xucre_targetTokens;
        uint256[] xucre_inputAmounts;
        uint24[] xucre_poolFees;
        uint256 xucre_amount;
        address xucre_paymentToken;
    }

    bytes32 public immutable PAUSER_ROLE;
    bytes32 public immutable MINTER_ROLE;
    bytes32 public immutable BATCH_CALL_ROLE;

    ISwapRouter public immutable xucre_swapRouter;

    address public immutable XUCRE;
    uint24 public immutable poolFee;

    uint256 private xucre_nextTokenId;
    mapping(address => ETFDefinition) private etfMappings;

    event Mint(
        address to,
        address[] targetTokens,
        uint256[] allocation,
        uint24[] poolFees,
        uint256 amount,
        address paymentToken
    );
    event Update(
        address to,
        address[] targetTokens,
        uint256[] allocation,
        uint24[] poolFees,
        uint256 amount,
        address paymentToken
    );

    event Console(uint256 message);

    constructor(
        address owner_xucre,
        address swapRouter_xucre,
        address tokenContract_xucre,
        uint24 poolFee_xucre
    ) ERC721("Xucre ETF", "XUCRETF") {
        PAUSER_ROLE = keccak256("PAUSER_ROLE");
        MINTER_ROLE = keccak256("MINTER_ROLE");
        BATCH_CALL_ROLE = keccak256("BATCH_CALL_ROLE");
        _grantRole(DEFAULT_ADMIN_ROLE, owner_xucre);
        _grantRole(PAUSER_ROLE, owner_xucre);
        _grantRole(MINTER_ROLE, owner_xucre);
        _grantRole(BATCH_CALL_ROLE, owner_xucre);
        xucre_swapRouter = ISwapRouter(swapRouter_xucre);
        XUCRE = tokenContract_xucre;
        poolFee = poolFee_xucre;
    }

    receive() external payable {}

    fallback() external payable {}

    function withdrawBalance(
        address xucre_to
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (xucre_to != address(0)) {
            address payable ownerPayable = payable(xucre_to);
            ownerPayable.transfer(address(this).balance);
        }
    }

    function withdrawTokenBalance(
        address xucre_to,
        address xucre_tokenAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (xucre_to != address(0)) {
            uint256 balance = checkBalance(xucre_to, xucre_tokenAddress);
            TransferHelper.safeTransfer(xucre_tokenAddress, xucre_to, balance);
        }
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function safeMint(
        address to_xucre,
        address[] calldata targetTokens_xucre,
        uint256[] calldata inputAmounts_xucre,
        uint24[] calldata poolFees_xucre,
        uint256 amount_xucre,
        address paymentToken_xucre
    ) external {
        uint256 xucre_tokenId = xucre_nextTokenId++;
        etfMappings[to_xucre] = ETFDefinition(
            targetTokens_xucre,
            inputAmounts_xucre,
            poolFees_xucre,
            amount_xucre,
            paymentToken_xucre
        );
        emit Mint(
            to_xucre,
            targetTokens_xucre,
            inputAmounts_xucre,
            poolFees_xucre,
            amount_xucre,
            paymentToken_xucre
        );
        _safeMint(to_xucre, xucre_tokenId);
    }

    function safeUpdate(
        uint256 tokenId_xucre,
        uint256 amount_xucre,
        address paymentToken_xucre
    ) external {
        require(
            ownerOf(tokenId_xucre) == msg.sender,
            "ERC721: caller is not owner."
        );
        emit Update(
            ownerOf(tokenId_xucre),
            etfMappings[ownerOf(tokenId_xucre)].xucre_targetTokens,
            etfMappings[ownerOf(tokenId_xucre)].xucre_inputAmounts,
            etfMappings[ownerOf(tokenId_xucre)].xucre_poolFees,
            amount_xucre,
            paymentToken_xucre
        );
        etfMappings[ownerOf(tokenId_xucre)].xucre_amount = amount_xucre;
        etfMappings[ownerOf(tokenId_xucre)]
            .xucre_paymentToken = paymentToken_xucre;
    }

    function subscriptionExecution(
        uint256 tokenId_xucre
    ) external onlyRole(BATCH_CALL_ROLE) {
        performSwapBatch(
            ownerOf(tokenId_xucre),
            etfMappings[ownerOf(tokenId_xucre)].xucre_targetTokens,
            etfMappings[ownerOf(tokenId_xucre)].xucre_inputAmounts,
            etfMappings[ownerOf(tokenId_xucre)].xucre_poolFees,
            etfMappings[ownerOf(tokenId_xucre)].xucre_amount,
            etfMappings[ownerOf(tokenId_xucre)].xucre_paymentToken,
            false
        );
    }

    function spotExecution(
        address to_xucre,
        address[] memory targetTokens_xucre,
        uint256[] memory inputAmounts_xucre,
        uint24[] memory poolFees_xucre,
        address paymentToken_xucre,
        uint256 totalIn_xucre
    ) external {
        performSwapBatch(
            to_xucre,
            targetTokens_xucre,
            inputAmounts_xucre,
            poolFees_xucre,
            totalIn_xucre,
            paymentToken_xucre,
            true
        );
    }

    function supportsInterface(
        bytes4 interfaceId_xucre
    ) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId_xucre);
    }

    function calculateFromPercent(
        uint256 amount_xucre,
        uint256 bps_xucre
    ) public pure returns (uint256) {
        require((amount_xucre * bps_xucre) >= 10000, "Invalid amount entries");
        return (amount_xucre * bps_xucre) / 10000;
    }

    function _update(
        address to_xucre,
        uint256 tokenId_xucre,
        address auth_xucre
    ) internal override(ERC721, ERC721Pausable) returns (address) {
        return super._update(to_xucre, tokenId_xucre, auth_xucre);
    }

    function swap(
        address to_xucre,
        uint256 amountIn_xucre,
        uint24 fee_xucre,
        address pt_xucre,
        address tokenOut_xucre
    ) private returns (uint256 amountOut) {
        ISwapRouter.ExactInputParams memory params = ISwapRouter
            .ExactInputParams({
                path: abi.encodePacked(pt_xucre, fee_xucre, tokenOut_xucre),
                recipient: to_xucre,
                deadline: block.timestamp,
                amountIn: amountIn_xucre,
                amountOutMinimum: 1
            });

        // Executes the swap.
        return xucre_swapRouter.exactInput(params);
    }

    function performSwapBatch(
        address to_xucre,
        address[] memory tt_xucre,
        uint256[] memory ia_xucre,
        uint24[] memory pf_xucre,
        uint256 ti_xucre,
        address pt_xucre,
        bool cf_xucre
    ) private {
        require(
            tt_xucre.length == ia_xucre.length &&
                ia_xucre.length == pf_xucre.length,
            "Invalid input parameters"
        );

        // Sum of input amounts
        uint256 totalInputAmounts = 0;
        for (uint256 i = 0; i < ia_xucre.length; ++i) {
            totalInputAmounts += ia_xucre[i];
        }
        require(
            totalInputAmounts == 10000,
            "Input amounts must add up to 10000"
        );

        // Validate wallet balance for source token
        uint256 xucre_totalIn = checkBalance(to_xucre, pt_xucre);
        require(xucre_totalIn >= ti_xucre, "Insufficient balance");
        // Fee calculation
        uint256 feeTotal = (ti_xucre / 100);
        uint256 totalAfterFees = !cf_xucre ? ti_xucre : ti_xucre - feeTotal;

        // Transfer `totalIn` of USDT to this contract.
        TransferHelper.safeTransferFrom(
            pt_xucre,
            to_xucre,
            address(this),
            ti_xucre
        );
        // Approve the router to spend USDT.
        TransferHelper.safeApprove(
            pt_xucre,
            address(xucre_swapRouter),
            ti_xucre
        );

        if (cf_xucre) {
            ISwapRouter.ExactInputParams memory feeParams = ISwapRouter
                .ExactInputParams({
                    path: abi.encodePacked(pt_xucre, poolFee, XUCRE),
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: feeTotal,
                    amountOutMinimum: 1
                });

            // Executes the fee swap.
            xucre_swapRouter.exactInput(feeParams);
        }

        for (uint256 i = 0; i < tt_xucre.length; ++i) {
            uint256 amountOut = swap(
                to_xucre,
                calculateFromPercent(totalAfterFees, ia_xucre[i]),
                pf_xucre[i],
                pt_xucre,
                tt_xucre[i]
            );
            require(amountOut > 0, "Swap failed");
        }

        /*uint256[2] memory resultingTotals;
        resultingTotals = [_totalIn, totalIn];
        return resultingTotals;*/
    }

    function checkBalance(
        address to_xucre,
        address tokenAddress_xucre
    ) private view returns (uint256) {
        // Create an instance of the token contract
        IERC20 token = IERC20(tokenAddress_xucre);
        // Return the balance of msg.sender
        return token.balanceOf(to_xucre);
    }
}
