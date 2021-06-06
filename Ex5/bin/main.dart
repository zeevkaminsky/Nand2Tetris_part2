import '../bin/XMlWriter.dart';
import '../bin/JackTokenizer.dart';
import '../bin/CompilationEngine.dart';
void compileOneFile(String inputFile)
{
  String outputFile = inputFile.substring(0, inputFile.length-5);
  outputFile += ".vm";
  CompilationEngine c = new CompilationEngine(inputFile,outputFile);
  c.compileClass();
	
	
}
	

void main()
{
  String pathSource = 'C:\\Users\\שירה\\Desktop\\nand2tetris\\nand2tetris\\projects\\11\\Average\\main.jack';
  compileOneFile(pathSource);
}
  


		

	