% 
% TaxiStand functions
% 
% 
% 


% Get PointID of taxi's parking lot

parkingLot(PID) :-
	node(PID,13,13).


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
	
