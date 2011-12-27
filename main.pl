% Main Program file
%
%
% city.pl has to be loaded as first!

%:-['city.pl'].
:-['city_small.pl'].
:-['print.pl'].
:-['shortestPath.pl'].
:-['customers.pl'].
:-['taxi.pl'].


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
createJobs(Time,[PickupTime-CID-[F,S|RestPath]|Rest]) :-
	
	(Time =:= PickupTime
		-> (	newTaxi(TaxID),
			edge(F,S,Dist),
			TimeDist is Time + Dist,
			pathBetweenPickAndDrop(CID,[First|Path2]),
			append([S|RestPath],Path2,PathToFollow),
			assert(job(TaxID,[CID],[],PathToFollow,Time,TimeDist,1)),
			write(PathToFollow),
			printJobDebug(TaxID),
			New is Time + 1,
			% if Rest is empty, all the customers will be picked up
			(isEmpty(Rest)
				-> (doAllJobs(Time),createJobs(New,Rest))
				; createJobs(Time,Rest))
			
		   )
		; (	
			New is Time + 1,
			doAllJobs(Time),
			createJobs(New,[PickupTime-CID-[F,S|RestPath]|Rest]))).


pathBetweenPickAndDrop(CID,Path) :-
	customer(CID,_,_,From,To),
	shortestPath(From,To,Path,_).

taxiProceedNextNode(TaxID,Time,_) :-
	forall(job(TaxID,Cust,CustInCab,[F,S|Rest],_,Time,1),
		(
			edge(F,S, Dist),
			NewTime is Time + Dist,
			retract(job(TaxID,_,_,_,_,_,_)),
			assert(job(TaxID,Cust,CustInCab,[S|Rest],Time,NewTime,Status))
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



