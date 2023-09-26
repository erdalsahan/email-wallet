// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts-upgradeable/utils/Create2Upgradeable.sol";
import "@zk-email/contracts/DKIMRegistry.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../src/EmailWalletCore.sol";
import "../src/utils/TokenRegistry.sol";
import "../src/utils/UniswapTWAPOracle.sol";
import "./mock/TestVerifier.sol";
import "./EmailWalletCoreTestHelper.sol";

contract AccountTest is EmailWalletCoreTestHelper {
    function setUp() public override {
        super.setUp();
        _registerRelayer();
    }

    function testCreateAccount() public {
        vm.startPrank(relayer);
        core.createAccount(emailAddrPointer, viewingKeyCommitment, walletSalt, psiPoint, mockProof);
        vm.stopPrank();

        assertEq(core.vkCommitmentOfPointer(emailAddrPointer), viewingKeyCommitment);
        assertEq(core.walletSaltOfVKCommitment(viewingKeyCommitment), walletSalt);
        assertEq(core.relayerOfVKCommitment(viewingKeyCommitment), relayer);
        assertEq(core.pointerOfPSIPoint(psiPoint), emailAddrPointer);
        assertTrue(!core.initializedVKCommitments(viewingKeyCommitment));
        assertTrue(!core.nullifiedVKCommitments(viewingKeyCommitment));
    }

    function testRevertCreateAccountWhenRelayerIsNotRegistered() public {
        vm.expectRevert("relayer not registered");
        core.createAccount(emailAddrPointer, viewingKeyCommitment, walletSalt, psiPoint, mockProof);
    }

    function testRevertIfPointerIsAlreadyRegistered() public {
        bytes32 viewingKeyCommitment2 = bytes32(uint256(2));
        bytes32 walletSalt2 = bytes32(uint256(3));
        bytes memory psiPoint2 = abi.encodePacked(uint(4));

        vm.startPrank(relayer);
        core.createAccount(emailAddrPointer, viewingKeyCommitment, walletSalt, psiPoint, mockProof);
        vm.expectRevert("pointer exists");
        core.createAccount(emailAddrPointer, viewingKeyCommitment2, walletSalt2, psiPoint2, mockProof);
        vm.stopPrank();
    }

    function testRevertIfPSIPointIsAlreadyRegistered() public {
        bytes32 emailAddrPointer2 = bytes32(uint256(2));
        bytes32 viewingKeyCommitment2 = bytes32(uint256(2));
        bytes32 walletSalt2 = bytes32(uint256(3));

        vm.startPrank(relayer);
        core.createAccount(emailAddrPointer, viewingKeyCommitment, walletSalt, psiPoint, mockProof);
        vm.expectRevert("PSI point exists");
        core.createAccount(emailAddrPointer2, viewingKeyCommitment2, walletSalt2, psiPoint, mockProof);
        vm.stopPrank();
    }

    function testRevertIfVkCommitmentAlreadyHasAnotherWalletSalt() public {
        bytes32 emailAddrPointer2 = bytes32(uint256(2));
        bytes32 walletSalt2 = bytes32(uint256(2));
        bytes memory psiPoint2 = abi.encodePacked(uint(4));

        vm.startPrank(relayer);
        core.createAccount(emailAddrPointer, viewingKeyCommitment, walletSalt, psiPoint, mockProof);
        vm.expectRevert("walletSalt exists");
        core.createAccount(emailAddrPointer2, viewingKeyCommitment, walletSalt2, psiPoint2, mockProof);
        vm.stopPrank();
    }

    function testCreateWalletWithPredeterministicAddress() public {
        address predictedAddr = core.getWalletOfSalt(walletSalt);

        vm.startPrank(relayer);
        address walletAddr = address(
            core.createAccount(emailAddrPointer, viewingKeyCommitment, walletSalt, psiPoint, mockProof)
        );
        vm.stopPrank();

        assertEq(walletAddr, predictedAddr);
    }

    function testRevertWhenPredeterministicWalletIsAlreadyDeployed() public {
        address predictedAddr = core.getWalletOfSalt(walletSalt);
        deployCodeTo("TestWallet.sol", abi.encode(), predictedAddr);

        vm.startPrank(relayer);
        vm.expectRevert("wallet already deployed");
        core.createAccount(emailAddrPointer, viewingKeyCommitment, walletSalt, psiPoint, mockProof);
        vm.stopPrank();
    }

    function testAccountInitailization() public {
        bytes32 emailNullifier = bytes32(uint256(101));

        vm.startPrank(relayer);
        core.createAccount(emailAddrPointer, viewingKeyCommitment, walletSalt, psiPoint, mockProof);
        core.initializeAccount(emailAddrPointer, emailDomain, emailNullifier, mockProof);
        vm.stopPrank();

        assertTrue(core.initializedVKCommitments(viewingKeyCommitment));
    }

    function testRevertAccountInitializationIfAccountNotRegistered() public {
        bytes32 emailNullifier = bytes32(uint256(101));

        vm.startPrank(relayer);
        vm.expectRevert("account not registered");
        core.initializeAccount(emailAddrPointer, emailDomain, emailNullifier, mockProof);
        vm.stopPrank();
    }

    function testAccountTransport() public {
        bytes32 emailNullifier = bytes32(uint256(101));
        bytes32 emailNullifier2 = bytes32(uint256(102));
        bytes32 newEmailAddrPointer = bytes32(uint256(2001));
        bytes32 newVKCommitment = bytes32(uint256(2002));
        bytes memory newPSIPoint = abi.encodePacked(uint(2003));
        address relayer2 = vm.addr(3);
        bytes32 relayer2RandHash = bytes32(uint256(311));

        vm.startPrank(relayer);
        core.createAccount(emailAddrPointer, viewingKeyCommitment, walletSalt, psiPoint, mockProof);
        core.initializeAccount(emailAddrPointer, emailDomain, emailNullifier, mockProof);
        vm.stopPrank();

        vm.startPrank(relayer2);
        core.registerRelayer(relayer2RandHash, "mail@relayer2", "relayer2.com");
        core.transportAccount(
            viewingKeyCommitment,
            newEmailAddrPointer,
            newVKCommitment,
            newPSIPoint,
            emailNullifier2,
            emailDomain,
            mockProof,
            mockProof
        );
        vm.stopPrank();

        assertEq(core.walletSaltOfVKCommitment(viewingKeyCommitment), bytes32(0));
        assertTrue(core.nullifiedVKCommitments(viewingKeyCommitment)); // old vkCommitment is nullified
        assertEq(core.vkCommitmentOfPointer(newEmailAddrPointer), newVKCommitment);
        assertEq(core.relayerOfVKCommitment(newVKCommitment), relayer2);
        assertEq(core.walletSaltOfVKCommitment(newVKCommitment), walletSalt); // should not change
        assertTrue(!core.nullifiedVKCommitments(newVKCommitment));
        assertTrue(core.initializedVKCommitments(newVKCommitment));
        assertEq(core.pointerOfPSIPoint(newPSIPoint), newEmailAddrPointer);
    }

    function testRevertIfTransportedAccountIsNullified() public {
        bytes32 emailNullifier = bytes32(uint256(101));
        bytes32 emailNullifier2 = bytes32(uint256(102));
        bytes32 newEmailAddrPointer = bytes32(uint256(2001));
        bytes32 newVKCommitment = bytes32(uint256(2002));
        bytes memory newPSIPoint = abi.encodePacked(uint(2003));
        address relayer2 = vm.addr(3);
        bytes32 relayer2RandHash = bytes32(uint256(311));
        address relayer3 = vm.addr(4);
        bytes32 relayer3RandHash = bytes32(uint256(411));

        vm.startPrank(relayer);
        core.createAccount(emailAddrPointer, viewingKeyCommitment, walletSalt, psiPoint, mockProof);
        core.initializeAccount(emailAddrPointer, emailDomain, emailNullifier, mockProof);
        vm.stopPrank();

        // Transporting will nullify the viewingKeyCommitment
        vm.startPrank(relayer2);
        core.registerRelayer(relayer2RandHash, "mail@relayer2", "relayer2.com");
        core.transportAccount(
            viewingKeyCommitment,
            newEmailAddrPointer,
            newVKCommitment,
            newPSIPoint,
            emailNullifier2,
            emailDomain,
            mockProof,
            mockProof
        );
        vm.stopPrank();

        vm.startPrank(relayer3);
        core.registerRelayer(relayer3RandHash, "mail@relayer3", "relayer3.com");
        vm.expectRevert("account is nullified");
        core.transportAccount(
            viewingKeyCommitment, // old vkCommitment
            bytes32(uint256(20011)), // newEmailAddrPointer
            bytes32(uint256(20021)), // newVKCommitment
            abi.encodePacked(uint(20031)), // newPSIPoint
            bytes32(uint256(1021)), // emailNullifier
            emailDomain,
            mockProof,
            mockProof
        );
        vm.stopPrank();
    }

    function testRevertIfTransportedAccountIsNotInitialized() public {
        bytes32 emailNullifier = bytes32(uint256(101));
        bytes32 newEmailAddrPointer = bytes32(uint256(2001));
        bytes32 newVKCommitment = bytes32(uint256(2002));
        bytes memory newPSIPoint = abi.encodePacked(uint(2003));
        address relayer2 = vm.addr(3);
        bytes32 relayer2RandHash = bytes32(uint256(311));

        vm.startPrank(relayer);
        core.createAccount(emailAddrPointer, viewingKeyCommitment, walletSalt, psiPoint, mockProof);
        vm.stopPrank();

        vm.startPrank(relayer2);
        core.registerRelayer(relayer2RandHash, "mail@relayer2", "relayer2.com");
        vm.expectRevert("account not initialized");
        core.transportAccount(
            viewingKeyCommitment,
            newEmailAddrPointer,
            newVKCommitment,
            newPSIPoint,
            emailNullifier,
            emailDomain,
            mockProof,
            mockProof
        );
        vm.stopPrank();
    }

    function testRevertIfTransportedAccountAlreadyExists() public {
        bytes32 emailNullifier = bytes32(uint256(101));
        bytes32 emailNullifier2 = bytes32(uint256(102));
        bytes32 newEmailAddrPointer = bytes32(uint256(2001));
        bytes32 newVKCommitment = bytes32(uint256(2002));
        bytes32 walletSalt2 = bytes32(uint256(2002));
        bytes memory newPSIPoint = abi.encodePacked(uint(2003));
        address relayer2 = vm.addr(3);
        bytes32 relayer2RandHash = bytes32(uint256(311));

        vm.startPrank(relayer);
        core.createAccount(emailAddrPointer, viewingKeyCommitment, walletSalt, psiPoint, mockProof);
        core.initializeAccount(emailAddrPointer, emailDomain, emailNullifier, mockProof);
        vm.stopPrank();

        vm.startPrank(relayer2);
        core.registerRelayer(relayer2RandHash, "mail@relayer2", "relayer2.com");
        core.createAccount(newEmailAddrPointer, newVKCommitment, walletSalt2, newPSIPoint, mockProof);
        vm.expectRevert("new pointer already exist");
        core.transportAccount(
            viewingKeyCommitment,
            newEmailAddrPointer,
            newVKCommitment,
            newPSIPoint,
            emailNullifier2,
            emailDomain,
            mockProof,
            mockProof
        );
        vm.stopPrank();
    }

    function testRevertAccountInitializationIfTransported() public {
        bytes32 emailNullifier = bytes32(uint256(101));
        bytes32 emailNullifier2 = bytes32(uint256(102));
        bytes32 newEmailAddrPointer = bytes32(uint256(2001));
        bytes32 newVKCommitment = bytes32(uint256(2002));
        bytes memory newPSIPoint = abi.encodePacked(uint(2003));
        address relayer2 = vm.addr(3);
        bytes32 relayer2RandHash = bytes32(uint256(311));

        vm.startPrank(relayer);
        core.createAccount(emailAddrPointer, viewingKeyCommitment, walletSalt, psiPoint, mockProof);
        core.initializeAccount(emailAddrPointer, emailDomain, emailNullifier, mockProof);
        vm.stopPrank();

        vm.startPrank(relayer2);
        core.registerRelayer(relayer2RandHash, "mail@relayer2", "relayer2.com");
        core.transportAccount(
            viewingKeyCommitment,
            newEmailAddrPointer,
            newVKCommitment,
            newPSIPoint,
            emailNullifier2,
            emailDomain,
            mockProof,
            mockProof
        );
        vm.stopPrank();

        // Transport will nullify account with relayer - Re initialization should fail
        vm.startPrank(relayer);
        vm.expectRevert("account is nullified");
        core.initializeAccount(emailAddrPointer, emailDomain, emailNullifier, mockProof);
        vm.stopPrank();
    }
}