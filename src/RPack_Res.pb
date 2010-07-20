;{ Macros
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
;}
;{ Structures
  Structure S_RPack
  	FileName.s
  	Type.l
  	Location.l
  EndStructure
  Structure S_RPack_TAR
    FileID.l
    FilePath.s
    FileName.s
    FileMode.s
    OUId.s
    GUId.s
    FileSize.l
    LastModifTime.s
    Checksum.s
    LinkIndicator.l
    NameLinkedFile.s
    Memory.l
    Magic.s
    Version.s
    UName.s
    GName.s
    DevMajor.s
    DevMinor.s
    Prefix.s
  EndStructure
;}
;{ Constantes
  Enumeration 0 ; Type
  	#RPack_Type_RPM
  	#RPack_Type_TAR
  EndEnumeration
  Enumeration 0 ; Error
    #RPack_Error
    #RPack_Error_Format_Unknown
  	#RPack_Error_FileNotFound
  	#RPack_Error_FileNotOpened
  	#RPack_Error_FileNotCreated
  	#RPack_Error_FileEverListed
  	#RPack_Error_Success
  EndEnumeration
  Enumeration 0 ; Append
  	#RPack_Method_Create
  	#RPack_Method_Append
  EndEnumeration
;}

;{ System : Linux
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
;}