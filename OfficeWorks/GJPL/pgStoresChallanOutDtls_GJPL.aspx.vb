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
Public Class pgStoresChallanOutDtls_GJPL
    Inherits System.Web.UI.Page
    Dim strMessage As Label
    Dim btnSubmit As Button
    Dim strOptType As String
    Dim txtMasterTableName As TextBox
    Dim txtSyncActualTable As TextBox
    Dim txtUserName As TextBox
    Dim txtButtonTag As TextBox
    Dim ddOperationType As DropDownList
    Dim strMENUTAG As TextBox
    ' for grid control
    Dim txtDETAILSTABLENAME As TextBox
    Dim blnExit As Boolean = True
    Dim dtTmp As New DataTable
    Dim blnHideDefHeader As Boolean = False
    Dim btnMasterSubmit As Button
    ' for grid control

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim strSql As String = ""
        '-- START -- FOLLOWINGS ARE MANDATORY FOR MASTER PAGE
        ddOperationType = DirectCast(Master.FindControl("ddChooseOperation"), DropDownList)
        strMessage = DirectCast(Master.FindControl("lblMasterMessage"), Label)
        txtDETAILSTABLENAME = DirectCast(Master.FindControl("txtDETAILSTABLENAME"), TextBox)
        txtSyncActualTable = DirectCast(Master.FindControl("txtSYNCACTUALTABLE"), TextBox)
        txtUserName = DirectCast(Master.FindControl("txtUSERNAME"), TextBox)
        txtButtonTag = DirectCast(Master.FindControl("txtButtonTag"), TextBox)
        btnMasterSubmit = DirectCast(Master.FindControl("btnSubmit"), Button)
        strMENUTAG = DirectCast(Master.FindControl("txtMENUTAG"), TextBox)

        If Not ddOperationType Is Nothing Then
            Dim strVal As String
            strVal = IIf(ddOperationType.SelectedValue = "ADD", "A", IIf(ddOperationType.SelectedValue = "EDIT", "M", IIf(ddOperationType.SelectedValue = "DELETE", "D", IIf(ddOperationType.SelectedValue = "VIEW", "V", IIf(ddOperationType.SelectedValue = "PRINT", "P", "")))))
            txtOPTMODE.Text = strVal
        End If
        '-- END   -- FOLLOWINGS ARE MANDATORY FOR MASTER PAGE

        If IsPostBack Then
            'If Len(Trim(txtCHALLANGRIDDATA.Text)) > 4 Then
            '    GetData(txtCHALLANGRIDDATA.Text, "ITEMDESC")
            'End If

            'prcUpdateChallanGridData()
            'If Not IsNothing(dtTmp) Then
            '    txtDETAILSTABLENAME.Text = "GBL_STORESCHALLANOUTDETAILS~" & ConvertDatatableToXML(dtTmp)
            'End If
        End If
    End Sub

    Private Sub pgStoresChallanOutDtls_GJPL_LoadComplete(sender As Object, e As EventArgs) Handles Me.LoadComplete
        txtCOMPCODE.Text = HttpContext.Current.Session("COMPANYCODE")
        txtDIVCODE.Text = HttpContext.Current.Session("DIVISIONCODE")
        txtYEARCODE.Text = HttpContext.Current.Session("YEARCODE")
        txtUSRNAME.Text = HttpContext.Current.Session("USERNAME")

        Dim ddOperationType As DropDownList = DirectCast(Master.FindControl("ddChooseOperation"), DropDownList)
        If Not ddOperationType Is Nothing Then
            Dim strVal As String
            strVal = IIf(ddOperationType.SelectedValue = "ADD", "A", IIf(ddOperationType.SelectedValue = "EDIT", "M", IIf(ddOperationType.SelectedValue = "DELETE", "D", IIf(ddOperationType.SelectedValue = "VIEW", "V", IIf(ddOperationType.SelectedValue = "PRINT", "P", "")))))
            txtOPTMODE.Text = strVal
        End If

        bindOutType()

        txtTRANSACTIONNO.Attributes.Add("readonly", "readonly")
        ''mskTRANSACTIONDATE.Attributes.Add("readonly", "readonly")
        txtPARTYCODE.Attributes.Add("readonly", "readonly")
        txtPARTYNAME.Attributes.Add("readonly", "readonly")

        mskTRANSACTIONDATE.Text = Format(Now, "dd/MM/yyyy")

        If Mid(strMessage.Text, 1, 9) <> "#SUCCESS#" Then
            If (Not Page.ClientScript.IsStartupScriptRegistered("populateChallanGriddetails")) Then
                Page.ClientScript.RegisterStartupScript(Me.GetType(), "populateChallanGriddetails", "PopulateChallandetailsGrid();", True)
            End If
        End If

    End Sub

    Public Sub GetData(gridData As String, strNotNullableColumnName As String)
        'string data = gridData;
        Dim DG As New pgStoresChallanOutDtls_GJPL()
        Dim DTable As DataTable = DG.ConvertJSONToDataTable(gridData, strNotNullableColumnName)
        Dim sender As New Object
        Dim e As New System.EventArgs
        dtTmp = DG.ConvertJSONToDataTable(gridData, strNotNullableColumnName)
        dtTmp.TableName = "Table1"
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
    Private Sub bindOutType()

        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        Dim dtOutType As New DataTable()
        Dim strSQL As String = ""

        strSQL = strSQL & vbCrLf & " SELECT OUTTYPE  "
        strSQL = strSQL & vbCrLf & "  FROM STORESCHALLANOUTTYPE "
        strSQL = strSQL & vbCrLf & "   ORDER BY ROWNUM"

        Try
            dbManager.Open()
            dtOutType = dbManager.ExecuteDataTable(CommandType.Text, strSQL)
            cmbOUTTYPE.Items.Clear()
            cmbOUTTYPE.DataSource = dtOutType
            cmbOUTTYPE.DataTextField = "OUTTYPE"
            cmbOUTTYPE.DataValueField = "OUTTYPE"
            cmbOUTTYPE.DataBind()
            cmbOUTTYPE.Items.Insert(0, "--Select--")
            cmbOUTTYPE.SelectedIndex = 0
        Catch ex As Exception
            strMessage.Text = "Error occured while fetching Out type .." & vbCrLf & ex.Message.ToString
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
    End Sub

    <WebMethod> _
    Public Shared Function fetchPartyDtls(strPartyCode As String) As String
        Dim strSQL As String
        Dim rcount As Integer = 0
        Dim strPartydata As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        strSQL = ""
        strSQL = "SELECT  PARTYNAME "
        strSQL += System.Environment.NewLine + " FROM PARTYMASTER "
        strSQL += System.Environment.NewLine + " WHERE COMPANYCODE='" & HttpContext.Current.Session("COMPANYCODE") & "' "
        strSQL += System.Environment.NewLine + " AND PARTYTYPE ='SUPPLIER' "
        strSQL += System.Environment.NewLine + " AND MODULE = 'STORES' "
        strSQL += System.Environment.NewLine + " AND PARTYCODE ='" + strPartyCode + "' "
        Try
            dbManager.Open()
            strPartydata = dbManager.ExecuteScalar(CommandType.Text, strSQL)
        Catch ex As Exception
            Throw New Exception(String.Format(ex.ToString))
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
        Return strPartydata
    End Function
    <WebMethod> _
    Public Shared Function fetchAgainstDtls(strAgainstNo As String, strOuttype As String) As String
        Dim strSQL As String
        Dim rcount As Integer = 0
        Dim strPartydata As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager

        strSQL = ""
        If strOuttype = "REJECTION W/O PO" Then
            strSQL += System.Environment.NewLine + "SELECT GATEPASSDATE||'~'||PARTYCHALLANNO||'~'||PARTYCHALLANDATE XX FROM ( "
            strSQL += System.Environment.NewLine + "SELECT DISTINCT GATEPASSNO, TO_CHAR(GATEPASSDATE,'DD/MM/YYYY') GATEPASSDATE, PARTYCHALLANNO, TO_CHAR(PARTYCHALLANDATE,'DD/MM/YYYY') PARTYCHALLANDATE  "
            strSQL += System.Environment.NewLine + "  FROM STORESGATEPASSENTRY "
            strSQL += System.Environment.NewLine + " WHERE COMPANYCODE='" & HttpContext.Current.Session("COMPANYCODE") & "' "
            strSQL += System.Environment.NewLine + "   AND DIVISIONCODE='" & HttpContext.Current.Session("DIVISIONCODE") & "' "
            strSQL += System.Environment.NewLine + ") "
            strSQL += System.Environment.NewLine + "WHERE GATEPASSNO='" + strAgainstNo + "' "
            strSQL += System.Environment.NewLine + "AND ROWNUM=1 "
        Else
            ''--------------------MODIFIED BY SARBANI ON 17092016------------------
            strSQL += System.Environment.NewLine + " SELECT ROUGHRECEIPTDATE||'~'||PARTYCHALLANNO||'~'||PARTYCHALLANDATE XX "
            strSQL += System.Environment.NewLine + " FROM ( "
            strSQL += System.Environment.NewLine + "  SELECT DISTINCT A.ROUGHRECEIPTNO, TO_CHAR(A.ROUGHRECEIPTDATE,'DD/MM/YYYY') ROUGHRECEIPTDATE, A.PARTYCHALLANNO, TO_CHAR(A.ORIGINALCHALLANDATE,'DD/MM/YYYY') PARTYCHALLANDATE  "
            strSQL += System.Environment.NewLine + "  FROM STORESRECEIPTMAST A,STORESRECEIPTDETAILS B"
            strSQL += System.Environment.NewLine + "  WHERE A.COMPANYCODE='" & HttpContext.Current.Session("COMPANYCODE") & "' "
            strSQL += System.Environment.NewLine + "   AND A.DIVISIONCODE='" & HttpContext.Current.Session("DIVISIONCODE") & "' "
            strSQL += System.Environment.NewLine + "   AND A.COMPANYCODE=B.COMPANYCODE "
            strSQL += System.Environment.NewLine + "   AND A.DIVISIONCODE=B.DIVISIONCODE"
            strSQL += System.Environment.NewLine + "   AND A.ROUGHRECEIPTNO=B.ROUGHRECEIPTNO"
            strSQL += System.Environment.NewLine + "   AND A.ROUGHRECEIPTDATE=B.ROUGHRECEIPTDATE"
            strSQL += System.Environment.NewLine + "   AND A.PARTYCHALLANNO=B.PARTYCHALLANNO"
            strSQL += System.Environment.NewLine + "   AND NVL(B.REJECTEDQUANTITY,0)>0 "
            strSQL += System.Environment.NewLine + " UNION ALL "
            strSQL += System.Environment.NewLine + " SELECT DISTINCT RRNO ROUGHRECEIPTNO, TO_CHAR(RRDATE,'DD/MM/YYYY') ROUGHRECEIPTDATE, CHALLANNO PARTYCHALLANNO, TO_CHAR(CHALLANDATE,'') PARTYCHALLANDATE "
            strSQL += System.Environment.NewLine + "  FROM STORESCASHSRDETAILS "
            strSQL += System.Environment.NewLine + "  WHERE COMPANYCODE='" & HttpContext.Current.Session("COMPANYCODE") & "' "
            strSQL += System.Environment.NewLine + "   AND DIVISIONCODE='" & HttpContext.Current.Session("DIVISIONCODE") & "' "
            strSQL += System.Environment.NewLine + "   AND NVL(REJECTEDQUANTITY,0)>0 "
            strSQL += System.Environment.NewLine + " ) "
            strSQL += System.Environment.NewLine + " WHERE ROUGHRECEIPTNO='" + strAgainstNo + "' "
            strSQL += System.Environment.NewLine + " AND ROWNUM=1 "
            ''------------------------------------------------------------------------
        End If

        Try
            dbManager.Open()
            strPartydata = dbManager.ExecuteScalar(CommandType.Text, strSQL)
        Catch ex As Exception
            Throw New Exception(String.Format(ex.ToString))
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
        Return strPartydata
    End Function
    <WebMethod> _
    Public Shared Function fetchChallanDtls(strChallanNo As String) As String
        Dim strSQL As String
        Dim rcount As Integer = 0
        Dim strGriddata As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        strSQL = ""
        strSQL = strSQL & vbCrLf & "SELECT TO_CHAR(A.TRANSACTIONDATE,'DD/MM/YYYY')||'~'||A.OUTTYPE||'~'||A.PARTYCODE||'~'||B.PARTYNAME||'~'||A.REPRESENTATIVE||'~'||A.AGAINSTNO||'~'||TO_CHAR(A.AGAINSTDATE,'DD/MM/YYYY')||'~'||A.PARTYCHALLANNO||'~'||TO_CHAR(A.PARTYCHALLANDATE,'DD/MM/YYYY')||'~'||A.ISSNO XX "
        strSQL = strSQL & vbCrLf & " FROM STORESCHALLANOUTDETAILS A ,PARTYMASTER B"
        strSQL = strSQL & vbCrLf & "  WHERE A.COMPANYCODE = B.COMPANYCODE"
        strSQL = strSQL & vbCrLf & "  AND A.PARTYCODE = B.PARTYCODE"
        strSQL = strSQL & vbCrLf & "  AND A.COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
        strSQL = strSQL & vbCrLf & "   AND A.DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
        strSQL = strSQL & vbCrLf & "   AND PARTYTYPE ='SUPPLIER' "
        strSQL = strSQL & vbCrLf & "   AND MODULE = 'STORES' "
        strSQL = strSQL & vbCrLf & "   AND A.TRANSACTIONNO = '" & strChallanNo & "'"

        Try
            dbManager.Open()
            strGriddata = dbManager.ExecuteScalar(CommandType.Text, strSQL)
        Catch ex As Exception
            Throw New Exception(String.Format(ex.ToString))
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
        Return strGriddata
    End Function

    <WebMethod> _
    Public Shared Function fetchChallanDtlsGridData(strTransactionNo As String, strvarRRno As String, strOperationMode As String, strOutType As String) As String
        Dim dd As New pgStoresChallanOutDtls_GJPL()
        Dim str As String = dd.GetDataTableJson(dd.challanDtlsByTransNo(strTransactionNo, strvarRRno, strOperationMode, strOutType))
        Return str
    End Function

    Private Function challanDtlsByTransNo(strTransactionNo As String, strvarRRno As String, strOperationMode As String, strOutType As String) As DataTable
        Dim dtGridData As New DataTable
        Dim strSQL As String
        Dim rcount As Integer = 0

        Dim strVoucherDtlsdata As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        strSQL = ""
        If Trim(strOperationMode) = "A" Then
            If Trim(strOutType) = "REJECTION AGAINST RR" Then
                strSQL = strSQL & vbCrLf & "SELECT * FROM ( "
                strSQL = strSQL & vbCrLf & "SELECT R.ITEMCODE, I.ITEMDESC, R.ITEMUNITOFMEASUREMENT ITEMUOM, R.REJECTEDQUANTITY QUANTITY, R.REJECTIONREMARKS REMARKS, "
                strSQL = strSQL & vbCrLf & "       I.ITEMTYPE, 'STOCK OUT' TRANSACTIONTYPE, 'OUT' STKINDICATOR, R.PARTYCHALLANNO, TO_CHAR(R.PARTYCHALLANDATE,'DD/MM/YYYY') PARTYCHALLANDATE, "
                strSQL = strSQL & vbCrLf & "       '' REPRESENTATIVE, R.RRSERIALNO SERIALNO, R.REPAIRTYPE, '' DEPTCODE, R.CHARGEABLEACCOUNTCODE CHARGEACCODE, "
                strSQL = strSQL & vbCrLf & "       '' ISSNO, 0 AMTISSUE, R.UOMASPERPO UOMASPO, R.QTYASPERPO QUANTITYASPO, '" & Trim(strOutType) & "' OUTTYPE, "
                strSQL = strSQL & vbCrLf & "       '' TRANSACTIONNO, '' TRANSACTIONDATE, R.ROUGHRECEIPTNO AGAINSTNO, TO_CHAR(R.ROUGHRECEIPTDATE,'DD/MM/YYYY') AGAINSTDATE, R.PARTYCODE, "
                strSQL = strSQL & vbCrLf & "       '" & HttpContext.Current.Session("COMPANYCODE") & "' COMPANYCODE, '" & HttpContext.Current.Session("DIVISIONCODE") & "' DIVISIONCODE,  "
                strSQL = strSQL & vbCrLf & "       '" & HttpContext.Current.Session("YEARCODE") & "' YEARCODE, '" & HttpContext.Current.Session("USERNAME") & "' USERNAME, "
                strSQL = strSQL & vbCrLf & "       '" & strOperationMode & "' AS OPERATIONMODE, '' SYSROWID "
                strSQL = strSQL & vbCrLf & "  FROM STORESRECEIPTDETAILS R, STORESITEMMAST I "
                strSQL = strSQL & vbCrLf & " WHERE R.COMPANYCODE=I.COMPANYCODE "
                strSQL = strSQL & vbCrLf & "   AND R.DIVISIONCODE=I.DIVISIONCODE "
                strSQL = strSQL & vbCrLf & "   AND R.ITEMCODE=I.ITEMCODE "
                strSQL = strSQL & vbCrLf & "   AND R.COMPANYCODE='" & HttpContext.Current.Session("COMPANYCODE") & "' "
                strSQL = strSQL & vbCrLf & "   AND R.DIVISIONCODE='" & HttpContext.Current.Session("DIVISIONCODE") & "' "
                strSQL = strSQL & vbCrLf & "   AND R.ROUGHRECEIPTNO='" & Trim(strvarRRno) & "' "
                strSQL = strSQL & vbCrLf & "   AND NVL(R.REJECTEDQUANTITY,0)>0 "
                strSQL = strSQL & vbCrLf & "UNION ALL "
                strSQL = strSQL & vbCrLf & "SELECT R.ITEMCODE, I.ITEMDESC, R.ITEMUNITOFMEASUREMENT ITEMUOM, R.REJECTEDQUANTITY QUANTITY, R.REJECTIONREMARKS REMARKS, "
                strSQL = strSQL & vbCrLf & "       I.ITEMTYPE, 'STOCK OUT' TRANSACTIONTYPE, 'OUT' STKINDICATOR, R.CHALLANNO PARTYCHALLANNO, TO_CHAR(R.CHALLANDATE,'DD/MM/YYYY') PARTYCHALLANDATE, "
                strSQL = strSQL & vbCrLf & "       '' REPRESENTATIVE, R.SERIALNO, '' REPAIRTYPE, '' DEPTCODE, R.CHARGEABLEACCOUNTCODE CHARGEACCODE, "
                strSQL = strSQL & vbCrLf & "       '' ISSNO, 0 AMTISSUE, '' UOMASPO, 0 QUANTITYASPO, '" & Trim(strOutType) & "' OUTTYPE, "
                strSQL = strSQL & vbCrLf & "       '' TRANSACTIONNO, '' TRANSACTIONDATE, R.RRNO AGAINSTNO, TO_CHAR(R.RRDATE,'DD/MM/YYYY') AGAINSTDATE, R.PARTYCODE, "
                strSQL = strSQL & vbCrLf & "       '" & HttpContext.Current.Session("COMPANYCODE") & "' COMPANYCODE, '" & HttpContext.Current.Session("DIVISIONCODE") & "' DIVISIONCODE, "
                strSQL = strSQL & vbCrLf & "       '" & HttpContext.Current.Session("YEARCODE") & "' YEARCODE, '" & HttpContext.Current.Session("USERNAME") & "' USERNAME, "
                strSQL = strSQL & vbCrLf & "       '" & strOperationMode & "' AS OPERATIONMODE, '' SYSROWID "
                strSQL = strSQL & vbCrLf & "  FROM STORESCASHSRDETAILS R, STORESITEMMAST I "
                strSQL = strSQL & vbCrLf & " WHERE R.COMPANYCODE=I.COMPANYCODE "
                strSQL = strSQL & vbCrLf & "   AND R.DIVISIONCODE=I.DIVISIONCODE "
                strSQL = strSQL & vbCrLf & "   AND R.ITEMCODE=I.ITEMCODE "
                strSQL = strSQL & vbCrLf & "   AND R.COMPANYCODE='" & HttpContext.Current.Session("COMPANYCODE") & "' "
                strSQL = strSQL & vbCrLf & "   AND R.DIVISIONCODE='" & HttpContext.Current.Session("DIVISIONCODE") & "' "
                strSQL = strSQL & vbCrLf & "   AND R.RRNO='" & Trim(strvarRRno) & "' "
                strSQL = strSQL & vbCrLf & "   AND NVL(R.REJECTEDQUANTITY,0)>0 "
                strSQL = strSQL & vbCrLf & ") "
                strSQL = strSQL & vbCrLf & "ORDER BY AGAINSTNO, SERIALNO "
            Else
                strSQL = strSQL & vbCrLf & "  SELECT '' ITEMCODE, '' ITEMDESC, '' ITEMUOM, 0 QUANTITY, '' REMARKS,"
                strSQL = strSQL & vbCrLf & "          '' ITEMTYPE, '' TRANSACTIONTYPE, '' STKINDICATOR, '' PARTYCHALLANNO, '' PARTYCHALLANDATE,"
                strSQL = strSQL & vbCrLf & "          '' REPRESENTATIVE, 0 SERIALNO, '' REPAIRTYPE, '' DEPTCODE, '' CHARGEACCODE,"
                strSQL = strSQL & vbCrLf & "          '' ISSNO, 0 AMTISSUE, '' UOMASPO, 0 QUANTITYASPO, '" & Trim(strOutType) & "' OUTTYPE,"
                strSQL = strSQL & vbCrLf & "          '' TRANSACTIONNO, ''TRANSACTIONDATE, '' AGAINSTNO, '' AGAINSTDATE, '' PARTYCODE,"
                strSQL = strSQL & vbCrLf & "          '" & HttpContext.Current.Session("COMPANYCODE") & "' COMPANYCODE, '" & HttpContext.Current.Session("DIVISIONCODE") & "' DIVISIONCODE, "
                strSQL = strSQL & vbCrLf & "          '" & HttpContext.Current.Session("YEARCODE") & "' YEARCODE, '" & HttpContext.Current.Session("USERNAME") & "' USERNAME,"
                strSQL = strSQL & vbCrLf & "          '" & strOperationMode & "' AS OPERATIONMODE, '' SYSROWID "
                strSQL = strSQL & vbCrLf & "  FROM DUAL"
            End If
        Else
            strSQL = strSQL & vbCrLf & " SELECT ITEMCODE, ITEMDESC, ITEMUOM, QUANTITY, REMARKS,"
            strSQL = strSQL & vbCrLf & "    ITEMTYPE, TRANSACTIONTYPE, STKINDICATOR, PARTYCHALLANNO, TO_CHAR(PARTYCHALLANDATE,'DD/MM/YYYY')PARTYCHALLANDATE,"
            strSQL = strSQL & vbCrLf & "    REPRESENTATIVE, SERIALNO, REPAIRTYPE, DEPTCODE, CHARGEACCODE,"
            strSQL = strSQL & vbCrLf & "    ISSNO, AMTISSUE, UOMASPO, QUANTITYASPO, OUTTYPE,"
            strSQL = strSQL & vbCrLf & "    TRANSACTIONNO,TO_CHAR(TRANSACTIONDATE,'DD/MM/YYYY') TRANSACTIONDATE, AGAINSTNO, TO_CHAR(AGAINSTDATE,'DD/MM/YYYY') AGAINSTDATE, PARTYCODE,"
            strSQL = strSQL & vbCrLf & "    COMPANYCODE, DIVISIONCODE, YEARCODE, '" & HttpContext.Current.Session("USERNAME") & "' USERNAME,"
            strSQL = strSQL & vbCrLf & "    '" & strOperationMode & "' AS OPERATIONMODE, SYSROWID "
            strSQL = strSQL & vbCrLf & " FROM STORESCHALLANOUTDETAILS  "
            strSQL = strSQL & vbCrLf & "        WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "' "
            strSQL = strSQL & vbCrLf & "          AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "' "
            strSQL = strSQL & vbCrLf & "          AND YEARCODE = '" & HttpContext.Current.Session("YEARCODE") & "' "
            strSQL = strSQL & vbCrLf & "          AND TRANSACTIONNO = '" & strTransactionNo & "' "
            strSQL = strSQL & vbCrLf & "          AND OUTTYPE = '" & strOutType & "' "
            strSQL = strSQL & vbCrLf & "  UNION ALL"
            strSQL = strSQL & vbCrLf & "  SELECT '' ITEMCODE, '' ITEMDESC, '' ITEMUOM, 0 QUANTITY, '' REMARKS,"
            strSQL = strSQL & vbCrLf & "          '' ITEMTYPE, '' TRANSACTIONTYPE, '' STKINDICATOR, '' PARTYCHALLANNO, '' PARTYCHALLANDATE,"
            strSQL = strSQL & vbCrLf & "          '' REPRESENTATIVE, 0 SERIALNO, '' REPAIRTYPE, '' DEPTCODE, '' CHARGEACCODE,"
            strSQL = strSQL & vbCrLf & "          '' ISSNO, 0 AMTISSUE, '' UOMASPO, 0 QUANTITYASPO, '" & Trim(strOutType) & "' OUTTYPE,"
            strSQL = strSQL & vbCrLf & "          '' TRANSACTIONNO, ''TRANSACTIONDATE, '' AGAINSTNO, '' AGAINSTDATE, '' PARTYCODE,"
            strSQL = strSQL & vbCrLf & "          '" & HttpContext.Current.Session("COMPANYCODE") & "' COMPANYCODE, '" & HttpContext.Current.Session("DIVISIONCODE") & "' DIVISIONCODE, "
            strSQL = strSQL & vbCrLf & "          '" & HttpContext.Current.Session("YEARCODE") & "' YEARCODE, '" & HttpContext.Current.Session("USERNAME") & "' USERNAME,"
            strSQL = strSQL & vbCrLf & "          '" & strOperationMode & "' AS OPERATIONMODE, '' SYSROWID "
            strSQL = strSQL & vbCrLf & "  FROM DUAL"
        End If

        Try
            dbManager.Open()
            dtGridData = dbManager.ExecuteDataTable(CommandType.Text, strSQL)
        Catch ex As Exception
            Throw New Exception(String.Format(ex.ToString))
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
        Return dtGridData
    End Function

    <WebMethod> _
    Public Shared Function getItemDtls(strItemCode As String) As String
        Dim strSQL As String
        Dim rcount As Integer = 0
        Dim strGriddata As String = ""
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager
        strSQL = ""
        strSQL = strSQL & vbCrLf & "SELECT ITEMDESC||'~'||ITEMUOM "
        strSQL = strSQL & vbCrLf & " FROM STORESITEMMAST "
        strSQL = strSQL & vbCrLf & "  WHERE COMPANYCODE = '" & HttpContext.Current.Session("COMPANYCODE") & "'"
        strSQL = strSQL & vbCrLf & "   AND DIVISIONCODE = '" & HttpContext.Current.Session("DIVISIONCODE") & "'"
        strSQL = strSQL & vbCrLf & "   AND UPPER(ITEMCODE) = UPPER('" & strItemCode & "') "

        Try
            dbManager.Open()
            strGriddata = dbManager.ExecuteScalar(CommandType.Text, strSQL)
            If IsNothing(strGriddata) Then
                strGriddata = "NoData"
            Else
                strGriddata = strGriddata
            End If
        Catch ex As Exception
            Throw New Exception(String.Format(ex.ToString))
        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try
        Return strGriddata
    End Function


    Private Sub prcUpdateChallanGridData()
        If dtTmp Is Nothing Or dtTmp.Rows.Count = 0 Then
            Exit Sub
        End If
        Dim intRows As Integer = 0
        Dim strSQL As String = ""

        Dim strITEMDESC As String = ""
        Dim strTRANSACTIONTYPE = "STOCK OUT"
        Dim strSTKINDICATOR = "OUT"
        Dim strOUTTYPE = ""
        Dim strPARTYCODE = ""
        Dim strREPRESENTATIVE = ""
        Dim strOperationMode = ""
        Dim SlNo = 0
        Dim dbManager As SW_DBObject.DBManager = New SW_DBObject.DBManager

        CreateColumn(dtTmp, "ITEMDESC")
        CreateColumn(dtTmp, "TRANSACTIONNO")

        CreateColumn(dtTmp, "TRANSACTIONDATE")
        CreateColumn(dtTmp, "OUTTYPE")
        CreateColumn(dtTmp, "PARTYCODE")
        CreateColumn(dtTmp, "REPRESENTATIVE")
        CreateColumn(dtTmp, "TRANSACTIONTYPE")
        CreateColumn(dtTmp, "STKINDICATOR")
        CreateColumn(dtTmp, "SERIALNO")
        CreateColumn(dtTmp, "AGAINSTNO")
        CreateColumn(dtTmp, "AGAINSTDATE")
        CreateColumn(dtTmp, "PARTYCHALLANNO")
        CreateColumn(dtTmp, "PARTYCHALLANDATE")
        CreateColumn(dtTmp, "ISSNO")
        CreateColumn(dtTmp, "COMPANYCODE")
        CreateColumn(dtTmp, "DIVISIONCODE")
        CreateColumn(dtTmp, "YEARCODE")
        CreateColumn(dtTmp, "USERNAME")
        CreateColumn(dtTmp, "OPERATIONMODE")

        Try
            dbManager.Open()
            With dtTmp
                For intRows = 0 To .Rows.Count - 1
                    If Len(Trim(.Rows(intRows).Item("ITEMDESC") & "")) > 0 Then
                        SlNo = SlNo + 1
                        dtTmp.Rows(intRows).Item("TRANSACTIONNO") = txtTRANSACTIONNO.Text
                        dtTmp.Rows(intRows).Item("TRANSACTIONDATE") = mskTRANSACTIONDATE.Text
                        dtTmp.Rows(intRows).Item("OUTTYPE") = cmbOUTTYPE.Text
                        dtTmp.Rows(intRows).Item("PARTYCODE") = txtPARTYCODE.Text
                        dtTmp.Rows(intRows).Item("REPRESENTATIVE") = txtREPRESENTATIVE.Text
                        dtTmp.Rows(intRows).Item("TRANSACTIONTYPE") = strTRANSACTIONTYPE
                        dtTmp.Rows(intRows).Item("STKINDICATOR") = strSTKINDICATOR
                        dtTmp.Rows(intRows).Item("SERIALNO") = SlNo
                        dtTmp.Rows(intRows).Item("AGAINSTNO") = txtAGAINSTNO.Text
                        dtTmp.Rows(intRows).Item("AGAINSTDATE") = mskAGAINSTDATE.Text
                        dtTmp.Rows(intRows).Item("PARTYCHALLANNO") = txtPARTYCHALLANNO.Text
                        dtTmp.Rows(intRows).Item("PARTYCHALLANDATE") = mskPARTYCHALLANDATE.Text
                        dtTmp.Rows(intRows).Item("ISSNO") = txtVehicleNumber.Text
                        dtTmp.Rows(intRows).Item("COMPANYCODE") = HttpContext.Current.Session("COMPANYCODE")
                        dtTmp.Rows(intRows).Item("DIVISIONCODE") = HttpContext.Current.Session("DIVISIONCODE")
                        dtTmp.Rows(intRows).Item("YEARCODE") = HttpContext.Current.Session("YEARCODE")
                        dtTmp.Rows(intRows).Item("USERNAME") = HttpContext.Current.Session("USERNAME")
                        dtTmp.Rows(intRows).Item("OPERATIONMODE") = txtOPTMODE.Text
                    End If
                Next
            End With
            If Len(Trim(strSQL)) > 0 Then
                dtTmp = dbManager.ExecuteDataTable(CommandType.Text, strSQL)
                dtTmp.TableName = "Table1"
            End If
        Catch ex As Exception

        Finally
            dbManager.Close()
            dbManager.Dispose()
            dbManager = Nothing
        End Try

    End Sub

    Public Sub CreateColumn(ByVal dtTable As DataTable, ByVal colName As String)
        If Not dtTable.Columns.Contains(colName) Then
            dtTable.Columns.Add(colName)
        End If
    End Sub

    Public Function ValidatePage() As Boolean
        Dim blnReturnValidate As Boolean = False
        Dim message As String = ""
        btnMasterSubmit = DirectCast(Master.FindControl("btnSubmit"), Button)
        Dim strITEMCODE = ""
        Dim strITEMDESC = ""
        Dim strITEMUOM = ""
        Dim strQUANTITY = ""
        Dim errCnt As Integer

        If Len(Trim(txtCHALLANGRIDDATA.Text)) > 4 Then
            GetData(txtCHALLANGRIDDATA.Text, "ITEMDESC")
        End If

        prcUpdateChallanGridData()
        If Not IsNothing(dtTmp) Then
            txtDETAILSTABLENAME.Text = "GBL_STORESCHALLANOUTDETAILS~" & ConvertDatatableToXML(dtTmp)
        End If



        If mskTRANSACTIONDATE.Text = "" Then
            message += "Error: Challan No. Can't be blank !!<br/>"
        End If
        If cmbOUTTYPE.Text.ToUpper = "--SELECT--" Then
            message += "Error: Select Out Type !!<br/>"
        End If
        If txtPARTYCODE.Text = "" Then
            message += "Error: Party Can't be blank !!<br/>"
        End If

        If txtREPRESENTATIVE.Text = "" Then
            message += "Error: Reference Can't be blank !!<br/>"
        End If

        For intRows = 0 To dtTmp.Rows.Count - 1
            ''------------------------------------------
            strITEMCODE = dtTmp.Rows(intRows).Item("ITEMCODE").ToString
            strITEMDESC = dtTmp.Rows(intRows).Item("ITEMDESC").ToString
            strITEMUOM = dtTmp.Rows(intRows).Item("ITEMUOM").ToString
            strQUANTITY = dtTmp.Rows(intRows).Item("QUANTITY").ToString


            If strITEMDESC.Length <= 0 Then
                message += "Error:Item Description can not be Blank !!<br />"
            Else
                strITEMDESC = dtTmp.Rows(intRows).Item("ITEMDESC").ToString()
                For i = 0 To dtTmp.Rows.Count - 1
                    If strITEMDESC = dtTmp.Rows(i).Item("ITEMDESC").ToString() And intRows <> i Then
                        errCnt = 1
                        Exit For
                    End If
                Next
            End If
            If strITEMUOM.Length <= 0 Then
                message += "Error:Item UOM can not be Blank !!<br />"
            End If
            If strQUANTITY.Length <= 0 Then
                message += "Error:Item Quantity can not be Blank !!<br />"
            End If
        Next
        If errCnt = 1 Then
            message += "Error: Item Can't be duplicate !! <br />"
        End If
        ''--------------
        If message <> "" Then
            message = "Following Errors are occured when save data<br />" + message
            strMessage.Text = message
            blnReturnValidate = False
        Else
            blnReturnValidate = True
        End If
        ''--------------
        Return blnReturnValidate
    End Function

End Class
