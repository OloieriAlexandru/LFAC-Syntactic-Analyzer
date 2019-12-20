%{
#include 	<stdio.h>
#include 	<string.h>
#include 	<unordered_map>
#include 	<string>
#include 	<vector>
#include 	<utility>
#include 	<iostream>
#include 	<iomanip>                             
#define uint 	unsigned int
#define uchar 	unsigned char
#define vector	std::vector
#define string 	std::string
#define pair	std::pair
#define pb 	push_back
#define mp 	make_pair
#define umap	std::unordered_map
#define 	ERROR 2147483639                                     

extern int yylineno;
void yyerror(const char *str) { printf("%s %d\n", str, yylineno); }
int yylex();
          
const char *dotsLineStr = "---------------------------------------------------------\n";
             
int customStructureParsing;
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

int 					functionArgsLogicInit;
umap<char,uchar>			functionArgType;
vector<pair<string,functionArgUnion>> 	thisFunctionArgs;
pair<string,string>			functionInfo;
functionArgUnion 	getFunctionArgUnion(uchar predefinedValueType, void *predefinedValue);
bool 			initFunctionArgsLogic(char* argName, uchar predefinedValueType, void *predefinedValue);
bool	 		addFunctionArg(char *argName, uchar predefinedValueType, void *predefinedValue);
int 			printFunctionInfo();
void 			printFunctionArg(const pair<string,functionArgUnion> &arg);
bool 			clearFunctionArgsArray();
bool 			clearFunctionArgsLogic();
            
// Variables, arrays parsing:

umap<string,pair<int,string>>		localV, globalV;
umap<string,pair<vector<int>,string>>	localArrs, globalArrs;
bool 	declareVariable(char *variableName, char* variableType, int value = 0, int local = 1);
bool 	declareArray(char *arrayName, char* variableType, uint arraySize, int local = 1);
bool    setVariableValue(char *variableName, int value);
int 	getVariableValue(char *variableName);           
bool 	setArrayValue(char *arrayName, uint pos, int value);
int 	getArrayValue(char *arrayName, uint pos);
void 	clearLocalVariables();

void initFunctionArgsLogic();
void init();

%}
                   
%union {
	int 	numVal;
	char*	stringVal;
	char	charVal;
	float 	floatVal;
}

%start 	check
%token  MAIN IF ELSE FOR WHILE DO RETURN DEFTYPE OBJECT CONST FUNC DEF ARROW O_PAR C_PAR O_BRACE C_BRACE EQUALS NOT_EQUALS OP_EQUALS OP_ADDEQ OP_SUBEQ DOT SEMICOLON DADD DSUB COMMA COLON O_BRACKET C_BRACKET 
%token  <numVal> TYPE_NUM TYPE_BOOL
%token 	<charVal> TYPE_CHAR
%token 	<stringVal> TYPE_STR TYPE ID
%token  <floatVal> TYPE_NFLOAT
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

function_declaration			: function_header instructions_block	{ 
						printFunctionInfo(); 
						clearFunctionArgsLogic();
						clearLocalVariables();
						functionParsing = 0;
						}
					;

function_header				: FUNC ID O_PAR function_parameters C_PAR ARROW TYPE	{ functionInfo = mp(string($2), string($7)); functionParsing = 1; }
					| FUNC ID O_PAR C_PAR ARROW TYPE 			{ functionInfo = mp(string($2), string($6)); functionParsing = 1; }
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

variable_declaration			: ID					{ declareVariable($1, "float", 0, functionParsing); }
					| ID O_BRACKET TYPE_NUM C_BRACKET	{ declareArray($1, "float", $3, functionParsing); }
					| ID OP_EQUALS arithmetic_expression_1	{ declareVariable($1, "int", $3, functionParsing); }
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

arithmetic_expression_6				: arithmetic_expression_6 MUL arithmetic_expression_term        { $$ = $1 * $3; }
						| arithmetic_expression_6 DIV arithmetic_expression_term        { $$ = $1 / $3; }
						| arithmetic_expression_6 MOD arithmetic_expression_term        { $$ = $1 % $3; }
						| arithmetic_expression_term                                    { $$ = $1;}
						;

