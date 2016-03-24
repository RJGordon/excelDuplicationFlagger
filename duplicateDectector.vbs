'Author: Ryan J Gordon, March 2016

'This programs purpose is to identify duplicate account entries in a client database (though it could easily be tweaked for any database)
'To be flagged as duplicates, accounts need not be identical.
'Duplicate flagging works by using a 'duplication threshold'. If two accounts are similar enough to meet this threshold, they are marked as duplicates.
'In this version, first name and last name are weighted- meaning they are required to be matching in order to meet the threshold.
'In addition to having the same first and last name, accounts must also share either physical address, or email address, to be marked as duplicates.
'Everything is case insensitive

'Future versions will detect minor spelling differences on accounts and intelligently decide whether the differences are mistakes or intentional.
'Future versions will also have email spelling mistake correction (i.e. gmial.com -> gmail.com) using both intelligent string comparison algorithms and SMTP port checking

'This code assumes the following: column A is last name, column B is first name, column C is address, column D is email, and columns E and F are empty.


'************* Technical Details ***************'
'This reads the entire sheet into a massive array, made up of subarrays, where each subarray is the column data for the given row.
'For each row not marked as a duplicate, it loops through every row after it searching for duplicates of it (and marking them when found).
'I've calculated this to lead to roughly a complexity of O[1/2(n-1)^2 + (n-1)].
'Once completed it writes the array back into the sheet.
'All application features that lead to possible slow downs are disabled before running and enabled afterwords.


Sub Main():
    Application.ActiveSheet.UsedRange
    Dim lRowCount As Integer
    lRowCount = Worksheets(ActiveSheet.Name).UsedRange.Rows.Count


    Application.ScreenUpdating = False
    Application.DisplayStatusBar = False
    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False
    ActiveSheet.DisplayPageBreaks = False
    
    Dim sheet() As Variant
    sheet = sheetArray(lRowCount)
    Call duplicates(sheet, lRowCount)
    Call writeToSheet(sheet, lRowCount)
    
    Application.ScreenUpdating = True
    Application.DisplayStatusBar = True
    Application.EnableEvents = True
    ActiveSheet.DisplayPageBreaks = True
End Sub

'Reads data from sheet into sheetArray
Function sheetArray(ByRef lRowCount):
    Dim sheetArr() As Variant
    ReDim sheetArr(lRowCount)
    For i = 1 To lRowCount:
        Dim Fields(1 To 6) As String
        
        Fields(1) = Range("A" & i).Value
        Fields(2) = Range("B" & i).Value
        Fields(3) = Range("C" & i).Value
        Fields(4) = Range("D" & i).Value
        Fields(5) = Range("E" & i).Value
        Fields(6) = Range("F" & i).Value
        
        sheetArr(i) = Fields
    Next
    sheetArray = sheetArr
End Function

'Writes data back into sheet
Sub writeToSheet(ByRef sheet, ByVal lRowCount):
    For i = 1 To lRowCount:
        Range("A" & i).Value = sheet(i)(1)
        Range("B" & i).Value = sheet(i)(2)
        Range("C" & i).Value = sheet(i)(3)
        Range("D" & i).Value = sheet(i)(4)
        Range("E" & i).Value = sheet(i)(5)
        Range("F" & i).Value = sheet(i)(6)
    Next
End Sub

Sub duplicates(ByRef sheet As Variant, ByVal lRowCount As Integer):
    For i = 1 To lRowCount
    
        If Duplicate = vbNullString Then
    
            Dim lastName, firstName, email, address As String
            
            lastName = UCase(sheet(i)(1))
            firstName = UCase(sheet(i)(2))
            address = UCase(sheet(i)(3))
            email = UCase(sheet(i)(4))
            Duplicate = sheet(i)(5)
        
            For n = (i + 1) To lRowCount
                
                Dim duplicateCounter As Integer
                duplicateCounter = 0
                
                Dim lastName2, firstName2, email2, address2 As String
                
                lastName2 = UCase(sheet(n)(1))
                firstName2 = UCase(sheet(n)(2))
                address2 = UCase(sheet(n)(3))
                email2 = UCase(sheet(n)(4))
                
                'Weak form of fuzzy logic
                If (StrComp(firstName, firstName, vbTextCompare) = 0) Then
                    duplicateCounter = duplicateCounter + 2
                End If
                
                If (StrComp(lastName, lastName2, vbTextCompare) = 0) Then
                    duplicateCounter = duplicateCounter + 2
                End If
                
                If (StrComp(address, address2, vbTextCompare) = 0) Or (StrComp(email, email2, vbTextCompare) = 0) Then
                    duplicateCounter = duplicateCounter + 1
                End If
                
                If duplicateCounter >= 5 Then
                    sheet(i)(5) = "YES"
                    sheet(i)(6) = i
                    sheet(n)(5) = "YES"
                    sheet(n)(6) = i
                End If
                
            Next
        End If
    Next
End Sub
        

