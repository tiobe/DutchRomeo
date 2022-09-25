grammar Julia;

@header{package com.tiobe.antlr;}

// Parser

// TODO

// Check in
// Calculate cyclomatic complexity
// Create tokenizer for CPD
// Publish first version 0.1 in Github and remain public for all increments

main
    : functionBody (functionDefinition functionBody)* EOF
    ;

functionDefinition
    : functionDefinition1
    | functionDefinition2
    ;

functionDefinition1
    : FUNCTION IDENTIFIER anyToken*? '(' anyToken*? ')' functionBody END
    ;

functionDefinition2
    : IDENTIFIER '(' anyToken*? ')' whereClause*? '=' functionBody
    ;

whereClause
    : WHERE anyToken*?
    ;

functionBody
    : anyToken*? (statement anyToken*?)*
    ;

statement
    : forStatement
    | ifStatement
    | tryCatchStatement
    | whileStatement
    ;

forStatement
    : FOR functionBody END
;

ifStatement
    : IF functionBody (ELSIF functionBody)* (ELSE functionBody)? END
    ;

tryCatchStatement
    : TRY functionBody (CATCH functionBody)? (FINALLY functionBody)? END
    ;

whileStatement
    : WHILE functionBody END
    ;

anyToken
    : ANY
    | END
    | FOR
    | IDENTIFIER
    | '('
    | ')'
    | '='
    | '&&' // short-circuit
    | '||' // short-circuit
    ;

// Lexer

COMMENTS : '#' ~[\r\n]* -> skip;
MULTILINECOMMENTS : '#=' .*? '=#' -> skip;
MULTILINESTRING : '"""' ('\\"'|.)*? '"""' -> skip;
INDEX : '[' .*? ']' -> skip;
NL : '\r'? '\n' -> skip ;
STRING : '"' ('\\"'|.)*? '"' -> skip;
WHITESPACE : [ \t]+ -> skip ;

CATCH : 'catch' ;
ELSE : 'else' ;
ELSIF : 'elsif' ;
END : 'end' ;
FINALLY : 'finally' ;
FOR : 'for' ;
FUNCTION : 'function' ;
IF : 'if' ;
TRY : 'try' ;
WHERE : 'where' ;
WHILE : 'while' ;

IDENTIFIER : [$a-zA-Z_] [a-zA-Z_0-9]* ;


ANY : . ;




