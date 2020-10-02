%{	/*parse.y
	 *编译工具：win_bison+gcc
	 */
#include <stdio.h>
#include <ctype.h>
#include <math.h>
#define STACK_LEN 1111
extern FILE *yyin;
enum Type{INT,FLOAT,ERR} type[STACK_LEN];//type stack
int size=0;
enum Type pop();
void push(enum Type t);
%}
%union {
	int i;
	float f;
}
%token <i>NUM ADD DOT SUB MUL DIV LP RP

%start E
%%
E:T {
	enum Type t=pop();
	if(t==ERR)
		yyerror("E->T: type error");
	else if(t==INT){
		$<i>$=$<i>1;
		push(INT);
		printf("int E->T E=%d\n",$<i>$);
	}
	else if(t==FLOAT){
		$<f>$=$<f>1;
		push(FLOAT);
		printf("float E->T E=%f\n",$<f>$);
	}
}
|E ADD T {
	enum Type t1,t3;
	t3=pop();
	t1=pop();
	if(t1==ERR||t3==ERR)
		yyerror("E->E+T: type error");
	else if(t1==INT&&t3==INT){
		$<i>$=$<i>1+$<i>3;
		push(INT);
		printf("int E->E+T E=%d\n",$<i>$);
	}
	else if(t1==FLOAT||t3==FLOAT){
		if(t1==FLOAT&&t3==FLOAT) $<f>$=$<f>1+$<f>3;
		else if(t1==FLOAT&&t3==INT) $<f>$=$<f>1+$<i>3;
		else if(t1==INT&&t3==FLOAT) $<f>$=$<i>1+$<f>3;
		push(FLOAT);
		printf("float E->E+T E=%f\n",$<f>$);
	}
}
|E SUB T {
	enum Type t1,t3;
	t3=pop();
	t1=pop();
	if(t1==ERR||t3==ERR)
		yyerror("E->E-T: type error");
	else if(t1==INT&&t3==INT){
		$<i>$=$<i>1-$<i>3;
		push(INT);
		printf("int E->E-T E=%d\n",$<i>$);
	}
	else if(t1==FLOAT||t3==FLOAT){
		if(t1==FLOAT&&t3==FLOAT) $<f>$=$<f>1-$<f>3;
		else if(t1==FLOAT&&t3==INT) $<f>$=$<f>1-$<i>3;
		else if(t1==INT&&t3==FLOAT) $<f>$=$<i>1-$<f>3;
		push(FLOAT);
		printf("float E->E-T E=%f\n",$<f>$);
	}
}

T:F		{
	enum Type t=pop();
	if(t==ERR)
		yyerror("T->F: type error");
	else if(t==INT){
		$<i>$=$<i>1;
		push(INT);
		printf("int T->F T=%d\n",$<i>$);
	}
	else if(t==FLOAT){
		$<f>$=$<f>1;
		push(FLOAT);
		printf("float T->F T=%f\n",$<f>$);
	}
}
|T MUL F {
	enum Type t1,t3;
	t3=pop();
	t1=pop();
	if(t1==ERR||t3==ERR)
		yyerror("T->T*F: type error");
	else if(t1==INT&&t3==INT){
		$<i>$=$<i>1*$<i>3;
		push(INT);
		printf("int T->T*F T=%d\n",$<i>$);
	}
	else if(t1==FLOAT||t3==FLOAT){
		if(t1==FLOAT&&t3==FLOAT) $<f>$=$<f>1*$<f>3;
		else if(t1==FLOAT&&t3==INT) $<f>$=$<f>1*$<i>3;
		else if(t1==INT&&t3==FLOAT) $<f>$=$<i>1*$<f>3;
		push(FLOAT);
		printf("float T->T*F T=%f\n",$<f>$);
	}
}
|T DIV F {
	enum Type t1,t3;
	t3=pop();
	t1=pop();
	if(t1==ERR||t3==ERR)
		yyerror("T->T/F: type error");
	else if(t1==INT&&t3==INT){
		$<i>$=$<i>1/$<i>3;
		push(INT);
		printf("int T->T/F T=%d\n",$<i>$);
	}
	else if(t1==FLOAT||t3==FLOAT){
		if(t1==FLOAT&&t3==FLOAT) $<f>$=$<f>1/$<f>3;
		else if(t1==FLOAT&&t3==INT) $<f>$=$<f>1/$<i>3;
		else if(t1==INT&&t3==FLOAT) $<f>$=$<i>1/$<f>3;
		push(FLOAT);
		printf("float T->T/F T=%f\n",$<f>$);
	}
}

F:NUM	{$<i>$=$1;push(INT);printf("int F->num F=%d\n",$<i>$);}
|NUM DOT NUM {
		float f=$3;
		while(f>=1) f/=10;
		$<f>$=$1+f;
		push(FLOAT);
		printf("float F->num.num F=%f\n",$<f>$);
}
|LP E RP {
	enum Type t=pop();
	if(t==ERR)
		yyerror("F->(E): type error");
	else if(t==INT){
		$<i>$=$<i>2;
		push(INT);
		printf("int F->(E) F=%d\n",$<i>$);
	}
	else if(t==FLOAT){
		$<f>$=$<f>2;
		push(FLOAT);
		printf("float F->(E) F=%f\n",$<f>$);
	}
}
;
%%

enum Type pop(){
	if(size<=0) return ERR;
	size--;
	return type[size];
}

void push(enum Type t){
	if(size>=STACK_LEN){
		yyerror("Error: Stack Overflow.");
	}
	type[size]=t;
	size++;
}

int yyerror(char *msg){
	printf("Error: %s \n", msg);
}

int main(int argc,char** argv){
	if(argc > 1)
        yyin = fopen(argv[1], "r");
    else
        yyin = stdin;
	return yyparse();
}