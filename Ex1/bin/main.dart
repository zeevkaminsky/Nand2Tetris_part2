import '../bin/parser.dart';
import '../bin/CodeWriter1.dart';





void main(List<String> args)
{
  String pathSource = 'C:\\Users\\שירה\\Desktop\\nand2tetris\\nand2tetris\\projects\\07\\MemoryAccess\\BasicTest\\BasicTest.vm';
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
			
  }
		

}
	