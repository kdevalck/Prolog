% Main Program file
%
%
% city.pl has to be loaded as first!

%:-['city.pl'].
%:-['city_small.pl'].
:-['modified_city_small.pl'].
:-['print.pl'].
:-['shortestPath.pl'].
:-['customers.pl'].
:-['taxi.pl'].


%%%%%%%%%%%%%%%%%%%%%%%%%
%	TODO:		%
%%%%%%%%%%%%%%%%%%%%%%%%%

%checkForPickUpNode : extra check for the correct time.













main :-
	writeln('Start adding jobs'),
	getDeparturesTimeToReachCustomers(DeparturesList),
	keysort(DeparturesList,SortedDeparturesList),
	writeln(SortedDeparturesList),
	createJobs(0,SortedDeparturesList).
	
	
	
	
	
	%printAllJobs.
	% at the end of the program: cleanup al jobs.
	%deleteAllJobs.



isEmpty([]).

% ---------------------------------------------------------------------------------
% Calculates all the shortestpaths from a particular point to all teh customers
%  their pickup node.
distancesFromDropToCustomer(Point,Customer,Result) :-
	customer(Customer,_,_,Start,_),
	shortestPath(Point,Start,_,Length),
	Result = [Length-Customer].

distancesFromDropToCustomers(DropPoint,[_-Customer-_-_], Result) :-
	distancesFromDropToCustomer(DropPoint, Customer, Result).

% give all the shortestpaths from 1 droppoint to all remaining customers
distancesFromDropToCustomers(DropPoint,[_-Customer-_-_|Rest], ResultCustomers) :-
	distancesFromDropToCustomers(DropPoint, Rest, Results),
	distancesFromDropToCustomer(DropPoint, Customer, Result),
	append(Results, Result, ResultCustomers).


% ---------------------------------------------------------------------------------
% InnerCheckTimeConstrains does the actual check
%  If the time we reach that pickup point is within
%  ETOP and LTOP then we add CID to result.
innerCheckTimeConstraints(Time,[Length-CID],Result) :-
	customer(CID,ETOP,LTOP,_,_),
	((ETOP=<Time+Length,Time+Length=<LTOP)
		-> Result = [CID-Length]
		;  Result = []).

% Last call of checkTimeConstraints
checkTimeConstraints(Time,[Length-CID],ReturnCID) :-
	innerCheckTimeConstraints(Time,[Length-CID],ReturnCID).

% check what time it is till we reach the closest customer. And check
%  if this time is within the time the customers wants to be picked up.	
checkTimeConstraints(Time,[Length-CID|Customers],ReturnCIDs) :-
	checkTimeConstraints(Time,Customers,InnerCIDs),
	innerCheckTimeConstraints(Time,[Length-CID],InnerCID),
	append(InnerCID,InnerCIDs,ReturnCIDs).
% ---------------------------------------------------------------------------------


% check will be ommitted if no customers remaining
checkForExtraCustomers(_,_,_,[],ExtraCustomers,ExtraPath,ResultCustomers) :-
	writeln('-----------> customers empty'),
	ResultCustomers = [],
	ExtraCustomers = [],
	ExtraPath = [].

% Time = the time at which we dropped of the last customer
checkForExtraCustomers(_,Time,Start,Customers,ExtraCustomers,ExtraPath,ResultCustomers) :-
	% 
	distancesFromDropToCustomers(Start,Customers,Distances),
	writeln(Distances),
	keysort(Distances,SortedDistances),
	writeln(SortedDistances),
	checkTimeConstraints(Time,SortedDistances,CheckedDistances),
	writeln(CheckedDistances),
	writeln(3),
	writeln(Time),
	% If no customer is found fullfilling the constraints,
	%  we return the original customers
	(isEmpty(CheckedDistances)
		-> (	ResultCustomers = Customers,
			ExtraCustomers = [],
			ExtraPath = [])
		% when we found the closest customer we can pickup next
		;  (	giveFirstCustomer(CheckedDistances,CID-_),
			removeCustFromCustomersList(CID,Customers, ResultCustomers),
			ExtraCustomers = [CID],
			customer(CID,_,_,From,To),
			shortestPath(Start,From,[_|Path1],Len1),
			shortestPath(From,To,[_|Path2],Len2),
			append(Path1,Path2,ExtraPath))).

giveFirstCustomer([Cust|_],Cust).
giveFirstCustomer([Cust],Cust).
% ---------------------------------------------------------------------------------	
% Customers are in the format: PickupTime-CID-Path-Length
% This function will remove specified customer with CID from
%  the customerslist.
removeCustFromCustomersList(CID,Customers,NewCustomers) :-
	select(_-CID-_-_,Customers,NewCustomers).

