%{
#include 	<stdio.h>
#include 	<string.h>
#include 	<unordered_map>
#include 	<unordered_set>
#include 	<string>
#include 	<vector>
#include 	<utility>
#include 	<stack>
#include 	<iostream>
#include 	<iomanip>
#include 	<cstdarg>        
#include 	<windows.h>                            
#define uint 	unsigned int
#define uchar 	unsigned char
#define vector	std::vector
#define string 	std::string
#define pair	std::pair
#define pb 	push_back
#define mp 	make_pair
#define umap	std::unordered_map
#define uset	std::unordered_set 
#define stack	std::stack
#define ERRORR 	2147483639
#define T_VOID	100
#define NO_VAR	101
#define NO_FUN	102                                     

extern int yylineno;
void yyerror(const char *str) { printf("%s %d\n", str, yylineno); }
int yylex();
          
const char *dotsLineStr = "---------------------------------------------------------\n";
             
int customTypeParsing;
int functionParsing;
                                                
// Functions parsing:

#define		FUNCTION_ARG(cType, name, nameInUnion) 		\
		struct functionArg_##name { 			\
		 	uchar  type;                   		\
			cType  name;				\
		} nameInUnion;                                         

union functionArgUnion {               
	uchar type; // 0 - int, 1 - bool, 2 - char*, 3 - float, 4 - char, 5 - int no val, 6 - bool no val, 7 - char* no val, 8 - float no val, 9 - char no val, 10 - no value
	FUNCTION_ARG(int,intVal,intUnionMember);        
	FUNCTION_ARG(bool,boolVal,boolUnionMember);
	FUNCTION_ARG(char*,stringVal,stringUnionMember);
	FUNCTION_ARG(float,floatVal,floatUnionMember);
	FUNCTION_ARG(char,charVal,charUnionMember); 
};                        

struct functionInfo {
	functionInfo(const vector<pair<string,functionArgUnion>>& args, const string& nm, const string& tp) {
		arguments = args;
		name = nm;
		type = tp;
	}
        vector<pair<string,functionArgUnion>> arguments;
	string name, type;
	
	bool operator==(const functionInfo& other) {
		if (arguments.size() != other.arguments.size() || name != other.name) {
			return false;
		}               
		for (int i=0;i<arguments.size();++i) {
			int t1 = (arguments[i].second.type + 5)%5;
			int t2 = (other.arguments[i].second.type + 5)%5;
			if (t1 != t2) {
				return false;
			}
		}
		return true;
	}
};

vector<functionInfo>			programFunctions;
int 					functionArgsLogicInit;
umap<char,uchar>			functionArgType;
vector<pair<string,functionArgUnion>> 	thisFunctionArgs;
pair<string,string>			thisFunctionInfo;      
umap<string,uchar>			functionArgsVarsCheck;
functionArgUnion 	getFunctionArgUnion(uchar predefinedValueType, void *predefinedValue);
bool 			initFunctionArgsLogic(char* argName, uchar predefinedValueType, void *predefinedValue);
bool	 		addFunctionArg(char *argName, uchar predefinedValueType, void *predefinedValue);
int 			printFunctionInfo(int functionInCustomType);
bool			saveFunctionInfo(int functionInCustomType);
void 			printFunctionArg(const pair<string,functionArgUnion> &arg);
bool 			clearFunctionArgsArray();
bool 			clearFunctionArgsLogic();

stack<vector<uchar>>	functionCallArgumentsType;
uchar			getFunctionReturnType(char *functionName);
void 			checkFunctionCall(char *functionName);
void			clearFunctionCallArguments();
            
// Variables, arrays parsing:

#define		VARIABLE(vType, name, nameInUnion)	\
		struct variable_##name {		\
			uchar 	type;			\
			bool    isConst;		\
			vType	name;			\
		} nameInUnion;

#define		VARIABLE_VALUE(vType, name, nameInUnion)	\
		struct variable_##name {			\
			uchar 	type;				\
			bool    isConst;			\
			vType	name;				\
		} nameInUnion;

union variableDeclUnion {
	uchar type; // 0 - int, 1 - bool, 2 - char*, 3 - float, 4 - char, 5 - all types
	VARIABLE(int,intVal,intUnionMember);
	VARIABLE(bool,boolVal,boolUnionMember);
	VARIABLE(char*,stringVal,stringUnionMember);
	VARIABLE(float,floatVal,floatUnionMember);
	VARIABLE(char,charVal,charUnionMember);
};

union variableValueUnion {
 	uchar type; // 0 - int, 1 - bool, 2 - char*, 3 - float, 4 - char
	VARIABLE_VALUE(int,intVal,intUnionMember);
	VARIABLE_VALUE(bool,boolVal,boolUnionMember);
	VARIABLE_VALUE(char*,stringVal,stringUnionMember);
	VARIABLE_VALUE(float,floatVal,floatUnionMember);
	VARIABLE_VALUE(char,charVal,charUnionMember);
};

struct variableInfo {
	variableInfo(const variableValueUnion& val, const string& nm, const string& tp) {
	 	value = val;
		name = nm;
		type = tp;
	}
	variableValueUnion value;
	string name, type;
};

