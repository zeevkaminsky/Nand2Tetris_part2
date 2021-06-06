import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:core';
import '../bin/XMlWriter.dart';
import '../bin/JackTokenizer.dart';

class CompilationEngine
{
  JackTokenizer tokenizer;
	XMLwriter xmlWriter;
	
	var op = ["+", "-", "*", "/", "|", "=", "<", ">", "&"];
	var unaryOp = ["-", "~"];
	var keywordConstant = ["true", "false", "null", "this"];
	
	CompilationEngine(String inputFile, String outputFile)
  {
    tokenizer = new JackTokenizer(inputFile);
		xmlWriter = new XMLwriter(outputFile);;
		tokenizer.advance();
  }
		
		
		
	void nextToken()
  {
    tokenizer.advance();
  }
		
		
	void writeTerminal()
  {
    xmlWriter.writeElement(tokenizer.tokenType(), tokenizer.keyWord());
  }
		
		
	void writeNextToken()
  {
    writeTerminal();
		nextToken();
  }
		
	
		
	void compileClass()
  {
    xmlWriter.writeStartTag("class");
		writeNextToken(); // write class keyWord
		writeNextToken(); // write className
		writeNextToken(); // write '{' symbol
		
		compileClassVarDec();
		compileSubroutine();
		
		writeNextToken(); // write '{' symbol
		xmlWriter.writeEndTag("class");
		
  }
	
	
	void compileClassVarDec()
  {
    while (isNextTokClassVarDec())
    {
      xmlWriter.writeStartTag("classVarDec");
			writeNextToken();		// 'static'/'field'
			writeNextToken();		// type
			writeNextToken();		// varName
			
			while (isNextTokComma())
      {
        writeNextToken();	// ','
				writeNextToken();	// varName
      }
				
			
			writeNextToken();		// ';'
			xmlWriter.writeEndTag("classVarDec");
    }
			
  }
		
	
	bool isNextTokClassVarDec()
  {
    return tokenizer.keyWord() == "static" || tokenizer.keyWord() == "field";
  }
		
		
	bool isNextTokComma()
  {
    return tokenizer.keyWord() == ",";
  }
		
	
	void compileSubroutine()
  {
    while (isNextTokSubroutine())
    {
      xmlWriter.writeStartTag("subroutineDec");
			writeNextToken();		// ('constructor'|'function'|'method')
			writeNextToken();		// ('void'|'type')
			writeNextToken();		// subroutineName
			writeNextToken();		// '('
			
			compileParameterList();
			
			writeNextToken();		// ')'
			
			compileSubroutineBody();
			
			xmlWriter.writeEndTag("subroutineDec");
    }
			
  }
	
		
			

	bool isNextTokSubroutine()
  {
    String keyWord = tokenizer.keyWord();
		return  keyWord == "constructor" || keyWord == "function" || keyWord == "method" ;
  }
		
	
	void compileParameterList()
  {
    xmlWriter.writeStartTag("parameterList");
		
		if (isNextTokType())
    {
      writeNextToken(); // Type
			writeNextToken(); // Var name
			
			while (isNextTokComma())
      {
        writeNextToken(); // ','
				writeNextToken() ;// Type
				writeNextToken(); // Var name
      }
				
    }		
		xmlWriter.writeEndTag("parameterList");
    
			
  }
		
		
	bool isNextTokType()
  {
    return tokenizer.tokenType() != "SYMBOL"; // if not exist parm so token is type 
  }
		
		
	void compileSubroutineBody()
  {
    xmlWriter.writeStartTag("subroutineBody");
		
		writeNextToken(); // '{'
		
		compileVarDec();
		compileStatements();
		
		writeNextToken() ;// '}'
	
		xmlWriter.writeEndTag("subroutineBody");
  }
		
	
	void compileVarDec()
  {
    while (isNextTokVarDec())
    {
      xmlWriter.writeStartTag("varDec");
			
			writeNextToken() ;// 'var'
			writeNextToken(); // type
			writeNextToken() ;// var name
			
			while (isNextTokComma())
      {
        writeNextToken(); // ','
				writeNextToken(); // var name
      }
				
				
			writeNextToken(); // ';'
			xmlWriter.writeEndTag("varDec");
    }
			
  }
		
			
	bool isNextTokVarDec()
  {
    return tokenizer.keyWord() == "var";
  }
		
		
	void compileStatements()
  {
    xmlWriter.writeStartTag("statements");
		
		while (isNextTokStatment())
    {
      if (isNextTokDo()) 
				compileDo();
			if (isNextTokLet())
				compileLet();
			if (isNextTokWhile())
				compileWhile();
			if (isNextTokReturn())
				compileReturn();
			if (isNextTokIf())
				compileIf();
    }
			
		
		xmlWriter.writeEndTag("statements");
  }
		
		
	bool isNextTokStatment()
  {
    String k = tokenizer.keyWord();
		return  k == "let" || k == "if" || k == "while" || k == "do" || k == "return";
  }
		
	
	
