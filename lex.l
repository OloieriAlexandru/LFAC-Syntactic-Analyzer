%{                                                    
#include <string.h>
#include <stdlib.h>
#include "yacc.tab.h"
%}
%option yylineno
%%                                                              
"int"|"float"|"char"|"string"|"bool"|"void" 	{ yylval.stringVal = strdup(yytext); return TYPE; }
"main"					{ return MAIN; }
"if"					{ return IF; }
"else"					{ return ELSE; }
"for"					{ return FOR; }
"while"					{ return WHILE; }
"do"					{ return DO; }
"return"				{ return RETURN; }   
"and"|"&&"				{ return AND; }
"or"|"||"				{ return OR; }
"not"|"!"				{ return NOT; }
"defType"				{ return DEFTYPE; }
"func"					{ return FUNC; }
"def"					{ return DEF; }
"object"				{ return OBJECT; }
"const"					{ return CONSTT; }
"eval"					{ return EVAL; }
"->"					{ return ARROW; } 
"{"					{ return O_BRACE; }
"}"					{ return C_BRACE; }
"("					{ return O_PAR; }   
")"					{ return C_PAR; }
"=="					{ return EQUALS; }
"!="					{ return NOT_EQUALS; }
">"					{ return GT; }
">="					{ return GET; }
"<"                     	        { return LT; }
"<="					{ return LET; }
"="					{ return OP_EQUALS; }
"+="					{ return OP_ADDEQ; }
"-="					{ return OP_SUBEQ; }
"*="					{ return OP_MULEQ; }
"/="					{ return OP_DIVEQ; }
"%="					{ return OP_MODEQ; }
"."					{ return DOT; }
";"					{ return SEMICOLON; }
"++"					{ return DADD; }
"--"					{ return DSUB; }
"+"					{ return ADD; }
"-"					{ return SUB; }
"/"					{ return DIV; }
"*"					{ return MUL; }
"%"					{ return MOD; }
"^"					{ return BIT_XOR; }
"&"					{ return BIT_AND; }
"|"					{ return BIT_OR; }
">>"					{ return BIT_SHL; }
"<<"					{ return BIT_SHR; }
","					{ return COMMA; } 
":"					{ return COLON; }  
"["					{ return O_BRACKET; }
"]"					{ return C_BRACKET; }
"$"					{ return DOLLAR; }  
-?[0-9]([0-9]{0,9})\.[0-9]+		{ yylval.floatVal = atof(yytext); return TYPE_NFLOAT; }
"0"|-?[1-9]([0-9]{0,8})			{ yylval.numVal = atoi(yytext); return TYPE_NUM; }
\'.\'					{ yylval.charVal = yytext[1]; return TYPE_CHAR; }
\"([^\"]|\n)*\"				{ yylval.stringVal = new char[yyleng-1]; 
						strncpy(yylval.stringVal, yytext+1, yyleng-2); 
						yylval.stringVal[yyleng-2] = '\0';
						return TYPE_STR; 
					}
"true"|"false"				{ yylval.numVal = (yytext[0] == 't' ? 1 : 0); return TYPE_BOOL; }
[_A-Za-z][_A-Za-z0-9]*			{ yylval.stringVal = strdup(yytext); return ID; }
.|\n					;
%%               
int yywrap() { return 1; }