vector<pair<string,variableDeclUnion>>			toCheckVars;
vector<pair<string,int>>				toCheckArrays;
umap<char,uchar>					varDeclType;
umap<string,pair<variableValueUnion,string>>		localV, globalV;
umap<string,pair<vector<int>,pair<string,int>>>		localArrs, globalArrs;
                                                      
void 	addVariableToCheck(char* variableName, uchar variableType, void* variableValue, bool isConst = false);
void	addArrayToCheck(char* arrayName, int arraySize);
bool 	checkVariables(uchar varType);
bool 	checkArrays(uchar arrayType);                                                                
void 	printVariableInfo(const string& name, const string& type, const variableValueUnion& varInfo); 
void	printArrayInfo(const string& name, const string& type, int size); 
string	getTypeName(uchar type, bool isConst = false);
uchar 	getTypeFromTypeName(const string& typeName);
bool 	declareVariable(const string& name, const variableDeclUnion& declUnion, int inCustomType, int local, bool isConst);
bool 	declareArray(const string& name, uchar arrayType, uint arraySize, int inCustomType, int local = 1);
bool    setVariableValue(char *variableName, int value);
int 	getVariableValue(char *variableName);           
bool 	setArrayValue(char *arrayName, uint pos, int value);
int 	getArrayValue(char *arrayName, uint pos);
void 	clearLocalVariables();
void	printGlobalVariables();
void	printGlobalArrays();
uchar	getVariableType(char *variableName);

// Custom types parsing:

struct customTypeInfo {
	vector<functionInfo> 				functions;
	vector<variableInfo> 				variables;
	vector<pair<pair<string,string>,int>>		arrays;
	string name;
};

customTypeInfo 		thisCustomType;
vector<customTypeInfo>	programCustomTypes;
uset<string>		customTypeVars, customTypeArrs;

void 	initCustomType(char* customTypeName);
void	printCustomTypeVariables();
void	printCustomTypeArrays();
void 	saveThisCustomType();

void 	initFunctionArgsLogic();
void 	initVarDeclLogic();
void 	init();
                                             
void 	printEvalResult(void* result, const char* type);
void 	printEvalWrongType(const char* type);
void	printError(const char*format, ...);

%}
                   
%union {
	int 	numVal;
	char*	stringVal;
	char	charVal;
	float 	floatVal;
}

%start 	check
%token  MAIN IF ELSE FOR WHILE DO RETURN DEFTYPE OBJECT CONSTT FUNC DEF EVAL DOLLAR ARROW O_PAR C_PAR O_BRACE C_BRACE EQUALS NOT_EQUALS OP_EQUALS OP_ADDEQ OP_SUBEQ DOT SEMICOLON DADD DSUB COMMA COLON O_BRACKET C_BRACKET 
%token  <numVal> 	TYPE_NUM TYPE_BOOL
%token 	<charVal> 	TYPE_CHAR
%token 	<stringVal> 	TYPE_STR TYPE ID
%token  <floatVal> 	TYPE_NFLOAT
%type 	<numVal> 	operand arithmetic_expression_1 arithmetic_expression_2 arithmetic_expression_3 arithmetic_expression_4 arithmetic_expression_5 arithmetic_expression_6 arithmetic_expression_term arithmetic_expression_term_2  
%type 	<numVal> 	logical_expression_1
%type	<stringVal>     string_operations_1 string_operations_2 string_operations_term function_call function_call_header

%left 	ADD SUB MUL DIV MOD BIT_XOR BIT_AND BIT_OR BIT_SHL BIT_SHR
%left 	NOT
%left 	AND
%left 	OR
%left 	EQUALS NOT_EQUALS GT GET LT LET
                                        
%%

check					: program				{ printf("Program corect sintactic!\n"); }
					;

program					: definitions main			{ printGlobalVariables(); printGlobalArrays(); }
					| main					{ }
					;

definitions				: definitions function_declaration		{ }
					| definitions custom_type_declaration		{ }
					| definitions any_variables_declarations 	{ }
					| function_declaration				{ }
					| custom_type_declaration			{ }
					| any_variables_declarations			{ }
					;

function_declaration			: function_header instructions_block	{ 
						if (saveFunctionInfo(customTypeParsing)) {
						 	printFunctionInfo(customTypeParsing);
						} 
						clearFunctionArgsLogic();
						clearLocalVariables();
						functionParsing = 0;
					}
					;

function_header				: FUNC ID O_PAR function_parameters C_PAR ARROW TYPE	{ thisFunctionInfo = mp(string($2), string($7)); functionParsing = 1; }
					| FUNC ID O_PAR C_PAR ARROW TYPE 			{ thisFunctionInfo = mp(string($2), string($6)); functionParsing = 1; }
					;
                                         
function_parameters			: function_parameters_no_def_values						{ }
					| function_parameters_def_values      						{ }
					| function_parameters_no_def_values COMMA function_parameters_def_values	{ }
					;

