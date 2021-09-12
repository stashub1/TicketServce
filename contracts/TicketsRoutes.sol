pragma solidity >= 0.8.0 < 0.9.0;

contract TicketsRoutes {
    
    
    struct  Ticket {
        uint ticketNumber;
        address adr;
        
        string routeName;
        uint listPointer;
        uint routeListPointer;
        bool isReal;
    }
    
    uint nextTicketId;
    
    address [] ticketIds;
    mapping(address => Ticket) public tickets;
    
    struct Route {
        string name;
        uint price;
        uint listPointer;
        
        address [] ticketIds;
        mapping(address => Ticket) ticketsOfRoute;
        bool isReal;
        
        uint nextTicketInRoute;
        
    }
    
    string [] routeIds;
    mapping(string => Route)  public routes;
    
    uint nextRouteId;

    event RouteAdding(address from, string name, uint price);
    event CountRoutes(address from, uint result);
    
    constructor() public {
        //populateRoutes();
    }
    
    function populateRoutes() public  {
        addRoute("E10", 100);
        addRoute("E20", 200);
        addRoute("E30", 300);
        addRoute("E40", 400);
        addRoute("E50", 500);
        addRoute("E60", 600);
    }
    
    function getRoutesCount() public returns(uint) {
        emit CountRoutes(msg.sender, routeIds.length);
        return routeIds.length;
    }
    
    function isRouteExists(string memory routeName) public returns(bool) {
        if(routeIds.length == 0) return false;
        return keccak256(abi.encodePacked(routeName)) == 
                        keccak256(abi.encodePacked(routeIds[routes[routeName].listPointer]));
    }
    
    function isTicketExists(address adr) public view returns(bool) {
        if(ticketIds.length == 0) return false;
        return adr == ticketIds[tickets[adr].listPointer];
    }
    
    function isTicketExistsInRoute(address tikectAdr, string memory routeName) public view returns(bool) {
        if(routes[routeName].ticketIds.length == 0) return false;
        return tikectAdr == routes[routeName].ticketIds[routes[routeName].ticketsOfRoute[tikectAdr].routeListPointer];
    }
    
    function getRouteListPointer(string memory routeName) public returns(uint) {
        if(routes[routeName].isReal == false) revert();
        return routes[routeName].listPointer;
    }
    
    //Function to add ticket to main ticket storage
    function addTicketToglobalStorage(string memory routeName) public payable {
        require(msg.value > routes[routeName].price, "The price for this route is higher ");
        require(!isTicketExists(msg.sender), "Ticket already exist for such address");
        ticketIds.push(msg.sender);
        tickets[msg.sender].routeName = routeName;
        tickets[msg.sender].isReal = true;
        tickets[msg.sender].adr = msg.sender;
        tickets[msg.sender].ticketNumber = nextTicketId;
        tickets[msg.sender].listPointer = nextTicketId;
        nextTicketId++;
    }

    function removeTicketFromGlobalStorage(address adr) 
                                            public returns(bool){

        require(isTicketExists(adr));                                            
        //routes[routeName].ticketsOfRoute[adr].listPointer = 0; 
        uint indexToDelete =  tickets[adr].listPointer;
        address ticketToMove = ticketIds[ticketIds.length - 1];
        ticketIds[indexToDelete] = ticketToMove;
        tickets[ticketToMove].listPointer = indexToDelete;
        ticketIds.pop();
        tickets[adr].isReal = false;
        return true;
    }

    function removeTicket(address adr) public returns(bool) {
        Ticket storage ticketToRemove = tickets[adr];
        require(isTicketExistsInRoute(adr, tickets[adr].routeName), "Ticket is not in the route");
        address[] storage ticketIdss  = routes[ticketToRemove.routeName].ticketIds;
        uint ticketIndexToRemove = ticketToRemove.routeListPointer;
        address tickeToRemove = ticketToRemove.adr;
        address ticketToMove = ticketIdss[ticketIdss.length-1];
        ticketIdss[ticketIndexToRemove] = ticketToMove;
        tickets[ticketToMove].routeListPointer = tickets[adr].routeListPointer;
        ticketIdss.pop();
        removeTicketFromGlobalStorage(adr);

        return true;
    }


    
    function buyTicket(string memory routeName) external payable {

        addTicketToglobalStorage(routeName);
        
        //Adding ticket to the route storage 
        routes[routeName].ticketsOfRoute[msg.sender] = tickets[msg.sender];
        routes[routeName].ticketsOfRoute[msg.sender].routeListPointer 
                                = routes[routeName].nextTicketInRoute;
        routes[routeName].ticketIds.push(msg.sender);
        routes[routeName].nextTicketInRoute++;
    }
    
    function getTicketsCountOfRoute(string memory routeName) public view returns(uint) {
        return routes[routeName].ticketIds.length;
    }
    
    function getTicketsCount() public view returns(uint) {
        return ticketIds.length;
    }
    
    function addRoute(string memory name, uint price) public returns (bool success) {
        if(isRouteExists(name)) return false;
        routes[name].name = name;
        routes[name].price = price;
        routes[name].isReal = true;
        routes[name].listPointer = nextRouteId;
        routeIds.push(name);
        nextRouteId++;
        emit RouteAdding(msg.sender, name, price);
        return true;
    }
    
    function deleteRoute(string memory name) public returns(bool)  {
        if(!isRouteExists(name)) return false;    
        uint indexToDelete = routes[name].listPointer;
        string memory routeToMove = routeIds[routeIds.length - 1];
        routeIds[indexToDelete] = routeToMove;
        routes[routeToMove].listPointer = indexToDelete;
        routes[name].isReal = false;
        routeIds.pop();
    }
    
    function getRoute(string memory name) public payable returns 
                (string memory tname, uint price, 
                    uint listPointer, bool isReal, uint ticketsCount) {
        if(!isRouteExists(name)) revert();
        return 
               (routes[name].name,
                routes[name].price,
                routes[name].listPointer,
                routes[name].isReal,
                routes[name].ticketIds.length
                 );
    }
    
}