:- dynamic resID/2.
resID(_,0).

/* init:- inits the environment for simplification rules*/
init:-
	consult("simplification.rules"),
	consult("reply.rules").	

/* pontuações */
pontos(X) :-
	X = '!';
	X = '?';
	X = '.';
	X = '\'';
	X = '/'.

/* simplify(+In,-Out):- removes unnecessary characters eg. "," and "." 
 	and simplify words*/
simplify(In, Out):-
	exclude(pontos, In, Out1),			% apaga as pontuações da lista de substrings
	findSynonyms(Out1,Out2),
	Out = Out2.

/* findSynonyms(+Words, -Synonyms) :- finds synonyms using
 	simplification rules (loaded by init function) */
findSynonyms(Words, Syn) :-
	sr(Words, Syn, RestWords, ResOutput),!,
	findSynonyms(RestWords, ResOutput).
findSynonyms([Word| ResWords], [Word| ResSyn]):-
	findSynonyms(ResWords, ResSyn),!.
findSynonyms([], []).

/* findReply(+Words, -Reply) :- finds reply with highest rank
 	(loaded by init function) */
findReply(Words, Reply) :-
	findReply2(Words, -2, 0, [], ID, Reply),
	ID \= 0,
	updateResID(ID).

/* findReply2(+Words, +ActScore, +ActRuleID, +ActRes, -RuleID, -Res):- finds reply using two
	accumulators */
findReply2([H|T], ActScore, _, _, ID, Res):-
	findall(Score,rules(_, Score,[H|T],_),Rules),
	Rules \= [], 		% bagof doesnt work as I except
	max_list(Rules,NewScore),
	ActScore < NewScore,
	rules(NewID, NewScore,[H|T],Replyes),
	resID(NewID,ResID),
	nth0(ResID,Replyes,NewReply),
	findReply2(T, NewScore, NewID, NewReply, ID, Res),!.
findReply2([_|T], ActScore, ActID, ActRes, ID, Res):-
	findReply2(T, ActScore, ActID, ActRes, ID, Res).
findReply2([], _, ID, Res, ID, Res).

/* updateResID(+ID):- moves to next reply for rule */
updateResID(ID):-
	resID(ID,RID),
	once(rules(ID,_,_,Replyes)),
	length(Replyes, Len),
	NRID is (RID + 1) mod Len,
	retract((resID(ID,RID):-!)),
	asserta(resID(ID,NRID):-!),!.
updateResID(ID):-
	resID(ID,RID),
	once(rules(ID,_,_,Replyes)),
	length(Replyes, Len),
	NRID is (RID + 1) mod Len,
	asserta(resID(ID,NRID):-!).


/* Função principal */

rotom:-
	init,
	write("- Olá! Eu sou o Rotom. Como posso ajudar você?"), nl,
	rotom([hi]).

rotom([quit|_]):-!.
rotom(_):-
	write("+ "), readln(Line),				% lê a string como uma lista de substrings
	simplify(Line, Words),
	findReply(Words,Reply),
	atomics_to_string(Reply, ' ', String),	% transforma a lista de volta em string
	write("- "), write(String), nl,
	rotom(Words).