function_parameters_no_def_values	: function_parameters_no_def_values COMMA TYPE ID	{ addFunctionArg($4, functionArgType[$3[0]], 0); }
					| TYPE ID						{ initFunctionArgsLogic($2, functionArgType[$1[0]], 0); }
					;
                                                         
function_parameters_def_values		: function_parameters_def_values COMMA TYPE ID OP_EQUALS TYPE_NUM	{ addFunctionArg($4, 0, (void*)&$6); }
					| function_parameters_def_values COMMA TYPE ID OP_EQUALS TYPE_BOOL	{ addFunctionArg($4, 1, (void*)&$6); }
					| function_parameters_def_values COMMA TYPE ID OP_EQUALS TYPE_STR	{ addFunctionArg($4, 2, (void*)$6); }
					| function_parameters_def_values COMMA TYPE ID OP_EQUALS TYPE_NFLOAT	{ addFunctionArg($4, 3, (void*)&$6); }
					| function_parameters_def_values COMMA TYPE ID OP_EQUALS TYPE_CHAR	{ addFunctionArg($4, 4, (void*)&$6); }
					| TYPE ID OP_EQUALS TYPE_NUM						{ initFunctionArgsLogic($2, 0, (void*)&$4); }
					| TYPE ID OP_EQUALS TYPE_BOOL						{ initFunctionArgsLogic($2, 1, (void*)&$4); }
					| TYPE ID OP_EQUALS TYPE_STR						{ initFunctionArgsLogic($2, 2, (void*)$4); }
					| TYPE ID OP_EQUALS TYPE_NFLOAT						{ initFunctionArgsLogic($2, 3, (void*)&$4); }
					| TYPE ID OP_EQUALS TYPE_CHAR						{ initFunctionArgsLogic($2, 4, (void*)&$4); }
					;                                                                       

custom_type_declaration			: custom_type_header ARROW O_BRACE custom_type_body C_BRACE	{ 
						printCustomTypeVariables(); 
						printCustomTypeArrays(); 
						saveThisCustomType(); 
						customTypeParsing = 0; 
					}
					| custom_type_header ARROW O_BRACE C_BRACE			{ customTypeParsing = 0; }
					;

custom_type_header			: DEFTYPE ID 						{ customTypeParsing = 1; initCustomType($2); }
					;
					
custom_type_body			: custom_type_body custom_type_body_declaration		{ }
					| custom_type_body_declaration				{ }
					;

custom_type_body_declaration		: function_declaration					{ }
					| any_variables_declarations				{ }
					;

main					: main_header instructions_block	{ functionParsing = 0; }
					;
                                        
main_header				: MAIN ARROW TYPE 			{ functionParsing = 1; }
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
					| eval_expr				{ }
					;

eval_expr				: eval_expr_call SEMICOLON			{ }
					;

eval_expr_call				: EVAL O_PAR arithmetic_expression_1 C_PAR	{ printEvalResult((void*)&$3, "int"); }
					| EVAL O_PAR logical_expression_1 C_PAR		{ printEvalResult((void*)&$3, "bool"); }
					| EVAL O_PAR string_operations_1 C_PAR		{ printEvalResult((void*)$3, "string"); }
					| EVAL O_PAR TYPE_NFLOAT C_PAR			{ printEvalWrongType("float"); }
					| EVAL O_PAR TYPE_CHAR C_PAR			{ printEvalWrongType("char"); }
					;

return_statement_full			: return_statement SEMICOLON		{ }
					;

return_statement			: RETURN return_statement_arg		{ }
					| RETURN				{ }
					;

return_statement_arg			: logical_expression_1                          { }
					| arithmetic_expression_1			{ }
					| TYPE_STR					{ }
					| TYPE_NFLOAT					{ }
					| TYPE_CHAR					{ }
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

variables_declaration			: DEF variables_declaration_list ARROW TYPE 		{ checkVariables(varDeclType[$4[0]]); checkArrays(varDeclType[$4[0]]); }
					;

variables_declaration_list		: variables_declaration_list COMMA variable_declaration	{ }
					| variable_declaration					{ }
					;

variable_declaration			: ID					{ addVariableToCheck($1, 5, NULL); }
					| ID OP_EQUALS arithmetic_expression_1	{ addVariableToCheck($1, 0, (void*)&$3); }
					| ID OP_EQUALS logical_expression_1	{ addVariableToCheck($1, 1, (void*)&$3); }
					| ID OP_EQUALS TYPE_STR			{ addVariableToCheck($1, 2, (void*)$3); }
					| ID OP_EQUALS TYPE_NFLOAT		{ addVariableToCheck($1, 3, (void*)&$3); }
					| ID OP_EQUALS TYPE_CHAR		{ addVariableToCheck($1, 4, (void*)&$3); }
					| ID O_BRACKET TYPE_NUM C_BRACKET	{ addArrayToCheck($1, $3); }
					;

const_variables_declaration_full	: const_variables_declaration SEMICOLON				{ }
					;

const_variables_declaration		: DEF CONSTT const_variables_declaration_list ARROW TYPE	{ checkVariables(varDeclType[$5[0]]); }
					;

