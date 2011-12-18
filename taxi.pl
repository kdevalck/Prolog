% 
% TaxiStand functions
% 
% 
% 


% Get PointID of taxi's parking lot.
% The parking lot is the node in the middle
%  of the city.

parkingLot(PID) :-
	node(PID,13,13).


% 
% Job for a specified taxi
% 
% A job wil have 5 parameters
% Taxi = the taxi id
% CustList = List of customers to be delivered
% Path = Path to follow to deliver customers
% CurrN = The current node where the taxi is situated at the moment
% StartTime = The time when the taxi should leave the parking lot
% 
:- dynamic job/5.

% 
% Ask a new empty taxi who is not busy doing a job.
% 
newTaxi(TaxID) :-
	taxi(TaxID),
	\+job(TaxID,_,_,_,_).


% 
% Print job for specified taxi.
% 
printJob(TaxID) :-
	job(TaxID,Cust,_,_,Time),
	write('Job created for Taxi '),
	write(TaxID),
	write(' at '),
	write(Time),
	write(' to deliver customer '),
	writeln(Cust).

% 
% Print all current jobs.
% 
printAllJobs :-
    	forall(job(TaxID,_,_,_,_),
           	printJob(TaxID)).

% 
% Clean up all jobs.
% 
deleteAllJobs :-
	retractall(job(_,_,_,_,_)).



% 

divideTaxis :-
	TaxID is 0,
	sortCustomers(Srtd),
	parkingLot(PaID),
	divideTaxis(Srtd,PaID,TaxID).
	%write(PaID),nl,
	%write(TaxID),nl,
	%write(Srtd).

% SortedCustomers = list of customers sorted by
%  pickuptime and in 'Pickuptime - CID' format.
%
% PLID = parkinglot node id
divideTaxis([FirstTime-FirstID|SortedCustomers],PLID,TaxID) :-
	write(FirstTime),
	write(FirstID),
	write(PLID),
	write(TaxID),
	write('   '),
	Temp is TaxID + 1,	
	\+TaxID = 10,!,
	shortestPath(PLID,FirstID,_,L),
	write(L),nl,

	divideTaxis(SortedCustomers,PLID,Temp).




divideTaxis([],_,_).
	
