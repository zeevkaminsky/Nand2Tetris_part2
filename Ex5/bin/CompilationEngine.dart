import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:core';
//import '../bin/XMlWriter.dart';
import '../bin/JackTokenizer.dart';
import '../bin/VMWriter.dart';
import '../bin/SymbolTable.dart';

class CompilationEngine
{
  JackTokenizer tokenizer;
  VMWriter vmWriter;
  SymbolTable symbolTable;
	
  String funcName;
	String funcType;
	String className;

  int ifCounter;
	int whileCounter;


	var op = ["+", "-", "*", "/", "|", "=", "<", ">", "&"];
	var unaryOp = ["-", "~"];
	var keywordConstant = ["true", "false", "null", "this"];
	
	CompilationEngine(String inputFile, String outputFile)
  {
    tokenizer = new JackTokenizer(inputFile);
		vmWriter = new VMWriter(outputFile);
    symbolTable = new SymbolTable();
		tokenizer.advance();
    ifCounter = 0;
		whileCounter = 0;
  }
		
		
		
	void nextToken()
  {
    tokenizer.advance();
  }
	
  
	void compileClass()
  {
    advance(); // write class keyWord
		
		className = tokenizer.keyWord();
		
		advance(); // write className
		advance(); // write '{' symbol
		
		compileClassVarDec();
		compileSubroutine();
		
		advance(); // write '{' symbol
		
  }
	
	
	void compileClassVarDec()
  {
    String kind;
		String type;
		
    while (isNextTokClassVarDec())
    {
      kind = tokenizer.keyWord(); // static/field
			advance();		// 'static'/'field'
			type = tokenizer.keyWord(); // type
			advance()	;	// type
			symbolTable.define(tokenizer.keyWord(), type, kind);
			advance();		// varName
			
			while (isNextTokComma())
      {
        advance();	// ','
				symbolTable.define(tokenizer.keyWord(), type, kind);
				advance();	// varName
      }
			advance();		// ';'
    }
			
  }
		
	
	void compileSubroutine()
  {
    while (isNextTokSubroutine())
    {
      symbolTable.startSubroutine();
			//ifCounter = 0
			//whileCounter = 0

			funcType = tokenizer.keyWord(); //('constructor'|'function'|'method')
			advance();		// ('constructor'|'function'|'method')
			advance();		//  return type ('void'|'type')
			
			
			
			funcName = className + "." + tokenizer.keyWord(); //subroutineName
			
			advance()	;	// subroutineName
			advance()	;	// '('
			
			compileParameterList();
			
			advance();		// ')'
			
			compileSubroutineBody();
    }
			
  }

	void compileParameterList()
  {
    String type;
		if (funcType == "method")
			symbolTable.define("this", "self", "ARG"); //TODO
		if (isNextTokType())
    {
      type = tokenizer.keyWord(); // type
			
			advance(); // Type
			
			symbolTable.define(tokenizer.keyWord(), type, "ARG");
			
			advance(); // Var name
			
			while (isNextTokComma())
      {
       advance(); // ','
				
				type = tokenizer.keyWord();
				advance(); // Type
				symbolTable.define(tokenizer.keyWord(), type, "ARG");
				advance() ;// Var name
      }
    }		
  }
		
	
	void compileSubroutineBody()
  {
    advance(); // '{'
		
		compileVarDec();
		
		vmWriter.writeFunction(funcName, symbolTable.varCount("VAR")); // TODO
		
		if (funcType == "constructor")
    {
      vmWriter.writePush("constant", symbolTable.varCount("FIELD"));
			vmWriter.writeCall("Memory.alloc", 1);
			vmWriter.writePop("pointer", 0); // 'this'
			
    }
			
		if (funcType == "method")
    {
      vmWriter.writePush("argument", 0);
			vmWriter.writePop("pointer", 0);
    }
			
		
		compileStatements();
		
		advance() ;// '}'
  }
		
	
	void compileVarDec()
  {
    String type;
    while (isNextTokVarDec())
    {
			advance() ;// 'var'
			type = tokenizer.keyWord();
			advance(); // type
			symbolTable.define(tokenizer.keyWord(), type, "VAR");
      advance(); // var name
			while (isNextTokComma())
      {
        advance(); // ','
				
				symbolTable.define(tokenizer.keyWord(), type, "VAR");
				
				advance(); // var name
      }
				
				
			advance(); // ';'
    }
			
  }
		
			
	
		
	void compileStatements()
  {
   
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
			
  }
		
	
	void compileDo()
  {
    advance(); // 'do'
		
		compileSubroutineCall();
		
		vmWriter.writePop("temp", 0);
		
		advance(); // ';'
  }
		
	
	void compileLet()
  {
    advance() ;// 'let'
		
		String varName = tokenizer.keyWord();
		bool isArr = false;
		
		advance(); // varName
		
		if (isNextTok("["))
    {
      isArr = true;
			advance() ;// '['
			
			compileExpression();
			
			vmWriter.writePush(kindToSegment(symbolTable.kindOf(varName)),symbolTable.indexOf(varName));
			vmWriter.writeArithmetic("add");
			
			advance(); // ']'
    }

		advance() ;// '='
		compileExpression();

    if (isArr)
    {
      vmWriter.writePop("temp", 0);
			vmWriter.writePop("pointer", 1);
			vmWriter.writePush("temp", 0);
			vmWriter.writePop("that", 0);
    }
			

		else
			vmWriter.writePop(kindToSegment(symbolTable.kindOf(varName)),symbolTable.indexOf(varName));
		
		advance(); // ';'
  }
 
