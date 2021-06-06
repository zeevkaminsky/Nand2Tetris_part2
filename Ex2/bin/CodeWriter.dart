
import 'dart:async';
import 'dart:io';


class CodeWriter
{
  int trueCounter;
	int endCounter;
  int callfuncCounter;
	String pathOutputFile;
	var file;
	String sourceFileName;
	var myFile;
  String filePath ;
	CodeWriter(String aOutputFile)
  {   
		trueCounter = 0;
		endCounter = 0;
    callfuncCounter = 0;
		pathOutputFile = aOutputFile;
    myFile = new File(pathOutputFile);
    file = myFile.openWrite();
    filePath = pathOutputFile.replaceAll("/$myFile", '');
		
  }
		
	void setFileName(String fileName)
  {
    sourceFileName = fileName;
		comment("File: " + fileName);
  }
		
		
	void writeArithmetic(String command)
  {
    String asmCommands="";
			if (command.startsWith( "add" ))
				asmCommands = binaryOp("+");
				
			if (command.startsWith( "sub" ))
				asmCommands = binaryOp("-");
				
			if (command.startsWith( "and" ))
				asmCommands = binaryOp("&");
				
			if (command.startsWith( "or" ))
				asmCommands = binaryOp("|");
				
			if (command.startsWith( "neg" ))
				asmCommands = unaryOp("-");
				
			if (command.startsWith( "not" ))
				asmCommands = unaryOp("!");
				
			if (command.startsWith( "eq" ))
				asmCommands = compareOp("JEQ");
				
			if (command.startsWith( "gt" ))
				asmCommands = compareOp("JLT");
				
			if (command.startsWith( "lt" ))
				asmCommands = compareOp("JGT");

		file.write(asmCommands);
    	
  }
		
    
	void writePushPop(String command, String segment, int index)
  {
    String asmCommands="";
		
		if (command == "C_PUSH")
			asmCommands = push(segment, index);
		else
			asmCommands = pop(segment,index);

		file.write(asmCommands);
  }
		
  void writeLabel(String label)
  {
    file.write("(" + label +")" + commentString());
  }
		
		
	void writeGoto(String label)
  {
    String asmCommands;
		
		asmCommands = "@" + label + commentString();
		asmCommands += "0;JMP" + commentString();
		
		file.write(asmCommands);
  }

  void writeIf(String label)
  {
   String asmCommands;;
		
		asmCommands = "@SP" +commentString(" A = 0");
		asmCommands += "M = M - 1" + commentString(" M[SP] = M[SP] - 1 , decrement the stack pointer ");
		asmCommands += "A = M" + commentString(" A = M[SP]");
		asmCommands += "D = M" + commentString(" M = M[M[SP]]");
		asmCommands += "@" + label + commentString();
		asmCommands += "D;JNE" + commentString(" If the stack head is different than zero, jump to Label C");
		
		file.write( asmCommands);
  }
		
  
  void writeCall(String functionName, int numArgs)
  {
    String asmCommands;
  		
  		asmCommands = "@ReturnAddress" + callfuncCounter.toString() +commentString();
  		asmCommands += "D = A" + commentString(" D = return address");
  		asmCommands += pushToStack() ;
  		
  		asmCommands += commentString(" Save LCL");
  		asmCommands += "@LCL" + commentString();
  		asmCommands += "D = M" + commentString();
  		asmCommands += pushToStack();
  		
  		asmCommands += commentString(" Save ARG");
  		asmCommands += "@ARG" + commentString();
  		asmCommands += "D = M" + commentString();
  		asmCommands += pushToStack();
  		
  		asmCommands += commentString(" Save THIS");
  		asmCommands += "@THIS" + commentString();
  		asmCommands += "D = M" + commentString();
  		asmCommands += pushToStack();
  	
  		asmCommands += commentString(" Save THAT");
  		asmCommands += "@THAT" + commentString();
  		asmCommands += "D = M" + commentString();
  		asmCommands += pushToStack();
  		
  		asmCommands += commentString(" ARG = SP-n-5 ");
  		asmCommands += "@SP" + commentString();
  		asmCommands += "D = M" + commentString(" D = RAM[SP]");
  		asmCommands += "@" + (numArgs + 5).toString() + commentString(" numArgs + 5 ");
  		asmCommands += "D = D - A" + commentString();
  		asmCommands += "@ARG" + commentString();
  		asmCommands += "M = D" + commentString(" RAM[ARG] = D = SP - (numArgs + 5)");
  	
  		asmCommands += commentString(" LCL = SP");
  		asmCommands += "@SP" + commentString();
  		asmCommands += "D = M" + commentString();
  		asmCommands += "@LCL" + commentString();
  		asmCommands += "M = D" + commentString();
  		
  		file.write(asmCommands);
  		
  		writeGoto(functionName);
  		writeLabel("ReturnAddress"+callfuncCounter.toString());
  		callfuncCounter++;
  }
		

