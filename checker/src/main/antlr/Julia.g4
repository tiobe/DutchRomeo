grammar Julia;

@header{package com.tiobe.antlr;}

// Parser

// TODO

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
    : FUNCTION IDENTIFIER? anyToken*? '(' anyToken*? ')'  whereClause*? functionBody END
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
    : forIfStatement
    | forStatement
    | functionDefinition1
    | ifStatement
    | tryCatchStatement
    | whileStatement
    ;

forIfStatement
   : FOR anyToken*? IF anyToken*?
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
    | WHERE
    | '('
    | ')'
    | '='
    | '&&' // short-circuit
    | '||' // short-circuit
    | '==' // to disambiguate from "="
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




