
#GLEW_H_File=0
#OUTPUT_CONSTANTS_FILE=1
#OUTPUT_GLOBALS_FILE=2
#OUTPUT_GLOBAL_FUNCTIONS=3

Define openFileResult.f=0

Global.s GLEW_INCLUDE_PATH = "glew\include\GL\glew.h"

Global.s curr = ""
Global.s text = ""

Global NewMap funMap.s()
Global NewMap constMap.s()


Macro DQ
    "
EndMacro

Procedure isalpha( c.s )
  
  ProcedureReturn Bool((Asc(c)>= Asc("A") And Asc(c) <=Asc("Z")) Or (Asc(c)>=Asc("a") And Asc(c)<=Asc("z")))
  
EndProcedure


Procedure.b isdigit( c.s )
  
  ProcedureReturn Bool(Asc(c)>=Asc("0") And Asc(c)<=Asc("9"))
  
EndProcedure


Procedure.b isalnum(c.s)
  ProcedureReturn Bool(isalpha(c) Or isdigit(c))
EndProcedure


Procedure.b isxdigit(c.s)
  ProcedureReturn Bool( (Asc(c) >= Asc("A") And Asc(c) <= Asc("F") ) Or ( Asc(c) >= Asc("a") And Asc(c) <= Asc("f")) Or isdigit(c))
EndProcedure


Procedure.s bump()
  Define i.i = 0
  
  While i < Len(text) And Asc(Mid(text, i+1, 1))<=Asc(" ")
    i=i+1
  Wend
  
  If i=Len(text)
    curr=""
    text=""
    ProcedureReturn curr
  EndIf
  
  text = Mid(text, i+1)
  Define c.s = Left(text, 1)
  i=1
  
  If isalpha(c) Or Asc(c)=Asc("_")
    While i<Len(text) And (isalnum(Mid(text, i+1, 1)) Or Asc(Mid(text, i+1, 1))=Asc("_")) 
      i=i+1
    Wend
  ElseIf Asc(c)>=Asc("0") And Asc(c)<=Asc("9")
    If i<Len(text) And Asc(c)=Asc("0") And Asc(Mid(text, i+1, 1))=Asc("x")
      i=i+1
      While i<Len(text) And isxdigit(Mid(text, i+1, 1))
        i=i+1
      Wend
    Else
      While i<Len(text) And isdigit(Mid(text, i+1, 1))
        i=i+1  
      Wend
    EndIf  
    
  EndIf
  
  curr=Left(text, i)
  text=Mid(text, i+1)
 
  ProcedureReturn curr
  
EndProcedure


Procedure.s gltype()
  Define ty.s = ""
  
  If curr="const"
    bump()
  EndIf 
  
  Select curr
    Case "void","GLvoid"
      ty=""
    Case "GLboolean"
      ty="b"
    Case "GLbyte","GLubyte"
      ty="s"
    Case "char","GLchar","GLcharARB"
      ty="c"
    Case "GLint","GLuint","GLenum","GLsizei","GLbitfield", "GLshort","GLushort","GLhalf"
      ty="i"
    Case "GLintptr","GLsizeiptr","GLintptrARB","GLsizeiptrARB"
      ty="i"
    Case "GLhandleARB"
      ty="i"
    Case "GLint64EXT","GLuint64EXT"
      ty="l"
    Case "GLfloat","GLclampf"
      ty="f"
    Case "GLdouble","GLclampd"
      ty="d"
    Default
      ProcedureReturn "x"
  EndSelect
  
  Repeat
    bump()
    If curr="const"
      bump()
    EndIf
    
    If curr<>"*" 
      Break
    EndIf
    
    If ty = ""
      ty = "b"
    EndIf
    
    ;ty = "*"+ty    
  ForEver
  
  If ty
    ty="."+ty
  EndIf
  
  ProcedureReturn ty
  
EndProcedure