const_variables_declaration_list	: const_variables_declaration_list const_variable_declaration	{ }
					| const_variable_declaration					{ }
					;

const_variable_declaration		: ID OP_EQUALS arithmetic_expression_1			{ addVariableToCheck($1, 0, (void*)&$3, true); }
					| ID OP_EQUALS logical_expression_1			{ addVariableToCheck($1, 1, (void*)&$3, true); }
					| ID OP_EQUALS TYPE_STR                                 { addVariableToCheck($1, 2, (void*)$3, true); }
					| ID OP_EQUALS TYPE_NFLOAT				{ addVariableToCheck($1, 3, (void*)&$3, true); }
					| ID OP_EQUALS TYPE_CHAR				{ addVariableToCheck($1, 4, (void*)&$3, true); }
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

arithmetic_expression_1				: arithmetic_expression_1 BIT_OR arithmetic_expression_2        { $$ = $1 | $3; }
						| arithmetic_expression_2                                       { $$ = $1; }
						;

arithmetic_expression_2				: arithmetic_expression_2 BIT_XOR arithmetic_expression_3       { $$ = $1 ^ $3; }
						| arithmetic_expression_3                                       { $$ = $1; }
						;

arithmetic_expression_3				: arithmetic_expression_3 BIT_AND arithmetic_expression_4       { $$ = $1 & $3; }
						| arithmetic_expression_4                                       { $$ = $1; }
						;

arithmetic_expression_4				: arithmetic_expression_4 BIT_SHL arithmetic_expression_5       { $$ = $1 << $3; }
						| arithmetic_expression_4 BIT_SHR arithmetic_expression_5       { $$ = $1 >> $3; }
						| arithmetic_expression_5                                       { $$ = $1; }
						;

arithmetic_expression_5				: arithmetic_expression_5 ADD arithmetic_expression_6           { $$ = $1 + $3; }
						| arithmetic_expression_5 SUB arithmetic_expression_6           { $$ = $1 - $3; }
						| arithmetic_expression_6                                       { $$ = $1;}
						;

arithmetic_expression_6				: arithmetic_expression_6 MUL arithmetic_expression_term_2      { $$ = $1 * $3; }
						| arithmetic_expression_6 DIV arithmetic_expression_term_2      { $$ = $1 / $3; }
						| arithmetic_expression_6 MOD arithmetic_expression_term_2      { $$ = $1 % $3; }
						| arithmetic_expression_term                                    { $$ = $1;}
						;

arithmetic_expression_term_2			: arithmetic_expression_term					{ $$ = $1; }
						| TYPE_NFLOAT							{ }
						;

arithmetic_expression_term			: O_PAR arithmetic_expression_1 C_PAR				{ $$ = $2; }
						| operand                                                       { $$ = $1; }
						;
                                                                                 
operand						: TYPE_NUM                              { $$ = $1; }
						| ID                                    { $$ = getVariableValue($1); }
						| function_call				{ }
						| ID O_BRACKET TYPE_NUM C_BRACKET	{ $$ = getArrayValue($1, $3); }
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

string_operations_1				: string_operations_1 DADD string_operations_2		{ 
                                                        int len1 = strlen($1), len2 = strlen($3), len3 = len1 + len2;
							$$ = new char[len3 + 1];
							strcpy($$, $1);
							strcpy($$+len1, $3);
						}
						| string_operations_2					{ $$ = $1; }
						;

string_operations_2				: string_operations_term MUL arithmetic_expression_1	{ 
                                                        int len1 = strlen($1), finalLen = len1 * $3;
							$$ = new char[finalLen + 1];
							if ($$ != NULL) {
                                                		for (int i=0;i<$3;++i) strcpy($$+i*len1, $1);
							}
						}
						| string_operations_term				{ $$ = $1; }
						;

string_operations_term				: O_PAR string_operations_1 C_PAR			{ $$ = $2; }
						| TYPE_STR						{ $$ = $1; }
						| ARROW ID						{ }
						;

function_call_full				: function_call SEMICOLON					{ }
						;

function_call					: function_call_header O_PAR O_PAR function_call_args C_PAR C_PAR		{ $$ = $1; checkFunctionCall($1); clearFunctionCallArguments(); }
						| function_call_header O_PAR O_PAR C_PAR C_PAR					{ $$ = $1; checkFunctionCall($1); clearFunctionCallArguments(); }
						;

function_call_header				: ID COLON COLON ID					{ 
							int len1 = strlen($1), len2 = strlen($4);
							$$ = new char[len1+len2+2];
							strcpy($$,$1);
							strcpy($$+len1,":");
							strcpy($$+len1+1,$4);
							functionCallArgumentsType.push(vector<uchar>());
						}
						| ID							{ $$ = $1; functionCallArgumentsType.push(vector<uchar>()); }
						;

function_call_args				: function_call_args COMMA function_call_arg		{ }
						| function_call_arg					{ }
						;

