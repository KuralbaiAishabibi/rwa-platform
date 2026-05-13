// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import {IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import {SafeERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import {IPriceOracle} from "../interfaces/IPriceOracle.sol";

contract RwaLendingPool is Initializable, UUPSUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct Loan {
        uint256 collateralAmount;
        uint256 debtAmount;
        uint256 lastUpdateTimestamp;
    }

    IERC20Upgradeable public stableAsset;
    IPriceOracle public oracle;
    address public admin;
    address public activeCollateral;

    mapping(address => mapping(address => Loan)) public loans;
    mapping(address => bool) public supportedCollateral;

    event Deposited(address indexed user, address indexed collateralToken, uint256 amount);
    event Borrowed(address indexed user, uint256 amount);
    event Repaid(address indexed user, uint256 amount);
    event Liquidated(address indexed liquidator, address indexed borrower, address collateralToken, uint256 collateralSeized);

    function initialize(address _stableAsset, address _oracle, address _admin) public initializer {
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
        stableAsset = IERC20Upgradeable(_stableAsset);
        oracle = IPriceOracle(_oracle);
        admin = _admin;
    }

    function setCollateralToken(address token, bool enabled) external onlyAdmin {
        supportedCollateral[token] = enabled;
        if (enabled) activeCollateral = token;
    }

    function deposit(address collateralToken, uint256 amount) external whenNotPaused nonReentrant {
        require(supportedCollateral[collateralToken], "collateral not supported");
        IERC20Upgradeable(collateralToken).safeTransferFrom(msg.sender, address(this), amount);
        loans[msg.sender][collateralToken].collateralAmount += amount;
        emit Deposited(msg.sender, collateralToken, amount);
    }

    function borrow(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "borrow zero");
        require(healthFactor(msg.sender) > 1e18, "health factor too low");
        loans[msg.sender][address(0)].debtAmount += amount;
        loans[msg.sender][address(0)].lastUpdateTimestamp = block.timestamp;
        stableAsset.safeTransfer(msg.sender, amount);
        emit Borrowed(msg.sender, amount);
    }

    function repay(uint256 amount) external nonReentrant {
        Loan storage loan = loans[msg.sender][address(0)];
        require(loan.debtAmount > 0, "no debt");
        if (amount > loan.debtAmount) amount = loan.debtAmount;
        stableAsset.safeTransferFrom(msg.sender, address(this), amount);
        loan.debtAmount -= amount;
        emit Repaid(msg.sender, amount);
    }

    function liquidate(address borrower, address collateralToken) external nonReentrant {
        require(healthFactor(borrower) < 1e18, "health factor not below 1");
        Loan storage loan = loans[borrower][collateralToken];
        uint256 collateral = loan.collateralAmount;
        loan.collateralAmount = 0;
        IERC20Upgradeable(collateralToken).safeTransfer(msg.sender, collateral);
        emit Liquidated(msg.sender, borrower, collateralToken, collateral);
    }

    function healthFactor(address user) public view returns (uint256) {
        uint256 debt = loans[user][address(0)].debtAmount;
        if (debt == 0) return type(uint256).max;
        address col = activeCollateral;
        uint256 collateralAmount = loans[user][col].collateralAmount;
        uint256 price = oracle.getPrice(col);
        uint256 collateralValue = (collateralAmount * price) / 1e8;
        if (collateralValue == 0) return 0;
        return (collateralValue * 1e18) / debt;
    }

    function pause() external onlyAdmin {
        _pause();
    }

    function unpause() external onlyAdmin {
        _unpause();
    }

    function _authorizeUpgrade(address) internal override onlyAdmin {}

    modifier onlyAdmin() {
        require(msg.sender == admin, "not admin");
        _;
    }
}