	bool isNextTokReturn()
  {
    return tokenizer.keyWord() == "return";
  }
		
	
	bool isNextTokWhile()
  {
    return tokenizer.keyWord() == "while";
  }
		
		
	bool isNextTokLet()
  {
    return tokenizer.keyWord() == "let";
  }
		
		
	bool isNextTokDo()
  {
    return tokenizer.keyWord() == "do";
  }
		
		
	bool isNextTokIf()
  {
    return tokenizer.keyWord() == "if";
  }
		
	
	void compileDo()
  {
    xmlWriter.writeStartTag("doStatement");
		
		writeNextToken(); // 'do'
		
		compileSubroutineCall();
		
		writeNextToken(); // ';'
		
		xmlWriter.writeEndTag("doStatement");
  }
		
	
	void compileLet()
  {
    xmlWriter.writeStartTag("letStatement");
		
		writeNextToken(); // 'let'
		writeNextToken(); // varName
		
		if (isNextTok("["))
    {
      writeNextToken(); // '['
			
			compileExpression();
			
			writeNextToken(); // ']'
    }
			
		writeNextToken(); // '='
		
		compileExpression();
		
		writeNextToken(); // ';'
		
		xmlWriter.writeEndTag("letStatement");

  }
  

		


	bool isNextTok(String s)
  {
    return tokenizer.keyWord() == s;
  }
		
	
	void compileWhile()
  {
    xmlWriter.writeStartTag("whileStatement");
		
		writeNextToken(); // 'while'
		writeNextToken() ;// '('
		
		compileExpression() ;
		
		writeNextToken(); // ')'
		writeNextToken() ;// '{'
		
		compileStatements();
		
		writeNextToken(); // '}'
		
		xmlWriter.writeEndTag("whileStatement");
  }
		
	
	void compileReturn()
  {
    xmlWriter.writeStartTag("returnStatement");
		
		writeNextToken(); // 'return'
		
		if (isNextTokExpression())
			compileExpression();
		
		writeNextToken() ;// ';'
		
		xmlWriter.writeEndTag("returnStatement");
  }
		
	
	bool isNextTokExpression()
  {
    return tokenizer.keyWord() != ")" && tokenizer.keyWord() != ";";
  }
		
		
	
	void compileIf()
  {
    xmlWriter.writeStartTag("ifStatement");
		
		writeNextToken(); // 'if'
		writeNextToken(); // '('
		
		compileExpression() ;
		
		writeNextToken(); // ')'
		writeNextToken(); // '{'
		
		compileStatements() ;
		
		writeNextToken(); // '}'
		
		xmlWriter.writeEndTag("ifStatement");
  }
		
	
	
	void compileExpression()
  {
    xmlWriter.writeStartTag("expression");
		
		compileTerm();
		
		while (isNextTokOp())
    {
      writeNextToken(); // op
			compileTerm();

    }
			
			
		xmlWriter.writeEndTag("expression");
	
  }
		
