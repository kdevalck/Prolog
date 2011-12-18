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
	
	
	
	
	
	printAllJobs,
	% at the end of the program: cleanup al jobs.
	deleteAllJobs.




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
			assert(job(TaxID,[CID],[F,S|RestPath],PID,Time,Dist,Dist)),
			printJob(TaxID),
			writeln(''),
			createJobs(Time,Rest)
		   )
		; (	
			New is Time + 1,
			createJobs(New,[PickupTime-CID-[F,S|RestPath]|Rest]))).

