% ---------------------------------------------------------------------------------
createJobForTaxi(Time,CID,[F,S|RestPath],LengthToCust,RestCustomers,ResultCustomers) :-
	writeln(1),
	newTaxi(TaxID),
	edge(F,S,Dist),
	TimeDist is Time + Dist,
	writeln(2),
	customer(CID,ETOP,_,From,To),
	% ask path  and length between pick up and drop from the first customer
	pathBetweenPickAndDrop(CID,[First|Path],Length),
	NewTime is LengthToCust + Time + Length,
	checkForExtraCustomers(1,NewTime,To,RestCustomers,ExtraCustomers,ExtraPath,ResultCustomers),
	writeln(4),
	append([S|RestPath],Path,PathToFirst),
	% Create the total path from first to last customer(if any)
	append(PathToFirst,ExtraPath,TotalPath),
	% append all the customers in one list
	append([CID],ExtraCustomers,TotalCustomers),
	% create the job for the taxi
	assert(job(TaxID,TotalCustomers,[],TotalPath,Time,TimeDist,1)).



createJobs(1440,Rest) :-
	writeln('Taxi company closed! Following customers were not picked up: '),
	write(Rest).

createJobs(Time,[]) :-
	%write('All jobs divided at '),
	%writeln(Time).
	New is Time + 1,
	doAllJobs(Time),
	createJobs(New,[]).

% loop over list and createjobs for the taxis to pickup customers
%  while looping over Time, do all the jobs.
createJobs(Time,[PickupTime-CID-[F,S|RestPath]-LengthToCust|Rest]) :-
	
	(Time =:= PickupTime
		-> (	writeln(0),
			createJobForTaxi(Time,CID,[F,S|RestPath],LengthToCust,Rest,NewCustomers),
			writeln(5),
			writeln(NewCustomers),
			%write(PathToFollow),
			%printJobDebug(TaxID),
			New is Time + 1,
			% if Rest is empty, all the customers will be picked up
			(isEmpty(NewCustomers)
				-> (doAllJobs(Time),createJobs(New,NewCustomers))
				; createJobs(Time,NewCustomers))
			
		   )
		; (	
			New is Time + 1,
			doAllJobs(Time),
			createJobs(New,[PickupTime-CID-[F,S|RestPath]-LengthToCust|Rest]))).

% The shortest path between the pickup and dropoff
% Return path and Length of shortestpath
pathBetweenPickAndDrop(CID,Path,Length) :-
	customer(CID,_,_,From,To),
	shortestPath(From,To,Path,Length).

taxiProceedNextNode(TaxID,Time,_) :-
	forall(job(TaxID,Cust,CustInCab,[F,S|Rest],_,Time,1),
		(
			edge(F,S, Dist),
			NewTime is Time + Dist,
			retract(job(TaxID,_,_,_,_,_,_)),
			assert(job(TaxID,Cust,CustInCab,[S|Rest],Time,NewTime,1))
		)).

taxiProceedNextNode(TaxId,Time,[]).

checkForPickUpNode(TaxID,Time) :-
	job(TaxID,Cust,CInCab,[F|R],STime,NTime,Status),
	forall((customer(ID,_,_,F,_),memberchk(ID, Cust)),
			%%%% make if test around member test
		(	
			append(CInCab,[ID],NewCInCab),
			delete(Cust,ID,NewCust),
			printCustomerPickUp(TaxID,ID,F),
			retract(job(TaxID,_,_,_,_,_,_)),
			assert(job(TaxID,NewCust,NewCInCab,[F|R],STime,NTime,Status)),
			printCustomersInTaxi(TaxID,NewCInCab,Time)
		)).
		
		
checkForParkingLot(TaxID,Time) :-
	forall( job(TaxID,Cust,CInCab,[L],_,_,1),
		( (isEmpty(Cust),isEmpty(CInCab))
		->
		(writeln('Both empty! So need to return to parking lot'),
		parkingLot(PID),
		shortestPath(L,PID,Path,Length),
		%write(Path),
		NewTime is Time + Length,
		retract(job(TaxID,_,_,_,_,_,_)),
		assert(job(TaxID,Cust,CInCab,Path,NewTime,NewTime,2))
		))).


checkForDropOffNode(TaxID,Time) :-
	job(TaxID,Cust,CInCab,[F|R],STime,NTime,Status),
	forall((customer(ID,_,_,_,F),memberchk(ID, CInCab)),
		(
			delete(CInCab,ID,NewCInCab),
			printCustomerDropOff(TaxID,ID,F),
			retract(job(TaxID,_,_,_,_,_,_)),
			assert(job(TaxID,Cust,NewCInCab,[F|R],STime,NTime,Status)),
			printCustomersInTaxi(TaxID,NewCInCab,Time)
		)),
	checkForParkingLot(TaxID,Time).


doAllJobs(Time) :-
	forall(job(TaxID,Cust,_,_,Time,_,1),
		(printTaxiStarted(TaxID,Time,Cust))),
	forall(job(TaxID,_,_,[F|Rest],_,Time,1),
		(	% print 
			printTaxiReachedNode(TaxID,Time,F),
			% check if node F is pickup node
			checkForPickUpNode(TaxID,Time),
			% check if node F is dropoff node
			checkForDropOffNode(TaxID,Time),
			% proceed the taxi to the next node
			taxiProceedNextNode(TaxID,Time,Rest)
			% change to forall
		)),
	forall(job(TaxID,_,_,_,_,Time,2),
		(	printTaxiBackToParking(TaxID,Time),
			freeTaxi(TaxID)
		)).

freeTaxi(TaxID) :-
	retract(job(TaxID,_,_,_,_,_,_)).



