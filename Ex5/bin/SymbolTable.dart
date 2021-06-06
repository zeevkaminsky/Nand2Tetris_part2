
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:core';


class symbolDetails
{
  symbolDetails(String t, String k, int i)
  {
    type = t;
		kind = k;
		index = i;
  }
		
		
	String type;
	String kind;
	int index;
}
class SymbolTable
{
  int staticCounter;
	int fieldCounter;
	
	int varCounter;
	int argCounter;
	

	Map globalScope;
	Map subroutinesScope;
	
	SymbolTable()
  {
    globalScope = new Map<String,symbolDetails> ();
		subroutinesScope = new Map<String,symbolDetails>();
		staticCounter = 0;
		fieldCounter = 0;
		varCounter = 0;
		argCounter = 0;
  }
		
		
	void startSubroutine()
  {
    subroutinesScope.clear();
		varCounter = 0;
		argCounter = 0;
  }
		
	
	void define(String name, String type, String kind)
  {
    if (kind.toUpperCase() == "STATIC" || kind.toUpperCase() == "FIELD")
			
			globalScope[name] = new symbolDetails(type,kind,increaseCount(kind));
			
		if (kind.toUpperCase() == "VAR" || kind.toUpperCase()  == "ARG")
			subroutinesScope[name] = new symbolDetails(type,kind,increaseCount(kind))	;
  }
		

	
	int increaseCount(String kind)
  {
    int res = -1;
		if (kind.toUpperCase() == "STATIC")
    {
      res = staticCounter;
			staticCounter++;
    }
			
			
		if (kind.toUpperCase() == "FIELD")
    {
      res = fieldCounter;
			fieldCounter++;
    }
			

		if (kind.toUpperCase() == "VAR")
    {
      res = varCounter;
			varCounter++;
    }
			
			
		if (kind.toUpperCase() == "ARG")
    {
      res = argCounter;
			argCounter++;
    }
		return res;
  }
		
		
	int varCount(String kind)
  {
    int res = -1;
		if (kind.toUpperCase() == "STATIC")
			res = staticCounter;
			
		if (kind.toUpperCase() == "FIELD")
			res = fieldCounter;

		if (kind.toUpperCase() == "VAR")
			res = varCounter;
			
		if (kind.toUpperCase() == "ARG")
			res = argCounter;

		return res;
  }
		
		
	String kindOf(String name)
  {
    if (hasKey(globalScope, name))
			//print globalScope[name].kind
			return globalScope[name].kind; 
		
		if (hasKey(subroutinesScope, name))
			//print subroutinesScope[name].kind
			return subroutinesScope[name].kind;
			
		return "NONE";
  }
		
	
	String typeOf(String name)
  {
    String res = "";
		if (hasKey(globalScope, name))
			res = globalScope[name].type ;
		
		if (hasKey(subroutinesScope, name))
			res = subroutinesScope[name].type;
		
		return res;
  }
		

		
	int  indexOf(String name)
  {
    int res = -1;
		
		if (hasKey(globalScope, name))
			res = globalScope[name].index ;
		
		if (hasKey(subroutinesScope, name))
			res = subroutinesScope[name].index;
		
		return res;
  }
			
		
	bool isInSymbolTables(String name)
  {
    return hasKey(globalScope, name) || hasKey(subroutinesScope, name);
  }
		
  bool hasKey(Map map, String s)
  {
    for(var k in map.keys)
    {
      if(k == s)
      {
        return true;
      }
    }
    return false;
  }

}

	
	