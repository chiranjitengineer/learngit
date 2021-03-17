<%@ Page Title="" Language="vb" ValidateRequest="false" AutoEventWireup="false" MasterPageFile="~/Site1.Master" CodeBehind="pgStoresChallanOutDtls_GJPL.aspx.vb" Inherits="swterp.pgStoresChallanOutDtls_GJPL" %>

<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">

    <link href="../../../Lib/jquery-ui-1.11.2/jquery-ui.min.css" rel="stylesheet" />
    <link href="../../../Scripts/jquery.handsontable.full.css" rel="stylesheet" />
    <script src="../../../Scripts/modernizr-2.6.2.js"></script>
    <script src="../../../Scripts/jquery-1.11.1.min.js"></script>
    <script src="../../../Lib/jquery-ui-1.11.2/jquery-ui.min.js"></script>
    <script src="../../../Scripts/jquery.handsontable.full.js"></script>
    <script src="../../../Scripts/jquery-ui.custom.js"></script>
    <script src="../../../Scripts/globalSearch.js"></script>
    <script src="../../../Scripts/jquery.maskedinput.js"></script>
    <script src="../../../Scripts/jquery.qtip.js"></script>
    <link href="../../../Scripts/jquery.qtip.css" rel="stylesheet" />
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            $("#mskTRANSACTIONDATE").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
            $("#mskAGAINSTDATE").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
            $("#mskPARTYCHALLANDATE").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
        });
        //----------------Press F1 on TextBox inside Grid Cell
        function searchKeyDown(obj, e) {
            var strComp = document.getElementById('<%=txtCOMPCODE.ClientID%>');
            var strDiv = document.getElementById('<%=txtDIVCODE.ClientID%>');
            var strYear = document.getElementById('<%=txtYEARCODE.ClientID%>');
            var strOPTMODE = document.getElementById('<%=txtOPTMODE.ClientID%>').value;
            var strOuttype = document.getElementById('<%=cmbOUTTYPE.ClientID%>').value;
            var strParty = document.getElementById('<%=txtPARTYCODE.ClientID%>').value;

            var unicode = e.keyCode ? e.keyCode : e.charCode;
            if (unicode == 113) // F1=112, Enter=13, F2=113
            {
                if ((obj.id == "mainContent_txtTRANSACTIONNO") && (strOPTMODE != "A")) {
                    obj.value = '';
                    var strHelp = "4105^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~YEARCODE:" + strYear.value + "~^" + "^" + "Transaction No Listing^''"
                    InvokePop(obj.id, strHelp);
                }

                if (obj.id == "mainContent_txtPARTYCODE") {
                    obj.value = '';
                    var strHelp = "74^" + "COMPANYCODE:" + strComp.value + "~PARTYTYPE:SUPPLIER~MODULE:STORES~^^Supplier Information^''"
                    InvokePop(obj.id, strHelp);
                }

                if (obj.id == "mainContent_txtPARTYCODE") {
                    if (strOuttype == "--SELECT--" || strOuttype == "--Select--") {
                        alert("Select Out Type..");
                    } else {
                        obj.value = '';
                        var strHelp = "74^" + "COMPANYCODE:" + strComp.value + "~PARTYTYPE:SUPPLIER~MODULE:STORES~^^Supplier Information^''"
                        InvokePop(obj.id, strHelp);
                    }
                }
                if (obj.id == "mainContent_txtAGAINSTNO") {
                    if (strOuttype == "--SELECT--" || strOuttype == "--Select--") {
                        alert("Select Out Type..");
                    }
                    else if (strOuttype == "REJECTION W/O PO") {
                        obj.value = '';
                        var strHelp = "4110^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~^^Rejected Order Information^''"
                        InvokePop(obj.id, strHelp);
                    }
                    else if (strOuttype == "REJECTION AGAINST RR") {
                        obj.value = '';
                        var strHelp = "4111^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~PARTYCODE:" + strParty + "~^^Rejected RR Information^''"
                        InvokePop(obj.id, strHelp);
                    }
                }
            }
        };

        function Cleardata() {
            document.getElementById('<%=txtPARTYCODE.ClientID%>').value = '';
            document.getElementById('<%=txtAGAINSTNO.ClientID%>').value = '';
            document.getElementById('<%=txtREPRESENTATIVE.ClientID%>').value = '';
            document.getElementById('<%=txtVehicleNumber.ClientID%>').value = '';
            GetPartyDtlsData();
            document.getElementById('<%=mskAGAINSTDATE.ClientID%>').value = '';
            document.getElementById('<%=txtPARTYCHALLANNO.ClientID%>').value = '';
            document.getElementById('<%=mskPARTYCHALLANDATE.ClientID%>').value = '';
            GetChallanDtlsGridData();
        };

        function Validate(obj, e) {
            if (obj.id == "mainContent_txtTRANSACTIONNO") {
                var strCODE = obj.value;
                if (strCODE != null && strCODE != "") {
                    GetChallanHeaderData();
                }
            }
            if (obj.id == "mainContent_txtPARTYCODE") {
                var strCODE = obj.value;
                if (strCODE != null && strCODE != "") {
                    GetPartyDtlsData();
                    GetChallanDtlsGridData();
                }
            }
            if (obj.id == "mainContent_txtAGAINSTNO") {
                var strCODE = obj.value;
                if (strCODE != null && strCODE != "") {
                    GetAgainstDtlsData();
                }
            }
        };

        function GetPartyDtlsData() {
            var varPartyCode = document.getElementById('<%=txtPARTYCODE.ClientID%>').value;
            $.ajax(
            {
                type: "POST",
                url: "pgStoresChallanOutDtls_GJPL.aspx/fetchPartyDtls",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ strPartyCode: varPartyCode }),
                success: function (response) {
                    var str1 = (response.d);
                    var strDataArr = new Array();
                    if (str1 != '') {
                        strDataArr = str1.split("~");
                        document.getElementById('<%=txtPARTYNAME.ClientID%>').value = strDataArr[0];
                    }
                },
                error: function () {
                    alert("An error occurred: " + status);
                }
            });
        }

        function GetAgainstDtlsData() {
            var varAgainstNo = document.getElementById('<%=txtAGAINSTNO.ClientID%>').value;
            var varOuttype = document.getElementById('<%=cmbOUTTYPE.ClientID%>').value;
            $.ajax(
            {
                type: "POST",
                url: "pgStoresChallanOutDtls_GJPL.aspx/fetchAgainstDtls",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ strAgainstNo: varAgainstNo, strOuttype: varOuttype }),
                success: function (response) {
                    var str1 = (response.d);
                    var strDataArr = new Array();
                    if (str1 != '') {
                        strDataArr = str1.split("~");
                        document.getElementById('<%=mskAGAINSTDATE.ClientID%>').value = strDataArr[0];
                        document.getElementById('<%=txtPARTYCHALLANNO.ClientID%>').value = strDataArr[1];
                        document.getElementById('<%=mskPARTYCHALLANDATE.ClientID%>').value = strDataArr[2];
                        if (varOuttype == 'REJECTION AGAINST RR') {
                            GetChallanDtlsGridData();
                        }
                    }
                },
                error: function () {
                    alert("An error occurred: " + status);
                }
            });
        }

        function GetChallanHeaderData() {
            var varChallanNo = document.getElementById('<%=txtTRANSACTIONNO.ClientID%>').value;
            $.ajax(
            {
                type: "POST",
                url: "pgStoresChallanOutDtls_GJPL.aspx/fetchChallanDtls",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ strChallanNo: varChallanNo }),
                success: function (response) {
                    var str1 = (response.d);
                    var strDataArr = new Array();
                    if (str1 != '') {
                        strDataArr = str1.split("~");
                        document.getElementById('<%=mskTRANSACTIONDATE.ClientID%>').value = strDataArr[0];
                        document.getElementById('<%=cmbOUTTYPE.ClientID%>').value = strDataArr[1];
                        document.getElementById('<%=txtPARTYCODE.ClientID%>').value = strDataArr[2];
                        document.getElementById('<%=txtPARTYNAME.ClientID%>').value = strDataArr[3];
                        document.getElementById('<%=txtREPRESENTATIVE.ClientID%>').value = strDataArr[4];
                        document.getElementById('<%=txtAGAINSTNO.ClientID%>').value = strDataArr[5];
                        document.getElementById('<%=mskAGAINSTDATE.ClientID%>').value = strDataArr[6];
                        document.getElementById('<%=txtPARTYCHALLANNO.ClientID%>').value = strDataArr[7];
                        document.getElementById('<%=mskPARTYCHALLANDATE.ClientID%>').value = strDataArr[8];
                        document.getElementById('<%=txtVehicleNumber.ClientID%>').value = strDataArr[9];
                        GetChallanDtlsGridData();
                    }
                },
                //error: function (xhr, status) {
                //    alert("An error occurred in GetChallanHeaderData :" + status);
                //}
            });
        }

        function GetChallanDtlsGridData() {
            var varTransactionNo = document.getElementById('<%=txtTRANSACTIONNO.ClientID%>').value;
            var varTransactionDt = document.getElementById('<%=mskTRANSACTIONDATE.ClientID%>').value;
            var varRRno = document.getElementById('<%=txtAGAINSTNO.ClientID%>').value;
            var varOperationMode = document.getElementById('<%=txtOPTMODE.ClientID%>').value;
            var varOutType = document.getElementById('<%=cmbOUTTYPE.ClientID%>').value;
            $.ajax(
            {
                type: "POST",
                url: "pgStoresChallanOutDtls_GJPL.aspx/fetchChallanDtlsGridData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ strTransactionNo: varTransactionNo, strvarRRno: varRRno, strOperationMode: varOperationMode, strOutType: varOutType }),
                success: function (res) {
                    part = res.d;
                    var data = JSON.parse(part);
                    $("div").find("#gridChallanDtls").handsontable('loadData', data);
                    // to initialize grid text box data after data fetching for later update without grid after event change
                    document.getElementById('<%=txtCHALLANGRIDDATA.ClientID%>').value = part;
                },
                //error: function (xhr, status) {
                //    alert("An error occurred: " + status);
                //}
            });
        }

    </script>

    <div align="center">
        <div id="divLoading" title="Loading..." style="display: none" class="popstyle" align="center">
            <div id='LoadingDetails' style='width: 200px; height: 100px; vertical-align: middle' align="center">
                <asp:Label ID="lblLoading" runat="server" Text="Loading.... Please wait..." Style="vertical-align: middle"></asp:Label>
                <img src="../../../buttons/ajax-loader.gif" style="vertical-align: middle" alt="Processing..." />
            </div>
        </div>
        <div id="popupdiv" title="Details Information" class="popstyle">
            <label id="search">Search : </label>
            <input id="SearchText" type="text" style='width: 600px;' />
            <div id='searchPanel' style='width: auto; height: 260px; overflow: scroll'></div>
        </div>
        <table cellpadding="1" cellspacing="0" class="box_shade" width="900px">
            <tr class="box_heading">
                <td colspan="6" align="center">
                    <asp:Label ID="lblForHeader" runat="server" Text="CHALLAN OUT DETAILS"></asp:Label>
                    <asp:TextBox ID="txtCOMPCODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtDIVCODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtYEARCODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtOPTMODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtUSRNAME" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtCHALLANGRIDDATA" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtGridCellHelp" runat="server" Width="0px" Font-Size="1px" CausesValidation="true" onblur="fnGridFill(this,event);"></asp:TextBox>
                    <asp:TextBox ID="txtGridCurRow" runat="server" Width="10px" Style="display: none"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td align="left">
                    <asp:Label ID="lblChallanOutNo" Text="Challan Out No" runat="server" CssClass="labelcaption"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtTRANSACTIONNO" runat="server" Width="200px" CssClass="readonly" onkeydown="searchKeyDown(this,event);"
                        onblur="Validate(this,event);" ToolTip="Press F2 to select" TabIndex="1"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblChallanDate" Text="Challan Date" runat="server" CssClass="labelcaption"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="mskTRANSACTIONDATE" runat="server" Width="100px" ClientIDMode="Static" TabIndex="2"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblOutType" Text="Out Type" runat="server" CssClass="labelcaption"></asp:Label>
                </td>
                <td align="left">
                    <asp:DropDownList ID="cmbOUTTYPE" runat="server" Width="200px" TabIndex="3" onblur="Cleardata();"></asp:DropDownList>
                    <asp:Label ID="lblMANDATORY1" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"> </asp:Label>
                </td>
            </tr>
            <tr>
                <td align="left">
                    <asp:Label ID="lblPartyCode" Text="Party" runat="server" CssClass="labelcaption"></asp:Label>
                </td>
                <td colspan="5" align="left">
                    <asp:TextBox ID="txtPARTYCODE" runat="server" Width="150px" onkeydown="searchKeyDown(this,event);" onblur="Validate(this,event);" ToolTip="Press F2 to select" TabIndex="4"></asp:TextBox>&nbsp;
                    <asp:TextBox ID="txtPARTYNAME" runat="server" Width="600px" CssClass="readonly"></asp:TextBox>
                    <asp:Label ID="lblMANDATORY2" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"> </asp:Label>
                </td>
            </tr>
            <tr>
                <td align="left">
                    <asp:Label ID="lblReference" Text="Reference" runat="server" CssClass="labelcaption"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtREPRESENTATIVE" runat="server" Width="200px" TabIndex="5"></asp:TextBox>
                    <asp:Label ID="lblMANDATORY3" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"> </asp:Label>
                </td>
                <td align="left">
                    <asp:Label ID="Label1" Text="Vehicle No " runat="server" CssClass="labelcaption"></asp:Label>
                </td>
                <td colspan="3" align="left">
                    <asp:TextBox ID="txtVehicleNumber" runat="server" Width="150px" TabIndex="6"></asp:TextBox>
                </td>
            </tr>
            <tr style="display:none">
                <td align="left">
                    <asp:Label ID="lblAGAINSTNO" Text="Against Doc No " runat="server" CssClass="labelcaption"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtAGAINSTNO" runat="server" Width="150px" onkeydown="searchKeyDown(this,event);" onblur="Validate(this,event);" ToolTip="Press F2 to select" TabIndex="7"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblAGAINSTDATE" Text=" Against Doc Date " runat="server" CssClass="labelcaption"></asp:Label>
                </td>
                <td colspan="3" align="left">
                    <asp:TextBox ID="mskAGAINSTDATE" runat="server" Width="150px" ClientIDMode="Static" TabIndex="8"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td align="left">
                    <asp:Label ID="lblPARTYCHALLANNO" Text="Party Challan No " runat="server" CssClass="labelcaption"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtPARTYCHALLANNO" runat="server" Width="150px" TabIndex="9"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblPARTYCHALLANDATE" Text="Party Challan Date " runat="server" CssClass="labelcaption"></asp:Label>
                </td>
                <td colspan="3" align="left">
                    <asp:TextBox ID="mskPARTYCHALLANDATE" runat="server" Width="150px" ClientIDMode="Static" TabIndex="10"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td align="left" style="background-color: white" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <asp:Label ID="lblCellDesc" Text="" runat="server" Font-Bold="False" ForeColor="#800000" BackColor="#ffffcc" CssClass="labelcaption"></asp:Label>
                </td>
            </tr>
            <tr>
                <td colspan="6" align="left">
                    <table width="100%" border="1">
                        <tr>
                            <td>
                                <asp:Panel ID="gridPanel" runat="server" Width="900px">
                                    <div id="gridChallanDtls" style="overflow: auto; border: 1px solid olive; width: 100%; height: 250px;">
                                    </div>
                                </asp:Panel>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>

    <%-- FIRST GRID --%>
    <script type="text/javascript">

        function returnColIndex(searchStr) {
            //var DataFields =
            //[
            //    "ITEMCODE",
            //    "ITEMDESC",
            //    "ITEMUOM",
            //    "QUANTITY",
            //    "REMARKS",
            //    "ITEMTYPE",
            //    "TRANSACTIONTYPE",
            //    "STKINDICATOR",
            //    "PARTYCHALLANNO",
            //    "PARTYCHALLANDATE",
            //    "REPRESENTATIVE",
            //    "SERIALNO",
            //    "REPAIRTYPE",
            //    "DEPTCODE",
            //    "CHARGEACCODE",
            //    "ISSNO",
            //    "AMTISSUE",
            //    "UOMASPO",
            //    "QUANTITYASPO",
            //    "OUTTYPE",
            //    "TRANSACTIONNO",
            //    "TRANSACTIONDATE",
            //    "AGAINSTNO",
            //    "AGAINSTDATE",
            //    "PARTYCODE",
            //    "COMPANYCODE",
            //    "DIVISIONCODE",
            //    "YEARCODE",
            //    "LASTMODIFIED",
            //    "USERNAME",
            //    "OPERATIONMODE",
            //    "SYSROWID"
            //];

            var DataFields = $('#gridChallanDtls').data('handsontable').getSettings().columns;
            for (var j = 0; j < DataFields.length; j++) {
                if (DataFields[j].data == searchStr) {
                    return j;
                }
            }
            return -1;
        }


        var noneditablecolor = function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
            td.style.backgroundColor = '#FFCCCC';
            //td.style.fontWeight = 'bold';
            td.style.color = 'black';
        };

        var editablecolor = function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
            td.style.backgroundColor = '#FFFACD';
            //td.style.fontWeight = 'bold';
            td.style.color = 'black';
        };


        var $container = $("div").find("#gridChallanDtls");
        $container.handsontable({
            data: [],
            colWidths: [120, 100, 400, 50, 100, 110, 400, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
            startRows: 1,
            startCols: 2,
            currentRowClassName: 'currentRow',
            currentColClassName: 'currentCol',
            //fixedRowsTop: 0,
            //fixedColumnsLeft: 3,
            minSpareRows: 1,
            fillHandle: false,
            manualColumnResize: true,
            contextMenu: ["remove_row"],
            colHeaders: ['Against Doc No', 'Item Code', 'Item Description', 'UOM', 'Quantity', 'Returnable (Y/N)', 'Remarks', 'ITEMTYPE', 'TRANSACTIONTYPE',
                         'STKINDICATOR', 'PARTYCHALLANNO', 'PARTYCHALLANDATE', 'REPRESENTATIVE', 'SERIALNO', 'REPAIRTYPE',
                         'DEPTCODE', 'CHARGEACCODE', 'ISSNO', 'AMTISSUE', 'UOMASPO', 'QUANTITYASPO', 'OUTTYPE', 'TRANSACTIONNO',
                         'TRANSACTIONDATE', 'AGAINSTNO', 'AGAINSTDATE', 'PARTYCODE', 'COMPANYCODE', 'DIVISIONCODE', 'YEARCODE', 'LASTMODIFIED', 'USERNAME', 'SYSROWID'],
            columns: [
              { data: "AGAINSTNO", readOnly: true, type: 'text', language: 'en' },
              { data: "ITEMCODE", readOnly: false, type: 'text', language: 'en' },
              { data: "ITEMDESC", readOnly: true, type: 'text', language: 'en' },
              { data: "ITEMUOM", readOnly: true, type: 'text', language: 'en' },
              { data: "QUANTITY", readOnly: false, format: '0.000', type: 'numeric', language: 'en' },
              { data: "ISRETURNABLE", type: 'dropdown', source: ['Y', 'N'], readOnly: false, type: 'text', language: 'en' },
              { data: "REMARKS", readOnly: false, type: 'text', language: 'en' },
              { data: "ITEMTYPE", readOnly: true, type: 'text', language: 'en' },
              { data: "TRANSACTIONTYPE", readOnly: true, type: 'text', language: 'en' },
              { data: "STKINDICATOR", readOnly: true, type: 'text', language: 'en' },
              { data: "PARTYCHALLANNO", readOnly: true, type: 'text', language: 'en' },
              { data: "PARTYCHALLANDATE", readOnly: true, type: 'text', language: 'en' },
              { data: "REPRESENTATIVE", readOnly: true, type: 'text', language: 'en' },
              { data: "SERIALNO", readOnly: true, type: 'text', language: 'en' },
              { data: "REPAIRTYPE", readOnly: true, type: 'text', language: 'en' },
              { data: "DEPTCODE", readOnly: true, type: 'text', language: 'en' },
              { data: "CHARGEACCODE", readOnly: true, type: 'text', language: 'en' },
              { data: "ISSNO", readOnly: true, type: 'text', language: 'en' },
              { data: "AMTISSUE", readOnly: true, type: 'text', language: 'en' },
              { data: "UOMASPO", readOnly: true, type: 'text', language: 'en' },
              { data: "QUANTITYASPO", readOnly: true, type: 'text', language: 'en' },
              { data: "OUTTYPE", readOnly: true, type: 'text', language: 'en' },
              { data: "TRANSACTIONNO", readOnly: true, type: 'text', language: 'en' },
              { data: "TRANSACTIONDATE", readOnly: true, type: 'text', language: 'en' },
              //{ data: "AGAINSTNO", readOnly: true, type: 'text', language: 'en' },
              { data: "AGAINSTDATE", readOnly: true, type: 'text', language: 'en' },
              { data: "PARTYCODE", readOnly: true, type: 'text', language: 'en' },
              { data: "COMPANYCODE", readOnly: true, type: 'text', language: 'en' },
              { data: "DIVISIONCODE", readOnly: true, type: 'text', language: 'en' },
              { data: "YEARCODE", readOnly: true, type: 'text', language: 'en' },
              { data: "LASTMODIFIED", readOnly: true, type: 'text', language: 'en' },
              { data: "USERNAME", readOnly: true, type: 'text', language: 'en' },
              { data: "OPERATIONMODE", readOnly: true, type: 'text', language: 'en' },
              { data: "SYSROWID", readOnly: true, type: 'text', language: 'en' },
            ],

            afterChange: AfterChange,
            onSelection: fnselectRow,
            afterRemoveRow: deleteTableRow,
            afterOnCellMouseOver: handleAfterOnCellMouseOver,
            cells: function (row, col, prop) {
                var varOutType = document.getElementById('<%=cmbOUTTYPE.ClientID%>').value;
                var hot2 = $("#gridChallanDtls").handsontable('getInstance');


                var strAGAINSTNO = hot2.getDataAtRowProp(row, "AGAINSTNO");
                var strITEMCODE = hot2.getDataAtRowProp(row, "ITEMCODE");
                var strITEMDESC = hot2.getDataAtRowProp(row, "ITEMDESC");
                var jsData = hot2.getData();

                if (strAGAINSTNO == null) strAGAINSTNO = '';
                if (strITEMCODE == null) strITEMCODE = '';
                if (strITEMDESC == null) strITEMDESC = '';

                console.log(row);
                console.log(col);
                console.log(prop);
                console.log(jsData);
                console.log('strAGAINSTNO');
                console.log(strAGAINSTNO);
                console.log('ITEMCODE');
                console.log(strITEMCODE);

                var cellVal = hot2.getDataAtRowProp(row, prop)

                var cellProperties = {};


                //REJECTION W/O PO
                //REPAIR
                //SAMPLE
                //MISC
                //REJECTION AGAINST RR
                //REJECTION AGAINST DEBIT NOTE
                //REPLACEMENT

                varOutType = String(varOutType).toUpperCase();

                if (varOutType == "REJECTION W/O PO" ||
                    varOutType == "SAMPLE" ||
                    varOutType == "MISC" ||
                    varOutType == "REPAIR"
                    ) {
                    if (prop != "AGAINSTNO" && prop != "ITEMCODE") {
                        if (String(strITEMCODE) != '' && String(strITEMCODE) != 'undefined') {
                            //cellProperties.editor = false;
                            console.log(cellProperties.readOnly);
                            cellProperties.readOnly = true;
                        } else {
                            cellProperties.readOnly = false;
                            console.log(cellProperties.readOnly);
                            //cellProperties.editor = 'text';
                        }
                    } else {
                        cellProperties.readOnly = false;
                        console.log(cellProperties.readOnly);
                        //cellProperties.editor = 'text';
                    }
                }
                else if (String(varOutType).toUpperCase() == "REJECTION AGAINST RR") {
                }
                else if (String(varOutType).toUpperCase() == "REJECTION AGAINST DEBIT NOTE") {
                }
                else if (String(varOutType).toUpperCase() == "REPLACEMENT") {
                }


                //AGAINSTNO
                //ITEMCODE 
                //ITEMDESC 
                //ITEMUOM 

                //console.log(strAGAINSTNO);
                //console.log(strITEMCODE);
                //console.log(strITEMDESC);
                //console.log(String(strITEMCODE));






                return cellProperties;
            },
            beforeKeyDown: function (e) {
                var gridrowcolumns = $('#gridChallanDtls').handsontable('getInstance');
                var currRow = gridrowcolumns.getSelected();
                var strComp1 = document.getElementById('<%=txtCOMPCODE.ClientID%>');
                var strDiv1 = document.getElementById('<%=txtDIVCODE.ClientID%>');
                //alert(e.charCode + ' ' + e.keyCode + $('[ID$=txtAGAINSTNO]').attr('id'));

                var strComp = document.getElementById('<%=txtCOMPCODE.ClientID%>');
                var strDiv = document.getElementById('<%=txtDIVCODE.ClientID%>');
                var strYear = document.getElementById('<%=txtYEARCODE.ClientID%>');
                var strOPTMODE = document.getElementById('<%=txtOPTMODE.ClientID%>').value;
                var strOuttype = document.getElementById('<%=cmbOUTTYPE.ClientID%>').value;
                var strParty = document.getElementById('<%=txtPARTYCODE.ClientID%>').value;
                var varOutType = document.getElementById('<%=cmbOUTTYPE.ClientID%>').value;

                var key = e.charCode || e.keyCode;
                key = 0;

                var unicode = e.keyCode ? e.keyCode : e.charCode

                if (currRow[1] == returnColIndex("REMARKS")) {
                    var key = e.charCode || e.keyCode; // to support all browsers                    
                    if (key == 9 || key == 39 || key == 40) { // Right-37,Up-38,Left-39, Down-40, Tab-9 Key            
                        if ($("#gridChallanDtls").handsontable('getDataAtCell', currRow[0], returnColIndex("ITEMDESC")).length > 0) {
                            $("#gridChallanDtls").handsontable('alter', 'insert_row', Number(currRow[0]) + 1);
                            $("#gridChallanDtls").handsontable('selectCell', Number(currRow[0]) + 1, returnColIndex("ITEMCODE"));
                        }
                    }
                }
                else if (unicode == 113) // F1=112, Enter=13, F2=113
                {
                    if (currRow[1] == returnColIndex("QUANTITY")) {
                        if (varOutType == 'REJECTION AGAINST RR') {
                            e.stopImmediatePropagation();
                            e.preventDefault();
                            var key = e.charCode || e.keyCode;
                            key = 0;
                        }
                    }
                    else if (currRow[1] == returnColIndex("AGAINSTNO")) {
                        if (varOutType == 'REJECTION AGAINST RR') {
                            e.stopImmediatePropagation();
                            e.preventDefault();
                            document.getElementById('<%=txtGridCurRow.ClientID%>').value = currRow[0] + ',' + currRow[1];
                            //var strHelp = "74^" + "COMPANYCODE:" + strComp.value + "~PARTYTYPE:SUPPLIER~MODULE:STORES~^^Supplier Information^''"
                            var strHelp = "4111^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~PARTYCODE:" + strParty + "~^^Rejected RR Information^''"
                            console.log(currRow);
                            console.log(strHelp);
                            InvokePop('mainContent_txtGridCellHelp', strHelp);
                            console.log(document.getElementById('<%=txtGridCurRow.ClientID%>').value);
                        }
                    }
                    else if (currRow[1] == returnColIndex("ITEMCODE")) {

                        var strAGAINSTNO = $("#gridChallanDtls").handsontable('getDataAtCell', currRow[0], returnColIndex("AGAINSTNO"));

                        if (varOutType == 'REJECTION AGAINST RR') {
                            e.stopImmediatePropagation();
                            e.preventDefault();
                            document.getElementById('<%=txtGridCurRow.ClientID%>').value = currRow[0] + ',' + currRow[1];

                            var strHelp = "4401^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~ROUGHRECEIPTNO:" + strAGAINSTNO + "~^^Rejected RR Information^''"
                            console.log(currRow);
                            console.log(strHelp);
                            InvokePop('mainContent_txtGridCellHelp', strHelp);
                            console.log(document.getElementById('<%=txtGridCurRow.ClientID%>').value);
                        }
                        else if (varOutType == 'REJECTION W/O PO') {
                            e.stopImmediatePropagation();
                            e.preventDefault();
                            document.getElementById('<%=txtGridCurRow.ClientID%>').value = currRow[0] + ',' + currRow[1];

                            var strHelp = "4401^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~ROUGHRECEIPTNO:" + strAGAINSTNO + "~^^Rejected RR Information^''"
                            console.log(currRow);
                            console.log(strHelp);
                            InvokePop('mainContent_txtGridCellHelp', strHelp);
                            console.log(document.getElementById('<%=txtGridCurRow.ClientID%>').value);
                        }
                    }
                }
            },
        });


        function fnselectRow() {
            var gridrowcolumns = $('#gridChallanDtls').handsontable('getInstance');
            var currRow = gridrowcolumns.getSelected();

            var num_rows = $("#gridChallanDtls").handsontable('countRows');
            if (num_rows > 0) {
                var currRow = gridrowcolumns.getSelected();
                var strCellDesc = $("#gridChallanDtls").handsontable('getDataAtCell', currRow[0], currRow[1]);
                document.getElementById('<%=lblCellDesc.ClientID%>').innerHTML = strCellDesc;
            }
        }

        function deleteTableRow() {
            document.getElementById('<%=txtCHALLANGRIDDATA.ClientID%>').value = '';
            fn_GetGridData();
        };


        function AfterChange(changes, data) {
            if (!changes) {
                return;
            }

            $.each(changes, function (index, element) {
                var change = element;
                var rowIndex = change[0];
                var columnIndex = change[1];
                var num_rows = $("#gridChallanDtls").handsontable('countRows');
                var str1 = "";


                var varOutType = document.getElementById('<%=cmbOUTTYPE.ClientID%>').value;


                if (String(varOutType).toUpperCase() == "REJECTION W/O PO") {

                }
                else if (String(varOutType).toUpperCase() == "REPAIR") {
                }
                else if (String(varOutType).toUpperCase() == "SAMPLE") {
                }
                else if (String(varOutType).toUpperCase() == "MISC") {
                }
                else if (String(varOutType).toUpperCase() == "REJECTION AGAINST RR") {
                }
                else if (String(varOutType).toUpperCase() == "REJECTION AGAINST DEBIT NOTE") {
                }
                else if (String(varOutType).toUpperCase() == "REPLACEMENT") {
                }






                if (columnIndex == "ITEMCODE") {
                    document.getElementById('<%=txtGridCurRow.ClientID%>').value = rowIndex + ',' + columnIndex;
                    var varItemCode = $("#gridChallanDtls").handsontable('getDataAtCell', rowIndex, returnColIndex("ITEMCODE"));
                    if (varItemCode.length > 0) {
                        $.ajax({
                            url: 'pgStoresChallanOutDtls_GJPL.aspx/getItemDtls',
                            contentType: "application/json; charset=utf-8",
                            dataType: 'json',
                            data: JSON.stringify({ strItemCode: varItemCode }),
                            //data: {},
                            dataType: 'json',
                            type: 'POST',
                            success: function (response) {
                                str1 = (response.d);


                                if (String(varOutType).toUpperCase() == "REJECTION W/O PO") {

                                    if (str1 == "NoData") {
                                        alert("Invalid Item Code");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMCODE'), "");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMDESC'), "");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMUOM'), "");
                                    } else {
                                        var strDataArr = new Array();
                                        strDataArr = str1.split("~");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMDESC'), strDataArr[0]);
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMUOM'), strDataArr[1]);
                                    }
                                }
                                else if (String(varOutType).toUpperCase() == "REPAIR") {

                                    if (str1 == "NoData") {
                                        alert("Invalid Item Code");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMCODE'), "");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMDESC'), "");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMUOM'), "");
                                    } else {
                                        var strDataArr = new Array();
                                        strDataArr = str1.split("~");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMDESC'), strDataArr[0]);
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMUOM'), strDataArr[1]);
                                    }
                                }
                                else if (String(varOutType).toUpperCase() == "SAMPLE") {

                                    if (str1 == "NoData") {
                                        alert("Invalid Item Code");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMCODE'), "");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMDESC'), "");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMUOM'), "");
                                    } else {
                                        var strDataArr = new Array();
                                        strDataArr = str1.split("~");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMDESC'), strDataArr[0]);
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMUOM'), strDataArr[1]);
                                    }
                                }
                                else if (String(varOutType).toUpperCase() == "MISC") {

                                    if (str1 == "NoData") {
                                        alert("Invalid Item Code");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMCODE'), "");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMDESC'), "");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMUOM'), "");
                                    } else {
                                        var strDataArr = new Array();
                                        strDataArr = str1.split("~");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMDESC'), strDataArr[0]);
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMUOM'), strDataArr[1]);
                                    }
                                }
                                else if (String(varOutType).toUpperCase() == "REJECTION AGAINST RR") {

                                    if (str1 == "NoData") {
                                        alert("Invalid Item Code");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMCODE'), "");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMDESC'), "");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMUOM'), "");
                                    } else {
                                        var strDataArr = new Array();
                                        strDataArr = str1.split("~");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMDESC'), strDataArr[0]);
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMUOM'), strDataArr[1]);
                                    }
                                }
                                else if (String(varOutType).toUpperCase() == "REJECTION AGAINST DEBIT NOTE") {

                                    if (str1 == "NoData") {
                                        alert("Invalid Item Code");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMCODE'), "");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMDESC'), "");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMUOM'), "");
                                    } else {
                                        var strDataArr = new Array();
                                        strDataArr = str1.split("~");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMDESC'), strDataArr[0]);
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMUOM'), strDataArr[1]);
                                    }
                                }
                                else if (String(varOutType).toUpperCase() == "REPLACEMENT") {

                                    if (str1 == "NoData") {
                                        alert("Invalid Item Code");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMCODE'), "");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMDESC'), "");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMUOM'), "");
                                    } else {
                                        var strDataArr = new Array();
                                        strDataArr = str1.split("~");
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMDESC'), strDataArr[0]);
                                        $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMUOM'), strDataArr[1]);
                                    }
                                }
                            }
                        }); // End Ajax 
                    }
                }
            });

            document.getElementById('<%=txtCHALLANGRIDDATA.ClientID%>').value = '';
            fn_GetGridData();
        }

        function fn_GetGridData() {
            var $container = $("div").find("#gridChallanDtls");
            var handsontable = $container.data('handsontable');
            var myData = handsontable.getData();
            document.getElementById('<%=txtCHALLANGRIDDATA.ClientID%>').value = JSON.stringify(myData);
        }

        function PopulateChallandetailsGrid() {
            var data1 = document.getElementById('<%=txtCHALLANGRIDDATA.ClientID%>').value;
            var data = jQuery.parseJSON(data1);
            $("div").find("#gridChallanDtls").handsontable("loadData", data);
        }

        //-------------------------------
        function fnGridFill(obj, e) {
            var strCODE = obj.value;
            if (obj.id == "mainContent_txtGridCellHelp") {
                curRow = document.getElementById('<%=txtGridCurRow.ClientID%>').value.split(',');
                fn_getGridFillData(curRow[0], curRow[1]);
            }
        }

        function fn_getGridFillData(rowIndex, colIndex) {
            var str1 = document.getElementById('<%=txtGridCellHelp.ClientID%>').value;
            $("#gridChallanDtls").handsontable('setDataAtCell', Number(rowIndex), Number(colIndex), '');
            $("#gridChallanDtls").handsontable('setDataAtCell', Number(rowIndex), Number(colIndex), str1);

            <%--

            var str1 = document.getElementById('<%=txtGridCellHelp.ClientID%>').value;
            var strComp1 = document.getElementById('<%=txtCOMPCODE.ClientID%>')
            var strDiv1 = document.getElementById('<%=txtDIVCODE.ClientID%>')
            var strYearCode1 = document.getElementById('<%=txtYEARCODE.ClientID%>')
            var varOperationMode = document.getElementById('<%=txtOPTMODE.ClientID%>').value;

            ///alert(str1);
            var strDataArr = new Array();
            if (str1 != '') {
                strDataArr = str1.split("~");
                if (colIndex == 0) {
                    $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMCODE'), strDataArr[0]);
                    $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMDESC'), strDataArr[1]);
                    $("#gridChallanDtls").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMUOM'), strDataArr[2]);
                }
            }
           --%>
            $("#popupdiv").dialog('close');
        }
        //---------------------------------
    </script>
</asp:Content>
 