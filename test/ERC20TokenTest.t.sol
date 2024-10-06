// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ERC20Token.sol";

contract ERC20TokenTest is Test {
    ERC20Token public token;
    address public addr1;
    address public addr2;

    function setUp() public {
        token = new ERC20Token(1000 * 10 ** 18); // Initial supply of 1000 tokens
        addr1 = address(0x123); // Mock address 1
        addr2 = address(0x456); // Mock address 2

        // Label the addresses for clarity in output
        vm.label(addr1, "addr1");
        vm.label(addr2, "addr2");
    }

    // 1. Test total supply
    function testTotalSupply() public {
        assertEq(token.totalSupply(), 1000 * 10 ** 18);
    }

    // 2. Test initial balance of the contract owner
    function testBalanceOfOwner() public {
        assertEq(token.balanceOf(address(this)), 1000 * 10 ** 18);
    }

    // 3. Test transfer between addresses
    function testTransfer() public {
        token.transfer(addr1, 100 * 10 ** 18);
        assertEq(token.balanceOf(addr1), 100 * 10 ** 18);
        assertEq(token.balanceOf(address(this)), 900 * 10 ** 18);
    }

    // 4. Test approve allowance for another address
    function testApprove() public {
        token.approve(addr1, 200 * 10 ** 18);
        assertEq(token.allowance(address(this), addr1), 200 * 10 ** 18);
    }

    // 5. Test transferFrom when allowed (spender can transfer tokens on behalf of owner)
    function testTransferFrom() public {
        // Approve addr1 to spend 200 tokens
        token.approve(addr1, 200 * 10 ** 18);

        // Addr1 tries to transfer tokens from this contract to addr2
        vm.prank(addr1); // Execute the following code as addr1
        token.transferFrom(address(this), addr2, 150 * 10 ** 18);

        assertEq(token.balanceOf(addr2), 150 * 10 ** 18);
        assertEq(token.balanceOf(address(this)), 850 * 10 ** 18);
        assertEq(token.allowance(address(this), addr1), 50 * 10 ** 18); // Remaining allowance
    }

    // 6. Test the allowance mechanism
    function testAllowance() public {
        token.approve(addr1, 300 * 10 ** 18);
        assertEq(token.allowance(address(this), addr1), 300 * 10 ** 18);
    }

    // 7. Test transfer fails if sender has insufficient balance
    function testTransferFailInsufficientBalance() public {
        vm.expectRevert(); // Expect the transfer to revert due to insufficient balance
        token.transfer(addr1, 2000 * 10 ** 18); // Trying to transfer more than available
    }

    // 8. Test transferFrom fails if not enough allowance
    function testTransferFromFailInsufficientAllowance() public {
        // Approve addr1 to spend 100 tokens
        token.approve(addr1, 100 * 10 ** 18);

        vm.prank(addr1); // Execute the following code as addr1
        vm.expectRevert(); // Expect this to revert due to insufficient allowance
        token.transferFrom(address(this), addr2, 150 * 10 ** 18); // Transfer more than allowed
    }

    // 9. Test approve and call transferFrom in sequence
    function testApproveAndTransferFrom() public {
        token.approve(addr1, 300 * 10 ** 18);

        // Addr1 transfers 100 tokens from this contract to addr2
        vm.prank(addr1); 
        token.transferFrom(address(this), addr2, 100 * 10 ** 18);

        assertEq(token.balanceOf(addr2), 100 * 10 ** 18);
        assertEq(token.allowance(address(this), addr1), 200 * 10 ** 18); // 300 - 100 remaining allowance
    }

    // 10. Test burning tokens (if you plan to add burn functionality)
    // You may need to add this functionality in your ERC20 contract if needed
    /*
    function testBurnTokens() public {
        token.burn(100 * 10 ** 18);
        assertEq(token.balanceOf(address(this)), 900 * 10 ** 18);
        assertEq(token.totalSupply(), 900 * 10 ** 18);
    }
    */
}
