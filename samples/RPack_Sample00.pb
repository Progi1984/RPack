IncludeFile "../RPack_Res.pb"
IncludeFile "../RPack_Inc.pb"


RPack_Init()
	#Path 			= "D:\Mes projets\PB_Userlibs\RPack"
	#Path_All 	= #Path+"\Extract_All"
	#Path_One 	= #Path+"\Extract_OneByOne"
	#EOL				=	Chr(13)+Chr(10)
	
	Global Text.s ="" 
	
	;- RPACK > READ
	RPack_Create(0, "Example0.tar", #RPack_Type_Tar)
		RPack_Read(0)
		RPack_FindFirst(0)
		Debug RPack_GetFileCount(0)
		For Inc_a = 0 To RPack_GetFileCount(0) -1
			Select RPack_GetType(0)
				Case #RPack_Type_Tar
					*Tar.S_RPack_TAR
					*Tar = RPack_FileInfo(0)
					With *Tar
					  Text = "FileID : " + Str(\FileID.l) + #EOL
					  Text + "Path : " + \FilePath.s + #EOL
					  Text + "FileName : " + \FileName.s + #EOL
					  Text + "Mode : " + \FileMode.s + #EOL
					  Text + "OUId : " + \OUId.s + #EOL
					  Text + "GUId : " + \GUId.s + #EOL
					  Text + "FileSize : " + Str(\FileSize.l) + #EOL
					  Text + "LastModifTime : " + \LastModifTime.s + #EOL
					  Text + "Checksum : " + \Checksum.s + #EOL
					  Text + "LinkIndicator : " + Str(\LinkIndicator.l) + #EOL
					  Text + "NameLinkedFile : " + \NameLinkedFile.s + #EOL
					  Text + "Magic : " + \Magic.s + #EOL
					  Text + "Version : " + \Version.s + #EOL
					  Text + "UName : " + \UName.s + #EOL
					  Text + "GName : " + \GName.s + #EOL
					  Text + "DevMajor : " + \DevMajor.s + #EOL
					  Text + "DevMinor : " + \DevMinor.s + #EOL
					  Text + "Prefix : " + \Prefix.s + #EOL
					EndWith
					MessageRequester("RPack", Text)
					RPack_Extract(0, #Path_One+"\", #False)
				Default
			EndSelect
			RPack_FindNext(0)
		Next
		RPack_Extract(0, #Path_All, #True)
	RPack_Free(0)
	
	;- RPACK > WRITE
 	RPack_Create(1, "Example1.tar", #RPack_Type_Tar)
		Debug RPack_GetFileCount(1)
		RPack_AddFiles(1, #Path_All, "*.*")
		Debug RPack_GetFileCount(1)
		RPack_AddFile(1, #Path_All+"\5\4.doc", #Path_All)
		Debug RPack_GetFileCount(1)
		RPack_FindFirst(1)
		For Inc_a = 0 To RPack_GetFileCount(1) -1
			Select RPack_GetType(1)
				Case #RPack_Type_Tar
					*Tar.S_RPack_TAR
					*Tar = RPack_FileInfo(1)
					With *Tar
					  Text = "FileID : " + Str(\FileID.l) + #EOL
					  Text + "Path : " + \FilePath.s + #EOL
					  Text + "FileName : " + \FileName.s + #EOL
					  Text + "Mode : " + \FileMode.s + #EOL
					  Text + "OUId : " + \OUId.s + #EOL
					  Text + "GUId : " + \GUId.s + #EOL
					  Text + "FileSize : " + Str(\FileSize.l) + #EOL
					  Text + "LastModifTime : " + \LastModifTime.s + #EOL
					  Text + "Checksum : " + \Checksum.s + #EOL
					  Text + "LinkIndicator : " + Str(\LinkIndicator.l) + #EOL
					  Text + "NameLinkedFile : " + \NameLinkedFile.s + #EOL
					  Text + "Magic : " + \Magic.s + #EOL
					  Text + "Version : " + \Version.s + #EOL
					  Text + "UName : " + \UName.s + #EOL
					  Text + "GName : " + \GName.s + #EOL
					  Text + "DevMajor : " + \DevMajor.s + #EOL
					  Text + "DevMinor : " + \DevMinor.s + #EOL
					  Text + "Prefix : " + \Prefix.s + #EOL
					EndWith
					MessageRequester("RPack", Text)
				Default
			EndSelect
			RPack_FindNext(1)
		Next
		RPack_Compress(1, #Path +"\FileOUT.tar", #RPack_Method_Create)
	RPack_Free(1)
; IDE Options = PureBasic 4.10 Beta 2 (Windows - x86)
; CursorPosition = 1
; Folding = A-
; EnableXP
; EnableCompileCount = 110
; EnableBuildCount = 0