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
createJobs(Time,[PickupTime-CID-[F,S|RestPath]|Rest]) :-
	
	(Time =:= PickupTime
		-> (	%write(Time),
			%write(' : '),
			newTaxi(TaxID),
			%parkingLot(PID),
			edge(F,S,Dist),
			%write('------------'),	%
			%writeln(F),		%
			TimeDist is Time + Dist,
			pathBetweenPickAndDrop(CID,[First|Path2]),
			append([S|RestPath],Path2,PathToFollow),
			assert(job(TaxID,[CID],[],PathToFollow,Time,TimeDist,1)),
			write(PathToFollow),
			printJobDebug(TaxID),
			%writeln(''),
			%doAllJobs(Time),
			New is Time + 1,
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
	job(TaxID,Cust,CustInCab,[F,S|Rest],_,Time,Status),
	%writeln(F),
	%writeln(S),
	
	edge(F,S, Dist),
	%write('Dist '),
	%writeln(Dist),
	NewTime is Time + Dist,
	retract(job(TaxID,_,_,_,_,_,_)),
	assert(job(TaxID,Cust,CustInCab,[S|Rest],Time,NewTime,Status)).

taxiProceedNextNode(TaxId,Time,[]) :-
	writeln('Do nothing anymore').

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
		
		
checkForDropOffNode(TaxID,Time) :-
	job(TaxID,Cust,CInCab,[F|R],STime,NTime,Status),
	forall((customer(ID,_,_,_,F),memberchk(ID, CInCab)),
		(
			delete(CInCab,ID,NewCInCab),
			printCustomerDropOff(TaxID,ID,F),
			retract(job(TaxID,_,_,_,_,_,_)),
			assert(job(TaxID,Cust,NewCInCab,[F|R],STime,NTime,Status)),
			printCustomersInTaxi(TaxID,NewCInCab,Time)
		)).

doAllJobs(Time) :-
	forall(job(TaxID,Cust,_,_,Time,_,_),
		(printTaxiStarted(TaxID,Time,Cust))),
	forall(job(TaxID,_,_,[F|Rest],_,Time,1),
		(	printTaxiReachedNode(TaxID,Time,F),
			% check op pickup node
			checkForPickUpNode(TaxID,Time),
			% check op dropoff node
			checkForDropOffNode(TaxID,Time),
			taxiProceedNextNode(TaxID,Time,Rest)
			% change to forall
		)
	       ).