 void writeFunction(String functionName, int numLocals)
 {
    writeLabel(functionName);
		for (int i = 1; i < numLocals; i++)
    {
      comment(" push local-" + i.toString());
			file.write(pushConstant(0));
    } 
			
 }
		
		
	void writeReturn()
  {
    String asmCommands;
		asmCommands = commentString("FRAME = LCL");
		asmCommands += "@LCL" + commentString();
		asmCommands += "D = M" + commentString();
		asmCommands += "@R13" + commentString( " FRAME store in R13");
		asmCommands += "M = D" + commentString();
		
		asmCommands += commentString("RET = *(FRAME - 5)");
		asmCommands += commentString("RAM[14] = (LOCAL - 5)");
		asmCommands += "@5" + commentString(" A = 5 ");
		asmCommands += "A = D - A" + commentString(" A = LCL - 5 " );
		asmCommands += "D = M" + commentString(" D = RAM[RAM[LCL]-5]");
		asmCommands += "@R14" + commentString(" RET store in R14");
		asmCommands += "M = D" + commentString();
		
		asmCommands += commentString(" *ARG = pop()");
		asmCommands += "@SP" +commentString(" A = 0");
		asmCommands += "M = M -1" +commentString();
		asmCommands += "A = M" +commentString(" pointer to top the stack");
		asmCommands += "D = M" +commentString(" D = value of top the stack");
		asmCommands += "@ARG" +commentString();
		asmCommands += "A = M" +commentString(" pointer to argument segment");
		asmCommands += "M = D" +commentString(" *ARG = pop");
		
		asmCommands += commentString(" SP = ARG -1");
		asmCommands += "@ARG" + commentString();
		asmCommands += "D = M" +commentString(" D = M[ARG]");
		asmCommands += "@SP" + commentString();
		asmCommands += "M = D + 1" + commentString(" M[SP] = M[ARG] + 1");
		
		asmCommands += commentString("THAT = *(FRAME-1)");
		asmCommands += restoreCaller("THAT");
		
		asmCommands += commentString("THIS = *(FRAME-2)");
		asmCommands += restoreCaller("THIS");
		
		asmCommands += commentString("ARG = *(FRAME-3)");
		asmCommands += restoreCaller("ARG");
		
		asmCommands += commentString("LCL = *(FRAME-4)");
		asmCommands += restoreCaller("LCL");
		
		asmCommands += "@R14" +commentString(" RET store in R14");
		asmCommands += "A = M" +commentString(" A = M[R14]");
		asmCommands += "0;JMP";
		
		file.write(asmCommands);
  }  
		
	void writeInit()
	{
		setFileName("Init");
		String asmCommands;
		asmCommands = commentString("SP = 256");
		asmCommands += "@256" + commentString(" A = 256");
		asmCommands += "D = A" + commentString(" D = A = 256");
		asmCommands += "@SP" + commentString(" A = 0");
		asmCommands += "M = D" + commentString(" M[SP] = D = 256");
		asmCommands += commentString(" call Sys.init");
		
		file.write(asmCommands);
		
		writeCall("Sys.init", 0);
  }
		
		
		
	String restoreCaller(String segment)
  {
    String asmCommands;
		
		asmCommands = "@R13" + commentString(" R13 = FRAME");
		asmCommands += "M = M - 1" + commentString(" FRAME = FRAME - 1");
		asmCommands += "A = M" + commentString();
		asmCommands += "D = M" +commentString();
		asmCommands += "@" + segment + commentString();
		asmCommands += "M = D" + commentString();
		
		return asmCommands;
  }
		
		

