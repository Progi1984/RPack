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