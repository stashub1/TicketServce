// SPDX-License-Identifier: GPL-3.0
    
pragma solidity >=0.8.0 <0.9.0;

// This import is automatically injected by Remix
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "../contracts/TicketsRoutes.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract TestTicketsRoutes {

    TicketsRoutes instance;
    
    uint routesAmunt = 5;

    address account1 = 0xD8Ce37FA3A1A61623705dac5dCb708Bb5eb9a125;

    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        instance = new TicketsRoutes();
        instance.addRoute("E10", 100);
        instance.addRoute("E20", 200);
        instance.addRoute("E30", 300);
        instance.addRoute("E40", 400);
        instance.addRoute("E50", 500);
    }
    
    function testCheckRoutesCount() public {
        Assert.equal(instance.getRoutesCount(), 5, "Routes amount is not equal");
    }
    
    function testCheckRoutesPosition() public  {
        Assert.equal(instance.getRouteListPointer("E50"), 4, "Wrong posiiton of route" );
    }
    
    
    function testCheckRoutesRemoval() public {
        instance.deleteRoute("E20");        
        //Check that routes amount is changed
        Assert.equal(uint(instance.getRoutesCount()), uint(4), "Routes amount is wrong");
        
        //check that particular route was removed
        Assert.equal(instance.isRouteExists("E20"), false, "Route was not removed");
        
        //Test that last element was moved in array to empty position
        Assert.equal(instance.getRouteListPointer("E50"), 1, "E50 route positin is wrong");

    }
    
    
    ///#sender: account-1
    ///#value: 20
    function testCheckBuyTicket1() public payable{
        //instance.buyTicket("E10").call({value:21 wei});

        //address(instance).buyTicket{value: 21 wei}(("E10"));    

        //instance.buyTicket{value: 20, gas: 200000}("E10");

        //instance.buyTicket("E10");
        instance.buyTicket{value: 22}("E10");

        
        Assert.equal(instance.getTicketsCountOfRoute("E10"), 1, "Tickets count in route is wrong");
        
        Assert.equal(instance.getTicketsCount(), 1, "Tickets count is wrong");
        
        Assert.equal(msg.sender, account1, "wrong account in checkBuyTicket1");

    }
    
    /// #sender: account-1
    /// #value: 100
    function testCheckBuyTicket2() public payable{
        instance.buyTicket("E10");
        
        Assert.equal(instance.getTicketsCountOfRoute("E10"), 2, "Tickets count is wrong");
    }
      

    
    

    /// Custom Transaction Context: https://remix-ide.readthedocs.io/en/latest/unittesting.html#customization
    /// #sender: account-1
    /// #value: 100
    // function checkSenderAndValue() public payable {
    //     // account index varies 0-9, value is in wei
    //     Assert.equal(msg.sender, TestsAccounts.getAccount(1), "Invalid sender");
    //     Assert.equal(msg.value, 100, "Invalid value");
    // }
}
