:- use_module(library(lists)).
:- use_module(library(clpfd)).
:-dynamic mesa/1.
:-dynamic mis_fichas/1.

% Programa realizado por Javier Nieto Merodio, Israel Cabrera Portillo y
% Mariano Alcaraz Aguilar.

/****************************************************************************/

%PROYECTO DE PROGAMACIÓN # 2: Sistema capaz de jugar dominó.

% Este programa consiste en un sistema que, empleando el algoritmo minimax
% con Poda Alfa-Beta y su respectiva función heurísitca, es capaz de jugar 
% bien al dominó en el mejor de tres partidas, sumando 1 punto por empate,
% 3 puntos por victoria y 0 puntos por derrota. 

%Organización del código.

% El código está dividido en tres secciones principales: 
%     1. Manual de uso.
%     2. Sistema que juega dominó.
%     3. Función heurísitca.
%     4. Algoritmo minimax con poda alfa-beta.

/****************************************************************************/

%1. Manual de uso.

% Para empezar a jugar, se ejecuta la línea de código:
%  
%        iniciar_juego. 
% 
% En el primer  turno, se pide al usuario que cargue una lista de sus fichas.
% Ahora, las fichas como tal son listas de PROLOG. Por ejemplo, si se roba 
% la ficha 3,2 se escribe:
% 
%        [3,2].
%
% Y tanto el tablero como la lista de las fichas del usuario, son listas de 
% fichas. Entonces, cuando en el inicio de la ronda se piden las fichas, se 
% hace de la siguiente manera:
%
%        [[1,2],[3,4],[6,6],[5,1],[0,0],[1,1]].
%
% A partir de la carga de la lista de fichas obtenidas en el inicio, todo 
% es bastante intuitivo. El sistema hace una serie de preguntas por turno.
% Primero, en el inicio de la primera ronda, o una ronda posterior a un 
% empate, se pregunta quién inició la ronda. Si es el rival, se pide la ficha 
% en con la que inició.  Luego, si juega el rival (y cuando sea el caso), 
% pregunta si jugó una ficha, qué ficha jugó, si robó fichas y cuántas, y en 
% dado caso si pasó de turno. Por último, en el turno del usuario, si tiene
% que robar una ficha pregunta cuál es. 

/****************************************************************************/

%2. Sistema que juega dominó.

% En esta primera parte del sistema, se muestran las reglas y condiciones 
% necesarias para que se pueda jugar dominó. Empleando únicamente este 
% segmento del código, se podría jugar dominó indicando qué ficha se quiere 
% jugar. 

%Iniciar juego
% Función de la primera ronda de la partida. No se reciben argumentos para 
% facilitar la llamada a una función main para iniciar el juego.

iniciar_juego:-
    write("Bienvenido al juego. Suerte."),
    nl,
    write("Dame la lista de tus fichas."),
    nl,
    read([Head_mis_fichas|Tail_mis_fichas]), % Recibe las fichas.
    nl,
    nl,
    inicio_juego([Head_mis_fichas|Tail_mis_fichas], 0,0,1).
    % Como es la primera ronda, inicia en ronda 1 y sin puntos ganados.


%Inicio_juego
% Pregunta quién inició la ronda para poder seguir. Se llama cuando es la
% primera ronda y cuando hay un empate. Recibe como inputs las fichas del 
% usuario, los puntos acumulados por jugador y la ronda.
inicio_juego([Head_mis_fichas|Tail_mis_fichas], PuntosU, PuntosR, Ronda):-
    write("¿Quien inicio el juego? Rival (rival) o Usuario (usuario)"),
    nl,
    read(Turno_uno),
    nl,
    nl,
    inicio_juego_2(Turno_uno, [Head_mis_fichas|Tail_mis_fichas], PuntosU, PuntosR, Ronda).

%Inicio juego 2
% Luego de preguntar en inicio_juego quién jugó la primera ficha, si es el 
% rival, se registra su ficha y se actualiza su número de fichas para iniciar
% función recursiva del resto de la partida.
inicio_juego_2(Turno_1, [MFH|MFT], PuntosU, PuntosR, Ronda):-
    Turno_1 == rival,
    write("¿Que ficha jugo el rival? "),
    nl,
    read([FH|FT]),
    nl,
    nl,
    jugar([MFH|MFT], 1, [[FH|FT]], 6, 14, 1, 0, PuntosU, PuntosR, Ronda).

