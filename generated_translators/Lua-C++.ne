
#The following expressions are the same in every language.

chunk -> _ ( _series_of_statements | class | class_extends) _ {%function(d){
	toReturn = d[1][0];
	if(Array.isArray(toReturn)){
		return d.join("");
	}
	else{
		return d[1][0];
	}
}%}

statement_without_semicolon -> _setVar | _initializeVar | _return | functionCall
_series_of_statements -> statement {%function(d){return d[0];}%} | series_of_statements __ statement {%function(d){return d[0] + "\n" + d[2];}%}

series_of_statements -> statement {%function(d){return d[0];}%} | series_of_statements statement_separator __ statement {%function(d){return d[0] + d[1] + "\n" + d[3];}%}

arithmetic_expression -> expression
boolean_expression -> expression
string_expression -> expression
array_expression -> expression

expression ->  accessArray | this | functionCall | varName | dictionary | declare_new_object
| parentheses_expression | string_to_int | add | subtract | multiply | mod | divide | number | pow | strlen | sin | cos | tan | sqrt | array_length
| String | concatenateString | substring | int_to_string | split | join
| initializerList | range
| false | true | not_equal | greaterThan | compareInts | strcmp | lessThanOrEqual | greaterThanOrEqual | lessThan | and | or | not | arrayContains

statement ->   func | for_loop | typeless_function | typeless_variable_declaration | plusEquals | minusEquals | declare_constant | initializeArray | print | comment | switch | setVar | initializeVar | functionCallStatement | return | if | while | forInRange | exception
class_statement -> constructor | initialize_static_variable_with_value | initialize_instance_variable_with_value | initialize_static_variable | initialize_instance_variable | instance_method | static_method | comment

_class_statements -> class_statements _ class_statement {%function(d){return d[0] +"\n"+ d[2];}%} | class_statement {%function(d){return d[0];}%} | null
class_statements -> class_statement {%function(d){return d[0];}%} | class_statements _ class_statement {%function(d){return d[0] + "\n" + d[2];}%}


