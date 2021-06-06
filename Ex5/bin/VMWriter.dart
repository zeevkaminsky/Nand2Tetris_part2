
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:core';


class VMWriter
{
  var file;
	
	VMWriter(String outputFile)
  {
    file = new File(outputFile).openWrite();
  }
		
		
	void writePush(String segment, int index)
  {
    file.write("push " + segment + " " + index.toString() + "\n") ;
  }
		
	
	void writePop(String segment, int index)
  {
    file.write("pop " + segment + " " + index.toString() + "\n");
  }
		
		
	void writeArithmetic(String command)
  {
    file.write(command + "\n");
  }
		
		
	void writeLabel(String label)
  {
    file.write("label " + label + "\n");
  }
		
		
	void writeGoto(String label)
  {
    file.write("goto " + label + "\n");	
  }
		
		
	void writeIf(String label)
  {
    file.write("if-goto " + label + "\n");
  }
		
	
	void writeCall(String name, int nArgs)
  {
    file.write("call " + name + " " + nArgs.toString() + "\n");
  }
		
		
	void writeFunction(String name, int nLocals)
  {
    file.write("function " + name + " " + nLocals.toString() + "\n");
  }
		
		
	void writeReturn()
  {
    file.write("return\n");
  }
		
}
	