	void compileWhile()
  {
    String counterStr = whileCounter.toString();
		whileCounter++;
		vmWriter.writeLabel("WHILE_EXP" + counterStr);
		
		advance() ;// 'while'
		advance(); // '('
		
		compileExpression() ;
		
		vmWriter.writeArithmetic("not");
		vmWriter.writeIf("WHILE_END" + counterStr);
		
		advance(); // ')'
		advance(); // '{'
		
		compileStatements();
		
		vmWriter.writeGoto("WHILE_EXP" + counterStr);
		vmWriter.writeLabel("WHILE_END" + counterStr);

		advance(); // '}'
  }
		
	
	void compileReturn()
  {
    advance(); // 'return'
		
		if (isNextTokExpression())
			compileExpression();
		else
			vmWriter.writePush("constant", 0);
		vmWriter.writeReturn();
		
		advance(); // ';'
  }
		

	void compileIf()
  {
    int tempIfCounter = ifCounter;
		ifCounter++; 

		advance(); // 'if'
		advance(); // '('
		
		compileExpression() ;
		
		advance(); // ')'
		advance(); // '{'
		
		vmWriter.writeIf("IF_TRUE" + tempIfCounter.toString());
		vmWriter.writeGoto("IF_FALSE" + tempIfCounter.toString());
		vmWriter.writeLabel("IF_TRUE" + tempIfCounter.toString());
		
		compileStatements() ;
		
		advance(); // '}'
		
		if (isNextTok("else"))
    {
      vmWriter.writeGoto("IF_END" + tempIfCounter.toString());
			vmWriter.writeLabel("IF_FALSE" + tempIfCounter.toString());
			
			advance(); // 'else
			advance() ;// '{'
			
			compileStatements();
			
			advance() ;//'}'
			
			vmWriter.writeLabel("IF_END" + tempIfCounter.toString());
    }
			
		else 
			vmWriter.writeLabel("IF_FALSE" + tempIfCounter.toString());

  }
		
	
	
	void compileExpression()
  {
    String op;
		
		compileTerm();
		
		while (isNextTokOp())
    {
      op = tokenizer.keyWord();

			advance(); // op
			compileTerm();
			
			writeOp(op);
    }
	
  }
		
	
	
	void compileTerm()
  {
   int nLocals = 0; //integerConstant | stringConstant | keyWordConstant
		
		if (isTypeNextTok("INT_CONST"))
    {
     vmWriter.writePush("constant",int.parse(tokenizer.keyWord()));
			
			advance();		// write constant

			return;
    } 


		if (isTypeNextTok("STRING_CONST"))
    {
      String s = tokenizer.keyWord();
			
			vmWriter.writePush("constant", s.length);
			vmWriter.writeCall("String.new", 1);
			
			for (int i = 0; i < (s.length - 1);i++)
      {
        vmWriter.writePush("constant",s.codeUnitAt(i));
				vmWriter.writeCall("String.appendChar", 2);
      }
				
				

			advance();		// write constant

			return;

    } 
			
    
    if (isKeywordConstant())
    {
      String word = tokenizer.keyWord();
			if (word == "this")
				vmWriter.writePush("pointer", 0);
			else 
      {
        vmWriter.writePush("constant", 0);
				if (word == "true")
				  vmWriter.writeArithmetic("not");
      }
				
				
			advance()	;	// write constant

			return;
    } 
			
		
			
		if (isNextTok("("))	// '(' expression ')'
    {
      advance()	;	// '('
			compileExpression();
			advance()	;	// ')'

			return;
    }		
			
			
		if (isNextTokUnaryOp())//unaryOp term
    {
      String op = tokenizer.keyWord();
			
			advance();		// 'unaryOp'
			compileTerm() ;
			
			if (op == "-")
				vmWriter.writeArithmetic("neg");
			if (op == "~")
				vmWriter.writeArithmetic("not");
				
			return;
    }		
			
		
		//  varName | varName '[' expression ']' | subroutineCall
		
		String nextTokenType = tokenizer.tokenType();
		String nextTokenValue = tokenizer.keyWord();
		
		String nextNextValue = NextNextTok();
		
		
		if (nextTokenType == "IDENTIFIER" && nextNextValue == "[")
    {
     advance(); // '['
				
			compileExpression();
			
			vmWriter.writePush(kindToSegment(symbolTable.kindOf(nextTokenValue)),symbolTable.indexOf(nextTokenValue));
			vmWriter.writeArithmetic("add");
			vmWriter.writePop("pointer", 1);
			vmWriter.writePush("that", 0);
		
			advance(); // ']'
			
    }
			
			
		else if (nextTokenType == "IDENTIFIER" && nextNextValue == "(")
    {
      nLocals++;
			vmWriter.writePush("pointer", 0);
			advance(); // '('
			nLocals += compileExpressionList();
			advance(); // ')'
			vmWriter.writeCall(className + "." + nextTokenValue, nLocals);
    }
			
			
		else if (nextTokenType == "IDENTIFIER" && nextNextValue == ".")
    {
      String subroutineName;
			String typeName = nextTokenValue;

			advance(); // '.'
			
			subroutineName = tokenizer.keyWord();
			
			if (symbolTable.isInSymbolTables(typeName))
      {
        vmWriter.writePush(kindToSegment(symbolTable.kindOf(typeName)), symbolTable.indexOf(typeName));
				nLocals++;
				subroutineName = symbolTable.typeOf(typeName) + "." + subroutineName;
      }
			else 
				subroutineName = typeName + "." +subroutineName;
				
			advance(); // subroutineName
			
			
			advance(); // '('
			nLocals += compileExpressionList();
			advance(); // ')'	
			vmWriter.writeCall(subroutineName, nLocals)	;
    }
			
			
		else if (nextTokenType == "IDENTIFIER")
    {
      vmWriter.writePush(kindToSegment(symbolTable.kindOf(nextTokenValue)),symbolTable.indexOf(nextTokenValue));
    }
			
  }
	
  
	int compileExpressionList()
  {
    int numOfExp = 0; 
		if (isNextTokExpression())
    {
      numOfExp++;
			compileExpression();
			
			while (isNextTokComma())
      {
        advance(); // ','
				numOfExp++;
				compileExpression();
      }
				
    } 
					
		return numOfExp;
  }
		
	 
	
