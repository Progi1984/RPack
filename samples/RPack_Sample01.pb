XIncludeFile "RPack_Res.pb"
XIncludeFile "RPack.pb"


RPack_Init()

	;- RPACK > READ
	RPack_Create(0, "amule-2.1.3-3.fc7.i386.rpm", #RPack_Type_RPM)
  RPack_RPM_GetHeader(0)
	RPack_Free(0)