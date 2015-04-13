printlist([]).
printlist([Hd | Tl]) :- 
  write(Hd), nl, printlist(Tl).

dry(_, [], 1, []).
dry(H,[H1|T1], 1, [H1|T1]) :- H \= H1.
dry(H, [H|T], N, L) :- 
  dry(H, T, N1, L), N is N1 + 1.

drylist([], []).
drylist([H|T], [[H, N]|L]):- 
  dry(H, T, N, L2), drylist(L2, L).

pad('2.217.01', '45_30', 1).
pad('2.217.07', '45_30', 2).
pad('2.217.09', '45_30', 3).
pad('2.217.10', '45_30', 5).
pad('3.217.01', '60_45', 1).
pad('3.217.07', '60_45', 2).
pad('3.217.09', '60_45', 3).
pad('3.217.10', '60_45', 5).
pad('3.107.25', '90_60', 2).
pad('3.107.27', '90_60', 3).
pad('3.107.28', '90_60', 5).

holder('2.451.01', '45_30', '30_18', 29).
holder('3.451.01', '60_45', '45_22', 35).
holder('2.451.02', '60_45', '45_22', 34).
holder('3.451.02', '90_60', '65_30', 42).

cam_p('2.913.01', '30_18', 10,  8, 12, 3,  7).
cam_p('2.913.02', '45_22', 12,  8, 12, 3,  7).
cam_p('2.913.07', '65_30', 25, 12, 30, 8, 18).

cam_t('2.913.05', '30_18',  'm6', 16).
cam_t('2.913.06', '45_22',  'm8', 20).
cam_t('2.913.09', '65_30', 'm12', 38).

bearing_s('2.910.01',  'm6').
bearing_s('2.910.02',  'm8').
bearing_s('3.910.01', 'm12').
bearing_s('3.910.02', 'm16'). 

bearing_r('2.911.01',  'm6').
bearing_r('2.911.02',  'm8').
bearing_r('3.911.01', 'm12').

pivot('2.213.01',  'm6',  6,  8).
pivot('2.213.04',  'm8',  8, 12).
pivot('2.213.06', 'm12', 12, 26).

compare(H, N, N, H):- 
  N >= H.
compare(H, N, H, N):- 
  N < H.

max([H|[]], H).
max([H|T], R):- 
  max(T, N), 
  compare(H, N, R, _).

min([H|[]], H).
min([H|T], R):- 
  min(T, N), 
  compare(H, N, _, R).

getminmax(Type, H):- 
  findall(N, develop(Type, H, N, _), Q), 
  max(Q, Nmax), findall(L, develop(Type, H, Nmax, L), Lmax),
  min(Q, Nmin), findall(L, develop(Type, H, Nmin, L) , Lmin),
  write('Max:'), nl, printlist(Lmax), nl,
  write('Min:'), nl, printlist(Lmin).

getminmax(Type, H, D):- 
  findall(N, develop(Type, H, N, D, _), Q), 
  max(Q, Nmax), findall(L, develop(Type, H, Nmax, D, L), Lmax),
  min(Q, Nmin), findall(L, develop(Type, H, Nmin, D, L) , Lmin),
  write('Max:'), nl, printlist(Lmax), nl,
  write('Min:'), nl, printlist(Lmin).
  
padding(H, _, _, _):- 
  H < 1, !, fail.
padding(H, Type, [PN], 1):- 
  pad(PN, Type, H). 
padding(H, Type, [PN | List], N):- pad(PN, Type, H2), H1 is H - H2, padding(H1, Type, List, N1),
  N is N1+1,!.

fixator(H, Type_cam, [PN], 0):- 
  holder(PN, _, Type_cam, H).
fixator(H, Type_cam, [PN | List], N):- 
  holder(PN, Type_holder, Type_cam, H1), H2 is H - H1, 
  padding(H2, Type_holder, L, N), drylist(L, List).

% develop(USP, H, N, [Bearing, Cam | [Holder | Pads]])

develop('flat_fine', H, N, [PN1, PN2 | List]):- 
  bearing_s(PN1, Mx), 
  cam_t(PN2, Type_cam, Mx, H1), 
  H2 is H - H1 - 30,
  fixator(H2, Type_cam, List, N).

develop('flat_draft', H, N, [PN1, PN2 | List]):- 
  bearing_r(PN1, Mx), 
  cam_t(PN2, Type_cam, Mx, H1), 
  H2 is H - H1 - 30,
  fixator(H2, Type_cam, List, N).

develop('cylinder_v', H, N, D, [PN1 | List]):- 
  cam_p(PN1, Type_cam, H1, _, _, Dmin, Dmax), 
  D >= Dmin, D =< Dmax,
  H2 is H - H1 - 30, 
  fixator(H2, Type_cam, List, N).

develop('cylinder_h', H, N, D, [PN1 | List]):- 
  cam_p(PN1, Type_cam, H1, Dmin, Dmax, _, _), 
  D >= Dmin, D =< Dmax, 
  H2 is H - H1 - 30, 
  fixator(H2, Type_cam, List, N).

develop('perforated', H, N, D,[PN1, PN2 | List]):- 
  pivot(PN1, Mx, Dmin, Dmax), 
  D >= Dmin, D =< Dmax, 
  cam_t(PN2, Type_cam, Mx, H1), 
  H2 is H - H1 - 30, 
  fixator(H2, Type_cam, List, N).
