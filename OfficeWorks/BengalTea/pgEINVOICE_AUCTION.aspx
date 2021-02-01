<%@ Page Title="" Language="vb" ValidateRequest="false"  AutoEventWireup="false" MasterPageFile="~/Site1.Master" CodeBehind="pgEINVOICE_AUCTION.aspx.vb" Inherits="swterptea.pgEINVOICE_AUCTION" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">

    <link href="../../../Lib/jquery-ui-1.11.2/jquery-ui.min.css" rel="stylesheet" />
    <link href="../../../Scripts/jquery.handsontable.full.css" rel="stylesheet" />
    <script src="../../../Scripts/modernizr-2.6.2.js" type="text/javascript"></script>
    <script src="../../../Scripts/jquery-1.11.1.min.js" type="text/javascript"></script>
    <script src="../../../Lib/jquery-ui-1.11.2/jquery-ui.min.js" type="text/javascript"></script>
    <script src="../../../Scripts/jquery.handsontable.full.js" type="text/javascript"></script>
    <script src="../../../Scripts/globalSearch.js" type="text/javascript"></script>
    <link href="../../../Styles/theme1.css" rel="stylesheet" />
    <script src="../../../Scripts/jquery.maskedinput.js"></script>
    <script src="../../../Scripts/commonvalidations.js"></script>
    <script src="../../../Scripts/SeachInGrid.js"></script>
    <script src="../../../Scripts/jquery.pleaseWait.js"></script>
    <script src="../../../Scripts/jquery.maskedinput.js"></script>

    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            $("#mskDOCUMENTTDATEFROM").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
            $("#mskDOCUMENTTDATETO").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
        });



        function Validate(obj, e) {
            var strCODE = obj.value;
            if (strCODE != null && strCODE != "[New Entry]" && strCODE != "[Select]" && strCODE != "" && strCODE != "undefined") {
                __doPostBack(obj.id, "TextChanged");
            }
        };
    </script>
    <div align="center">
        <div id="divLoading" title="Searching..." style="display: none" class="popstyle" align="center">
            <div id='LoadingDetails' style='width: 200px; height: 100px; vertical-align: middle' align="center">
                <asp:Label ID="lblLoading" runat="server" Text="Searching.... Please wait..." Style="vertical-align: middle"></asp:Label>
                <img src="../../../buttons/ajax-loader.gif" style="vertical-align: middle" alt="Processing..." />
            </div>
        </div>

        <div id="divSeaching" title="Searching..." style="display: none" class="popstyle" align="center">
            <div id='Div2' style='width: 200px; height: 100px; vertical-align: middle' align="center">
                <asp:Label ID="Label4" runat="server" Text="Searching.... Please wait..." Style="vertical-align: middle"></asp:Label>
                <img src="../../../buttons/ajax-loader.gif" style="vertical-align: middle" alt="Processing..." />
            </div>
        </div>


        <div id="popupdiv" title="Basic modal dialog" class="popstyle">
            <label id="search">Search : </label>
            <input id="SearchText" type="text" style='width: 200px;' />
            <div id='searchPanel' style='width: auto; height: 260px; overflow: scroll'></div>
        </div>

        <table cellpadding="0" cellspacing="1" class="box_shade" style="height: 100px">

            <tr class="box_heading">
                <td colspan="4" align="center">
                    <asp:Label ID="lblHeader" Text="" runat="server"></asp:Label>
                    <br />
                    <asp:Label ID="lblYearcode" ForeColor="Yellow" runat="server" Style="display: none"> </asp:Label>
                    <asp:TextBox ID="txtGRIDDATA" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtGridCurRow" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtGridHelp" runat="server" Width="0.0001px" Height="0.0001px" onblur="fnGridFill(this,event);"></asp:TextBox>
                    <asp:TextBox ID="txtCOMPCODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtDIVCODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtOPTMODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtYEARCODE1" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtUSRNAME" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtSYSROWID" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtSEASONCODE1" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtMENUTAG" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtGSTIN" runat="server" Style="display: none"></asp:TextBox>
                </td>
            </tr>


            <tr>
                <td align="left">
                    <asp:Label ID="lblCHANNEL" Text="Channel" runat="server"> </asp:Label>
                </td>
                <td align="left" colspan="3">
                    <asp:DropDownList ID="ddlCHANNEL" runat="server" Width="320px" CausesValidation="True" TabIndex="1"></asp:DropDownList>
                    <asp:TextBox ID="txtCHANNEL" runat="server" Style="display: none"></asp:TextBox>
                </td>
                
            </tr>
            <tr>
                <td align="left">
                    <asp:Label ID="lblDOCUMENTDATE" Text="Document Date From" runat="server"> </asp:Label>
                </td>
                <td align="left" colspan="2">
                    <asp:TextBox ID="mskDOCUMENTTDATEFROM" runat="server" Width="100px" MaxLength="10" CausesValidation="True" ClientIDMode="Static" TabIndex="3"></asp:TextBox>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                     <asp:Label ID="Label1" Text="To" runat="server"> </asp:Label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <asp:TextBox ID="mskDOCUMENTTDATETO" runat="server" Width="100px" MaxLength="10" CausesValidation="True" ClientIDMode="Static" TabIndex="3"></asp:TextBox>
                </td>
                <td align="right">
                    <input type="button" id="btnGetList" value="Get Data" class="button" style="width: 120px; height: 25px" onclick="FetchGridData();" runat="server" />
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <asp:CheckBox ID="chkSelect" Text="Select All" runat="server" onClick="fnValidateRangeControls(this)" />
                </td>
            </tr>
            <tr>
                <td colspan="4">
                    <table>
                        <tr>
                            <td colspan="4" align="center">
                                <fieldset style="width: auto">
                                    <legend><b>IRN Related</b></legend>
                                    <asp:Panel ID="Panel2" runat="server">
                                        <div id="dataTable" class="hot handsontable htColumnHeaders" style="overflow: auto; border: 1px solid olive; width: 780px; height: 400px; z-index: 0;">
                                        </div>
                                    </asp:Panel>
                                </fieldset>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="4" align="right">
                    <%--<input type="button" id="btnGetIRNData" value="Get Result" class="button" style="width: 120px; height: 25px" onclick="FetchGeneratedIRNData();" runat="server" />--%>
                    <asp:Button ID="btnDOWNLOAD" runat="server" CssClass="button" Text="Download" Width="100px" Style="margin-left: 0px" />
                </td>
            </tr>
        </table>
    </div>

    <script type="text/javascript">


        function rePopulateGrid() {

            var data1 = document.getElementById('<%=txtGRIDDATA.ClientID%>').value;
            var data = jQuery.parseJSON(data1);
            $("div").find("#dataTable").handsontable("loadData", data);

        }

        var stroptmode = '';
        stroptmode = document.getElementById('<%=txtOPTMODE.ClientID%>').value;

        var noneditablecolor = function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
            td.style.backgroundColor = '#FFCCCC';
            td.style.color = 'black';
        };

        var editablecolor = function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
            td.style.backgroundColor = 'white';
            //td.style.fontWeight = 'bold';
            td.style.color = 'black';
        };

        var searchedcolor = function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
            td.style.backgroundColor = '#FFCCCC';
            td.style.color = 'black';
        };

        var placeHolders = {
            "class_date": "DD/MM/YYYY",
            "class_time": "00:00",
        };

        function returnColIndex(searchStr) {
            var DataFields = $("#dataTable").handsontable('getSettings').columns;
            for (var j = 0; j < DataFields.length; j++) {
                if (DataFields[j].data == searchStr) {
                    return j;
                }
            }
            return -1;
        };

        var $container = $("div").find("#dataTable");
        $container.handsontable({
            data: [],
            colWidths: [
                       50, 150, 80, 200, 100, 100,
                       100, 80, 300

            ],
            colHeaders: true,
            startRows: 2,
            colHeaders: [

            '<b>Select</b>', '<b>Document No.</b>', '<b>Document Dt.</b>', '<b>Party</b>', '<b>GSTIN</b>', '<b>Amount</b>',
            '<b>Ack. No.</b>', '<b>Ack. Date</b>', '<b>IRN</b>'

            ],
            minSpareRows: 0,
            //rowHeaders: true,
            //contextMenu: ["remove_row"],
            fillHandle: false,
            manualColumnResize: true,
            //fixedColumnsLeft: 2,
            //renderAllRows: true,
            beforeRender: function () {
                $container.find('thead').find('tr').remove();
                $('#header-grouping').remove();
            },
            columns: [
                        { data: "SELECTED", type: 'checkbox', checkedTemplate: 'YES', uncheckedTemplate: 'NO' },
                        { data: "DOC_NO", type: 'text', allowInvalid: false, language: 'en', readOnly: true, renderer: noneditablecolor },
                        { data: "DOC_DT", type: 'text', allowInvalid: false, language: 'en', readOnly: true, renderer: noneditablecolor, placeholder: placeHolders.class_date },
                        { data: "BILLTO_TRDNM", type: 'text', allowInvalid: false, language: 'en', readOnly: true, renderer: noneditablecolor },
                        { data: "BILLTO_GSTIN", type: 'text', allowInvalid: false, language: 'en', readOnly: true, renderer: noneditablecolor },
                        { data: "VAL_TOTINVVAL", type: 'numeric', format: '0.00', allowInvalid: false, language: 'en', readOnly: true, renderer: noneditablecolor },
                        { data: "ACKNO", type: 'text', allowInvalid: false, language: 'en', readOnly: true, renderer: noneditablecolor },
                        { data: "ACKDATE", type: 'text', allowInvalid: false, language: 'en', readOnly: true, renderer: noneditablecolor },
                        { data: "IRN", type: 'text', readOnly: true, renderer: noneditablecolor }
                        

            ],
            //afterSelection: AfterSelection,
            afterChange: AfterChange,
            beforeKeyDown: function (e) {
                if (e.which == 113) {
                    e.stopImmediatePropagation();
                    e.preventDefault();
                    var gridrowcolumns = $('#dataTable').handsontable('getInstance');
                    var currRow = gridrowcolumns.getSelected();
                    
                }
            }
        });

        function AfterChange(changes, data) {
            if (!changes) {
                return;
            }
            $.each(changes, function (index, element) {
                var change = element;
                var rowIndex = change[0];
                var columnIndex = change[1];
             
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
            var operationmode = document.getElementById('<%=txtOPTMODE.ClientID%>').value;
            var channel = document.getElementById('<%=ddlCHANNEL.ClientID%>').value;
            var Fromdate = document.getElementById('<%=mskDOCUMENTTDATEFROM.ClientID%>').value;
            var Todate = document.getElementById('<%=mskDOCUMENTTDATETO.ClientID%>').value;
            var check = 'NO';
           
                if (document.getElementById('<%=chkSelect.ClientID%>').checked == true) {
                    check = 'YES';
                }
                else {
                    check = 'NO';
                }
            var menutag = document.getElementById('<%=txtMENUTAG.ClientID%>').value;
            //alert(menutag);
            $.ajax({
                type: "POST",
                url: "pgEINVOICE_AUCTION.aspx/GetGridData",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({
                    strOperationMode: operationmode, strChannel: channel, strFromdate: Fromdate, strTodate: Todate, strChecked: check
                }),
                dataType: "json",
                async: false,
                beforeSend: function () { InvokeLoading(); },
                success: function (res) {
                    if (res.d != "") {
                        part = res.d;
                        console.log(part);

                        var data = JSON.parse(part);
                        console.log(data);
                        $("div").find("#dataTable").handsontable('loadData', data);
                        document.getElementById('<%=txtGRIDDATA.ClientID%>').value = part;
                    }
                    else {
                        alert("No IRN Pending Data Found!!! ");
                      
                    }

                },
                error: function (xhr, status) {
                    DisposeLoading();
                    alert("An error occurred 1: " + status);
                }
            });
            DisposeLoading();
        };

       
    </script>

</asp:Content>
