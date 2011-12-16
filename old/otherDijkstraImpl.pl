% dijkstra(Vertex0, Ss) is true if Ss is a list of structures s(Vertex, Dist,
%   Path) containing the shortest Path from Vertex0 to Vertex, the distance of
%   the path being Dist.  The graph is defined by e/3.
% e.g. dijkstra(penzance, Ss)
dijkstra(Vertex, Ss):-
  create(Vertex, [Vertex], Ds),
  dijkstra_1(Ds, [s(Vertex,0,[])], Ss).

dijkstra_1([], Ss, Ss).
dijkstra_1([D|Ds], Ss0, Ss):-
  best(Ds, D, S),
  delete([D|Ds], [S], Ds1),
  S=s(Vertex,Distance,Path),
  reverse([Vertex|Path], Path1),
  merge(Ss0, [s(Vertex,Distance,Path1)], Ss1),
  create(Vertex, [Vertex|Path], Ds2),
  delete(Ds2, Ss1, Ds3),
  incr(Ds3, Distance, Ds4),
  merge(Ds1, Ds4, Ds5),
  dijkstra_1(Ds5, Ss1, Ss).

% path(Vertex0, Vertex, Path, Dist) is true if Path is the shortest path from
%   Vertex0 to Vertex, and the length of the path is Dist. The graph is defined
%   by e/3.
% e.g. path(penzance, london, Path, Dist)
path(Vertex0, Vertex, Path, Dist):-
  dijkstra(Vertex0, Ss),
  member(s(Vertex,Dist,Path), Ss), !.
  
% create(Start, Path, Edges) is true if Edges is a list of structures s(Vertex,
%   Distance, Path) containing, for each Vertex accessible from Start, the
%   Distance from the Vertex and the specified Path.  The list is sorted by the
%   name of the Vertex.
create(Start, Path, Edges):-
  setof(s(Vertex,Edge,Path), e(Start,Vertex,Edge), Edges), !.
create(_, _, []).
  
% best(Edges, Edge0, Edge) is true if Edge is the element of Edges, a list of
%   structures s(Vertex, Distance, Path), having the smallest Distance.  Edge0
%   constitutes an upper bound.
best([], Best, Best).
best([Edge|Edges], Best0, Best):-
  shorter(Edge, Best0), !,
  best(Edges, Edge, Best).
best([_|Edges], Best0, Best):-
  best(Edges, Best0, Best).

shorter(s(_,X,_), s(_,Y,_)):-X < Y.

% delete(Xs, Ys, Zs) is true if Xs, Ys and Zs are lists of structures s(Vertex,
%   Distance, Path) ordered by Vertex, and Zs is the result of deleting from Xs
%   those elements having the same Vertex as elements in Ys.
delete([], _, []). 
delete([X|Xs], [], [X|Xs]):-!. 
delete([X|Xs], [Y|Ys], Ds):-
  eq(X, Y), !, 
  delete(Xs, Ys, Ds). 
delete([X|Xs], [Y|Ys], [X|Ds]):-
  lt(X, Y), !, delete(Xs, [Y|Ys], Ds). 
delete([X|Xs], [_|Ys], Ds):-
  delete([X|Xs], Ys, Ds). 
  
% merge(Xs, Ys, Zs) is true if Zs is the result of merging Xs and Ys, where Xs,
%   Ys and Zs are lists of structures s(Vertex, Distance, Path), and are
%   ordered by Vertex.  If an element in Xs has the same Vertex as an element
%   in Ys, the element with the shorter Distance will be in Zs.
merge([], Ys, Ys). 
merge([X|Xs], [], [X|Xs]):-!. 
merge([X|Xs], [Y|Ys], [X|Zs]):-
  eq(X, Y), shorter(X, Y), !, 
  merge(Xs, Ys, Zs).
merge([X|Xs], [Y|Ys], [Y|Zs]):-
  eq(X, Y), !, 
  merge(Xs, Ys, Zs).
