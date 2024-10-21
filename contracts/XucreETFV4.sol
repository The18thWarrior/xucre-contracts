// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.24;

/// @title An ETF contract leveraging Uniswap V3
/// @author Jordan Paul
/// @dev All function calls are currently implemented without side effects

pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract XucreETFV4 is Pausable, AccessControl {
    struct ETFDefinition {
        address[] xucre_targetTokens;
        uint256[] xucre_inputAmounts;
        uint24[] xucre_poolFees;
        uint256 xucre_amount;
        address xucre_paymentToken;
    }

    bytes32 public immutable PAUSER_ROLE;
    bytes32 public immutable BATCH_CALL_ROLE;

    ISwapRouter public immutable xucre_swapRouter;

    address public feeToken;
    uint24 public poolFee;

    uint256 private xucre_nextTokenId;
    mapping(address => ETFDefinition) private etfMappings;

    constructor(
        address owner_xucre,
        address swapRouter_xucre,
        address tokenContract_xucre,
        uint24 poolFee_xucre
    ) {
        PAUSER_ROLE = keccak256("PAUSER_ROLE");
        BATCH_CALL_ROLE = keccak256("BATCH_CALL_ROLE");
        _grantRole(DEFAULT_ADMIN_ROLE, owner_xucre);
        _grantRole(PAUSER_ROLE, owner_xucre);
        _grantRole(BATCH_CALL_ROLE, owner_xucre);
        xucre_swapRouter = ISwapRouter(swapRouter_xucre);
        feeToken = tokenContract_xucre;
        poolFee = poolFee_xucre;
    }

    receive() external payable {
        revert("Ether not accepted");
    }

    fallback() external payable {
        revert("Function does not exist");
    }

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

    function update(
        uint24 xucre_fee,
        address xucre_tokenAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        feeToken = xucre_tokenAddress;
        poolFee = xucre_fee;
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
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

    function calculateFromPercent(
        uint256 amount_xucre,
        uint256 bps_xucre
    ) public pure returns (uint256) {
        require((amount_xucre * bps_xucre) >= 10000, "Invalid amount entries");
        return (amount_xucre * bps_xucre) / 10000;
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
        uint256 feeTotal = (ti_xucre / 50);
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
                    path: abi.encodePacked(pt_xucre, poolFee, feeToken),
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
