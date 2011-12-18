% Calculate the shortest path in the graph from one point
%  to another.
%
% Before using this route calculation edge/3 must be already
%  defined
%
% Usage example:
%
% 	?- shortestPath(1,10,Path,Length).
%
% shortestPath
% 	Start		: Starting point
% 	End     	: Ending point
% 	ShortestPath 	: Shortest path from Start to End
% 	Length         	: Length of the shortest path
%


shortestPath(Start, End, ShortestPath, Length) :-
  dijk( [0-[Start]], End, RShort, Length),
  reverse(RShort, ShortestPath).



% When we so that the End point is reached we stop and return
%  to the shortestPath function where we reverse the 
%  shortest path.
dijk( [ Length-[End|Rest] |_], End, [End|Rest], Length) :- !.

% First search for new best point to add to path
% Then call dijk function again with new best point
%  added to path.
dijk( Visited, End, RShortestPath, Length) :-
  bestCandidate(Visited, BestCandidate,End), 
  dijk( [BestCandidate|Visited], End, RShortestPath, Length).



% 
% Calculate heuristic to improve the algorithm
% 
% http://www.cs.cmu.edu/~crpalmer/sp/
%
% 360723510   79
% 3601063511   82
% 3701243512   79
% 372493513   103
% 3742493514   26
% 390413515   90
% 393903516   62
% 401133517   88
% 405683518   103
% 411453519   92

calcHeuristic(Point,End,Result) :-
	node(Point,X1,Y1),
	node(End,X2,Y2),
	Result is max(abs(X2 - X1), abs(Y2 - Y1)).

square_of(X, XSquared) :-
  	XSquared is X * X.

% Euclidian metric
%
% 360723510   83
% 3601063511   70
% 3701243512   82
% 372493513   106
% 3742493514   28
% 390413515   92
% 393903516   47
% 401133517   87
% 405683518   85
% 411453519   103

calcHeuristic1(Point,End,Result) :-
	node(Point,X1,Y1),
	node(End,X2,Y2),
	square_of(abs(X1-X2), RX),
	square_of(abs(Y1-Y2), RY),
	Result is sqrt(RX+RY).

% Manhatten heuristic
% http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html
% http://en.wikipedia.org/wiki/Taxicab_geometry
%
% 360723510   68
% 3601063511   80
% 3701243512   60
% 372493513   88
% 3742493514   23
% 390413515   64
% 393903516   42
% 401133517   81
% 405683518   73
% 411453519   68

calcHeuristic2(Point,End,Result) :-
	node(Point,X1,Y1),
	node(End,X2,Y2),
	Temp is (abs(X1 - X2)+abs(Y1 - Y2)),
	square_of(Temp,Result).

%
% Find the best new point to add to the current path.
%

bestCandidate(Paths, BestNewPoint,End) :-
  findall(NewPoint,
    ( member( Length-[Point1|Path], Paths),	% Take the last point visited.
      edge(Point1,Point2,Dist),		% Take all the edges from Point1.
      \+isVisited(Paths, Point2),         	% Check if Point2 isn't visted yet.
      
      calcHeuristic2(Point2,End,Heuristic),
      Cost is Dist+Heuristic,
      NLength is Length+Dist,              	% Add the distance from Point1 to Point2 to the Length we already had.
	% Save this new discovered point into the right format
      NewPoint=Cost-[NLength-[Point2,Point1|Path]] 
    ),
	% NewPointList contains all the NewPoint's in the right format
    NewPointList
  ),

  % From this NewPointList we calculate the BestNewPoint
  % Where BestNewPoint is the one with the shortest path from
  %  the start point till the current point.
  minimum(NewPointList, BestNewPoint).

% Check if this point has been visited yet.

isVisited(Paths, Point2) :-
  memberchk(_-[Point2|_], Paths).

% Sort the NewPointList by the length of the path
% So the shortest path will endup first.
% We return the first.

minimum(NewPointList, BestNewPoint) :-
  keysort(NewPointList, [_-[BestNewPoint|_]|_]).




