<%@ Page ValidateRequest="false" Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site1.Master" CodeBehind="pgPFStaffDataUpload.aspx.vb" Inherits="swterp.pgPFStaffDataUpload" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">
    &nbsp;<link href="../../../Lib/jquery-ui-1.11.2/jquery-ui.min.css" rel="stylesheet" /><link href="../../../Scripts/jquery.handsontable.full.css" rel="stylesheet" /><script src="../../../Scripts/modernizr-2.6.2.js" type="text/javascript"></script><script src="../../../Scripts/jquery-1.11.1.min.js" type="text/javascript"></script><script src="../../../Lib/jquery-ui-1.11.2/jquery-ui.min.js" type="text/javascript"></script><script src="../../../Scripts/jquery.handsontable.full.js" type="text/javascript"></script><script src="../../../Scripts/globalSearch.js" type="text/javascript"></script><script src="../../../Scripts/jquery.maskedinput.js"></script><script src="../../../Scripts/commonvalidations.js"></script><script type="text/javascript" language="javascript">
        $(document).ready(function () {
            $("#mskFROMDATE").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
            $("#mskTODATE").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
        });

        var noneditablecolor = function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
            td.style.backgroundColor = '#FFCCCC';
            td.style.color = 'black';
        };
        var editablecolor = function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
            td.style.backgroundColor = '#FFFFFF';
            td.style.color = 'black';
        };

        function Validate(obj, e) {
            var strCODE = obj.value;
            if (strCODE != null && strCODE != "[New Entry]" && strCODE != "[Select]" && strCODE != "" && strCODE != "undefined") {
                __doPostBack(obj.id, "TextChanged");
            }
        };

        function rePopulateGrid() {
            var data1 = document.getElementById('<%=txtGRIDDATA.ClientID%>').value;
            if (data1 != '') {
                var data = jQuery.parseJSON(data1);
                $("div").find("#dataTable").handsontable("loadData", data);
            }
        };
    </script><div align="center">
        <div id="divLoading" title="Loading..." style="display: none" class="popstyle" align="center">
            <div id='LoadingDetails' style='width: 200px; height: 100px; vertical-align: middle' align="center">
                <asp:Label ID="lblLoading" runat="server" Text="Loading.... Please wait..." Style="vertical-align: middle"></asp:Label>
                <img src="../../../buttons/ajax-loader.gif" style="vertical-align: middle" alt="Processing..." />
            </div>
        </div>
        <div id="popupdiv" title="Basic modal dialog" style="display: none" class="popstyle">
            <label id="search">Search : </label>
            <input id="SearchText" type="text" style='width: 200px;' />
            <div id='searchPanel' style='width: 500px; height: 260px; overflow: scroll'></div>
        </div>
        <table align="center" cellpadding="1" cellspacing="0" class="box_shade">
            <tr class="box_heading">
                <td colspan="6" align="center">
                    <asp:Label ID="lblHeader" Text="Staff PF Data Upload" runat="server"> </asp:Label>
                    <asp:TextBox ID="txtSYSROWID" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtCOMPCODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtGARDENCODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtDIVCODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtYEARCODE1" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtUSRNAME" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtOPTMODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtGRIDDATA" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtGRIDIMPORTEXPORT" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtGridCurRow" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtMessage" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtMENUTAG" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtMENUTAG1" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtMENUTAG2" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtCOLUMN" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtFIELD" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtHEADER" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtLENGTH" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtSOURCE_QUERY" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtTARGET_TABLE_NAME" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtFILE_NAME_WITH_PATH" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtTEMP_TARGET_TABLE_NAME" runat="server" Style="display: none"></asp:TextBox>
                    <asp:Label ID="strExportFiles" runat="server" Style="display: none"> </asp:Label>
                    <asp:TextBox ID="txtEXCELFilename" runat="server" Style="display: none"></asp:TextBox>
                </td>
            </tr>
            <tr align="left" class="trUpload1">
                <td align="left" colspan="3">
                    <asp:Label ID="Label2" Text="Year Month : " runat="server"></asp:Label>
                    <asp:DropDownList ID="ddlYEARMONTH" runat="server" Width="100px" CausesValidation="True"></asp:DropDownList>
                    <asp:Label ID="lblMANDATORY1" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"> </asp:Label>
                </td>

                <td align="left">
                    <asp:FileUpload ID="FileUpload1" runat="server" onchange="UploadFile(this);" Width="345px" type="file" accept=".xls,.xlsx" Font-Bold="True" />
                </td>

                <td align="right">
                    <asp:Button ID="btnUPLOAD" runat="server" CssClass="button" Text="Get List" Width="100px" Style="margin-left: 0px" />
                </td>
            </tr>
            <tr>
                <td align="center" colspan="6">
                    <asp:Label ID="lblMsg" runat="server" BorderColor="White" Font-Bold="True" ForeColor="Red" Text="Please Select Proper File" Visible="false"></asp:Label>
                </td>
            </tr>
            <tr align="left">
                <td align="left" colspan="6" valign="top">
                    <asp:Panel ID="pnlDatatable" runat="server">
                        <div id="dataTable" style="overflow: auto; border: 1px solid olive; width: 780px; height: 230px;"></div>
                    </asp:Panel>
                </td>
            </tr>
        </table>
    </div>

    <script type="text/javascript" language="javascript">
        var noneditablecolor = function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
            //Handsontable.renderers.NumericRenderer.apply(this, arguments);
            td.style.backgroundColor = '#FFCCCC';
            td.style.color = 'black';
        };
        var editablecolor = function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
            td.style.backgroundColor = 'white';
            //td.style.fontWeight = 'bold';
            td.style.color = 'black';
        };

        var $container = $("div").find("#dataTable");
        $container.handsontable({
            data: [],
            colWidths: [70, 70, 150, 80, 80, 80, 80, 80, 90, 90, 1],
            startRows: 1,
            colHeaders: ['Token No', 'PF No.', 'Name', 'PF_E', 'PF_C', 'VPF', 'LOAN_CAP', 'LOAN_INT', 'Remarks', 'Update Status'],
            columns: [
              { data: "TOKENNO", readOnly: true, renderer: noneditablecolor },
              { data: "PFNO", readOnly: true, renderer: noneditablecolor },
              { data: "EMPLOYEENAME", readOnly: true, renderer: noneditablecolor },
              { data: "PF_E", type: 'numeric', format: '0.00' },
              { data: "PF_C", type: 'numeric', format: '0.00' },
              { data: "VPF", type: 'numeric', format: '0.00' },
              { data: "LOAN_CAP", type: 'numeric', format: '0.00' },
              { data: "LOAN_INT", type: 'numeric', format: '0.00' },
              { data: "REMARKS", readOnly: true, renderer: noneditablecolor },
              { data: "UPDATESTATUS", readOnly: true, renderer: noneditablecolor },
              { data: "WORKERSERIAL", readOnly: true, renderer: noneditablecolor },
            ],
            afterChange: AfterChange,
        });

        function UploadFile(fileUpload) {
            if (fileUpload.value != '') {
                    document.getElementById("<%=btnUPLOAD.ClientID%>").click();
            }
        }
        function returnColIndex(searchStr) {
            var DataFields =
                    [
                        "TOKENNO", "PFNO", "EMPLOYEENAME", "PF_E", "PF_C", "VPF", "LOAN_CAP", "LOAN_INT", "REMARKS", "UPDATESTATUS", "WORKERSERIAL"
                    ];
            for (var j = 0; j < DataFields.length; j++) {
                if (DataFields[j] == searchStr) {
                    return j;
                }
            }
            return -1;
        }

        function AfterChange(changes, data) {
            if (!changes) {
                return;
            }

            $.each(changes, function (index, element) {
                var change = element;
                var rowIndex = change[0];
                var columnIndex = change[1];
                //enableDisableCell(rowIndex);

                //if (columnIndex == "SELECTED") {
                //   if ($("#dataTable").handsontable('getDataAtCell', rowIndex, returnColIndex("SELECTED")) == "Y") {     
                //        enableDisableCell(rowIndex);
                //    }
                //    else {
                //        enableDisableCell(rowIndex);
                //    }
                // }

            });
            document.getElementById('<%=txtGRIDDATA.ClientID%>').value = '';
            fn_GetGridData();
        }

        function fn_GetGridData() {
            var $container = $("div").find("#dataTable");
            var handsontable = $container.data('handsontable');
            var myData = handsontable.getData();
            document.getElementById('<%=txtGRIDDATA.ClientID%>').value = JSON.stringify(myData);
        }

        function FetchGridData() {
            var SOURCE_QUERY = document.getElementById('<%=txtMENUTAG1.ClientID%>').value;
            var FILE_NAME_WITH_PATH = document.getElementById('<%=txtFILE_NAME_WITH_PATH.ClientID%>').value;
            var operationmode = document.getElementById('<%=txtOPTMODE.ClientID%>').value;
            //InvokeLoading();

            $.ajax({
                type: "POST",
                url: "pgPFStaffDataUpload.aspx/GetGridData",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ strSOURCE_QUERY: SOURCE_QUERY, strFILE_NAME_WITH_PATH: FILE_NAME_WITH_PATH, stroperationmode: operationmode }),
                dataType: "json",
                beforeSend: InvokeLoading(),
                success: function (res) {
                    part = res.d;
                    var data = JSON.parse(part);
                    $("div").find("#dataTable").handsontable('loadData', data);
                    // to initialize grid text box data after data fetching for later update without grid after event change
                    document.getElementById('<%=txtGRIDDATA.ClientID%>').value = part;
                    // to initialize grid text box data after data fetching for later update without grid after event change
                    //--- to hide columns
                    DisposeLoading();
                },
                error: function (xhr, status) {
                    DisposeLoading();
                    //alert("An error occurred: " + status);
                }
            });
        }


        function ValidateGridData() {
            var SOURCE_QUERY = document.getElementById('<%=txtSOURCE_QUERY.ClientID%>').value;
            var TARGET_TABLE_NAME = document.getElementById('<%=txtTARGET_TABLE_NAME.ClientID%>').value;
            var FILE_NAME_WITH_PATH = document.getElementById('<%=txtFILE_NAME_WITH_PATH.ClientID%>').value;
            var TEMP_TARGET_TABLE_NAME = document.getElementById('<%=txtTEMP_TARGET_TABLE_NAME.ClientID%>').value;
            var operationmode = document.getElementById('<%=txtOPTMODE.ClientID%>').value;
            //alert('strIndentFrom: '+ IndentFrom + ', strIndentTo: ' + IndentTo + ', operationmode: ' + operationmode);
            if (document.getElementById('<%=txtMENUTAG.ClientID%>').value == 'IMPORT_TAB') {
                //InvokeLoading();
                $.ajax({
                    type: "POST",
                    url: "pgPFStaffDataUpload.aspx/ValidateData",
                    contentType: "application/json; charset=utf-8",
                    data: JSON.stringify({ strSOURCE_QUERY: SOURCE_QUERY, strTARGET_TABLE_NAME: TARGET_TABLE_NAME, strFILE_NAME_WITH_PATH: FILE_NAME_WITH_PATH, strTEMP_TARGET_TABLE_NAME: TEMP_TARGET_TABLE_NAME, strOperationMode: operationmode }),
                    dataType: "json",
                    success: function (res) {
                        var str1 = res.d;
                        if (str1 != '') {
                            alert(str1);
                        }
                    },
                    error: function (xhr, status) {
                        alert("An error occurred: " + status);
                    }
                });
                //DisposeLoading();
            }
        };
    </script>
</asp:Content>

