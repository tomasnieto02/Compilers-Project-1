%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX_STRING_LENGTH 20
 /* Código por Nieto Rodríguez Tomás Andrés */
 /* Code by Tomás Nieto */
 /* Declaración de contadores y arreglos de tablas pre-existentes, servirán para imprimir los tokens. */
 /*Declaration of pre-existing counters and table arrays, which will be used to print tokens.*/
int symbol_pos = 0;
int literal_real_num_pos = 0;
int literal_int_num_pos = 0;
int literal_str_pos = 0;
int literal_char_pos = 0;
char *RelOp[] = {"^^", "^”", "==", "^^=", "^”=", "<>"};
char *ReservedWords[] = {"cadena", "caracter", "else", "entero", "For", "if", "real", "return", "void", "while"};
char *AsigOp[] = {"~", "+~", "-~", "*~", "/~", "$~"};

 /* Declaración de tipos de datos utilizados en las tablas */
 /* Declaration of data types used in table arrays */
typedef struct {
    int pos;
    char name[100];
    int type;
} Symbol;

typedef struct {
    int pos;
    char data[100];
} Literal;
 /* Declaración del arreglo dinámico para guardar los mensajes de error */
 /* Declaration of the dynamic array used to store error messages */
typedef struct {
    char **messages;
    int size;
    int capacity;
} ErrorList;

 /* Inicialización del arreglo de errores */
 /* Initialization of the error array */
void initErrorList(ErrorList *list, int initial_capacity) 
{
    list->messages = (char **)malloc(initial_capacity * sizeof(char *));
    list->size = 0;
    list->capacity = initial_capacity;
}
 /* Función para añadir elementos al arreglo de errores */
 /* Function used to add elements into the error array */
void addError(ErrorList *list, const char *message) 
{
    if (list->size >= list->capacity) 
	{
        list->capacity *= 2;
        list->messages = (char **)realloc(list->messages, list->capacity * sizeof(char *));
    }
    list->messages[list->size] = (char *)malloc(strlen(message) + 1);
    strcpy(list->messages[list->size], message);
    list->size++;
}

 /* Liberación de la memoria usada para el arreglo de errores */
 /* Function used to free memory used by error array */
void freeErrorList(ErrorList *list) 
{
    for (int i = 0; i < list->size; i++) 
	{
        free(list->messages[i]);
    }
    free(list->messages);
}

 /* Declaración de tablas de literales */
 /* Declaration of literal tables */

Symbol symbol_table[1000];
Literal literal_real_numbers[1000];
Literal literal_integer_numbers[1000];
Literal literal_strings[1000];
Literal literal_characters[1000];

 /* Funciones para añadir elementos a las tablas de literales */
 /* Functions used to add elements into the literal tables */
void add_literal_int_number(char *data)
{
	strcpy(literal_integer_numbers[literal_int_num_pos].data, data);
	literal_integer_numbers[literal_int_num_pos].pos = literal_int_num_pos;
	literal_int_num_pos++;
}

void add_literal_real_number(char *data)
{
	strcpy(literal_real_numbers[literal_real_num_pos].data, data);
	literal_real_numbers[literal_real_num_pos].pos = literal_real_num_pos;
	literal_real_num_pos++;
}

void add_literal_string(char *data)
{
	strcpy(literal_strings[literal_str_pos].data, data);
	literal_strings[literal_str_pos].pos = literal_str_pos;
	literal_str_pos++;
}

void add_literal_char(char *data)
{
	strcpy(literal_characters[literal_char_pos].data, data);
	literal_characters[literal_char_pos].pos = literal_char_pos;
	literal_char_pos++;
}

 /* Algoritmo de busqueda lineal para encontrar elementos en tablas pre-existentes */
 /* Linear search algorithm used to find elements in pre-existing table arrays */ 
int search(char *match, char *arr[], int size)
{
	for(int i = 0; i < size; i++)
	{
		if(strcmp(match, arr[i]) == 0)
		{
			return i;
		}
	}
	return -1;
}

 /* Algoritmo de busqueda lineal para encontrar elementos en la tabla de identificadores */
 /* Linear search algorithm used to find elements in the identifier table */
int find_symbol(char *name) {
    for (int i = 0; i < symbol_pos; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return symbol_table[i].pos; // Devuelve la posición si se encuentra
        }
    }
    return -1; // Devuelve -1 si no se encuentra
}
 /* Función para añadir simbolos a la tabla de identificadores */
 /* Function used to add symbols into the identifier table */

int add_symbol(char *name, int type)
{
	int pos = find_symbol(name);
    if (pos == -1) 
	{ // Si no se encontró, se agrega el símbolo
	  // If not found, the symbol is added
        strcpy(symbol_table[symbol_pos].name, name);
        symbol_table[symbol_pos].pos = symbol_pos;
        symbol_table[symbol_pos].type = type;
        symbol_pos++;
        pos = symbol_pos - 1;
	}
	return pos;
}

ErrorList errors;
%}

 //Expresiones regulares
 // Regular expressions

