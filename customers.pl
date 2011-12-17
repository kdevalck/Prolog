% 
% Customers functions file
% 
% 
% 

% Sort the custumers according their pick up time.
% Pit the result list in the global variable 'sorted'.
sortCustomers :-
	findall(ETOP-CID, customer(CID,ETOP,_,_,_), ResultList),
	keysort(ResultList,Srtd),
	recorda(sorted,Srtd,_).

% Sort the customers according to their pickup time
%  and return the whole list.
sortCustomers(SortedList) :-
	findall(ETOP-CID, customer(CID,ETOP,_,_,_), All),
	keysort(All,SortedList).

% Give the first customer to be picked up.
giveFirstCustomer(First) :-
	findall(ETOP-CID, customer(CID,ETOP,_,_,_), ResultList),
	keysort(ResultList,[First|_]).

% Give the next customer to be picked up. This customer is then removed
%  from the list.
nextCustomer(Next) :-
	recorded(sorted,[Next|Rest],R),
	erase(R),
	recorda(sorted, Rest,_).
	
% Get all the CustomersID's with the same starting point as
%  the given customer
getCustomersWithSameStart(CID,OutputCustomers) :-
	customer(CID,_,_,NID,_),
	findall(Newcust,
		(customer(CID1,_,_,NID,_),
		\+CID=CID1,
		Newcust=CID1),
		OutputCustomers).

% Get all the customers with the same destination point as
%  the given customer
getCustomersWithSameDest(CID,OutputCustomers) :-
	customer(CID,_,_,_,Dest),
	findall(Newcust,
		(customer(CID1,_,_,_,Dest),
		\+CID=CID1,
		Newcust=CID1),
		OutputCustomers).


