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
	write(SortedDeparturesList),
	createJobs(0,SortedDeparturesList),
	
	
	
	
	
	printAllJobs.
	% at the end of the program: cleanup al jobs.
	%deleteAllJobs.




createJobs(Time,[]) :-
	write('All jobs divided at '),
	writeln(Time).

createJobs(1440,Rest) :-
	writeln('Taxi company closed! Following customers were not picked up: '),
	write(Rest).


% loop over list and createjobs for the taxis to pickup customers
createJobs(Time,[PickupTime-CID-[F,S|RestPath]|Rest]) :-
	
	(Time =:= PickupTime
		-> (	write(Time),
			write(' : '),
			newTaxi(TaxID),
			parkingLot(PID),
			edge(F,S,Dist),
			assert(job(TaxID,[CID],[S|RestPath],PID,Time,Dist,Dist,1)),
			%write([S|RestPath]),
			printJob(TaxID),
			writeln(''),
			createJobs(Time,Rest)
		   )
		; (	
			New is Time + 1,
			createJobs(New,[PickupTime-CID-[F,S|RestPath]|Rest]))).


% Simulate the moving of the taxi by doing the jobs
doAllJobs :-
	forall(job(TaxID,Customers,Path,CurrN,StartTime,Dist,TDist,Status),
		    doJob(TaxID,Customers,Path,CurrN,StartTime,Dist,TDist,Status)).   	
doJob(TaxID,Customers,Path,CurrN,StartTime,Dist,TDist,1) :-
	writeln('Driving to customer'),
	
	printJobDebug(TaxID),
	NewDist is Dist - 1,
	write(NewDist).
	

doJob(TaxID,Customers,Path,CurrN,StartTime,Dist,TDist,3) :-
	writeln('Driving back to lot').











