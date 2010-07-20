;- Macros
  Macro RPACK_ID(object)
    Object_GetObject(RPackObjects, object)
  EndMacro
  Macro RPACK_IS(object)
    Object_IsObject(RPackObjects, object) 
  EndMacro
  Macro RPACK_NEW(object)
    Object_GetOrAllocateID(RPackObjects, object)
  EndMacro
  Macro RPACK_FREEID(object)
    If object <> #PB_Any And RPACK_IS(object) = #True
      Object_FreeID(RPackObjects, object)
    EndIf
  EndMacro
  Macro RPACK_INITIALIZE(hCloseFunction)
    Object_Init(SizeOf(S_RPack), 1, hCloseFunction)
  EndMacro

;- Structures
Structure S_RPack
	sFileName.s
	lType.l
	lLocation.l
EndStructure

;- Constantes
Enumeration 1 ; Type
	#RPack_Type_RPM
	#RPack_Type_TAR
EndEnumeration
Enumeration 0 ; Error
  #RPack_Error
  #RPack_Error_Format_Unknown = -5
	#RPack_Error_FileNotFound = -4
	#RPack_Error_FileNotOpened = -3
	#RPack_Error_FileNotCreated = -2
	#RPack_Error_FileEverListed = -1
	#RPack_Error_Error = 0
	#RPack_Error_Success = 1
EndEnumeration
Enumeration 1 ; Append
	#RPack_Method_Create
	#RPack_Method_Append
EndEnumeration

CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Linux   : #System_Separator = "/"
  CompilerCase #PB_OS_Windows : #System_Separator = "\"
CompilerEndSelect

;- System : Linux
CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  Structure stat
    st_dev.l
    _unused_1.l
    _unused_2.l
    st_ino.l
    st_mode.l
    st_nlink.l
    st_uid.l
    st_gid.l
    st_rdev.l
    _unused_3.l
    _unused_4.l
    st_size.l
    st_blksize.l
    st_blocks.l
    st_atime.l
    st_atime_nsec.l
    st_mtime.l
    st_mtime_nsec.l
    st_ctime.l
    st_ctime_nsec.l
    __unused4.l
    __unused5.l
  EndStructure
CompilerEndIf

XIncludeFile "RPack_TAR_Res.pb"