function_call_arg				: arithmetic_expression_1			{ functionCallArgumentsType.top().pb(0); }
						| logical_expression_1                          { functionCallArgumentsType.top().pb(1); }
						| TYPE_STR					{ functionCallArgumentsType.top().pb(2); }
						| TYPE_NFLOAT					{ functionCallArgumentsType.top().pb(3); }
						| TYPE_CHAR					{ functionCallArgumentsType.top().pb(4); }
						| DOLLAR ID					{ functionCallArgumentsType.top().pb(getVariableType($2)); }
						| DOLLAR function_call				{ functionCallArgumentsType.top().pb(getFunctionReturnType($2)); }
						;

%%

functionArgUnion getFunctionArgUnion(uchar predefinedValueType, void *predefinedValue) {                                        
	functionArgUnion 	ret;
	char* 			strPointer;
	int*			intPointer;
	float*			floatPointer;
	memset(&ret,0,sizeof(functionArgUnion));
	ret.type = predefinedValueType;
	switch(predefinedValueType) {
		case 0: intPointer = (int*)predefinedValue; 
			ret.intUnionMember.intVal = *intPointer;		
			break;
		case 1:	intPointer = (int*)predefinedValue;
			ret.boolUnionMember.boolVal = (*intPointer == 1 ? true : false);	
			break;
		case 2: strPointer = (char*)predefinedValue;
			ret.stringUnionMember.stringVal = strPointer;
			break;
		case 3: floatPointer = (float*)predefinedValue;
			ret.floatUnionMember.floatVal = *floatPointer;
			break;
		case 4: strPointer = (char*)predefinedValue;
			ret.charUnionMember.charVal = *strPointer;
			break;
		default:break;
	}                     
	return ret;                                   
}

bool initFunctionArgsLogic(char* argName, uchar predefinedValueType, void *predefinedValue) {       
	if (!functionArgsLogicInit) {
		clearFunctionArgsArray();
		functionArgsVarsCheck.clear();
		functionArgsLogicInit = 1;
	}
	if (argName == 0) {
		return false;
	}
	return addFunctionArg(argName, predefinedValueType, predefinedValue);	
}

bool addFunctionArg(char *argName, uchar predefinedValueType, void *predefinedValue) {
        if (argName == 0) {
		return false;
	}
	string name(argName);
	functionArgUnion fArg = getFunctionArgUnion(predefinedValueType, predefinedValue);
	thisFunctionArgs.pb(mp(name,fArg));
	functionArgsVarsCheck[name] = predefinedValueType % 5;	
	return true;
}

int printFunctionInfo(int functionInCustomType) {
	if (!functionInCustomType) {
		std::cout<<dotsLineStr;
	}
 	std::cout<<"Function name: ";
	if (functionInCustomType) {
		std::cout<<thisCustomType.name<<'.';
	} 
	std::cout<<thisFunctionInfo.first<<'\n';
	std::cout<<"Function return value: "<<thisFunctionInfo.second<<'\n';
	std::cout<<"Number of arguments: "<< thisFunctionArgs.size()<<'\n';
	for (uint i=0;i<thisFunctionArgs.size();++i) {
		printFunctionArg(thisFunctionArgs[i]);
	}
	std::cout<<"Local variables: "<< localV.size() << '\n';
	for (auto var : localV) {
		printVariableInfo(var.first, var.second.second, var.second.first);
	}
	std::cout<<"Local arrays: "<< localArrs.size() << '\n';
	for (auto arr : localArrs) {
		printArrayInfo(arr.first, arr.second.second.first, arr.second.second.second);
	}
	std::cout<<'\n';		
}
                                                        
void printFunctionArg(const pair<string,functionArgUnion> &arg) {              
	std::cout<<"* Arg name: "<<arg.first<<", ";
	std::cout<<"arg type: ";
	switch(arg.second.type) {
	 	case 0: case 5: std::cout<<"int"; break;
		case 1: case 6: std::cout<<"bool"; break;
		case 2: case 7: std::cout<<"string"; break;
		case 3: case 8: std::cout<<"float"; break;
		case 4: case 9: std::cout<<"char"; break;
		default: break;
	}
	std::cout<<", predefined value: ";
	switch(arg.second.type) {
	 	case 0: std::cout<<arg.second.intUnionMember.intVal; break;
		case 1: std::cout<<arg.second.boolUnionMember.boolVal ? "true" : "false"; break;
		case 2: if (arg.second.stringUnionMember.stringVal) std::cout<<'\''<<arg.second.stringUnionMember.stringVal<<'\''; break;
		case 3: std::cout<<std::setprecision(3)<<std::fixed<<arg.second.floatUnionMember.floatVal; break;
		case 4: std::cout<<'\''<<arg.second.charUnionMember.charVal<<'\''; break;
		default:std::cout<<"none"; break;
	}
	std::cout<<'\n';
}

