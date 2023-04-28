:- module(proylcc, 
	[  
		join/4
	]).


/**
 * join(+Grid, +NumOfColumns, +Path, -RGrids) 
 * RGrids es la lista de grillas representando el efecto, en etapas, de combinar las celdas del camino Path
 * en la grilla Grid, con número de columnas NumOfColumns. El número 0 representa que la celda está vacía. 
 */ 

 join(Grid, NumOfColumns, Path, RGrids):-
	borrarElementos(Grid, Path, NumOfColumns, 0, GridEliminados, NewValue),
	
	initializeLists([], NumOfColumns, ColumnsList),
	gridToColumns(GridEliminados, ColumnsList,0, AuxColumnsList),
	addLast([], AuxColumnsList, NewColumnsList),
    
	min_list(Grid, AuxMin),
	max_list(GridEliminados, AuxMax),
	Min is round(log(AuxMin)/log(2)),
	Max is round(log(AuxMax)/log(2)),
		
	nth0(0, NewColumnsList, FirstList),
	gravityFalls(FirstList,0, NewColumnsList, AuxListGravity, Min, Max),
    remove([], AuxListGravity, ListGravity),
	nth0(0, ListGravity, Column),	
	columnsToGrid(Column, ListGravity,0, [], GridGravity),
	
	
	RGrids = [GridEliminados, GridGravity].

/**
 * 
 */

gravityFalls([], _, ColumnsList, ColumnsList,_,_).
gravityFalls(List, IndexOfList, ColumnsList, GravityList, Min, Max):-
    List \= [],
	member(0, List),
	nth0(IndexElem, List, 0),
	eliminar_por_indice(List, IndexElem, ListElim),
	squareGenerator(Min, Max, AuxValue),
	Value is round(log(AuxValue)/log(2)),
	NewMax is max(Max, Value),
	add_first(AuxValue, ListElim, Aux),
	replace(ColumnsList, IndexOfList, Aux, NewList),
	NewIndex is IndexOfList+1,
    nth0(NewIndex,ColumnsList, NextList),
	gravityFalls(NextList, NewIndex, NewList, GravityList, Min, NewMax);
	
    List \= [],
	NewIndex is IndexOfList+1,
    nth0(NewIndex,ColumnsList, NextList),
	gravityFalls(NextList, NewIndex, ColumnsList, GravityList, Min, Max).


eliminar_por_indice([], _, []).
eliminar_por_indice([_|T], 0, T).
eliminar_por_indice([H|T], Indice, [H|Resto]) :-
    Indice > 0,
    Indice1 is Indice - 1,
    eliminar_por_indice(T, Indice1, Resto).

/**
 * 
 */
gridToColumns([],ColumnsList,_,ColumnsList).
gridToColumns([H|Tail], ColumnsList, Index, NewList):-
	nth0(Index, ColumnsList, IndexedList),
	addLast(H, IndexedList, Aux),
	replace(ColumnsList, Index, Aux, ReturnList),
	length(ColumnsList, NumOfColumns),
	NewIndex is (Index+1) mod NumOfColumns,
	gridToColumns(Tail, ReturnList, NewIndex, NewList).

/**
 * 
 */
columnsToGrid([], _, _, GridList, GridList).
columnsToGrid([H|Tail], ColumnsList, Index, GridList, ReturnList):-
	addLast(H, GridList, UpdatedList),
	remove(H, [H|Tail], UpdatedCurrent),
	replace(ColumnsList, Index, UpdatedCurrent, UpdatedColumnsList),
	length(ColumnsList, NumOfColumns),
	NewIndex is (Index+1) mod NumOfColumns,
    nth0(NewIndex, ColumnsList,NewElement),
	columnsToGrid(NewElement, UpdatedColumnsList, NewIndex, UpdatedList, ReturnList).

initializeLists(List, 0, List).
initializeLists(List, NumofLists, ReturnList):-
	addLast([], List, NewList),
	Aux is NumofLists-1,
	initializeLists(NewList, Aux, ReturnList).

