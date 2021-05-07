Function MailAndCtrlAppends() As String

    DoCmd.SetWarnings (False)



    Dim mailFile As DAO.Recordset

    Dim ctrlFile As DAO.Recordset

    Dim i As Long

    Dim mailFileFieldCount As Integer

    Dim ctrlFileFieldCount As Integer

    Dim fieldName As String



    Dim mailAlterTableQueries As String

    Dim mailUpdateQuery As String



    Dim ctrlAlterTableQueries As String

    Dim ctrlUpdateQuery As String



    Dim hardmatchMailFieldsString As String

    Dim hardmatchMailFields() As String

    Dim hardmatchMailFieldsForUpdateString As String

    Dim hardmatchMailFieldsForUpdate() As String

    Dim hardmatchMailFieldCount As Integer

    Dim mailFileVarsString As String

    Dim mailFileVars() As String

    Dim splitMailQueries() As String



    Dim hardmatchCtrlFieldsString As String

    Dim hardmatchCtrlFields() As String

    Dim hardmatchCtrlFieldsForUpdateString As String

    Dim hardmatchCtrlFieldsForUpdate() As String

    Dim hardmatchCtrlFieldCount As Integer

    Dim ctrlFileVarsString As String

    Dim ctrlFileVars() As String

    Dim splitCtrlQueries() As String



    ' ////////// *Hardmatch Mail //////////



    With CurrentDb.OpenRecordset("*Hardmatch Mail")

        hardmatchMailFieldCount = .Fields.Count

        For i = 0 To hardmatchMailFieldCount - 1

            hardmatchMailFieldsString = hardmatchMailFieldsString + .Fields(i).Name + ";"

        Next

        .Close

    End With



    hardmatchMailFields = Split(hardmatchMailFieldsString, ";")

'    Debug.Print Join(hardmatchMailFields, ",")



    ' Get Mail File variables

    Set mailFile = CurrentDb.OpenRecordset("Mail File")



    With mailFile

        mailFileFieldCount = .Fields.Count

        For i = 0 To mailFileFieldCount - 1

            fieldName = .Fields(i).Name

            mailFileVarsString = mailFileVarsString + fieldName + ";"



            If IsInArray(fieldName, hardmatchMailFields) Then

                Debug.Print fieldName & " exists so it needs an underscore!"

                fieldName = fieldName & "_"

            End If



            hardmatchMailFieldsForUpdateString = hardmatchMailFieldsForUpdateString + fieldName + ";"

            mailAlterTableQueries = mailAlterTableQueries & "ALTER TABLE " & "[*Hardmatch Mail] ADD COLUMN [" & fieldName & "] " & convertTableType(.Fields(i).Type) & ";"

        Next

        .Close

    End With



    Set mailFile = Nothing



    splitMailQueries = Split(mailAlterTableQueries, ";")

    For Each SQLSegment In splitMailQueries

        If InStr(SQLSegment, "Hardmatch") > 0 Then

            Debug.Print "Segment to run: " & SQLSegment

            DoCmd.RunSQL SQLSegment

        End If

    Next



    hardmatchMailFieldsForUpdateString = Left(hardmatchMailFieldsForUpdateString, Len(hardmatchMailFieldsForUpdateString) - 1)

    hardmatchMailFieldsForUpdate = Split(hardmatchMailFieldsForUpdateString, ";")

    Debug.Print "HM Mail fields: " + Join(hardmatchMailFieldsForUpdate, ",") + vbNewLine + vbNewLine

    mailFileVarsString = Left(mailFileVarsString, Len(mailFileVarsString) - 1)

    mailFileVars = Split(mailFileVarsString, ";")

    Debug.Print "Mail File fields: " + Join(mailFileVars, ",") + vbNewLine + vbNewLine

    mailUpdateQuery = "UPDATE [*Hardmatch Mail] INNER JOIN [Mail File] ON [*Hardmatch Mail].MailfileID = [Mail File].FMCGID SET "



    For i = 1 To mailFileFieldCount - 1

        mailUpdateQuery = mailUpdateQuery & "[*Hardmatch Mail].[" & hardmatchMailFieldsForUpdate(i) & "] = [Mail File].[" & mailFileVars(i) & "], "

    Next



    ' Remove the extra comma from the UPDATE query

    mailUpdateQuery = Left(mailUpdateQuery, Len(mailUpdateQuery) - 2)

    DoCmd.RunSQL mailUpdateQuery



    ' ////////// *Hardmatch Ctrl //////////



    With CurrentDb.OpenRecordset("*Hardmatch Ctrl")

        hardmatchCtrlFieldCount = .Fields.Count

        For i = 0 To hardmatchCtrlFieldCount - 1

            hardmatchCtrlFieldsString = hardmatchCtrlFieldsString + .Fields(i).Name + ";"

        Next

        .Close

    End With



    hardmatchCtrlFields = Split(hardmatchCtrlFieldsString, ";")