bool saveFunctionInfo(int functionInCustomType) {
	functionInfo newFunction(thisFunctionArgs, thisFunctionInfo.first, thisFunctionInfo.second);
	bool good = true;
	if (functionInCustomType) {
	        for (int i=0;i<thisCustomType.functions.size();++i) {
	         	if (thisCustomType.functions[i] == newFunction) {
			      	good = false;
				break;
			}
		}
		if (good) {
		 	thisCustomType.functions.pb(newFunction);
		} else {
		 	printError("Error when declaring the function named \"%s\" in custom type \"%s\"! Another function with the same signature was previously defined!\n", thisFunctionInfo.first.c_str(), thisCustomType.name.c_str());
		}
	} else {
		for (int i=0;i<programFunctions.size();++i) {
		 	if (programFunctions[i] == newFunction) {
		 		good = false;
				break;
			}
		}
		if (good) {
		 	programFunctions.pb(newFunction);
		} else {
		 	printError("Error when declaring the function named \"%s\"! Another function with the same signature was previously defined!\n", thisFunctionInfo.first.c_str());
		}
	}
	return good;
}
   
bool clearFunctionArgsArray() {
        for (uint i=0;i<thisFunctionArgs.size();++i)
		if (thisFunctionArgs[i].second.type == 2 && thisFunctionArgs[i].second.stringUnionMember.stringVal != 0) {
			delete[] thisFunctionArgs[i].second.stringUnionMember.stringVal;
			thisFunctionArgs[i].second.stringUnionMember.stringVal = 0;
		}
	thisFunctionArgs.clear();
	return true; 	
}
   
bool clearFunctionArgsLogic() {         
	if (!functionArgsLogicInit) {
		return false;
	}
	functionArgsLogicInit = 0;
	return clearFunctionArgsArray();
}

uchar getFunctionReturnType(char *functionName) {
	string name(functionName);        
	for (int i=0;i<programFunctions.size();++i) {
		if (programFunctions[i].name == name) {
		 	return getTypeFromTypeName(programFunctions[i].type);
		}
	}
	return NO_FUN;
}

void checkFunctionCall(char *functionName) {
	string name(functionName);
	int index = -1;
	for (int i=0;i<programFunctions.size();++i) {
	 	if (programFunctions[i].name == name) {
		 	index = i;
			break;
		}
	}
	if (index == -1) {
		printError("Cannot call function named \"%s\"! A function with this name was not declared!\n", name.c_str());
		return;
	}
	vector<uchar> args = functionCallArgumentsType.top();
	for (int i=index;i<programFunctions.size();++i) {
	        if (programFunctions[i].name != name || programFunctions[i].arguments.size() < args.size()) {
			continue;
		}
		bool ok = true;
		for (int j=0;j<args.size();++j){
			if (args[j] != programFunctions[i].arguments[j].second.type % 5) {
				ok = false;
				break;
			}
		}
		if (ok) {
			return;
		}
	}
	printError("Invalid arguments when calling a function called \"%s\"! No matching function signature found!\n", name.c_str());
}

void clearFunctionCallArguments() {
        functionCallArgumentsType.pop();
}

void addVariableToCheck(char* variableName, uchar variableType, void* variableValue, bool isConst) {
	string 			varName(variableName);
	char* 			charPointer;
	int* 			intPointer;
	float*			floatPointer;
	variableDeclUnion 	varInfo;
	memset(&varInfo,0,sizeof(varInfo));
	varInfo.type = variableType;
	varInfo.intUnionMember.isConst = isConst;
	switch(variableType) {
		case 0: intPointer = (int*)variableValue;
			varInfo.intUnionMember.intVal = *intPointer;
			break;
		case 1: intPointer = (int*)variableValue;
		        varInfo.boolUnionMember.boolVal = (*intPointer == 1 ? true : false);
			break;
		case 2: charPointer = (char*)variableValue;
			varInfo.stringUnionMember.stringVal = strdup(charPointer);
			break;
		case 3: floatPointer = (float*)variableValue;
			varInfo.floatUnionMember.floatVal = *floatPointer;
			break;
		case 4: charPointer = (char*)variableValue;
			varInfo.charUnionMember.charVal = *charPointer;
		default:break;
	}
	toCheckVars.pb(mp(varName,varInfo));
}

void addArrayToCheck(char* arrayName, int arraySize) {
	string		name(arrayName);
	toCheckArrays.pb(mp(name,arraySize));
}

bool checkVariables(uchar varType) {
	for (auto var : toCheckVars) {
		if (var.second.type == 5) {
			var.second.type = varType;
		} else {
		        if (var.second.type != varType) {
				printError("Invalid type for variable \"%s\"\n",var.first.c_str());
				continue;
			}              
		}
		declareVariable(var.first, var.second, customTypeParsing, functionParsing, var.second.intUnionMember.isConst); 	 	                           
	}
	toCheckVars.clear();
}

bool checkArrays(uchar arrayType) {
        for (auto var : toCheckArrays) {
                declareArray(var.first, arrayType, var.second, customTypeParsing, functionParsing);
	}
	toCheckArrays.clear();
}

void printVariableInfo(const string& name, const string& type, const variableValueUnion& varInfo) {
	std::cout<<type<<' '<<name<<", value: ";
	switch(varInfo.type) {
		case 0: std::cout<<varInfo.intUnionMember.intVal; break;
		case 1: std::cout<<varInfo.boolUnionMember.boolVal; break;
		case 2: if (varInfo.stringUnionMember.stringVal) std::cout<<'\''<<varInfo.stringUnionMember.stringVal<<'\''; break;
		case 3: std::cout<<std::setprecision(3)<<std::fixed<<varInfo.floatUnionMember.floatVal; break;
		case 4: std::cout<<'\''<<varInfo.charUnionMember.charVal<<'\''; break;
		default:break;
	}                    
	std::cout<<'\n';
}
     