% Si es el usuario el que juega primero, borra de sus fichas la ficha jugada 
% y llama a la función recursiva jugar actualizada.
inicio_juego_2(Turno_1, [MFH|MFT], PuntosU, PuntosR, Ronda):-
    Turno_1 == usuario,
    write("¿Con que ficha iniciaste? "),
    nl,
    read([FH|FT]),
    nl,
    delete([MFH|MFT],[FH|FT],Nuevas),
    nl,
    jugar(Nuevas, 2, [[FH|FT]], 7, 14, 1, 0, PuntosU, PuntosR, Ronda).


%Iniciar Ronda
% Función que se ejecuta a partir de terminar la segunda ronda. Esto para 
% tener en cuenta la suma de puntos por ronda y si se ganó, empató o perdió
% la ronda anterior

iniciar_ronda(PuntosU, PuntosR, Empate, Ronda, _):-
    Empate =:= 1, % Caso en el que es un empate 
    Ronda < 4,    % y no ha terminado el juego.
    nl,
    nl,
    write("Inicio de la ronda numero: "),
    write(Ronda),
    nl,
    nl,
    write("Dame la lista de tus fichas."),
    nl,
    read([Head_mis_fichas|Tail_mis_fichas]),
    nl,
    inicio_juego([Head_mis_fichas|Tail_mis_fichas], PuntosU,PuntosR,Ronda). 
    % Como es el mismo caso cuando se empata que con la primera ronda, 
    % se llama a la misma función. 

iniciar_ronda(PuntosU, PuntosR, _, Ronda, Ganador):-
    Ganador =:= 1, % Cuando en la ronda anterior ganó el usuario
    Ronda < 4,     % y no ha terminado el juego.
    nl,
    nl,
    write("Inicio de la ronda numero: "),
    write(Ronda),
    nl,
    nl,
    write("Dame la lista de tus fichas."),
    nl,
    read([MFH|MFT]),
    nl,
    write("¿Con que ficha inicias?"),
    nl,
    read([FH|FT]),
    nl,
    nl,
    delete([MFH|MFT],[FH|FT],Nuevas),
    % Actualiza las fichas del usuario después de insertar.
    jugar(Nuevas, 2, [[FH|FT]], 7, 14, 1, 0, PuntosU, PuntosR, Ronda).
    % Llama a la función jugar para iniciar la función recursiva del resto 
    % de la ronda. 

iniciar_ronda(PuntosU, PuntosR, _, Ronda, Ganador):-
    Ganador =:= 2, % Cuando ganó el rival y
    Ronda < 4,     % el juego sigue en curso.
    nl,
    nl,
    write("Inicio de la ronda numero: "),
    write(Ronda),
    nl,
    nl,
    write("Dame la lista de tus fichas."),
    nl,
    read([MFH|MFT]),
    nl,
    write("¿Que ficha jugo el rival? "),
    nl,
    read([FH|FT]),
    nl,
    nl,
    jugar([MFH|MFT], 1, [[FH|FT]], 6, 14, 1, 0, PuntosU, PuntosR, Ronda).
    % Se llama a la función jugar.

iniciar_ronda(PuntosU, PuntosR, _, Ronda, _):-
    Ronda =:= 4, % Caso en el que ya se jugaron las 3 rondas.
    nl,
    nl,
    write("Fin del juego."),
    nl,
    write("Puntos finales del usuario: "),
    write(PuntosU),
    nl,
    write("Puntos finales del rival: "),
    write(PuntosR),
    nl,
    ganador_final(PuntosU, PuntosR). % Llama a la función para imprimir
                                     % el ganador.

%Función jugar.
% Se encarga del tunrno 2 hasta el último de cada ronda. Recibe como argumentos:
% las fichas del usuario, de quién es el turno (1 es el usuario, 2 el rival), 
% el tablero, el número de fichas del rival, número de fichas en el pozo, 
% valor que comprueba si es el final de la ronda (1 si no es, 0 si es), número
% de rondas pasadas seguidas, y los puntos por ususario y rival tanto como la 
% ronda que está en curso. 