	String push(String segment, int index)
  {
    if (segment.startsWith("local"))
			return pushGroup1("LCL", index);
		if (segment.startsWith("argument"))
			return pushGroup1("ARG", index);
		if (segment.startsWith("this"))
			return pushGroup1("THIS", index);
		if (segment.startsWith("that"))
			return pushGroup1("THAT", index);
		if (segment.startsWith("temp"))
			return pushTemp(index);
		if (segment.startsWith("static"))
			return pushStatic(index);
		if (segment.startsWith("pointer"))
			return pushPointer(index);
		if (segment.startsWith("constant"))
			return pushConstant(index);
		return "";
  }
		
			
	String pop(String segment, int index)
  {
    if (segment.startsWith("local"))
			return popGroup1("LCL", index);
		if (segment.startsWith("argument"))
			return popGroup1("ARG", index);
		if (segment.startsWith("this"))
			return popGroup1("THIS", index);
		if (segment.startsWith("that"))
			return popGroup1("THAT", index);
		if (segment.startsWith("temp"))
			return popTemp(index);
		if (segment.startsWith("static"))
			return popStatic(index);
		if (segment.startsWith("pointer"))
			return popPointer(index);	
		return "";
  }
		
		
	//def close()
    //TODO
    
	String binaryOp(String op)
  {
    String asmCommand;
		asmCommand  = "@SP" + commentString(" A = 0");
		asmCommand += "A = M - 1" +commentString( " A = RAM[SP] - 1");
		asmCommand += "D = M" + commentString(" D = RAM[A] = RAM[RAM[SP]-1] = y");
		asmCommand += "A = A-1" + commentString(" A = A -1 = RAM[SP] - 2");
		asmCommand += "M = M" + op + "D" + commentString( "RAM[RAM[SP]-2] =  RAM[RAM[SP]-2] " + op + " D = x " + op + " y");
		asmCommand += "@SP" + commentString( " A = 0");
		asmCommand += "M = M - 1" + commentString("RAM[SP] = RAM[SP] - 1 ,decrement the stack pointer");
		return asmCommand;
  }
		
        
	String unaryOp(String op)
  {
    String asmCommand;
		asmCommand  = "@SP" + commentString( "A = 0");
		asmCommand += "A = M - 1" +commentString(" A = RAM[SP] - 1");
		asmCommand += "M = " + op + "M" + commentString( " RAM[RAM[SP]-1] = " + op + " y");
		return asmCommand;
  }
		
		
	String compareOp(String op)
  {
    String asmCommands;
		asmCommands = "@SP" + commentString("A = 0");
		asmCommands += "A = M - 1" +commentString(" A = RAM[sp] -1 ");
		asmCommands += "D = M "    + commentString(" D = y ");
		asmCommands += "A = A - 1" + commentString(" A = RAM[sp] -2 ");
		asmCommands += "D = D - M" + commentString(" D = y - x ");
		asmCommands += "@IF_TRUE"+trueCounter.toString() + commentString(" label if true");
		asmCommands += "D;" + op + commentString();
		asmCommands += "D = 0" +commentString(" The comparison result is false ");
		asmCommands += "@END" + endCounter.toString() +commentString();
		asmCommands += "0;JMP" +commentString( " Jump anyway ");
		asmCommands += "(IF_TRUE" + trueCounter.toString() + ")" +commentString();
		asmCommands += "D = -1" +commentString(" The comparison result is true");
		asmCommands += "(END" + endCounter.toString() + ")"+commentString();
		asmCommands += "@SP" +commentString(" A = 0");
		asmCommands += "A = M - 1" +commentString(" A = RAM[SP] - 1");
		asmCommands += "A = A - 1" +commentString(" A = RAM[sp] - 2" );
		asmCommands += "M = D" +commentString(" RAM[RAM[SP]-2] = result <0 if false, -1 if true>");
		asmCommands += "@SP" +commentString(" A = 0");
		asmCommands += "M = M -1" +commentString(" RAM[SP] = RAM[SP] -1 ,decrement the stack pointer");
		
		endCounter++;
		trueCounter++;
		
		return asmCommands;
		
  }
		
