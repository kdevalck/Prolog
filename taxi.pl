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
% Cust = List of customers to be pickedup
% CustInCab = List of customers in cab
% Path = Path to follow to deliver customers
% StartTime = The time when the taxi should leave the parking lot
% TimeAtNext = at this time the cab will reach the next node in the path
% Status = the status in which the job is. 
% 	1 => doing his job
%	2 => returning to parking lot
% 
:- dynamic job/7.

% 
% Ask a new empty taxi who is not busy doing a job.
% 
newTaxi(TaxID) :-
	taxi(TaxID),
	\+job(TaxID,_,_,_,_,_,_).

% 
% Print job for debugging
% 
printJobDebug(TaxID) :-
	job(TaxID,Cust,InCab,P,STime,NTime,S),
	write('TaxID	'),
	writeln(TaxID),
	write('Cust	'),
	writeln(Cust),
	write('InCab	'),
	writeln(InCab),
	write('Path	'),
	writeln(P),
	write('STime	'),
	writeln(STime),
	write('NTime	'),
	writeln(NTime),
	write('Status	'),
	writeln(S).

% 
% Print all current jobs for debugging.
% 
printAllJobsDebug :-
    	forall(job(TaxID,_,_,_,_,_,_),
           	printJobDebug(TaxID)).

% 
% Count available taxi's.
% 
availableTaxis(Count) :-
	findall(_,
		( taxi(TaxID),
		  \+job(TaxID,_,_,_,_,_,_)),
		List),
	length(List,X),
	Count is X.

% 
% Clean up all jobs.
% 
deleteAllJobs :-
	retractall(job(_,_,_,_,_,_,_)).
	