% Cuando juega el usuario, puede robar, no ha terminado el juego, y tiene
% una ficha que puede jugar.
jugar([Mis_fichasH|Mis_fichasT], Turno, [Tablero_H|Tablero_T], Rival, Pozo, Fin, _, PuntosU, PuntosR, Ronda):-
    Fin =:= 1,
    Turno =:= 1,
    Pozo > 0,
    puedo([Mis_fichasH|Mis_fichasT], [Tablero_H|Tablero_T]), % Comprueba que 
    write("Turno del usuario."),                             % se pueda jugar.
    nl,
    write("¿Que ficha quieres jugar?:"),
    calculo_minimax([Tablero_H|Tablero_T],[Mis_fichasH|Mis_fichasT], Res),
    write(" --> La Inteligencia Artificial va a jugar la ficha: "),
    write(Res),
    nl,
    jugar_ficha([Mis_fichasH|Mis_fichasT], Res, [Tablero_H|Tablero_T], Nuevot),
    nl,
    borrar_ficha(Res, [Mis_fichasH|Mis_fichasT], MisFichas),
    nl,
    write("Tus fichas al final del turno: "),
    nl,
    write(MisFichas),
    nl,
    nl,
    write("Tablero al final del turno: "),
    nl,
    write(Nuevot),
    nl,
    nl,
    length(MisFichas,LMF), 
    fin_juego(0, Rival, LMF, Final), % Evalúa si el valor actual de Fin.
    jugar(MisFichas, 2, Nuevot, Rival, Pozo, Final, 0, PuntosU, PuntosR, Ronda).

% Juego en curso, usuario no puede robar ni jugar. Pasa de turno.
jugar([Mis_fichasH|Mis_fichasT], Turno, [Tablero_H|Tablero_T], Rival, Pozo, Fin, Pasadas, PuntosU, PuntosR, Ronda):-
    Fin =:= 1,
    Turno =:= 1,
    Pozo =:= 0,
    no_puedo([Mis_fichasH|Mis_fichasT], [Tablero_H|Tablero_T]),
    write("Turno del usuario."),
    nl,
    write("No puedes jugar ninguna ficha y no hay fichas que robar."),
    nl,
    write("Pasas de turno"),
    nl,
    nl,
    write("Tus fichas al final del turno: "),
    nl,
    write([Mis_fichasH|Mis_fichasT]),
    nl,
    nl,
    write("Tablero al final del turno: "),
    nl,
    write([Tablero_H|Tablero_T]),
    nl,
    nl,
    length([Mis_fichasH|Mis_fichasT],LMF),
    FinPasadas is Pasadas + 1, % En este caso, solo se suma al valor anterior 
                               % de pasadas, pues al llamar esta función siempre
                               % pasa el usuario.
    fin_juego(FinPasadas, Rival, LMF, Final),
    jugar([Mis_fichasH|Mis_fichasT], 2, [Tablero_H|Tablero_T], Rival, Pozo, Final, FinPasadas, PuntosU, PuntosR, Ronda).

% Juego en curso, usuario no puede jugar y debe robar. Si toma una ficha y no
% puede jugarla, se vuelve a llamar a esta misma instancia hasta que se pueda 
% jugar una o se llegue al caso anterior de tener que pasar.
jugar([Mis_fichasH|Mis_fichasT], Turno, [Tablero_H|Tablero_T], Rival, Pozo, Fin, Pasadas, PuntosU, PuntosR, Ronda):-
    Fin =:= 1,
    Turno =:= 1,
    Pozo > 0,
    no_puedo([Mis_fichasH|Mis_fichasT], [Tablero_H|Tablero_T]),
    write("Turno del usuario."),
    nl,
    write("No puedes jugar ninguna ficha."),
    nl,
    nl,
    write("¿Que ficha robaste?"),
    nl,
    read(FichaRob),
    nl,
    nl,
    append([FichaRob],[Mis_fichasH|Mis_fichasT],NuevasMisF), % Nueva lista de mis fichas
    PozoFin is Pozo - 1, % Sé que robo exactamente una ficha.
    jugar(NuevasMisF, 1, [Tablero_H|Tablero_T], Rival, PozoFin, Fin, Pasadas, PuntosU, PuntosR, Ronda).

% A partir de aquí, la función jugar se encarga de los turnos del rival
% Juega el rival, y puede robar fichas, jugar fichas, y pasar. 
jugar(MisFichas, Turno, Tablero, Rival, Pozo, Fin, Pasadas, PuntosU, PuntosR, Ronda):-
    Fin =:= 1,
    Turno =:= 2,
    Pozo > 0,
    write("Turno del rival."),
    nl,
    write("¿El rival robo fichas? Si(si) o No(no)"),
    nl,
    read(Robo), % Lee si robó fichas o no
    nl,
    robo_rival(Robo, Robadas), % En caso de haber robado, esta función lee cuántas.
    nl,
    write("¿Jugo alguna ficha el rival? Si(si) o No(no)"),
    nl,
    read(Jugada),
    nl,
    juego_pasa_rival(Jugada, Tablero, Nuevot), % Si jugó una ficha, lee
    jugoc(Jugada,Jugadas),                     % cual y regresa el tablero nuevo.
    nl,
    write("El rival se queda con : "),
    FinRondaRival is Rival + Robadas - Jugadas, % Actualiza fichas del rival.
    write(FinRondaRival),
    write(" fichas."),
    nl,
    nl,
    write("Tablero al final del turno: "),
    nl,
    write(Nuevot),
    nl,
    nl,
    length(MisFichas,LMF),
    pasadas_r(Pasadas,Jugada,FinPasadas), % Evalúa cuantas lleva pasadas seguidas el juego.
    fin_juego(FinPasadas, FinRondaRival, LMF, Final),
    FinPozo is Pozo - Robadas, % Actualiza las fichas robadas para seguir recursivamente.
    jugar(MisFichas, 1, Nuevot, FinRondaRival, FinPozo, Final, FinPasadas, PuntosU, PuntosR, Ronda).

