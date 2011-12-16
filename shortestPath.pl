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
dijk( Visited, Fin, RShortestPath, Length) :-
  bestCandidate(Visited, BestCandidate), 
  dijk( [BestCandidate|Visited], Fin, RShortestPath, Length).



%
% Find the best new point to add to the current path.
%

bestCandidate(Paths, BestNewPoint) :-
  findall(NewPoint,
    ( member( Length-[Point1|Path], Paths),	% Take the last point visited.
      edge(Point1,Point2,Dist),		% Take all the edges from Point1.
      \+isVisited(Paths, Point2),         	% Check if Point2 isn't visted yet.

      NLength is Length+Dist,              	% Add the distance from Point1 to Point2 to the Length we already had.
	% Save this new discovered point into the right format
      NewPoint=NLength-[Point2,Point1|Path] 
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
  keysort(NewPointList, [BestNewPoint|_]).




