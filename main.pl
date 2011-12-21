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
doCheck(X) :-
	(isEmpty(X) -> write('empty');write('not empty')).

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
			parkingLot(PID),
			edge(F,S,Dist),
			%write('------------'),	%
			%writeln(F),		%
			TimeDist is Time + Dist,
			assert(job(TaxID,[CID],[],[S|RestPath],Time,TimeDist,1)),
			%write([S|RestPath]),
			%printJobDebug(TaxID),
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


taxiProceedNextNode(TaxID,Time) :-
	job(TaxID,Cust,CustInCab,[F,S|Rest],_,Time,Status),
	writeln(F),
	writeln(S),
	
	edge(F,S, Dist),
	write('Dist '),
	writeln(Dist),
	NewTime is Time + Dist,
	retract(job(TaxID,_,_,_,_,_,_)),
	assert(job(TaxID,Cust,CustInCab,[S|Rest],Time,NewTime,Status)).



doAllJobs(Time) :-
	forall(job(TaxID,Cust,_,_,Time,_,_),
		(printTaxiStarted(TaxID,Time,Cust))),
	forall(job(TaxID,_,_,[F|_],_,Time,1),
		(	printTaxiReachedNode(TaxID,Time,F),
			% check op pickup node
			% check op dropoff node
			taxiProceedNextNode(TaxID,Time)
		
		)
	       ).