% Juega el rival, y no puede robar fichas. Ahora solo puede jugar o pasar.
jugar(MisFichas, Turno, Tablero, Rival, Pozo, Fin, Pasadas, PuntosU, PuntosR, Ronda):-
    Fin =:= 1,
    Turno =:= 2,
    Pozo =:= 0, % Notemos no se admiten errores de pozo con un número negativo 
    write("¿Jugo alguna ficha el rival? Si(si) o No(no)"), % de fichas.
    nl,
    read(Jugada), % Misma intuición que el caso anterior.
    nl,
    juego_pasa_rival(Jugada, Tablero, Nuevot),
    jugoc(Jugada,Jugadas),
    nl,
    write("El rival se queda con: "),
    FinRondaRival is Rival - Jugadas,
    write(FinRondaRival),
    write(" fichas."),
    nl,
    nl,
    write("Tablero al final del turno: "),
    nl,
    write(Nuevot),
    nl,
    nl,
    length(MisFichas,LMF),
    pasadas_r(Pasadas, Jugada,FinPasadas),
    fin_juego(FinPasadas, FinRondaRival, LMF, Final),
    jugar(MisFichas, 1, Nuevot, FinRondaRival, Pozo, Final, FinPasadas, PuntosU, PuntosR, Ronda).

% Esta última instancia evalúa y da resultados del final de ronda. También,
% llama a la función jugar_ronda para continuar con las siguientes rondas, 
% actualizando los puntos, si se empató, y el número de ronda siguiente.
jugar(MisF, _, Tablero, Rival, Pozo, Fin, _, PuntosU, PuntosR, Ronda):-
    Fin =:= 0,
    write("Fin de la ronda."),
    length(MisF,X),
    nl,
    nl,
    eval_ganador(X, Rival, PuntajeUsuarioN, PuntajeRivalN, Empate), % Imprime
    nl,nl,                                                          % ganador.
    write("Resultados finales de la ronda: "),
    nl,nl,
    write("Tablero final: "),
    write(Tablero),
    nl,
    write("Tus fichas: "),
    write(MisF),
    nl,
    write("El rival se quedo con "),
    write(Rival),
    write(" fichas."),
    nl,
    write("El pozo se quedo con "),
    write(Pozo),
    write(" fichas."),
    nl,
    nl,
    FinU is PuntosU + PuntajeUsuarioN,
    FinR is PuntosR + PuntajeRivalN,
    RondaF is Ronda + 1,
    ganador(PuntajeUsuarioN, PuntajeRivalN, Ganador), % Para saber quién inicia la ronda.
    iniciar_ronda(FinU,FinR,Empate,RondaF, Ganador).

%Función robo_rival
% Evalúa, si robó el rival, cuántas robó. Si no robó, marca 0.
% Recibe el input de si robó o no, regresa las robadas.
robo_rival(Robo, Robadas):-
    Robo == si,
    write("¿Cuantas fichas robo el rival?"),
    nl,
    read(InputRob),
    nl,
    Robadas is InputRob.

robo_rival(Robo, Robadas):-
    Robo == no,
    Robadas is 0.

%Juego pasa Rival
% Si el rival jugó una ficha, recibe cuál es, comprueba si se puede jugar,
% y actualiza el tablero con la funcioón colcar. Recibe si jugó o no, el
% tablero, y regresa el tablero actualizado.
juego_pasa_rival(Jugada, Tablero, Nuevo_tablero):-
    Jugada == si,
    write("¿Que ficha jugo el rival?"),
    nl,
    read(Resp),
    nl,
    puedo([Resp], Tablero),
    get_head(Tablero,[A|_]),
    get_tail(Tablero,[_|D]),
    donde_colocar(Resp, [A|D], Pos),
    colocar(Resp, Tablero, Pos, Nuevo_tablero).
    % Se da la variable Nuevo_Tablero para que esa sea la que se regrese
    % en la llamada a la función juego pasa rival.

