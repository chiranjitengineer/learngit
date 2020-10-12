Imports SW_DBObject
Imports System.Web
Imports Sw_Common
Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.IO
Imports System.Text
Imports System.Reflection
Imports AjaxControlToolkit
Imports System.Net
Imports swterp.Site1
Imports System.Collections.Generic
Imports System.Web.Script.Serialization
Imports System.Text.RegularExpressions
Imports System.Web.Services
Imports System.Web.ClientServices
Imports System.Data.OleDb

Public Class pgPFStaffDataUpload
    Inherits System.Web.UI.Page
    Dim strMessage As Label
    Dim btnSubmit As Button
    Dim strOptType As String
    Dim txtMasterTableName As TextBox
    Dim txtSyncActualTable As TextBox
    Dim txtButtonTag As TextBox
    Dim strMenutag As TextBox
    Dim strImpExpFile As String = ""

    ' for grid control
    Dim txtDETAILSTABLENAME As TextBox
    Dim blnExit As Boolean = True
    Dim dtTmp As New DataTable
    Dim blnHideDefHeader As Boolean = False
    Dim btnMasterSubmit As Button

    Private Property dtExcelSchema As DataTable

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim ddOperationType As DropDownList = DirectCast(Master.FindControl("ddChooseOperation"), DropDownList)
        strMessage = DirectCast(Master.FindControl("lblMasterMessage"), Label)
        txtMasterTableName = DirectCast(Master.FindControl("txtMASTERTABLENAME"), TextBox)
        txtDETAILSTABLENAME = DirectCast(Master.FindControl("txtDETAILSTABLENAME"), TextBox)
        txtSyncActualTable = DirectCast(Master.FindControl("txtSYNCACTUALTABLE"), TextBox)
        txtButtonTag = DirectCast(Master.FindControl("txtButtonTag"), TextBox)
        txtMENUTAG1 = DirectCast(Master.FindControl("txtMENUTAG1"), TextBox)
        txtMENUTAG2 = DirectCast(Master.FindControl("txtMENUTAG2"), TextBox)

        If Not ddOperationType Is Nothing Then
            Dim strVal As String
            'strVal = IIf(ddOperationType.SelectedValue = "ADD", "A", IIf(ddOperationType.SelectedValue = "EDIT", "M", IIf(ddOperationType.SelectedValue = "DELETE", "D", "")))
            strVal = IIf(ddOperationType.SelectedValue = "ADD", "M", IIf(ddOperationType.SelectedValue = "EDIT", "M", IIf(ddOperationType.SelectedValue = "DELETE", "D", "")))
            txtOPTMODE.Text = strVal
        End If
        '-- END   -- FOLLOWINGS ARE MANDATORY FOR MASTER PAGE
        txtSyncActualTable.Text = "true"

        If HttpContext.Current.Session("COMPANYCODE") Is Nothing Then
            strMessage.Text = "Session has Expired !!!!"
        End If
        If (Not System.IO.Directory.Exists(Server.MapPath("~") & "\EXPORTMASTER")) Then
            System.IO.Directory.CreateDirectory(Server.MapPath("~") & "\EXPORTMASTER")
        End If
    End Sub

    Private Sub pgPFStaffDataUpload_LoadComplete(sender As Object, e As EventArgs) Handles Me.LoadComplete
        Dim ddOperationType As DropDownList = DirectCast(Master.FindControl("ddChooseOperation"), DropDownList)
        txtCOMPCODE.Text = HttpContext.Current.Session("COMPANYCODE")
        txtGARDENCODE.Text = HttpContext.Current.Session("GARDENCODE")
        txtUSRNAME.Text = HttpContext.Current.Session("USERNAME")
        txtYEARCODE1.Text = HttpContext.Current.Session("YEARCODE")
        btnSubmit = DirectCast(Master.FindControl("btnSubmit"), Button)
        strMenutag = DirectCast(Master.FindControl("txtMENUTAG"), TextBox)
        txtMENUTAG1 = DirectCast(Master.FindControl("txtMENUTAG1"), TextBox)
        txtMENUTAG2 = DirectCast(Master.FindControl("txtMENUTAG2"), TextBox)

        If Len(strMenutag.Text) > 0 Then
            HttpContext.Current.Session("MENUTAG") = strMenutag.Text
        End If
        strExportFiles.Text = HttpContext.Current.Session("EXPORTFILES")
        txtMENUTAG.Text = HttpContext.Current.Session("MENUTAG")
        lblHeader.Text = HttpContext.Current.Session("MENUTAG")
        If Not ddOperationType Is Nothing Then
            Dim strVal As String
            strVal = IIf(ddOperationType.SelectedValue = "ADD", "A", IIf(ddOperationType.SelectedValue = "EDIT", "M", IIf(ddOperationType.SelectedValue = "DELETE", "D", "")))
            txtOPTMODE.Text = strVal
        End If
        'If Len(Trim(txtGRIDIMPORTEXPORT.Text)) <= 4 Then
        '    If (Not ClientScript.IsStartupScriptRegistered("FetchImpExpGridData1")) Then
        '        Page.ClientScript.RegisterStartupScript(Me.GetType(), "FetchImpExpGridData1", "FetchGridData();", True)
        '    End If
        'End If
        'If txtButtonTag.Text = "Submit" And Len(Trim(txtGRIDIMPORTEXPORT.Text)) > 4 Then            '
        '    If (Not ClientScript.IsStartupScriptRegistered("rePopulateGrid12")) Then
        '        Page.ClientScript.RegisterStartupScript(Me.GetType(), "rePopulateGrid12", "FetchGridData();", True)
        '    End If
        'End If
        If txtButtonTag.Text = "Submit" And Len(Trim(txtGRIDDATA.Text)) > 4 Then            '
            If (Not ClientScript.IsStartupScriptRegistered("rePopulateGrid12")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "rePopulateGrid12", "rePopulateGrid();", True)
            End If
        End If
        ''mskFROMDATE.Focus()


        If (IsPostBack = False) Then
            Load_YearMonth()
        End If

    End Sub

    Public Sub GetData(gridData As String, strNotNullableColumnName As String)
        Dim DG As New pgPFStaffDataUpload()
        Dim DTable As DataTable = DG.ConvertJSONToDataTable(gridData, strNotNullableColumnName)
        Dim sender As New Object
        Dim e As New System.EventArgs
        dtTmp = DG.ConvertJSONToDataTable(gridData, strNotNullableColumnName)
        dtTmp.TableName = "Table1"
    End Sub

    Private Function ConvertJSONToDataTable(jsonString As String, strNotNullableColumnName As String) As DataTable
        Dim dt As New DataTable()
        Dim strSplitChar As String = Chr(213)
        Dim jsonParts As String() = Regex.Split(jsonString.Replace("[", "").Replace("]", "").Replace("," + Chr(34), strSplitChar + Chr(34)), "},{")
        Dim dtColumns As New List(Of String)()
        Dim intColCounter As Integer = 0
        For Each jp As String In jsonParts
            Dim propData As String() = Regex.Split(jp.Replace("{", "").Replace("}", ""), strSplitChar)
            For Each rowData As String In propData

                Try
                    Dim idx As Integer = rowData.IndexOf(":")
                    Dim n As String = rowData.Substring(0, idx - 1)
                    Dim v As String = rowData.Substring(idx + 1)
                    If Not dtColumns.Contains(n) Then
                        dtColumns.Add(n.Replace("""", ""))
                    End If
                Catch ex As Exception
                    Throw New Exception(String.Format("Error Parsing Column Name : {0}", rowData))
                End Try
            Next
            ' TO DO: might not be correct. Was : Exit For
            Exit For
        Next

        For Each c As String In dtColumns
            dt.Columns.Add(c)
        Next
        For Each jp As String In jsonParts
            Dim propData As String() = Regex.Split(jp.Replace("{", "").Replace("}", ""), strSplitChar)
            Dim nr As DataRow = dt.NewRow()
            Dim blnDataFound As Boolean = True
            For Each rowData As String In propData
                Try
                    Dim idx As Integer = rowData.IndexOf(":")
                    Dim n As String = rowData.Substring(0, idx - 1).Replace("""", "")
                    Dim v As String = rowData.Substring(idx + 1).Replace("""", "").Replace("\n\r", vbCr).Replace("\n", vbCr).Replace("\r", vbCr).Replace("\", Chr(34)).Replace("\\", "\").Replace(Chr(34) + Chr(34), "\")
                    nr(n) = v
                    If n.ToUpper = strNotNullableColumnName.ToUpper Then
                        If Trim(v.ToUpper) = "NULL" Or Trim(v.ToLower) = "null" Or Len(Trim(v.ToLower)) = 0 Then
                            blnDataFound = False
                        End If
                    End If
                Catch ex As Exception
                    blnDataFound = False
                End Try
            Next
            If blnDataFound Then
                dt.Rows.Add(nr)
            End If
        Next
        Return dt
    End Function

    Public Function ConvertDatatableToXML(ByVal dt As DataTable) As String
        If Not IsNothing(dt) And dt.Rows.Count = 0 Then
            Return ""
            Exit Function
        End If
        Dim str As New MemoryStream()
        dt.WriteXml(str, True)
        str.Seek(0, SeekOrigin.Begin)
        Dim sr As New StreamReader(str)
        Dim xmlstr As String
        xmlstr = Replace(Replace(Replace(Replace(Replace(sr.ReadToEnd(), "<Table1>", "<data>"), "</Table1>", "</data>"), "<DocumentElement>", "<root>"), "</DocumentElement>", "</root>"), "<Table1 />", "")
        Return (xmlstr)
    End Function

    Private Function GetDataTableJson(DTable As DataTable) As String
        Dim serializer As New System.Web.Script.Serialization.JavaScriptSerializer()
        Dim rows As New List(Of Dictionary(Of String, Object))()
        Dim row As Dictionary(Of String, Object) = Nothing
        For Each dr As DataRow In DTable.Rows
            row = New Dictionary(Of String, Object)()
            For Each col As DataColumn In DTable.Columns
                row.Add(col.ColumnName.Trim(), dr(col))
            Next
            rows.Add(row)
        Next
        serializer.MaxJsonLength = Int32.MaxValue
        Return serializer.Serialize(rows)
    End Function

    Private Sub btnUPLOAD_Click(sender As Object, e As EventArgs) Handles btnUPLOAD.Click
        Dim txtFilePath As String
        Dim strAppPath As String
        Dim strFileName As String
        Dim strImpQry As String = ""
        Dim strSQL As String = ""
        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim dtGridData As New DataTable

        If FileUpload1.PostedFile.FileName = String.Empty Then
            lblMsg.Visible = True
            lblMsg.Text = "No file selected."
            lblMsg.ForeColor = Drawing.Color.Red
            Return
        Else
            'save the file 
            'restrict user to upload other file extenstion
            Dim FileExt As String() = FileUpload1.FileName.Split(".")
            Dim FileEx As String = FileExt(FileExt.Length - 1)
            If FileEx.ToLower() = "xls" Or FileEx.ToLower() = "xlsx" Then
                strAppPath = Server.MapPath("~/STAFFPFUPLOAD/")
                If Not Directory.Exists(strAppPath) Then
                    Directory.CreateDirectory(strAppPath)
                End If
                txtFilePath = strAppPath + Path.GetFileName(FileUpload1.PostedFile.FileName)
                FileUpload1.SaveAs(txtFilePath)
                txtEXCELFilename.Text = Path.GetFileName(FileUpload1.PostedFile.FileName)
                txtFILE_NAME_WITH_PATH.Text = txtFilePath
                lblMsg.Visible = True
                lblMsg.Text = "File Uploaded..Ready for Import!"
                lblMsg.ForeColor = Drawing.Color.Blue

                'Try
                '    DBManager.Open()
                '    strImpQry = Replace(Replace(Trim(txtMENUTAG1.Text), "<<DIVISIONCODE>>", "'" & HttpContext.Current.Session("DIVISIONCODE") & "'"), "<<COMPANYCODE>>", "'" & HttpContext.Current.Session("COMPANYCODE") & "'")
                '    DBManager.ExecuteScalar(CommandType.StoredProcedure, "prc_create_dynamic_view('" & HttpContext.Current.Session("COMPANYCODE") & "','','" & Replace(strImpQry, "'", "''") & "','') ")

                '    strSQL = "SELECT COLUMN_NAME, COLUMN_HEADER, COLUMN_LENGTH, COLUMN_DATA FROM VW_AUTO_DYNAMICGRID "
                '    strSQL = strSQL & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "' "

                '    dtGridData = DBManager.ExecuteDataTable(CommandType.Text, strSQL)
                '    If Not IsNothing(dtGridData) And dtGridData.Rows.Count > 0 Then
                '        txtCOLUMN.Text = dtGridData.Rows(0).Item("COLUMN_NAME")
                '        txtHEADER.Text = Replace(dtGridData.Rows(0).Item("COLUMN_HEADER") & "", "$", "'")
                '        txtLENGTH.Text = dtGridData.Rows(0).Item("COLUMN_LENGTH")
                '        txtFIELD.Text = Replace(Replace(dtGridData.Rows(0).Item("COLUMN_DATA") & "", "$", "'"), "nedit", "renderer: noneditablecolor")
                '    End If
                'Catch ex As Exception
                'Finally
                '    DBManager.Close()
                '    DBManager.Dispose()
                '    DBManager = Nothing
                'End Try

                If (Not ClientScript.IsStartupScriptRegistered("FetchImpExpGridData1")) Then
                    Page.ClientScript.RegisterStartupScript(Me.GetType(), "FetchImpExpGridData1", "FetchGridData();", True)
                End If
            Else
                lblMsg.Visible = True
                lblMsg.Text = "Invalid file format selected."
                lblMsg.ForeColor = Drawing.Color.Red
                Return
            End If
        End If
    End Sub

    Public Shared Function ImportExceltoDatatable(filepath As String) As DataTable
        ' string sqlquery= "Select * From [SheetName$] Where YourCondition";
        Dim dt As New DataTable
        Dim ds As New DataSet()
        Dim constring As String = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" & filepath & ";Extended Properties=""Excel 12.0;HDR=YES;"""
        'Dim constring As String = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & filepath & ";Extended Properties=""Excel 8.0;HDR=YES;"""
        Dim con As New OleDbConnection(constring)
        Try
            con.Open()
            Dim myTableName = con.GetSchema("Tables").Rows(0)("TABLE_NAME")
            Dim sqlquery As String = String.Format("SELECT * FROM [{0}]", myTableName) ' "Select * From " & myTableName  
            Dim da As New OleDbDataAdapter(sqlquery, con)
            da.Fill(ds)
            dt = ds.Tables(0)
            Return dt
        Catch ex As Exception
            MsgBox(Err.Description, MsgBoxStyle.Critical)
            con.Close()
            Return dt
        Finally
            con.Close()
        End Try
    End Function

    <WebMethod> _
    Public Shared Function GetGridData(strSOURCE_QUERY As String, strFILE_NAME_WITH_PATH As String, stroperationmode As String) As String ', sysDeviceID As String, strAttenDate As String) As String
        Dim dd As New pgPFStaffDataUpload()
        Dim str As String = dd.GetDataTableJson(dd.GridDataFetch(strSOURCE_QUERY, strFILE_NAME_WITH_PATH, stroperationmode)) ', sysDeviceID, strAttenDate))
        Return str
    End Function

    Protected Function GridDataFetch(strSOURCE_QUERY As String, strFILE_NAME_WITH_PATH As String, stroperationmode As String) As DataTable ', sysDeviceID As String, strAttenDate As String) As DataTable
        Dim dtGridData As New DataTable
        Dim strSQL As String = ""
        Dim StrHeader As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager

        Try
            dtGridData = ImportExceltoDatatable(strFILE_NAME_WITH_PATH)
            dtGridData = UpdateData(dtGridData)
        Catch ex As Exception
            strMessage.Text = "Error occured while fetching details.." & vbCrLf & ex.Message.ToString
        End Try
        Return dtGridData
    End Function

    Sub DeleteFilesFromFolder(Folder As String)
        If Directory.Exists(Folder) Then
            For Each _file As String In Directory.GetFiles(Folder)
                File.Delete(_file)
            Next
            For Each _folder As String In Directory.GetDirectories(Folder)
                DeleteFilesFromFolder(_folder)
            Next
        End If
    End Sub

    Public Function ValidatePage() As Boolean
        Dim strSQL As String = ""
        Dim strWORKERSERIAL As String = ""
     
        Dim DAYWISECOUNT As Integer
        Dim dtATTNDAYWISECHECK As New DataTable
        'Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager

        'Dim blnReturnValidate As Boolean = False
        Dim blnReturnValidate As Boolean = True

        If Len(Trim(txtGRIDDATA.Text)) > 0 Then
            GetData(txtGRIDDATA.Text, "WORKERSERIAL")
        Else
            strMessage.Text = "Error: Please Fill the Sorted data first. <br />"
            blnReturnValidate = False
            Return blnReturnValidate
        End If
       
        If ddlYEARMONTH.Text = "--- Select ---" Then
            strMessage.Text = "Error: Please Choose an Option. <br />"
            blnReturnValidate = False
            Return blnReturnValidate
        End If


        'DBManager.Open()
      

        dtTmp.Columns.Add("COMPANYCODE")
        dtTmp.Columns.Add("DIVISIONCODE")
        'dtTmp.Columns.Add("WORKERSERIAL")
        dtTmp.Columns.Add("YEARMONTH")
        dtTmp.Columns.Add("YEARCODE")
        dtTmp.Columns.Add("USERNAME")
        dtTmp.Columns.Add("OPERATIONMODE")
        'dtTmp.Columns.Add("UPDATESTATUS")
        'dtTmp.Columns.Add("REMARKS")
        dtTmp.Columns.Add("MODULE")


        For intRows = 0 To dtTmp.Rows.Count - 1

            'If dtTmp.Rows(intRows).Item("TOKENNO") = "" Then
            '    strMessage.Text = "Error : Can not save data due to Enormous data"
            '    blnReturnValidate = False
            '    Return blnReturnValidate
            'End If

            strSQL = ""
            dtTmp.Rows(intRows).Item("COMPANYCODE") = HttpContext.Current.Session("COMPANYCODE")
            dtTmp.Rows(intRows).Item("DIVISIONCODE") = HttpContext.Current.Session("DIVISIONCODE")
            dtTmp.Rows(intRows).Item("YEARCODE") = HttpContext.Current.Session("YEARCODE")
            dtTmp.Rows(intRows).Item("YEARMONTH") = ddlYEARMONTH.Text
           
            dtTmp.Rows(intRows).Item("USERNAME") = HttpContext.Current.Session("USERNAME")
            dtTmp.Rows(intRows).Item("OPERATIONMODE") = "A"
            dtTmp.Rows(intRows).Item("MODULE") = "PIS"
        Next

        'txtGRIDIMPORTEXPORT.Text = GetDataTableJson(dtTmp)
        'If (Not ClientScript.IsStartupScriptRegistered("rePopulateGrid1") And Len(Trim(txtGRIDIMPORTEXPORT.Text)) > 4) Then
        '    Page.ClientScript.RegisterStartupScript(Me.GetType(), "rePopulateGrid1", "rePopulateGrid();", True)
        'End If

        If Not IsNothing(dtTmp) Then
            txtDETAILSTABLENAME.Text = "GBL_STAFFPFDATAUPLOAD~" & ConvertDatatableToXML(dtTmp)
        End If


        Return blnReturnValidate
    End Function

    Public Function UpdateData(dtTmp1 As DataTable) As DataTable
        Dim strSQL As String = ""
        Dim strWORKERSERIAL As String = ""

        Dim DAYWISECOUNT As Integer
        Dim dtATTNDAYWISECHECK As New DataTable
        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager

        'Dim blnReturnValidate As Boolean = False
        Dim blnReturnValidate As Boolean = True
        Try
            dtTmp1.Columns.Add("WORKERSERIAL")
            dtTmp1.Columns.Add("UPDATESTATUS")
            dtTmp1.Columns.Add("REMARKS")

            DBManager.Open()

            For intRows = 0 To dtTmp1.Rows.Count - 1

                strSQL = ""
                strSQL = " SELECT WORKERSERIAL FROM PFEMPLOYEEMASTER"
                strSQL = strSQL & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
                strSQL = strSQL & vbCrLf & "   AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
                strSQL = strSQL & vbCrLf & "   AND TOKENNO = '" & dtTmp1.Rows(intRows).Item("TOKENNO") & "'"
                strWORKERSERIAL = DBManager.ExecuteScalar(CommandType.Text, strSQL)

                If strWORKERSERIAL <> Nothing Then
                    dtTmp1.Rows(intRows).Item("WORKERSERIAL") = strWORKERSERIAL
                    dtTmp1.Rows(intRows).Item("UPDATESTATUS") = "YES"
                    dtTmp1.Rows(intRows).Item("REMARKS") = "FOUND"
                Else
                    dtTmp1.Rows(intRows).Item("WORKERSERIAL") = ""
                    dtTmp1.Rows(intRows).Item("UPDATESTATUS") = "NO"
                    dtTmp1.Rows(intRows).Item("REMARKS") = "NOT FOUND"
                End If
            Next

        Catch ex As Exception
        Finally
            DBManager.Close()
            DBManager.Dispose()
            DBManager = Nothing
        End Try

        Return dtTmp1
    End Function

    Public Sub Load_YearMonth()
        Dim YEARCODE As String = HttpContext.Current.Session("YEARCODE")

        Dim strSQL As String
        strSQL = ""
        strSQL = strSQL & vbCrLf & "SELECT TO_CHAR(WHICH_MONTH, 'MON-YY') MONTHNAME,TO_CHAR(WHICH_MONTH, 'YYYYMM') MONTHVAL"
        strSQL = strSQL & vbCrLf & "FROM"
        strSQL = strSQL & vbCrLf & "("
        strSQL = strSQL & vbCrLf & "    SELECT ADD_MONTHS(B.STARTDATE, ROWNUM-1) WHICH_MONTH"
        strSQL = strSQL & vbCrLf & "         FROM DBA_OBJECTS A,"
        strSQL = strSQL & vbCrLf & "         ("
        strSQL = strSQL & vbCrLf & "             SELECT DISTINCT STARTDATE, ENDDATE FROM FINANCIALYEAR WHERE YEARCODE='" & YEARCODE & "'"
        strSQL = strSQL & vbCrLf & "         ) B"
        strSQL = strSQL & vbCrLf & "         WHERE ROWNUM <= MONTHS_BETWEEN(B.ENDDATE, ADD_MONTHS(B.STARTDATE, -1))"
        strSQL = strSQL & vbCrLf & "         ORDER BY WHICH_MONTH"
        strSQL = strSQL & vbCrLf & ")"

        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager

        Try
            DBManager.Open()
            Dim DS1 As DataSet = DBManager.ExecuteDataSet(CommandType.Text, strSQL)
            ddlYEARMONTH.Items.Clear()
            ddlYEARMONTH.DataSource = DS1
            ddlYEARMONTH.DataTextField = "MONTHNAME"
            ddlYEARMONTH.DataValueField = "MONTHVAL"
            ddlYEARMONTH.DataBind()
        Catch ex As Exception
        Finally
            DBManager.Close()
            DBManager.Dispose()
            DBManager = Nothing
        End Try
    End Sub

End Class