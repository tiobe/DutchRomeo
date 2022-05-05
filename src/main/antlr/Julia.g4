grammar Julia;

@header{package com.tiobe.antlr;}

// Parser

// TODO

// Create a build and test environment for Julia based on Julia.g4 file similar to Gherkin but may be for the new Github environment as a test
// Automate running all Julia files from existing ASML test set (Python script)
// Make counter to check what percentage files failed (exclude files with @ parse errors)
// Parse 25% 65% 85% 95% 100% of all files correctly
// Publish first version 0.1 in Github and remain public for all increments
// Calculate cyclomatic complexity
// Create tokenizer for CPD
// Create Julia preprocessor
// Make sure preprocessor is run before Julia checker is run

main
    : STRING? (MODULE identifier)? interfaceStatement* languageElement* END? EOF
    ;

interfaceStatement
    : exportStatement
    | importStatement
    | usingStatement
    ;

exportStatement
    : EXPORT identifierList
    ;

importStatement
    : IMPORT identifier (':' identifierList)?
    ;

usingStatement
    : USING identifier (',' identifier)*
    ;

languageElement
    : declaration
    | statement
    ;

declaration
    : abstractType
    | functionDefinition1
    | functionDefinition2
    | struct
    ;

abstractType
    : ABSTRACT TYPE typeArgument END
    ;

functionDefinition2
    : CONST? identifier ('.' identifier)* argumentList? index* whereStatement? '=' expression template? argumentList?
    ;

struct
    : MUTABLE? STRUCT identifier template? structBody END
    ;

structBody
    : structElement+
    ;

structElement
    : field
    | functionDefinition1
    ;

field
    : identifier '::' identifier
    ;

functionDefinition1
    : FUNCTION identifier ('.' identifier)? '!'? templateQualifier? argumentList ('::' identifier)? whereStatement? statement* END
    ;

whereStatement
    : WHERE templateExpression
    ;

templateExpression
    : template
    | typeArgument
    ;

templateQualifier
    : '(' '::' identifier '{' identifier template '}' ')'
    ;

statement
    : assignment
    | expression
    | forStatement
    | returnStatement
    | tryCatchStatement
    ;

assignment
    : identifierList '=' expression
    ;

forStatement
    : FOR identifierList IN expression (: expression)? statement+ END
    ;

returnStatement
    : RETURN expression?
    ;

tryCatchStatement
    : 'try' statement* 'catch' statement* 'end'
    ;

expression
    : replaceExpression
    | expression2
    ;

replaceExpression
    : expression2 '=>' expression
    ;

expression2
    : orExpression
    | expression3
    ;

orExpression
    : expression3 '||' expression
    ;

expression3
    : andExpression
    | expression4
    ;

andExpression
    : expression4 '&&' expression
    ;

expression4
    : equalExpression
    | expression5
    ;

equalExpression
    : expression5 ('==' | '!=') expression
    ;

expression5
    : additionExpression
    | expression6
    ;

additionExpression
    : expression6 ('+' | '-') expression
    ;

expression6
    : multiplicationExpression
    | expression7
    ;

multiplicationExpression
    : expression7 ('*' | '/') expression
    ;

expression7
    : functionCall
    | ifStatement
    | lambdaExpression
    | listExpression
    | negativeExpression
    | notExpression
    | NUMERICAL
    | parenthesizedExpression
    | primaryExpression
    | STRING
    ;

functionCall
    : identifier ('.' identifier)* ('!' | '*')? template? '(' expressionList? keywordExpressionList? ','? ')' (doStatement)?
    ;

doStatement
    : DO expressionList statement* END
    ;

template
    : '{' templateList '}'
    ;

templateList
    : typeArgument  ( ',' typeArgument)*
    ;

typeArgument
    : identifier? '<:'? identifier ('.' identifier)* template?
    ;

expressionList
    : expression ('=' expression)? ( ',' expressionList )?
    ;

keywordExpressionList
    : ';' expressionList
    ;

argumentList
    : '(' identifierList? keywordArgumentList? ')'
    ;

keywordArgumentList
    : ';' identifierList
    ;

ifStatement
    : IF expression statement+ elseStatement? END
    ;

elseStatement
    : ELSE statement+
    ;

lambdaExpression
    : identifier '->' expression
    ;

listExpression
    : '[' ( expression ','?)* ']'
    ;

negativeExpression
    : '-' expression
    ;

notExpression
    : '!' expression
    ;

parenthesizedExpression
    : '(' expressionList ')'
    ;

primaryExpression
    : primaryExpressionElement ('.' primaryElement)* template? '...'?
    ;

primaryExpressionElement
    : normalPrimaryExpression
    | scopedPrimaryExpression
    ;

normalPrimaryExpression
    : primaryElement ('::' primaryElement)*
    ;

scopedPrimaryExpression
    : ('::' primaryElement)+
    ;

primaryElement
    : identifier index*
    ;

index
    : '[' expression? ']'
    ;

identifierList
    : identifierListElement (',' identifierListElement)*
    ;

identifierListElement
    : primaryExpression ('=' primaryExpression)?
    ;

// we have to able to parse keywords as identifiers (add new ones if encountered)
identifier
    : IDENTIFIER
    | END
    | TYPE
    ;

// Lexer

COMMENTS : '#' ~[\r\n]* -> skip;
MULTILINECOMMENTS : '#=' .*? '=#' -> skip;

ABSTRACT : 'abstract' ;
CONST : 'const' ;
DO : 'do' ;
ELSE : 'else' ;
END : 'end' ;
EXPORT : 'export' ;
FOR : 'for' ;
FUNCTION : 'function' ;
IF : 'if' ;
IMPORT : 'import' ;
IN : 'in' ;
INCLUDE : 'include' ;
MODULE : 'module' ;
MUTABLE : 'mutable' ;
RETURN : 'return' ;
STRUCT : 'struct' ;
TYPE : 'type' ;
USING : 'using' ;
WHERE : 'where' ;

IDENTIFIER : [:a-zA-Z_] [a-zA-Z_0-9]* ;
NUMERICAL : [0-9]+ ('.' [0-9]+)? ('e' '-'? [0-9]+)? ;
STRING : '"' .*? '"' | '"""' .*? '"""';

NL : '\r'? '\n' -> skip ;
WHITESPACE : [ \t]+ -> skip ;