% Si no jugó una ficha, queda igual el tablero.
juego_pasa_rival(Jugada,Tablero,Tablero):-
    Jugada == no.

% Si pasa el rival, marca 1. Si no pasa, marca 0. Esto para poder sumarse
% a las pasadas en general. Recibe el valor de si jugó una ficha o no el rival.
pasa(Jugada,Y):-
    Jugada == si,
    Y is 0.
pasa(Jugada,Y):-
    Jugada == no,
    Y is 1.

% Si jugó una ficha el rival, evalúa 1. Si no, evalúa 0. Se hace esta función
% para poder sumar fácilmente al número de fichas del rival al terminar
% la ronda.
jugoc(Jugada,Z):-
    Jugada == si,
    Z is 1.
jugoc(Jugada,Z):-
    Jugada == no,
    Z is 0.

% Función no puedo
% Evalúa true si la ficha o lista de fichas recibida no puede ser jugada en el 
% tablero recibido.
no_puedo(Misf,Tablero):-
    get_head(Tablero,[A|_]),
    get_tail(Tablero,[_|D]),
    no_puedo_r(Misf,[A|D]).
    % Llama a una funcíon recursiva con las fichas y los extremos del tablero.
 
 no_puedo_r([MFH|MFT],_):-
    length([MFH|MFT], X),
    X=:=0.
    % Caso base. Cuando se recibe una lista vacía no se puede jugar.

no_puedo_r([MFH|MFT],Extremos):-
    length([MFH|MFT], X),
    X>1,
    no_igual(Extremos,MFH),
    no_puedo_r(MFT,Extremos).
    % Caso recursivo. Va haciendo la lista de fichas cada vez más pequeña
    % comprobando ficha por ficha si se puede jugar en alguno de los extremos.

% Cuando llega a la última ficha, la evalúa en particular si no se puede jugar, 
% para terminar regresando si no se puede o si sí.
no_puedo_r(Fichas,Extremos):-
    length(Fichas, X),
    X=:=1,
    get_head(Fichas,Y),
    no_igual(Extremos,Y).


%Funcion puedo
% True si se puede jugar una ficha en un tablero específico. Se hace aparte de 
% la función no_puedo para ahorrar código en el agregado. Con que una ficha se 
% pueda jugar.

puedo(Misf,Tablero):-
    get_head(Tablero,[A|_]),
    get_tail(Tablero,[_|D]),
    puedo_r(Misf,[A|D]).
    % Recibe los extremos del tablero y la lista de fichas.
 
 puedo_r([MFH|MFT],Extremos):-
    length([MFH|MFT], X),
    X>1,
    no_igual(Extremos,MFH),
    puedo_r(MFT,Extremos).
    % Si no es igual la ficha actual, sigue buscando.
 
 puedo_r([MFH|MFT],Extremos):-
    length([MFH|MFT], X),
    X>1,
    igual(Extremos,MFH).
    % Si la ficha actual es igual, termina de buscar y regresa true.
 
 puedo_r(Fichas,Extremos):-
    length(Fichas, X),
    X=:=1,
    get_head(Fichas,Y),
    igual(Extremos,Y).
    % Cuando queda una ficha, evalúa si es igual o no.
 
 puedo_r(Mis_fichas,_):-
    length(Mis_fichas, X),
    X=:=0,
    1>2. % Para que regrese false en el caso de que se reciba una lista vacía.
    
 % Pequeña función para obtener la cabeza y cola de una lista de forma sencilla.
 get_head([A|_],A).
 get_tail(List,B):-
    reverse(List,ListR),
    get_head(ListR,B).
 
 % Regresa true con que algun valor de la ficha sea igual a algún extremo.
 igual([A|B],[C|D]):-
    A =:= C;
    A =:= D;
    B =:= C;
    B =:= D.
% Regresa true si ningun valor de la ficha es igual a ambos extremos. 
 no_igual([A|B],[C|D]):-
    A =\= C,
    A =\= D,
    B =\= C,
    B =\= D.
 

%Ganador
% Para la transición de ronda y evaluar quien debe tirar primero, regresa
% 1 si el usuario gana, 2 si el rival gana, y 0 si es empate.
ganador(PuntosU, PuntosR, Ganador):-
    PuntosU>PuntosR,
    Ganador is 1.

ganador(PuntosU, PuntosR, Ganador):-
    PuntosU<PuntosR,
    Ganador is 2.
ganador(PuntosU, PuntosR, Ganador):-
    PuntosU=:=PuntosR,
    Ganador is 0.

