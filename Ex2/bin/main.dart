import '../bin/parser.dart';
import '../bin/CodeWriter.dart';





void main(List<String> args)
{
  String pathSource = 'C:\\Users\\שירה\\Desktop\\nand2tetris\\nand2tetris\\projects\\08\\FunctionCalls\\FibonacciElement\\Main.vm';
	String outputFile;
	CodeWriter codeWriter;
	
 
    outputFile = pathSource.substring(0, pathSource.length-3);
    outputFile += ".asm";
		codeWriter = new CodeWriter(outputFile);
		writeOneFile(pathSource, codeWriter);
  
}

	
		
			


	


void writeOneFile(String pathFile ,CodeWriter codeWriter)
{
  codeWriter.setFileName(pathFile);
	Parser parser = new Parser(pathFile);
	String commandType;

	while(parser.hasMoreCommands() == true)
  {
    parser.advance();
		commandType = parser.commandType();
		if (commandType == "C_POP" || commandType == "C_PUSH")
    {
      codeWriter.comment("vm command: " + parser.getCurrentCommand());
			codeWriter.writePushPop(commandType, parser.arg1() ,parser.arg2());
    }
			
		if (commandType == "C_ARITHMETIC")
    {
      codeWriter.comment("vm command: " + parser.getCurrentCommand());
			codeWriter.writeArithmetic(parser.arg1());
    }

    if (commandType == "C_LABEL")
    {
      codeWriter.comment("vm command: " + parser.getCurrentCommand());
			codeWriter.writeLabel(parser.arg1());
    }
			
		if (commandType == "C_GOTO")
    {
      codeWriter.comment("vm command: " + parser.getCurrentCommand());
			codeWriter.writeGoto(parser.arg1());
    }
			
		if (commandType == "C_IF")
    {
      codeWriter.comment("vm command: " + parser.getCurrentCommand());
			codeWriter.writeIf(parser.arg1());
    }
			
		if (commandType == "C_FUNCTION")
    {
      codeWriter.comment("vm command: " + parser.getCurrentCommand());
			codeWriter.writeFunction(parser.arg1(), parser.arg2());
    }
			
		if (commandType == "C_RETURN")
    {
      codeWriter.comment("vm command: " + parser.getCurrentCommand())	;
			codeWriter.writeReturn();
    }
			
		if (commandType == "C_CALL")
    {
      codeWriter.comment("vm command: " + parser.getCurrentCommand());
			codeWriter.writeCall(parser.arg1(), parser.arg2());
    }
			
			
  }
		

}
	