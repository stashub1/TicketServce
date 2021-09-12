const Reverter = require('./helpers/reverter');
const { asserts, reverts, equal } = require('./helpers/asserts');

const TicketsRoutes = artifacts.require('./TicketsRoutes');


contract('TicketsRoutes', function(accounts) {

    // And this thing is used to make snapshots of test network state
    // and return to the latest `snapshot` with `revert` method, to keep
    // things clear afterEach test.
    // It's not related to the Solidity revert!
    const reverter = new Reverter(web3);

    const OWNER = accounts[0];
    const NON_OWNER = accounts[1];

    let ticketsRoutes;

    // afterEach('revert', reverter.revert);  // Reset test network state to the latest `snapshot`

    // before('setup', async () => {
    //     ticketsRoutes = await TicketsRoutes.deployed();
    //     await reverter.snapshot();  // Create first `snapshot` before all tests
    // });


    it("should add 5 routes", async () => {
    	const instance = await TicketsRoutes.deployed();
        await instance.addRoute('E10', 10);
        await instance.addRoute('E20', 20);
        await instance.addRoute('E30', 30);
        await instance.addRoute("E40", 40);
        await instance.addRoute("E50", 50);

        const routesNumber = await instance.getRoutesCount.call();
        console.log('Routes Number:', routesNumber);


   		assert.equal(routesNumber, 5, "Not 5 routes in end");
  	});


  	it("Check rout existance", async () => {
    	const instance = await TicketsRoutes.deployed();
        // await instance.addRoute.call('E10', 100);
        // await instance.addRoute.call('E20', 200);
        const isRouteExists = await instance.isRouteExists.call('E20');
        console.log('isRouteExists:', isRouteExists);
        // console.log('Something 1')

   		assert.equal(isRouteExists, true, "Noo such route");
  	});


  	it("Check rout deletion", async () => {
    	const instance = await TicketsRoutes.deployed();
        // await instance.addRoute.call('E10', 100);
        // await instance.addRoute.call('E20', 200);
        await instance.deleteRoute('E20');
        //console.log('isRouteExists:', isRouteExists);
        // console.log('Something 1')
        const isRouteExists = await instance.isRouteExists.call('E20');
   		assert.equal(isRouteExists, false, "Route is  still not deleted");
  	});

  	it("Check routs number after deletion", async () => {
    	const instance = await TicketsRoutes.deployed();
        // await instance.addRoute.call('E10', 100);
        // await instance.addRoute.call('E20', 200);
        const routesNumber = await instance.getRoutesCount.call();
        //console.log('isRouteExists:', isRouteExists);
        // console.log('Something 1')
        //const amuountOfRoutes = await instance.isRouteExists.call('E20');
   		assert.equal(routesNumber, 4, "After deletion still same amount of routes");
  	});

	it("Check routs position after deletion", async () => {
    	const instance = await TicketsRoutes.deployed();
        // await instance.addRoute.call('E10', 100);
        // await instance.addRoute.call('E20', 200);
        const routesNumber = await instance.getRouteListPointer.call('E50');
        //console.log('isRouteExists:', isRouteExists);
        // console.log('Something 1')
        //const amuountOfRoutes = await instance.isRouteExists.call('E20');
   		assert.equal(routesNumber, 1, "After deletion still same amount of routes");
  	});

  	it("Check tickets creation", async () => {
    	const instance = await TicketsRoutes.deployed();
    
        await instance.buyTicket('E50', {from : accounts[0], value : 51});
        await instance.buyTicket('E50', {from : accounts[1], value : 51});
        await instance.buyTicket('E50', {from : accounts[2], value : 51});
        const ticketsAmount = await instance.getTicketsCount();
   		assert.equal(ticketsAmount, 3, "Wrong tickets count");
  	});

  	it("Check number of tickets of Route", async () => {
    	const instance = await TicketsRoutes.deployed();
    	const route = await instance.getRoute.call('E50');
    	console.log("Route : ", route);
    	const ticketsAmount = await instance.getTicketsCountOfRoute.call('E50');

   		assert.equal(ticketsAmount, 3, "Wrong tickets count");
  	});

  	it("Check tickets removal in global ticket storage", async () => {
    	const instance = await TicketsRoutes.deployed();
        await instance.removeTicket(accounts[1]);     
        const ticketsAmount = await instance.getTicketsCount();
   		assert.equal(ticketsAmount, 2, "Wrong tickets count after removal");
  	});


	it("Check tickets removal in route ticket storage", async () => {
    	const instance = await TicketsRoutes.deployed();
        const ticketsAmountInRoute = await instance.getTicketsCountOfRoute("E50");
   		assert.equal(ticketsAmountInRoute, 2, "Wrong tickets count after removal");
  	});






    // describe("Negative", () => {

    //     it("should NOT allow to call main function by non-owner", async () => {
    //         const result = await example.main.call(1, {from: NON_OWNER});
    //         assert.isFalse(result);
    //     });

    //     it("should NOT change state when calling main function by non-owner", async () => {
    //         const initialState = await example.state();
    //         equal(initialState, 0);

    //         await example.main(2, {from: NON_OWNER});
    //         const currentState = await example.state();
    //         equal(currentState, 0);
    //     });

    //     it("should NOT emit event about state changes when calling main function by non-owner, should emit error event instead", async () => {
    //         const tx = await example.main(3, {from: NON_OWNER});
    //         equal(tx.logs.length, 1);
    //         equal(tx.logs[0].address, example.address);
    //         equal(tx.logs[0].event, "Error");
    //         equal(tx.logs[0].args.msg, "You are not the owner");
    //     });

    //     it("should revert transaction when calling other function by contract owner", async () => {
    //         const initialState = await example.state();
    //         equal(initialState, 0);

    //         reverts(example.other(5, {from: OWNER}));
    //         const currentState = await example.state();
    //         equal(currentState, 0);
    //     });

    // });


    // describe("Positive", () => {

    //     it("should allow contract owner to call main function", async () => {
    //         const result = await ticketsRoutes.main.call(1, {from: OWNER});
    //         assert.isTrue(result);
    //     });

    //     it("should change state when calling main function by contract owner", async () => {
    //         const initialState = await example.state();
    //         equal(initialState, 0);

    //         await example.main(2, {from: OWNER});
    //         const currentState = await example.state();
    //         equal(currentState, 2);
    //     });

    //     it("should emit event about state changes when calling main function by contract owner", async () => {
    //         const tx = await example.main(3, {from: OWNER});
    //         equal(tx.logs.length, 1);
    //         equal(tx.logs[0].address, example.address);
    //         equal(tx.logs[0].event, "StateChanged");
    //         equal(tx.logs[0].args.changedTo, 3);
    //     });

    //     it("should change state when calling other function by non-owner", async () => {
    //        const initialState = await example.state();
    //        equal(initialState, 0);

    //        await example.other(4, {from: NON_OWNER});
    //        const currentState = await example.state();
    //        equal(currentState, 4);
    //     });

    //     // TODO
    //     it("should emit event about state changes when calling other function by non-owner");

    // });

});
