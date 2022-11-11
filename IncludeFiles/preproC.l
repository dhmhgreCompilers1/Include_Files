%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <stack> 
std::stack<YY_BUFFER_STATE> yystatebuffer;
FILE *files[3]={0};
int currentfile=0;
FILE *fout;
%}

%x INCLUDE

%%

#include[ ]+[<"] { BEGIN INCLUDE; }
<INCLUDE>[^>"]+ { printf("filename= %s\n",yytext);
				  int c= 0;
				  while( c!= '>' && c!= '\"' ){
				     c = yyinput();
				  }
				  currentfile++;
				  fopen_s(&files[currentfile],yytext,"r");
				  yystatebuffer.push(yy_create_buffer(files[currentfile], YY_BUF_SIZE));
				  yy_switch_to_buffer(yystatebuffer.top());
				  BEGIN INITIAL;
				} 


.|\n { fprintf(fout,"%s",yytext);}

<<EOF>> { fclose(files[currentfile]);
		  yystatebuffer.pop();
		  currentfile--;
		  if (yystatebuffer.empty()){
			  yyterminate(); 
		  }
		  else{			  
			  yy_switch_to_buffer(yystatebuffer.top());			  
		  }
		}

%%

int main(int argc, char *argv[]){
	
	fopen_s(&files[currentfile],argv[1],"r");
	fopen_s(&fout,"results.txt","w");
	yystatebuffer.push(yy_create_buffer(files[currentfile], YY_BUF_SIZE));
	yy_switch_to_buffer(yystatebuffer.top());
	//yyin = files[0];
	yylex();
	fclose(files[0]);
	fclose(fout);
return 0;
}