% Regresa los puntajes y si hay empate. Si es empate da 1, si no 0.
% Si gana el usuario regresa 1, si empatan 0, si pierden 
eval_ganador(NumFich,_,PuntosU, PuntosR, Empate):-
    NumFich =:= 0,
    write("Ganamos la ronda."),
    PuntosU is 3,
    PuntosR is 0,
    Empate is 0.

eval_ganador(_,NumRival, PuntosU, PuntosR, Empate):-
    NumRival =:= 0,
    write("Perdimos la ronda:("),
    PuntosU is 0,
    PuntosR is 3,
    Empate is 0.

eval_ganador(NumFich,NumRival, PuntosU, PuntosR, Empate):-
    NumFich =\=0,
    NumRival =\= 0,
    write("Empatamos la ronda :0"),
    PuntosU is 1,
    PuntosR is 1,
    Empate is 1.

% Imprime de quién es el turno
turno(NumTurn):-
    NumTurn =:= 2,
    write("Es turno del rival.").

turno(NumTurn):-
    NumTurn =:= 1,
    write("Es nuestro turno.").

%Jugar ficha
% Jugar ficha es una función que recibe la ficha seleccionada para jugar,
% las fichas del usuario, el tablero y regresa el tablero actualizado.
% las fichas del usuario se actualizan en la función jugar.
jugar_ficha(MisFichas, Ficha, Tablero, Nuevo_tablero):-
    puedo([Ficha], Tablero), %Pregunta específicamente si puedes jugar dicha ficha. 
    member(Ficha,MisFichas), % Comprueba que sea miembro de las fichas
    get_head(Tablero,[A|_]),
    get_tail(Tablero,[_|D]),
    donde_colocar(Ficha, [A|D], Pos), % Regresa el lado del tablero donde se puede colocar.
    colocar(Ficha, Tablero, Pos, Nuevo_tablero).

jugar_ficha(MisFichas, Ficha, Tablero, Nuevo_tablero):-
    puedo([Ficha], Tablero), 
    reverse(Ficha, FichaR), % En caso de que esté al revés la ficha,
    member(FichaR,MisFichas), % comprueba que esté en la lista de fichas.
    get_head(Tablero,[A|_]),
    get_tail(Tablero,[_|D]),
    donde_colocar(FichaR, [A|D], Pos),
    colocar(FichaR, Tablero, Pos, Nuevo_tablero).
 
 %Colocar 
 % Coloca la ficha del tablero donde corresponde e invierte la ficha en caso 
 % en el que se necesite para poder ser colocada.
 % Si pos es 1, en la cabeza y no se invierte, 2 si es en la cabeza y se invierte*/
 % 3 si es cola y no se invierte, 4 si es cola y se invierte*/
 % 5 si es en ambas y no se invierte, 6 si es en ambas y se invierte*/

 % Las primeras 4 colocan la ficha en la cabeza del tablero.
 colocar([A|B],Tablero, Pos, NuevoTab):-
    Pos =:=1,
    invertir_ficha([A|B],Pos,Ficha),
    append([Ficha],Tablero,NuevoTab).

colocar([A|B],Tablero, Pos, NuevoTab):-
    Pos =:=2,
    invertir_ficha([A|B],Pos,Ficha),
    append([Ficha],Tablero,NuevoTab).

colocar([A|B],Tablero, Pos, NuevoTab):-
    Pos=:=5,
    invertir_ficha([A|B],Pos,Ficha),
    append([Ficha],Tablero,NuevoTab).

colocar([A|B],Tablero, Pos, NuevoTab):-
    Pos=:=6,
    invertir_ficha([A|B],Pos,Ficha),
    append([Ficha],Tablero,NuevoTab).
% Las últimas 2 colocan la ficha en la cola del tablero 
colocar([A|B],Tablero, Pos, NuevoTab):-
    Pos =:=3,
    invertir_ficha([A|B],Pos,Ficha),
    append(Tablero,[Ficha],NuevoTab).

colocar([A|B],Tablero, Pos, NuevoTab):-
    Pos =:=4,
    invertir_ficha([A|B],Pos,Ficha),
    append(Tablero,[Ficha],NuevoTab).
 
% Función sencilla para invertir una ficha usando auxiliares de prolog.
 invertir_ficha(Ficha,Pos,Nueva):-
    par(Pos),
    reverse(Ficha,Nueva).
 invertir_ficha(Ficha, _,Ficha).
 
% De acuerdo a la ficha y los extremos, regresa qué caso de colocación se maneja.
% En cabeza y no se invierte
 donde_colocar(Ficha, Extremos, Pos):-
    b_c(Ficha,Extremos),
    Pos is 1.
 
