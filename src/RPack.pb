; Macros for double quotes
Macro DQuote
  "
EndMacro
; Define the ImportLib
CompilerSelect #PB_Compiler_Thread
  CompilerCase #False ;{ THREADSAFE : OFF
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Linux         : #Power_ObjectManagerLib = #PB_Compiler_Home + "compilers/objectmanager.a"
      CompilerCase #PB_OS_Windows   : #Power_ObjectManagerLib = #PB_Compiler_Home + "compilers\ObjectManager.lib"
    CompilerEndSelect
  ;}
  CompilerCase #True ;{ THREADSAFE : ON
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Linux         : #Power_ObjectManagerLib = #PB_Compiler_Home + "compilers/objectmanagerthread.a"
      CompilerCase #PB_OS_Windows   : #Power_ObjectManagerLib = #PB_Compiler_Home + "compilers\ObjectManagerThread.lib"
    CompilerEndSelect
  ;}
CompilerEndSelect
; Macro ImportFunction
CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Linux ;{
    Macro ImportFunction(Name, Param)
      DQuote#Name#DQuote
    EndMacro
  ;}
  CompilerCase #PB_OS_Windows ;{
    Macro ImportFunction(Name, Param)
      DQuote _#Name@Param#DQuote
    EndMacro
  ;}
CompilerEndSelect
; Import the ObjectManager library
CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Linux : ImportC #Power_ObjectManagerLib
  CompilerCase #PB_OS_Windows : Import #Power_ObjectManagerLib
CompilerEndSelect
  Object_GetOrAllocateID(Objects, Object.l) As ImportFunction(PB_Object_GetOrAllocateID, 8)
  Object_GetObject(Objects, Object.l) As ImportFunction(PB_Object_GetObject,8)
  Object_IsObject(Objects, Object.l) As ImportFunction(PB_Object_IsObject,8)
  Object_EnumerateAll(Objects, ObjectEnumerateAllCallback, *VoidData) As ImportFunction(PB_Object_EnumerateAll,12)
  Object_EnumerateStart(Objects) As ImportFunction(PB_Object_EnumerateStart,4)
  Object_EnumerateNext(Objects, *object.Long) As ImportFunction(PB_Object_EnumerateNext,8)
  Object_EnumerateAbort(Objects) As ImportFunction(PB_Object_EnumerateAbort,4)
  Object_FreeID(Objects, Object.l) As ImportFunction(PB_Object_FreeID,8)
  Object_Init(StructureSize.l, IncrementStep.l, ObjectFreeFunction) As ImportFunction(PB_Object_Init,12)
  Object_GetThreadMemory(MemoryID.l) As ImportFunction(PB_Object_GetThreadMemory,4)
  Object_InitThreadMemory(Size.l, InitFunction, EndFunction) As ImportFunction(PB_Object_InitThreadMemory,12)
EndImport

Procedure.s RMisc_ReadAscii(FileID.l, NumByte.l)
  Protected Ascii.s, Inc_a.l
  Ascii = ""
  For Inc_a = 1 To NumByte
    Ascii + Chr(ReadByte(FileID))
  Next
  ProcedureReturn Ascii
EndProcedure
Procedure.l RMisc_OctToDec(Octal.s)
  Protected Dec.l, Inc_a.l
  Dec = 0
  For Inc_a=1 To Len(octal)
    Dec=Dec+Val(Mid(octal,Len(octal)-Inc_a+1,1))*Pow(8,Inc_a-1)
  Next Inc_a
  ProcedureReturn Dec
EndProcedure
Procedure.s RMisc_DecToOct(Dec.l)
  Protected Octal.s
  Octal = ""
  Repeat
    Octal = Str(Dec%8) + Octal
    Dec   = Int(Dec/8)
  Until Dec<8
  Octal = Str(Dec) + Octal
  ProcedureReturn Octal
