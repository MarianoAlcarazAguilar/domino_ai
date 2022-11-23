/*
Aquí solo guardo datos para poder probar la la funcionalidad del programa.
*/
mis_fichas([[1,2], [3,4], [6,6], [5,0], [2,3], [5,5]]).
mesa([[1,2], [2,4], [4,5]]).

/*
list_sum(input, input, output)

Esta función recibe dos listas de números y suma los valores entrada a entrada. 
Regresa el resultado en otra lista.
*/
list_sum([], [], []).
list_sum([H1|T1],[H2|T2],[X|L3]):-
   list_sum(T1,T2,L3), 
   X is H1+H2.


/* 
numeros_extremos(input, output1, output2)

Esta funcion recibe una lista de listas que normalmente será la mesa.
Regresa los extremos de la mesa para saber qué valores se pueden jugar siguiente.
*/
numeros_extremos([[H1,_]|T], Extremo_izq, Extremo_der):-
   Extremo_izq = H1,
   last([_|T], X),
   last(X,Extremo_der).

/* 
numeros_en_ficha(input, input, output)
dame_numeros(input, input, output)

La funcion numeros en ficha recibe una lista de listas que normalmente serán mis fichas.
Sobre ella itera para saber si tenemos valores en la otra cara de la ficha regresa los valores.
dame_numeros convierte los resultados en una lista para que sea más fácil trabajar con ellos
*/
numeros_en_ficha(Mis_fichas, Numero_que_tengo, Otros_numeros):-
   member([Numero_que_tengo, Otros_numeros], Mis_fichas).

numeros_en_ficha(Mis_fichas, Numero_que_tengo, Otros_numeros):-
   member([Otros_numeros, Numero_que_tengo], Mis_fichas).

dame_numeros(Mis_fichas, Numero_que_tengo, Lista):-
   findall(Y, numeros_en_ficha(Mis_fichas, Numero_que_tengo, Y), Lista).


/*
hay_mula(input, input)

Esta funcion revisa si hay mulas en una lista de listas.
Recibe fichas y el número que se busca
*/
hay_mula([[H1, H2]|T], Numero):-
   (
      H1 == Numero, H2 == Numero -> 
         true
         ;
         hay_mula(T, Numero)
   ).

encuentra_mulas([], []).

encuentra_mulas([[H1, H2]|T], [Mula1 | Mula2]):-
   encuentra_mulas(T, Mula2),
   (
      H1 == H2 ->
         Mula1 is H1;
         true
   ).

/*
fichas_jugadas(input, input, output)
total_jugadas(input, input, output)
total_jugadas(input, input, input, output)

La funcion fichas_jugadas recibe las fichas de la mesa y las nuestras y regresa una lista donde junta ambas
La funcion total_jugadas \3 recibe una lista de fichas, un número buscado, y el total de fichas que tienen ese número
La funcion total_jugadas \4 recibe dos lstas de fichas que son después juntadas y llama a total_jugadas \3 con esa
*/
fichas_jugadas(Mesa, Mis_fichas, Jugadas):-
   append(Mesa, Mis_fichas, Jugadas).

total_jugadas(Jugadas, Numero, Total):-
   dame_numeros(Jugadas, Numero, Aux_lista),
   length(Aux_lista, Total).

total_jugadas(Numero, Total):-
   mesa(X),
   mis_fichas(Y), 
   fichas_jugadas(X, Y, Jugadas),
   total_jugadas(Jugadas, Numero, Aux_total),
   (
      hay_mula(Jugadas, Numero) ->
         Total is Aux_total - 1
         ;

         Total = Aux_total
   ).

total_jugadas(Lista1, Lista2, Numero, Total):- 
   fichas_jugadas(Lista1, Lista2, Jugadas),
   total_jugadas(Jugadas, Numero, Aux_total),
   (
      hay_mula(Jugadas, Numero) ->
         Total is Aux_total - 1
         ;

         Total = Aux_total
   ).

/*
suma_fichas(input, output)

Suma los valores de las caras de las fichas. Regresa el resultado en una lista.
*/
suma_fichas([], []).
suma_fichas([[N1, N2] | T], [Sum1 | SumR]):-
   suma_fichas(T, SumR),
   Sum1 is N1 + N2.


/* 
asinga_valor_ficha(input, input, input, input, output)
recorre_fichas_asignando_valor(input, input, input, input, output)

La funcion asigna valor recibe una ficha, el numero extremo, el total de fichas que tenemos con ese numero extremo, el total de fichas
que se han jugado y regresa un valor heurístico para esa ficha

La funcion recorre fichas asignando valor recibe tus fichas, el numero extremo, el total de fichas con ese número, el total de fichas
que se han jugado y regresa una lista con los valores heurísticos correspondientes a cada ficha
*/