% En cabeza y se invierte*/
 donde_colocar(Ficha, Extremos, Pos):-
    a_c(Ficha,Extremos),
    Pos is 2.
 
% En cola y no se invierte*/
 donde_colocar(Ficha, Extremos, Pos):-
    a_d(Ficha,Extremos),
    Pos is 3.
 
% En cola y se invierte*/
 donde_colocar(Ficha, Extremos, Pos):-
    b_d(Ficha,Extremos),
    Pos is 4.
 
% FORMA [B,A],[A,B]*/
 donde_colocar(Ficha,Extremos,Pos):-
    a_d(Ficha,Extremos),
    b_c(Ficha, Extremos),
    Pos is 5.
 
% FORMA [A,B],[A,B] INVIERTE*/
 donde_colocar(Ficha,Extremos,Pos):-
    a_c(Ficha,Extremos),
    b_d(Ficha, Extremos),
    Pos is 6.
 
% Revisa qué caso es: si el lado izquierdo o derecho de la ficha son iguales
% a los lados izquierdo o derecho.
 a_d([A|_], [_|D]):-
    A=:=D.
 
 b_c([_|B], [C|_]):-
    B=:=C.
 
 b_d([_|B], [_|D]):-
    B=:=D.
 
 a_c([A|_], [C|_]):-
    A=:=C.
    
 % Simplemente revisa si un número es par.
 par(N):-
    mod(N,2) =:= 0.

%Borrar ficha.
% Actualiza las fichas con la ficha jugada, invirtiendo la ficha en caso necesario.
borrar_ficha(Ficha, Viejas, Nuevas):-
    member(Ficha,Viejas),
    delete(Viejas,Ficha,Nuevas).

borrar_ficha(Ficha, Viejas, Nuevas):-
    reverse(Ficha, FichaR),
    member(FichaR,Viejas),
    delete(Viejas, FichaR, Nuevas).

%Fin juego
% Regresa 0 si ya se acabó el juego, 1 si sigue en curso. Evalúa si el número
% de pasadas seguidas es 2, si el rival ya no tiene fichas o si el jugador no tiene.
% No importa quién haya ganado.

fin_juego(Pasadas, _, _, Fin):-
    Pasadas =:=2,
    Fin is 0.

fin_juego(_, Rival, _, Fin):-
    Rival =:= 0,
    Fin is 0.

fin_juego(_, _, LenMisFichas, Fin):-
    LenMisFichas =:=0,
    Fin is 0.

fin_juego(Pasadas, Rival, LenMisFichas, Fin):-
    LenMisFichas =\=0,
    Rival =\= 0,
    Pasadas =\=2,
    Fin is 1.
%Ganador final
% Simplemente imprime los ganadores del final de las tres rondas comparando los puntos.
% También maneja el raro caso de un empate en suma de puntos.
ganador_final(PuntosU,PuntosR):-
    PuntosU > PuntosR,
    write("Somos los ganadores del juego.").

ganador_final(PuntosU,PuntosR):-
    PuntosU < PuntosR,
    write("Perdimos el juego :,(").

ganador_final(PuntosU,PuntosR):-
    PuntosU =:= PuntosR,
    write("El resultado final es un empate.").

% Función que evalúa si se han pasado dos veces seguidas o no.
% Si se jugó una en ese turno, se reinicia a 0.
pasadas_r(PasadasAnt, Jugada, Res):-
    Jugada == no,
    PasadasAnt =:=1,
    Res is 2.

pasadas_r(_, Jugada, Res):-
    Jugada == si,
    Res is 0.
pasadas_r(PasadasAnt,Jugada, Res):-
    Jugada == no,
    PasadasAnt =:= 0,
    Res is 1.

/****************************************************************************/

%3. Función heurística.


% El método recibe los siguientes parámetros: list_sum(input, input, output)
% Esta función recibe dos listas de números y suma los valores entrada a entrada. 
% Regresa el resultado en otra lista.

list_sum([], [], []).
list_sum([H1|T1],[H2|T2],[X|L3]):-
   list_sum(T1,T2,L3), 
   X is H1+H2.



% La función numeros_extremos funge como auxiliar: numeros_extremos(input, output1, output2)
% Esta funcion recibe una lista de listas que normalmente será la mesa.
% Regresa los extremos de la mesa para saber qué valores se pueden jugar siguiente.

numeros_extremos([[H1,_]|T], Extremo_izq, Extremo_der):-
   Extremo_izq = H1,
   last([_|T], X),
   last(X,Extremo_der).

 


