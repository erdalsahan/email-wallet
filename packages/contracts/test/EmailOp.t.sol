// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./EmailWalletCoreTestHelper.sol";

contract TransferTest is EmailWalletCoreTestHelper {
    bytes extensionParams = abi.encodePacked("");
    ExtensionManagerParams extManagerParams = ExtensionManagerParams({command: "", extensionName: ""});

    function setUp() public override {
        super.setUp();
        _registerRelayer();
        _registerAndInitializeAccount();
    }

    function _getBaseEmailOp() internal view returns (EmailOp memory) {
        return
            EmailOp({
                emailAddrPointer: emailAddrPointer,
                hasEmailRecipient: false,
                recipientEmailAddrCommit: bytes32(0),
                recipientETHAddr: address(0),
                command: "",
                emailNullifier: bytes32(uint(123)),
                emailDomain: emailDomain,
                timestamp: block.timestamp,
                maskedSubject: "",
                feeTokenName: "ETH",
                feePerGas: 0,
                extensionSubjectTemplateIndex: 0,
                executeCallData: abi.encodePacked(""),
                walletParams: WalletParams({tokenName: "", amount: 0}),
                extManagerParams: extManagerParams,
                extensionParams: extensionParams,
                emailProof: mockProof
            });
    }

    function testSendTokenToEOA() public {
        address recipient = vm.addr(5);
        string memory subject = string.concat("Send 100 DAI to ", Strings.toHexString(uint160(recipient), 20));

        // Mint 150 DAI to sender wallet (will send 100 DAI to recipient)
        daiToken.freeMint(walletAddr, 150 ether);

        // Create EmailOp
        EmailOp memory emailOp = _getBaseEmailOp();
        emailOp.command = Commands.SEND;
        emailOp.walletParams.tokenName = "DAI";
        emailOp.walletParams.amount = 100 ether;
        emailOp.recipientETHAddr = recipient;
        emailOp.maskedSubject = subject;

        vm.startPrank(relayer);
        (bool success, ) = core.handleEmailOp(emailOp);
        vm.stopPrank();

        assertEq(success, true, "handleEmailOp failed");
        assertEq(daiToken.balanceOf(recipient), 100 ether, "recipient did not receive 100 DAI");
        assertEq(daiToken.balanceOf(walletAddr), 50 ether, "sender did not have 50 DAI left");
    }

    function testSendTokenToEOAWithDecimals() public {
        address recipient = vm.addr(5);
        string memory subject = string.concat("Send 10.52 DAI to ", Strings.toHexString(uint160(recipient), 20));

        daiToken.freeMint(walletAddr, 20 ether);

        EmailOp memory emailOp = _getBaseEmailOp();
        emailOp.command = Commands.SEND;
        emailOp.walletParams.tokenName = "DAI";
        emailOp.walletParams.amount = 10.52 ether;
        emailOp.recipientETHAddr = recipient;
        emailOp.maskedSubject = subject;

        vm.startPrank(relayer);
        (bool success, ) = core.handleEmailOp(emailOp);
        vm.stopPrank();

        assertEq(success, true, "handleEmailOp failed");
        assertEq(daiToken.balanceOf(recipient), 10.52 ether, "recipient did not receive 10.52 DAI");
        assertEq(daiToken.balanceOf(walletAddr), 9.48 ether, "sender did not have 9.48 DAI left");
    }

    function testExecute() public {
        // We will send 5 USDC to recipient by passing calldata
        // This could be done using the "Send" command, but we want to test the "Execute" command
        usdcToken.freeMint(walletAddr, 20 ether);
        address recipient = vm.addr(5);

        bytes memory erc20Calldata = abi.encodeWithSignature("transfer(address,uint256)", recipient, 5 ether);
        bytes memory emailOpCalldata = abi.encode(address(usdcToken), 0, erc20Calldata);

        string memory subject = string.concat("Execute 0x", core.bytesToHexString(emailOpCalldata));

        EmailOp memory emailOp = _getBaseEmailOp();
        emailOp.command = Commands.EXECUTE;
        emailOp.executeCallData = emailOpCalldata;
        emailOp.maskedSubject = subject;

        vm.startPrank(relayer);
        (bool success, ) = core.handleEmailOp(emailOp);
        vm.stopPrank();

        assertEq(success, true, "handleEmailOp failed");
        assertEq(usdcToken.balanceOf(recipient), 5 ether, "recipient did not receive 5 USDC");
        assertEq(usdcToken.balanceOf(walletAddr), 15 ether, "sender did not have 15 USDC left");
    }
}