	bool isNextTokOp()
  {
    for (var o in op)
    {
      if (o == tokenizer.keyWord())
				return true;
    }
			
		return false;
  }
		
		
	bool	isNextTokUnaryOp()
  {
    for(var o in unaryOp)
    {
      if (o == tokenizer.keyWord())
				return true;
    }
			
		return false;
  }
		
		
	bool isKeywordConstant()
  {
    for (var c in keywordConstant)
    {
      if (c == tokenizer.keyWord())
				return true;
    }
			
		return false;
  }
		
	
	void compileTerm()
  {
    xmlWriter.writeStartTag("term");
		
									//integerConstant | stringConstant | keyWordConstant
		
		if (isTypeNextTok("INT_CONST") || isTypeNextTok("STRING_CONST") || isKeywordConstant())
    {
      writeNextToken()	;	// write constant
			xmlWriter.writeEndTag("term");
			return;
    } 
			
			
			
		if (isNextTok("("))	// '(' expression ')'
    {
      writeNextToken();		// '('
			compileExpression();
			writeNextToken();		// ')'
			xmlWriter.writeEndTag("term");
			return;
    }		
			
			
		if (isNextTokUnaryOp())//unaryOp term
    {
      writeNextToken();		// 'unaryOp'
			compileTerm() ;
			xmlWriter.writeEndTag("term");
			return;
    }		
			
		
		//  varName | varName '[' expression ']' | subroutineCall
		
		String nextTokenType = tokenizer.tokenType();
		String nextTokenValue = tokenizer.keyWord();
		
		String nextNextValue = NextNextTok();
		
		
		if (nextTokenType == "IDENTIFIER" && nextNextValue == "[")
    {
      xmlWriter.writeElement("IDENTIFIER",nextTokenValue) ;// write var name
			writeNextToken(); // '['
				
			compileExpression();
				
			writeNextToken() ;// ']'
    }
			
			
		else if (nextTokenType == "IDENTIFIER" && nextNextValue == "(")
    {
      xmlWriter.writeElement("IDENTIFIER",nextTokenValue);	//'varName'
			writeNextToken(); // '('
			compileExpressionList();
			writeNextToken(); // ')'
    }
			
			
		else if (nextTokenType == "IDENTIFIER" && nextNextValue == ".")
    {
      xmlWriter.writeElement("IDENTIFIER",nextTokenValue);	// varName
			writeNextToken(); // '.'
			writeNextToken(); // subroutineName
			writeNextToken(); // '('
			compileExpressionList();
			writeNextToken(); // ')'	
    }
			
			
		else if (nextTokenType == "IDENTIFIER")
    {
      xmlWriter.writeElement("IDENTIFIER",nextTokenValue); // write var name
    }
			
			
		xmlWriter.writeEndTag("term");
  }
		
	
	String NextNextTok()
  {
    tokenizer.advance();
		return tokenizer.keyWord();
  }
		
	
	bool isTypeNextTok(String s)
  {
    return tokenizer.tokenType() == s;
  }
		
	
	void compileExpressionList()
  {
    xmlWriter.writeStartTag("expressionList");
		
		if (isNextTokExpression())//TODO
    {
      compileExpression();
			
			while (isNextTokComma())
      {
        writeNextToken(); // ','
				compileExpression();
      }
				
    } 

			
				
		xmlWriter.writeEndTag("expressionList");
  }
		
	 
	
	void compileSubroutineCall([String nextNextValue = ""])
  {
    //xmlWriter.writeStartTag("subroutineCall")
		
		if (nextNextValue == "")
			writeNextToken(); // subroutineName / className / varName
		else 
			xmlWriter.writeElement("IDENTIFIER" , nextNextValue);
		if (!isNextTok("."))
    {
      writeNextToken() ;// '('
			
			compileExpressionList();
			
			writeNextToken(); // ')'
    }
		
		else 
    {
      writeNextToken(); // '.' 
			writeNextToken(); // subroutineName
			writeNextToken(); // '('
			
			compileExpressionList();
			
			writeNextToken(); // ')'
    }
	
  }
		
}
	
	