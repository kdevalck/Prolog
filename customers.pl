% 
% Customers functions file
% 
% 
% 

sortCustomers :-
	findall(ETOP-CID, customer(CID,ETOP,_,_,_), ResultList),
	keysort(ResultList,Srtd),
	recorda(sorted,Srtd,_).

giveFirstCustomer(First) :-
	findall(ETOP-CID, customer(CID,ETOP,_,_,_), ResultList),
	keysort(ResultList,[First|_]).

nextCustomer(Next) :-
	recorded(sorted,[Next|Rest],R),
	erase(R),
	recorda(sorted, Rest,_).
	
