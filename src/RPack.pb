;- Import
CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Windows ;{
    Import "C:\Program Files\PureBasic\Compilers\ObjectManager.lib"
      Object_GetOrAllocateID  (Objects, Object.l) As "_PB_Object_GetOrAllocateID@8"
      Object_GetObject        (Objects, Object.l) As "_PB_Object_GetObject@8"
      Object_IsObject         (Objects, Object.l) As "_PB_Object_IsObject@8"
      Object_EnumerateAll     (Objects, ObjectEnumerateAllCallback, *VoidData) As "_PB_Object_EnumerateAll@12"
      Object_EnumerateStart   (Objects) As "_PB_Object_EnumerateStart@4"
      Object_EnumerateNext    (Objects, *object.Long) As "_PB_Object_EnumerateNext@8"
      Object_EnumerateAbort   (Objects) As "_PB_Object_EnumerateAbort@4"
      Object_FreeID           (Objects, Object.l) As "_PB_Object_FreeID@8"
      Object_Init             (StructureSize.l, IncrementStep.l, ObjectFreeFunction) As "_PB_Object_Init@12"
      Object_GetThreadMemory  (MemoryID.l) As "_PB_Object_GetThreadMemory@4"
      Object_InitThreadMemory (Size.l, InitFunction, EndFunction) As "_PB_Object_InitThreadMemory@12"
    EndImport
  ;}
  CompilerCase #PB_OS_Linux ;{
    ImportC "/media/DISK/Programs/purebasic/compilers/objectmanager.a"
      Object_GetOrAllocateID  (Objects, Object.l) As "PB_Object_GetOrAllocateID"
      Object_GetObject        (Objects, Object.l) As "PB_Object_GetObject"
      Object_IsObject         (Objects, Object.l) As "PB_Object_IsObject"
      Object_EnumerateAll     (Objects, ObjectEnumerateAllCallback, *VoidData) As "PB_Object_EnumerateAll"
      Object_EnumerateStart   (Objects) As "PB_Object_EnumerateStart"
      Object_EnumerateNext    (Objects, *object.Long) As "PB_Object_EnumerateNext"
      Object_EnumerateAbort   (Objects) As "PB_Object_EnumerateAbort"
      Object_FreeID           (Objects, Object.l) As "PB_Object_FreeID"
      Object_Init             (StructureSize.l, IncrementStep.l, ObjectFreeFunction) As "PB_Object_Init"
      Object_GetThreadMemory  (MemoryID.l) As "PB_Object_GetThreadMemory"
      Object_InitThreadMemory (Size.l, InitFunction, EndFunction) As "PB_Object_InitThreadMemory"
    EndImport
  ;}
CompilerEndSelect

CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Linux ;{
    Global System_Separator.s = "/"
  ;}
  CompilerCase #PB_OS_Windows ;{
    Global System_Separator.s = "\"
  ;}
CompilerEndSelect

; Declarations
Declare RPack_Tar_Read(ID.l)
Declare RPack_Tar_FileInfo(ID.l)
Declare RPack_Tar_Compress(ID.l, FileName.s, AppendMethod.l)
Declare RPack_Tar_ExtractOne(ID, OutputPath.s, FileID.l)
Declare RPack_Tar_ExtractAll(ID, OutputPath.s)
Declare RPack_Tar_AddFile(ID.l, FileName.s, Path.s)
Declare RPack_Tar_AddMemory(ID.l, FileName.s, *MemoryBank, MemoryBankSize.l)
Declare RPack_Tar_FindFile(ID.l, FileName.s)