Procedure.s glproto()
  
  If bump()=")" 
    ProcedureReturn ""
  EndIf
  
  Define proto.s
  Define err.i, argid.i
  
  Repeat
    Define argty.s = gltype()
    
    If argty = "x" 
      ProcedureReturn argty
    EndIf
    
    Define id.s
    
    If curr<>"," And curr<>")" And Len(curr) And (isalpha(Left(curr, 1)) Or Asc(Left(curr, 1))=Asc("_"))
      id=curr
      If bump()="["
        While bump()<>"]"
        Wend
        bump()
        If argty
        Else
          argty="Byte"
        EndIf
        argty = "*"+argty
      EndIf
    Else  
      id="arg"+argid
    EndIf
    argid=argid+1
    If proto
      proto = proto+","
    EndIf
    proto = proto + id + "_"+argty
    If curr=")"
      bump()
      If proto="arg0_"
        proto=""
      EndIf
      
      ProcedureReturn proto
    EndIf
    
    If curr<>","
      ProcedureReturn "x"
    EndIf
    
    bump()
    
  ForEver 
  
EndProcedure




OpenConsole()



If ReadFile(0, GLEW_INCLUDE_PATH) And CreateFile(1, "output/glew_include.pbi") And CreateFile(2, "output/glew_globals.pbi") And CreateFile(3, "output/glew_global_func.pbi")
  
  While Eof(0) = 0
    
    text = ReadString(0)
    bump()
    
    If curr = "GLAPI"
      bump()
      Define funty.s=gltype()
      If funty<>"x" And curr="GLAPIENTRY"
        Define id.s=bump()
        If Left(id, 2)="gl" And bump()="("
          Define proto.s = glproto()
          If proto<>"x"
            WriteStringN(1, ""+id+funty+"("+proto+")")
          EndIf
        EndIf
      EndIf
    ElseIf curr="#"
      
      If bump() = "define"
        Define id.s=bump()
     
        If Left(id, 11)="GL_VERSION_"
          
        ElseIf Left(id, 3)="GL_"
          If FindMapElement(constMap(), id) = 0 ;If not found
            Define n.s = bump()
            If Left(n, 2)="0x"
              WriteStringN(1, "#"+id+"=$"+Mid(n, 2+1))
            ElseIf Len(n) > 0 And isdigit(Left(n, 1)) And n<>"1"
              WriteStringN(1,"#"+id+"="+n)
            EndIf
            constMap(id)=n
          EndIf
        ElseIf Left(id, 5)="GLEW_"
          If bump()="GLEW_GET_VAR" And bump()="("
            Define sym.s=bump()
            If Left(sym, 7)="__GLEW_" And bump() = ")"
              WriteStringN(2, "Global GL_"+Mid(id, 5+1)+".s="+Chr(34)+sym+Chr(34)) 
            EndIf
          EndIf 
        ElseIf Left(id, 2)="gl"
          If bump()="GLEW_GET_FUN" And bump()="("
          	Define sym.s=bump()
          	
          	
          	
            If Left(sym, 6)="__glew" And bump() = ")"
              Define key.s = "PFNGL"+UCase( Mid(sym, 6+1) )+"PROC"
              Define val.s = funMap(key)
              
              If val
              	;WriteStringN(3, "Global "+id+val+"="+Chr(34)+sym+Chr(34))
              	Define funcAddr.s = "addr_"+id+".i As "+ #DQUOTE$ + sym + #DQUOTE$
              	
              	Define returnType.s = Left(val, 1)
              	Define protoFun.s
              	If Asc(returnType) = Asc("(")
              		protoFun = "Prototype.i proto_"+id+val
              	Else
              		protoFun = "Prototype.i proto_"+id+Mid(val,3)
              	EndIf
              		
              	Define funCall.s = "Global "+id+".proto_"+id
              	Debug protoFun
              	;Debug funCall
                WriteStringN(3, ""+id+val)
              Else
                WriteStringN(3,"***** "+sym+" *****")
              EndIf
            EndIf
          EndIf
        EndIf  
      EndIf
    ElseIf curr="typedef"
      bump()
      Define funty.s = gltype()
      If funty<>"x" And curr="(" And bump()="GLAPIENTRY" And bump()="*"
        Define id.s=bump()
        If Left(id, 5) ="PFNGL" And bump()=")" And bump()="("
          Define proto.s = glproto()
          If proto <> "x"
            
            funMap(id) = funty+"("+proto+")"
          EndIf
        EndIf
      EndIf
    EndIf
  Wend
  CloseFile(0)
  CloseFile(1)
  CloseFile(2)
  CloseFile(3)
Else
  PrintN("Couldn't open the file")
EndIf





; IDE Options = PureBasic 5.31 Beta 4 (Windows - x64)
; CursorPosition = 243
; FirstLine = 92
; Folding = h9
; EnableUnicode
; EnableXP