type -> boolean | int | string | auto | arrayType | void
caseStatements -> caseStatements _ case {%function(d){return d[0] +"\n"+ d[2];}%} | case
elifStatements -> elifStatements _ elif {%function(d){return d[0] +"\n"+ d[2];}%} | elif #Match a series of elif statements
elifOrElse -> else | elifStatements _ else {%function(d){return d[0] +"\n"+ d[2];}%} #Match a series of elif statements followed by else

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
statement_separator -> _{%function(d){
	return "";
}%}
for_loop -> statement_without_semicolon _ "\n" _ "while" _ __ _ expression _ __ _ "do" _ __ _ series_of_statements _ __ _ statement_without_semicolon _ __ _ "end"{%function(d){
	return "for" + "(" + d[0] + ";" + d[8] + ";" + d[20] + ")" + "{" + d[16] + "}";
}%}
typeless_parameter -> identifier{%function(d){
	return "auto" + " " + d[0];
}%}
typeless_function -> "function" _ __ _ identifier _ "(" _ typeless_parameters _ ")" _ "\n" _ series_of_statements _ __ _ "end"{%function(d){
	return "auto" + " " + d[4] + "(" + d[8] + ")" + "{" + d[14] + "}";
}%}
typeless_variable_declaration -> "local" _ __ _ varName _ "=" _ identifier _ ";"{%function(d){
	return "auto" + " " + d[4] + "=" + d[8] + ";";
}%}
int_to_string -> "tostring" _ "(" _ expression _ ")"{%function(d){
	return "std" + "::" + "to_string" + "(" + d[4] + ")";
}%}
function_call_parameter_separator -> ","{%function(d){
	return ",";
}%}
string_to_int -> "tonumber" _ "(" _ expression _ ")"{%function(d){
	return "atoi" + "(" + d[4] + "." + "c_str" + "(" + ")" + ")";
}%}
array_access_separator -> "]["{%function(d){
	return "][";
}%}
array_access_index -> expression _ "+" _ "1"{%function(d){
	return d[0];
}%}
accessArray -> identifier _ "[" _ array_access_list _ "]"{%function(d){
	return d[0] + "[" + d[4] + "]";
}%}
initializerListSeparator -> ","{%function(d){
	return ",";
}%}
initializerList -> "{" _ _initializerList _ "}"{%function(d){
	return "{" + d[2] + "}";
}%}
keyValue -> identifier _ "=" _ expression{%function(d){
	return "{" + d[0] + "," + d[4] + "}";
}%}
charAt -> expression _ ":" _ "sub(" _ expression _ "+" _ "1" _ "," _ expression _ "+" _ "1" _ ")"{%function(d){
	return d[0] + "[" + d[6] + "]";
}%}
anonymousFunction -> "function" _ "(" _ parameterList _ ")" _ __ _ series_of_statements _ __ _ "end"{%function(d){
	return "[" + "=" + "]" + "(" + d[4] + ")" + "->" + "int" + "{" + d[10] + "}";
}%}
void -> _{%function(d){
	return "void";
}%}
sin -> "math" _ "." _ "sin" _ "(" _ expression _ ")"{%function(d){
	return "std" + "::" + "sin" + "(" + d[8] + ")";
}%}
sqrt -> "math" _ "." _ "sqrt" _ "(" _ expression _ ")"{%function(d){
	return "std" + "::" + "sqrt" + "(" + d[8] + ")";
}%}
cos -> "math" _ "." _ "cos" _ "(" _ expression _ ")"{%function(d){
	return "std" + "::" + "cos" + "(" + d[8] + ")";
}%}
tan -> "math:tan" _ "(" _ expression _ ")"{%function(d){
	return "std" + "::" + "tan" + "(" + d[4] + ")";
}%}
dictionary -> "{" _ keyValueList _ "}"{%function(d){
	return "{" + d[2] + "}";
}%}
keyValueSeparator -> ","{%function(d){
	return ",";
}%}
true -> "true"{%function(d){
	return "true";
}%}
false -> "false"{%function(d){
	return "false";
}%}
compareInts -> arithmetic_expression _ "==" _ arithmetic_expression{%function(d){
	return d[0] + "==" + d[4];
}%}
parentheses_expression -> "(" _ expression _ ")"{%function(d){
	return "(" + d[2] + ")";
}%}
greaterThan -> arithmetic_expression _ ">" _ arithmetic_expression{%function(d){
	return d[0] + ">" + d[4];
}%}
lessThan -> arithmetic_expression _ "<" _ arithmetic_expression{%function(d){
	return d[0] + "<" + d[4];
}%}
pow -> "math" _ "." _ "pow" _ "(" _ arithmetic_expression _ "," _ arithmetic_expression _ ")"{%function(d){
	return "pow" + "(" + d[8] + "," + d[12] + ")";
}%}
_or -> arithmetic_expression _ __ _ "or" _ __ _ arithmetic_expression{%function(d){
	return d[0] + "||" + d[8];
}%}
or -> _or{%function(d){
	return d[0];
}%}
_and -> boolean_expression _ __ _ "and" _ __ _ boolean_expression{%function(d){
	return d[0] + "&&" + d[8];
}%}
and -> _and{%function(d){
	return d[0];
}%}
not -> "not" _ __ _ boolean_expression{%function(d){
	return "!" + d[4];
}%}
_multiply -> arithmetic_expression _ "*" _ arithmetic_expression{%function(d){
	return d[0] + "*" + d[4];
}%}
multiply -> _multiply{%function(d){
	return d[0];
}%}
_divide -> arithmetic_expression _ "/" _ arithmetic_expression{%function(d){
	return d[0] + "/" + d[4];
}%}
divide -> _divide{%function(d){
	return d[0];
}%}
_add -> arithmetic_expression _ "+" _ arithmetic_expression{%function(d){
	return d[0] + "+" + d[4];
}%}
add -> _add{%function(d){
	return d[0];
}%}
_subtract -> arithmetic_expression _ "-" _ arithmetic_expression{%function(d){
	return d[0] + "-" + d[4];
}%}
subtract -> _subtract{%function(d){
	return d[0];
}%}
functionCall -> identifier _ "(" _ functionCallParameters _ ")"{%function(d){
	return d[0] + "(" + d[4] + ")";
}%}
concatenateString -> string_expression _ ".." _ string_expression{%function(d){
	return d[0] + "+" + d[4];
}%}
initializeVar -> _initializeVar _ semicolon{%function(d){
	return d[0] + d[2];
}%}
return -> "return" _ __ _ expression{%function(d){
	return "return" + " " + d[4] + ";";
}%}
varName -> identifier{%function(d){
	return d[0];
}%}
if -> "if" _ __ _ boolean_expression _ __ _ "then" _ __ _ series_of_statements _ __ _ elifOrElse _ __ _ "end"{%function(d){
	return "if" + "(" + d[4] + ")" + "{" + d[12] + "}" + d[16];
}%}
elif -> "elsif" _ __ _ boolean_expression _ __ _ "then" _ __ _ series_of_statements{%function(d){
	return "else" + " " + "if" + "(" + d[4] + ")" + "{" + d[12] + "}";
}%}
plusEquals -> expression _ "+=" _ expression{%function(d){
	return d[0] + "+=" + d[4] + ";";
}%}
minusEquals -> expression _ "-=" _ expression{%function(d){
	return d[0] + "-=" + d[4] + ";";
}%}
else -> "else" _ __ _ series_of_statements{%function(d){
	return "else" + "{" + d[4] + "}";
}%}
while -> "while" _ __ _ boolean_expression _ __ _ series_of_statements _ __ _ "end"{%function(d){
	return "while" + "(" + d[4] + ")" + "{" + d[8] + "}";
}%}
forInRange -> "for" _ __ _ varName _ "=" _ arithmetic_expression _ "," _ arithmetic_expression _ "," _ "1" _ "do" _ __ _ series_of_statements _ __ _ "end"{%function(d){
	return "for" + "(" + "int" + " " + d[4] + "=" + d[8] + ";" + d[4] + "<" + d[12] + ";" + d[4] + "++" + ")" + "{" + d[22] + "}";
}%}
import -> "require" _ __ _ "'" _ expression _ "'"{%function(d){
	return "#include" + " " + "'" + d[6] + ".h'";
}%}
print -> "print" _ "(" _ expression _ ")"{%function(d){
	return "cout" + "<<" + d[4] + ";";
}%}
comment -> "--" _ _string{%function(d){
	return "//" + d[2];
}%}
mod -> arithmetic_expression _ "%" _ arithmetic_expression{%function(d){
	return d[0] + "%" + d[4];
}%}
semicolon -> _{%function(d){
	return ";";
}%}
_setVar -> varName _ "=" _ expression{%function(d){
	return d[0] + "=" + d[4];
}%}
setVar -> _setVar _ semicolon{%function(d){
	return d[0] + d[2];
}%}
boolean -> "boolean"{%function(d){
	return "bool";
}%}
int -> "number"{%function(d){
	return "int";
}%}
string -> "string"{%function(d){
	return "string";
}%}
functionCallStatement -> functionCall _ semicolon{%function(d){
	return d[0] + d[2];
}%}
greaterThanOrEqual -> arithmetic_expression _ ">=" _ arithmetic_expression{%function(d){
	return d[0] + ">=" + d[4];
}%}
lessThanOrEqual -> arithmetic_expression _ "<=" _ arithmetic_expression{%function(d){
	return d[0] + "<=" + d[4];
}%}
strcmp -> string_expression _ "==" _ string_expression{%function(d){
	return d[0] + "." + "compare" + "(" + d[4] + ")";
}%}
array_length -> "#" _ array_expression{%function(d){
	return d[2] + "." + "size" + "(" + ")";
}%}
strlen -> "string" _ "." _ "len" _ "(" _ string_expression _ ")"{%function(d){
	return d[8] + "." + "length" + "(" + ")";
}%}
parameter_separator -> ","{%function(d){
	return ",";
}%}
not_equal -> expression _ "~=" _ expression{%function(d){
	return d[0] + "!=" + d[4];
}%}
