
#The following expressions are the same in every language.

chunk -> _ ( series_of_statements | class | class_extends) _ {%function(d){
	toReturn = d[1][0];
	if(Array.isArray(toReturn)){
		return d.join("");
	}
	else{
		return d[1][0];
	}
}%}

series_of_statements -> statement {%function(d){return d[0];}%} | series_of_statements statement_separator __ statement {%function(d){return d[0] + d[1] + "\n" + d[3];}%}

arithmetic_expression -> expression
boolean_expression -> expression
string_expression -> expression
array_expression -> expression

statement_with_semicolon -> statement_without_semicolon _ semicolon {% function(d){return d[0] + d[2]; }%}

expression -> string_to_regex | accessArray | this | functionCall | varName | dictionary | declare_new_object
| parentheses_expression | pi | natural_logarithm | absolute_value | floor | ceiling | string_to_int | add | subtract | multiply | mod | divide | number | pow | strlen | asin | acos | atan | sin | cos | tan | sqrt | array_length
| String | concatenateString | substring | int_to_string | split | join | startswith | endswith | globalReplace
| initializerList | range
| false | true | not_equal | greaterThan | compareInts | strcmp | lessThanOrEqual | greaterThanOrEqual | lessThan | and | or | not | arrayContains | stringContains

statement_without_semicolon -> typeless_variable_declaration | setVar | increment | decrement | initializeVar | typeless_initializeVar | functionCall | exception | return | functionCallStatement | plusEquals | minusEquals | declare_constant | initializeArray | print
statement ->   func | statement_with_semicolon | for_loop | typeless_function | comment | switch | if | while | forInRange

class_statement_without_semicolon -> initialize_static_variable_with_value | initialize_instance_variable_with_value | initialize_static_variable | initialize_instance_variable
class_statement_with_semicolon -> class_statement_without_semicolon _ semicolon {% function(d){return d[0] + d[2]; }%}
class_statement -> constructor | instance_method | static_method | comment | class_statement_with_semicolon

_class_statements -> class_statements _ class_statement {%function(d){return d[0] +"\n"+ d[2];}%} | class_statement {%function(d){return d[0];}%} | null
class_statements -> class_statement {%function(d){return d[0];}%} | class_statements _ class_statement {%function(d){return d[0] + "\n" + d[2];}%}


type -> boolean | int | string | auto | arrayType | void | dictionary_type
caseStatements -> caseStatements _ case {%function(d){return d[0] +"\n"+ d[2];}%} | case
elifOrElse -> else | elif

parameterList -> _parameterList | null
_parameterList -> _parameterList _ parameter_separator _ ( parameter | default_parameter ) {%function(d){return d[0]+d[2]+d[4]}%}
| (parameter | default_parameter )

typeless_parameters -> _typeless_parameters | null
_typeless_parameters -> _typeless_parameters _ parameter_separator _ typeless_parameter {%function(d){return d[0]+d[2]+d[4]}%}
| typeless_parameter

functionCallParameters -> functionCallParameters _ function_call_parameter_separator _ ( expression | function_call_named_parameter) {% function(d) {return d.join(""); } %} | (expression | function_call_named_parameter) | null

keyValueList -> _keyValueList
_keyValueList -> _keyValueList _ keyValueSeparator _ keyValue {%function(d){return d[0]+d[2]+d[4]}%}
| keyValue

_initializerList -> _initializerList _ initializerListSeparator _ expression {%function(d){return d[0]+d[2]+d[4]}%}
| expression

array_access_list -> array_access_index | array_access_list array_access_separator array_access_index {%function(d){return d[0]+d[1]+d[2]}%}

# Primitives
# ==========

identifier -> _name {% function(d) {return d[0]; } %}

_name -> [a-zA-Z_] {% id %}
	| _name [\w_] {% function(d) {return d[0] + d[1]; } %}

# Numbers