DIGIT [0-9]
REAL {DIGIT}+\.{DIGIT}+|\.{DIGIT}+
IDENT [a-zA-Z]([a-zA-Z]|[0-9]){0,5}_
INT_CONST [+-]?{DIGIT}{1,6}
STRING_LITERAL \"[^\"]{1,38}\"
CHAR_LITERAL \'[^\'']\'
ARITH_OP [+\-*/$]
REL_OP (\^\^|\^\"|==|\^\^=|\^\"=|<>)
ASSIGN_OP ("~"|"+~"|"-~"|"*~"|"~"|"$~")
SPECIAL [(){}[\]&,:]
RES_WORD ("cadena"|"caracter"|"else"|"entero"|"For"|"if"|"real"|"return"|"void"|"while")
ILLEGAL_ID [a-zA-Z]{DIGIT}

%%
 /* Clase 0: Palabras reservadas */
 /* Class 0: Reserved words */
{RES_WORD} {
    int index = search(yytext, ReservedWords, sizeof(ReservedWords)/sizeof(ReservedWords[0]));
    printf("(0, %d)\n", index); /* Palabra reservada */
}

 /* Clase 1: Operadores aritméticos */
 /* Class 1: Arithmetic operators */
{ARITH_OP} { 
	printf("(1, %s)\n", yytext); 
}

 /* Clase 2: Operadores de asignación */
 /* Class 2: Assignment operators */
{ASSIGN_OP} { 
	int value = search(yytext, AsigOp, sizeof(AsigOp)/sizeof(AsigOp[0]));
	printf("(2, %s)\n", yytext); 
}

 /* Clase 3: Símbolos especiales */
 /* Clase 3: Special symbols */
{SPECIAL} { 
	printf("(3, %s)\n", yytext); 
}

 /* Clase 4: Operadores relacionales */
 /* Clase 4: Relational operators */
{REL_OP} { 
    int value = search(yytext, RelOp, sizeof(RelOp)/sizeof(RelOp[0])); 
    printf("(4, %d)\n", value);
}

 /* Clase 5: Identificadores */
 /* Clase 5: Identifiers */
{IDENT} { 
	// Se obtiene la posición al añadir el símbolo o al buscar en la tabla
	// The position is retrieved when adding a symbol and searching in the table
    int pos = add_symbol(yytext, -2);
	printf("(5, %d)\n", pos);
}

 /* Clase 6: Constantes numéricas enteras */
 /* Clase 6: Integer numeric constants */
{INT_CONST} { 
	printf("(6, %d)\n", literal_int_num_pos); 
	add_literal_int_number(yytext); 
}

 /* Clase 7: Constantes numéricas reales */
 /* Class 7: Numeric real constants */
{REAL} { 
	printf("(7, %d)\n", literal_real_num_pos); 
	add_literal_real_number(yytext); 
}

 /* Clase 8: Constantes cadenas */
 /* Class 8: String constants */
{STRING_LITERAL} { 
	printf("(8, %d)\n", literal_str_pos); 
	add_literal_string(yytext); 
}

 /* Clase 9: Constantes carácter */
 /* Class 9: Character constants */
{CHAR_LITERAL} { 
	printf("(9, %d)\n", literal_char_pos); 
	add_literal_char(yytext); 
}

 /* Espacios y saltos de línea */
 /* Spacing and line breaks */
[ \t\n]+ { /* Ignorar / Ignore */ }

 /* Manejo de errores */
 /* Error handling */
. {
    char error_message[100];
    sprintf(error_message, "Lexical error: %s", yytext);
    addError(&errors, error_message);
}

{ILLEGAL_ID} {
	// Ejemplos de ID's ilegales: b2, c4, a8
	// Examples of illegal ID's: b2, c4, a8
    char error_message[100];
    sprintf(error_message, "Lexical error: %s", yytext);
    addError(&errors, error_message);
}


%%

int yywrap()
{
    return 1;
}

int main(int argc, char **argv)
{
 /* Inicialización del arreglo de errores */
 /* Initialization of error array */
	initErrorList(&errors, 10);
	if (argc < 2)
	{
		printf("Usage: %s <source-file>\n", argv[0]);
		exit(1);
	}
 /* Manejo de archivo */
 /* File handling */
	FILE *source_file = fopen(argv[1], "r");
	
	if (!source_file)
	{
		printf("Error: Cannot open the source file %s\n", argv[1]);
		exit(1);
	}
 
 /* Impresión de tokens */
 /* Token printing */
	printf("Tokens\n");
	
	yyin = source_file;
	yylex();
	
 /* Impresión de tablas */
 /*Table printing */
	printf("\n Symbol Table:\n");
	for(int i = 0; i < symbol_pos; i++)
	{
		printf("Pos: %d, Name: %s\n", symbol_table[i].pos, symbol_table[i].name);
	}
	
	printf("\n Literal Real Table:\n");
	for(int i = 0; i < literal_real_num_pos; i++)
	{
		printf("Pos: %d, Data: %s\n", literal_real_numbers[i].pos, literal_real_numbers[i].data);
	}

	printf("\n Literal Integer Table:\n");
	for(int i = 0; i < literal_int_num_pos; i++)
	{
		printf("Pos: %d, Data: %s\n", literal_integer_numbers[i].pos, literal_integer_numbers[i].data);
	}
	
	
	printf("\n String Literal Table\n");
	for(int i = 0; i < literal_str_pos; i++)
	{
		printf("Pos: %d, Data: %s\n", literal_strings[i].pos, literal_strings[i].data);
	}

	printf("\n Character Literal Table\n");
	for(int i = 0; i < literal_char_pos; i++)
	{
		printf("Pos: %d, Data: %s\n", literal_characters[i].pos, literal_characters[i].data);
	}
 /* Impresión de errores */
 /* Error printing */
	printf("\nErrors\n");
	if (errors.size > 0) {
        printf("Errors found:\n");
        for (int i = 0; i < errors.size; i++) 
		{
            printf("%s\n", errors.messages[i]);
        }
    }
 /* Liberación de memoria del arreglo dinámico de errores */
 /* Dynamic error array memory release */
	freeErrorList(&errors);
	fclose(source_file);
	return 0;
}

			