arithmetic_expression_term			: O_PAR arithmetic_expression_1 C_PAR				{ $$ = $2; }
						| operand                                                       { $$ = $1; }
						;
                                                                                 
operand						: TYPE_NUM                              { $$ = $1; }
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
	return true;
}

int printFunctionInfo() {
	std::cout<<dotsLineStr;
 	std::cout<<"Function name: "<<functionInfo.first<<'\n';
	std::cout<<"Function return value: "<<functionInfo.second<<'\n';
	std::cout<<"Number of arguments: "<< thisFunctionArgs.size()<<'\n';
	for (uint i=0;i<thisFunctionArgs.size();++i) {
		printFunctionArg(thisFunctionArgs[i]);
	}
	std::cout<<"Local variables: "<< localV.size() << '\n';
	for (auto var : localV) {
	 	std::cout<<var.second.second<<' '<<var.first<<'\n';
	}
	std::cout<<"Local arrays: "<< localArrs.size() << '\n';
	for (auto arr : localArrs) {
		std::cout<<arr.second.second<<' '<<arr.first<<'['<<arr.second.first.size()<<"]\n";
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
		case 2: std::cout<<arg.second.stringUnionMember.stringVal; break;
		case 3: std::cout<<std::setprecision(3)<<std::fixed<<arg.second.floatUnionMember.floatVal; break;
		case 4: std::cout<<arg.second.charUnionMember.charVal; break;
		default:std::cout<<"none"; break;
	}
	std::cout<<'\n';
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

bool declareVariable(char *variableName, char* variableType, int value, int local) {
	string name(variableName);	
	if (local == 1 && localV.count(name)) {
		return false;
	} else if (local == 2 && globalV.count(name)) {
		return false;
	}
	string type(variableType);
	if (local == 1) {
		localV[name] = mp(value,type);
	} else {
		globalV[name] = mp(value,type);
	}
	return true;
}

bool declareArray(char *arrayName, char* variableType, uint arraySize, int local) {       
	string name(arrayName);	
	if (local == 1 && localArrs.count(name)) {
		return false;
	} else if (local == 2 && globalArrs.count(name)) {
		return false;
	}
	string type(variableType);
	if (type != "int"){
		arraySize = 1;
	}  
	vector<int>arr(arraySize, 0);
	if (local == 1) {
		localArrs[name] = mp(arr,type);
	} else {
		globalArrs[name] = mp(arr,type);
	}
	return true;	
}

bool setVariableValue(char *variableName, int value) {
 	string name(variableName);
	bool res = false;
	if (localV.count(name)) {
		res = true;
		localV[name].first = value;
	} else if (globalV.count(name)) {
		res = true;
		globalV[name].first = value;
	}
	return true;
}

int getVariableValue(char *variableName) {
	string name(variableName);
	if (localV.count(name)){
		return localV[name].first;
	}
	if (globalV.count(name)){
		return globalV[name].first;
	}
	return ERROR;
}

bool setArrayValue(char *arrayName, uint pos, int value) {                 
	string name(arrayName);
	bool res = false;
	if (localArrs.count(name)) {
		if (pos < localArrs[name].first.size()) {
			localArrs[name].first[pos] = value;	
		}
	} else if (globalArrs.count(name)) {
	 	if (pos < globalArrs[name].first.size()) {
		        globalArrs[name].first[pos] = value;
		}
	}
	return res;
}

int getArrayValue(char *arrayName, uint pos) {
        string name(arrayName);
	if (localArrs.count(name)) {
		if (pos < localArrs[name].first.size()) {
			return localArrs[name].first[pos];	
		}
	} else if (globalArrs.count(name)) {
	 	if (pos < globalArrs[name].first.size()) {
		        return globalArrs[name].first[pos];
		}
	}
	return ERROR;
}

void clearLocalVariables() {
 	localV.clear();
	localArrs.clear();
}

void initFunctionArgsLogic() {
	functionArgType['i'] = 5;
	functionArgType['b'] = 6;
	functionArgType['s'] = 7;
	functionArgType['f'] = 8;
	functionArgType['c'] = 9;
}

void init() {
 	initFunctionArgsLogic();
}               
 
int main() {
	init();             
	return yyparse();
}