/**
 * borrarElementos(+Grid, +Path, +NumColumnas, +TotalPath, -GridElim, -NewValue)
 * En la lista Grid, recorre todos los elementos de la lista Path y los reemplaza por un 0, lo cuál
 * representa un bloque vacío. Al llegar al último elemento del Path, este debe ser aumentado utilizando
 * la función "smallerPow2GreaterOrEqualThan".
 * NumColumnas se utiliza para calcular el índice de los elementos eliminados en la grilla.
 * TotalPath se utiliza para mantener el resultado total de los valores recorridos en el Path.
 * GridElim es la nueva grilla con los elementos ya eliminados, mientras que NewValue es el valor del 
 * último bloque el cuál fue aumentado. 
 */
borrarElementos(Grid, [[I,J]|[]], NumColumnas, TotalPath, GridElim, NewValue):-
	Index is I*NumColumnas+J,
	nth0(Index, Grid, OldValue),
	NewTotalPath is TotalPath+OldValue,
	smallerPow2GreaterOrEqualThan(NewTotalPath, NewValue),
	replace(Grid, Index, NewValue, GridElim).

borrarElementos(Grid, [[I,J]|Tail], NumColumnas, TotalPath, GridElim, NewValue):-
    Index is I * NumColumnas + J,
	nth0(Index, Grid, OldValue),
	NewTotalPath is TotalPath+OldValue,
    replace(Grid, Index, 0, GridRep),
    borrarElementos(GridRep, Tail, NumColumnas, NewTotalPath, GridElim, NewValue).

/**
 * smallerPow2GreatorOrEqualThan(+Result, -Value)
 * Calcula la menor potencia de 2, que sea mayor o igual al Result pasado por parámetro.
 * Este resultado es retornado en Value
 */
smallerPow2GreaterOrEqualThan(Result, Value):-
	Log2num = floor(log(Result)/log(2)),
	Result is 2**Log2num,
	Value is Result;
	Log2num = floor(log(Result)/log(2)),
	Value is 2**(Log2num+1).

/**
 * replace(+[H|T], +I, +X, -[H|R])
 * [H|T] es la lista de la cuál se quiere reemplazar el elemento en el índice I por X
 * [H|R] es la lista a retornar con el elemento reemplazado por X
 */

replace([_|T], 0, X, [X|T]).
replace([H|T], I, X, [H|R]) :-
    I > 0,
    NI is I - 1,
    replace(T, NI, X, R).


/**
 * squareGenerator(+Min, +Max, -Number)
 * Min es la potencia de 2 más baja de la grilla, Max es la potencia de 2 más alta de la grilla y Number es
 * un número aleatorio potencia de 2 entre Min y Max. Se utiliza para generar el valor de un Square nuevo.
 */
squareGenerator(Min, Max,Number):- 
	random(Min, Max, Random),
	Number is 2**Random.


/**
 * find(+X, +[Y|Tail])
 * Busca X dentro de la lista pasada como segundo parámetro
 */
find(X,[X|_]). 
find(X,[_|Tail]):- 
  find(X,Tail). 

/**
 * findAll(+X, +[X|Tail], -List)
 * Encuentra todos los elementos iguales a X dentro de la lista pasada por parámetro y los devuelve en una
 * nueva lista List
 */
findAll(_,[],_). 
findAll(X,[X|Tail], List):- 
  addLast(X, List, NewList),
  findAll(X,Tail, NewList). 

/**
 * addLast(+X, +[Head|Tail], -[Head|R])
 * Agrega el elemento X al final de la lista pasada por parámetro y retorna la nueva lista.
 */
addLast(X,[],[X]).
addLast(X,[Head|Tail],[Head|R]):- addLast(X,Tail,R). 

add_first(X,[],[X]).
add_first(X,List,[X|List]). 

find(Index, Lista, Elemento, ListaDefault) :-
    (nth0(Index, Lista, Elemento) ; Elemento = ListaDefault).
    
remove(X,[X|Tail],Tail).
remove(X, [Head|Tail], [Head|New_Tail]):-
  X \= Head, 
  remove(X,Tail,New_Tail).
