Imports SW_DBObject
Imports System.Web
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

Public Class pgSalesOtherBillWOChallan_GST
    Inherits System.Web.UI.Page
    Dim strMessage As Label
    Dim btnSubmit As Button
    Dim strOptType As String
    Dim ddOperationType As DropDownList
    Dim txtMasterTableName As TextBox
    Dim txtSyncActualTable As TextBox
    Dim txtUserName As TextBox
    Dim txtButtonTag As TextBox
    ' for grid control
    Dim txtDETAILSTABLENAME As TextBox
    Dim txtOPERATIONMODE As TextBox
    Dim blnExit As Boolean = True
    Dim dtTmp As New DataTable
    Dim dtCharge As New DataTable
    Dim dtForm As New DataTable
    Dim dtIndent As New DataTable
    Dim blnHideDefHeader As Boolean = False
    Dim btnMasterSubmit As Button

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '-- START -- FOLLOWINGS ARE MANDATORY FOR MASTER PAGE
        ddOperationType = DirectCast(Master.FindControl("ddChooseOperation"), DropDownList)
        strMessage = DirectCast(Master.FindControl("lblMasterMessage"), Label)
        txtMasterTableName = DirectCast(Master.FindControl("txtMASTERTABLENAME"), TextBox)
        txtDETAILSTABLENAME = DirectCast(Master.FindControl("txtDETAILSTABLENAME"), TextBox)
        txtSyncActualTable = DirectCast(Master.FindControl("txtSYNCACTUALTABLE"), TextBox)
        txtUserName = DirectCast(Master.FindControl("txtUSERNAME"), TextBox)
        txtButtonTag = DirectCast(Master.FindControl("txtButtonTag"), TextBox)
        btnMasterSubmit = DirectCast(Master.FindControl("btnSubmit"), Button)

        txtMasterTableName.Text = "GBL_SALESOTHERBILLMASTER"
        txtSyncActualTable.Text = "true"

        '------------ FOR GRID
        If Not ddOperationType Is Nothing Then
            Dim strVal As String
            strVal = IIf(ddOperationType.SelectedValue = "ADD", "A", IIf(ddOperationType.SelectedValue = "EDIT", "M", IIf(ddOperationType.SelectedValue = "DELETE", "D", "")))
            txtOPTMODE.Text = strVal
        End If
        If HttpContext.Current.Session("COMPANYCODE") Is Nothing Then
            strMessage.Text = "Session has Expired !!!!"
        End If

        If Not IsPostBack Then
            If (Not ClientScript.IsStartupScriptRegistered("fetchgrid1")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgrid1", "FetchGridData();", True)
            End If
            If (Not ClientScript.IsStartupScriptRegistered("fetchgridCharge")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgridCharge", "FetchChargeGridData();", True)
            End If
        Else
            If Len(Trim(txtGRIDDATA.Text)) > 4 Then
                GetData(txtGRIDDATA.Text, "RATE")
            End If
            If Len(Trim(txtCHARGEGRIDDATA.Text)) > 4 Then
                GetChargeData(txtCHARGEGRIDDATA.Text, "DOCUMENTDATE")
            End If
            If Not IsNothing(dtTmp) Then
                txtDETAILSTABLENAME.Text = "GBL_SALESOTHERBILLDETAIL~" & ConvertDatatableToXML(dtTmp)
                If Not IsNothing(dtCharge) Then
                    If dtCharge.Rows.Count > 0 Then
                        txtDETAILSTABLENAME.Text = txtDETAILSTABLENAME.Text & "#GBL_SALESCHARGEDETAILS~" & ConvertDatatableToXML(dtCharge)
                    End If
                End If
            End If
        End If
    End Sub

    Private Sub pgSalesOtherBillWOChallan_GST_LoadComplete(sender As Object, e As EventArgs) Handles Me.LoadComplete
        ddOperationType = DirectCast(Master.FindControl("ddChooseOperation"), DropDownList)
        txtCOMPCODE.Text = HttpContext.Current.Session("COMPANYCODE")
        txtDIVCODE.Text = HttpContext.Current.Session("DIVISIONCODE")
        txtUSRNAME.Text = HttpContext.Current.Session("USERNAME")
        txtPROJNAME.Text = HttpContext.Current.Session("PROJECTNAME")
        txtYRCODE.Text = HttpContext.Current.Session("YEARCODE")
        txtCHANNELCODE.Attributes.Add("readonly", "readonly")
        'txtSCRAPSALESBILLNO.Attributes.Add("readonly", "readonly")
        txtSALESBILLNO.Attributes.Add("readonly", "readonly")
        txtNETAMT.Attributes.Add("readonly", "readonly")
        txtGROSSAMT.Attributes.Add("readonly", "readonly")
        txtBILLTYPE.Text = "WITHOUT CHALLAN"

        txtADDRESSCODE.Attributes.Add("readonly", "readonly")
        txtADDRESSDESC.Attributes.Add("readonly", "readonly")
        txtADDRESSCODEBILL.Attributes.Add("readonly", "readonly")
        txtADDRESSDESCBILL.Attributes.Add("readonly", "readonly")
        txtBILLSTATECODE.Attributes.Add("readonly", "readonly")
        txtBILLSTATEDESC.Attributes.Add("readonly", "readonly")
        txtPARTYNAME.Attributes.Add("readonly", "readonly")
        If Not ddOperationType Is Nothing Then
            Dim strVal As String
            strVal = IIf(ddOperationType.SelectedValue = "ADD", "A", IIf(ddOperationType.SelectedValue = "EDIT", "M", IIf(ddOperationType.SelectedValue = "DELETE", "D", "")))
            txtOPTMODE.Text = strVal
        End If
        If Mid(strMessage.Text, 1, 9) <> "#SUCCESS#" And Len(strMessage.Text) > 0 And Len(Trim(txtDETAILSTABLENAME.Text)) > 4 Then
            If (Not Page.ClientScript.IsStartupScriptRegistered("populatedetails1")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "populatedetails", "rePopulateGrid();", True)
            End If
        End If
    End Sub

    Public Sub GetData(gridData As String, strNotNullableColumnName As String)
        'string data = gridData;
        Dim DG As New pgSalesOtherBillWOChallan_GST()
        'Dim DTable As DataTable = DG.ConvertJSONToDataTable(gridData, strNotNullableColumnName)
        Dim sender As New Object
        Dim e As New System.EventArgs
        dtTmp = DG.ConvertJSONToDataTable(gridData, strNotNullableColumnName)
        dtTmp.TableName = "Table1"
    End Sub
    Public Sub GetChargeData(gridData As String, strNotNullableColumnName As String)
        'string data = gridData;
        Dim DG As New pgSalesOtherBillWOChallan_GST()
        Dim sender As New Object
        Dim e As New System.EventArgs
        dtCharge = DG.ConvertJSONToDataTable(gridData, strNotNullableColumnName)
        dtCharge.TableName = "Table1"
    End Sub

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
        Return serializer.Serialize(rows)
    End Function

    <WebMethod> _
    Public Shared Function GetWebData(strKey As String, strKey2 As String, strParam As String) As String
        Dim dd As New pgSalesOtherBillWOChallan_GST()
        Dim str As String = dd.WebDataFetch(strKey, strKey2, strParam)
        Return str
    End Function
    <WebMethod> _
    Public Shared Function GetGridData(strchallanno As String, strbillno As String, strOperationMode As String) As String
        Dim dd As New pgSalesOtherBillWOChallan_GST()
        Dim str As String = dd.GetDataTableJson(dd.GridDataFetch(strchallanno, strbillno, strOperationMode))
        Return str
    End Function
    <WebMethod> _
    Public Shared Function GetChargeGridData(strOperationMode As String, strChannelCode As String, strSALEBILLNO As String, strdoctype As String) As String
        Dim dd As New pgSalesOtherBillWOChallan_GST()
        Dim str As String = dd.GetDataTableJson(dd.ChargeGridDataFetch(strOperationMode, strChannelCode, strSALEBILLNO, strdoctype))
        Return str
    End Function
    <WebMethod> _
    Public Shared Function GetUOMcodeDetails() As String
        Dim str As String = String.Empty
        Dim DG As New pgSalesOtherBillWOChallan_GST()
        str = DG.GetUOMListJson()
        Return str
    End Function
    <WebMethod> _
    Public Shared Function GetUOMData(strUOM As String) As String
        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim strSQL As String = ""
        Try
            DBManager.Open()
            strSQL = DBManager.ExecuteScalar(CommandType.Text, "SELECT MEASURENAME UOMNAME FROM SALESMEASUREMASTER  WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "' AND DIVISIONCODE ='" & HttpContext.Current.Session("DIVISIONCODE") & "' AND MEASURECODE= '" & strUOM & "'")

        Catch ex As Exception
        Finally
            DBManager.Close()
            DBManager.Dispose()
            DBManager = Nothing
        End Try
        Return (strSQL).ToString()
    End Function
    <WebMethod> _
    Public Shared Function fnGetACHEAD(strACCODE As String) As String
        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim strSQL As String = ""
        Try
            DBManager.Open()
            strSQL = ""
            strSQL = strSQL & vbCrLf & " SELECT DISTINCT ACHEAD FROM ACACLEDGER "
            strSQL = strSQL & vbCrLf & " WHERE ACCODE='" & strACCODE & "'"
            strSQL = DBManager.ExecuteScalar(CommandType.Text, strSQL)
        Catch ex As Exception
        Finally
            DBManager.Close()
            DBManager.Dispose()
            DBManager = Nothing
        End Try
        Return (strSQL).ToString()
    End Function
    Private Function GetUOMListJson() As String
        Dim jss As New JavaScriptSerializer()
        Dim CR As New CourseRepository()
        Dim output As String = jss.Serialize(CR.GetUOMcodeData())
        Return output
    End Function
    Public Class CourseNameModel
        Public Property CourseNameID() As Integer
            Get
                Return m_CourseNameID
            End Get
            Set(value As Integer)
                m_CourseNameID = value
            End Set
        End Property
        Private m_CourseNameID As Integer
        Public Property CourseName() As String
            Get
                Return m_CourseName
            End Get
            Set(value As String)
                m_CourseName = value
            End Set
        End Property
        Private m_CourseName As String
    End Class

    Public Class CourseModel
        Public Property CourseId() As Integer
            Get
                Return m_CourseId
            End Get
            Set(value As Integer)
                m_CourseId = value
            End Set
        End Property
        Private m_CourseId As Integer
        Public Property NameId() As Integer
            Get
                Return m_NameId
            End Get
            Set(value As Integer)
                m_NameId = value
            End Set
        End Property
        Private m_NameId As Integer
    End Class

    Public Class CourseRepository
        Dim dtTmpCol As New DataTable

        Public Function GetUOMcodeData() As System.Collections.Generic.List(Of CourseNameModel)
            Dim CourseList As New System.Collections.Generic.List(Of CourseNameModel)()
            Dim strSQL As String = ""
            CourseList.Clear()
            Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
            Try
                dtTmpCol.Rows.Clear()
                DBManager.Open()

                strSQL = "SELECT MEASURECODE UOMCODE, MEASURENAME UOMNAME FROM SALESMEASUREMASTER WHERE COMPANYCODE ='" & HttpContext.Current.Session("COMPANYCODE") & "' AND DIVISIONCODE='" & HttpContext.Current.Session("DIVISIONCODE") & "'"
                dtTmpCol = DBManager.ExecuteDataTable(CommandType.Text, strSQL)
                dtTmpCol.TableName = "Table2"
                If dtTmpCol.Rows.Count <= 0 Then
                    Dim sender As New Object
                Else
                    Dim DS1 As DataSet = DBManager.ExecuteDataSet(CommandType.Text, strSQL)
                    For intCTR As Integer = 0 To DS1.Tables(0).Rows.Count - 1
                        CourseList.Add(New CourseNameModel() With {.CourseNameID = intCTR, .CourseName = DS1.Tables(0).Rows(intCTR)("UOMCODE")})
                    Next
                End If

            Catch ex As Exception
                Throw New Exception(String.Format(ex.ToString))
            Finally
                DBManager.Close()
                DBManager.Dispose()
                DBManager = Nothing
            End Try

            Return CourseList
        End Function

    End Class
    Protected Function WebDataFetch(strKey As String, strKey2 As String, strParam As String) As String
        Dim strReturnVal As String = ""
        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim strSQL As String = ""
        'Dim strArray() As String
        If strKey.Trim.Length = 0 Then
            strReturnVal = ""
            Return strReturnVal
        End If
        Try
            DBManager.Open()

            Select Case strParam
                Case "CHANNEL"
                    'strSQL = ""
                    'strSQL = strSQL & vbCrLf & " SELECT DISTINCT CHANNELTAG"
                    'strSQL = strSQL & vbCrLf & "  FROM CHANNELMASTER"
                    'strSQL = strSQL & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
                    'strSQL = strSQL & vbCrLf & "   AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
                    'strSQL = strSQL & vbCrLf & "   AND MODULE = '" & HttpContext.Current.Session("PROJECTNAME") & "'"
                    'strSQL = strSQL & vbCrLf & "   AND CHANNELCODE = '" & strKey & "'"

                    'strReturnVal = DBManager.ExecuteScalar(CommandType.Text, strSQL)
                Case "PARTY"
                    strReturnVal = DBManager.ExecuteScalar(CommandType.Text, "SELECT PARTYNAME FROM PARTYMASTER WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "' AND PARTYTYPE ='BUYER' AND PARTYCODE='" & strKey & "' AND CHANNELLIST LIKE ('%''" & strKey2 & "''%') AND MODULE='SALES'")
                Case "ADDRESSCODE"
                    strSQL = ""
                    strSQL = strSQL & vbCrLf & "SELECT ADDRESS||'~'||GSTSTATECODE"
                    strSQL = strSQL & vbCrLf & "  FROM PARTYADDRESS"
                    strSQL = strSQL & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
                    strSQL = strSQL & vbCrLf & "   AND MODULE = '" & HttpContext.Current.Session("PROJECTNAME") & "'"
                    strSQL = strSQL & vbCrLf & "   AND PARTYTYPE = 'BUYER'"
                    strSQL = strSQL & vbCrLf & "   AND ADDRESSCODE = '" & strKey2 & "'"
                    strSQL = strSQL & vbCrLf & "   AND PARTYCODE = '" & strKey & "'"
                    strReturnVal = DBManager.ExecuteScalar(CommandType.Text, strSQL)
                Case "ADDRESSCODEBILL"
                    strSQL = ""
                    strSQL = strSQL & vbCrLf & "SELECT ADDRESS||'~'||GSTSTATECODE||'~'||STATE XX "
                    strSQL = strSQL & vbCrLf & "  FROM PARTYADDRESS"
                    strSQL = strSQL & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
                    strSQL = strSQL & vbCrLf & "   AND MODULE = '" & HttpContext.Current.Session("PROJECTNAME") & "'"
                    strSQL = strSQL & vbCrLf & "   AND PARTYTYPE = 'BUYER'"
                    strSQL = strSQL & vbCrLf & "   AND ADDRESSCODE = '" & strKey2 & "'"
                    strSQL = strSQL & vbCrLf & "   AND PARTYCODE = '" & strKey & "'"
                    strReturnVal = DBManager.ExecuteScalar(CommandType.Text, strSQL)
                Case "BILLSTATECODE"
                    strSQL = ""
                    strSQL = strSQL & vbCrLf & "SELECT STATENAME "
                    strSQL = strSQL & vbCrLf & "FROM GSTSTATEMASTER "
                    strSQL = strSQL & vbCrLf & "WHERE GSTSTATECODE='" & strKey & "' "
                    strReturnVal = DBManager.ExecuteScalar(CommandType.Text, strSQL)
            End Select

        Catch ex As Exception
            strMessage.Text = "Error occured while populating data..." & vbCrLf & ex.Message.ToString
        Finally
            DBManager.Close()
            DBManager.Dispose()
            DBManager = Nothing
        End Try
        Return strReturnVal
    End Function

    <WebMethod> _
    Public Shared Function prcChargeDetails(strChargeGridData As String, strTotalNetQuantity As String, strTotalNetAmount As String) As String
        Dim dtCharge As New DataTable
        Dim DG As New pgSalesOtherBillWOChallan_GST()

        Try
            dtCharge = DG.ConvertChargeJSONToDataTable(strChargeGridData, "CHARGECODE")
            Dim sender As New Object
            Dim e As New System.EventArgs
            dtCharge.TableName = "ChargeTable"

            With dtCharge
                For iRow = 0 To .Rows.Count - 1
                    Call DG.fnCalculateCharge(iRow, dtCharge, strTotalNetQuantity, strTotalNetAmount)
                Next
            End With
        Catch ex As Exception
            Return "~Error in Charge"
        End Try

        Return DG.GetDataTableJson(dtCharge)
    End Function

    Public Function fnCalculateCharge(iRowNo As Long, ByRef dtCharge As DataTable, strTotalNetQuantity As String, strTotalNetAmount As String) As DataTable
        Dim dblTotal As Double
        Dim dblRoundOff As Double
        Dim dblGrossAmount As Double
        Dim strCalculated As String = ""
        Dim strFORMULA As String = ""

        strCalculated = "Amount=" & Format(Val(strTotalNetAmount), "0.00")
        strCalculated = strCalculated & ";" & "QUANTITY=" & Format(Val(strTotalNetQuantity), "0.000")

        With dtCharge
            For iRow = 0 To iRowNo
                If .Rows(iRow).Item("SELECTED") = "YES" And iRow <> iRowNo Then
                    'If .Rows(iRow).Item("CHARGENATURE") = "FIXED" & .Rows(iRow).Item("ADDLESSSIGN") = "?" Then

                    'Else
                    strCalculated = strCalculated & ";" & .Rows(iRow).Item("CHARGECODE") & "=" & Val(Trim(.Rows(iRow).Item("CHARGEAMOUNT")))
                    'End If
                ElseIf .Rows(iRow).Item("SELECTED") = "YES" Then
                    If .Rows(iRow).Item("CHARGENATURE") = "FIXED" And .Rows(iRow).Item("ADDLESSSIGN") = "?" Then

                    ElseIf .Rows(iRow).Item("CHARGENATURE") = "FIXED" Then
                        strCalculated = strCalculated & ";" & .Rows(iRow).Item("CHARGECODE") & "=" & Val(Trim(.Rows(iRow).Item("CHARGEAMOUNT")))
                    ElseIf .Rows(iRow).Item("CHARGENATURE") = "QUANTATIVE" Then
                        .Rows(iRow).Item("CHARGEAMOUNT") = Format((Val(strTotalNetQuantity) * Val(.Rows(iRow).Item("RATE"))) / Val(.Rows(iRow).Item("UNITQUANTITY")), "0.00")
                    ElseIf .Rows(iRow).Item("CHARGENATURE") = "WEIGHTED" Then
                        '.Rows(iRow).Item("CHARGEAMOUNT") = Format((Val(strTotalNetWeight) * Val(.Rows(iRow).Item("RATE"))) / Val(.Rows(iRow).Item("UNITQUANTITY")), "0.00")
                    ElseIf .Rows(iRow).Item("CHARGENATURE") = "NO OF PACKING" Then
                        '.Rows(iRow).Item("CHARGEAMOUNT") = Format((Val(strTotalNoofPacking) * Val(.Rows(iRow).Item("RATE"))) / Val(.Rows(iRow).Item("UNITQUANTITY")), "0.00")
                    Else
                        .Rows(iRow).Item("CHARGEAMOUNT") = Format(fnProcessFormula(Trim(.Rows(iRow).Item("CHANNELCODE")), .Rows(iRow).Item("CHARGECODE"), strFORMULA, , strCalculated & IIf(Len(strCalculated) > 0, ";", "") & "RATE=" & Val(.Rows(iRow).Item("RATE")), "Y"), "0.00")

                        .Rows(iRow).Item("ASSESSABLEAMOUNT") = Format(fnProcessFormula(Trim(.Rows(iRow).Item("CHANNELCODE")), .Rows(iRow).Item("CHARGECODE"), strFORMULA, , strCalculated & IIf(Len(strCalculated) > 0, ";", "") & "RATE=" & Val(.Rows(iRow).Item("RATE")), "N"), "0.00")
                    End If
                Else
                    strCalculated = strCalculated & ";" & .Rows(iRow).Item("CHARGECODE") & "=0"
                End If

                If .Rows(iRow).Item("ADDLESSSIGN") = "+" Then
                    If .Rows(iRow).Item("CHARGETYPE") <> "ROUND OFF" Then
                        dblTotal = dblTotal + Val(.Rows(iRow).Item("CHARGEAMOUNT"))
                    End If
                ElseIf .Rows(iRow).Item("ADDLESSSIGN") = "-" Then
                    If .Rows(iRow).Item("CHARGETYPE") <> "ROUND OFF" Then
                        dblTotal = dblTotal - Val(.Rows(iRow).Item("CHARGEAMOUNT"))
                    End If
                End If
            Next

            dblGrossAmount = Format(Val(dblTotal) + Val(strTotalNetAmount), "0.00")
            dblRoundOff = Math.Round(Val(dblGrossAmount), 0) - Val(dblGrossAmount)
            dblGrossAmount = Format(Val(dblGrossAmount) + dblRoundOff, "0.00")
            If dtCharge.Rows(dtCharge.Rows.Count - 1).Item("CHARGETYPE") = "ROUND OFF" Then
                If dtCharge.Rows(dtCharge.Rows.Count - 1).Item("SELECTED") = "YES" Then
                    dtCharge.Rows(dtCharge.Rows.Count - 1).Item("CHARGEAMOUNT") = Format(dblRoundOff, "0.00")
                End If
            End If
        End With

        Return dtCharge
    End Function
    Private Function ConvertChargeJSONToDataTable(jsonString As String, strNotNullableColumnName As String) As DataTable
        Dim dt As New DataTable()
        Dim jsonParts As String() = Regex.Split(jsonString.Replace("[", "").Replace("]", ""), "},{")

        Dim dtColumns As New List(Of String)()

        For Each jp As String In jsonParts
            Dim propData As String() = Regex.Split(jp.Replace("{", "").Replace("}", ""), ",")
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
            Dim propData As String() = Regex.Split(jp.Replace("{", "").Replace("}", ""), ",")
            Dim nr As DataRow = dt.NewRow()
            Dim blnDataFound As Boolean = True
            For Each rowData As String In propData
                Try
                    Dim idx As Integer = rowData.IndexOf(":")
                    Dim n As String = rowData.Substring(0, idx - 1).Replace("""", "")
                    Dim v As String = rowData.Substring(idx + 1).Replace("""", "")
                    nr(n) = v
                    If n.ToUpper = strNotNullableColumnName.ToUpper Then
                        If Trim(v.ToUpper) = "NULL" Or Trim(v.ToLower) = "null" Then
                            blnDataFound = False
                        End If
                    End If
                Catch ex As Exception

                End Try
            Next
            If blnDataFound Then
                dt.Rows.Add(nr)
            End If
        Next
        Return dt
    End Function
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
                    Dim v As String = rowData.Substring(idx + 1).Replace("""", "").Replace("\n\r", vbCr).Replace("\n", vbCr).Replace("\r", vbCr).Replace("\", Chr(34)).Replace("\\", "\").Replace(Chr(34) + Chr(34), "\").Replace("""U0027", "'").Replace("""U0026", "&").Replace("""u0027", "'").Replace("""u0026", "&")
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

    Public Function fnProcessFormula(strChannelCode As String, vChargeCode As String, strGFormula As String, Optional vCodeInitial As String = "C", Optional vReplaceCode As String = "Amount=0", Optional vIsCharge As String = "Y") As Double
        Dim arrChargeCode() As String
        Dim arrReplace() As String
        Dim strSql As String, strFORMULA = ""
        Dim StrRoundOff As String
        Dim strTmp As String
        Dim iCnt As Long
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim dtRetVal As New DataTable

        Try

            If strGFormula = "" Then
                strSql = ""
                If strChannelCode = "MISCELLANEOUS SALES" Then
                    strSql = strSql & vbCr & "SELECT FORMULA"
                    strSql = strSql & vbCr & "From CHARGEMASTER"
                    strSql = strSql & vbCr & "WHERE MODULETYPE = '" & strChannelCode & "'"
                    strSql = strSql & vbCr & "  AND CHARGECODE = '" & vChargeCode & "'"
                Else
                    If vIsCharge = "N" Then
                        strSql = strSql & vbCr & "SELECT ASSESSABLEFORMULA FORMULA"
                    Else
                        strSql = strSql & vbCr & "SELECT FORMULA"
                    End If
                    strSql = strSql & vbCr & "From CHARGEMASTER"
                    strSql = strSql & vbCr & "WHERE CHANNELCODE = '" & strChannelCode & "'"
                    strSql = strSql & vbCr & "  AND CHARGECODE = '" & vChargeCode & "'"
                    strSql = strSql & vbCr & "  AND ACTIVE = 'Y'"
                    strSql = strSql & vbCr & "  AND LASTMODIFIED = ("
                    strSql = strSql & vbCr & "      SELECT MAX(LASTMODIFIED) "
                    strSql = strSql & vbCr & "      FROM CHARGEMASTER"
                    strSql = strSql & vbCr & "      WHERE ACTIVE = 'Y'"
                    strSql = strSql & vbCr & "        AND CHANNELCODE = '" & strChannelCode & "'"
                    strSql = strSql & vbCr & "        AND CHARGECODE = '" & vChargeCode & "'"
                    strSql = strSql & vbCr & "      )"
                End If

                dbManager.Open()
                dtRetVal = dbManager.ExecuteDataTable(CommandType.Text, strSql)

                If Len(Trim(dtRetVal.Rows(0).Item("FORMULA"))) > 0 Then
                    strGFormula = dtRetVal.Rows(0).Item("FORMULA")
                Else
                    strGFormula = vChargeCode
                End If

                dtRetVal.Clear()
                dbManager.Close()

                strFORMULA = strGFormula
            End If

            arrReplace = Split(vReplaceCode, ";")

            For iCnt = 0 To UBound(arrReplace)
                arrChargeCode = Split(arrReplace(iCnt), "=")
                strFORMULA = Replace(strFORMULA, arrChargeCode(0), "(" & arrChargeCode(1) & ")", , , vbTextCompare)

            Next

            While InStr(strFORMULA, vCodeInitial) > 0
                strTmp = strFORMULA
                strTmp = Replace(strTmp, "+", "~")
                strTmp = Replace(strTmp, "-", "~")
                strTmp = Replace(strTmp, "*", "~")
                strTmp = Replace(strTmp, "/", "~")
                strTmp = Replace(strTmp, "\", "~")
                strTmp = Replace(strTmp, "^", "~")
                strTmp = Replace(strTmp, "%", "~")
                strTmp = Replace(strTmp, "(", "~")
                strTmp = Replace(strTmp, ")", "~")
                strTmp = Replace(strTmp, "~~", "~")
                strTmp = Replace(strTmp, " ", "")

                arrChargeCode = Split(strTmp, "~")

                For iCnt = 0 To UBound(arrChargeCode)
                    If InStr(arrChargeCode(iCnt), vCodeInitial) > 0 Then
                        strSql = ""
                        If strChannelCode = "MISCELLANEOUS SALES" Then
                            strSql = strSql & vbCr & "SELECT NVL(MAX(FORMULA), '0') FORMULA"
                            strSql = strSql & vbCr & "From CHARGEMASTER"
                            strSql = strSql & vbCr & "WHERE MODULETYPE = '" & strChannelCode & "'"
                            strSql = strSql & vbCr & "  AND CHARGECODE = '" & arrChargeCode(iCnt) & "'"
                            strSql = strSql & vbCr & "  AND CHARGENATURE = 'FORMULA'"
                        Else
                            If vIsCharge = "N" Then
                                strSql = strSql & vbCr & "SELECT  NVL(MAX(ASSESSABLEFORMULA), '0') FORMULA"
                            Else
                                strSql = strSql & vbCr & "SELECT NVL(MAX(FORMULA), '0') FORMULA"
                            End If
                            strSql = strSql & vbCr & "From CHARGEMASTER"
                            strSql = strSql & vbCr & "WHERE CHANNELCODE = ''"
                            strSql = strSql & vbCr & "  AND CHARGECODE = '" & arrChargeCode(iCnt) & "'"
                            strSql = strSql & vbCr & "  AND CHARGENATURE = 'FORMULA'"
                            strSql = strSql & vbCr & "  AND ACTIVE = 'Y'"
                            strSql = strSql & vbCr & "  AND LASTMODIFIED = ("
                            strSql = strSql & vbCr & "      SELECT MAX(LASTMODIFIED) "
                            strSql = strSql & vbCr & "      FROM CHARGEMASTER"
                            strSql = strSql & vbCr & "      WHERE ACTIVE = 'Y'"
                            strSql = strSql & vbCr & "        AND CHANNELCODE = '" & strChannelCode & "'"
                            strSql = strSql & vbCr & "        AND CHARGECODE = '" & arrChargeCode(iCnt) & "'"
                            strSql = strSql & vbCr & "        AND CHARGENATURE = 'FORMULA'"
                            strSql = strSql & vbCr & "      )"
                        End If

                        dbManager.Open()
                        dtRetVal = dbManager.ExecuteDataTable(CommandType.Text, strSql)

                        If Len(Trim(dtRetVal.Rows(0).Item("FORMULA"))) > 0 Then
                            strFORMULA = Replace(strFORMULA, arrChargeCode(iCnt), "(" & dtRetVal.Rows(0).Item("FORMULA") & ")")
                        Else
                            strFORMULA = Replace(strFORMULA, arrChargeCode(iCnt), "0")
                        End If

                        dtRetVal.Clear()
                        dbManager.Close()
                    End If
                Next
            End While

            arrReplace = Split(vReplaceCode, ";")

            For iCnt = 0 To UBound(arrReplace)
                arrChargeCode = Split(arrReplace(iCnt), "=")
                strFORMULA = Replace(strFORMULA, arrChargeCode(0), "(" & arrChargeCode(1) & ")", , , vbTextCompare)
            Next

            strSql = ""
            strSql = " SELECT ROUNDOFF FROM CHARGEMASTER "
            strSql = strSql & vbCrLf & " WHERE CHANNELCODE = '" & strChannelCode & "'"
            strSql = strSql & vbCrLf & "   AND CHARGECODE = '" & vChargeCode & "'"

            dbManager.Open()
            dtRetVal = dbManager.ExecuteDataTable(CommandType.Text, strSql)

            StrRoundOff = Val(dtRetVal.Rows(0).Item("ROUNDOFF") & "")

            dtRetVal.Clear()
            dbManager.Close()

            strSql = "SELECT ROUND(" & IIf(Trim(strFORMULA) = "", 0, strFORMULA) & ", " & StrRoundOff & ") CHARGEAMOUNT FROM DUAL"

            dbManager.Open()
            dtRetVal = dbManager.ExecuteDataTable(CommandType.Text, strSql)

            fnProcessFormula = Val(dtRetVal.Rows(0).Item("CHARGEAMOUNT") & "")

            dtRetVal.Clear()
            dbManager.Close()
        Catch ex As Exception
            Return "~Error in Sales Process Formula"
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
    End Function
    Public Function ValidatePage() As Boolean
        Dim blnReturnValidate As Boolean = True

        Return blnReturnValidate
    End Function

    Private Sub txtSCRAPSALESBILLNO_TextChanged(sender As Object, e As EventArgs) Handles txtSCRAPSALESBILLNO.TextChanged
        If Len(txtSCRAPSALESBILLNO.Text) > 0 Then
            getMasterData()
        End If
    End Sub
    Protected Sub getMasterData()
        Dim strSql As String
        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Try
            DBManager.Open()

            strSql = ""
            strSql = strSql & vbCrLf & " SELECT A.CHANNELCODE, A.SCRAPSALESBILLNO,TO_CHAR( A.SCRAPSALESBILLDATE,'DD/MM/YYYY') SCRAPSALESBILLDATE, A.SALESBILLNO,A.BILLTYPE,"
            strSql = strSql & vbCrLf & " TO_CHAR(A.SALESBILLDATE,'DD/MM/YYYY') SALESBILLDATE, A.PARTYCODE, B.PARTYNAME PARTYNAME,A.NETAMT,A.GROSSAMT ,A.WEIGHTSLIPNO, A.AMENDMENT, A.DESTINATION, "
            strSql = strSql & vbCrLf & " A.GATEPASSNO, TO_CHAR(A.GATEPASSDATE,'DD/MM/YYYY') GATEPASSDATE, A.LORRYNO, A.LETTERNO,TO_CHAR( A.LETTERDATE,'DD/MM/YYYY') LETTERDATE, "
            strSql = strSql & vbCrLf & " A.PURCHASEORDERNO PONO, TO_CHAR(A.PURCHASEORDERDATE,'DD/MM/YYYY') PODATE, A.MRNO, TO_CHAR(A.MRDATE,'DD/MM/YYYY') MRDATE, A.ADDRESSCODEBILL, A.BILLSTATECODE, A.ADDRESSCODE "
            strSql = strSql & vbCrLf & " FROM SALESOTHERBILLMASTER A, PARTYMASTER B"
            strSql = strSql & vbCrLf & " WHERE A.PARTYCODE = B.PARTYCODE"
            strSql = strSql & vbCrLf & "  AND A.COMPANYCODE = B.COMPANYCODE"
            strSql = strSql & vbCrLf & "  AND A.SALESBILLNO = '" & txtSALESBILLNO.Text & "'"
            strSql = strSql & vbCrLf & "  AND A.CHANNELCODE = '" & txtCHANNELCODE.Text & "'"
            strSql = strSql & vbCrLf & "  AND A.COMPANYCODE ='" & HttpContext.Current.Session("COMPANYCODE") & "'"
            strSql = strSql & vbCrLf & "  AND A.DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "' "
            strSql = strSql & vbCrLf & "  AND A.BILLTYPE='WITHOUT CHALLAN'"

            Call ObjectSetClass.ObjectSetClass.GetMasterData(Me.Controls, DBManager, strSql)

            txtADDRESSDESCBILL.Text = DBManager.ExecuteScalar(CommandType.Text, "SELECT DISTINCT ADDRESS FROM PARTYADDRESS WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "' AND PARTYCODE ='" & txtPARTYCODE.Text & "' AND ADDRESSCODE='" & txtADDRESSCODEBILL.Text & "'") & ""
            txtADDRESSDESC.Text = DBManager.ExecuteScalar(CommandType.Text, "SELECT DISTINCT ADDRESS FROM PARTYADDRESS WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "' AND PARTYCODE ='" & txtPARTYCODE.Text & "' AND ADDRESSCODE='" & txtADDRESSCODE.Text & "'") & ""
            txtBILLSTATEDESC.Text = DBManager.ExecuteScalar(CommandType.Text, "SELECT DISTINCT STATENAME FROM GSTSTATEMASTER WHERE GSTSTATECODE = '" & txtBILLSTATECODE.Text & "' ") & ""

            If (Not ClientScript.IsStartupScriptRegistered("fetchgrid1")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgrid1", "FetchGridData();", True)
            End If
            '------------- Filling Charge Grid
            If (Not ClientScript.IsStartupScriptRegistered("fetchgridCharge")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgridCharge", "FetchChargeGridData();", True)
            End If
        Catch ex As Exception
            strMessage.Text = "Error occured while populating data..." & vbCrLf & ex.Message.ToString
        Finally
            DBManager.Close()
            DBManager.Dispose()
            DBManager = Nothing
        End Try
    End Sub
    Protected Function GridDataFetch(strchallanno As String, strbillno As String, strOperationMode As String) As DataTable
        Dim dtGridData As New DataTable

        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim strSQL As String = ""

        strSQL = ""
        strSQL = " SELECT A.CHANNELCODE, A.SALESBILLNO, TO_CHAR(A.SALESBILLDATE,'DD/MM/YYYY') SALESBILLDATE, A.SERIALNO,A.SCRAPSERIALNO, A.ITEMDESC, A.QUANTITY, B.MEASURECODE UOMCODE, "
        strSQL = strSQL & vbCrLf & " B.MEASURENAME UOMDESC, A.RATE, A.AMOUNT,A.ACCODE, L.ACHEAD, "
        strSQL = strSQL & vbCrLf & " A.COMPANYCODE,  A.DIVISIONCODE, A.YEARCODE, A.NOOFPKG, "
        strSQL = strSQL & vbCrLf & " '" & HttpContext.Current.Session("USERNAME") & "' USERNAME, '' SYSROWID,'" & HttpContext.Current.Session("OPERATIONMODE") & "' OPERATIONMODE, A.HSNCODE "
        strSQL = strSQL & vbCrLf & " FROM SALESOTHERBILLDETAIL A, SALESMEASUREMASTER B,ACACLEDGER L "
        strSQL = strSQL & vbCrLf & " WHERE A.UOMCODE = B.MEASURECODE(+)"
        strSQL = strSQL & vbCrLf & " AND A.COMPANYCODE = B.COMPANYCODE(+)"
        strSQL = strSQL & vbCrLf & " AND A.DIVISIONCODE = B.DIVISIONCODE(+)"
        strSQL = strSQL & vbCrLf & " AND A.COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "' "
        strSQL = strSQL & vbCrLf & " AND A.DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "' "
        strSQL = strSQL & vbCrLf & " AND A.SALESBILLNO = '" & strbillno & "'  "
        strSQL = strSQL & vbCrLf & " AND A.COMPANYCODE=L.COMPANYCODE"
        strSQL = strSQL & vbCrLf & " AND L.DIVISIONCODE LIKE '%" & HttpContext.Current.Session("DIVISIONCODE") & "%'"
        strSQL = strSQL & vbCrLf & " AND A.ACCODE=L.ACCODE"
        strSQL = strSQL & vbCrLf & " ORDER BY A.SERIALNO"

        Try
            dbManager.Open()
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
    Protected Function ChargeGridDataFetch(strOperationMode As String, strChannelCode As String, strSALEBILLNO As String, strdoctype As String) As DataTable
        Dim dtGridData As New DataTable
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim strSQL As String

        Try
            dbManager.Open()
            Dim intRecords As Integer = Val(dbManager.ExecuteScalar(CommandType.Text, "SELECT NVL(COUNT(*),0) FROM SALESCHARGEDETAILS WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "' AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "' AND DOCUMENTNO = '" & strSALEBILLNO & "'") & "")
            strSQL = ""
            strSQL = strSQL & vbCrLf & "SELECT DECODE(B.DOCUMENTNO, NULL, 'NO', 'YES') SELECTED, A.CHARGECODE, A.CHARGENAME CHARGEDESC, A.CHARGENATURE,"
            strSQL = strSQL & vbCrLf & "       A.FORMULA,  NVL(A.RATEPERUNIT,0) RATE, A.ADDLESS, DECODE(A.ADDLESS, 'ADDITION', '+', 'SUBSTRACTION', '-', '?') ADDLESSSIGN, B.CHARGEAMOUNT,"
            strSQL = strSQL & vbCrLf & "       B.COMPANYCODE, B.DIVISIONCODE, B.DIVISIONCODEFOR, B.YEARCODE, B.CHANNELCODE, DOCUMENTNO, TO_CHAR(DOCUMENTDATE,'DD/MM/YYYY') DOCUMENTDATE,"
            strSQL = strSQL & vbCrLf & "       DOCUMENTTYPE, ASSESSABLEAMOUNT, A.CHARGETYPE, NULL SYSROWID, B.USERNAME, '" & IIf(intRecords > 0, strOperationMode, "A") & "' OPERATIONMODE,B.UNIT, B.UORCODE, NVL(A.UNITQUANTITY,B.UNITQUANTITY) UNITQUANTITY"
            strSQL = strSQL & vbCrLf & "  FROM CHARGEMASTER A, SALESCHARGEDETAILS B"
            strSQL = strSQL & vbCrLf & " WHERE A.COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
            strSQL = strSQL & vbCrLf & "   AND A.DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
            '''strSQL = strSQL & vbCrLf & "   AND A.YEARCODE = '" & HttpContext.Current.Session("YEARCODE") & "'"
            strSQL = strSQL & vbCrLf & "   AND A.MODULE = '" & HttpContext.Current.Session("PROJECTNAME") & "'"
            strSQL = strSQL & vbCrLf & "   AND A.CHANNELCODE = '" & strChannelCode & "'"
            strSQL = strSQL & vbCrLf & "   AND A.ACTIVE = 'Y'"
            strSQL = strSQL & vbCrLf & "   AND A.CHARGENATURE<>'TCS'"
            If strOperationMode <> "A" Then
                strSQL = strSQL & vbCrLf & "   AND B.DOCUMENTNO (+) ='" & strSALEBILLNO & "'"
            Else
                strSQL = strSQL & vbCrLf & "   AND B.DOCUMENTNO (+) = CHR(32)"
            End If
            strSQL = strSQL & vbCrLf & "   AND B.DOCUMENTTYPE (+) = '" & strdoctype & "'"
            strSQL = strSQL & vbCrLf & "   AND B.CHANNELCODE (+) = '" & strChannelCode & "'"
            strSQL = strSQL & vbCrLf & "   AND A.COMPANYCODE = B.COMPANYCODE (+)"
            strSQL = strSQL & vbCrLf & "   AND A.DIVISIONCODE = B.DIVISIONCODE (+)"
            '''strSQL = strSQL & vbCrLf & "   AND A.YEARCODE = B.YEARCODE (+)"
            strSQL = strSQL & vbCrLf & "   AND A.CHANNELCODE = B.CHANNELCODE (+)"
            strSQL = strSQL & vbCrLf & "   AND A.CHARGECODE = B.CHARGECODE (+)"
            strSQL = strSQL & vbCrLf & " ORDER BY A.SERIALNO"

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

    Private Sub txtSALESBILLNO_TextChanged(sender As Object, e As EventArgs) Handles txtSALESBILLNO.TextChanged
        If Len(txtSALESBILLNO.Text) > 0 Then
            getMasterData()
        End If
    End Sub

    Private Sub txtCHANNELCODE_TextChanged(sender As Object, e As EventArgs) Handles txtCHANNELCODE.TextChanged
        If Len(txtCHANNELCODE.Text) > 0 Then
            Dim STRSQL As String = ""
            Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
            Try
                dbManager.Open()
                STRSQL = ""
                STRSQL = STRSQL & vbCrLf & " SELECT DISTINCT CHANNELTAG"
                STRSQL = STRSQL & vbCrLf & "  FROM CHANNELMASTER"
                STRSQL = STRSQL & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
                STRSQL = STRSQL & vbCrLf & "   AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
                STRSQL = STRSQL & vbCrLf & "   AND MODULE = '" & HttpContext.Current.Session("PROJECTNAME") & "'"
                STRSQL = STRSQL & vbCrLf & "   AND CHANNELCODE = '" & txtCHANNELCODE.Text & "'"
                txtCHANNELTAG.Text = dbManager.ExecuteScalar(CommandType.Text, STRSQL)
                If txtCHANNELTAG.Text = "SCRAP" Then
                    txtDOCUMENTTYPE.Text = "SCRAP BILL"
                ElseIf txtCHANNELTAG.Text = "OTHERS" Then
                    txtDOCUMENTTYPE.Text = "OTHERS BILL"
                Else
                    txtDOCUMENTTYPE.Text = "SALE BILL"
                End If
                '------------- Filling Charge Grid
                If (Not ClientScript.IsStartupScriptRegistered("fetchgridCharge")) Then
                    Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgridCharge", "FetchChargeGridData();", True)
                End If
            Catch ex As Exception
                strMessage.Text = "Error occured while fetching details.." & vbCrLf & ex.Message.ToString
            Finally
                dbManager.Close()
                dbManager.Dispose()
                dbManager = Nothing
            End Try
        End If
    End Sub
End Class