import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:core';


class XMLwriter
{
  var file;
	var myFile;
	var d;
	XMLwriter(String fileName)
  {
    myFile = new File(fileName);
    file = myFile.openWrite();
    //print fileName;
		//file = FileStream.open(fileName, "w");
		d = new Map();
		d["KEYWORD"] = "keyword";
		d["SYMBOL"] = "symbol";
		d["IDENTIFIER"] = "identifier";
		d["INT_CONST"] = "integerConstant";
		d["STRING_CONST"] = "stringConstant";
  }
		

	void writeElement(String tag, String data)
  {
    String temp = d[tag];
		if (data == "<")
			data = "&lt;";
			
		if (data == ">")
			data = "&gt;";
			
		if (data == "\"")
			data = "&quot;";
			
		if (data == "&")
			data = "&amp;";
		file.write("<" + temp + "> " + data + " </" + temp + ">\n");
		
	
  }
  void writeStartTag(String startTag)
  {
    	file.write("<" + startTag + ">\n");
  }
	
		
		
	void writeEndTag(String endTag)
  {
    file.write("</" + endTag + ">\n");
  }
		
}

	
		