void printArrayInfo(const string& name, const string& type, int size) {
        std::cout<<type <<' '<<name<<'['<<size<<"]\n";
}

string getTypeName(uchar type, bool isConst) {
	string res;
	if (isConst) {
		res += "const ";
	}
	switch(type) {
		case 0: res += "int"; break;
		case 1: res += "bool"; break;
		case 2: res += "string"; break;
		case 3: res += "float"; break;
		case 4: res += "char"; break;
		default:res = "error"; break;
	}
	return res;
}

uchar getTypeFromTypeName(const string& typeName) {
        const char* asChar = typeName.c_str();
	if (!strncmp(asChar,"co",2)) { // const
	       return varDeclType[asChar[6]];	
	} else if (asChar[0] == 'v') { 
	       return T_VOID;
	} else {
	       return varDeclType[asChar[0]];
	}
}

bool declareVariable(const string& name, const variableDeclUnion& declUnion, int inCustomType, int local, bool isConst) {	
	if (local == 1 && localV.count(name)) {
		printError("Local variable \"%s\" was previously defined!\n", name.c_str());
		return false;
	} else if (local == 0 && inCustomType && customTypeVars.count(name)) {
                printError("A variable with name \"%s\" was previously defined in custom type \"%s\"!\n", thisCustomType.name.c_str(), name.c_str());
		return false;
	} else if (local == 0 && globalV.count(name)) {
		printError("Global variable \"%s\" was previously defined!\n", name.c_str());
		return false;
	}
	string type = getTypeName(declUnion.type, isConst);
	variableValueUnion value;
	memset(&value,0,sizeof(value));
	value.type = declUnion.type;
	switch(declUnion.type) {
		case 0: value.intUnionMember.intVal = declUnion.intUnionMember.intVal; break;
		case 1: value.boolUnionMember.boolVal = declUnion.boolUnionMember.boolVal; break;
		case 2: value.stringUnionMember.stringVal = declUnion.stringUnionMember.stringVal; break;
		case 3: value.floatUnionMember.floatVal = declUnion.floatUnionMember.floatVal; break;
		case 4: value.charUnionMember.charVal = declUnion.charUnionMember.charVal; break;
		default:break;
	}
	if (local == 1) {
		localV[name] = mp(value,type);
	} else if (local == 0 && inCustomType == 1) {
		variableInfo varInfo(value, name, type);
	        thisCustomType.variables.pb(varInfo);
	} else {
		globalV[name] = mp(value,type);
	}
	return true;
}

bool declareArray(const string& name, uchar arrayType, uint arraySize, int inCustomType, int local) {       
	if (local == 1 && localArrs.count(name)) {
		printError("Local array \"%s\" was previously defined!\n", name.c_str());
		return false;
	} else if (local == 0 && inCustomType == 1 && customTypeArrs.count(name)) {
        	printError("An array with name \"%s\" was previously defined in custom type \"%s\"!\n", thisCustomType.name.c_str(), name.c_str());
		return false;
	} else if (local == 0 && inCustomType == 0 && globalArrs.count(name)) {  
		printError("Global array \"%s\" was previously defined!\n", name.c_str());
		return false;
	}
	string type = getTypeName(arrayType);
	vector<int>arr;
	if (type == "int"){
		arr.resize(arraySize, 0);
	}  
	if (local == 1) {
		localArrs[name] = mp(arr,mp(type,arraySize));
	} else if (local == 0 && inCustomType == 1) {
	        thisCustomType.arrays.pb(mp(mp(name, type),arraySize));
	} else {
		globalArrs[name] = mp(arr,mp(type,arraySize));
	}
	return true;	
}

bool setVariableValue(char *variableName, int value) {
 	string name(variableName);
	bool res = false;
	if (localV.count(name)) {
		res = true;
		localV[name].first.intUnionMember.intVal = value;
	} else if (globalV.count(name)) {
		res = true;
		globalV[name].first.intUnionMember.intVal = value;
	}
	return true;
}

int getVariableValue(char *variableName) {
	string name(variableName);
	if (localV.count(name)){
		return localV[name].first.intUnionMember.intVal;
	}
	if (functionParsing && functionArgsVarsCheck.count(name)) {
	 	return 0; 
	}
	if (globalV.count(name)){
		return globalV[name].first.intUnionMember.intVal;
	}                                                                          
	printError("The variable \"%s\" was not declared in the program!\n", name.c_str());
	return ERRORR;
}

