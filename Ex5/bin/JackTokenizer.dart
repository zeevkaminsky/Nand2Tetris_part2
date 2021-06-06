import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:core';


class JackTokenizer
{
  var strings = ["class", "constructor", "function", "method", "field", "static", "var", "int", "char", "boolean","void", "true", "false", "null", "this", "let", "do", "if(", "else", "while", "return"];
	var chars = ['{', '}', '(', ')', '[', ']', '.', ',', ';', '+', '-', '*', '/', '&', '<', '>', '=', '~'];
  var numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];


	
	var currentToken;
	String buffer;
	String cur_char;
	bool eof;
	var myFile;
  var file;
  var inputFile;
  String string;
  int i;
  int length;
	//Opens the input file and gets ready to tokenize it.
	JackTokenizer(String pathInputFile)
  {
    
    inputFile=pathInputFile;
     myFile = new File(inputFile);
     file = myFile.readAsStringSync();
    //index of file
    i = 0;
    
    
		buffer = "";
		currentToken = new List(2);
		cur_char = file[i++];
    length = file.length;
    if(i >= length)
      eof = true;
    else
      eof = false;
  }
	
	
	bool hasMoreTokens()
  {
    
    return !eof;
  }
		
		
		
	void q0()
  {
    if(eof)
			return;
		if(isAlpha(cur_char) || cur_char == '_')
    {
      next_char();
			q1();
			return;
    }
			
		
		if(isNumeric(cur_char))
    {
      next_char();
			q2();
			return;
    }
			
			
		if( isSimbol(cur_char))
    {
      next_char();
			q3();
			return;
    }
			
			
		if( cur_char == '"')
    {
      ignoreChar();
			q4();
			return;
    }
			
			
		if( isSlash(cur_char))
    {
      ignoreChar();
			q5();
			return;
    }
			
			
		ignoreChar();
		q0();
  }
		
			
	void q1()
  {
    
    
    if( isAlpha(cur_char) || cur_char == '_' || isNumeric(cur_char))
    {
      
      next_char();
			q1();
    }
		else
    {
      if( isKeyword(buffer))
				setToken("KEYWORD", buffer);
			else
				setToken("IDENTIFIER", buffer) ;
    }
			
  }
		
				
	void q2()
  {
    if(isNumeric(cur_char))
    {
      next_char();
		  q2();
    }
			
		else
			setToken("INT_CONST", buffer);
  }
	
		
	void q3()
  {
    setToken("SYMBOL", buffer);
  }
		
		
	void q4()
  {
    	if( cur_char != '"')
      {
        next_char();
			  q4();
      }
			
		else
    {
      ignoreChar();
			setToken("STRING_CONST", buffer);
    }
			
  }
	
			
	void q5()
  {
    if( isSlash(cur_char))
    {
      ignoreChar();
			q6();
			return;
    }
			
		
		if( isAsterisk(cur_char))
    {
      ignoreChar();
			q7();
			return;
    }
		
		
		setToken("SYMBOL", "/");
  }
		
		
		
	void q6()
  {
    if( isNewline(cur_char))
    {
      ignoreChar();
			q0();
    }
			
		else
    {
      ignoreChar();
			q6();
    }
			
  }
		
			
	void q7()
  {
    if( isAsterisk(cur_char))
    {
      ignoreChar();
			q8();
    }
			
		else
    {
      ignoreChar();
			q7();
    }
			
  }
		
			
	void q8()
  {
    if( isSlash(cur_char))
    {
      ignoreChar();
			q0();
    }
			
		else
    {
      ignoreChar();
			q7();
    }
			
  }
		
		
			
	void next_char()
  {
    
    buffer += cur_char;
		if( i >= length)
	  	eof = true;
	  else
		  cur_char = file[i++];
  }
	
		
	void ignoreChar()
  {
    
    if( i >= length)
		  eof = true;
  	else
		  cur_char = file[i++];
  }
		
		
	bool isKeyword(String word)
  {
    for (var w in strings)
			if( w == word)
				return true;
		return false;
  }
		
			
	bool isSimbol(String symbol)
  {
    if( symbol == '/')
			return false;
		for ( var c in chars)
			if( c == symbol)
				return true;
		return false;
  }
		
		
	bool isSlash(String symbol)
  {
    return symbol == '/';
  }
		
	
	bool isAsterisk(String symbol)
  {
    return symbol == '*';
  }
		
		
	bool isNewline(String symbol)
  {
    return symbol == '\n' || symbol == '\r';
  }
		
			
	void setToken(String tokenType, String tokenValue)
  {
    	currentToken[0] = tokenType;
	  	currentToken[1] = tokenValue;
  }
	
		
	void advance()
  {
    buffer = "";
		currentToken[1] = "";
		currentToken[0] = "";
		q0();
  }
		
	
	String tokenType()
  {
    return currentToken[0];
  }
		
	
	String keyWord()
  {
    return currentToken[1];
  }
		
		
	String symbol()
  {
    return currentToken[1];
  }
		
		
	String identifier()
  {
    return currentToken[1];
  }
		
	
	int intVal()
  {
      return int.parse(currentToken[1]);
  }
		
	
	String stringVal()
  {

    return (currentToken[1]).substring(1, (currentToken[1].length)-2);
  }


  bool isNumeric(string)
  {
    for(var n in numbers)
    {
      if(string == n)
        return true;
    }
    return false;
  } 
	
  
  
  bool isAlpha(String str)
  {
    if (str == 'a' ||str == 'b' || str == 'c' || str == 'd' || str == 'e' ||
         str == 'f' ||str == 'g' ||str == 'h' ||str == 'i' ||str == 'j' ||str == 'k' ||
         str == 'l' ||str == 'm' ||str == 'n' ||str == 'o' ||str == 'p' ||str == 'q' ||
         str == 'r' ||str == 's' ||str == 't' ||str == 'u' ||str == 'v' ||str == 'w' ||
         str == 'x' ||str == 'y' ||str == 'z' ||
         str == 'A' || str == 'B' ||str == 'C' ||str == 'D' ||str == 'E' ||str == 'F' ||str == 'G' ||str == 'H' ||str == 'I' ||
         str == 'J' ||
         str == 'K' ||
         str == 'L' ||str == 'M' ||str == 'N' ||str == 'O' ||str == 'P' ||str == 'Q' ||str == 'R' ||str == 'S' ||
         str == 'T' ||
         str == 'U' ||
         str == 'V' ||
         str == 'W' ||
         str == 'X' ||
         str == 'Y' ||
         str == 'Z' )
           return true;
        return false;
  }	
}


		

	