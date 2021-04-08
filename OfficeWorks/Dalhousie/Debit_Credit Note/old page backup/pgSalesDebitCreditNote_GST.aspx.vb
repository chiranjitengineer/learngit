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
Public Class pgSalesDebitCreditNote_GST
    Inherits System.Web.UI.Page

    Dim strMessage As Label
    Dim btnSubmit As Button
    Dim strOptType As String
    Dim txtMasterTableName As TextBox
    Dim txtSyncActualTable As TextBox
    Dim txtUserName As TextBox
    Dim txtButtonTag As TextBox
    Dim ddOperationType As DropDownList
    ' for grid control
    Dim txtDETAILSTABLENAME As TextBox
    Dim blnExit As Boolean = True
    Dim dtTmp As New DataTable
    Dim dtCharge As New DataTable
    Dim blnHideDefHeader As Boolean = False
    Dim btnMasterSubmit As Button
    ' for grid control

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim strSql As String = ""
        '-- START -- FOLLOWINGS ARE MANDATORY FOR MASTER PAGE
        ddOperationType = DirectCast(Master.FindControl("ddChooseOperation"), DropDownList)
        strMessage = DirectCast(Master.FindControl("lblMasterMessage"), Label)
        txtMasterTableName = DirectCast(Master.FindControl("txtMASTERTABLENAME"), TextBox)
        txtDETAILSTABLENAME = DirectCast(Master.FindControl("txtDETAILSTABLENAME"), TextBox)
        txtSyncActualTable = DirectCast(Master.FindControl("txtSYNCACTUALTABLE"), TextBox)
        txtUserName = DirectCast(Master.FindControl("txtUSERNAME"), TextBox)
        txtButtonTag = DirectCast(Master.FindControl("txtButtonTag"), TextBox)
        btnMasterSubmit = DirectCast(Master.FindControl("btnSubmit"), Button)

        If Not ddOperationType Is Nothing Then
            Dim strVal As String
            strVal = IIf(ddOperationType.SelectedValue = "ADD", "A", IIf(ddOperationType.SelectedValue = "EDIT", "M", IIf(ddOperationType.SelectedValue = "DELETE", "D", "")))
            txtOPTMODE.Text = strVal
        End If
        '-- END   -- FOLLOWINGS ARE MANDATORY FOR MASTER PAGE

        txtMasterTableName.Text = "GBL_SALESDEBITCREDITNOTEMASTER"
        txtSyncActualTable.Text = "true"

        If IsPostBack Then
            If Len(Trim(txtDETAILSGRIDDATA.Text)) > 4 Then
                GetData(txtDETAILSGRIDDATA.Text, "SELECTED")
            End If

            If Len(Trim(txtCHARGEGRIDDATA.Text)) > 4 Then
                GetChargeData(txtCHARGEGRIDDATA.Text, "DOCUMENTDATE")
            End If

            If Not IsNothing(dtTmp) Then
                txtDETAILSTABLENAME.Text = "GBL_SALESDEBITCREDITNOTEDTLS~" & ConvertDatatableToXML(dtTmp)
                If Not IsNothing(dtCharge) Then
                    If dtCharge.Rows.Count > 0 Then
                        txtDETAILSTABLENAME.Text = txtDETAILSTABLENAME.Text & "#GBL_SALESCHARGEDETAILS~" & ConvertDatatableToXML(dtCharge)
                    End If
                End If
            End If
        End If
    End Sub

    Private Sub pgSalesDebitCreditNote_GST_LoadComplete(sender As Object, e As EventArgs) Handles Me.LoadComplete
        txtCOMPCODE.Text = HttpContext.Current.Session("COMPANYCODE")
        txtDIVCODE.Text = HttpContext.Current.Session("DIVISIONCODE")
        txtUSRNAME.Text = HttpContext.Current.Session("USERNAME")
        txtPROJNAME.Text = HttpContext.Current.Session("PROJECTNAME")
        txtYRCODE.Text = HttpContext.Current.Session("YEARCODE")

        '' txtDOCUMENTTYPE.Text = "EXCISE INVOICE"

        If Len(Trim(txtCHANNELCODE.Text)) = 0 Then
            txtCHANNELCODE.Focus()
        Else
            If Len(Trim(txtREFEXCISEINVNO.Text)) = 0 Then
                txtREFEXCISEINVNO.Focus()
            End If
        End If

        txtOPTMODE.Text = IIf(ddOperationType.SelectedValue = "ADD", "A", IIf(ddOperationType.SelectedValue = "EDIT", "M", IIf(ddOperationType.SelectedValue = "DELETE", "D", "")))

        txtCHANNELCODE.Attributes.Add("readonly", "readonly")

        txtNETAMOUNT.Attributes.Add("readonly", "readonly")
        txtNETINDIANAMOUNT.Attributes.Add("readonly", "readonly")
        txtGROSSAMOUNT.Attributes.Add("readonly", "readonly")
        txtTOTALNETQUANTITY.Attributes.Add("readonly", "readonly")

        If txtButtonTag.Text = "Submit" Or txtButtonTag.Text = "Reset" Then
            txtButtonTag.Text = ""
        End If
        If txtOPTMODE.Text = "" Or txtOPTMODE.Text = "A" Then
            mskDEBITCREDITNOTEDATE.Text = Format(Now, "dd/MM/yyyy")
        End If

        '------------ Locking Textbox having Help (F2)
        txtCHANNELCODE.Attributes.Add("readonly", "readonly")
        txtREFEXCISEINVNO.Attributes.Add("readonly", "readonly")

        If IsPostBack Then
            RbtDebitNote.Checked = True
        End If

        If RbtDebitNote.Checked = True Then
            txtREFERENCETYPE.Text = "DEBIT NOTE"
            txtDOCUMENTTYPE.Text = "DEBIT NOTE"
            lblDEBITCREDITNOTENO.Text = "Debit Note No."
            lblDEBITCREDITNOTEDATE.Text = "Debit Note Date"
            txtDOCUMENTTYPE.Text = "DEBIT NOTE"
        End If
        If RbtCreditNote.Checked = True Then
            txtREFERENCETYPE.Text = "CREDIT NOTE"
            txtDOCUMENTTYPE.Text = "CREDIT NOTE"
            lblDEBITCREDITNOTENO.Text = "Credit Note No."
            lblDEBITCREDITNOTEDATE.Text = "Credit Note Date"
            txtDOCUMENTTYPE.Text = "CREDIT NOTE"
        End If



        ' ''If Mid(strMessage.Text, 1, 9) <> "#SUCCESS#" Then
        ' ''    If (Not Page.ClientScript.IsStartupScriptRegistered("populatedetails")) Then
        ' ''        Page.ClientScript.RegisterStartupScript(Me.GetType(), "populatedetails", "rePopulateGrid();", True)
        ' ''    End If
        ' ''End If

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

    Public Sub GetData(gridData As String, strNotNullableColumnName As String)
        'string data = gridData;
        Dim DG As New pgSalesDebitCreditNote_GST()
        Dim DTable As DataTable = DG.ConvertJSONToDataTable(gridData, strNotNullableColumnName)
        Dim sender As New Object
        Dim e As New System.EventArgs
        dtTmp = DG.ConvertJSONToDataTable(gridData, strNotNullableColumnName)
        dtTmp.TableName = "Table1"
    End Sub

    Public Sub GetChargeData(gridData As String, strNotNullableColumnName As String)
        'string data = gridData;
        Dim DG As New pgSalesDebitCreditNote_GST()
        Dim sender As New Object
        Dim e As New System.EventArgs
        dtCharge = DG.ConvertJSONToDataTable(gridData, strNotNullableColumnName)
        dtCharge.TableName = "Table1"
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
                        If Trim(v.ToUpper) = "NULL" Or Trim(v.ToLower) = "null" Or Len(Trim(v.ToLower)) = 0 Then
                            blnDataFound = False
                        End If
                    End If
                    If n.ToUpper = "SELECTED" Then
                        If Trim(v.ToUpper) = "NO" Or Trim(v.ToLower) = "no" Or Len(Trim(v.ToLower)) = 0 Then
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


    Protected Sub getMasterDataByDRCRNo()
        Dim strSql As String
        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager

        Try
            DBManager.Open()

            strSql = ""

            strSql = strSql & vbCrLf & " SELECT /*+ ORDERED */ DISTINCT A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE, A.CHANNELCODE, "
            strSql = strSql & vbCrLf & "       A.PROFORMAINVNO, TO_CHAR(A.PROFORMAINVDATE,'DD/MM/YYYY') PROFORMAINVDATE, "
            strSql = strSql & vbCrLf & "       A.EXCISEINVNO, TO_CHAR(A.EXCISEINVDATE,'DD/MM/YYYY') EXCISEINVDATE, "
            strSql = strSql & vbCrLf & "       A.AGAINSTEXCISEINVNO SALEBILLNO, TO_CHAR(A.AGAINSTEXCISEINVDATE,'DD/MM/YYYY') SALEBILLDATE, "
            strSql = strSql & vbCrLf & "       A.CHALLANNO, A.BROKERCODE, A.BROKERNAME, A.BUYERCODE, A.BUYERNAME, A.ADDRESSCODE, A.ADDRESS, "
            strSql = strSql & vbCrLf & "       A.VEHICLENO, A.TRANSPORTERCODE, A.DESTINATION, A.CNOTENO, TO_CHAR(A.CNOTEDATE,'DD/MM/YYYY') CNOTEDATE, A.BOOKING, "
            strSql = strSql & vbCrLf & "       TO_CHAR(B.REMOVALDATE,'DD/MM/YYYY') REMOVALDATE, A.TIMEOFPREPARATION, A.SEALNO, TO_CHAR(A.ISSUEDATE,'DD/MM/YYYY') ISSUEDATE, "
            strSql = strSql & vbCrLf & "       A.TIMEOFISSUE, A.VESSELORFLIGHT, A.CONTAINERTYPE, A.CONTAINERNO, A.REMARKS, A.EXFROM, A.EXTO, A.RENO, A.FORM1NO, "
            strSql = strSql & vbCrLf & "      TO_CHAR(B.DEBITCREDITNOTEDATE,'DD/MM/YYYY') DEBITCREDITNOTEDATE,A.ADDRESSCODEBILL,A.ADDRESS AS ADDRESSDESCBILL, A.BILLSTATECODE,G.STATENAME AS BILLSTATEDESC, A.BILLEXCHANGERATE AS EXCHRATE, "
            strSql = strSql & vbCrLf & "       B.NETAMONT NETAMOUNT, B.GROSSAMOUNT, B.SYSROWID, '" & txtUSRNAME.Text & "' USERNAME, B.REFEXCISEINVNO, TO_CHAR(B.REFEXCISEINVDATE,'DD/MM/YYYY') REFEXCISEINVDATE "
            strSql = strSql & vbCrLf & "  FROM SALESEXCISEINVOICEVIEW A, SALESDEBITCREDITNOTEMASTER B, GSTSTATEMASTER G"
            strSql = strSql & vbCrLf & " WHERE A.COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "' "
            strSql = strSql & vbCrLf & "   AND A.DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "' "
            strSql = strSql & vbCrLf & "   AND A.EXCISEINVNO = '" & txtDEBITCREDITNOTENO.Text & "' "
            strSql = strSql & vbCrLf & "   AND A.COMPANYCODE = B.COMPANYCODE "
            strSql = strSql & vbCrLf & "   AND A.DIVISIONCODE = B.DIVISIONCODE "
            strSql = strSql & vbCrLf & "   AND A.YEARCODE = B.YEARCODE "
            strSql = strSql & vbCrLf & "   AND A.CHANNELCODE = B.CHANNELCODE "
            strSql = strSql & vbCrLf & "   AND A.EXCISEINVNO = B.DEBITCREDITNOTENO "
            strSql = strSql & vbCrLf & "   AND A.BILLSTATECODE=G.GSTSTATECODE(+) "

            ''strSql = strSql & vbCrLf & "SELECT /*+ ORDERED */ DISTINCT A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE, A.CHANNELCODE,"
            ''strSql = strSql & vbCrLf & "       A.PROFORMAINVNO, TO_CHAR(A.PROFORMAINVDATE,'DD/MM/YYYY') PROFORMAINVDATE,"
            ''strSql = strSql & vbCrLf & "       A.EXCISEINVNO, TO_CHAR(A.DEBITCREDITNOTEDATE,'DD/MM/YYYY') DEBITCREDITNOTEDATE,"
            ''strSql = strSql & vbCrLf & "       A.CHALLANNO, A.BROKERCODE, A.BROKERNAME, A.BUYERCODE, A.BUYERNAME, A.ADDRESSCODE, A.ADDRESS,"
            ''strSql = strSql & vbCrLf & "       A.VEHICLENO, A.TRANSPORTERCODE, A.DESTINATION, A.CNOTENO, TO_CHAR(A.CNOTEDATE,'DD/MM/YYYY') CNOTEDATE, A.BOOKING,"
            ''strSql = strSql & vbCrLf & "       TO_CHAR(B.REMOVALDATE,'DD/MM/YYYY') REMOVALDATE, A.TIMEOFPREPARATION, A.SEALNO, TO_CHAR(A.ISSUEDATE,'DD/MM/YYYY') ISSUEDATE,"
            ''strSql = strSql & vbCrLf & "       A.TIMEOFISSUE, A.VESSELORFLIGHT, A.CONTAINERTYPE, A.CONTAINERNO, A.REMARKS, A.EXFROM, A.EXTO, A.RENO, A.FORM1NO,"
            ''strSql = strSql & vbCrLf & "       B.NETAMONT NETAMOUNT, B.GROSSAMOUNT, B.SYSROWID, '" & txtUSRNAME.Text & "' USERNAME, B.REFEXCISEINVNO, TO_CHAR(B.REFEXCISEINVDATE,'DD/MM/YYYY') REFEXCISEINVDATE "
            ''strSql = strSql & vbCrLf & "  FROM SALESEXCISEINVOICEVIEW A, SALESEXCISEINVOICEMASTER B"
            ''strSql = strSql & vbCrLf & " WHERE A.COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
            ''strSql = strSql & vbCrLf & "   AND A.DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
            ''strSql = strSql & vbCrLf & "   AND A.EXCISEINVNO = '" & txtDEBITCREDITNOTENO.Text & "'"
            ''strSql = strSql & vbCrLf & "   AND A.COMPANYCODE = B.COMPANYCODE"
            ''strSql = strSql & vbCrLf & "   AND A.DIVISIONCODE = B.DIVISIONCODE"
            ''strSql = strSql & vbCrLf & "   AND A.YEARCODE = B.YEARCODE"
            ''strSql = strSql & vbCrLf & "   AND A.CHANNELCODE = B.CHANNELCODE"
            ''strSql = strSql & vbCrLf & "   AND A.EXCISEINVNO = B.EXCISEINVNO"

            Call ObjectSetClass.ObjectSetClass.GetMasterData(Me.Controls, DBManager, strSql)
            DBManager.Close()

            '================ Fetching Descriptions
            If Len(Trim(txtBROKERCODE.Text)) > 0 Then
                '--------------- Broker Description
                strSql = ""
                strSql = strSql & vbCrLf & "SELECT PARTYNAME"
                strSql = strSql & vbCrLf & "  FROM PARTYMASTER"
                strSql = strSql & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
                strSql = strSql & vbCrLf & "   AND MODULE = '" & HttpContext.Current.Session("PROJECTNAME") & "'"
                strSql = strSql & vbCrLf & "   AND PARTYTYPE = 'BROKER'"
                strSql = strSql & vbCrLf & "   AND PARTYCODE = '" & txtBROKERCODE.Text & "'"

                DBManager.Open()
                txtBROKERNAME.Text = DBManager.ExecuteScalar(CommandType.Text, strSql)
            End If

            If Len(Trim(txtBUYERCODE.Text)) > 0 Then
                '--------------- Buyer Description
                strSql = ""
                strSql = strSql & vbCrLf & "SELECT PARTYNAME"
                strSql = strSql & vbCrLf & "  FROM PARTYMASTER"
                strSql = strSql & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
                strSql = strSql & vbCrLf & "   AND MODULE = '" & HttpContext.Current.Session("PROJECTNAME") & "'"
                strSql = strSql & vbCrLf & "   AND PARTYTYPE = 'BUYER'"
                strSql = strSql & vbCrLf & "   AND PARTYCODE = '" & txtBUYERCODE.Text & "'"

                DBManager.Open()
                txtBUYERNAME.Text = DBManager.ExecuteScalar(CommandType.Text, strSql)
            End If

            If Len(Trim(txtADDRESSCODE.Text)) > 0 Then
                '--------------- Address Description
                strSql = ""
                strSql = strSql & vbCrLf & "SELECT ADDRESS"
                strSql = strSql & vbCrLf & "  FROM PARTYADDRESS"
                strSql = strSql & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
                strSql = strSql & vbCrLf & "   AND MODULE = '" & HttpContext.Current.Session("PROJECTNAME") & "'"
                strSql = strSql & vbCrLf & "   AND PARTYTYPE = 'BUYER'"
                strSql = strSql & vbCrLf & "   AND PARTYCODE = '" & txtBUYERCODE.Text & "'"
                strSql = strSql & vbCrLf & "   AND ADDRESSCODE = '" & txtADDRESSCODE.Text & "'"

                DBManager.Open()
                txtADDRESSDESC.Text = DBManager.ExecuteScalar(CommandType.Text, strSql)
            End If

            If Len(Trim(txtTRANSPORTERCODE.Text)) > 0 Then
                '--------------- Transporter Description
                strSql = ""
                strSql = strSql & vbCrLf & "SELECT PARTYNAME"
                strSql = strSql & vbCrLf & "  FROM PARTYMASTER"
                strSql = strSql & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
                strSql = strSql & vbCrLf & "   AND MODULE = '" & HttpContext.Current.Session("PROJECTNAME") & "'"
                strSql = strSql & vbCrLf & "   AND PARTYTYPE = 'TRANSPORTER'"
                strSql = strSql & vbCrLf & "   AND PARTYCODE = '" & txtTRANSPORTERCODE.Text & "'"

                DBManager.Open()
                txtTRANSPORTERDESC.Text = DBManager.ExecuteScalar(CommandType.Text, strSql)
            End If

            If Len(Trim(txtVESSELFLIGHTNO.Text)) > 0 Then
                '--------------- Vessel/Flight Description
                strSql = ""
                strSql = strSql & vbCrLf & "SELECT TRANSPORTMODEDESC"
                strSql = strSql & vbCrLf & "  FROM SALESMODEOFTRANSPORTMASTER"
                strSql = strSql & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
                strSql = strSql & vbCrLf & "   AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
                strSql = strSql & vbCrLf & "   AND TRANSPORTMODECODE = '" & txtVESSELFLIGHTNO.Text & "'"

                DBManager.Open()
                txtVESSELFLIGHTDESC.Text = DBManager.ExecuteScalar(CommandType.Text, strSql)
            End If
        Catch ex As Exception
            strMessage.Text = "Error occured while populating data..." & vbCrLf & ex.Message.ToString
        Finally
            DBManager.Close()
            DBManager.Dispose()
            DBManager = Nothing
        End Try
    End Sub

    Private Sub txtCHANNELCODE_TextChanged(sender As Object, e As EventArgs) Handles txtCHANNELCODE.TextChanged
        Dim strSql As String
        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager

        strSql = ""
        strSql = strSql & vbCrLf & "SELECT DISTINCT CHANNELTAG"
        strSql = strSql & vbCrLf & "  FROM CHANNELMASTER"
        strSql = strSql & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
        strSql = strSql & vbCrLf & "   AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
        strSql = strSql & vbCrLf & "   AND MODULE = '" & HttpContext.Current.Session("PROJECTNAME") & "'"
        strSql = strSql & vbCrLf & "   AND CHANNELCODE = '" & txtCHANNELCODE.Text & "'"

        Try
            DBManager.Open()
            txtCHANNELTAG.Text = DBManager.ExecuteScalar(CommandType.Text, strSql)
            If (txtCHANNELTAG.Text <> "EXPORT") Then
                txtEXCHANGERATE.Text = "1.00"
            End If
        Catch ex As Exception
            strMessage.Text = "Error occured while fetching details.." & vbCrLf & ex.Message.ToString
        Finally
            DBManager.Close()
            DBManager.Dispose()
            DBManager = Nothing
        End Try
    End Sub
    Private Sub txtSALEBILLNO_TextChanged(sender As Object, e As EventArgs) Handles txtSALEBILLNO.TextChanged
        Dim strSql As String
        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim dr As IDataReader

        If Len(Trim(txtSALEBILLNO.Text)) > 0 Then
            strSql = ""
            strSql = strSql & vbCrLf & "SELECT TO_CHAR(SALEBILLDATE,'DD/MM/YYYY') SALEBILLDATE,EXCISEINVNO,TO_CHAR(EXCISEINVDATE,'DD/MM/YYYY') EXCISEINVDATE"
            strSql = strSql & vbCrLf & "  FROM SALESBILLVIEW"
            strSql = strSql & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
            strSql = strSql & vbCrLf & "   AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
            strSql = strSql & vbCrLf & "   AND CHANNELCODE = '" & txtCHANNELCODE.Text & "'"
            strSql = strSql & vbCrLf & "   AND SALEBILLNO = '" & txtSALEBILLNO.Text & "'"

            Try
                DBManager.Open()
                dr = DBManager.ExecuteReader(CommandType.Text, strSql)
                While dr.Read()
                    Dim item As New ListItem()
                    If (dr("SALEBILLDATE").ToString().Length >= 10) Then
                        mskSALEBILLDATE.Text = dr("SALEBILLDATE").ToString()
                        ''mskSALEBILLDATE.Text = Format(CDate(dr("SALEBILLDATE").ToString()), "dd/MM/yyyy")
                    End If
                    txtREFEXCISEINVNO.Text = dr("EXCISEINVNO").ToString()
                    If (dr("EXCISEINVDATE").ToString().Length >= 10) Then
                        mskREFEXCISEINVDATE.Text = dr("EXCISEINVDATE").ToString()
                        '' mskREFEXCISEINVDATE.Text = Format(CDate(dr("EXCISEINVDATE").ToString()), "dd/MM/yyyy")
                    End If
                End While
                dr.Close()

                '------------- Filling Controls On Basis of Delivery Order
                Call prcFillProformaBasedMasterData()

                '------------- Filling Grid On Basis of Delivery Order
                If (Not ClientScript.IsStartupScriptRegistered("fetchgrid1")) Then
                    Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgrid1", "FetchGridData();", True)
                End If

                '------------- Filling Charge Grid
                If (Not ClientScript.IsStartupScriptRegistered("fetchgridCharge")) Then
                    Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgridCharge", "FetchChargeGridData();", True)
                End If

                mskDEBITCREDITNOTEDATE.Focus()
            Catch ex As Exception
                strMessage.Text = "Error occured while fetching details.." & vbCrLf & ex.Message.ToString
            Finally
                DBManager.Close()
                DBManager.Dispose()
                DBManager = Nothing
            End Try
        End If
    End Sub
    Private Sub txtREFEXCISEINVNO_TextChanged(sender As Object, e As EventArgs) Handles txtREFEXCISEINVNO.TextChanged
        Dim strSql As String
        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager

        If Len(Trim(txtREFEXCISEINVNO.Text)) > 0 Then
            strSql = ""
            strSql = strSql & vbCrLf & "SELECT TO_CHAR(EXCISEINVDATE,'DD/MM/YYYY') REFEXCISEINVDATE"
            strSql = strSql & vbCrLf & "  FROM SALESEXCISEINVOICEMASTER"
            strSql = strSql & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
            strSql = strSql & vbCrLf & "   AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
            strSql = strSql & vbCrLf & "   AND CHANNELCODE = '" & txtCHANNELCODE.Text & "'"
            strSql = strSql & vbCrLf & "   AND EXCISEINVNO = '" & txtREFEXCISEINVNO.Text & "'"

            Try
                DBManager.Open()
                mskREFEXCISEINVDATE.Text = DBManager.ExecuteScalar(CommandType.Text, strSql)

                If Len(mskREFEXCISEINVDATE.Text) > 10 Then
                    mskREFEXCISEINVDATE.Text = Format(CDate(mskREFEXCISEINVDATE.Text), "dd/MM/yyyy")
                End If

                '------------- Filling Controls On Basis of Delivery Order
                Call prcFillProformaBasedMasterData()

                '------------- Filling Grid On Basis of Delivery Order
                If (Not ClientScript.IsStartupScriptRegistered("fetchgrid1")) Then
                    Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgrid1", "FetchGridData();", True)
                End If

                '------------- Filling Charge Grid
                If (Not ClientScript.IsStartupScriptRegistered("fetchgridCharge")) Then
                    Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgridCharge", "FetchChargeGridData();", True)
                End If

                mskDEBITCREDITNOTEDATE.Focus()
            Catch ex As Exception
                strMessage.Text = "Error occured while fetching details.." & vbCrLf & ex.Message.ToString
            Finally
                DBManager.Close()
                DBManager.Dispose()
                DBManager = Nothing
            End Try
        End If
    End Sub

    Private Sub txtDEBITCREDITNOTENO_TextChanged(sender As Object, e As EventArgs) Handles txtDEBITCREDITNOTENO.TextChanged
        If Len(Trim(txtDEBITCREDITNOTENO.Text)) > 0 Then
            If txtOPTMODE.Text <> "A" Then
                Call getMasterDataByDRCRNo()

                If (Not ClientScript.IsStartupScriptRegistered("fetchgrid1")) Then
                    Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgrid1", "FetchGridData();", True)
                End If

                '------------- Filling Charge Grid
                If (Not ClientScript.IsStartupScriptRegistered("fetchgrid1")) Then
                    Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgridCharge", "FetchChargeGridData();", True)
                End If

                '''txtCHALLANNO.Text = txtDEBITCREDITNOTENO.Text
                mskDEBITCREDITNOTEDATE.Focus()
            End If
        End If
    End Sub

    Private Sub txtBUYERCODE_TextChanged(sender As Object, e As EventArgs) Handles txtBUYERCODE.TextChanged
        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim strSQL As String = ""
        Try
            DBManager.Open()
            txtBUYERNAME.Text = DBManager.ExecuteScalar(CommandType.Text, "SELECT PARTYNAME FROM PARTYMASTER WHERE COMPANYCODE = '" & txtCOMPCODE.Text & "' AND PARTYTYPE ='BUYER' AND PARTYCODE='" & txtBUYERCODE.Text & "'")

            '------------- Filling Grid On Basis of Sale Order
            If (Not ClientScript.IsStartupScriptRegistered("fetchgrid1")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgrid1", "FetchGridData();", True)
            End If

            '------------- Filling Charge Grid
            If (Not ClientScript.IsStartupScriptRegistered("fetchgrid1")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgridCharge", "FetchChargeGridData();", True)
            End If

            txtADDRESSCODE.Focus()
        Catch ex As Exception
            strMessage.Text = "Error occured while populating data..." & vbCrLf & ex.Message.ToString
        Finally
            DBManager.Close()
            DBManager.Dispose()
            DBManager = Nothing
        End Try
    End Sub

    Protected Sub txtADDRESSCODE_TextChanged(sender As Object, e As EventArgs) Handles txtADDRESSCODE.TextChanged
        Dim strSql As String
        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager

        Try
            strSql = ""
            strSql = strSql & vbCrLf & "SELECT ADDRESS"
            strSql = strSql & vbCrLf & "  FROM PARTYADDRESS"
            strSql = strSql & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
            strSql = strSql & vbCrLf & "   AND MODULE = '" & HttpContext.Current.Session("PROJECTNAME") & "'"
            strSql = strSql & vbCrLf & "   AND PARTYTYPE = 'BUYER'"
            strSql = strSql & vbCrLf & "   AND ADDRESSCODE = '" & txtADDRESSCODE.Text & "'"

            DBManager.Open()
            txtADDRESSDESC.Text = DBManager.ExecuteScalar(CommandType.Text, strSql)

            '------------- Filling Grid On Basis of Sale Order
            If (Not ClientScript.IsStartupScriptRegistered("fetchgrid1")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgrid1", "FetchGridData();", True)
            End If

            '------------- Filling Charge Grid
            If (Not ClientScript.IsStartupScriptRegistered("fetchgrid1")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgridCharge", "FetchChargeGridData();", True)
            End If

            txtVEHICLENO.Focus()
        Catch ex As Exception
            strMessage.Text = "Error occured while fetching details.." & vbCrLf & ex.Message.ToString
        Finally
            DBManager.Close()
            DBManager.Dispose()
            DBManager = Nothing
        End Try
    End Sub

    <WebMethod> _
    Public Shared Function GetWebData(strKey As String, strParam As String) As String
        Dim dd As New pgSalesDebitCreditNote_GST()
        Dim str As String = dd.WebDataFetch(strKey, strParam)
        Return str
    End Function

    <WebMethod> _
    Public Shared Function GetGridData(strProformaInvNo As String, strOperationMode As String, strChannelCode As String, strDebitCreditNoteNo As String) As String
        Dim dd As New pgSalesDebitCreditNote_GST()
        Dim str As String = dd.GetDataTableJson(dd.GridDataFetch(strProformaInvNo, strOperationMode, strChannelCode, strDebitCreditNoteNo))
        Return str
    End Function

    <WebMethod> _
    Public Shared Function GetChargeGridData(strOperationMode As String, strChannelCode As String, strDocumentno As String, strDocumentDate As String, strDocumentType As String) As String
        Dim dd As New pgSalesDebitCreditNote_GST()
        Dim str As String = dd.GetDataTableJson(dd.ChargeGridDataFetch(strOperationMode, strChannelCode, strDocumentno, strDocumentDate, strDocumentType))
        Return str
    End Function

    Protected Function GetDataTableJson(DTable As DataTable) As String
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

    Protected Function WebDataFetch(strKey As String, strParam As String) As String
        Dim strReturnVal As String = ""
        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim strSQL As String = ""
        Dim strArray() As String

        If strKey.Trim.Length = 0 Then
            strReturnVal = ""
            Return strReturnVal
            Exit Function
        End If

        strArray = Split(strKey, "~")

        Try
            DBManager.Open()
            Select Case strParam
                Case "CHANNEL"
                    strSQL = ""
                    strSQL = strSQL & vbCrLf & "SELECT DISTINCT CHANNELTAG"
                    strSQL = strSQL & vbCrLf & "  FROM CHANNELMASTER"
                    strSQL = strSQL & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
                    strSQL = strSQL & vbCrLf & "   AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
                    strSQL = strSQL & vbCrLf & "   AND MODULE = '" & HttpContext.Current.Session("PROJECTNAME") & "'"
                    strSQL = strSQL & vbCrLf & "   AND CHANNELCODE = '" & strKey & "'"

                    strReturnVal = DBManager.ExecuteScalar(CommandType.Text, strSQL)
                Case "ADDRESS"
                    strSQL = ""
                    strSQL = strSQL & vbCrLf & "SELECT ADDRESS"
                    strSQL = strSQL & vbCrLf & "  FROM PARTYADDRESS"
                    strSQL = strSQL & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
                    strSQL = strSQL & vbCrLf & "   AND MODULE = '" & HttpContext.Current.Session("PROJECTNAME") & "'"
                    strSQL = strSQL & vbCrLf & "   AND PARTYTYPE = 'BUYER'"
                    strSQL = strSQL & vbCrLf & "   AND ADDRESSCODE = '" & strArray(0) & "'"
                    strSQL = strSQL & vbCrLf & "   AND PARTYCODE = '" & strArray(1) & "'"

                    strReturnVal = DBManager.ExecuteScalar(CommandType.Text, strSQL)
                Case "TRANSPORTER"
                    strSQL = ""
                    strSQL = strSQL & vbCrLf & "SELECT PARTYNAME"
                    strSQL = strSQL & vbCrLf & "  FROM PARTYMASTER"
                    strSQL = strSQL & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
                    strSQL = strSQL & vbCrLf & "   AND MODULE = '" & HttpContext.Current.Session("PROJECTNAME") & "'"
                    strSQL = strSQL & vbCrLf & "   AND PARTYTYPE = 'TRANSPORTER'"
                    strSQL = strSQL & vbCrLf & "   AND PARTYCODE = '" & strArray(0) & "'"

                    strReturnVal = DBManager.ExecuteScalar(CommandType.Text, strSQL)
                Case "VESSEL"
                    strSQL = ""
                    strSQL = strSQL & vbCrLf & "SELECT TRANSPORTMODEDESC"
                    strSQL = strSQL & vbCrLf & "  FROM SALESMODEOFTRANSPORTMASTER"
                    strSQL = strSQL & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
                    strSQL = strSQL & vbCrLf & "   AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
                    strSQL = strSQL & vbCrLf & "   AND TRANSPORTMODECODE = '" & strArray(0) & "'"

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

    Protected Function GridDataFetch(strRefExciseInvNo As String, strOperationMode As String, strChannelCode As String, strDebitCreditNoteNo As String) As DataTable
        Dim dtGridData As New DataTable
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim strSQL As String

        ' ''If Len(Trim(strRefExciseInvNo)) = 0 Then
        ' ''    Return dtGridData
        ' ''    Exit Function
        ' ''End If


        strSQL = ""
        If strOperationMode = "A" Then
            strSQL = strSQL & vbCrLf & "SELECT 'NO' SELECTED, "
        Else
            strSQL = strSQL & vbCrLf & "SELECT 'YES' SELECTED, "
        End If
        strSQL = strSQL & vbCrLf & "        CHANNELCODE, EXCISEINVNO DEBITCREDITNOTENO, TO_CHAR(EXCISEINVDATE,'DD/MM/YYYY') DEBITCREDITNOTEDATE,"
        strSQL = strSQL & vbCrLf & "        BROKERCODE, BUYERCODE, TRANSPORTERCODE,"
        strSQL = strSQL & vbCrLf & "        NETAMONT, NETINDIANAMOUNT, GROSSAMOUNT,"
        strSQL = strSQL & vbCrLf & "        VESSELFLIGHTNO, DESTINATION, BOOKING,"
        strSQL = strSQL & vbCrLf & "        CONTAINERNO, CNOTENO, TO_CHAR(CNOTEDATE,'DD/MM/YYYY') CNOTEDATE,"
        strSQL = strSQL & vbCrLf & "        SEALNO, FORM1NO, RENO,"
        strSQL = strSQL & vbCrLf & "        TIMEOFPREPARATION, EXAPPLICABLE, EXFROM,"
        strSQL = strSQL & vbCrLf & "        EXTO, YEARCODE, COMPANYCODE,"
        strSQL = strSQL & vbCrLf & "        DIVISIONCODE, PROFORMAINVNO, TO_CHAR(PROFORMAINVDATE,'DD/MM/YYYY') PROFORMAINVDATE,"
        strSQL = strSQL & vbCrLf & "        SHIPPINGINSNO, TO_CHAR(SHIPPINGINSDATE,'DD/MM/YYYY') SHIPPINGINSDATE, SAUDANO,"
        strSQL = strSQL & vbCrLf & "        TO_CHAR(SAUDADATE,'DD/MM/YYYY') SAUDADATE, NOOFPACKINGUNIT, TOTALQUANTITY,"
        strSQL = strSQL & vbCrLf & "        TOTALWEIGHT, PACKSHEETWEIGHT, GROSSWEIGHT,"
        strSQL = strSQL & vbCrLf & "        EXPORTWEIGHT, CONTAINERSIZE, TOTALAMOUNT,"
        strSQL = strSQL & vbCrLf & "        TOTALINDIANAMOUNT, NOFROM, NOTO,"
        strSQL = strSQL & vbCrLf & "        SAUDASERIALNO, SHIPPINGSERIALNO, PROFORMASERIALNO,"
        strSQL = strSQL & vbCrLf & "        EXCISESERIALNO DEBITCREDITNOTESERIALNO, REMARKSPRO, REMARKS,"
        strSQL = strSQL & vbCrLf & "        ADDRESSCODE, ADDRESS, COUNTRYOFFINALDESTINATION,"
        strSQL = strSQL & vbCrLf & "        PRECARRIAGE, VESSELORFLIGHT, PORTOFDISCHARGE,"
        strSQL = strSQL & vbCrLf & "        PAYMENTCONDITION, PLACEOFRECEIPT, PORTOFLOADING,"
        strSQL = strSQL & vbCrLf & "        FINALDESTINATION, COUNTRYOFORIGIN, QUALITYCODE,"
        strSQL = strSQL & vbCrLf & "        QUALITYMANUALDESC, PACKINGCODE, PACKINGNAME,"
        strSQL = strSQL & vbCrLf & "        PACKINGSHORTNAME, PACKINGWEIGHT, PACKSTYLECODE,"
        strSQL = strSQL & vbCrLf & "        PACKSTYLENAME, UORCODE, UORNAME, NOCALCULATION,"
        strSQL = strSQL & vbCrLf & "        RATE, INDIANRATE, BUYERNAME, BROKERNAME,"
        strSQL = strSQL & vbCrLf & "        QUALITYTYPE, PACKINGQUANTITY, MEASURECODE,"
        strSQL = strSQL & vbCrLf & "        MEASURENAME, CURRENCYCODE, CURRENCYDESC,"
        strSQL = strSQL & vbCrLf & "        CONTRACTNO, TO_CHAR(CONTRACTDATE,'DD/MM/YYYY') CONTRACTDATE, UNITQUANTITY,"
        strSQL = strSQL & vbCrLf & "        VEHICLENO, TIMEOFISSUE, TO_CHAR(ISSUEDATE,'DD/MM/YYYY') ISSUEDATE,"
        strSQL = strSQL & vbCrLf & "        TO_CHAR(REMOVALDATE,'DD/MM/YYYY') REMOVALDATE, CHALLANNO, MARKS, SONO,"
        strSQL = strSQL & vbCrLf & "        TAREWEIGHT, CHANNELTAG, PROFORMAQUALITYMANUALDESC,"
        strSQL = strSQL & vbCrLf & "        TRADINGGPNO, TO_CHAR(TRADINGGPDATE,'DD/MM/YYYY') TRADINGGPDATE, TRADINGGPSERIALNO,"
        strSQL = strSQL & vbCrLf & "        DIRECTTRADING, PRICETYPE, TO_CHAR(BUYERORDERDATE,'DD/MM/YYYY') BUYERORDERDATE,"
        strSQL = strSQL & vbCrLf & "        BUYERORDERNO, OLDREFERENCENO, OUTSIDEGODOWN,"
        strSQL = strSQL & vbCrLf & "        CONTAINERTYPE, HBPWT, NETWEIGHT,"
        strSQL = strSQL & vbCrLf & "        CURRENCYSYMBOL, CURRENCYSIGN, AGAINSTEXCISEINVNO,TO_CHAR(AGAINSTEXCISEINVDATE,'DD/MM/YYYY') AGAINSTEXCISEINVDATE,"
        If strOperationMode = "A" Then
            strSQL = strSQL & vbCrLf & "         null SYSROWID, '" & HttpContext.Current.Session("USERNAME") & "' USERNAME,PADLOCKKEYNO,'' OPERATIONMODE "
            strSQL = strSQL & vbCrLf & "   FROM SALESEXCISEINVOICEVIEW"
            strSQL = strSQL & vbCrLf & "  WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
            strSQL = strSQL & vbCrLf & "    AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
            strSQL = strSQL & vbCrLf & "    AND EXCISEINVNO = '" & strRefExciseInvNo & "'"
        Else
            strSQL = strSQL & vbCrLf & "        SYSROWID, '" & HttpContext.Current.Session("USERNAME") & "' USERNAME,PADLOCKKEYNO,'' OPERATIONMODE "
            strSQL = strSQL & vbCrLf & "   FROM SALESEXCISEINVOICEVIEW"
            strSQL = strSQL & vbCrLf & "  WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
            strSQL = strSQL & vbCrLf & "    AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
            strSQL = strSQL & vbCrLf & "    AND EXCISEINVNO = '" & strDebitCreditNoteNo & "'"
        End If
      

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

    Protected Function ChargeGridDataFetch(strOperationMode As String, strChannelCode As String, strDocumentNo As String, strDocumentDate As String, strDocumentType As String) As DataTable
        Dim dtGridData As New DataTable
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim strSQL As String

        strSQL = ""
        If strOperationMode = "A" Then
            strSQL = strSQL & vbCrLf & "SELECT DECODE(B.DOCUMENTNO, NULL, 'NO', 'YES') SELECTED, A.CHARGECODE, A.CHARGENAME CHARGEDESC, A.CHARGENATURE,"
            strSQL = strSQL & vbCrLf & "       A.FORMULA, A.RATEPERUNIT RATE, A.ADDLESS, DECODE(A.ADDLESS, 'ADDITION', '+', '-') ADDLESSSIGN, 0 CHARGEAMOUNT,"
            strSQL = strSQL & vbCrLf & "       '" & HttpContext.Current.Session("COMPANYCODE") & "' COMPANYCODE, A.DIVISIONCODE, A.DIVISIONCODE DIVISIONCODEFOR, '" & HttpContext.Current.Session("YEARCODE") & "' YEARCODE, '" & strChannelCode & "' CHANNELCODE, '" & strDocumentNo & "' DOCUMENTNO, null DOCUMENTDATE,"
            strSQL = strSQL & vbCrLf & "        '" & strDocumentType & "' DOCUMENTTYPE, 0 ASSESSABLEAMOUNT, A.CHARGETYPE, null SYSROWID, '" & HttpContext.Current.Session("USERNAME") & "' USERNAME, '" & strOperationMode & "' OPERATIONMODE,"
            strSQL = strSQL & vbCrLf & "       B.UNIT, B.UORCODE, NVL(A.UNITQUANTITY,B.UNITQUANTITY) UNITQUANTITY"
        Else
            strSQL = strSQL & vbCrLf & "SELECT DECODE(B.DOCUMENTNO, NULL, 'NO', 'YES') SELECTED, A.CHARGECODE, A.CHARGENAME CHARGEDESC, A.CHARGENATURE,"
            strSQL = strSQL & vbCrLf & "       A.FORMULA, A.RATEPERUNIT RATE, A.ADDLESS, DECODE(A.ADDLESS, 'ADDITION', '+', '-') ADDLESSSIGN, B.CHARGEAMOUNT,"
            strSQL = strSQL & vbCrLf & "       '" & HttpContext.Current.Session("COMPANYCODE") & "' COMPANYCODE, A.DIVISIONCODE, A.DIVISIONCODE DIVISIONCODEFOR, '" & HttpContext.Current.Session("YEARCODE") & "' YEARCODE, '" & strChannelCode & "' CHANNELCODE, B.DOCUMENTNO, TO_CHAR(B.DOCUMENTDATE,'DD/MM/YYYY') DOCUMENTDATE,"
            strSQL = strSQL & vbCrLf & "        '" & strDocumenttype & "' DOCUMENTTYPE, ASSESSABLEAMOUNT, A.CHARGETYPE, B.SYSROWID, '" & HttpContext.Current.Session("USERNAME") & "' USERNAME, '" & strOperationMode & "' OPERATIONMODE,"
            strSQL = strSQL & vbCrLf & "       B.UNIT, B.UORCODE, NVL(A.UNITQUANTITY,B.UNITQUANTITY) UNITQUANTITY"
        End If
        strSQL = strSQL & vbCrLf & "  FROM CHARGEMASTER A, SALESCHARGEDETAILS B"
        strSQL = strSQL & vbCrLf & " WHERE A.COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
        strSQL = strSQL & vbCrLf & "   AND A.DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
        strSQL = strSQL & vbCrLf & "   AND A.MODULE = '" & HttpContext.Current.Session("PROJECTNAME") & "'"
        strSQL = strSQL & vbCrLf & "   AND A.CHANNELCODE = '" & strChannelCode & "'"
        strSQL = strSQL & vbCrLf & "   AND A.ACTIVE = 'Y'"
        'strSQL = strSQL & vbCrLf & "   AND A.CHARGENATURE<>'TCS'"
        If strOperationMode = "A" Then
            strSQL = strSQL & vbCrLf & "   AND B.DOCUMENTNO (+) ='" & strDocumentNo & "'"
            strSQL = strSQL & vbCrLf & "   AND B.DOCUMENTTYPE (+) = 'EXCISE INVOICE'"
        Else
            strSQL = strSQL & vbCrLf & "   AND B.DOCUMENTNO (+) ='" & strDocumentNo & "'"
            strSQL = strSQL & vbCrLf & "   AND B.DOCUMENTTYPE (+) = '" & strDocumentType & "'"
        End If
        strSQL = strSQL & vbCrLf & "   AND B.CHANNELCODE (+) = '" & strChannelCode & "'"
        strSQL = strSQL & vbCrLf & "   AND A.COMPANYCODE = B.COMPANYCODE (+)"
        strSQL = strSQL & vbCrLf & "   AND A.DIVISIONCODE = B.DIVISIONCODE (+)"
        '''strSQL = strSQL & vbCrLf & "   AND A.YEARCODE = B.YEARCODE (+)"
        strSQL = strSQL & vbCrLf & "   AND A.CHANNELCODE = B.CHANNELCODE (+)"
        strSQL = strSQL & vbCrLf & "   AND A.CHARGECODE = B.CHARGECODE (+)"
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

    Private Sub prcFillProformaBasedMasterData()
        Dim strSql As String
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim dtRetVal As New DataTable

        Try
            strSql = ""
            strSql = strSql & vbCrLf & " SELECT DISTINCT A.BROKERCODE, A.BROKERNAME, A.BUYERCODE, A.BUYERNAME, A.ADDRESSCODE, A.ADDRESS, "
            strSql = strSql & vbCrLf & "  A.ADDRESSCODEBILL, A.BILLSTATECODE,B.STATENAME, A.BILLEXCHANGERATE "
            strSql = strSql & vbCrLf & "  FROM SALESEXCISEINVOICEVIEW A, GSTSTATEMASTER B "
            strSql = strSql & vbCrLf & " WHERE A.COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "' "
            strSql = strSql & vbCrLf & "   AND A.DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "' "
            strSql = strSql & vbCrLf & "   AND A.CHANNELCODE = '" & txtCHANNELCODE.Text & "' "
            strSql = strSql & vbCrLf & "   AND A.EXCISEINVNO = '" & txtREFEXCISEINVNO.Text & "' "
            strSql = strSql & vbCrLf & "   AND A.BILLSTATECODE=B.GSTSTATECODE(+) "
            dbManager.Open()
            dtRetVal = dbManager.ExecuteDataTable(CommandType.Text, strSql)

            If Len(Trim(dtRetVal.Rows(0).Item("BROKERCODE").ToString)) > 0 Then
                txtBROKERCODE.Text = dtRetVal.Rows(0).Item("BROKERCODE")
            End If
            If Len(Trim(dtRetVal.Rows(0).Item("BROKERNAME").ToString)) > 0 Then
                txtBROKERNAME.Text = dtRetVal.Rows(0).Item("BROKERNAME")
            End If
            If Len(Trim(dtRetVal.Rows(0).Item("BUYERCODE").ToString)) > 0 Then
                txtBUYERCODE.Text = dtRetVal.Rows(0).Item("BUYERCODE")
            End If
            If Len(Trim(dtRetVal.Rows(0).Item("BUYERNAME").ToString)) > 0 Then
                txtBUYERNAME.Text = dtRetVal.Rows(0).Item("BUYERNAME")
            End If
            If Len(Trim(dtRetVal.Rows(0).Item("ADDRESSCODE").ToString)) > 0 Then
                txtADDRESSCODE.Text = dtRetVal.Rows(0).Item("ADDRESSCODE")
            End If
            If Len(Trim(dtRetVal.Rows(0).Item("ADDRESS").ToString)) > 0 Then
                txtADDRESSDESC.Text = dtRetVal.Rows(0).Item("ADDRESS")
            End If

            If Len(Trim(dtRetVal.Rows(0).Item("ADDRESSCODEBILL").ToString)) > 0 Then
                txtADDRESSCODEBILL.Text = dtRetVal.Rows(0).Item("ADDRESSCODEBILL")
            End If
            If Len(Trim(dtRetVal.Rows(0).Item("ADDRESS").ToString)) > 0 Then
                txtADDRESSDESCBILL.Text = dtRetVal.Rows(0).Item("ADDRESS")
            End If

            If Len(Trim(dtRetVal.Rows(0).Item("BILLSTATECODE").ToString)) > 0 Then
                txtBILLSTATECODE.Text = dtRetVal.Rows(0).Item("BILLSTATECODE")
            End If

            If Len(Trim(dtRetVal.Rows(0).Item("STATENAME").ToString)) > 0 Then
                txtBILLSTATEDESC.Text = dtRetVal.Rows(0).Item("STATENAME")
            End If

            If Len(Trim(dtRetVal.Rows(0).Item("BILLEXCHANGERATE").ToString)) > 0 Then
                txtEXCHRATE.Text = dtRetVal.Rows(0).Item("BILLEXCHANGERATE")
            End If

        Catch ex As Exception
            strMessage.Text = "Error occured while fetching details.." & vbCrLf & ex.Message.ToString
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
    End Sub

    <WebMethod> _
    Public Shared Function fnSalesAllSolution(rWeight As Double, rPackWeight As Double, rTotalQty As Double, rAmount As Double, _
                                              rINAmount As Double, rNoFrom As Double, rNoTo As Double, vQualityCode As String, _
                                              vPackingCode As String, vPackSheetWeight As Double, vUORCode As String, vRate As Double, _
                                              vINRate As Double, vNoOfPackingUnit As Double, vNoCalculation As Double, _
                                              oErrHndlNoOfPacking As Boolean, strChannelTag As String, vTotalQuantity As Double, vExchangeRate As Double) As String


        Dim dblPackingQuantity As Double
        Dim dblUnitQuantity As Double
        Dim dblContractWeight As Double
        Dim dblPackSheetQtyForPAckingCode As Double
        Dim strMeasureName As String
        Dim strWhichField As String
        Dim strSql As String
        Dim strReturnString As String
        Dim dblGmsToMt As Double
        Dim dblRateInMT As Double
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim dtRetVal As New DataTable
        Dim dblYARDSTOMETER As Double
        Dim dblMETERTOYARDS As Double
        Dim dblTAREWEIGHT As Double
        Dim dblPACKSHEETWEIGHTQUALITY As Double
        Dim strUORMeasureName As String = "'"
        Dim strQUALITYTYPE As String = ""
        Try
            'Initializing Grams to M.T
            dblGmsToMt = 1000000

            'START - Getting Packing Inf.
            strSql = ""
            strSql = strSql & vbCrLf & "SELECT NVL(A.PACKINGQUANTITY,0) PACKINGQUANTITY, B.MEASUREUNIT, NVL(A.PACKINGWEIGHT,0) PACKINGWEIGHT"
            strSql = strSql & vbCrLf & " FROM SALESPACKINGMASTER A, SALESMEASUREMASTER B"
            strSql = strSql & vbCrLf & "WHERE A.CompanyCode = B.CompanyCode"
            strSql = strSql & vbCrLf & "  AND A.MEASURECODE = B.MEASURECODE"
            strSql = strSql & vbCrLf & "  AND A.COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
            strSql = strSql & vbCrLf & "  AND A.PACKINGCODE = '" & vPackingCode & "'"

            dblPackSheetQtyForPAckingCode = 0

            dblYARDSTOMETER = (914.4 / 1000)
            dblMETERTOYARDS = (1000 / 914.4)

            dbManager.Open()
            dtRetVal = dbManager.ExecuteDataTable(CommandType.Text, strSql)

            dblPackingQuantity = Val(dtRetVal.Rows(0).Item("PACKINGQUANTITY"))
            strMeasureName = dtRetVal.Rows(0).Item("MEASUREUNIT") & ""
            dblPackSheetQtyForPAckingCode = Val(dtRetVal.Rows(0).Item("PACKINGWEIGHT"))

            dtRetVal.Clear()
            dbManager.Close()
            'END - Getting Packing Inf.

            'START - Getting UOR Inf.
            strSql = ""
            strSql = strSql & vbCrLf & "SELECT NVL(UNITQUANTITY,0) UNITQUANTITY, MEASURENAME, WHICHFIELD, M.MEASUREUNIT "
            strSql = strSql & vbCrLf & "FROM SALESUORMASTER U, SALESMEASUREMASTER M"
            strSql = strSql & vbCrLf & "WHERE U.COMPANYCODE = M.COMPANYCODE"
            strSql = strSql & vbCrLf & "  AND U.MEASURECODE = M.MEASURECODE"
            strSql = strSql & vbCrLf & "  AND U.COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
            strSql = strSql & vbCrLf & "  AND U.UORCODE = '" & vUORCode & "'"

            dbManager.Open()
            dtRetVal = dbManager.ExecuteDataTable(CommandType.Text, strSql)

            dblUnitQuantity = Val(dtRetVal.Rows(0).Item("UNITQUANTITY"))
            strWhichField = dtRetVal.Rows(0).Item("WHICHFIELD")
            strUORMeasureName = dtRetVal.Rows(0).Item("MEASUREUNIT") & ""

            If (strMeasureName = "YARDS" Or strMeasureName = "YARD") And (strUORMeasureName = "METERS" Or strUORMeasureName = "METERS") Then
                dblPackingQuantity = dblPackingQuantity * dblYARDSTOMETER
            ElseIf (strMeasureName = "METERS" Or strMeasureName = "METER") And (strUORMeasureName = "YARDS" Or strUORMeasureName = "YARD") Then
                dblPackingQuantity = dblPackingQuantity * dblMETERTOYARDS
            End If

            dtRetVal.Clear()
            dbManager.Close()
            'END - Getting UOR Inf.

            'START - Getting Quality Inf.
            strSql = ""
            strSql = strSql & vbCr & "SELECT NVL(CONTRACTWEIGHT, 0) CONTRACTWEIGHT, NVL(CONTRACTWEIGHT_YARD, 0) CONTRACTWEIGHT_YARD, NVL(PACKSHEETWEIGHT,0) PACKSHEETWEIGHT, NVL(TAREWEIGHT,0) TAREWEIGHT, QUALITYTYPE"
            strSql = strSql & vbCr & "  FROM SALESQUALITYMASTER"
            strSql = strSql & vbCr & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
            strSql = strSql & vbCr & "   AND QUALITYCODE = '" & vQualityCode & "'"

            dbManager.Open()
            dtRetVal = dbManager.ExecuteDataTable(CommandType.Text, strSql)

            strQUALITYTYPE = dtRetVal.Rows(0).Item("QUALITYTYPE") & ""

            If strMeasureName = "YARDS" Or strMeasureName = "YARD" Then
                dblContractWeight = Val(dtRetVal.Rows(0).Item("CONTRACTWEIGHT_YARD"))
            Else
                If strWhichField = "TOTAL WEIGHT" Then
                    If strChannelTag = "EXPORT" Then
                        If Val(dtRetVal.Rows(0).Item("CONTRACTWEIGHT")) = 0 Then
                            dblContractWeight = dblGmsToMt
                        Else
                            dblContractWeight = Val(dtRetVal.Rows(0).Item("CONTRACTWEIGHT"))
                        End If
                    Else
                        dblContractWeight = Val(dtRetVal.Rows(0).Item("CONTRACTWEIGHT"))
                    End If
                Else
                    dblContractWeight = Val(dtRetVal.Rows(0).Item("CONTRACTWEIGHT"))
                End If
            End If
            '----------Pick up Tare parameters from Quality master
            dblTAREWEIGHT = Val(dtRetVal.Rows(0).Item("TAREWEIGHT"))
            dblPACKSHEETWEIGHTQUALITY = Val(dtRetVal.Rows(0).Item("PACKSHEETWEIGHT"))

            dbManager.Close()
            dtRetVal.Clear()
            'END - Getting Quality Inf.

            '------------ Start Calculating Export/Domestic Details

            'If UCase(strChannelTag) = "EXPORT" Then
            '    vINRate = Format(vRate * vExchangeRate, "#0.00")
            'Else
            '    vINRate = Format(vRate, "#0.00")
            'End If
            '------------ End Calculating Indian Details

            If vTotalQuantity <> -1 Then
                rTotalQty = vTotalQuantity
            Else
                rTotalQty = vNoOfPackingUnit * dblPackingQuantity
            End If
            rWeight = Val(Format(rTotalQty * dblContractWeight / dblGmsToMt, "0.0000"))
            '--------TARE WEIGHT CALCULATION
            rPackWeight = Format(rWeight * Val(dblPackSheetQtyForPAckingCode), "0.000")

            If (dblTAREWEIGHT + dblPACKSHEETWEIGHTQUALITY) <> 0 Then
                rPackWeight = dblTAREWEIGHT + dblPACKSHEETWEIGHTQUALITY
                rPackWeight = Format((Val(vNoOfPackingUnit) * Val(rPackWeight)) / 1000, "0.000")
            End If

            If strWhichField = "TOTAL WEIGHT" Then
                rAmount = Val(Format(rWeight * vRate / dblUnitQuantity, "0.00"))
                rINAmount = Val(Format(rWeight * vINRate / dblUnitQuantity, "0.00"))
            Else
                rAmount = Val(Format(rTotalQty * vRate / dblUnitQuantity, "0.00"))
                rINAmount = Val(Format(rTotalQty * vINRate / dblUnitQuantity, "0.00"))
            End If

            '------------ Start Calculating Rate in MT
            dblRateInMT = 0

            strSql = ""
            strSql = strSql & vbCrLf & "SELECT MEASUREUNIT"
            strSql = strSql & vbCrLf & "  FROM SALESMEASUREMASTER"
            strSql = strSql & vbCrLf & " WHERE MEASURECODE IN"
            strSql = strSql & vbCrLf & "                     ("
            strSql = strSql & vbCrLf & "                        SELECT MEASURECODE"
            strSql = strSql & vbCrLf & "                          FROM SALESUORMASTER"
            strSql = strSql & vbCrLf & "                          WHERE UORCODE= '" & vUORCode & "'"
            strSql = strSql & vbCrLf & "                     )"

            dbManager.Open()
            If dbManager.ExecuteScalar(CommandType.Text, strSql) & "" = "YARD" Or dbManager.ExecuteScalar(CommandType.Text, strSql) & "" = "YARDS" Then
                strSql = "SELECT CONTRACTWEIGHT_YARD AS CONTRACTWEIGHT,CONTRACTWEIGHTUNIT_YARD AS CONTRACTWEIGHTUNIT FROM SALESQUALITYMASTER where QUALITYCODE='" & vQualityCode & "'"
            Else
                strSql = "SELECT CONTRACTWEIGHT,CONTRACTWEIGHTUNIT FROM SALESQUALITYMASTER where QUALITYCODE='" & vQualityCode & "'"
            End If

            dbManager.Close()

            dbManager.Open()
            dtRetVal = dbManager.ExecuteDataTable(CommandType.Text, strSql)

            dbManager.Close()

            If dtRetVal.Rows(0).Item("CONTRACTWEIGHTUNIT") & "" = "GMS" Then
                dbManager.Open()
                strSql = "SELECT MEASURECODE FROM SALESUORMASTER WHERE UORCODE='" & vUORCode & "'"

                If dbManager.ExecuteScalar(CommandType.Text, strSql) = "MT" Then
                    dbManager.Close()
                    dblRateInMT = vRate
                ElseIf dbManager.ExecuteScalar(CommandType.Text, strSql) = "KGS" Then
                    dbManager.Close()

                    dbManager.Open()
                    strSql = dbManager.ExecuteScalar(CommandType.Text, "SELECT UNITQUANTITY FROM  SALESUORMASTER WHERE UORCODE='" & vUORCode & "'")

                    dblRateInMT = (Val(vRate) * 1000000) / (1000 * Val(strSql))
                    dbManager.Close()
                Else
                    dbManager.Close()

                    dbManager.Open()
                    strSql = dbManager.ExecuteScalar(CommandType.Text, "SELECT UNITQUANTITY FROM  SALESUORMASTER WHERE UORCODE='" & vUORCode & "'")

                    dblRateInMT = (Val(vRate) * 1000000) / (dtRetVal.Rows(0).Item("CONTRACTWEIGHT") * Val(strSql))
                    dbManager.Close()
                End If
            Else
                dbManager.Open()
                strSql = dbManager.ExecuteScalar(CommandType.Text, "SELECT UNITQUANTITY FROM  SALESUORMASTER WHERE UORCODE='" & vUORCode & "'")
                dbManager.Close()

                dbManager.Open()
                If dbManager.ExecuteScalar(CommandType.Text, "SELECT MEASURECODE FROM  SALESUORMASTER WHERE UORCODE='" & vUORCode & "'") = "KGS" Then
                    dblRateInMT = (Val(vRate) * 1000000) / (1000 * Val(strSql))
                Else
                    dblRateInMT = Val(vRate)
                End If
                dbManager.Close()
            End If
            '------------ End Calculating Rate in MT

            If strQUALITYTYPE <> "YARN" Then
                strWhichField = "TOTAL QUANTITY"
            End If
            strReturnString = rWeight & "~" & rPackWeight & "~" & rTotalQty & "~" & rAmount & "~" & rINAmount & "~" & rNoFrom & "~" & rNoTo & "~" & vQualityCode & "~" _
                              & vPackingCode & "~" & vPackSheetWeight & "~" & vUORCode & "~" & vRate & "~" & vINRate & "~" & vNoOfPackingUnit & "~" & vNoCalculation & "~" _
                              & oErrHndlNoOfPacking & "~" & strChannelTag & "~" & vTotalQuantity & "~" & Format(dblRateInMT, "#0.00") & "~" & strWhichField
            Return strReturnString
        Catch ex As Exception
            Return "~Error in Sales All Solution"
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
    End Function

    '<WebMethod> _
    'Public Shared Function fnMeasurementInfo(strUORCode As String)
    '    Dim strSql As String
    '    Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
    '    Dim dtRetVal As New DataTable
    '    Dim strRetVal As String

    '    Try
    '        dbManager.Open()
    '        strSql = ""
    '        strSql = strSql & vbCrLf & "SELECT UNITQUANTITY, WHICHFIELD"
    '        strSql = strSql & vbCrLf & "  FROM SALESUORMASTER U, SALESMEASUREMASTER M"
    '        strSql = strSql & vbCrLf & " WHERE U.COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
    '        strSql = strSql & vbCrLf & "   AND U.DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
    '        strSql = strSql & vbCrLf & "   AND U.COMPANYCODE = M.COMPANYCODE"
    '        strSql = strSql & vbCrLf & "   AND U.DIVISIONCODE = M.DIVISIONCODE"
    '        strSql = strSql & vbCrLf & "   AND U.MEASURECODE = M.MEASURECODE"
    '        strSql = strSql & vbCrLf & "   AND U.UORCODE = '" & strUORCode & "'"

    '        dtRetVal = dbManager.ExecuteDataTable(CommandType.Text, strSql)



    '        strRetVal = Val(dtRetVal.Rows(0).Item("UNITQUANTITY")) & "~" & dtRetVal.Rows(0).Item("WHICHFIELD")
    '        Return strRetVal
    '    Catch ex As Exception
    '        Return "~Error in Sales Measurement Info"
    '    Finally
    '        dbManager.Close()
    '        dbManager.Dispose()
    '        dbManager = Nothing
    '    End Try
    'End Function

    <WebMethod> _
    Public Shared Function fnMeasurementInfo(strUORCode As String, strQualitycode As String, strPackingCode As String)
        Dim strSql As String
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim dtRetVal As New DataTable
        Dim strRetVal As String
        Dim strQUALITYTYPE As String = ""

        Try

            dbManager.Open()
            strSql = ""
            strSql = strSql & vbCrLf & "SELECT QUALITYTYPE"
            strSql = strSql & vbCrLf & "FROM SALESQUALITYMASTER"
            strSql = strSql & vbCrLf & "WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
            strSql = strSql & vbCrLf & "  AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
            strSql = strSql & vbCrLf & "  AND QUALITYCODE = '" & strQualitycode & "'"
            strQUALITYTYPE = dbManager.ExecuteScalar(CommandType.Text, strSql)
            dbManager.Close()


            dbManager.Open()
            strSql = ""
            strSql = strSql & vbCrLf & "SELECT UNITQUANTITY, WHICHFIELD, NVL(M.MEASUREUNIT,'KGS') MEASUREUNIT"
            strSql = strSql & vbCrLf & "  FROM SALESUORMASTER U, SALESMEASUREMASTER M"
            strSql = strSql & vbCrLf & " WHERE U.COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
            strSql = strSql & vbCrLf & "   AND U.DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
            strSql = strSql & vbCrLf & "   AND U.COMPANYCODE = M.COMPANYCODE"
            strSql = strSql & vbCrLf & "   AND U.DIVISIONCODE = M.DIVISIONCODE"
            strSql = strSql & vbCrLf & "   AND U.MEASURECODE = M.MEASURECODE"
            strSql = strSql & vbCrLf & "   AND U.UORCODE = '" & strUORCode & "'"

            dtRetVal = dbManager.ExecuteDataTable(CommandType.Text, strSql)

            strSql = ""
            strSql = strSql & vbCrLf & "SELECT NVL(B.MEASUREUNIT,'KGS') MEASUREUNIT"
            strSql = strSql & vbCrLf & "  FROM SALESPACKINGMASTER A, SALESMEASUREMASTER B"
            strSql = strSql & vbCrLf & " WHERE A.COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
            strSql = strSql & vbCrLf & "   AND A.DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
            strSql = strSql & vbCrLf & "   AND A.PACKINGCODE = '" & strPackingCode & "'"
            strSql = strSql & vbCrLf & "   AND A.COMPANYCODE = B.COMPANYCODE"
            strSql = strSql & vbCrLf & "   AND A.DIVISIONCODE = B.DIVISIONCODE"
            strSql = strSql & vbCrLf & "   AND A.MEASURECODE = B.MEASURECODE"
            Dim strPACKINGMEASUREUNIT As String = dbManager.ExecuteScalar(CommandType.Text, strSql)

            ' ''If strQUALITYTYPE <> "YARN" Then
            ' ''    strRetVal = Val(dtRetVal.Rows(0).Item("UNITQUANTITY")) & "~" & "TOTAL QUANTITY"
            ' ''Else
            ' ''    strRetVal = Val(dtRetVal.Rows(0).Item("UNITQUANTITY")) & "~" & dtRetVal.Rows(0).Item("WHICHFIELD")
            ' ''End If

            strRetVal = Val(dtRetVal.Rows(0).Item("UNITQUANTITY")) & "~" & dtRetVal.Rows(0).Item("WHICHFIELD") & "~" & dtRetVal.Rows(0).Item("MEASUREUNIT") & "~" & strPACKINGMEASUREUNIT
            Return strRetVal
        Catch ex As Exception
            Return "~Error in Sales Measurement Info"
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
    End Function

    <WebMethod> _
    Public Shared Function prcChargeDetails(strChargeGridData As String, strTotalNetQuantity As String, strTotalNetAmount As String, strTotalNetWeight As String, strTotalNoofPacking As String) As String
        Dim dtCharge As New DataTable
        Dim DG As New pgSalesDebitCreditNote_GST()

        Try
            dtCharge = DG.ConvertChargeJSONToDataTable(strChargeGridData, "CHARGECODE")
            Dim sender As New Object
            Dim e As New System.EventArgs
            dtCharge.TableName = "ChargeTable"

            With dtCharge
                For iRow = 0 To .Rows.Count - 1
                    Call DG.fnCalculateCharge(iRow, dtCharge, strTotalNetQuantity, strTotalNetAmount, strTotalNetWeight, strTotalNoofPacking)
                Next
            End With
        Catch ex As Exception
            Return "~Error in Charge"
        End Try

        Return DG.GetDataTableJson(dtCharge)
    End Function

    Public Function fnCalculateCharge(iRowNo As Long, ByRef dtCharge As DataTable, strTotalNetQuantity As String, strTotalNetAmount As String, strTotalNetWeight As String, strTotalNoofPacking As String) As DataTable
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
                    strCalculated = strCalculated & ";" & .Rows(iRow).Item("CHARGECODE") & "=" & Val(Trim(.Rows(iRow).Item("CHARGEAMOUNT")))
                ElseIf .Rows(iRow).Item("SELECTED") = "YES" Then
                    If .Rows(iRow).Item("CHARGENATURE") = "FIXED" Then
                        strCalculated = strCalculated & ";" & .Rows(iRow).Item("CHARGECODE") & "=" & Val(Trim(.Rows(iRow).Item("CHARGEAMOUNT")))
                    ElseIf .Rows(iRow).Item("CHARGENATURE") = "QUANTATIVE" Then
                        .Rows(iRow).Item("CHARGEAMOUNT") = Format((Val(strTotalNetQuantity) * Val(.Rows(iRow).Item("RATE"))) / Val(.Rows(iRow).Item("UNITQUANTITY")), "0.00")
                    ElseIf .Rows(iRow).Item("CHARGENATURE") = "WEIGHTED" Then
                        .Rows(iRow).Item("CHARGEAMOUNT") = Format((Val(strTotalNetWeight) * Val(.Rows(iRow).Item("RATE"))) / Val(.Rows(iRow).Item("UNITQUANTITY")), "0.00")
                    ElseIf .Rows(iRow).Item("CHARGENATURE") = "NO OF PACKING" Then
                        .Rows(iRow).Item("CHARGEAMOUNT") = Format((Val(strTotalNoofPacking) * Val(.Rows(iRow).Item("RATE"))) / Val(.Rows(iRow).Item("UNITQUANTITY")), "0.00")
                    Else
                        .Rows(iRow).Item("CHARGEAMOUNT") = Format(fnProcessFormula(Trim(.Rows(iRow).Item("CHANNELCODE")), .Rows(iRow).Item("CHARGECODE"), strFORMULA, , strCalculated & IIf(Len(strCalculated) > 0, ";", "") & "RATE=" & Val(.Rows(iRow).Item("RATE"))), "0.00")

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

    Private Sub txtBROKERCODE_TextChanged(sender As Object, e As EventArgs) Handles txtBROKERCODE.TextChanged
        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim strSQL As String = ""
        Try
            DBManager.Open()
            txtBROKERNAME.Text = DBManager.ExecuteScalar(CommandType.Text, "SELECT PARTYNAME FROM PARTYMASTER WHERE COMPANYCODE = '" & txtCOMPCODE.Text & "' AND PARTYTYPE ='BROKER' AND PARTYCODE='" & txtBROKERCODE.Text & "'")

            '------------- Filling Grid On Basis of Delivery Order
            If (Not ClientScript.IsStartupScriptRegistered("fetchgrid1")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgrid1", "FetchGridData();", True)
            End If

            '------------- Filling Charge Grid
            If (Not ClientScript.IsStartupScriptRegistered("fetchgrid1")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchgridCharge", "FetchChargeGridData();", True)
            End If

            txtBUYERCODE.Focus()
        Catch ex As Exception
            strMessage.Text = "Error occured while populating data..." & vbCrLf & ex.Message.ToString
        Finally
            DBManager.Close()
            DBManager.Dispose()
            DBManager = Nothing
        End Try
    End Sub

    Private Sub txtVESSELFLIGHTNO_TextChanged(sender As Object, e As EventArgs) Handles txtVESSELFLIGHTNO.TextChanged
        Dim strSql As String
        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager

        Try
            strSql = ""
            strSql = strSql & vbCrLf & "SELECT TRANSPORTMODEDESC"
            strSql = strSql & vbCrLf & "  FROM SALESMODEOFTRANSPORTMASTER"
            strSql = strSql & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
            strSql = strSql & vbCrLf & "   AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
            strSql = strSql & vbCrLf & "   AND TRANSPORTMODECODE = '" & txtVESSELFLIGHTNO.Text & "'"

            DBManager.Open()
            txtVESSELFLIGHTDESC.Text = DBManager.ExecuteScalar(CommandType.Text, strSql)

            '------------- Filling Grid On Basis of Delivery Order
            If (Not ClientScript.IsStartupScriptRegistered("fetchExistingDetails")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchExistingDetails", "fnFetchExistingDetailsGridData();", True)
            End If

            '------------- Filling Charge Grid
            If (Not ClientScript.IsStartupScriptRegistered("fetchExistingCharge")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchExistingCharge", "fnFetchExistingChargeGridData();", True)
            End If

            txtCONTAINERTYPE.Focus()
        Catch ex As Exception
            strMessage.Text = "Error occured while populating data..." & vbCrLf & ex.Message.ToString
        Finally
            DBManager.Close()
            DBManager.Dispose()
            DBManager = Nothing
        End Try
    End Sub

    Private Sub txtTRANSPORTERCODE_TextChanged(sender As Object, e As EventArgs) Handles txtTRANSPORTERCODE.TextChanged
        Dim strSql As String
        Dim DBManager As SW_DBObject.DBManager = New SW_DBObject.DBManager

        Try
            strSql = ""
            strSql = strSql & vbCrLf & "SELECT PARTYNAME"
            strSql = strSql & vbCrLf & "  FROM PARTYMASTER"
            strSql = strSql & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
            strSql = strSql & vbCrLf & "   AND MODULE = '" & HttpContext.Current.Session("PROJECTNAME") & "'"
            strSql = strSql & vbCrLf & "   AND PARTYTYPE = 'TRANSPORTER'"
            strSql = strSql & vbCrLf & "   AND PARTYCODE = '" & txtTRANSPORTERCODE.Text & "'"

            DBManager.Open()
            txtTRANSPORTERDESC.Text = DBManager.ExecuteScalar(CommandType.Text, strSql)

            '------------- Filling Grid On Basis of Delivery Order
            If (Not ClientScript.IsStartupScriptRegistered("fetchExistingDetails")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchExistingDetails", "fnFetchExistingDetailsGridData();", True)
            End If

            '------------- Filling Charge Grid
            If (Not ClientScript.IsStartupScriptRegistered("fetchExistingCharge")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchExistingCharge", "fnFetchExistingChargeGridData();", True)
            End If

            txtDESTINATION.Focus()
        Catch ex As Exception
            strMessage.Text = "Error occured while populating data..." & vbCrLf & ex.Message.ToString
        Finally
            DBManager.Close()
            DBManager.Dispose()
            DBManager = Nothing
        End Try
    End Sub

    Protected Sub txtDESTINATION_TextChanged(sender As Object, e As EventArgs) Handles txtDESTINATION.TextChanged
        '------------- Filling Grid On Basis of Delivery Order
        If (Not ClientScript.IsStartupScriptRegistered("fetchExistingDetails")) Then
            Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchExistingDetails", "fnFetchExistingDetailsGridData();", True)
        End If

        '------------- Filling Charge Grid
        If (Not ClientScript.IsStartupScriptRegistered("fetchExistingCharge")) Then
            Page.ClientScript.RegisterStartupScript(Me.GetType(), "fetchExistingCharge", "fnFetchExistingChargeGridData();", True)
        End If

        txtCNOTENO.Focus()
    End Sub

    Public Function ValidatePage() As Boolean
        Dim blnReturnValidate As Boolean = True

        Return blnReturnValidate
    End Function
End Class