	void compileSubroutineCall()
  {
    String subroutineName;
		String typeName;
		int nLocals = 0;
		
		typeName = tokenizer.keyWord();
			
		advance(); // subroutineName / className / varName
    if (!isNextTok("."))
    {
      advance(); // '('
			vmWriter.writePush("pointer", 0);
			nLocals++;
			subroutineName = className + "." + typeName;
			nLocals += compileExpressionList();
			
			advance(); // ')'
    }
			
		
		else // subroutine of another  class
    {
      advance() ;// '.' 
			subroutineName = tokenizer.keyWord();
			if (symbolTable.isInSymbolTables(typeName))
      {
        vmWriter.writePush(kindToSegment(symbolTable.kindOf(typeName)), symbolTable.indexOf(typeName));
				nLocals++;
				subroutineName = symbolTable.typeOf(typeName) + "." + subroutineName;
      }
				
			
			else 
      {
        subroutineName = typeName + "." +subroutineName;
      }	
			advance(); // subroutineName
			
			advance() ;// '('
			
			nLocals += compileExpressionList();
			
			advance(); // ')'
    }
      
			
		vmWriter.writeCall(subroutineName, nLocals);
  }
		

	
  bool isNextTokClassVarDec()
  {
    return tokenizer.keyWord() == "static" || tokenizer.keyWord() == "field";
  }


  bool isNextTokComma()
  {
    return tokenizer.keyWord() == ",";
  }

  bool isNextTokSubroutine()
  {
    String keyWord = tokenizer.keyWord();
		return  keyWord == "constructor" || keyWord == "function" || keyWord == "method" ;
  }


  bool isNextTokType()
  {
    return tokenizer.tokenType() != "SYMBOL"; // if not exist parm so token is type 
  }

  bool isNextTokVarDec()
  {
    return tokenizer.keyWord() == "var";
  }

  bool isNextTokExpression()
  {
    return tokenizer.keyWord() != ")" && tokenizer.keyWord() != ";";
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

  bool isNextTok(String s)
  {
    return tokenizer.keyWord() == s;
  }

  void writeOp(String op)
  {
    if (op == "+")
			vmWriter.writeArithmetic("add");
		if (op == "-")
			vmWriter.writeArithmetic("sub");
		if (op == "*")
			vmWriter.writeCall("Math.multiply", 2);
		if (op == "/")
			vmWriter.writeCall("Math.divide", 2);
		if (op == "|")
			vmWriter.writeArithmetic("or");
		if (op == "&")
			vmWriter.writeArithmetic("and");
		if (op == "=")
			vmWriter.writeArithmetic("eq");
		if (op == "<")
			vmWriter.writeArithmetic("lt");
		if (op == ">")
			vmWriter.writeArithmetic("gt");
  }
	
		
		
	void advance()
  {
    tokenizer.advance();
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

  String NextNextTok()
  {
    tokenizer.advance();
		return tokenizer.keyWord();
  }
		
	
	bool isTypeNextTok(String s)
  {
    return tokenizer.tokenType() == s;
  }

  String kindToSegment(String kind)
  {
    if (kind == "VAR")
			return "local";
			
		if (kind == "ARG")
			return "argument";
			
		if (kind == "static")
			return "static";

		return "this";
  }
		
		
}
		
	