#USE_STATIC_GLEW = 1

#GL_VERTEX_SHADER=$8B31

Macro DQ
    "
EndMacro


Import #PB_Compiler_Home+"PureLibraries/Windows/Libraries/opengl32.lib"
    EndImport
    Import "glew32s.lib" ; STDCALL on Windows
      
    Macro ImportName(__name__)
        DQ#__name__#DQ
    EndMacro

  
   libGlewInit() As "glewInit"
   glewGetString.i(name.i) ;As "_glewGetString@4"
   glewGetErrorString.i(error.i) ;As "_glewGetErrorString@4"
   
   ;adr_glCreateShader.i As ImportName(__glewCreateShader)
   adr_glCreateShader.i As "__glewCreateShader"
   
   
EndImport
Prototype.i proto_glCreateShader(type_.i)

Global glCreateShader.proto_glCreateShader


Procedure glewInit()
  
  
  error = libGlewInit()
  
  If error = 0
    Global glCreateShader.proto_glCreateShader = adr_glCreateShader
  Else
    Debug PeekS( glewGetErrorString(error), -1, #PB_Ascii)
    
  EndIf
EndProcedure


Macro glewGetProcAddress(__addr__)
  __addr__
EndMacro






Procedure Main()
    
    
    
    If InitSprite()=0                                                                                   
  		MessageRequester("Error Initializing Graphics System","The Sprite system could not be initialized",0)
  		End
  	EndIf
  	If InitKeyboard()=0                                                                                 
  		MessageRequester("Error Initializing Graphics System","The keyboard system could not be initialized",0)
  		End
  	EndIf
  	
    OpenWindow(0, 0, 0, 800, 600, "PureBasic Application", flags )
		
		If OpenWindowedScreen(WindowID(0), 0, 0, 800, 600, #False, 0, 0, vSyng)=0                                                                     
			MessageRequester("Error Openening Windowed Screen","An error has occured while opening the rendering screen",0)
			End
		EndIf
		
    
    Debug "GLEW Version: " + PeekS( glewGetString(1), -1, #PB_Ascii)
    
   
    glewInit()
    
    
        
        
    Debug "glCreateShader address: " + StrU(glCreateShader)
    If glCreateShader

      shader = glCreateShader(#GL_VERTEX_SHADER) ; Init OpenGl stuff first
      Shader2 = glCreateShader(#GL_VERTEX_SHADER)
        Debug "Algo:" + shader + " Otro:" + Shader2
    EndIf
    
    
EndProcedure



Main()
; IDE Options = PureBasic 5.31 Beta 4 (Windows - x64)
; CursorPosition = 28
; Folding = -
; EnableUnicode
; EnableXP