asigna_valor_ficha([Num1, Num2], Num_cara, Total_mias, Total_jugadas, Valor):-
   Num1 == Num2,
   Num1 == Num_cara,
   (
      Num_cara == 0 ->
         Numero_extremo is 1;
         Numero_extremo is Num_cara
   ),
   Valor is 100 * Total_mias * Numero_extremo * Total_jugadas,
   !.

asigna_valor_ficha([Num1 | _], Num_cara, Total_mias, Total_jugadas, Valor):-
   Num1 == Num_cara,
   (
      Num_cara == 0 ->
         Numero_extremo is 1;
         Numero_extremo is Num_cara
   ),
   Valor is 10 * Total_mias * Numero_extremo * Total_jugadas,
   !.

asigna_valor_ficha([_ , Num2 | _], Num_cara, Total_mias, Total_jugadas,  Valor):-
   Num2 == Num_cara,
   (
      Num_cara == 0 ->
         Numero_extremo is 1;
         Numero_extremo is Num_cara
   ),
   Valor is 10 * Total_mias * Numero_extremo * Total_jugadas,
   !.

asigna_valor_ficha([_|_], _, _, _, Valor):-
   Valor is 0.


recorre_fichas_asignando_valor([], _, _, _, []).

recorre_fichas_asignando_valor([H|T], Valor_extremo, Total_mias, Total_jugadas, [Valor1|Valor2]):-
   recorre_fichas_asignando_valor(T, Valor_extremo, Total_mias, Total_jugadas, Valor2),
   asigna_valor_ficha(H, Valor_extremo, Total_mias, Total_jugadas, Valor1).


/*
funcion_heuristica(input, input, output)
input 1: Fichas en el tablero
input 2: Fichas en mi mano
output: Lista con valores heurísitcos para cada ficha

Recibe las fichas en la mesa, las fichas que tenemos y regresa una lista del tamaño de mis fichas con el valor
heurístico correspondiente a cada ficha.
*/
funcion_heuristica([], Mis_fichas, Respuesta):-
   suma_fichas(Mis_fichas, Respuesta),
   !.

funcion_heuristica([[Valor_izquierdo,Valor_derecho]], Mis_fichas, Respuesta):-
   fichas_jugadas([[Valor_izquierdo, Valor_derecho]], Mis_fichas, Jugadas),
   total_jugadas(Jugadas, Valor_izquierdo, Total_jugadas_izq),
   total_jugadas(Jugadas, Valor_derecho, Total_jugadas_der),
   dame_numeros(Mis_fichas, Valor_izquierdo, Aux_izq),
   length(Aux_izq, Total_fichas_mias_izq),
   dame_numeros(Mis_fichas, Valor_derecho, Aux_der),
   length(Aux_der, Total_fichas_mias_der),
   recorre_fichas_asignando_valor(Mis_fichas, Valor_izquierdo, Total_fichas_mias_izq, Total_jugadas_izq, L1),
   recorre_fichas_asignando_valor(Mis_fichas, Valor_derecho, Total_fichas_mias_der, Total_jugadas_der, L2),
   list_sum(L1, L2, Respuesta),
   !.

funcion_heuristica(Mesa, Mis_fichas, Respuesta):-
   numeros_extremos(Mesa, Valor_izquierdo, Valor_derecho),
   fichas_jugadas(Mesa, Mis_fichas, Jugadas),
   total_jugadas(Jugadas, Valor_izquierdo, Total_jugadas_izq),
   total_jugadas(Jugadas, Valor_derecho, Total_jugadas_der),
   dame_numeros(Mis_fichas, Valor_izquierdo, Aux_izq),
   dame_numeros(Mis_fichas, Valor_derecho, Aux_der),
   length(Aux_izq, Total_fichas_mias_izq),
   length(Aux_der, Total_fichas_mias_der),
   recorre_fichas_asignando_valor(Mis_fichas, Valor_izquierdo, Total_fichas_mias_izq, Total_jugadas_izq, L1),
   recorre_fichas_asignando_valor(Mis_fichas, Valor_derecho, Total_fichas_mias_der, Total_jugadas_der, L2),
   list_sum(L1, L2, Respuesta).

main(Respuesta):-
   otra_mesa(Mesa),
   mis_fichas(Mis_fichas),
   funcion_heuristica(Mesa, Mis_fichas, Respuesta).