;- Functions RMisc
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
Procedure.l RMisc_OpenFileEx(File.l, FileName.s)
  Protected PathPart.s = ""
  Protected FilePart.s = GetFilePart(FileName)
  Protected Inc_a.l
  If GetPathPart(FileName) <> ""
      Inc_a = 1
      Repeat
        Node.s = StringField(FileName, Inc_a, "\")
        If Node = FilePart
            Break
        EndIf
        PathPart + Node + "\"
        If FileSize(PathPart) = -2
          Else
            CreateDirectory(PathPart)
        EndIf
        Inc_a + 1
      Until Node = ""
  EndIf
  ProcedureReturn OpenFile(File, FileName)
EndProcedure 
Procedure.l RMisc_CreateDirectoryEx(FolderPath.s)
 Protected Folder.s, Txt.s, Cpt.l
 If FileSize(Folder) = -1
  Folder = StringField(FolderPath, 1, System_Separator) + System_Separator
  Cpt     = 1
  Repeat
   Cpt + 1
   Txt      = StringField(FolderPath, Cpt, System_Separator)
   Folder = Folder + Txt + System_Separator
   CreateDirectory(Folder)
  Until Txt = ""
 EndIf
 If FileSize(FolderPath) = -2
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
ProcedureDLL.l RPack_(ID.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)

EndProcedure

ProcedureDLL.l RPack_Create(ID.l, FileName.s, Type.l)
  Protected *RObject.S_RPack = RPACK_NEW(ID)
	With *RObject
		\FileName =	FileName
		\Type =	Type
	EndWith
  ProcedureReturn *RObject
EndProcedure
ProcedureDLL.l RPack_Read(ID.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
	Select *RObject\Type 
		Case #RPack_Type_Tar
			ProcedureReturn RPack_Tar_Read(ID)
		Default
			ProcedureReturn #RPack_Error_Format_Unknown		
	EndSelect
EndProcedure
ProcedureDLL.l RPack_Free(ID.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
    ; Format : Tar
  	ForEach S_RPack_TAR_File()
  		If S_RPack_TAR_File()\FileID = ID
  			DeleteElement(S_RPack_TAR_File())
  		EndIf
  	Next
  	
  	; Free the pack
  	RPackFree(Id)
  	ProcedureReturn #RPack_Error_Success
  EndIf
EndProcedure
ProcedureDLL.l RPack_GetType(ID.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
	  ProcedureReturn *RObject\Type
	EndIf
EndProcedure
ProcedureDLL.l RPack_GetFileCount(ID.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  Protected lNum.l
  If *RObject
  	Select *RObject\Type 
  		Case #RPack_Type_Tar ;{
      	ForEach S_RPack_TAR_File()
      		With S_RPack_TAR_File()
      			If \FileID	=	Id
      				lNum	+1
      			EndIf
      		EndWith
      	Next
  		;}
  		Default
  			ProcedureReturn #RPack_Error_Format_Unknown		
  	EndSelect
  EndIf
  ProcedureReturn lNum
EndProcedure
ProcedureDLL.l RPack_FileInfo(ID.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
  	Select *RObject\Type 
  		Case #RPack_Type_Tar
  			ProcedureReturn RPack_Tar_FileInfo(ID)
  		Default
  			ProcedureReturn #RPack_Error_Format_Unknown
  	EndSelect
  EndIf
EndProcedure

ProcedureDLL.l RPack_FindFirst(ID.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
  	*RObject\Location	=	0
  	ProcedureReturn #RPack_Error_Success
  EndIf
EndProcedure
ProcedureDLL.l RPack_FindNext(ID.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
  	If *RObject\Location < RPack_GetFileCount(ID) - 1
  		*RObject\Location	+ 1
  	EndIf
  	ProcedureReturn #RPack_Error_Success
  EndIf
EndProcedure
ProcedureDLL.l RPack_FindFile(ID.l, FileName.s)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
  	Select *RObject\Type 
  		Case #RPack_Type_Tar
  			ProcedureReturn RPack_Tar_FindFile(ID.l, FileName.s)
  		Default
  			ProcedureReturn #RPack_Error_Format_Unknown		
  	EndSelect
  EndIf
EndProcedure
ProcedureDLL.l RPack_Extract(ID.l, Path.s, ExtractPath.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
		If ExtractPath = #True ; on extrait tout
			Select *RObject\Type 
				Case #RPack_Type_Tar
					ProcedureReturn RPack_Tar_ExtractAll(ID, Path)
				Default
					ProcedureReturn #RPack_Error_Format_Unknown
			EndSelect
		Else
			Select *RObject\Type 
				Case #RPack_Type_Tar
					ProcedureReturn RPack_Tar_ExtractOne(ID, Path, *RObject\Location)
				Default
					ProcedureReturn #RPack_Error_Format_Unknown
			EndSelect
		EndIf
  EndIf
EndProcedure
ProcedureDLL.l RPack_ExtractFile(ID.l, FileNumberInArchive.l, OutputPath.s) 
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
  	Select *RObject\Type 
  		Case #RPack_Type_Tar
  			ProcedureReturn RPack_Tar_ExtractOne(ID, OutputPath, FileNumberInArchive)
  		Default
  			ProcedureReturn #RPack_Error_Format_Unknown
  	EndSelect
  EndIf
EndProcedure
ProcedureDLL.l RPack_Compress(ID.l, FileName.s, AppendMethod.l)
  Protected *RObject.S_RPack 	= RPACK_ID(ID)
  If *RObject
  	Select *RObject\Type 
  		Case #RPack_Type_Tar
  			ProcedureReturn RPack_Tar_Compress(ID, FileName, AppendMethod)
  		Default
  			ProcedureReturn #RPack_Error_Format_Unknown
  	EndSelect
  EndIf
EndProcedure
ProcedureDLL.l RPack_AddFile(ID.l, FileName.s, Path.s)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
  	Select *RObject\Type 
  		Case #RPack_Type_Tar
  			ProcedureReturn RPack_Tar_AddFile(ID, FileName, Path)
  		Default
  			ProcedureReturn #RPack_Error_Format_Unknown
  	EndSelect
  EndIf
EndProcedure
ProcedureDLL.l RPack_AddFiles(ID.l, Directory.s, Filter.s)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  Protected lDirExam.l
  Protected sEntryName.s
  If *RObject
    If Right(Directory, 1) <> System_Separator
      Directory + System_Separator
    EndIf
  	lDirExam = ExamineDirectory(#PB_Any, Directory, Filter)  
  	If lDirExam
      While NextDirectoryEntry(lDirExam)
      	sEntryName = DirectoryEntryName(lDirExam)
        If DirectoryEntryType(lDirExam) = #PB_DirectoryEntry_File
  				Select *RObject\Type 
  					Case #RPack_Type_Tar
  						RPack_Tar_AddFile(ID, Directory + sEntryName, Directory)
  						ProcedureReturn #RPack_Error_Success
  				EndSelect
        EndIf
      Wend
      FinishDirectory(lDirExam)
    EndIf
  	ProcedureReturn #RPack_Error_Success
  EndIf
EndProcedure
ProcedureDLL.l RPack_AddMemory(ID.l, FileName.s, *MemoryBank, MemoryBankSize.l)
  Protected *RObject.S_RPack = RPACK_ID(ID)
  If *RObject
  	Select *RObject\Type 
  		Case #RPack_Type_Tar
  			ProcedureReturn RPack_Tar_AddMemory(ID, FileName, *MemoryBank, MemoryBankSize)
  		Default
  			ProcedureReturn #RPack_Error_Format_Unknown
  	EndSelect
  EndIf
EndProcedure

;- TAR
;{
	Procedure RPack_Tar_Read(ID.l)
		Protected *RObject.S_RPack = RPACK_ID(ID)
		Protected FileTAR.l
		Protected Ascii.s
		If *RObject
      If FileSize(*RObject\FileName) = -1
        ProcedureReturn #RPack_Error_FileNotFound
      Else
        FileTAR = ReadFile(#PB_Any, *RObject\FileName)
        FileSeek(FileTAR,0)
        If FileTAR
          With S_RPack_TAR_File()
          	Repeat
            	Repeat
                Ascii.s = RMisc_ReadAscii(FileTAR, 100)
                If Len(Ascii) = 0
                  FileSeek(FileTAR, Loc(FileTAR) + (512 - Loc(FileTAR) % 512))
                Else
                  LastElement(S_RPack_TAR_File())
                  AddElement(S_RPack_TAR_File())
                    \FileID = ID
                    \FileName = Ascii
                    \FileMode = RMisc_ReadAscii(FileTAR, 8)
                    \OUID = RMisc_ReadAscii(FileTAR, 8)
                    \GUID = RMisc_ReadAscii(FileTAR, 8)
                    \FileSize = RMisc_OctToDec(Trim(RMisc_ReadAscii(FileTAR, 12)))
                    \LastModifTime = RMisc_ReadAscii(FileTAR, 12)
                    \Checksum = RMisc_ReadAscii(FileTAR, 8)
                    \LinkIndicator  = Val(Trim(RMisc_ReadAscii(FileTAR, 1)))
                    \NameLinkedFile = RMisc_ReadAscii(FileTAR, 100)
                    \Magic = RMisc_ReadAscii(FileTAR,6)
                    If Trim(\Magic) ="ustar"
                      \Version = RMisc_ReadAscii(FileTAR, 2)
                      \Uname = RMisc_ReadAscii(FileTAR, 32)
                      \GName = RMisc_ReadAscii(FileTAR, 32)
                      \DevMajor = RMisc_ReadAscii(FileTAR, 8)
                      \DevMinor = RMisc_ReadAscii(FileTAR, 8)
                      \Prefix = RMisc_ReadAscii(FileTAR, 155)
                    Else
                      FileSeek(FileTAR, Loc(FileTAR) - 6)
                    EndIf
                    If \FileSize > 0
                      FileSeek(FileTAR, Loc(FileTAR) + (512 - Loc(FileTAR) % 512))
                      \Memory = AllocateMemory(\FileSize)
                      ReadData(FileTAR, \Memory, \FileSize)
                    EndIf
                    If Loc(FileTAR) % 512 <> 0
                      FileSeek(FileTAR, Loc(FileTAR) + (512 - Loc(FileTAR) % 512))
                    EndIf
                  Break
                EndIf 
              Until Len(Ascii) > 0 Or Eof(FileTAR) > 0
            Until Eof(FileTAR) > 0
            CloseFile(FileTAR)
          EndWith
          ProcedureReturn #RPack_Error_Success
        Else
          ProcedureReturn #RPack_Error_FileNotOpened
        EndIf
      EndIf
    EndIf
	EndProcedure
	Procedure RPack_Tar_FileInfo(ID.l)
		Protected *RObject.S_RPack 	= RPACK_ID(ID)
		Protected Count.l =	0
		If *RObject
			ForEach S_RPack_TAR_File()
				If S_RPack_TAR_File()\FileID	=	ID 
					If Count = *RObject\Location
						Break
					Else
						Count + 1
					EndIf
				EndIf
			Next
  		ProcedureReturn @S_RPack_TAR_File()
  	EndIf
	EndProcedure
	Procedure RPack_Tar_Compress(ID.l, FileName.s, AppendMethod.l)
	 	Protected TarSize.l = 0
	 	Protected TarMemoryLoc.l = 0
	 	Protected FileOpen.l, FileMemory.l, TarCreate.l, TarMemory.l
  	; Taille du Tar
  	ForEach S_RPack_TAR_File()
  		If S_RPack_TAR_File()\FileID = ID
  			TarSize + 512 + S_RPack_TAR_File()\FileSize + (512 - (S_RPack_TAR_File()\FileSize % 512))
  		EndIf
  	Next
  	TarSize + 512
  	; Allocation de Mémoire
  	TarMemory = AllocateMemory(TarSize)
		With S_RPack_TAR_File()
	  	ForEach S_RPack_TAR_File()
	  		If \FileID = ID
		      For Inc_a = 1 To Len(\FileName)
		      	PokeB(TarMemory + TarMemoryLoc,Asc(Mid(\FileName,Inc_a,1)))
		      	TarMemoryLoc + 1
		      Next
		      TarMemoryLoc + (100- Len(\FileName))
		      For Inc_a = 1 To Len(\FileMode)
		      	PokeB(TarMemory + TarMemoryLoc,Asc(Mid(\FileMode,Inc_a,1)))
		      	TarMemoryLoc + 1
		      Next
		      For Inc_a = 1 To Len(\OUID)
		      	PokeB(TarMemory + TarMemoryLoc,Asc(Mid(\OUID,Inc_a,1)))
		      	TarMemoryLoc + 1
		      Next
		      For Inc_a = 1 To Len(\GUID)
		      	PokeB(TarMemory + TarMemoryLoc,Asc(Mid(\GUID,Inc_a,1)))
		      	TarMemoryLoc + 1
		      Next
		      For Inc_a = 1 To Len(RSet(RMisc_DecToOct(\FileSize),12," "))
		      	PokeB(TarMemory + TarMemoryLoc,Asc(Mid(RSet(RMisc_DecToOct(\FileSize),12," "), Inc_a,1)))
		      	TarMemoryLoc + 1
		      Next
		      For Inc_a = 1 To Len(\LastModifTime)
		      	PokeB(TarMemory + TarMemoryLoc,Asc(Mid(\LastModifTime, Inc_a,1)))
		      	TarMemoryLoc + 1
		      Next
		      For Inc_a = 1 To Len(\Checksum)
		      	PokeB(TarMemory + TarMemoryLoc,Asc(Mid(\Checksum, Inc_a,1)))
		      	TarMemoryLoc + 1
		      Next
		      PokeB(TarMemory + TarMemoryLoc,Asc(Str(\LinkIndicator)))
		      TarMemoryLoc + 1
		      For Inc_a = 1 To Len(\NameLinkedFile)
		      	PokeB(TarMemory + TarMemoryLoc,Asc(Mid(\NameLinkedFile, Inc_a,1)))
		      	TarMemoryLoc + 1
		      Next
		  		TarMemoryLoc + (512 - (TarMemoryLoc % 512))
		  		If FileSize(\FilePath) > 0
		  			CopyMemory(\Memory, TarMemory + TarMemoryLoc, MemorySize(\Memory))
		  			TarMemoryLoc + (MemorySize(\Memory) + 512 - MemorySize(\Memory)%512)
		  		EndIf
	  		EndIf
	  	Next
  	EndWith
  	; Append
		If AppendMethod = #RPack_Method_Create
			If FileSize(FileName) > -1
				DeleteFile(FileName)
			EndIf
		ElseIf AppendMethod = #RPack_Method_Append
			; Ouvre le fichier
			FileOpen 	= OpenFile(#PB_Any, FileName)
			; Envoie le contenu du fichier dans *FileMemory 
			ReadData	(FileOpen, FileMemory, FileSize(FileName))
			CloseFile	(FileOpen)
			
			; Mets *TarMemory dans une mem temporaire
			TmpMemory = AllocateMemory(MemorySize(TarMemory))
			CopyMemory(TarMemory, TmpMemory, MemorySize(TarMemory))
			; Agrandit TarMemory de la taille de *FileMemory
			TarMemory = ReAllocateMemory(TarMemory, MemorySize(TarMemory) + MemorySize(FileMemory))
			; Copie *FileMemory au début de TarMemory
			CopyMemory(FileMemory, TarMemory, MemorySize(FileMemory))
			; Copie *TarMemory à la fin
			CopyMemory(TmpMemory, TarMemory + MemorySize(FileMemory), MemorySize(TmpMemory))
			; Libère Mem inutiles
			FreeMemory(TmpMemory)
			FreeMemory(FileMemory)
			If FileSize(FileName) > -1
				DeleteFile(FileName)
			EndIf
		EndIf
  	; Ecriture du Tar
  	TarCreate = CreateFile(#PB_Any, FileName)
  	If TarCreate
	  	WriteData(TarCreate, TarMemory, MemorySize(TarMemory))
	  	CloseFile(TarCreate)
	  	FreeMemory(TarMemory)
	  	ProcedureReturn #RPack_Error_Success
  	Else
  		ProcedureReturn #RPack_Error_FileNotCreated
  	EndIf
	EndProcedure
	Procedure RPack_Tar_ExtractOne(ID, OutputPath.s, FileID.l)
    Protected FileNum.l = 0, FileCreateID.l
    Protected FileCreateName.s
    If Right(OutputPath,1) <> System_Separator
      OutputPath + System_Separator
    EndIf
    With S_RPack_TAR_File()
	    ForEach S_RPack_TAR_File()
	      If \FileID = ID
	        If FileNum = FileID
	          If \LinkIndicator = 0
	            FileCreateName = OutputPath + ReplaceString(\FileName,"/","\")
	            FileCreateID = RMisc_OpenFileEx(#PB_Any, FileCreateName)
	            WriteData(FileCreateID, \Memory, \FileSize)
	            CloseFile(FileCreateID)
	          Else
	            FileCreateName = OutputPath + ReplaceString(\FileName,"/","\")
	            RMisc_CreateDirectoryEx(FileCreateName)
	          EndIf
	          ProcedureReturn #RPack_Error_Success
	        Else
	          FileNum + 1
	        EndIf
	      EndIf
	    Next
    EndWith
    ProcedureReturn #RPack_Error_FileNotFound
	EndProcedure
	Procedure RPack_Tar_ExtractAll(ID, OutputPath.s)
    Protected FileNum.l = 0
    With S_RPack_TAR_File()
	    ForEach S_RPack_TAR_File()
	      If \FileID = ID
	        RPack_Tar_ExtractOne(ID, OutputPath, FileNum)
	        FileNum + 1
	      EndIf
	    Next
    EndWith
    ProcedureReturn #RPack_Error_Success
	EndProcedure
	Procedure RPack_Tar_AddFile(ID.l, FileName.s, Path.s)
    Protected Sum_Header.l	= 0
    Protected FileRead.l, Inc_a.l
    With S_RPack_TAR_File()
	    ForEach S_RPack_TAR_File()
	      If \FileID = ID And \FileName = Path + GetFilePart(FileName)
	        ProcedureReturn #RPack_Error_FileEverListed
	      EndIf
	    Next
	    If FileSize(FileName) >= 0
	    	Sum_Header			=	0
	      LastElement(S_RPack_TAR_File())
	      AddElement(S_RPack_TAR_File())
	      \FileID = ID
	      \FilePath =	FileName
	      \FileName = GetFilePart(FileName)
	      \FileMode = RSet("777",8, " ")
	      \OUID = RSet("0"  ,8, " ")
	      \GUID = RSet("0"  ,8, " ")
	      \FileSize = FileSize(FileName)
	      \LastModifTime = RSet(RMisc_DecToOct(RMisc_GetModifTime(FileName)),12, " ")
	      \Checksum = RSet(""		, 8, " ")
	      \LinkIndicator = 0
	      \NameLinkedFile = RSet(""  	,100, " ")
	      ; Checksum
	      For Inc_a = 1 To Len(\FileName)
	      	Sum_Header + Asc(Mid(\FileName,Inc_a,1))
	      Next
	      For Inc_a = 1 To Len(\FileMode)
	      	Sum_Header + Asc(Mid(\FileMode,Inc_a,1))
	      Next
	      For Inc_a = 1 To Len(\OUID)
	      	Sum_Header + Asc(Mid(\OUID,Inc_a,1))
	      Next
	      For Inc_a = 1 To Len(\GUID)
	      	Sum_Header + Asc(Mid(\GUID,Inc_a,1))
	      Next
	      For Inc_a = 1 To Len(RSet(RMisc_DecToOct(\FileSize),12," "))
	      	Sum_Header + Asc(Mid(RSet(RMisc_DecToOct(\FileSize),12," "),Inc_a,1))
	      Next
	      For Inc_a = 1 To Len(\LastModifTime)
	      	Sum_Header + Asc(Mid(\LastModifTime,Inc_a,1))
	      Next
	      For Inc_a = 1 To Len(\Checksum)
	      	Sum_Header + Asc(Mid(\Checksum,Inc_a,1))
	      Next
	     	Sum_Header + Asc(Str(\LinkIndicator))
	      For Inc_a = 1 To Len(\NameLinkedFile)
	      	Sum_Header + Asc(Mid(\NameLinkedFile,Inc_a,1))
	      Next
	    	\CheckSum = RSet(RMisc_DecToOct(Sum_Header), 8, " ")
	    	
	    	\Memory =	AllocateMemory(\FileSize)
	    	FileRead = ReadFile(#PB_Any, \FilePath)
	    	  ReadData(FileRead, \Memory, \FileSize)
	    	CloseFile(FileRead)
	    	ProcedureReturn #RPack_Error_Success
	    Else
	      ProcedureReturn #RPack_Error_FileNotFound
	    EndIf
    EndWith
	EndProcedure
	Procedure RPack_Tar_AddMemory(ID.l, FileName.s, *MemoryBank, MemoryBankSize.l)
		With S_RPack_TAR_File()
	    ForEach S_RPack_TAR_File()
	      If \FileID = ID And \FileName = FileName
	        ProcedureReturn #RPack_Error_FileEverListed
	      EndIf
	      If FileSize(FileName) >= 0
		    	Sum_Header			=	0
		      LastElement(S_RPack_TAR_File())
		      AddElement(S_RPack_TAR_File())
		      \FileID = ID
		      \FilePath =	GetPathPart(FileName)
		      \FileName = FileName
		      \FileMode = RSet("777",8, " ")
		      \OUID = RSet("0"  ,8, " ")
		      \GUID = RSet("0"  ,8, " ")
		      \FileSize = MemoryBankSize
		      \LastModifTime = RSet(RMisc_DecToOct(Date()),12, " ")
		      \Checksum = RSet(""		, 8, " ")
		      \LinkIndicator = 0
		      \NameLinkedFile = RSet("",100, " ")
		      ; Checksum
		      For Inc_a = 1 To Len(\FileName)
		      	Sum_Header + Asc(Mid(\FileName,Inc_a,1))
		      Next
		      For Inc_a = 1 To Len(\FileMode)
		      	Sum_Header + Asc(Mid(\FileMode,Inc_a,1))
		      Next
		      For Inc_a = 1 To Len(\OUID)
		      	Sum_Header + Asc(Mid(\OUID,Inc_a,1))
		      Next
		      For Inc_a = 1 To Len(\GUID)
		      	Sum_Header + Asc(Mid(\GUID,Inc_a,1))
		      Next
		      For Inc_a = 1 To Len(RSet(RMisc_DecToOct(\FileSize),12," "))
		      	Sum_Header + Asc(Mid(RSet(RMisc_DecToOct(\FileSize),12," "),Inc_a,1))
		      Next
		      For Inc_a = 1 To Len(\LastModifTime)
		      	Sum_Header + Asc(Mid(\LastModifTime,Inc_a,1))
		      Next
		      For Inc_a = 1 To Len(\Checksum)
		      	Sum_Header + Asc(Mid(\Checksum,Inc_a,1))
		      Next
		     	Sum_Header + Asc(Str(\LinkIndicator))
		      For Inc_a = 1 To Len(\NameLinkedFile)
		      	Sum_Header + Asc(Mid(\NameLinkedFile,Inc_a,1))
		      Next
		    	
		    	\CheckSum = RSet(RMisc_DecToOct(Sum_Header), 8, " ")
		    	
		    	\Memory =	AllocateMemory(\FileSize)
		    	CopyMemory(*MemoryBank, \Memory, \FileSize)
		    	ProcedureReturn #RPack_Error_Success
		    Else
		      ProcedureReturn #RPack_Error_FileNotFound
		    EndIf
	    Next
		EndWith
	EndProcedure
	Procedure RPack_Tar_FindFile(ID.l, FileName.s)
    Protected FileNum.l = 0
    With S_RPack_TAR_File()
	    ForEach S_RPack_TAR_File()
	      If \FileID = ID
	        If \FileName = FileName
	        	ProcedureReturn FileNum
	        Else
	        	FileNum + 1
	        EndIf
	      EndIf
	    Next
    EndWith
    ProcedureReturn #RPack_Error_FileNotFound
	EndProcedure
;}
;{ RPM
	Procedure RPack_RPM_GetHeader(ID.l)
    If OpenFile(0, "amule-2.1.3-3.fc7.i386.rpm")
      Debug "Header"
      Debug ReadCharacter(0)
      Debug $ED
      Debug ReadCharacter(0)
      Debug $AB
      Debug ReadCharacter(0)
      Debug $EE
      Debug ReadCharacter(0)
      Debug $DB
      
      Debug "MAJ"
      Debug ReadCharacter(0)
      Debug "MIN"
      Debug ReadCharacter(0)
      
      Debug "TYPE"
      Debug ReadCharacter(0)

      Debug "ARCH"
      Debug ReadCharacter(0)

      Debug "NAME"
      Debug RMisc_ReadAscii(0, 66) 
;       sString.s = ""
;       For Inc = 0 To 65
;         sString + Chr(ReadCharacter(0))
;       Next 
;       Debug sString
      
      Debug "OS"
      Debug ReadCharacter(0)
      
      Debug "Signature"
      Debug ReadCharacter(0)
      
      Debug "Reserved"
      Debug RMisc_ReadAscii(0, 16) 
      
      CloseFile(0)
    EndIf
	EndProcedure
;}
;{ CPIO
;}
;{ XTM
;}