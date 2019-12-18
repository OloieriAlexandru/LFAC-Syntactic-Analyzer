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
%token  MAIN IF ELSE TYPE_NFLOAT FOR WHILE DO RETURN DEFTYPE OBJECT CONST FUNC DEF ARROW O_PAR C_PAR O_BRACE C_BRACE EQUALS NOT_EQUALS OP_EQUALS OP_ADDEQ OP_SUBEQ DOT SEMICOLON DADD DSUB COMMA COLON O_BRACKET C_BRACKET 
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

definitions				: definitions function_declaration		{ }
					| definitions custom_type_declaration		{ }
					| definitions any_variables_declarations 	{ }
					| function_declaration				{ }
					| custom_type_declaration			{ }
					| any_variables_declarations			{ }
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

custom_type_declaration			: DEFTYPE ID ARROW O_BRACE custom_type_body C_BRACE	{ }
					| DEFTYPE ID ARROW O_BRACE C_BRACE			{ }
					;
					
custom_type_body			: custom_type_body custom_type_body_declaration		{ }
					| custom_type_body_declaration				{ }
					;

custom_type_body_declaration		: function_declaration					{ }
					| any_variables_declarations				{ }
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
					| const_variables_declaration_full	{ }
					| function_call_full			{ }
					| return_statement_full			{ }
					| variables_operations_full		{ }
					| if_block				{ }
					| for_loop				{ }
					| while_loop				{ }
					| do_while_loop				{ }
					;

return_statement_full			: return_statement SEMICOLON		{ }
					;

return_statement			: RETURN return_statement_arg		{ }
					| RETURN				{ }
					;

return_statement_arg			: logical_expression_1                          { }
					| arithmetic_expression_1			{ }
					| types_constants				{ }
					;					

if_block				: IF O_PAR logical_expression_1 C_PAR ARROW instructions_block					{ }
					| IF O_PAR C_PAR ARROW instructions_block							{ }
					| IF O_PAR logical_expression_1 C_PAR ARROW instructions_block ELSE ARROW instructions_block	{ }
					| IF O_PAR logical_expression_1 C_PAR ARROW instructions_block ELSE if_block			{ }
					; 

for_loop				: FOR O_PAR for_loop_header C_PAR ARROW instructions_block	{ }
					;

for_loop_header				: variables_declaration SEMICOLON logical_expression_1 SEMICOLON variables_operations	{ }
					| variables_declaration SEMICOLON logical_expression_1 SEMICOLON			{ }
					| variables_declaration SEMICOLON SEMICOLON variables_operations			{ }
					| variables_declaration SEMICOLON SEMICOLON						{ }
					| SEMICOLON logical_expression_1 SEMICOLON variables_operations				{ }
					| SEMICOLON logical_expression_1 SEMICOLON 						{ }
					| SEMICOLON SEMICOLON variables_operations						{ }
					| SEMICOLON SEMICOLON									{ }
					;

while_loop				: WHILE O_PAR logical_expression_1 C_PAR ARROW instructions_block	{ }
					| WHILE O_PAR C_PAR ARROW instructions_block				{ }
					;

do_while_loop				: DO ARROW instructions_block WHILE O_PAR logical_expression_1 C_PAR SEMICOLON	{ }
					| DO ARROW instructions_block WHILE O_PAR C_PAR SEMICOLON                       { }
					;

any_variables_declarations		: variables_declaration_full			{ }
					| const_variables_declaration_full		{ }
					| custom_type_variable_declaration_full		{ }
					;

variables_declaration_full		: variables_declaration SEMICOLON			{ }
					;

variables_declaration			: DEF variables_declaration_list ARROW TYPE 		{ }
					;

variables_declaration_list		: variables_declaration_list COMMA variable_declaration	{ }
					| variable_declaration					{ }
					;

variable_declaration			: ID					{ }
					| ID O_BRACKET TYPE_NUM C_BRACKET	{ }
					| ID OP_EQUALS arithmetic_expression_1	{ }
					| ID OP_EQUALS logical_expression_1	{ }
					;

const_variables_declaration_full	: const_variables_declaration SEMICOLON				{ }
					;

const_variables_declaration		: DEF CONST const_variables_declaration_list ARROW TYPE		{ }
					;

const_variables_declaration_list	: const_variables_declaration_list const_variable_declaration	{ }
					| const_variable_declaration					{ }
					;

const_variable_declaration		: ID OP_EQUALS arithmetic_expression_1				{ }
					| ID OP_EQUALS logical_expression_1				{ }
					;

custom_type_variable_declaration_full	: custom_type_variable_declaration SEMICOLON			{ }
					;

custom_type_variable_declaration	: DEF OBJECT ID OP_EQUALS custom_type_variable_declaration_body	ARROW ID { }
					;

custom_type_variable_declaration_body	: O_BRACE custom_type_variable_declaration_decl C_BRACE		{ }
					| O_BRACE C_BRACE						{ }
					;

custom_type_variable_declaration_decl	: custom_type_variable_declaration_decl COMMA custom_type_variable_declaration_attr	{ }
                                        | custom_type_variable_declaration_attr							{ }
					;
custom_type_variable_declaration_attr	: ID COLON custom_type_variable_declaration_attr_pos_value	{ }
                                        ;

custom_type_variable_declaration_attr_pos_value	: arithmetic_expression_1		{ }
						| logical_expression_1			{ }
						;

variables_operations_full		: variables_operations SEMICOLON		{ }
					;

variables_operations			: variables_operations COMMA variable_operation	{ }
					| variable_operation				{ }
					;

variable_operation			: variable_operation_operand OP_EQUALS arithmetic_expression_1 	{ }
					| variable_operation_operand OP_EQUALS logical_expression_1	{ }
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
						| TYPE_NFLOAT				{ }
						| ID                                    { }
						| function_call				{ }
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

function_call_full				: function_call SEMICOLON					{ }
						;

function_call					: ID COLON COLON ID O_PAR O_PAR function_call_args C_PAR C_PAR	{ }
						| ID COLON COLON ID O_PAR O_PAR C_PAR C_PAR			{ }
						| ID O_PAR O_PAR function_call_args C_PAR C_PAR			{ }
						| ID O_PAR O_PAR C_PAR C_PAR					{ }
						;

function_call_args				: function_call_args COMMA function_call_arg		{ }
						| function_call_arg					{ }
						;

function_call_arg				: logical_expression_1                          { }
						| arithmetic_expression_1			{ }
						| types_constants				{ }
						;

types_constants					: TYPE_STR					{ }
						| TYPE_CHAR					{ }
						;

%%
                
int main() {             
	return yyparse();
}