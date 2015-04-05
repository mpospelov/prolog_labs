debug_print(Name, Val):-
  print(Name), write(Val), nl.

%last(L1, X)
last([], _):- !, fail.
last([X], X).
last([_|T],X):- last(T,X).

%push(X, L1, L2)
push(X, [], [X]).
push(X, [F|L1_Tail], [F|L2_Tail]):-
  push(X, L1_Tail, L2_Tail).
% is_blank_list(L)
is_list_blank([]).

% concat(L1,L2,L3)
%?-concat([a,b],[c,d],[a,b,c,d]). Yes
concat([], L2, L2).
concat([H | []], L2, [H | L2]).
concat([H | L1_Tail], L2, L3):-
  concat([H], L4_Concated, L3),
  concat(L1_Tail, L2, L4_Concated). 

%invert(L1, L2)
%invert([a,b,c],[c,X,a]). X=b

accumulator_invert([], A, A):-!.
accumulator_invert([H|L1_Tail], A, L2):- 
  accumulator_invert(L1_Tail, [H|A], L2).

invert(L1, L2):- accumulator_invert(L1, [], L2).

%% member(X, L)
member(X, [X|_]).
member(X, [_|T]):-
  member(X,T).

%% ?-uniq([a,b,a,c,d,d],Z). Z=[a,b,c,d]
accumulator_uniq([], A, A).
accumulator_uniq([H|L1_Tail], A, L2):-
  (member(H, A))->
    accumulator_uniq(L1_Tail, A, L2); 
    accumulator_uniq(L1_Tail, [H|A], L2).

uniq(L1, L2):-
  accumulator_uniq(L1, [], L3),
  invert(L2, L3).


%%?-ucat([a,b,c],[d,c,e,a],Y). Y=[a,b,c,d,e]

ucat(L1, L2, Result):-
  concat(L1, L2, L3),
  uniq(L3, Result).

%% ?-mapop("+",[1,2,3],[4,5,6],R). R=[5,7,9]
calc("+", X, Y, R):-
  R is X + Y.
calc("*", X, Y, R):-
  R is X * Y.
calc("/", X, Y, R):-
  R is X / Y.
calc("-", X, Y, R):-
  R is X - Y.

accumulator_mapop(_, [], [], A, Result):-
  invert(A, Result).

accumulator_mapop(OP, [H1|T1], [H2|T2], A, Result):-
  calc(OP, H1, H2, New_Head),
  accumulator_mapop(OP, T1, T2, [New_Head|A], Result).

mapop(OP, L1, L2, Result):-
  accumulator_mapop(OP, L1, L2, [], Result).

%% unbr([[],[a,[1,[2,d],[]],56],[[[[v],b]]]],Q]. Q=[a,1,2,d,56,v,b]
accumulator_unbr([], A, A).
accumulator_unbr([H | L1_Tail], A, L2):-
  (is_list(H)->
    accumulator_unbr(H, [], A1),
    concat(A1, A, New_A)
    ;
    New_A = [H|A]
  ),
  accumulator_unbr(L1_Tail, New_A, L2).  
unbr(L1, L2):-
  accumulator_unbr(L1, [], M_R),
  invert(M_R, L2).

%% msum([[1,2,3],[],[-12,13]],S]. S=[6,0,1]
list_sum([], 0).
list_sum([H|T], S):- 
  list_sum(T, Tail_Sum),
  S is H + Tail_Sum.

accumulator_msum([], A, A).
accumulator_msum([H|T], A, L2):-
  list_sum(H, S),
  accumulator_msum(T,[S|A],L2).

msum(L1, L2):-
  accumulator_msum(L1, [], IL2),
  invert(IL2, L2).

% path(From, To, Path)

%% room(Id, Neighbour_rooms).
%% maze(Rooms).

room(0, [1]).
room(1, [0, 2]).
room(2, [1, 3, 4]).
room(3, [2,6]).
room(4, [2,5]).
room(5, [4,6,7]).
room(6, [5]).
room(7, [5]).

% path(0, 7, Path). Path = [0,1,2,5,7]
acc_next_rooms([], _, A, A).
acc_next_rooms(Neighbours, Visited, A, R):-
  Neighbours = [H|T],
  (member(H, Visited)->
    acc_next_rooms(T, Visited, A, R);
    acc_next_rooms(T, Visited, [H|A], R)
  ).

next_rooms(Neighbours, Visited, R):-
  acc_next_rooms(Neighbours, Visited, [], R).

acc_path(From, From, _, A, [From|A]).
acc_path(From, To, Visited, A, Path):-
  room(From, Neighbours),
  next_rooms(Neighbours, Visited, NextRooms),
  each_next_room(NextRooms, To, [From|Visited], [From|A], Path).

each_next_room([], _, _, _, _).
each_next_room([NextRoom|NextRooms], To, Visited, A, Path):-
  acc_path(NextRoom, To, Visited, A, Path),
  each_next_room(NextRooms, To, Visited, A, Path).

path(From, To, Path):-
  acc_path(From, To, [], [], IPath),
  IPath \= [],
  invert(IPath, Path).
