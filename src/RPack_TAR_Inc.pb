	Procedure RPack_Tar_Read(ID.l)
		Protected *RObject.S_RPack = RPACK_ID(ID)
		Protected lFileTAR.l
		Protected sAscii.s
		If *RObject
      If FileSize(*RObject\sFileName) = -1
        ProcedureReturn #RPack_Error_FileNotFound
      Else
        FileTAR = ReadFile(#PB_Any, *RObject\sFileName)
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
                    \lFileID = ID
                    \sFileName = Ascii
                    \sFileMode = RMisc_ReadAscii(FileTAR, 8)
                    \sOUID = RMisc_ReadAscii(FileTAR, 8)
                    \sGUID = RMisc_ReadAscii(FileTAR, 8)
                    \lFileSize = RMisc_OctToDec(Trim(RMisc_ReadAscii(FileTAR, 12)))
                    \sLastModifTime = RMisc_ReadAscii(FileTAR, 12)
                    \sChecksum = RMisc_ReadAscii(FileTAR, 8)
                    \lLinkIndicator  = Val(Trim(RMisc_ReadAscii(FileTAR, 1)))
                    \sNameLinkedFile = RMisc_ReadAscii(FileTAR, 100)
                    \sMagic = RMisc_ReadAscii(FileTAR,6)
                    If Trim(\sMagic) ="ustar"
                      \sVersion = RMisc_ReadAscii(FileTAR, 2)
                      \sUname = RMisc_ReadAscii(FileTAR, 32)
                      \sGName = RMisc_ReadAscii(FileTAR, 32)
                      \sDevMajor = RMisc_ReadAscii(FileTAR, 8)
                      \sDevMinor = RMisc_ReadAscii(FileTAR, 8)
                      \sPrefix = RMisc_ReadAscii(FileTAR, 155)
                    Else
                      FileSeek(FileTAR, Loc(FileTAR) - 6)
                    EndIf
                    If \lFileSize > 0
                      FileSeek(FileTAR, Loc(FileTAR) + (512 - Loc(FileTAR) % 512))
                      \lMemory = AllocateMemory(\lFileSize)
                      ReadData(FileTAR, \lMemory, \lFileSize)
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
				If S_RPack_TAR_File()\lFileID	=	ID 
					If Count = *RObject\lLocation
						Break
					Else
						Count + 1
					EndIf
				EndIf
			Next
  		ProcedureReturn @S_RPack_TAR_File()
  	EndIf
	EndProcedure
	Procedure RPack_Tar_Compress(ID.l, FileName.s, bAppendMethod.b)
	 	Protected TarSize.l = 0
	 	Protected TarMemoryLoc.l = 0
	 	Protected FileOpen.l, FileMemory.l, TarCreate.l, TarMemory.l
  	; Taille du Tar
  	ForEach S_RPack_TAR_File()
  		If S_RPack_TAR_File()\lFileID = ID
  			TarSize + 512 + S_RPack_TAR_File()\lFileSize + (512 - (S_RPack_TAR_File()\lFileSize % 512))
  		EndIf
  	Next
  	TarSize + 512
  	; Allocation de Mémoire
  	TarMemory = AllocateMemory(TarSize)
		With S_RPack_TAR_File()
	  	ForEach S_RPack_TAR_File()
	  		If \lFileID = ID
		      For Inc_a = 1 To Len(\sFileName)
		      	PokeB(TarMemory + TarMemoryLoc,Asc(Mid(\sFileName,Inc_a,1)))
		      	TarMemoryLoc + 1
		      Next
		      TarMemoryLoc + (100- Len(\sFileName))
		      For Inc_a = 1 To Len(\sFileMode)
		      	PokeB(TarMemory + TarMemoryLoc,Asc(Mid(\sFileMode,Inc_a,1)))
		      	TarMemoryLoc + 1
		      Next
		      For Inc_a = 1 To Len(\sOUID)
		      	PokeB(TarMemory + TarMemoryLoc,Asc(Mid(\sOUID,Inc_a,1)))
		      	TarMemoryLoc + 1
		      Next
		      For Inc_a = 1 To Len(\sGUID)
		      	PokeB(TarMemory + TarMemoryLoc,Asc(Mid(\sGUID,Inc_a,1)))
		      	TarMemoryLoc + 1
		      Next
		      For Inc_a = 1 To Len(RSet(RMisc_DecToOct(\lFileSize),12," "))
		      	PokeB(TarMemory + TarMemoryLoc,Asc(Mid(RSet(RMisc_DecToOct(\lFileSize),12," "), Inc_a,1)))
		      	TarMemoryLoc + 1
		      Next
		      For Inc_a = 1 To Len(\sLastModifTime)
		      	PokeB(TarMemory + TarMemoryLoc,Asc(Mid(\sLastModifTime, Inc_a,1)))
		      	TarMemoryLoc + 1
		      Next
		      For Inc_a = 1 To Len(\sChecksum)
		      	PokeB(TarMemory + TarMemoryLoc,Asc(Mid(\sChecksum, Inc_a,1)))
		      	TarMemoryLoc + 1
		      Next
		      PokeB(TarMemory + TarMemoryLoc,Asc(Str(\lLinkIndicator)))
		      TarMemoryLoc + 1
		      For Inc_a = 1 To Len(\sNameLinkedFile)
		      	PokeB(TarMemory + TarMemoryLoc,Asc(Mid(\sNameLinkedFile, Inc_a,1)))
		      	TarMemoryLoc + 1
		      Next
		  		TarMemoryLoc + (512 - (TarMemoryLoc % 512))
		  		If FileSize(\sFilePath) > 0
		  			CopyMemory(\lMemory, TarMemory + TarMemoryLoc, MemorySize(\lMemory))
		  			TarMemoryLoc + (MemorySize(\lMemory) + 512 - MemorySize(\lMemory)%512)
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
    If Right(OutputPath,1) <> #System_Separator
      OutputPath + #System_Separator
    EndIf
    With S_RPack_TAR_File()
	    ForEach S_RPack_TAR_File()
	      If \lFileID = ID
	        If FileNum = FileID
	          If \lLinkIndicator = 0
	            FileCreateName = OutputPath + ReplaceString(\sFileName,"/","\")
	            FileCreateID = RMisc_OpenFileEx(#PB_Any, FileCreateName)
	            WriteData(FileCreateID, \lMemory, \lFileSize)
	            CloseFile(FileCreateID)
	          Else
	            FileCreateName = OutputPath + ReplaceString(\sFileName,"/","\")
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
	      If \lFileID = ID
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
	      If \lFileID = ID And \sFileName = Path + GetFilePart(FileName)
	        ProcedureReturn #RPack_Error_FileEverListed
	      EndIf
	    Next
	    If FileSize(FileName) >= 0
	    	Sum_Header			=	0
	      LastElement(S_RPack_TAR_File())
	      AddElement(S_RPack_TAR_File())
	      \lFileID = ID
	      \sFilePath =	FileName
	      \sFileName = GetFilePart(FileName)
	      \sFileMode = RSet("777",8, " ")
	      \sOUID = RSet("0"  ,8, " ")
	      \sGUID = RSet("0"  ,8, " ")
	      \lFileSize = FileSize(FileName)
	      \sLastModifTime = RSet(RMisc_DecToOct(RMisc_GetModifTime(FileName)),12, " ")
	      \sChecksum = RSet(""		, 8, " ")
	      \lLinkIndicator = 0
	      \sNameLinkedFile = RSet(""  	,100, " ")
	      ; Checksum
	      For Inc_a = 1 To Len(\sFileName)
	      	Sum_Header + Asc(Mid(\sFileName,Inc_a,1))
	      Next
	      For Inc_a = 1 To Len(\sFileMode)
	      	Sum_Header + Asc(Mid(\sFileMode,Inc_a,1))
	      Next
	      For Inc_a = 1 To Len(\sOUID)
	      	Sum_Header + Asc(Mid(\sOUID,Inc_a,1))
	      Next
	      For Inc_a = 1 To Len(\sGUID)
	      	Sum_Header + Asc(Mid(\sGUID,Inc_a,1))
	      Next
	      For Inc_a = 1 To Len(RSet(RMisc_DecToOct(\lFileSize),12," "))
	      	Sum_Header + Asc(Mid(RSet(RMisc_DecToOct(\lFileSize),12," "),Inc_a,1))
	      Next
	      For Inc_a = 1 To Len(\sLastModifTime)
	      	Sum_Header + Asc(Mid(\sLastModifTime,Inc_a,1))
	      Next
	      For Inc_a = 1 To Len(\sChecksum)
	      	Sum_Header + Asc(Mid(\sChecksum,Inc_a,1))
	      Next
	     	Sum_Header + Asc(Str(\lLinkIndicator))
	      For Inc_a = 1 To Len(\sNameLinkedFile)
	      	Sum_Header + Asc(Mid(\sNameLinkedFile,Inc_a,1))
	      Next
	    	\sChecksum = RSet(RMisc_DecToOct(Sum_Header), 8, " ")
	    	
	    	\lMemory =	AllocateMemory(\lFileSize)
	    	FileRead = ReadFile(#PB_Any, \sFilePath)
	    	  ReadData(FileRead, \lMemory, \lFileSize)
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
	      If \lFileID = ID And \sFileName = FileName
	        ProcedureReturn #RPack_Error_FileEverListed
	      EndIf
	      If FileSize(FileName) >= 0
		    	Sum_Header			=	0
		      LastElement(S_RPack_TAR_File())
		      AddElement(S_RPack_TAR_File())
		      \lFileID = ID
		      \sFilePath =	GetPathPart(FileName)
		      \sFileName = FileName
		      \sFileMode = RSet("777",8, " ")
		      \sOUID = RSet("0"  ,8, " ")
		      \sGUID = RSet("0"  ,8, " ")
		      \lFileSize = MemoryBankSize
		      \sLastModifTime = RSet(RMisc_DecToOct(Date()),12, " ")
		      \sChecksum = RSet(""		, 8, " ")
		      \lLinkIndicator = 0
		      \sNameLinkedFile = RSet("",100, " ")
		      ; Checksum
		      For Inc_a = 1 To Len(\sFileName)
		      	Sum_Header + Asc(Mid(\sFileName,Inc_a,1))
		      Next
		      For Inc_a = 1 To Len(\sFileMode)
		      	Sum_Header + Asc(Mid(\sFileMode,Inc_a,1))
		      Next
		      For Inc_a = 1 To Len(\sOUID)
		      	Sum_Header + Asc(Mid(\sOUID,Inc_a,1))
		      Next
		      For Inc_a = 1 To Len(\sGUID)
		      	Sum_Header + Asc(Mid(\sGUID,Inc_a,1))
		      Next
		      For Inc_a = 1 To Len(RSet(RMisc_DecToOct(\lFileSize),12," "))
		      	Sum_Header + Asc(Mid(RSet(RMisc_DecToOct(\lFileSize),12," "),Inc_a,1))
		      Next
		      For Inc_a = 1 To Len(\sLastModifTime)
		      	Sum_Header + Asc(Mid(\sLastModifTime,Inc_a,1))
		      Next
		      For Inc_a = 1 To Len(\sChecksum)
		      	Sum_Header + Asc(Mid(\sChecksum,Inc_a,1))
		      Next
		     	Sum_Header + Asc(Str(\lLinkIndicator))
		      For Inc_a = 1 To Len(\sNameLinkedFile)
		      	Sum_Header + Asc(Mid(\sNameLinkedFile,Inc_a,1))
		      Next
		    	
		    	\sChecksum = RSet(RMisc_DecToOct(Sum_Header), 8, " ")
		    	
		    	\lMemory =	AllocateMemory(\lFileSize)
		    	CopyMemory(*MemoryBank, \lMemory, \lFileSize)
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
	      If \lFileID = ID
	        If \sFileName = FileName
	        	ProcedureReturn FileNum
	        Else
	        	FileNum + 1
	        EndIf
	      EndIf
	    Next
    EndWith
    ProcedureReturn #RPack_Error_FileNotFound
	EndProcedure