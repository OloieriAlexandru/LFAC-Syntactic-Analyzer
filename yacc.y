%{
#include 	<stdio.h>
#include 	<string.h>
#include 	<unordered_map>
#include 	<string>
#include 	<vector>
#include 	<utility>
#include 	<iostream>                             
#define uint 	unsigned int
#define uchar 	unsigned char
#define vector	std::vector
#define string 	std::string
#define pb 	push_back
#define mp 	make_pair
#define umap	std::unordered_map

extern int yylineno;
void yyerror(const char *str) { printf("%s %d\n", str, yylineno); }
int yylex();
%}

%union{
	int 	numVal;
	char*	stringVal;
	char	charVal;
}

%start 	check
%token  MAIN IF FOR WHILE DO RETURN DEFTYPE FUNC DEF ARROW O_BRACE C_BRACE O_PAR C_PAR EQUALS NOT_EQUALS OP_EQUALS OP_ADDEQ OP_SUBEQ DOT SEMICOLON DADD DSUB COMMA COLON O_BRACKET C_BRACKET 
%token  <numVal> TYPE_NUM TYPE_BOOL
%token 	<charVal> TYPE_CHAR
%token 	<stringVal> TYPE_STR TYPE ID
%type 	<numVal> operand arithmetic_expression_1 arithmetic_expression_2 arithmetic_expression_3 arithmetic_expression_4 arithmetic_expression_5 arithmetic_expression_6 arithmetic_expression_term  

%left ADD SUB MUL DIV MOD BIT_XOR BIT_AND BIT_OR BIT_SHL BIT_SHR
%left NOT
%left AND
%left OR
%left EQUALS NOT_EQUALS GT GET LT LET

%%

check					: program				{ printf("Program corect sintactic!\n"); }
					;

program					: definitions main			{ }
					| main					{ }
					;

definitions				: definitions function_declaration	{ }
					| definitions custom_type_declaration	{ }
					| function_declaration			{ }
					| custom_type_declaration		{ }
					;

function_declaration			: function_header instructions_block	{ }
					;

function_header				: FUNC ID O_PAR function_parameters C_PAR ARROW TYPE	{ }
					| FUNC ID O_PAR C_PAR ARROW TYPE 			{ }
					;
          
function_parameters			: function_parameters COMMA function_parameter 		{ }
					| function_parameter					{ }
					;

function_parameter			: TYPE ID						{ }
					| TYPE ID OP_EQUALS TYPE_NUM				{ }
					;

custom_type_declaration			: DEFTYPE ID O_BRACE custom_type_body C_BRACE		{ }
					| DEFTYPE ID O_BRACE C_BRACE				{ }
					;
					
custom_type_body			: custom_type_body custom_type_body_declaration		{ }
					| custom_type_body_declaration				{ }
					;

custom_type_body_declaration		: function_declaration					{ }
					| variables_declaration_full				{ }
					;

main					: MAIN ARROW TYPE instructions_block	{ }
					;
                                                                          
instructions_block			: O_BRACE instructions C_BRACE		{ }
					| O_BRACE C_BRACE			{ }
					;

instructions				: instructions instruction		{ }
					| instruction				{ }
					;

instruction				: instructions_block			{ }
					| variables_declaration_full		{ }
					| if_block				{ }
					| for_loop				{ }
					| while_loop				{ }
					;

if_block				: IF O_PAR logical_expression_1 C_PAR ARROW instructions_block	{ }
					| IF O_PAR  C_PAR ARROW instructions_block			{ }
					; 

for_loop				: FOR O_PAR for_loop_header C_PAR ARROW instructions_block	{ }
					;

for_loop_header				: variables_declaration SEMICOLON logical_expression_1 SEMICOLON variables_operations	{ }
					;

while_loop				: WHILE O_PAR logical_expression_1 C_PAR ARROW instructions_block	{ }
					| WHILE O_PAR C_PAR ARROW instructions_block				{ }
					;

variables_declaration_full		: variables_declaration SEMICOLON			{ }
					;

variables_declaration			: DEF variables_declaration_list ARROW TYPE 		{ }
					;