merge([X|Xs], [Y|Ys], [X|Zs]):-
  lt(X, Y), !, 
  merge(Xs, [Y|Ys], Zs).
merge([X|Xs], [Y|Ys], [Y|Zs]):-
  merge([X|Xs], Ys, Zs).

eq(s(X,_,_), s(X,_,_)).  

lt(s(X,_,_), s(Y,_,_)):-X @< Y.

% incr(Xs, Incr, Ys) is true if Xs and Ys are lists of structures s(Vertex,
%   Distance, Path), the only difference being that the value of Distance in Ys
%   is Incr more than that in Xs.
incr([], _, []).  
incr([s(V,D1,P)|Xs], Incr, [s(V,D2,P)|Ys]):-
  D2 is D1 + Incr,
  incr(Xs, Incr, Ys).

% member(X, Ys) is true if the element X is contained in the list Ys.
%member(X, [X|_]).
%member(X, [_|Ys]):-member(X, Ys).

% reverse(Xs, Ys) is true if Ys is the result of reversing the order of the
%   elements in the list Xs.
%reverse(Xs, Ys):-reverse_1(Xs, [], Ys).

%reverse_1([], As, As).
%reverse_1([X|Xs], As, Ys):-reverse_1(Xs, [X|As], Ys).

e(X, Y, Z):-dist(X, Y, Z).
e(X, Y, Z):-dist(Y, X, Z).

/* A subset of the data from EXAMPLES\SALESMAN.PL in LPA Win-Prolog */
dist(aberdeen,    edinburgh,   115).
dist(aberdeen,    glasgow,     142).
dist(aberystwyth, birmingham,  114).
dist(aberystwyth, cardiff,     108).
dist(aberystwyth, liverpool,   100).
dist(aberystwyth, nottingham,  154).
dist(aberystwyth, sheffield,   154).
dist(aberystwyth, swansea,      75).
dist(birmingham,  bristol,      86).
dist(birmingham,  cambridge,    97).
dist(birmingham,  cardiff,     100).
dist(birmingham,  liverpool,    99).
dist(birmingham,  manchester,   80).
dist(birmingham,  nottingham,   48).
dist(birmingham,  oxford,       63).
dist(birmingham,  sheffield,    75).
dist(birmingham,  swansea,     125).
dist(brighton,    bristol,     136).
dist(brighton,    dover,        81).
dist(brighton,    oxford,       96).
dist(brighton,    portsmouth,   49).
dist(brighton,    london,       52).
dist(bristol,     exeter,       76).
dist(bristol,     oxford,       71).
dist(bristol,     portsmouth,   97).
dist(bristol,     swansea,      89).
dist(bristol,     london,      116).
dist(cambridge,   nottingham,   82).
dist(cambridge,   oxford,       80).
dist(cambridge,   london,       54).
dist(cardiff,     swansea,      45).
dist(carlisle,    edinburgh,    93).
dist(carlisle,    glasgow,      94).
dist(carlisle,    leeds,       117).
dist(carlisle,    liverpool,   118).
dist(carlisle,    manchester,  120).
dist(carlisle,    newcastle,    58).
dist(carlisle,    york,        112).
dist(dover,       london,       71).
dist(edinburgh,   glasgow,      44).
dist(edinburgh,   newcastle,   104).
dist(exeter,      penzance,    112).
dist(exeter,      portsmouth,  126).
dist(glasgow,     newcastle,   148).
dist(hull,        leeds,        58).
dist(hull,        nottingham,   90).
dist(hull,        sheffield,    65).
dist(hull,        york,         37).
dist(leeds,       manchester,   41).
dist(leeds,       newcastle,    89).
dist(leeds,       sheffield,    34).
dist(leeds,       york,         23).
dist(liverpool,   manchester,   35).
dist(liverpool,   nottingham,  100).
dist(liverpool,   sheffield,    70).
dist(manchester,  newcastle,   130).
dist(manchester,  sheffield,    38).
dist(newcastle,   york,         80).
dist(nottingham,  sheffield,    38).
dist(oxford,      london,       57).
