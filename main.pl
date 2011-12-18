% Main Program file
%
%
% city.pl has to be loaded as first!

:-['city.pl'].
:-['print.pl'].
:-['shortestPath.pl'].
:-['customers.pl'].
:-['taxi.pl'].


main :-
	writeln('Start adding jobs'),
	getDeparturesTimeToReachCustomers(DeparturesList),
	keysort(DeparturesList,SortedDeparturesList),
	write(SortedDeparturesList),
	printAllJobs.
	
	
	
	
	
	
	
	
	
	
	
	% at the end of the program: cleanup al jobs.
	% deleteAllJobs.