variables_declaration_list		: variables_declaration_list variable_declaration	{ }
					| variable_declaration					{ }
					;

variable_declaration			: ID					{ }
					| ID O_BRACKET TYPE_NUM C_BRACKET	{ }
					| ID OP_EQUALS arithmetic_expression_1	{ }
					;

variables_operations			: variables_operations COMMA variable_operation	{ }
					| variable_operation				{ }
					;

variable_operation			: variable_operation_operand OP_EQUALS arithmetic_expression_1 	{ }
					| variable_operation_operand OP_ADDEQ arithmetic_expression_1 	{ }
					| variable_operation_operand OP_SUBEQ arithmetic_expression_1 	{ }
					| DADD variable_operation_operand 	 			{ }
					| DSUB variable_operation_operand 	 			{ }
					| variable_operation_operand DADD 	 			{ }
					| variable_operation_operand DSUB	 			{ }
					;

variable_operation_operand		: ID					{ }
					| ID O_BRACKET TYPE_NUM C_BRACKET	{ }
					;

arithmetic_expression_1				: arithmetic_expression_1 BIT_OR arithmetic_expression_2        {$$ = $1 | $3;}
						| arithmetic_expression_2                                       {$$ = $1;}
						;

arithmetic_expression_2				: arithmetic_expression_2 BIT_XOR arithmetic_expression_3       {$$ = $1 ^ $3;}
						| arithmetic_expression_3                                       {$$ = $1;}
						;

arithmetic_expression_3				: arithmetic_expression_3 BIT_AND arithmetic_expression_4       {$$ = $1 & $3;}
						| arithmetic_expression_4                                       {$$ = $1;}
						;

arithmetic_expression_4				: arithmetic_expression_4 BIT_SHL arithmetic_expression_5       {$$ = $1 << $3;}
						| arithmetic_expression_4 BIT_SHR arithmetic_expression_5       {$$ = $1 >> $3;}
						| arithmetic_expression_5                                       {$$ = $1;}
						;

arithmetic_expression_5				: arithmetic_expression_5 ADD arithmetic_expression_6           {$$ = $1 + $3;}
						| arithmetic_expression_5 SUB arithmetic_expression_6           {$$ = $1 - $3;}
						| arithmetic_expression_6                                       {$$ = $1;}
						;

arithmetic_expression_6				: arithmetic_expression_6 MUL arithmetic_expression_term        {$$ = $1 * $3;}
						| arithmetic_expression_6 DIV arithmetic_expression_term        {$$ = $1 / $3;}
						| arithmetic_expression_6 MOD arithmetic_expression_term        {$$ = $1 % $3;}
						| arithmetic_expression_term                                    {$$ = $1;}
						;

arithmetic_expression_term			: O_PAR arithmetic_expression_1 C_PAR				{$$ = $2;}
						| operand                                                       {$$ = $1;}
						;
                                                                                 
operand						: TYPE_NUM                              {$$ = $1;}
						| ID                                    { }
						//| function_call				{;}
						| ID O_BRACKET TYPE_NUM C_BRACKET	{ }
						;

logical_expression_1				: logical_expression_1 OR logical_expression_2			{ }
						| logical_expression_2                                          { }
						;

logical_expression_2				: logical_expression_2 AND logical_expression_3			{ }
						| logical_expression_3                                          { }
                                                ;

logical_expression_3				: NOT logical_expression_4                                      { }
						| logical_expression_4						{ }
						;

logical_expression_4				: O_PAR logical_expression_1 C_PAR					{ }
						| logical_expression_operand EQUALS logical_expression_operand   	{ }
						| logical_expression_operand NOT_EQUALS logical_expression_operand 	{ }
						| logical_expression_operand GT logical_expression_operand   		{ }
						| logical_expression_operand GET logical_expression_operand  		{ }
						| logical_expression_operand LT logical_expression_operand   		{ }
						| logical_expression_operand LET logical_expression_operand   		{ }
						| TYPE_BOOL								{ }								
						;
                                                 
logical_expression_operand			: TYPE_BOOL                                                     { }
						| arithmetic_expression_1                                       { }
						;


%%

int main() {             
	return yyparse();
}