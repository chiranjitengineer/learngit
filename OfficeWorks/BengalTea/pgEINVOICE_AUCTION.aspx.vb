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
Imports Newtonsoft.Json
Imports Newtonsoft.Json.Converters
Imports Newtonsoft.Json.Serialization
Imports swterptea.Site1
Imports System.Web.Services
Imports System.Collections.Generic
Imports System.Web.Script.Serialization
Imports System.Text.RegularExpressions
Imports System.Data.OracleClient
Imports OfficeOpenXml
Imports OfficeOpenXml.ConditionalFormatting
Imports Ionic.Zip

Public Class pgEINVOICE_AUCTION
    Inherits System.Web.UI.Page
    Dim strMessage As Label
    Dim btnSubmit As Button
    Dim strOptType As String
    Dim tempActivity As TextBox
    Dim txtMasterTableName As TextBox
    Dim txtDetailsTableName As TextBox
    Dim txtSyncActualTable As TextBox
    Dim dtTmp As New DataTable
    Dim dtDetails As New DataTable
    Dim txtButtonTag As TextBox
    Dim txtOPERATIONMODE1 As TextBox
    Dim strMenutag As TextBox
    Dim dtTmpIRN As New DataTable
    Dim btnMasterSubmit As Button

    Dim dtEinvoice As New DataTable

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim ddOperationType As DropDownList = DirectCast(Master.FindControl("ddChooseOperation"), DropDownList)
        strMessage = DirectCast(Master.FindControl("lblMasterMessage"), Label)
        tempActivity = DirectCast(Master.FindControl("txtOPERATIONMODE"), TextBox)
        txtMasterTableName = DirectCast(Master.FindControl("txtMASTERTABLENAME"), TextBox)
        txtDetailsTableName = DirectCast(Master.FindControl("txtDETAILSTABLENAME"), TextBox)
        txtSyncActualTable = DirectCast(Master.FindControl("txtSYNCACTUALTABLE"), TextBox)
        txtButtonTag = DirectCast(Master.FindControl("txtButtonTag"), TextBox)
        txtOPERATIONMODE1 = DirectCast(Master.FindControl("txtOPERATIONMODE"), TextBox)
        btnMasterSubmit = DirectCast(Master.FindControl("btnSubmit"), Button)

        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        strMenutag = DirectCast(Master.FindControl("txtMENUTAG"), TextBox)
        'If Len(strMenutag.Text) > 0 Then
        '    HttpContext.Current.Session("MENUTAG") = strMenutag.Text
        'End If
        'txtMENUTAG.Text = HttpContext.Current.Session("MENUTAG")
        txtMENUTAG.Text = strMenutag.Text

        If Not ddOperationType Is Nothing Then
            Dim strVal As String
            strVal = IIf(ddOperationType.SelectedValue = "ADD", "A", IIf(ddOperationType.SelectedValue = "EDIT", "M", IIf(ddOperationType.SelectedValue = "DELETE", "D", "")))
            txtOPTMODE.Text = strVal
        End If

    End Sub


    Private Sub pgEINVOICE_AUCTION_LoadComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.LoadComplete
        Dim ddOperationType As DropDownList = DirectCast(Master.FindControl("ddChooseOperation"), DropDownList)
        txtCOMPCODE.Text = HttpContext.Current.Session("COMPANYCODE")
        txtDIVCODE.Text = HttpContext.Current.Session("DIVISIONCODE")
        txtUSRNAME.Text = HttpContext.Current.Session("USERNAME")
        txtYEARCODE1.Text = HttpContext.Current.Session("YEARCODE")
        txtSEASONCODE1.Text = HttpContext.Current.Session("SEASONCODE")
        strMenutag = DirectCast(Master.FindControl("txtMENUTAG"), TextBox)
        txtButtonTag = DirectCast(Master.FindControl("txtButtonTag"), TextBox)
        btnSubmit = DirectCast(Master.FindControl("btnSubmit"), Button)
        btnSubmit.Enabled = False
        btnSubmit.Visible = False
        'If Len(strMenutag.Text) > 0 Then
        '    HttpContext.Current.Session("MENUTAG") = strMenutag.Text
        'End If

        'txtMENUTAG.Text = HttpContext.Current.Session("MENUTAG")


        txtMENUTAG.Text = strMenutag.Text

        If (txtMENUTAG.Text <> "") Then
            If txtMENUTAG.Text = "REQUEST" Then
                lblHeader.Text = "REQUEST FOR IRN GENERATE"
            Else
                lblHeader.Text = "IRN BILL UPDATE FOR AUCTION"
            End If
        End If

        If Not ddOperationType Is Nothing Then
            Dim strVal As String
            strVal = IIf(ddOperationType.SelectedValue = "ADD", "A", IIf(ddOperationType.SelectedValue = "EDIT", "M", IIf(ddOperationType.SelectedValue = "DELETE", "D", "")))
            txtOPTMODE.Text = strVal
        End If

        'mskDOCUMENTTDATEFROM.Text = Date.Now()
        'mskDOCUMENTTDATETO.Text = Date.Now()

        Dim drTemp As IDataReader
        Dim strSql As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Try
            dbManager.Open()
            txtGSTIN.Text = dbManager.ExecuteScalar(CommandType.Text, "SELECT GSTNNO FROM DIVISIONMASTER WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "' AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'")
            If Len(Trim(mskDOCUMENTTDATEFROM.Text)) = 0 Then
                mskDOCUMENTTDATEFROM.Text = dbManager.ExecuteScalar(CommandType.Text, "SELECT TO_CHAR(SYSDATE, 'DD/MM/YYYY') FROM DUAL")
                mskDOCUMENTTDATETO.Text = dbManager.ExecuteScalar(CommandType.Text, "SELECT TO_CHAR(SYSDATE, 'DD/MM/YYYY') FROM DUAL")
            End If
            If ddlCHANNEL.Items.Count = 0 Then

                ''--------DOCUMENT TYPE------
                ddlCHANNEL.Items.Clear()
                strSql = ""
                strSql = strSql & vbCrLf & " SELECT CHANNELCODE     "
                strSql = strSql & vbCrLf & "   FROM CHANNELMASTER"
                strSql = strSql & vbCrLf & "  WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
                strSql = strSql & vbCrLf & "    AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
                strSql = strSql & vbCrLf & "    AND CHANNELTAG = 'AUCTION'"
                strSql = strSql & vbCrLf & "    AND MODULE = 'SALES'"

                drTemp = dbManager.ExecuteReader(CommandType.Text, strSql)

                ddlCHANNEL.DataSource = drTemp
                ddlCHANNEL.DataTextField = "CHANNELCODE"
                ddlCHANNEL.DataValueField = "CHANNELCODE"
                ddlCHANNEL.DataBind()
                ddlCHANNEL.SelectedIndex = 0
                drTemp.Close()
                drTemp.Dispose()
                drTemp = Nothing


                ''--------STATUS------
            End If


        Catch ex As Exception
            strMessage.Text = "Error Occured while Fetching Data ..." & vbCrLf & ex.Message.ToString
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try

        If txtButtonTag.Text = "Submit" Then            '
            If (Not ClientScript.IsStartupScriptRegistered("rePopulateGrid")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "rePopulateGrid", "rePopulateGrid();", True)
            End If
        End If

    End Sub

    <WebMethod> _
    Public Shared Function GetGridData(strOperationMode As String, strChannel As String, strFromdate As String, strTodate As String, strChecked As String) As String

        Dim dd As New pgEINVOICE_AUCTION()
        Dim str As String = dd.GetDataTableJson(dd.GridDataFetch(strOperationMode, strChannel, strFromdate, strTodate, strChecked))

        Return str
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
        Return serializer.Serialize(rows)
    End Function

    Protected Function GridDataFetch(strOperationMode As String, strChannel As String, strFromdate As String, strTodate As String, strChecked As String) As DataTable
        Dim dtGridData As New DataTable
        Dim strSQL As String
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager

        Try
            dbManager.Open()
            strSQL = ""
            strSQL = strSQL & vbCrLf & " SELECT '" & strChecked & "' SELECTED, DOC_NO, /*TO_CHAR(DOC_DT, 'DD/MM/YYYY')*/ DOC_DT, BILLTO_TRDNM, BILLTO_GSTIN,"
            strSQL = strSQL & vbCrLf & "        VAL_TOTINVVAL, B.ACKNO, B.ACKDATE, A.IRN, B.SIGNEDQRCODE, B.SIGNEDINVOICE"
            'strSQL = strSQL & vbCrLf & "   FROM VW_SALEBILL_DNCN A, EINVOICE_MAIN B, SALESBILLMASTER C"
            strSQL = strSQL & vbCrLf & "   FROM ( SELECT DISTINCT COMPANYCODE,DIVISIONCODE,DOC_NO,DOC_DT,BILLTO_TRDNM,BILLTO_GSTIN,VAL_TOTINVVAL,IRN  FROM VW_SALEBILL_DNCN  ) A, EINVOICE_MAIN B, SALESBILLMASTER C"
            strSQL = strSQL & vbCrLf & "  WHERE A.COMPANYCODE='" & HttpContext.Current.Session("COMPANYCODE") & "' "
            strSQL = strSQL & vbCrLf & "    AND A.DIVISIONCODE='" & HttpContext.Current.Session("DIVISIONCODE") & "'"
            strSQL = strSQL & vbCrLf & "    AND A.DOC_NO = B.DOCNO"
            strSQL = strSQL & vbCrLf & "    AND B.IRN IS NOT NULL"
            strSQL = strSQL & vbCrLf & "    AND B.ACKNO IS NOT NULL"
            strSQL = strSQL & vbCrLf & "    AND A.COMPANYCODE = C.COMPANYCODE"
            strSQL = strSQL & vbCrLf & "    AND A.DIVISIONCODE = C.DIVISIONCODE"
            strSQL = strSQL & vbCrLf & "    AND A.DOC_NO = C.SALEBILLNO"
            strSQL = strSQL & vbCrLf & "    AND C.CHANNELCODE = '" & strChannel & "'"
            strSQL = strSQL & vbCrLf & "    AND NVL(B.ZIP_FLAG,'N') = 'N'"
            strSQL = strSQL & vbCrLf & "    AND C.SALEBILLDATE >= TO_DATE('" & strFromdate & "', 'DD/MM/YYYY')"
            strSQL = strSQL & vbCrLf & "    AND C.SALEBILLDATE <= TO_DATE('" & strTodate & "', 'DD/MM/YYYY')"
            strSQL = strSQL & vbCrLf & "  ORDER BY A.DOC_NO"

            dtGridData = dbManager.ExecuteDataTable(CommandType.Text, strSQL)


        Catch ex As Exception
            strMessage.Text = "Error occured while fetching details.." & vbCrLf & ex.Message.ToString
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try

        Return dtGridData
    End Function

    Public Sub GetData(gridData As String, strNotNullableColumnName As String)
        'string data = gridData;
        Dim DG As New pgEINVOICE_AUCTION()
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
                        If Trim(v.ToUpper) = "NULL" Or Trim(v.ToLower) = "null" Or Trim(v.ToUpper) = "" Or Trim(v.ToUpper) = "N" Or Trim(v.ToUpper) = "NO" Then
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

    Public Function ValidatePage() As Boolean
        Dim blnReturnValidate As Boolean = False
        Dim strSql As String
        Dim count As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager

       
        Return blnReturnValidate
       
    End Function


    Public Sub Redirect(url As String, target As String, windowFeatures As String)
        Dim context As HttpContext = HttpContext.Current
        Dim intItem As Integer = 0

        If ([String].IsNullOrEmpty(target) OrElse target.Equals("_self", StringComparison.OrdinalIgnoreCase)) AndAlso [String].IsNullOrEmpty(windowFeatures) Then

            context.Response.Redirect(url)
        Else
            Dim page As Page = DirectCast(context.Handler, Page)
            If page Is Nothing Then
                Throw New InvalidOperationException("Cannot redirect to new window outside Page context.")
            End If
            url = page.ResolveClientUrl(url)

            Dim script As String
            If Not [String].IsNullOrEmpty(windowFeatures) Then
                script = "window.open(""{0}"", ""{1}"", ""{2}"");"
            Else
                script = "window.open(""{0}"", ""{1}"");"
            End If

            script = [String].Format(script, url, target, windowFeatures)
            If (Not page.ClientScript.IsStartupScriptRegistered("OpenWindows")) Then
                ScriptManager.RegisterStartupScript(page, GetType(Page), "Redirect" & intItem, script, True)
            End If
        End If
    End Sub

    Private Sub btnDOWNLOAD_Click(sender As Object, e As EventArgs) Handles btnDOWNLOAD.Click
        Dim strMsg = ""
        Dim kStr = ""

        Try
            If Len(Trim(txtGRIDDATA.Text)) > 4 Then
                dtTmp = ConvertJSONToDataTable(txtGRIDDATA.Text, "SELECTED")
                dtTmp.TableName = "Table1"
                If dtTmp.Rows.Count > 0 Then
                    Dim RES = IRN_ZIP_JSONEXCEL.WriteJSONFile(dtTmp)

                    If IRN_ZIP_JSONEXCEL.DocNos <> "" Then
                        kStr = "UPDATE EINVOICE_MAIN SET ZIP_FLAG='Y' WHERE DOCNO IN (" & IRN_ZIP_JSONEXCEL.DocNos & ")"
                        GeneralFunctions.ExecuteCommand(kStr)
                    End If
                    Response.ContentType = "application/zip"
                    'Response.ContentType = "text/plain"
                    Response.AppendHeader("Content-Disposition", "attachment; filename=" & Path.GetFileName(RES) & "")
                    Response.TransmitFile(RES)
                    Response.End()
                Else
                    strMsg = "No Selected Data Found!!!"

                End If
            Else
                strMsg = "No Data Found!!!"
            End If
        Catch ex As Exception
            strMsg = ex.Message
        End Try

        If strMsg <> "" Then
            If (Not ClientScript.IsStartupScriptRegistered("rePopulateGrid")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "rePopulateGrid", "rePopulateGrid();", True)
            End If
            If (Not ClientScript.IsStartupScriptRegistered("showMsg")) Then
                'Page.ClientScript.RegisterStartupScript(Me.GetType(), "showMsg", "<script>alert('" & strMsg & "');</script>", True)
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "showMsg", "alert('" & strMsg & "');", True)
            End If
        End If
    End Sub
