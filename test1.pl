print_path(V, X) :- 
        lpath(V, X), 
        write('There is a path between '), write(V), write(' and '), 
write(X), nl. 
neighbour(Vertex0, Vertex1) :- 
        ( edge(Vertex0, Vertex1,_) 
        ; edge(Vertex1, Vertex0,_) 
        ). 
lpath(Vertex0, Vertex1) :- 
        lpath(Vertex0, Vertex1, []). 
lpath(Vertex0, Vertex1, _) :- 
        neighbour(Vertex0, Vertex1). 
lpath(Vertex0, Vertex1, Visited) :- 
        \+ member(Vertex1, Visited), 
        neighbour(Vertex1, Aux), 
        lpath(Vertex0, Aux, [Vertex1|Visited]).