'    Debug.Print Join(hardmatchCtrlFields, ",")



    ' Get Ctrl File variables

    Set ctrlFile = CurrentDb.OpenRecordset("Ctrl File")



    With ctrlFile

        ctrlFileFieldCount = .Fields.Count

        For i = 0 To ctrlFileFieldCount - 1

            fieldName = .Fields(i).Name

            ctrlFileVarsString = ctrlFileVarsString + fieldName + ";"



            If IsInArray(fieldName, hardmatchCtrlFields) Then

                Debug.Print fieldName & " exists so it needs an underscore!"

                fieldName = fieldName & "_"

            End If



            hardmatchCtrlFieldsForUpdateString = hardmatchCtrlFieldsForUpdateString + fieldName + ";"

            ctrlAlterTableQueries = ctrlAlterTableQueries & "ALTER TABLE " & "[*Hardmatch Ctrl] ADD COLUMN [" & fieldName & "] " & convertTableType(.Fields(i).Type) & ";"

        Next

        .Close

    End With



    Set ctrlFile = Nothing



    splitCtrlQueries = Split(ctrlAlterTableQueries, ";")

    For Each SQLSegment In splitCtrlQueries

        If InStr(SQLSegment, "Hardmatch") > 0 Then

            Debug.Print "Segment to run: " & SQLSegment

            DoCmd.RunSQL SQLSegment

        End If

    Next



    hardmatchCtrlFieldsForUpdateString = Left(hardmatchCtrlFieldsForUpdateString, Len(hardmatchCtrlFieldsForUpdateString) - 1)

    hardmatchCtrlFieldsForUpdate = Split(hardmatchCtrlFieldsForUpdateString, ";")

    Debug.Print "HM Ctrl fields: " + Join(hardmatchCtrlFieldsForUpdate, ",") + vbNewLine + vbNewLine

    ctrlFileVarsString = Left(ctrlFileVarsString, Len(ctrlFileVarsString) - 1)

    ctrlFileVars = Split(ctrlFileVarsString, ";")

    Debug.Print "Ctrl File fields: " + Join(ctrlFileVars, ",") + vbNewLine + vbNewLine

    ctrlUpdateQuery = "UPDATE [*Hardmatch Ctrl] INNER JOIN [Ctrl File] ON [*Hardmatch Ctrl].MailfileID = [Ctrl File].FMCGID SET "



    For i = 1 To ctrlFileFieldCount - 1

        ctrlUpdateQuery = ctrlUpdateQuery & "[*Hardmatch Ctrl].[" & hardmatchCtrlFieldsForUpdate(i) & "] = [Ctrl File].[" & ctrlFileVars(i) & "], "

    Next



    ' Remove the extra comma from the UPDATE query

    ctrlUpdateQuery = Left(ctrlUpdateQuery, Len(ctrlUpdateQuery) - 2)

    DoCmd.RunSQL ctrlUpdateQuery



    Debug.Print "Mail update query is: " & mailUpdateQuery & vbNewLine & vbNewLine

    Debug.Print "Ctrl update query is: " & ctrlUpdateQuery



    DoCmd.SetWarnings (True)



    MsgBox "Mail and Ctrl Appends are done!"

End Function



Function convertTableType(TableType As String)

    Dim convertedDataType As String



    If TableType = "1" Then

        convertedDataType = "Yes/No"

    ElseIf TableType = "2" Then

        convertedDataType = "Byte"

    ElseIf TableType = "3" Then

        convertedDataType = "Integer"

    ElseIf TableType = "4" Then

        convertedDataType = "Long Integer"

    ElseIf TableType = "5" Then

        convertedDataType = "Currency"

    ElseIf TableType = "6" Then

        convertedDataType = "Single"

    ElseIf TableType = "7" Then

        convertedDataType = "Double"

    ElseIf TableType = "8" Then

        convertedDataType = "DateTime"

    ElseIf TableType = "9" Then

        convertedDataType = "Binary"

    ElseIf TableType = "10" Then

        convertedDataType = "Varchar(255)"

    Else

        convertedDataType = "Varchar(255)"

    End If



    convertTableType = convertedDataType

End Function



Function IsInArray(searchString As Variant, arr As Variant) As Boolean

    Dim element As Variant



    On Error GoTo IsInArrayError: ' This happens if the array is empty

        For Each element In arr

            If element = searchString Then

                IsInArray = True

                Exit Function

            End If

        Next element



    Exit Function



IsInArrayError:

    On Error GoTo 0

    IsInArray = False



End Function