	String pushGroup1(String segment,int index)
  {
    String asmCommands;
		
		asmCommands = "@" + index.toString() +commentString( "A = "+ index.toString());
		asmCommands += "D = A" +commentString(" D = A = " + index.toString());
		asmCommands += "@" +segment + commentString();
		asmCommands += "A = M + D" + commentString(" A = RAM[" + segment + "] + " + index.toString());
		asmCommands += "D = M" + commentString(" D = RAM[RAM[" + segment +"]+" + index.toString() + "]");
		asmCommands += pushToStack() ;
		
		return asmCommands;
  }
		
		
	String pushTemp(int index)
  {
    String indexStr = index.toString();
		String asmCommands;
		
		asmCommands = "@" + (index + 5).toString() + commentString( " A = 5 + " + indexStr);
		asmCommands += "D = M" +commentString(" D = RAM[5+"+indexStr+"]");
		asmCommands += pushToStack() + commentString();
		
		return asmCommands;
  }
		
		
	String pushStatic(int index)
  {
    String indexStr= index.toString();
		String asmCommands;

		asmCommands = "@" + filePath + "." + indexStr + commentString();
		asmCommands += "D = M" +commentString( " D = RAM["+filePath + "." + indexStr +"]");
		asmCommands += pushToStack() + commentString();
		
		return asmCommands;
  }
	
		
	String pushPointer(int index)
  {
    String indexStr = index.toString();
		String asmCommands;
		
		if (index == 0)
			asmCommands = "@THIS" + commentString();
		else
			asmCommands = "@THAT" + commentString();
		
		asmCommands += "D = M" +commentString( " D = RAM[3+"+indexStr+"]");
		asmCommands += pushToStack() + commentString();
		
		return asmCommands;
  }
	
		
	String pushConstant(int index)
  {
    String indexStr = index.toString();
		String asmCommands ="";
		
		asmCommands  = "@" + indexStr + commentString(" A = " + indexStr);
		asmCommands +=asmCommands+ "D = A" + commentString(" D = A = " + indexStr);
		asmCommands += pushToStack();
		
		return asmCommands;

  }
		
		
		
	String pushToStack()
  {
    String asmCommands;
		asmCommands = "@SP" +commentString(" A = 0");
		asmCommands += "A = M" +commentString(" A = RAM[SP]");
		asmCommands += "M = D" +commentString(" RAM[RAM[SP]] = D");
		asmCommands += "@SP" +commentString(" A = 0");
		asmCommands += "M = M + 1" +commentString(" RAM[SP] = RAM[SP]+1 ,increment the stack pointer");

		return asmCommands;
  }
		
		
		
	String popFromStack()
  {
    String asmCommands;
		
		asmCommands = "@SP" + commentString(" A = 0");
		asmCommands += "A = M - 1" + commentString(" A = RAM[SP] - 1");
		asmCommands += "D = M" + commentString(" D = RAM[RAM[SP]-1] ,Top of the stack");
		asmCommands += "@SP" + commentString(" A = 0");
		asmCommands += "M = M - 1" + commentString(" RAM[SP] = RAM[SP] -1 ,decrement the stack pointer");
		
		return asmCommands;
  }

		
		
	String popGroup1(String segment, int index)
  {
    String indexStr = index.toString();
		String asmCommands;
		 
		asmCommands = "@" + indexStr + commentString(" A = " + indexStr);
		asmCommands += "D = A" + commentString(" D = A = " + indexStr);
		asmCommands += "@" + segment + commentString();
		asmCommands += "A = M" + commentString(" A = M[" + segment +"]");
		asmCommands += "D = A + D" +commentString(" D = M[" + segment +"] + " + indexStr );
		asmCommands += "@R13" + commentString( "A = 13");
		asmCommands += "M = D" + commentString(" RAM[13] = D" );
		asmCommands += popFromStack();
		asmCommands += "@R13" + commentString(" A = 13");
		asmCommands += "A = M" +commentString(" A = RAM[13]");
		asmCommands += "M = D" +commentString(" M[RAM[13]] = D");
		 
		return asmCommands;
  }
		
		 
	String popTemp(int index)
  {
    String asmCommands;
		
		asmCommands = popFromStack();
		asmCommands += "@" + (5 + index).toString() + commentString(" A = 5 + " + index.toString());
		asmCommands += "M = D" + commentString("M[A] = D");
		
		return asmCommands;
  }
		
		
		
	String popPointer(int index)
  {
    String asmCommands;
		
		asmCommands = popFromStack();
		
		if (index == 0)
			asmCommands += "@THIS" + commentString();
		else
			asmCommands += "@THAT" + commentString();
		
		asmCommands += "M = D" + commentString(" M[3+" + index.toString() + "] = D");
		
		return asmCommands;
  }
		
		
	String popStatic(int index)
  {
    String indexStr = index.toString();
		String asmCommands;
    String filePath = sourceFileName.replaceAll("/$myFile", '');

		asmCommands = popFromStack();
		asmCommands += "@" + filePath + "." + indexStr + commentString();
		asmCommands += "M = D" + commentString(" M[" +  filePath + "." + indexStr +"] = D" );
		
		return asmCommands;
  }
	
	
	
	void comment([String comment = ""])
  {
    file.write("\n//" + comment +"\n\n");
  }
		
		
	String commentString([String comment = ""])
  {
    if (comment == "")
			return "\n";
		return "\t\t//" + comment +"\n";
  }
		
}
	