End Class

Public Class IRN_ZIP_JSONEXCEL
    Public Shared DocNos As String

    Public Shared Function WriteJSONFile(dtTbl As DataTable) As String
        Dim dir = HttpContext.Current.Server.MapPath("~")
        dir = Path.Combine(dir, "IRN_ZIP_JSONEXCEL")
        If Directory.Exists(dir) = False Then
            Directory.CreateDirectory(dir)
        End If

        dir = Path.Combine(dir, "IRNUPLOAD" & DateTime.Now.ToString("yyyyMMddHHmmss"))
        If Directory.Exists(dir) = False Then
            Directory.CreateDirectory(dir)
        End If


        'Dim dtTbl = GeneralFunctions.ConvertJSONToDataTable(str, "SELECTED")
        Dim jsonFile = Path.Combine(dir, "123456789.json")

        DocNos = ""


        Dim lstData As New List(Of IRN_DATA)

        For index = 0 To dtTbl.Rows.Count - 1
            Dim irn As New IRN_DATA()

            If DocNos = "" Then
                DocNos = DocNos & "'" & dtTbl.Rows(index).Item("DOC_NO").ToString() & "'"
            Else
                DocNos = DocNos & ",'" & dtTbl.Rows(index).Item("DOC_NO").ToString() & "'"

            End If



            irn.AckNo = dtTbl.Rows(index).Item("ACKNO").ToString()
            irn.AckDt = dtTbl.Rows(index).Item("ACKDATE").ToString()
            irn.Irn = dtTbl.Rows(index).Item("IRN").ToString()
            irn.SignedInvoice = dtTbl.Rows(index).Item("SIGNEDINVOICE").ToString()
            irn.SignedQRCode = dtTbl.Rows(index).Item("SIGNEDQRCODE").ToString()
            'irn.Status = dtTbl.Rows(index).Item("Status").ToString()
            'irn.EwbNo = dtTbl.Rows(index).Item("EwbNo").ToString()
            'irn.EwbDt = dtTbl.Rows(index).Item("EwbDt").ToString()
            'irn.EwbValidTill = dtTbl.Rows(index).Item("EwbValidTill").ToString()
            'irn.Remarks = dtTbl.Rows(index).Item("Remarks").ToString()

            jsonFile = Path.Combine(dir, irn.AckNo & ".json")
            'jsonFile = Path.Combine(dir, dtTbl.Rows(index).Item("BILLTO_GSTIN") & ".json")
            File.WriteAllText(jsonFile, irn.ToString())
        Next
        DocNos = DocNos

        Create_ExcelFile(dir, dtTbl)
        Return MakeZipFile(dir)
    End Function
    Public Shared Function Create_ExcelFile(dir As String, dtTbl As DataTable) As Boolean
        Dim excelFile = Path.Combine(dir, "UploadedInvoiceDetails.xlsx")

        Dim newFile = New FileInfo(excelFile)
        Dim package = New ExcelPackage(newFile)

        Dim worksheet = package.Workbook.Worksheets.Add("Sheet1")

        Dim rowIndex = 1


        Dim cellRow = 0
        'Sl. No	Invoice No	Invoice Date	Buyer GSTIN	Invoice Value	Ack No	Ack Date	IRN	EWB No./ If Any Errors While Creating EWB.
        cellRow = cellRow + 1
        worksheet.Cells(rowIndex, cellRow).Value = "Sl. No"
        cellRow = cellRow + 1
        worksheet.Cells(rowIndex, cellRow).Value = "Invoice No"
        cellRow = cellRow + 1
        worksheet.Cells(rowIndex, cellRow).Value = "Invoice Date"
        cellRow = cellRow + 1
        worksheet.Cells(rowIndex, cellRow).Value = "Buyer GSTIN"
        cellRow = cellRow + 1
        worksheet.Cells(rowIndex, cellRow).Value = "Invoice Value"
        cellRow = cellRow + 1
        worksheet.Cells(rowIndex, cellRow).Value = "Ack No"
        cellRow = cellRow + 1
        worksheet.Cells(rowIndex, cellRow).Value = "Ack Date"
        cellRow = cellRow + 1
        worksheet.Cells(rowIndex, cellRow).Value = "IRN"
        cellRow = cellRow + 1
        worksheet.Cells(rowIndex, cellRow).Value = "EWB No./ If Any Errors While Creating EWB."

        worksheet.Cells(1, 1, rowIndex, cellRow).Style.Font.Bold = True


        '      "SELECTED": "NO",
        '"DOC_NO": "ANTEA/2021/00157",
        '"DOC_DT": "02/10/2020",
        '"BILLTO_TRDNM": "RAJ TEA COMPANY",
        '"BILLTO_GSTIN": "08AACFR0054P1Z0",
        '"VAL_TOTINVVAL": 527990,
        '"ACKNO": null,
        '"ACKDATE": null,
        '"IRN": "bddb4608ec76

        Try
            'Sl. No	Invoice No	Invoice Date	Buyer GSTIN	Invoice Value	Ack No	Ack Date	IRN	EWB No./ If Any Errors While Creating EWB.
            For index = 0 To dtTbl.Rows.Count - 1

                cellRow = 0
                rowIndex = rowIndex + 1
                cellRow = cellRow + 1
                worksheet.Cells(rowIndex, cellRow).Value = (index + 1) 'Sl. No
                cellRow = cellRow + 1
                worksheet.Cells(rowIndex, cellRow).Value = dtTbl.Rows(index).Item("DOC_NO") 'Invoice No
                cellRow = cellRow + 1
                worksheet.Cells(rowIndex, cellRow).Value = dtTbl.Rows(index).Item("DOC_DT") 'Invoice Date
                cellRow = cellRow + 1
                worksheet.Cells(rowIndex, cellRow).Value = dtTbl.Rows(index).Item("BILLTO_GSTIN") 'Buyer GSTIN
                cellRow = cellRow + 1
                worksheet.Cells(rowIndex, cellRow).Value = CDbl(dtTbl.Rows(index).Item("VAL_TOTINVVAL")) '"Invoice Value"
                cellRow = cellRow + 1
                worksheet.Cells(rowIndex, cellRow).Value = dtTbl.Rows(index).Item("ACKNO") ' "Ack No"
                cellRow = cellRow + 1
                worksheet.Cells(rowIndex, cellRow).Value = dtTbl.Rows(index).Item("ACKDATE") '"Ack Date"
                cellRow = cellRow + 1
                worksheet.Cells(rowIndex, cellRow).Value = dtTbl.Rows(index).Item("IRN") ' "IRN"
                'cellRow = cellRow + 1
                'worksheet.Cells(rowIndex, cellRow).Value = "EWB No./ If Any Errors While Creating EWB."

            Next
        Catch ex As Exception

        End Try
        package.Save()
    End Function

    Public Shared Function MakeZipFile(dir As String) As String


        HttpContext.Current.Response.Clear()
        HttpContext.Current.Response.BufferOutput = False '; // for large files...
        Dim c = System.Web.HttpContext.Current
        Dim ReadmeText = "This is a README..." & DateTime.Now.ToString("G")
        'Dim archiveName = String.Format("IRNUploadFormat-{0}.zip", DateTime.Now.ToString("yyyy-MMM-dd-HHmmss"))
        Dim archiveName = String.Format("IRN{0}{1}-{2}.zip", c.Session("COMPANYCODE"), c.Session("YEARCODE"), DateTime.Now.ToString("yyyy-MMM-dd-HHmmss"))
        'HttpContext.Current.Response.ContentType = "application/zip"
        'HttpContext.Current.Response.AddHeader("content-disposition", "filename=" & archiveName)

        Dim zip As New ZipFile()
        zip.TempFileFolder = dir
        Dim all_file = Directory.GetFiles(dir)
        For Each STR As String In all_file
            zip.AddFile(Path.GetFileName(STR))
        Next
        'zip.AddFiles(all_file, "files")
        'zip.AddFiles(all_file)
        'zip.AddFile(all_file(0))
        'zip.AddFile(all_file(1))
        'zip.AddItem(all_file(0), Path.GetFileName(dir))
        'zip.AddItem(all_file(0), Path.GetFileName(dir))
        'zip.AddItem(all_file(0), "FILES")

        'zip.AddEntry("Readme.txt", ReadmeText)

        'zip.Save(HttpContext.Current.Response.OutputStream)
        zip.Save(Path.Combine(dir, archiveName))

        For Each Str As String In all_file
            Try
                If Path.GetExtension(Str.ToUpper()) <> ".ZIP" Then
                    File.Delete(Str)
                End If
            Catch ex As Exception

            End Try
        Next
        'using (ZipFile zip = new ZipFile())
        '{
        '    // filesToInclude is an IEnumerable<String>, like String[] or List<String>
        '    zip.AddFiles(filesToInclude, "files");            

        '    // Add a file from a string
        '    zip.AddEntry("Readme.txt", "", ReadmeText);
        '    zip.Save(Response.OutputStream);
        '}
        '// Response.End();  // no! See http://stackoverflow.com/questions/1087777
        'HttpContext.Current.Response.Close()
        Return Path.Combine(dir, archiveName)
    End Function
End Class
Public Class IRN_DATA
    Public AckNo As String
    Public AckDt As String
    Public Irn As String
    Public SignedInvoice As String
    Public SignedQRCode As String
    Public Status As String
    Public EwbNo As String
    Public EwbDt As String
    Public EwbValidTill As String
    Public Remarks As String

    Public Overrides Function ToString() As String
        Dim serializer As New System.Web.Script.Serialization.JavaScriptSerializer()
        Dim rows As New List(Of Dictionary(Of String, Object))()
        Dim row As Dictionary(Of String, Object) = Nothing
        row = New Dictionary(Of String, Object)()
        row.Add("AckNo", AckNo)
        row.Add("AckDt", AckDt)
        row.Add("Irn", Irn)
        row.Add("SignedInvoice", SignedInvoice)
        row.Add("SignedQRCode", SignedQRCode)
        row.Add("Status", Status)
        row.Add("EwbNo", EwbNo)
        row.Add("EwbDt", EwbDt)
        row.Add("EwbValidTill", EwbValidTill)
        row.Add("Remarks", Remarks)
        rows.Add(row)
        Return serializer.Serialize(row)
        'Return serializer.Serialize(rows)
    End Function
End Class