EndProcedure
Procedure.l RMisc_OpenFileEx(File.l, sFileName.s)
  Protected sPathPart.s
  Protected sFilePart.s = GetFilePart(sFileName)
  Protected lInc.l
  If GetPathPart(sFileName) <> ""
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Linux : lInc = 2 : sPathPart = "/"
      CompilerCase #PB_OS_Windows : lInc = 1 : sPathPart = ""
    CompilerEndSelect
    Repeat
      sNode.s = StringField(GetPathPart(sFileName), lInc, #System_Separator)
      If sNode > ""
        If sNode = sFilePart
            Break
        EndIf
        sPathPart + sNode + #System_Separator
        If FileSize(sPathPart) = -2
        Else
            CreateDirectory(sPathPart)
        EndIf
        lInc + 1
      EndIf
    Until sNode = ""
  EndIf
  ProcedureReturn OpenFile(File, sFileName)
EndProcedure 
Procedure.l RMisc_CreateDirectoryEx(sFolderPath.s)
  Protected sFolder.s, sTxt.s
  Protected lCpt.l
 If FileSize(sFolder) = -1
  sFolder = StringField(sFolderPath, 1, #System_Separator) + #System_Separator
  lCpt     = 1
  Repeat
   lCpt + 1
   sTxt      = StringField(sFolderPath, sCpt, #System_Separator)
   sFolder = sFolder + sTxt + #System_Separator
   CreateDirectory(sFolder)
  Until sTxt = ""
 EndIf
 If FileSize(sFolderPath) = -2
  ProcedureReturn #True
 Else
  ProcedureReturn #False
 EndIf
EndProcedure 
Procedure.l RMisc_GetModifTime(Filename.s)
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows ;{
      Protected lFile.l, hLibKernel.l
      Protected ftc.FILETIME, ftlat.FILETIME, ftlwt.FILETIME, ftlocal.FILETIME
      Protected st.SYSTEMTIME
      Protected sDateFile.s, sHourFile.s
      lFile = OpenFile(#PB_Any, Filename) ; recupère le Handle du fichier avec la fonction OpenFile
      If lFile 
        hLibKernel = OpenLibrary(#PB_Any, "kernel32.dll")
        If hLibKernel
          CallFunction(hLibKernel, "GetFileTime", FileID(lFile), ftc, ftlat, ftlwt)
          ; pour prendre en compte l'heure d'été et d'hiver
          CallFunction(hLibKernel, "FileTimeToLocalFileTime", @ftlwt, @ftlocal) 
          ; pour convertir la date dans le format systemtime
          CallFunction(hLibKernel, "FileTimeToSystemTime", @ftlocal, @st)
          ; on initialise les variables
          sDateFile = Space(256)
          sHourFile = sDateFile
          ; donne la dte du fichier
          GetDateFormat_(2048, 0, @st, "dd'/'MM'/'yyyy", @sDateFile, 254) 
          ; donne l'heure du fichier
          GetTimeFormat_(2048, #TIME_FORCE24HOURFORMAT, @st, 0, @sHourFile, 254) 
          ; on assemble l'année et l'heure
          sDateFile = sDateFile + " " + sHourFile
          ; on libère les ressources
          CloseLibrary(hLibKernel)
          CloseFile(lFile)
          ProcedureReturn ParseDate("%dd/%mm/%yyyy %hh:%ii:%ss", sDateFile)
        EndIf
      EndIf
      ProcedureReturn #RPack_Error
    ;}
    CompilerCase #PB_OS_Linux ;{
      Protected stat_infos.stat
      If stat_(@Filename, @stat_infos) = #False
        ProcedureReturn stat_infos\st_mtime
      Else
        ProcedureReturn #RPack_Error
      EndIf
    ;}
  CompilerEndSelect
EndProcedure

Procedure RPackFree(ID.l)
  Protected *RObject.S_RPack
	If *RObject
    RPACK_FREEID(ID)
  EndIf
  ProcedureReturn #True
EndProcedure
ProcedureDLL RPack_Init()
  Global RPackObjects = RPACK_INITIALIZE(@RPackFree()) 
  
  Global NewList S_RPack_TAR_File.S_RPack_TAR()
EndProcedure

IncludePath #PB_Compiler_FilePath
;XIncludeFile "RPack_RPM_Inc.pb"
XIncludeFile "RPack_TAR_Inc.pb"

ProcedureDLL.l RPack_Create(ID.l, sFileName.s, lType.l)
  Protected *RObject.S_RPack = RPACK_NEW(ID)
  If *RObject
  	With *RObject
  		\sFileName  =	sFileName
  		\lType      =	lType
  	EndWith
    ProcedureReturn *RObject
  Else
    ProcedureReturn #False
  EndIf
EndProcedure
ProcedureDLL.l RPack_Read(ID.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
  	Select *RObject\lType 
  		Case #RPack_Type_TAR
  			ProcedureReturn RPack_Tar_Read(ID)
  		Default
  			ProcedureReturn #RPack_Error_Format_Unknown		
  	EndSelect
  Else
    ProcedureReturn #False
  EndIf
EndProcedure
ProcedureDLL.l RPack_Free(ID.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
    ; Format : Tar
  	ForEach S_RPack_TAR_File()
  		If S_RPack_TAR_File()\lFileID = ID
  			DeleteElement(S_RPack_TAR_File())
  		EndIf
  	Next
  	
  	; Free the pack
  	RPackFree(ID)
  	ProcedureReturn #RPack_Error_Success
  EndIf
EndProcedure
ProcedureDLL.l RPack_GetType(ID.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
	  ProcedureReturn *RObject\lType
	Else
	  ProcedureReturn #False
	EndIf
EndProcedure
ProcedureDLL.l RPack_GetFileCount(ID.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  Protected lNum.l
  If *RObject
  	Select *RObject\lType 
  		Case #RPack_Type_TAR ;{
      	ForEach S_RPack_TAR_File()
      		With S_RPack_TAR_File()
      			If \lFileID	=	ID
      				lNum	+1
      			EndIf
      		EndWith
      	Next
      	ProcedureReturn lNum
  		;}
  		Default
  			ProcedureReturn #RPack_Error_Format_Unknown		
  	EndSelect
  Else
    ProcedureReturn #False
  EndIf
EndProcedure
ProcedureDLL.l RPack_GetFileInfo(ID.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
  	Select *RObject\lType 
  		Case #RPack_Type_TAR
  			ProcedureReturn RPack_Tar_FileInfo(ID)
  		Default
  			ProcedureReturn #RPack_Error_Format_Unknown
  	EndSelect
  Else
    ProcedureReturn #False  
  EndIf
EndProcedure

ProcedureDLL.l RPack_FindFirst(ID.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
  	*RObject\lLocation	=	0
  	ProcedureReturn #RPack_Error_Success
  EndIf
EndProcedure
ProcedureDLL.l RPack_FindNext(ID.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
  	If *RObject\lLocation < RPack_GetFileCount(ID) - 1
  		*RObject\lLocation	+ 1
  	EndIf
  	ProcedureReturn #RPack_Error_Success
  EndIf
EndProcedure
ProcedureDLL.l RPack_FindFile(ID.l, sFileName.s)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
  	Select *RObject\lType 
  		Case #RPack_Type_TAR
  			ProcedureReturn RPack_Tar_FindFile(ID.l, sFileName.s)
  		Default
  			ProcedureReturn #RPack_Error_Format_Unknown		
  	EndSelect
  Else
    ProcedureReturn #False
  EndIf
EndProcedure
;@todo : Moebius 1.5 : Default bExtractPath à #True
ProcedureDLL.l RPack_Extract(ID.l, sPath.s, bExtractPath.b)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
		If bExtractPath = #True ; on extrait tout
			Select *RObject\lType 
				Case #RPack_Type_TAR
					ProcedureReturn RPack_Tar_ExtractAll(ID, sPath)
				Default
					ProcedureReturn #RPack_Error_Format_Unknown
			EndSelect
		Else
			Select *RObject\lType 
				Case #RPack_Type_TAR
					ProcedureReturn RPack_Tar_ExtractOne(ID, sPath, *RObject\lLocation)
				Default
					ProcedureReturn #RPack_Error_Format_Unknown
			EndSelect
		EndIf
  Else
    ProcedureReturn #False
  EndIf
EndProcedure
ProcedureDLL.l RPack_ExtractFile(ID.l, lFileNumberInArchive.l, sOutputPath.s) 
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
  	Select *RObject\lType 
  		Case #RPack_Type_TAR
  			ProcedureReturn RPack_Tar_ExtractOne(ID, sOutputPath, lFileNumberInArchive)
  		Default
  			ProcedureReturn #RPack_Error_Format_Unknown
  	EndSelect
  Else
    ProcedureReturn #False
  EndIf
EndProcedure
ProcedureDLL.l RPack_Compress(ID.l, sFileName.s, bAppendMethod.b)
  Protected *RObject.S_RPack 	= RPACK_ID(ID)
  If *RObject
  	Select *RObject\lType 
  		Case #RPack_Type_TAR
  			ProcedureReturn RPack_Tar_Compress(ID, sFileName, bAppendMethod)
  		Default
  			ProcedureReturn #RPack_Error_Format_Unknown
  	EndSelect
  Else
    ProcedureReturn #False
  EndIf
EndProcedure
ProcedureDLL.l RPack_AddFile(ID.l, sFileName.s, sPath.s)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
  	Select *RObject\lType 
  		Case #RPack_Type_TAR
  			ProcedureReturn RPack_Tar_AddFile(ID, sFileName, sPath)
  		Default
  			ProcedureReturn #RPack_Error_Format_Unknown
  	EndSelect
  Else
    ProcedureReturn #False
  EndIf
EndProcedure
;@todo : Moebius 1.5 : Default sFilter à "*.*"
ProcedureDLL.l RPack_AddFiles(ID.l, sDirectory.s, sFilter.s)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  Protected lDirExam.l
  Protected sEntryName.s
  If *RObject
    If Right(sDirectory, 1) <> #System_Separator
      sDirectory + #System_Separator
    EndIf
  	lDirExam = ExamineDirectory(#PB_Any, sDirectory, sFilter)  
  	If lDirExam
      While NextDirectoryEntry(lDirExam)
      	sEntryName = DirectoryEntryName(lDirExam)
        If DirectoryEntryType(lDirExam) = #PB_DirectoryEntry_File
  				Select *RObject\lType 
  					Case #RPack_Type_TAR
  						RPack_Tar_AddFile(ID, sDirectory + sEntryName, sDirectory)
  				EndSelect
        EndIf
      Wend
      FinishDirectory(lDirExam)
    EndIf
  	ProcedureReturn #RPack_Error_Success
  Else
    ProcedureReturn #False
  EndIf
EndProcedure
ProcedureDLL.l RPack_AddMemory(ID.l, sFileName.s, *MemBank, lMemBankSize.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
  	Select *RObject\lType 
  		Case #RPack_Type_TAR
  			ProcedureReturn RPack_Tar_AddMemory(ID, sFileName, *MemBank, lMemBankSize)
  		Default
  			ProcedureReturn #RPack_Error_Format_Unknown
  	EndSelect
  Else
    ProcedureReturn #False
  EndIf
EndProcedure