bool setArrayValue(char *arrayName, uint pos, int value) {                 
	string name(arrayName);
	bool res = false;
	if (localArrs.count(name)) {
		if (pos < localArrs[name].second.second) {
			localArrs[name].first[pos] = value;	
		} else {
			printError("Index %d out of bounds for local array \"%s\"!\n", pos, name.c_str());
		}
	} else if (globalArrs.count(name)) {
	 	if (pos < globalArrs[name].second.second) {
		        globalArrs[name].first[pos] = value;
		} else {
			printError("Index %d out of bounds for global array \"%s\"!\n", pos, name.c_str());
		}
	}
	return res;
}

int getArrayValue(char *arrayName, uint pos) {
        string name(arrayName);
	if (localArrs.count(name)) {
		if (pos < localArrs[name].second.second) {
			return localArrs[name].first[pos];	
		}
		printError("Index %d out of bounds for local array \"%s\"!\n", pos, name.c_str());
		return ERROR;
	}
	if (globalArrs.count(name)) {
	 	if (pos < globalArrs[name].second.second) {
		        return globalArrs[name].first[pos];
		}
		printError("Index %d out of bounds for global array \"%s\"!\n", pos, name.c_str());
		return ERROR;
	}
	printError("The array \"%s\" was not declared in the program!\n", name.c_str());
	return ERRORR;
}

void clearLocalVariables() {
 	localV.clear();
	localArrs.clear();
}

void printGlobalVariables() {
	if (!globalV.size()) {
		return;
	}
	std::cout<<dotsLineStr<<"Global variables:\n\n";
	for (auto& var : globalV) {
	 	printVariableInfo(var.first, var.second.second, var.second.first);
	}
	std::cout<<'\n';
}

void printGlobalArrays() {
	if (!globalArrs.size()) { 
		return;
	}
	std::cout<<dotsLineStr<<"Global arrays:\n\n";
	for (auto& arr : globalArrs) {
	 	printArrayInfo(arr.first, arr.second.second.first, arr.second.second.second);
	}
	std::cout<<'\n';
}

uchar getVariableType(char *variableName) {
	string name(variableName);
	if (functionParsing) {
		if (localV.count(name)) {
			return getTypeFromTypeName(localV[name].second);
		}
	}
	if (customTypeParsing) {
		if (customTypeVars.count(name)) {
			std::cout<<name<<" found\n";
		 	return 0;
		}
	}
	if (globalV.count(name)) {
		return getTypeFromTypeName(globalV[name].second); 
	}
	return NO_VAR;	
}

void initCustomType(char* customTypeName) {
	string name(customTypeName);
	thisCustomType.name = customTypeName;
	std::cout<<dotsLineStr<<dotsLineStr<<"Custom type: "<<name<<"\n\n";
}

void printCustomTypeVariables() {
	if (!thisCustomType.variables.size()) {
		return;
	}
        std::cout<<thisCustomType.name<<" members (variables):\n";
	for (auto& var : thisCustomType.variables) {
		printVariableInfo(var.name, var.type, var.value);
	}
	std::cout<<'\n';
}

void printCustomTypeArrays() {
	if (!thisCustomType.arrays.size()) {
		return;
	}
	std::cout<<thisCustomType.name<<" members (arrays):\n";
	for (auto& arr : thisCustomType.arrays) {
	        printArrayInfo(arr.first.first, arr.first.second, arr.second);
	}
	std::cout<<'\n';
}

void saveThisCustomType() {
	programCustomTypes.pb(thisCustomType);
	thisCustomType.functions.clear();
	thisCustomType.variables.clear();
	thisCustomType.arrays.clear();
	customTypeVars.clear();
	customTypeArrs.clear();
}

void initFunctionArgsLogic() {
	functionArgType['i'] = 5, functionArgType['b'] = 6, functionArgType['s'] = 7, functionArgType['f'] = 8, functionArgType['c'] = 9;
}
     
void initVarDeclLogic() {
	varDeclType['i'] = 0, varDeclType['b'] = 1, varDeclType['s'] = 2, varDeclType['f'] = 3, varDeclType['c'] = 4;
}

void init() {
 	initFunctionArgsLogic();
	initVarDeclLogic();
}               

void printEvalResult(void* result, const char* type) {
	if (type == NULL || strlen(type) < 1) {
		printError("Internal error!\n");
		return;
	}                  
	if (*type == 'i') {
		int* 	intPointer = (int*)result;
		printf("Line %d eval: int expr = %d\n", yylineno, *intPointer);
	} else if (*type == 'b') {
	        int*	intPointer = (int*)result;
		printf("Line %d eval: bool expr = %s\n", yylineno, *intPointer ? "true" : "false");
	} else {
	        char* 	strPointer = (char*)result;
		printf("Line %d eval: string expr = %s\n", yylineno, strPointer);
	}                                              
}

void printEvalWrongType(const char* type) {
	printf("Line %d eval: invalid type, \"int\" expected, found: %s\n", yylineno, type);
}

void printError(const char*format, ...) {
 	HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    	SetConsoleTextAttribute(hConsole, 12);
	va_list args;
     	va_start(args, format);
	printf("Line %d error: ", yylineno);
     	vprintf(format, args);
	va_end(args);
	SetConsoleTextAttribute(hConsole, 7);
}
 
int main() {
	init();             
	return yyparse();
}