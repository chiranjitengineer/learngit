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
Public Class AcPaymentAdvanceDirect
    Inherits System.Web.UI.Page

    Dim strMessage As Label
    Dim btnSubmit As Button
    Dim strOptType As String
    Dim tempActivity As TextBox
    Dim txtMasterTableName As TextBox
    Dim txtSyncActualTable As TextBox
    Dim txtADDEDIT As TextBox
    Dim txtDETAILSTABLENAME As TextBox
    Dim strMENUTAG As TextBox
    Dim strMENUTAG1 As TextBox
    Dim strMENUTAG2 As TextBox

    Dim strSQL As String = ""
    Dim dtTmpVoucher As New DataTable
    Dim dtTempAdjBill As New DataTable
    Dim dtTempCostCentre As New DataTable
    Dim dtTempTDS As New DataTable
    Dim dtTempLiabilityDtls As New DataTable
    Dim txtPageValidatePassed As TextBox
    Dim btnMasterSubmit As Button

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '-- START -- FOLLOWINGS ARE MANDATORY FOR MASTER PAGE     
        Dim ddOperationType As DropDownList = DirectCast(Master.FindControl("ddChooseOperation"), DropDownList)
        strMessage = DirectCast(Master.FindControl("lblMasterMessage"), Label)
        tempActivity = DirectCast(Master.FindControl("txtOPERATIONMODE"), TextBox)
        txtMasterTableName = DirectCast(Master.FindControl("txtMASTERTABLENAME"), TextBox)
        txtDETAILSTABLENAME = DirectCast(Master.FindControl("txtDETAILSTABLENAME"), TextBox)
        txtSyncActualTable = DirectCast(Master.FindControl("txtSYNCACTUALTABLE"), TextBox)
        txtADDEDIT = DirectCast(Master.FindControl("txtADDEDIT"), TextBox)
        'txtPageValidatePassed = DirectCast(Master.FindControl("txtPageValidatePassed"), TextBox)
        btnMasterSubmit = DirectCast(Master.FindControl("btnSubmit"), Button)

        strMENUTAG1 = DirectCast(Master.FindControl("txtMENUTAG1"), TextBox) ''//Memorandum/pass

        If Not ddOperationType Is Nothing Then
            Dim strVal As String
            strVal = IIf(ddOperationType.SelectedValue = "ADD", "A", IIf(ddOperationType.SelectedValue = "EDIT", "M", IIf(ddOperationType.SelectedValue = "DELETE", "D", IIf(ddOperationType.SelectedValue = "VIEW", "V", IIf(ddOperationType.SelectedValue = "PRINT", "P", "")))))
            txtOPTMODE.Text = strVal
        End If

        txtSYSTEMVOUCHERNO.Attributes.Add("readonly", "readonly")
        txtCASHBANKAC.Attributes.Add("readonly", "readonly")
        txtAMOUNT.Attributes.Add("readonly", "readonly")
        txtTOTALTDSON.Attributes.Add("readonly", "readonly")
        txtTOTALTDSAMOUNT.Attributes.Add("readonly", "readonly")
        '-- END   -- FOLLOWINGS ARE MANDATORY FOR MASTER PAGE

        txtMasterTableName.Text = "GBL_ACVOUCHER_PYMT"
        txtSyncActualTable.Text = "true"
        '------------ FOR GRID        
        If HttpContext.Current.Session("COMPANYCODE") Is Nothing Then
            strMessage.Text = "Session has Expired !!!!"
        End If

        If Not IsPostBack Then
            '' txtAUTOMANUALMARK.Text = "MANUAL VOUCHER"
        Else
            Dim strAcCode = txtCASHBANKACCODE.Text
            Dim strAMOUNT = txtAMOUNT.Text
            Dim strDRCR = "C"
            Dim strTRANSACTIONTYPE = txtPAYMENTTYPE.Text
            Dim strCOMPANYCODE = HttpContext.Current.Session("COMPANYCODE")
            Dim strDIVISIONCODE = HttpContext.Current.Session("DIVISIONCODE")
            Dim strYEARCODE = HttpContext.Current.Session("YEARCODE")
            Dim strUSERNAME = HttpContext.Current.Session("USERNAME")
            Dim strOPERATIONMODE = txtOPTMODE.Text
            Dim strSERIALNO = "1"
            Dim strSYSTEMVOUCHERNO = txtSYSTEMVOUCHERNO.Text
            Dim strTDSONAMOUNT = txtTDSONAMOUNT.Text

            Dim strAcbillData = "[{" + """ACCODE""" + ":""" + strAcCode + """," + """AMOUNT""" + ":""" + strAMOUNT + """," + """TDSON""" + ":""" + strTDSONAMOUNT + """," + """DRCR""" + ":""" + strDRCR + """," + """COMPANYCODE""" + ":""" + strCOMPANYCODE + """," + """DIVISIONCODE""" + ":""" + strDIVISIONCODE + """," + """OPERATIONMODE""" + ":""" + strOPERATIONMODE + """," + """SERIALNO""" + ":""" + strSERIALNO + """," + """TRANSACTIONTYPE""" + ":""" + strTRANSACTIONTYPE + """," + """USERNAME""" + ":""" + strUSERNAME + """," + """YEARCODE""" + ":""" + strYEARCODE + """," + """SYSTEMVOUCHERNO""" + ":""" + strSYSTEMVOUCHERNO + """," + """LOCATIONCODE""" + ":""" + strDIVISIONCODE + """" + "}]"
            txtACLIABILITYDETAILS.Text = strAcbillData

            If Len(Trim(txtACLIABILITYDETAILS.Text)) > 4 Then
                GetLiabilityDtlsData(txtACLIABILITYDETAILS.Text, "ACCODE")
            End If

            If Len(Trim(txtTDSGRIDDATA.Text)) > 4 Then
                GetTDSData(txtTDSGRIDDATA.Text, "TDSDEDUCTEDON")
            End If

            If dtTempLiabilityDtls.Rows.Count > 0 Then
                txtDETAILSTABLENAME.Text = "GBL_ACVOUCHERDETAILS_PYMT~" & ConvertDatatableToXML(dtTempLiabilityDtls)

                If dtTempTDS.Rows.Count > 0 Then
                    txtDETAILSTABLENAME.Text = txtDETAILSTABLENAME.Text & "#GBL_ACTDSDETAILS_ENTRY~" & ConvertDatatableToXML(dtTempTDS)
                End If
            End If


        End If
    End Sub

    Private Sub Page_LoadComplete(sender As Object, e As EventArgs) Handles Me.LoadComplete
        txtCOMPCODE.Text = HttpContext.Current.Session("COMPANYCODE")
        txtDIVCODE.Text = HttpContext.Current.Session("DIVISIONCODE")
        txtYEARCODE1.Text = HttpContext.Current.Session("YEARCODE")
        txtUSRNAME.Text = HttpContext.Current.Session("USERNAME")
        txtDIVISIONCODEFOR.Text = HttpContext.Current.Session("DIVISIONCODE")

        If (Not Page.ClientScript.IsStartupScriptRegistered("cashbanktype")) Then
            Page.ClientScript.RegisterStartupScript(Me.GetType(), "cashbanktype", "fn_getCashBankType();", True)
        End If

        Dim ddOperationType As DropDownList = DirectCast(Master.FindControl("ddChooseOperation"), DropDownList)
        If Not ddOperationType Is Nothing Then
            Dim strVal As String
            strVal = IIf(ddOperationType.SelectedValue = "ADD", "A", IIf(ddOperationType.SelectedValue = "EDIT", "M", IIf(ddOperationType.SelectedValue = "DELETE", "D", IIf(ddOperationType.SelectedValue = "VIEW", "V", IIf(ddOperationType.SelectedValue = "PRINT", "P", "")))))
            txtOPTMODE.Text = strVal
        End If

        If txtOPTMODE.Text = "A" Then
            txtAUTOMANUALMARK.Text = "MANUAL VOUCHER"
        End If

        If txtOPTMODE.Text = "V" Then
            btnMasterSubmit.Enabled = False
        End If
        txtSYSTEMVOUCHERDATE.Text = getEffectSysDate()

        txtVOUCHERNO.Attributes.Add("readonly", "readonly")
        txtSYSTEMVOUCHERDATE.Attributes.Add("readonly", "readonly")
        txtVOUCHERNATURE.Attributes.Add("readonly", "readonly")
        getDivisionName()
        getFinancialDt()

        RbtManualRef.Checked = True
        txtREFERENCETYPE.Text = "MANUAL"

        txtTotAdjustingAmt.Text = txtAMOUNT.Text

        If Mid(strMessage.Text, 1, 9) <> "#SUCCESS#" Then
            If (Not Page.ClientScript.IsStartupScriptRegistered("populateTDSdetails")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "populateTDSdetails", "PopulateTDSdetailsGrid();", True)
            End If
        End If

    End Sub

    Public Sub getFinancialDt()
        Dim strYearCode = HttpContext.Current.Session("YEARCODE")
        Dim strcompanyCode = HttpContext.Current.Session("COMPANYCODE")
        Dim strdivisionCode = HttpContext.Current.Session("DIVISIONCODE")

        Dim dbManager As IDBManager = New DBManager()
        Dim dr As IDataReader
        Dim strQuery = ""

        strQuery = " SELECT TO_CHAR(STARTDATE,'DD/MM/YYYY') STARTDATE , TO_CHAR(ENDDATE,'DD/MM/YYYY') ENDDATE  "
        strQuery += System.Environment.NewLine + " FROM  FINANCIALYEAR "
        strQuery += System.Environment.NewLine + " WHERE COMPANYCODE='" + strcompanyCode + "'  "
        strQuery += System.Environment.NewLine + " AND DIVISIONCODE='" + strdivisionCode + "'  "
        strQuery += System.Environment.NewLine + " AND YEARCODE='" + strYearCode + "'  "

        Try
            dbManager.Open()
            dr = dbManager.ExecuteReader(CommandType.Text, strQuery)
            While dr.Read()
                Dim item As New ListItem()
                txtSTARTDATE.Text = dr("STARTDATE").ToString()
                txtENDDATE.Text = dr("ENDDATE").ToString()
            End While
            dr.Close()
        Catch ex As Exception
            Throw New Exception(String.Format(ex.ToString))
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try

    End Sub
    Public Shared Function getEffectSysDate() As String
        Dim strSQL As String
        Dim rcount As Integer = 0
        Dim strSysVoucherDate As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        strSQL = ""
        strSQL = " SELECT FN_GET_ACC_EFFECTSYSDATE('" & HttpContext.Current.Session("COMPANYCODE") & "', '" & HttpContext.Current.Session("DIVISIONCODE") & "','" & HttpContext.Current.Session("YEARCODE") & "') SysVoucherDate from dual "

        Try
            dbManager.Open()
            strSysVoucherDate = dbManager.ExecuteScalar(CommandType.Text, strSQL)
        Catch ex As Exception
            Throw New Exception(String.Format(ex.ToString))
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try

        Return strSysVoucherDate
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

    Public Sub GetTDSData(gridData As String, strNotNullableColumnName As String)
        'string data = gridData;
        Dim DG As New AcPaymentAdvanceDirect()
        Dim DTable As DataTable = DG.ConvertJSONToDataTable(gridData, strNotNullableColumnName)
        Dim sender As New Object
        Dim e As New System.EventArgs
        dtTempTDS = DG.ConvertJSONToDataTable(gridData, strNotNullableColumnName)
        dtTempTDS.TableName = "Table1"
    End Sub

    Public Sub GetLiabilityDtlsData(gridData As String, strNotNullableColumnName As String)
        'string data = gridData;
        Dim DG As New AcPaymentAdvanceDirect()
        Dim DTable As DataTable = DG.ConvertJSONToDataTable(gridData, strNotNullableColumnName)
        Dim sender As New Object
        Dim e As New System.EventArgs
        dtTempLiabilityDtls = DG.ConvertJSONToDataTable(gridData, strNotNullableColumnName)
        dtTempLiabilityDtls.TableName = "Table1"
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
                    Dim v As String = rowData.Substring(idx + 1).Replace("""", "").Replace("\n\r", vbCr).Replace("\n", vbCr).Replace("\r", vbCr)
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

    Protected Sub getDivisionName()
        Dim strSQL As String
        Dim rcount As Integer = 0
        Dim strGriddata As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        strSQL = ""
        strSQL = strSQL & vbCrLf & "SELECT DIVISIONNAME "
        strSQL = strSQL & vbCrLf & " FROM DIVISIONMASTER "
        strSQL = strSQL & vbCrLf & " WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
        strSQL = strSQL & vbCrLf & " AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
        Try
            dbManager.Open()
            txtDIVISIONNAME.Text = dbManager.ExecuteScalar(CommandType.Text, strSQL)
        Catch ex As Exception
            Throw New Exception(String.Format(ex.ToString))
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
    End Sub

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
    Private Sub txtPARTYNAME_TextChanged(sender As Object, e As EventArgs) Handles txtPARTYNAME.TextChanged
        If (Not Page.ClientScript.IsStartupScriptRegistered("partyDtls")) Then
            Page.ClientScript.RegisterStartupScript(Me.GetType(), "partyDtls", "GetPartyDtlsData();", True)
        End If
        'If (Not Page.ClientScript.IsStartupScriptRegistered("tdsGrid")) Then
        '    Page.ClientScript.RegisterStartupScript(Me.GetType(), "tdsGrid", "FetchTDSGridData();", True)
        'End If
    End Sub

    <WebMethod> _
    Public Shared Function fetchPartyDtls(strPartyName As String) As String
        Dim strSQL As String
        Dim rcount As Integer = 0
        Dim strGroupdata As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        strSQL = ""
        strSQL = "SELECT  A.PARTYCODE||'~'||A.ACCODE||'~'||A.ACTYPE||'~'||A.GROUPTYPE||'~'||A.ISTDSAPPLICABLE||'~'||A.MODULENAME||'~'||B.MAINGROUPCODE"
        strSQL += System.Environment.NewLine + " FROM VW_AC_PARTY A, ACACLEDGER B"
        strSQL += System.Environment.NewLine + " WHERE A.COMPANYCODE='" & HttpContext.Current.Session("COMPANYCODE") & "' "
        strSQL += System.Environment.NewLine + " AND A.COMPANYCODE=B.COMPANYCODE "
        strSQL += System.Environment.NewLine + " AND A.ACCODE=B.ACCODE "
        strSQL += System.Environment.NewLine + " AND A.PARTYNAME ='" + strPartyName + "' "

        Try
            dbManager.Open()
            strGroupdata = dbManager.ExecuteScalar(CommandType.Text, strSQL)
        Catch ex As Exception
            Throw New Exception(String.Format(ex.ToString))
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
        Return strGroupdata
    End Function
    Private Sub txtORDERNO_TextChanged(sender As Object, e As EventArgs) Handles txtORDERNO.TextChanged
        If (Not Page.ClientScript.IsStartupScriptRegistered("orderNo")) Then
            Page.ClientScript.RegisterStartupScript(Me.GetType(), "orderNo", "GetOrderDtlsData();", True)
        End If
    End Sub
    <WebMethod> _
    Public Shared Function getReferenceNo(strManualVoucherNo As String, strrReffType As String, strSysVoucherNo As String, strAccode As String) As String
        Dim strSQL As String
        Dim rcount As Integer = 0
        Dim strGroupdata As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        strSQL = ""

        strSQL = "SELECT  COUNT(REFBILLNO) REFBILLNO  "
        strSQL += System.Environment.NewLine + " FROM ACVOUCHER_PYMT "
        strSQL += System.Environment.NewLine + " WHERE COMPANYCODE='" & HttpContext.Current.Session("COMPANYCODE") & "' "
        strSQL += System.Environment.NewLine + " AND DIVISIONCODE='" & HttpContext.Current.Session("DIVISIONCODE") & "' "
        strSQL += System.Environment.NewLine + " AND YEARCODE='" & HttpContext.Current.Session("YEARCODE") & "' "
        If Len(Trim(strSysVoucherNo)) > 0 Then
            strSQL += System.Environment.NewLine + " AND SYSTEMVOUCHERNO <>'" + strSysVoucherNo + "' "
        End If
        strSQL += System.Environment.NewLine + " AND ACCODE ='" + strAccode + "' "
        strSQL += System.Environment.NewLine + " AND REFBILLNO LIKE '" + strManualVoucherNo + "%' "

        Try
            dbManager.Open()
            strGroupdata = dbManager.ExecuteScalar(CommandType.Text, strSQL)
        Catch ex As Exception
            ''Throw New Exception(String.Format(ex.ToString))
            strGroupdata = "Reference No. already exist!!"
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
        Return strGroupdata
    End Function

    <WebMethod> _
    Public Shared Function fetchOrderDtls(strOrderNo As String, strrReffType As String, strSysVoucherNo As String, strAccode As String) As String
        Dim strSQL As String
        Dim rcount As Integer = 0
        Dim strGroupdata As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        strSQL = ""

        If strrReffType = "MANUAL" Then
            strSQL = "SELECT  COUNT(REFBILLNO) REFBILLNO  "
            strSQL += System.Environment.NewLine + " FROM ACVOUCHER_LIB "
            strSQL += System.Environment.NewLine + " WHERE COMPANYCODE='" & HttpContext.Current.Session("COMPANYCODE") & "' "
            strSQL += System.Environment.NewLine + " AND DIVISIONCODE='" & HttpContext.Current.Session("DIVISIONCODE") & "' "
            strSQL += System.Environment.NewLine + " AND YEARCODE='" & HttpContext.Current.Session("YEARCODE") & "' "
            If Len(Trim(strSysVoucherNo)) > 0 Then
                strSQL += System.Environment.NewLine + " AND SYSTEMVOUCHERNO <>'" + strSysVoucherNo + "' "
            End If
            strSQL += System.Environment.NewLine + " AND ACCODE ='" + strAccode + "' "
            strSQL += System.Environment.NewLine + " AND REFBILLNO ='" + strOrderNo + "' "
            dbManager.Open()
            rcount = Convert.ToInt32(dbManager.ExecuteScalar(CommandType.Text, strSQL))
        End If

        If rcount > 0 Then
            strSQL = "SELECT  (888 /0) hh from dual "
        Else
            strSQL = "SELECT  to_char(ORDERDATE,'DD/MM/YYYY')||'~'||nvl(AMOUNT,'0')||'~'||MODULE  "
            strSQL += System.Environment.NewLine + " FROM VW_AC_SYSTEM_ORDERS "
            strSQL += System.Environment.NewLine + " WHERE COMPANYCODE='" & HttpContext.Current.Session("COMPANYCODE") & "' "
            strSQL += System.Environment.NewLine + " AND DIVISIONCODE='" & HttpContext.Current.Session("DIVISIONCODE") & "' "
            strSQL += System.Environment.NewLine + " AND ORDERNO ='" + strOrderNo + "' "
        End If
        Try
            dbManager.Open()
            strGroupdata = dbManager.ExecuteScalar(CommandType.Text, strSQL)
        Catch ex As Exception
            ''Throw New Exception(String.Format(ex.ToString))
            strGroupdata = "Reference No. already exist!!"
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
        Return strGroupdata
    End Function

    <WebMethod> _
    Public Shared Function fetchLiabilityDtls(strAcHead As String) As String
        Dim strSQL As String
        Dim rcount As Integer = 0
        Dim strGroupdata As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        strSQL = ""
        strSQL = "SELECT  ACCODE ||'~'||NVL(COSTCENTREALLOWED,'N') "
        strSQL += System.Environment.NewLine + " FROM ACACLEDGER "
        strSQL += System.Environment.NewLine + " WHERE COMPANYCODE='" & HttpContext.Current.Session("COMPANYCODE") & "' "
        strSQL += System.Environment.NewLine + "  AND ACHEAD ='" + strAcHead + "' "
        strSQL += System.Environment.NewLine + "  ORDER BY ACHEAD "
        Try
            dbManager.Open()
            strGroupdata = dbManager.ExecuteScalar(CommandType.Text, strSQL)
        Catch ex As Exception
            Throw New Exception(String.Format(ex.ToString))
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
        Return strGroupdata
    End Function
    <WebMethod> _
    Public Shared Function fetchChequeNo(strCashBankCode As String, strBookSlNo As String) As String
        Dim strSQL As String
        Dim rcount As Integer = 0
        Dim strGroupdata As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        strSQL = ""
        strSQL = " select fn_generate_chequeno('" & HttpContext.Current.Session("COMPANYCODE") & "', '" & HttpContext.Current.Session("DIVISIONCODE") & "','" & strCashBankCode & "','" & strBookSlNo & "') chequedtls from dual "
        Try
            dbManager.Open()
            strGroupdata = dbManager.ExecuteScalar(CommandType.Text, strSQL)
        Catch ex As Exception
            Throw New Exception(String.Format(ex.ToString))
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
        Return strGroupdata
    End Function
    '<WebMethod> _
    'Public Shared Function getTDSGridData(strAcCode As String, strSysVoucherDt As String, strGroupType As String) As String
    '    Dim dd As New AcPaymentAdvanceDirect()
    '    Dim str As String = dd.GetDataTableJson(dd.TDSGridDataFetch(strAcCode, strSysVoucherDt, strGroupType))
    '    Return str
    'End Function

    'Private Function TDSGridDataFetch(strAcCode As String, strSysVoucherDt As String, strGroupType As String) As DataTable
    '    Dim dtGridData As New DataTable
    '    Dim strSQL As String
    '    Dim rcount As Integer = 0

    '    If Len(Trim(strAcCode)) = 0 Then
    '        Return dtGridData
    '        Exit Function
    '    End If


    '    Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
    '    strSQL = ""

    '    strSQL = strSQL & vbCrLf & " SELECT 'NO' AS SELECTED, A.TDSNATURE,A.TDSCODE,A.ALWAYSDEDUCT,A.LOWERDEDUCTLIMIT,"
    '    strSQL = strSQL & vbCrLf & "  B.EDUCATIONCESS,B.SREDUCATIONCESS,B.SERVICETAXPERCENT AS SURCHARGEPERCENTAGE,B.YEARLYLIMIT,B.SINGLETRANSACTIONLIMIT,'' AS TDSDEDUCTEDON, "
    '    If strGroupType = "DEBTORS" Or strGroupType = "CREDITORS" Then
    '        strSQL = strSQL & vbCrLf & "  A.PERCENT,A.TDSPERCENTAGE, "
    '    Else
    '        strSQL = strSQL & vbCrLf & "  A.PERCENT AS TDSPERCENTAGE, "
    '    End If
    '    strSQL = strSQL & vbCrLf & "   '" & HttpContext.Current.Session("COMPANYCODE") & "' as COMPANYCODE, "
    '    strSQL = strSQL & vbCrLf & "   '" & HttpContext.Current.Session("DIVISIONCODE") & "' as DIVISIONCODE, "
    '    strSQL = strSQL & vbCrLf & "   '" & HttpContext.Current.Session("YEARCODE") & "' as YEARCODE "
    '    strSQL = strSQL & vbCrLf & "  FROM ACTDSLEDGERMASTER A , ACTDSMASTER B"
    '    strSQL = strSQL & vbCrLf & "         WHERE A.COMPANYCODE = B.COMPANYCODE"
    '    strSQL = strSQL & vbCrLf & "   AND A.TDSNATURE=B.TDSNATURE"
    '    strSQL = strSQL & vbCrLf & "   AND A.COMPANYCODE ='" & HttpContext.Current.Session("COMPANYCODE") & "' "
    '    strSQL = strSQL & vbCrLf & "   AND A.WITHEFFECTFROM = (SELECT MAX(B.WITHEFFECTFROM) "
    '    strSQL = strSQL & vbCrLf & "                          FROM ACTDSLEDGERMASTER B "
    '    strSQL = strSQL & vbCrLf & "                          WHERE B.COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "' "
    '    strSQL = strSQL & vbCrLf & "                            AND B.ACCODE = A.ACCODE "
    '    strSQL = strSQL & vbCrLf & "                            AND B.WITHEFFECTFROM <= TO_DATE('" & strSysVoucherDt & "','DD/MM/YYYY') "
    '    strSQL = strSQL & vbCrLf & "                         )"
    '    strSQL = strSQL & vbCrLf & " AND A.ACCODE='" & strAcCode & "'  "

    '    Try
    '        dbManager.Open()
    '        dtGridData = dbManager.ExecuteDataTable(CommandType.Text, strSQL)
    '    Catch ex As Exception
    '        strMessage.Text = "Error occured while fetching details.." & vbCrLf & ex.Message.ToString
    '    Finally
    '        dbManager.Close()
    '        dbManager.Dispose()
    '        dbManager = Nothing
    '    End Try
    '    Return dtGridData
    'End Function

    <WebMethod> _
    Public Shared Function calcTDSAmount(strcompcode As String, strdivcode As String, stryearcode As String,
                    straccode As String, strtdscode As String, strTDSOnAmt As Double) As String
        Dim strSQL As String
        Dim rcount As Integer = 0
        Dim strTDSAmt As String = ""
        Dim strSelectQry = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        strSQL = ""

        strSQL = " prc_DeductTDS('" & strcompcode & "', '" & strdivcode & "','" & stryearcode & "','" & straccode & "','" & strtdscode & "'," & strTDSOnAmt & ") "

        Try
            dbManager.Open()
            dbManager.BeginTransaction()
            dbManager.ClearParameter()
            dbManager.CreateParameters(0)
            rcount = dbManager.ExecuteNonQuery(CommandType.StoredProcedure, strSQL)
            If rcount > 0 Then
                strSelectQry = ""
                strSelectQry = " SELECT TDSDEDUCTEDON||'~'||BILLAMOUNT||'~'||DRCR||'~'||PERCENTAGE||'~'||HSEDUCATIONCESSAMOUNT ||'~'||SERVICETAXAMOUNT||'~'||EDUCATIONCESSAMOUNT||'~'||NETTDSAMOUNT||'~'||NETAMOUNT||'~'||TOTALTDSAMOUNT||'~'||PARTYCODE||'~'||TRANSACTIONTYPE ||'~'||ACCODE "
                strSelectQry = strSelectQry & vbCrLf & " FROM gbl_tdstobededucted "
            End If
            strTDSAmt = dbManager.ExecuteScalar(CommandType.Text, strSelectQry)
            dbManager.CommitTransaction()
        Catch ex As Exception
            Throw New Exception(String.Format(ex.ToString))
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
        Return strTDSAmt
    End Function

    <WebMethod> _
    Public Shared Function fetchVoucherHeaderData(strSysVoucherNo As String) As String
        Dim strSQL As String
        Dim rcount As Integer = 0
        Dim strVoucherHeaderdata As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        strSQL = ""

        strSQL = "        SELECT TO_CHAR(A.SYSTEMVOUCHERDATE,'DD/MM/YYYY')|| '~' ||A.VOUCHERNO|| '~' ||TO_CHAR(A.VOUCHERDATE,'DD/MM/YYYY') "
        strSQL = strSQL & vbCrLf & " || '~' ||A.ACCODE|| '~' ||B.PARTYNAME|| '~' ||B.PARTYCODE|| '~' || B.ACTYPE|| '~' ||B.GROUPTYPE|| '~' ||A.AMOUNT|| '~' ||A.DRCR  "
        strSQL = strSQL & vbCrLf & " || '~' ||A.REFERENCETYPE|| '~' ||A.REFBILLNO|| '~' ||TO_CHAR(A.REFBILLDATE,'DD/MM/YYYY')|| '~' ||A.TDSONAMOUNT|| '~' ||A.TOTALTDSAMOUNT|| '~' ||A.NARRATION "
        strSQL = strSQL & vbCrLf & " || '~' ||A.AUTOMANUALMARK|| '~' ||A.DOCUMENTTYPE|| '~' ||A.MODULENAME|| '~' ||A.SYSROWID|| '~' ||B.ISTDSAPPLICABLE|| '~' ||'NONE'|| '~' ||'' "
        strSQL = strSQL & vbCrLf & " || '~' ||A.CASHBANKACCODE|| '~' ||C.ACHEAD|| '~' ||NVL(A.CHEQUENO,'')|| '~' ||NVL(A.INSTRUCTIONNO,'')|| '~' ||A.CHEQUEBOOKSLNO|| '~' ||TO_CHAR(A.CHEQUEDATE,'DD/MM/YYYY') "
        strSQL = strSQL & vbCrLf & " || '~' ||A.CHEQUEDRAWNON|| '~' ||A.PARTY|| '~' ||(NVL(A.AMOUNT,0)+NVL(A.TOTALTDSAMOUNT,0)) "
        strSQL = strSQL & vbCrLf & "  FROM ACVOUCHER_PYMT A, VW_AC_PARTY B,ACACLEDGER C"
        strSQL = strSQL & vbCrLf & "         WHERE A.COMPANYCODE = B.COMPANYCODE"
        strSQL = strSQL & vbCrLf & "          AND A.COMPANYCODE=B.COMPANYCODE "
        strSQL = strSQL & vbCrLf & "          AND INSTR(A.DIVISIONCODE,A.DIVISIONCODE)>0 "
        strSQL = strSQL & vbCrLf & "          AND A.CASHBANKACCODE=C.ACCODE "
        strSQL = strSQL & vbCrLf & "          AND A.ACCODE=B.ACCODE"
        strSQL = strSQL & vbCrLf & "          AND A.SYSTEMVOUCHERNO='" & strSysVoucherNo & "'"

        Try
            dbManager.Open()
            strVoucherHeaderdata = dbManager.ExecuteScalar(CommandType.Text, strSQL)
        Catch ex As Exception
            Throw New Exception(String.Format(ex.ToString))
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try

        Return strVoucherHeaderdata
    End Function
    <WebMethod> _
    Public Shared Function fetchVoucherDtlsData(strSysVoucherNo As String) As String
        Dim strSQL As String
        Dim rcount As Integer = 0
        Dim strVoucherDtlsdata As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        strSQL = ""

        strSQL = "        SELECT  "
        strSQL = strSQL & vbCrLf & " A.ACCODE|| '~' ||B.ACHEAD|| '~' ||A.AMOUNT|| '~' ||NVL(COSTCENTREALLOWED,'N')||'~'||A.DRCR "
        strSQL = strSQL & vbCrLf & "  FROM ACVOUCHERDETAILS_LIB A, ACACLEDGER B"
        strSQL = strSQL & vbCrLf & "         WHERE A.COMPANYCODE = B.COMPANYCODE"
        strSQL = strSQL & vbCrLf & "            AND InStr(A.DIVISIONCODE, A.DIVISIONCODE) > 0"
        strSQL = strSQL & vbCrLf & "            AND A.ACCODE=B.ACCODE"
        strSQL = strSQL & vbCrLf & "            AND A.SYSTEMVOUCHERNO='" & strSysVoucherNo & "'"

        Try
            dbManager.Open()
            strVoucherDtlsdata = dbManager.ExecuteScalar(CommandType.Text, strSQL)
        Catch ex As Exception
            Throw New Exception(String.Format(ex.ToString))
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
        Return strVoucherDtlsdata
    End Function

    <WebMethod> _
    Public Shared Function getTDSGridBySysVoucherNo(strSysVoucherNo As String, strOperationMode As String, strAcCode As String, strSysVoucherDt As String, strGroupType As String) As String
        Dim dd As New AcPaymentAdvanceDirect()
        Dim str As String = dd.GetDataTableJson(dd.TDSGridBySysVoucherNo(strSysVoucherNo, strOperationMode, strAcCode, strSysVoucherDt, strGroupType))
        Return str
    End Function
    Private Function TDSGridBySysVoucherNo(strSysVoucherNo As String, strOperationMode As String, strAcCode As String, strSysVoucherDt As String, strGroupType As String) As DataTable
        Dim dtGridData As New DataTable
        Dim strSQL As String = ""
        Dim rcount As Integer = 0

        'If Len(Trim(strSysVoucherNo)) = 0 Then
        '    Return dtGridData
        '    Exit Function
        'End If


        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim strSQL2 = ""
        strSQL2 = "SELECT  COUNT (ACCODE) CNT  "
        strSQL2 += System.Environment.NewLine + " FROM ACTDSDETAILS_ENTRY "
        strSQL2 += System.Environment.NewLine + " WHERE COMPANYCODE='" & HttpContext.Current.Session("COMPANYCODE") & "' "
        strSQL2 += System.Environment.NewLine + " AND DIVISIONCODE='" & HttpContext.Current.Session("DIVISIONCODE") & "' "
        strSQL2 += System.Environment.NewLine + " AND YEARCODE='" & HttpContext.Current.Session("YEARCODE") & "' "
        strSQL2 += System.Environment.NewLine + " AND SYSTEMVOUCHERNO ='" + strSysVoucherNo + "' "
        dbManager.Open()
        rcount = Convert.ToInt32(dbManager.ExecuteScalar(CommandType.Text, strSQL2))
        If rcount = 0 Then
            strOperationMode = "A"
        Else
            strOperationMode = "M"
        End If

        strSQL = strSQL & vbCrLf & " SELECT DECODE(NVL(A.TDSCODE,'AA'), 'AA', 'NO','YES') SELECTED, A.ACCODE, B.TDSNATURE, B.PERCENTNEW AS TDSPERCENTAGE,B.PERCENTNEW AS NETPERCENTAGE, A.BILLNO, A.BILLDATE, "
        strSQL = strSQL & vbCrLf & "     A.BILLAMOUNT, A.TDSDEDUCTEDON , A.DRCR,A.SREEDUCESSAMT, A.SERVICETAXAMOUNT, A.EDUCESSAMT, A.NETTDSAMT, A.NETAMT, A.TDSAMT,"
        strSQL = strSQL & vbCrLf & "    A.TRANSACTIONTYPE, A.MANUALAUTO, A.PARTYCODE,"
        strSQL = strSQL & vbCrLf & "   '" & HttpContext.Current.Session("COMPANYCODE") & "' as COMPANYCODE, "
        strSQL = strSQL & vbCrLf & "   '" & HttpContext.Current.Session("DIVISIONCODE") & "' as DIVISIONCODE, "
        strSQL = strSQL & vbCrLf & "   '" & HttpContext.Current.Session("YEARCODE") & "' as YEARCODE, "
        strSQL = strSQL & vbCrLf & "   '" & HttpContext.Current.Session("USERNAME") & "' as USERNAME, '" & strOperationMode & "' as OPERATIONMODE , '" & strSysVoucherNo & "' as SYSTEMVOUCHERNO, "
        strSQL = strSQL & vbCrLf & "    B.TDSCODE, B.ALWAYSDEDUCT, B.LOWERDEDUCTLIMIT, B.YEARLYLIMIT, B.SINGLETRANSACTIONLIMIT"
        strSQL = strSQL & vbCrLf & " FROM "
        strSQL = strSQL & vbCrLf & " ("
        strSQL = strSQL & vbCrLf & "  SELECT 'YES' AS SELECTED, A.ACCODE, B.TDSNATURE, A.PERCENTAGE as TDSPERCENTAGE, A.BILLNO, TO_CHAR(A.BILLDATE,'DD/MM/YYYY') BILLDATE,A.BILLAMOUNT, A.TDSDEDUCTEDON ,A.DRCR, "
        strSQL = strSQL & vbCrLf & "  A.HSEDUCATIONCESSAMOUNT AS SREEDUCESSAMT, A.SERVICETAXAMOUNT, A.EDUCATIONCESSAMOUNT AS EDUCESSAMT, A.NETTDSAMOUNT AS NETTDSAMT, NETAMOUNT AS NETAMT, TOTALTDSAMOUNT AS TDSAMT, "
        strSQL = strSQL & vbCrLf & "  A.TRANSACTIONTYPE, A.MANUALAUTO, A.PARTYCODE, "
        strSQL = strSQL & vbCrLf & "         B.TDSCODE, B.ALWAYSDEDUCT, B.LOWERDEDUCTLIMIT, C.YEARLYLIMIT, C.SINGLETRANSACTIONLIMIT"
        strSQL = strSQL & vbCrLf & "   FROM ACTDSDETAILS_ENTRY A, ACTDSLEDGERMASTER B,ACTDSMASTER C "
        strSQL = strSQL & vbCrLf & "         WHERE A.COMPANYCODE = B.COMPANYCODE"
        strSQL = strSQL & vbCrLf & "    AND A.TDSTYPE=B.TDSNATURE"
        strSQL = strSQL & vbCrLf & "    AND A.ACCODE=B.ACCODE"
        strSQL = strSQL & vbCrLf & "    AND A.COMPANYCODE=C.COMPANYCODE "
        strSQL = strSQL & vbCrLf & "    AND A.TDSTYPE=C.TDSNATURE "
        strSQL = strSQL & vbCrLf & "    AND A.COMPANYCODE ='" & HttpContext.Current.Session("COMPANYCODE") & "' "
        strSQL = strSQL & vbCrLf & "    AND A.SYSTEMVOUCHERNO='" & strSysVoucherNo & "' "
        strSQL = strSQL & vbCrLf & " ) A,"
        strSQL = strSQL & vbCrLf & " (           "
        strSQL = strSQL & vbCrLf & "  SELECT 'NO' AS SELECTED, A.ACCODE, A.TDSNATURE,A.TDSCODE,A.ALWAYSDEDUCT,A.LOWERDEDUCTLIMIT,"
        strSQL = strSQL & vbCrLf & "   B.EDUCATIONCESS,B.SREDUCATIONCESS,B.SERVICETAXPERCENT,B.YEARLYLIMIT,B.SINGLETRANSACTIONLIMIT,'' AS TDSDEDUCTEDON, "
        If strGroupType = "DEBTORS" Or strGroupType = "CREDITORS" Then
            strSQL = strSQL & vbCrLf & "  A.PERCENT,A.PERCENTNEW "
        Else
            strSQL = strSQL & vbCrLf & "  A.PERCENT AS TDSPERCENTAGE "
        End If
        strSQL = strSQL & vbCrLf & "   FROM ACTDSLEDGERMASTER A , ACTDSMASTER B"
        strSQL = strSQL & vbCrLf & "         WHERE A.COMPANYCODE = B.COMPANYCODE"
        strSQL = strSQL & vbCrLf & "    AND A.TDSNATURE=B.TDSNATURE"
        strSQL = strSQL & vbCrLf & "    AND A.COMPANYCODE ='" & HttpContext.Current.Session("COMPANYCODE") & "' "
        strSQL = strSQL & vbCrLf & "    AND A.WITHEFFECTFROM = (SELECT MAX(B.WITHEFFECTFROM) "
        strSQL = strSQL & vbCrLf & "                           FROM ACTDSLEDGERMASTER B "
        strSQL = strSQL & vbCrLf & "                           WHERE B.COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "' "
        strSQL = strSQL & vbCrLf & "                             AND B.ACCODE = A.ACCODE "
        strSQL = strSQL & vbCrLf & "                             AND B.WITHEFFECTFROM <= TO_DATE('" & strSysVoucherDt & "','DD/MM/YYYY') "
        strSQL = strSQL & vbCrLf & "                          )"
        strSQL = strSQL & vbCrLf & "  AND A.ACCODE='" & strAcCode & "'  "
        strSQL = strSQL & vbCrLf & " ) B"
        strSQL = strSQL & vbCrLf & " WHERE A.TDSCODE(+)=B.TDSCODE"

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

    Public Function ValidatePage() As Boolean

        If txtAUTOMANUALMARK.Text = "" Then
            txtAUTOMANUALMARK.Text = "MANUAL VOUCHER"
        End If

        Dim blnReturnValidate As Boolean = False

        'If txtTDSONAMOUNT.Text = txtTOTALTDSON.Text Then
        '    strMessage.Text = ""
        '    blnReturnValidate = True
        'Else
        '    strMessage.Text = "Error: Total TDS On amount should be equals to Rs." + txtTDSONAMOUNT.Text
        '    blnReturnValidate = False
        'End If

        ''-------------------------
        Dim startdate As Date = Date.ParseExact(txtSTARTDATE.Text, "dd/MM/yyyy", System.Globalization.DateTimeFormatInfo.InvariantInfo)
        Dim enddate As Date = Date.ParseExact(txtENDDATE.Text, "dd/MM/yyyy", System.Globalization.DateTimeFormatInfo.InvariantInfo)
        Dim sysdate As Date = Date.ParseExact(txtSYSTEMVOUCHERDATE.Text, "dd/MM/yyyy", System.Globalization.DateTimeFormatInfo.InvariantInfo)

        Dim myDate As Date = Date.ParseExact(mskORDERDATE.Text, "dd/MM/yyyy", System.Globalization.DateTimeFormatInfo.InvariantInfo)

        'If CDate(myDate) >= CDate(startdate) And CDate(myDate) <= CDate(sysdate) Then
        If CDate(myDate) > CDate(sysdate) Then
            strMessage.Text = "Error: Reference Bill date can't be greater than system date!!"
            mskORDERDATE.Focus()
            blnReturnValidate = False
        Else
            strMessage.Text = ""
            blnReturnValidate = True
        End If

        If txtVOUCHERNATURE.Text.Length = 0 Then
            strMessage.Text = "Error: Liability Nature can't be blank." + "<br />"
            blnReturnValidate = False
        Else
            strMessage.Text = ""
            blnReturnValidate = True
        End If

        If txtMANUALVOUCHERNO.Text.Length = 0 Then
            strMessage.Text = "Error: Order No can't be blank." + "<br />"
            blnReturnValidate = False
        Else
            strMessage.Text = ""
            blnReturnValidate = True
        End If

        ''--------------
        If txtOPTMODE.Text = "M" Or txtOPTMODE.Text = "D" Then
            If txtVOUCHERNO.Text.Length > 0 Then
                strMessage.Text = "Voucher Already Approved, Edit or Delete not possible. <br/>"
                blnReturnValidate = False
            Else
                strMessage.Text = ""
                blnReturnValidate = True
            End If
        End If
        ''-----------------------
        If txtOPTMODE.Text = "P" Then
            If Len(Trim(txtSYSTEMVOUCHERNO.Text)) > 0 Then
                rptBuffer = FreeFile()
                strFileNameAccount = fnGenerateReportFileName()
                blnReturnValidate = fn_Accounts_Voucher_All(",~" + txtSYSTEMVOUCHERNO.Text + "~")
            End If

            If blnReturnValidate = True Then
                Dim appPath As String = HttpContext.Current.Request.ApplicationPath   '''' virtual path of application
                Dim physicalPath As String = HttpContext.Current.Request.MapPath(appPath)   '' actual physical path of application
                Dim strOnlyFileName As String = Mid(strFileNameAccount, InStr(strFileNameAccount, "SWTRPT"))
                Response.ContentType = "Application/swt"
                Dim FilePath As String = MapPath(strOnlyFileName)
                DownloadFile(physicalPath & "/text_reports/" & strOnlyFileName, True)
            Else
                Page.ClientScript.RegisterStartupScript(Me.GetType, "msgbox", "alert('No data found for this selection.');", True)
            End If

        End If
        Return blnReturnValidate
    End Function

    Private Sub DownloadFile(ByVal fname As String, ByVal forceDownload As Boolean)
        Dim path As Path
        Dim fullpath = path.GetFullPath(fname)
        Dim name = path.GetFileName(fullpath)
        Dim ext = path.GetExtension(fullpath)
        Dim type As String = ""
        If Not IsDBNull(ext) Then
            ext = LCase(ext)
        End If
        Select Case ext
            Case ".htm", ".html"
                type = "text/HTML"
            Case ".txt"
                type = "text/plain"
            Case ".doc", ".rtf"
                type = "Application/msword"
            Case ".csv", ".xls"
                type = "Application/x-msexcel"
            Case ".swt"
                type = "Application/SWTPrinting"
            Case Else
                type = "text/plain"
        End Select
        If (forceDownload) Then
            Response.AppendHeader("content-disposition", _
            "attachment; filename=" + name)
        End If
        If type <> "" Then
            Response.ContentType = type
        End If
        Response.WriteFile(fullpath)
        Response.End()
    End Sub

    <WebMethod> _
    Public Shared Function GetCompletionList(prefixText As String, listCnt As String) As String()

        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim oReader As OracleClient.OracleDataReader
        Dim CompletionSet As New List(Of String)()
        Dim strSQL = ""

        strSQL = strSQL & vbCrLf & "SELECT NARRATION FROM ACVOUCHER  "
        strSQL = strSQL & vbCrLf & "       WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
        strSQL = strSQL & vbCrLf & "         AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "' "
        strSQL = strSQL & vbCrLf & "         AND UPPER(NARRATION) LIKE '" & prefixText.ToUpper & "%'  "
        If listCnt > 0 Then
            strSQL = strSQL & vbCrLf & "    AND ROWNUM <= '" & listCnt & "' "
        End If

        Try
            dbManager.Open()
            oReader = dbManager.ExecuteReader(CommandType.Text, strSQL)
            While oReader.Read()
                CompletionSet.Add(oReader("NARRATION").ToString())
            End While

        Catch ex As Exception
            Throw New Exception(String.Format(ex.ToString))
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
        Return CompletionSet.ToArray()
    End Function


End Class