% solve(Coordinates, Median)
% @param Coordinates: [[X0,Y0], [X1, Y1], ...] 
% @param Median: [Xk, Yk]

solve(Coordinates, Median):-
  Coordinates = [ H | CalculatingCoords],
  weight(H, Coordinates, FirstWeight),
  acc_solve(Coordinates, CalculatingCoords, [H, FirstWeight], Median).
    
% acc_solve(Coordinates, CalculatingCoords, CurrentMin, Median)
% @param Coordinates: [[X0,Y0], [X1, Y1], ...] 
% @param CalculatingCoords: [[Xi,Yi], [Xi+1, Yi+1], ...] 
% @param CurrentMin: [[Xj,Yj], MinWeight]
% @param Median: [Xk, Yk]

acc_solve(_, [], [ Median | _], Median).

acc_solve(Coordinates, [ CurrentCoordinate | TCoordinates], CurrentMin, Median):-
  CurrentMin = [_, CurrentMinWeight],
  weight(CurrentCoordinate, Coordinates, Weight),
  (CurrentMinWeight > Weight->
    NewMinWeight = [CurrentCoordinate, Weight];
    NewMinWeight = CurrentMin
  ),
  acc_solve(Coordinates, TCoordinates, NewMinWeight, Median).
  
weight([X,Y], Coordinates, Result):-
  acc_weight([X,Y], Coordinates, 0, Result).

acc_weight(_, [], Result, Result).
acc_weight([Xi,Yi], [[Xj,Yj] | TCoordinates], Acc, Result):-
  Wij is sqrt((Xi - Xj)*(Xi - Xj) + (Yi - Yj)*(Yi - Yj)),
  NewAcc is Acc + Wij,
  acc_weight([Xi, Yi], TCoordinates, NewAcc, Result).