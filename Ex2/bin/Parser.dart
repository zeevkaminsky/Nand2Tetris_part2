import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:core';


class Parser
{
  String pathInputFile;
  var myFile;
  List<String> file;
  String currentCommand;
  int i ;
 
  Parser(String aPathInputFile)
    {
      pathInputFile=aPathInputFile;
      myFile = new File(pathInputFile);
      file = myFile.readAsLinesSync();
      i = 0;
      for (var line in file) 
      {
        stdout.writeln(line); 
      } 
    }
        

  bool  hasMoreCommands()
  {
      return i < file.length;
  }
      

  void advance()
  {
      currentCommand = file[i];
      i++;
  }
      

  String commandType()
  {
      if (currentCommand == null)
          return "";
      if (currentCommand.startsWith("add"))
          return "C_ARITHMETIC";
      if (currentCommand.startsWith("sub"))
          return "C_ARITHMETIC";
      if (currentCommand.startsWith("neg"))
          return "C_ARITHMETIC";
      if (currentCommand.startsWith("eq"))
          return "C_ARITHMETIC";
      if (currentCommand.startsWith("gt"))
          return "C_ARITHMETIC";
      if (currentCommand.startsWith("lt"))
          return "C_ARITHMETIC";
      if (currentCommand.startsWith("and"))
          return "C_ARITHMETIC";
      if (currentCommand.startsWith("or"))
          return "C_ARITHMETIC";
      if (currentCommand.startsWith("not"))
          return "C_ARITHMETIC";
          
      if (currentCommand.startsWith("push"))
          return "C_PUSH";
      if (currentCommand.startsWith("pop"))
          return "C_POP";

      if (currentCommand.startsWith("label"))
			  return "C_LABEL";
		  if (currentCommand.startsWith("goto"))
		  	return "C_GOTO";
	  	if (currentCommand.startsWith("if"))
		  	return "C_IF";

	  	if (currentCommand.startsWith("function"))
		  	return "C_FUNCTION";
		  if (currentCommand.startsWith("return"))
		  	return "C_RETURN";
	  	if (currentCommand.startsWith("call"))
		  	return "C_CALL";
      return "";
  }
      
      
  String arg1()
  {
      if (commandType()== "C_ARITHMETIC")
          return currentCommand.split(" ")[0];
      else
          return currentCommand.split(" ")[1];
  }
      

  
  int arg2()
  {
     return int.parse(currentCommand.split(" ")[2]);
  }
  
     

  String getCurrentCommand()
  {
    return currentCommand;
  }
      
  
    
}

    