number -> _number {% function(d) {return parseFloat(d[0])} %}

_posint ->
	[0-9] {% id %}
	| _posint [0-9] {% function(d) {return d[0] + d[1]} %}

_int ->
	"-" _posint {% function(d) {return d[0] + d[1]; }%}
	| _posint {% id %}

_float ->
	_int {% id %}
	| _int "." _posint {% function(d) {return d[0] + d[1] + d[2]; }%}

_number ->
	_float {% id %}
	| _float "e" _int {% function(d){return d[0] + d[1] + d[2]; } %}


#Strings

String -> "\"" _string "\"" {% function(d) {return '"' + d[1] + '"'; } %}

_string ->
	null {% function() {return ""; } %}
	| _string _stringchar {% function(d) {return d[0] + d[1];} %}

_stringchar ->
	[^\\"] {% id %}
	| "\\" [^] {% function(d) {return JSON.parse("\"" + d[0] + d[1] + "\""); } %}

# Whitespace
_ -> null | _ [\s] {% function() {} %}
__ -> [\s] | __ [\s] {% function() {} %}


#The next two lines are the languages for the translator.
increment -> expression _ "++"{%function(d){
	return d[0] + "" + "=" + "" + d[0] + "" + "+" + "" + "1";
}%}
statement_separator -> _{%function(d){
	return "";
}%}
split -> expression _ "." _ "split" _ "(" _ expression _ ")"{%function(d){
	return "split" + " " + d[0] + " " + d[8];
}%}
function_call_parameter_separator -> ","{%function(d){
	return " ";
}%}
string_to_int -> "Integer" _ "." _ "parseInt" _ "(" _ expression _ ")"{%function(d){
	return "to" + " " + "integer!" + " " + d[8];
}%}
declare_constant -> "final" __ type __ varName _ "=" _ expression{%function(d){
	return d[4] + "" + ":" + "" + d[8];
}%}
initializeArray -> arrayType __ identifier _ "=" _ array_expression{%function(d){
	return d[2] + "" + ":" + "" + d[6];
}%}
initializerListSeparator -> ","{%function(d){
	return " ";
}%}
initializerList -> "{" _ _initializerList _ "}"{%function(d){
	return "[" + "" + d[2] + "" + "]";
}%}
keyValue -> "put" _ "(" _ identifier _ "," _ expression _ ")"{%function(d){
	return d[4] + " " + d[8];
}%}
sin -> "Math" _ "." _ "sin" _ "(" _ expression _ ")"{%function(d){
	return "(" + "" + "sine/radians" + " " + d[8] + "" + ")";
}%}
sqrt -> "Math" _ "." _ "sqrt" _ "(" _ expression _ ")"{%function(d){
	return "(" + "" + "square-root" + " " + d[8] + "" + ")";
}%}
cos -> "Math" _ "." _ "cos" _ "(" _ expression _ ")"{%function(d){
	return "(" + "" + "cosine/radians" + " " + d[8] + "" + ")";
}%}
tan -> "Math" _ "." _ "tan" _ "(" _ expression _ ")"{%function(d){
	return "(" + "" + "tangent/radians" + " " + d[8] + "" + ")";
}%}
dictionary -> "new" __ "HashMap" _ "<" _ type _ "," _ type _ ">" _ "(" _ ")" _ "{" _ "{" _ keyValueList _ "}" _ "}"{%function(d){
	return "to-hash" + "" + "[" + "" + d[22] + "" + "]";
}%}
keyValueSeparator -> ";"{%function(d){
	return " ";
}%}
true -> "true"{%function(d){
	return "true";
}%}
false -> "false"{%function(d){
	return "false";
}%}
compareInts -> arithmetic_expression _ "==" _ arithmetic_expression{%function(d){
	return d[0] + "" + "=" + "" + d[4];
}%}
parentheses_expression -> "(" _ expression _ ")"{%function(d){
	return "(" + "" + d[2] + "" + ")";
}%}
greaterThan -> arithmetic_expression _ ">" _ arithmetic_expression{%function(d){
	return d[0] + "" + ">" + "" + d[4];
}%}
lessThan -> arithmetic_expression _ "<" _ arithmetic_expression{%function(d){
	return d[0] + "" + "<" + "" + d[4];
}%}
class -> "public" __ "class" __ identifier _ "{" _ class_statements _ "}"{%function(d){
	return "a:" + " " + "make" + " " + "object!" + "" + "[" + "" + d[8] + "" + "]";
}%}
arrayContains -> "Arrays" _ "." _ "asList" _ "(" _ array_expression _ ")" _ "." _ "contains" _ "(" _ expression _ ")"{%function(d){
	return "not" + " " + "none?" + " " + "find" + " " + d[8] + " " + d[18];
}%}
this -> "this" _ "." _ varName{%function(d){
	return "self" + "" + "/" + "" + d[4];
}%}
pow -> "Math" _ "." _ "pow" _ "(" _ arithmetic_expression _ "," _ arithmetic_expression _ ")"{%function(d){
	return "power" + " " + d[8] + " " + d[12];
}%}
_or -> arithmetic_expression _ "||" _ arithmetic_expression{%function(d){
	return d[0] + " " + "or" + " " + d[4];
}%}
or -> _or{%function(d){
	return d[0];
}%}
_and -> boolean_expression _ "&&" _ boolean_expression{%function(d){
	return d[0] + " " + "and" + " " + d[4];
}%}
and -> _and{%function(d){
	return d[0];
}%}
not -> "!" _ boolean_expression{%function(d){
	return "not" + " " + d[2];
}%}
_multiply -> arithmetic_expression _ "*" _ arithmetic_expression{%function(d){
	return d[0] + "" + "*" + "" + d[4];
}%}
multiply -> _multiply{%function(d){
	return d[0];
}%}
_divide -> arithmetic_expression _ "/" _ arithmetic_expression{%function(d){
	return d[0] + "" + "/" + "" + d[4];
}%}
divide -> _divide{%function(d){
	return d[0];
}%}
_add -> arithmetic_expression _ "+" _ arithmetic_expression{%function(d){
	return d[0] + "" + "+" + "" + d[4];
}%}
add -> _add{%function(d){
	return d[0];
}%}
_subtract -> arithmetic_expression _ "-" _ arithmetic_expression{%function(d){
	return d[0] + "" + "-" + "" + d[4];
}%}
subtract -> _subtract{%function(d){
	return d[0];
}%}
functionCall -> identifier _ "(" _ functionCallParameters _ ")"{%function(d){
	return d[0] + " " + d[4];
}%}
concatenateString -> string_expression _ "+" _ string_expression{%function(d){
	return "append" + " " + d[0] + " " + d[4];
}%}
initializeVar -> type __ varName _ "=" _ expression{%function(d){
	return d[2] + "" + ":" + "" + d[6];
}%}
return -> "return" __ expression{%function(d){
	return "return" + " " + d[2];
}%}
varName -> identifier{%function(d){
	return d[0];
}%}
func -> "public" __ "static" __ type __ identifier _ "(" _ parameterList _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return d[6] + "" + ":" + " " + "func" + "" + "[" + "" + d[10] + "" + "]" + "" + "[" + "" + d[16] + "" + "]";
}%}
if -> "if" _ "(" _ expression _ ")" _ "{" _ series_of_statements _ "}" _ elifOrElse{%function(d){
	return "case" + "" + "[" + "" + d[4] + "" + "[" + "" + d[10] + "" + "]" + "" + d[14] + "" + "]";
}%}
elif -> "else" __ "if" _ "(" _ expression _ ")" _ "{" _ series_of_statements _ "}" _ elifOrElse{%function(d){
	return d[6] + "" + "[" + "" + d[12] + "" + "]" + " " + d[16];
}%}
else -> "else" _ "{" _ series_of_statements _ "}"{%function(d){
	return "true" + "" + "[" + "" + d[4] + "" + "]";
}%}
while -> "while" _ "(" _ boolean_expression _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return "while" + "" + "[" + "" + d[4] + "" + "]" + "" + "[" + "" + d[10] + "" + "]";
}%}
forInRange -> "for" _ "(" _ "int" __ varName _ "=" _ arithmetic_expression _ ";" _ varName _ "<" _ arithmetic_expression _ ";" _ varName _ "++" _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return "for" + " " + d[6] + " " + d[10] + " " + d[18] + " " + "1" + "" + "[" + "" + d[30] + "" + "]";
}%}
import -> "import" __ expression _ ";"{%function(d){
	return d[2] + "" + ":" + " " + "load" + " " + "%" + "" + d[2] + "" + ".r";
}%}
print -> "System" _ "." _ "out" _ "." _ "println" _ "(" _ expression _ ")"{%function(d){
	return "print" + " " + d[12];
}%}
comment -> "//" _ _string{%function(d){
	return "comment" + "" + "[" + "" + d[2] + "" + "]";
}%}
mod -> arithmetic_expression _ "%" _ arithmetic_expression{%function(d){
	return "mod" + " " + d[0] + " " + d[4];
}%}
semicolon -> ";"{%function(d){
	return "";
}%}
setVar -> varName _ "=" _ expression{%function(d){
	return d[0] + "" + ":" + " " + d[4];
}%}
parameter -> type __ varName{%function(d){
	return d[0] + "" + "[" + "" + d[2] + "" + "]";
}%}
boolean -> "boolean"{%function(d){
	return "logic!";
}%}
int -> "int"{%function(d){
	return "integer!";
}%}
string -> "String"{%function(d){
	return "string!";
}%}
functionCallStatement -> functionCall _ semicolon{%function(d){
	return d[0] + "" + d[2];
}%}
greaterThanOrEqual -> arithmetic_expression _ ">=" _ arithmetic_expression{%function(d){
	return d[0] + "" + ">=" + "" + d[4];
}%}
lessThanOrEqual -> arithmetic_expression _ "<=" _ arithmetic_expression{%function(d){
	return d[0] + "" + "<=" + "" + d[4];
}%}
switch -> "switch" _ "(" _ expression _ ")" _ "{" _ caseStatements __ default _ "}"{%function(d){
	return "switch/default" + "" + "[" + "" + d[4] + " " + d[10] + "" + "]";
}%}
case -> "case" __ expression _ ":" _ series_of_statements _ "break" _ ";"{%function(d){
	return d[2] + "" + "[" + "" + d[6] + "" + "]";
}%}
foreach -> "for" _ "(" _ type __ expression _ ":" _ expression _ ")" _ "{" _ series_of_statements _ "}"{%function(d){
	return "foreach" + " " + d[6] + " " + d[10] + "" + "[" + "" + d[16] + "" + "]";
}%}
default -> "default" _ ":" _ series_of_statements{%function(d){
	return "][" + "" + d[4];
}%}
substring -> string_expression _ "." _ "substring" _ "(" _ arithmetic_expression _ "," _ arithmetic_expression _ ")"{%function(d){
	return "copy/part" + " " + "skip" + " " + d[0] + " " + d[8] + " " + d[12];
}%}
strcmp -> string_expression _ "." _ "equals" _ "(" _ string_expression _ ")"{%function(d){
	return d[0] + "" + "==" + "" + d[8];
}%}
array_length -> array_expression _ "." _ "length"{%function(d){
	return "length?" + " " + d[0];
}%}
strlen -> string_expression _ "." _ "length" _ "(" _ ")"{%function(d){
	return "length?" + " " + d[0];
}%}
parameter_separator -> ","{%function(d){
	return " ";
}%}
