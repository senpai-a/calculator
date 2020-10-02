%{
	/*word.lex
	 *编译工具：win_flex+gcc
	 *依赖：parse.tab.h 由parse.y生成
	 */
#include <stdio.h>
#include <ctype.h>
#include "parse.tab.h"
%}

num		[0-9]+
ws		[ \t\n]+

%option yylineno
%%
{ws} 	{}
{num}	{yylval.i=atoi(yytext);return NUM;}
"+" 	{return ADD;}
"-" 	{return SUB;}
"*" 	{return MUL;}
"/" 	{return DIV;}
"."		{return DOT;}
"(" 	{return LP;}
")" 	{return RP;}
%%
 int yywrap(){
	return 1;
 }