% La funcion numeros en ficha recibe una lista de listas que normalmente serán mis fichas.
% Sobre ella itera para saber si tenemos valores en la otra cara de la ficha regresa los valores.
% dame_numeros convierte los resultados en una lista para que sea más fácil trabajar con ellos

numeros_en_ficha(Mis_fichas, Numero_que_tengo, Otros_numeros):-
   member([Numero_que_tengo, Otros_numeros], Mis_fichas).

numeros_en_ficha(Mis_fichas, Numero_que_tengo, Otros_numeros):-
   member([Otros_numeros, Numero_que_tengo], Mis_fichas).

dame_numeros(Mis_fichas, Numero_que_tengo, Lista):-
   findall(Y, numeros_en_ficha(Mis_fichas, Numero_que_tengo, Y), Lista).



% Esta funcion revisa si hay mulas en una lista de listas.
% Recibe fichas y el número que se busca

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

% La funcion fichas_jugadas recibe las fichas de la mesa y las nuestras y regresa una lista donde junta ambas
% La funcion total_jugadas \3 recibe una lista de fichas, un número buscado, y el total de fichas que tienen ese número
% La funcion total_jugadas \4 recibe dos lstas de fichas que son después juntadas y llama a total_jugadas \3 con esa

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


% Suma los valores de las caras de las fichas. Regresa el resultado en una lista.

suma_fichas([], []).
suma_fichas([[N1, N2] | T], [Sum1 | SumR]):-
   suma_fichas(T, SumR),
   Sum1 is N1 + N2.


% La funcion asigna valor recibe una ficha, el numero extremo, el total de fichas que tenemos con ese numero extremo, el total de fichas
% que se han jugado y regresa un valor heurístico para esa ficha
 
% La funcion recorre fichas asignando valor recibe tus fichas, el numero extremo, el total de fichas con ese número, el total de fichas
% que se han jugado y regresa una lista con los valores heurísticos correspondientes a cada ficha

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



%Función_Heurística(input, input, output)
% input 1: Fichas en el tablero
% input 2: Fichas en mi mano
% output: Lista con valores heurísitcos para cada ficha

% Recibe las fichas en la mesa, las fichas que tenemos y regresa una lista del tamaño de mis fichas con el valor
% heurístico correspondiente a cada ficha.

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
   /* Obtenemos los numeros de los extremos */
   numeros_extremos(Mesa, Valor_izquierdo, Valor_derecho),
   /* Sacamos todas las fichas que se han jugado */
   fichas_jugadas(Mesa, Mis_fichas, Jugadas),
   /* Contamos el numero de fichas que se han jugado con cada extremo */
   total_jugadas(Jugadas, Valor_izquierdo, Total_jugadas_izq),
   total_jugadas(Jugadas, Valor_derecho, Total_jugadas_der),
   /* Obtenemos cuantas fichas tenemos con cada valor extremo */
   dame_numeros(Mis_fichas, Valor_izquierdo, Aux_izq),
   dame_numeros(Mis_fichas, Valor_derecho, Aux_der),
   length(Aux_izq, Total_fichas_mias_izq),
   length(Aux_der, Total_fichas_mias_der),
   /* Ahora recorremos toda nuestra lista */
   recorre_fichas_asignando_valor(Mis_fichas, Valor_izquierdo, Total_fichas_mias_izq, Total_jugadas_izq, L1),
   recorre_fichas_asignando_valor(Mis_fichas, Valor_derecho, Total_fichas_mias_der, Total_jugadas_der, L2),
   list_sum(L1, L2, Respuesta).

/****************************************************************************/

%4. Algoritmo minimax
% La función minimax trata de maximizar nuestras jugadas, por lo tanto va a buscar dentro del arreglo 
% con los pesos resultantes de haber aplicado la función heurística el número o balanceo que permita 
% esa maximización de la jugada, entregandonos como resultado la ficha que se recomienda jugar.
calculo_minimax(Mesa,Mis_fichas,Respuesta):-
    funcion_heuristica(Mesa, Mis_fichas, R),
    zs_maximum_at(R, M, Pos),
    match(Mis_fichas, Pos, Respuesta).

% Predicado auxiliar que ayuda a determinar cuál es el máximo de los pesos dentro del arreglo resultante de la
% función heurística
zs_maximum_at(Zs,Max,Pos) :-
    maplist(#>=(Max),Zs),
    nth0(Pos,Zs,Max).

% Este predicado ayuda a realizar el 'match' adecuado entre el resultado del algoritmo minimax y nuestras fichas para regresar 
% la ficha óptima a jugar
match([H|_],0,H) :-
        !.
match([_|T],N,H) :-
    N > 0,
    N1 is N-1,
    match(T,N1,H).


/****************************************************************************/