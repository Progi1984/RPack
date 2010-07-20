; XIncludeFile "../src/RPack.pb"
; RPack_Init()

	sPath.s 		= GetCurrentDirectory()
	sPath_All.s	= sPath+"TAR_Extract_All"
	sPath_One.s	= sPath+"TAR_Extract_OneByOne"
	#EOL				=	Chr(13) + Chr(10)
	sText.s     = "" 
	;- RPACK > READ
	RPack_Create(0, "SampleTAR_Read.tar", #RPack_Type_Tar)
		RPack_Read(0)
		RPack_FindFirst(0)
		For Inc_a = 0 To RPack_GetFileCount(0) - 1
			Select RPack_GetType(0)
				Case #RPack_Type_Tar
					*Tar.S_RPack_TAR
					*Tar = RPack_GetFileInfo(0)
					With *Tar
					  sText = "FileID : " + Str(\lFileID) + #EOL
					  sText + "Path : " + \sFilePath + #EOL
					  sText + "FileName : " + \sFileName + #EOL
					  sText + "Mode : " + \sFileMode + #EOL
					  sText + "OUId : " + \sOUId + #EOL
					  sText + "GUId : " + \sGUId + #EOL
					  sText + "FileSize : " + Str(\lFileSize) + #EOL
					  sText + "LastModifTime : " + \sLastModifTime + #EOL
					  sText + "Checksum : " + \sChecksum + #EOL
					  sText + "LinkIndicator : " + Str(\lLinkIndicator) + #EOL
					  sText + "NameLinkedFile : " + \sNameLinkedFile + #EOL
					  sText + "Magic : " + \sMagic + #EOL
					  sText + "Version : " + \sVersion + #EOL
					  sText + "UName : " + \sUName + #EOL
					  sText + "GName : " + \sGName + #EOL
					  sText + "DevMajor : " + \sDevMajor + #EOL
					  sText + "DevMinor : " + \sDevMinor + #EOL
					  sText + "Prefix : " + \sPrefix + #EOL
					EndWith
					MessageRequester("RPack", sText)
					CompilerSelect #PB_Compiler_OS
					  CompilerCase #PB_OS_Linux : RPack_Extract(0, sPath_One+"/", #False)
					  CompilerCase #PB_OS_Windows : RPack_Extract(0, sPath_One+"\", #False)
					CompilerEndSelect
				Default
			EndSelect
			RPack_FindNext(0)
		Next
		RPack_Extract(0, sPath_All, #True)
	RPack_Free(0)
	
	;- RPACK > WRITE
 	RPack_Create(1, "SampleTAR_Write.tar", #RPack_Type_Tar)
		RPack_AddFiles(1, sPath_All, "*.*")
		RPack_FindFirst(1)
		For Inc_a = 0 To RPack_GetFileCount(1) -1
			Select RPack_GetType(1)
				Case #RPack_Type_Tar
					*Tar.S_RPack_TAR
					*Tar = RPack_GetFileInfo(1)
					With *Tar
					  sText = "FileID : " + Str(\lFileID) + #EOL
					  sText + "Path : " + \sFilePath + #EOL
					  sText + "FileName : " + \sFileName + #EOL
					  sText + "Mode : " + \sFileMode + #EOL
					  sText + "OUId : " + \sOUId + #EOL
					  sText + "GUId : " + \sGUId + #EOL
					  sText + "FileSize : " + Str(\lFileSize) + #EOL
					  sText + "LastModifTime : " + \sLastModifTime + #EOL
					  sText + "Checksum : " + \sChecksum + #EOL
					  sText + "LinkIndicator : " + Str(\lLinkIndicator) + #EOL
					  sText + "NameLinkedFile : " + \sNameLinkedFile + #EOL
					  sText + "Magic : " + \sMagic + #EOL
					  sText + "Version : " + \sVersion + #EOL
					  sText + "UName : " + \sUName + #EOL
					  sText + "GName : " + \sGName + #EOL
					  sText + "DevMajor : " + \sDevMajor + #EOL
					  sText + "DevMinor : " + \sDevMinor + #EOL
					  sText + "Prefix : " + \sPrefix + #EOL
					EndWith
					MessageRequester("RPack", sText)
				Default
			EndSelect
			RPack_FindNext(1)
		Next
		CompilerSelect #PB_Compiler_OS
		  CompilerCase #PB_OS_Linux : RPack_Compress(1, sPath +"/SampleTAR_Write.tar", #RPack_Method_Create)
		  CompilerCase #PB_OS_Windows : RPack_Compress(1, sPath +"\SampleTAR_Write.tar", #RPack_Method_Create)
		CompilerEndSelect
	RPack_Free(1)