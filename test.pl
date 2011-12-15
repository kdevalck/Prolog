%edge(a,b,5).
%edge(a,d,10).
%edge(a,c,7).
%edge(a,e,12).
%edge(b,d,2).
%edge(b,c,6).
%edge(c,d,4).
%edge(e,f,3).

%e(a0,a1,5).
%e(a0,a2,3).
%e(a0,a4,2).
%e(a1,a2,2).
%e(a1,a3,6).
%e(a2,a1,1).
%e(a2,a3,2).
%e(a4,a1,6).
%e(a4,a2,9).
%e(a4,a3,4).


connected(X,Y) :- edge(X,Y,_) ; edge(Y,X,_).
connected(X,Y,L) :- edge(X,Y,L) ; edge(Y,X,L).

path(A,B,Path) :-
       travel(A,B,[A],Q), 
       reverse(Q,Path).

travel(A,B,P,[B|P]) :- 
       connected(A,B).
travel(A,B,Visited,Path) :-
       connected(A,C),           
       C \== B,
       \+member(C,Visited),
       travel(C,B,[C|Visited],Path).  


spath(First, Last, Path, Length):-
  path_1(First, Last, [], 0, Path, Length).

path_1(Last, Last, Path, Length, [Last|Path], Length).
path_1(First, Last, Path0, Length0, Path, Length):-
  edge(NextToLast, Last, Length1), 
  \+member(NextToLast, Path0), 
  Length2 is Length0 + Length1,
  path_1(First, NextToLast, [Last|Path0], Length2, Path, Length).
