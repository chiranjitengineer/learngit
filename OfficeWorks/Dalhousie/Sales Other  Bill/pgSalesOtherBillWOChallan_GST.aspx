<%@ Page Title="" ValidateRequest="false" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site1.Master" CodeBehind="pgSalesOtherBillWOChallan_GST.aspx.vb" Inherits="swterp.pgSalesOtherBillWOChallan_GST" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
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

    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            $("#mskSALESBILLDATE").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
            $("#mskGATEPASSDATE").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
            $("#mskLETTERDATE").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
            $("#txtPODATE").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
            $("#txtMRDATE").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
        })
        function fnGridFill(obj, e) {
            var strCODE = obj.value;
            if (obj.id == "mainContent_txtGridHelp") {
                var str1 = document.getElementById('<%=txtGridHelp.ClientID%>').value;
                curRow = document.getElementById('<%=txtGridCurRow.ClientID%>').value.split(',');
                fn_getGridFillData(curRow[0], curRow[1]);
            }
        }
        function fn_getGridFillData(rowIndex, colIndex) {
            var str1 = document.getElementById('<%=txtGridHelp.ClientID%>').value;
            ///alert(str1);
            var strDataArr = new Array();
            if (str1 != '') {
                strDataArr = str1.split("~");

                if (colIndex == returnColIndex("ACCODE")) {
                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex('ACCODE'), strDataArr[0]);
                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex('ACHEAD'), strDataArr[1]);
                }
                if (colIndex == returnColIndex("HSNCODE")) {
                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex('HSNCODE'), strDataArr[0]);
                }
                if (colIndex == returnColIndex("ITEMDESC")) {
                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex('ITEMDESC'), strDataArr[0]);
                }
            }
            $("#popupdiv").dialog('close');
        }
        //----------------Press F2 on TextBox
        function searchKeyDown(obj, e) {
            var strComp = document.getElementById('<%=txtCOMPCODE.ClientID%>');
            var strDiv = document.getElementById('<%=txtDIVCODE.ClientID%>');
            var strPROJECTNAME = document.getElementById('<%=txtPROJNAME.ClientID%>');
            var strChannelCode = document.getElementById('<%=txtCHANNELCODE.ClientID%>');
            var strYearCode = document.getElementById('<%=txtYRCODE.ClientID%>');
            var strSCRAPBILLNO = document.getElementById('<%=txtSCRAPSALESBILLNO.ClientID%>');
            var strPartyCode = document.getElementById('<%=txtPARTYCODE.ClientID%>');
            var strAddressCode = document.getElementById('<%=txtADDRESSCODE.ClientID%>').value + ',' + document.getElementById('<%=txtADDRESSCODEBILL.ClientID%>').value;

            var strShipCode = document.getElementById('<%=txtADDRESSCODE.ClientID%>');
            var strBillCode = document.getElementById('<%=txtADDRESSCODEBILL.ClientID%>');

            var unicode = e.keyCode ? e.keyCode : e.charCode
            if (unicode == 113) // F1=112, Enter=13
            {
                if (obj.id == "mainContent_txtCHANNELCODE") {
                    obj.value = '';
                    var strHelp = "3091^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~MODULE:" + strPROJECTNAME.value + "~^^Sales Channel Information"
                    InvokePop(obj.id, strHelp);
                }
                if (obj.id == "mainContent_txtPARTYCODE") {
                    obj.value = '';
                    var strHelp = "3067^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~MODULE:" + strPROJECTNAME.value + "~PARTYTYPE:BUYER~CHANNELLIST:" + strChannelCode.value + "~^^Sales Party Information"
                    InvokePop(obj.id, strHelp);
                }
                if (obj.id == "mainContent_txtSCRAPSALESBILLNO") {
                    obj.value = '';
                    var strHelp = "3094^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~CHANNELCODE:" + strChannelCode.value + "~^^Sales Other Challan Information"
                    InvokePop(obj.id, strHelp);
                }
                if (obj.id == "mainContent_txtSALESBILLNO") {
                    obj.value = '';
                    var strHelp = "3093^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~CHANNELCODE:" + strChannelCode.value + "~BILLTYPE:WITHOUT CHALLAN" + "~^^Sales Other Bill Information"
                    InvokePop(obj.id, strHelp);
                }
                if (obj.id == "mainContent_txtADDRESSCODE") {
                    obj.value = '';
                    var strHelp = "3049^" + "COMPANYCODE:" + strComp.value + "~MODULE:" + strPROJECTNAME.value + "~PARTYTYPE:BUYER" + "~PARTYCODE:" + strPartyCode.value + "~^^Sales Buyer Address Information"
                    InvokePop(obj.id, strHelp);
                }
                if (obj.id == "mainContent_txtADDRESSCODEBILL") {
                    obj.value = '';
                    var strHelp = "3049^" + "COMPANYCODE:" + strComp.value + "~MODULE:" + strPROJECTNAME.value + "~PARTYTYPE:BUYER" + "~PARTYCODE:" + strPartyCode.value + "~^^Sales Buyer Address Information"
                    InvokePop(obj.id, strHelp);
                }
                if (obj.id == "mainContent_txtBILLSTATECODE") {
                    obj.value = '';
                    var strHelp = "9115^" + "COMPANYCODE:" + strComp.value + "~MODULE:" + strPROJECTNAME.value + "~PARTYCODE:" + strPartyCode.value + "~ADDRESSCODE:" + strAddressCode + "~^^Sales Buyer Address State Information"
                    InvokePop(obj.id, strHelp);
                }
                if (obj.id == "mainContent_txtPONO") {
                    obj.value = '';
                    var strHelp = "3223^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~BUYERCODE:" + strPartyCode.value + "~ADDRESSCODE:" + strShipCode.value + "~ADDRESSCODEBILL:" + strBillCode.value + "~^^PCSO Information"
                    InvokePop(obj.id, strHelp);
                }
                if (obj.id == "mainContent_txtDESTINATION") {
                    obj.value = '';
                    var strHelp = "3224^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~BUYERCODE:" + strPartyCode.value + "~ADDRESSCODE:" + strShipCode.value + "~ADDRESSCODEBILL:" + strBillCode.value + "~^^Destination Information"
                    InvokePop(obj.id, strHelp);
                }
            }
        }

        function Validate(obj, e) {
            var strCODE = obj.value;
            if (strCODE != null && strCODE != "[New Entry]" && strCODE != "[Select]" && strCODE != "" && strCODE != "undefined") {
                __doPostBack(obj.id, "TextChanged");
                //GridDataRefresh();
            }
        };
        function FetchWebData(strParameter) {
            var Keydata = '';
            var Keydata2 = '';
            var operationmode = document.getElementById('<%=txtOPTMODE.ClientID%>').value;

            if (strParameter == 'CHANNEL') {
                Keydata = document.getElementById('<%=txtCHANNELCODE.ClientID%>').value;
            }
            if (strParameter == 'PARTY') {
                Keydata = document.getElementById('<%=txtPARTYCODE.ClientID%>').value;
                Keydata2 = document.getElementById('<%=txtCHANNELCODE.ClientID%>').value;
            }
            if (strParameter == 'ADDRESSCODE') {
                Keydata = document.getElementById('<%=txtPARTYCODE.ClientID%>').value;
                Keydata2 = document.getElementById('<%=txtADDRESSCODE.ClientID%>').value;
            }
            if (strParameter == 'ADDRESSCODEBILL') {
                Keydata = document.getElementById('<%=txtPARTYCODE.ClientID%>').value;
                Keydata2 = document.getElementById('<%=txtADDRESSCODEBILL.ClientID%>').value;
            }
            if (strParameter == 'BILLSTATECODE') {
                Keydata = document.getElementById('<%=txtBILLSTATECODE.ClientID%>').value;
            }
            if (Keydata.length > 0) {
                $.ajax({
                    type: "POST",
                    url: "pgSalesOtherBillWOChallan_GST.aspx/GetWebData",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: false,
                    data: JSON.stringify({ strKey: Keydata, strKey2: Keydata2, strParam: strParameter }),
                    success: function (res) {
                        var strArray = new Array()
                        strArray = res.d.split("~");

                        if (strParameter == 'CHANNEL') {
                            document.getElementById('<%=txtCHANNELTAG.ClientID%>').value = strArray[0];
                            if (strArray[0] = "SCRAP") {
                                document.getElementById('<%=txtDOCUMENTTYPE.ClientID%>').value = "SCRAP BILL";
                            }
                            else if (strArray[0] = "OTHERS") {
                                document.getElementById('<%=txtDOCUMENTTYPE.ClientID%>').value = "OTHERS BILL";
                            }
                            document.getElementById('<%=txtSCRAPSALESBILLNO.ClientID%>').focus();
                        }

                        if (strParameter == 'PARTY') {
                            document.getElementById('<%=txtPARTYNAME.ClientID%>').value = strArray[0];
                        }
                        if (strParameter == 'ADDRESSCODE') {
                            document.getElementById('<%=txtADDRESSDESC.ClientID%>').value = strArray[0];
                        }
                        if (strParameter == 'ADDRESSCODEBILL') {
                            document.getElementById('<%=txtADDRESSDESCBILL.ClientID%>').value = strArray[0];
                            document.getElementById('<%=txtBILLSTATECODE.ClientID%>').value = strArray[1];
                            document.getElementById('<%=txtBILLSTATEDESC.ClientID%>').value = strArray[2];
                        }
                        if (strParameter == 'BILLSTATECODE') {
                            document.getElementById('<%=txtBILLSTATEDESC.ClientID%>').value = strArray[0];
                        }
                    },
                    error: function (xhr, status) {
                        alert("An error occurred: " + status);
                    }
                });
            }
        };

        function rePopulateGrid() {
            var data1 = document.getElementById('<%=txtGRIDDATA.ClientID%>').value;
            var data = jQuery.parseJSON(data1);
            $("div").find("#dtDetails").handsontable("loadData", data);

            var data2 = document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value;
            var datacharge = jQuery.parseJSON(data2);
            $("div").find("#dtChargeDetails").handsontable("loadData", datacharge);
        };
    </script>
    <div align="center">
        <div id="popupdiv" title="Details Information" class="popstyle">
            <label id="search">Search : </label>
            <input id="SearchText" type="text" style='width: 600px;' />
            <div id='searchPanel' style='width: auto; height: 260px; overflow: scroll'></div>
        </div>
        <table cellpadding="1" cellspacing="0" class="box_shade">
            <tr class="box_heading">
                <td colspan="6" align="center">
                    <asp:Label ID="lblHeader" Text="Sales Other/Scrap Bill (Without Challan)" runat="server"> </asp:Label>
                    <asp:TextBox ID="txtCOMPCODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtDIVCODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtYRCODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtUSRNAME" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtOPTMODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtPROJNAME" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtSYSROWID" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtGRIDDATA" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtCHANNELTAG" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtBILLTYPE" runat="server" Style="display: none"></asp:TextBox>
                    <%-- For Charge Grid --%>
                    <asp:TextBox ID="txtDOCUMENTTYPE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtCHARGEGRIDDATA" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtSCRAPSALESBILLNO" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="mskSCRAPSALESBILLDATE" runat="server" Style="display: none"></asp:TextBox>
                    <%----------------------%>
                </td>
            </tr>
            <tr>
                <td align="left">
                    <asp:Label ID="lblCHANNELCODE" Text="Channel" runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtCHANNELCODE" runat="server" Width="220px" MaxLength="100" CausesValidation="True" AutoPostBack="true" onkeydown="searchKeyDown(this,event)" onblur="Validate(this, event);"></asp:TextBox>
                    <asp:Label ID="lblMAND1" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"> </asp:Label>
                </td>
                <td align="left">
                    <asp:Label ID="lblSALESBILLNO" Text="Sale Bill No." runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtSALESBILLNO" runat="server" Width="180px" MaxLength="10" CausesValidation="True" AutoPostBack="true" onkeydown="searchKeyDown(this,event)" onblur="Validate(this, event); " TabIndex="3"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblSALESBILLDATE" Text="Sale Bill Date" runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="mskSALESBILLDATE" runat="server" Width="180px" MaxLength="10" CausesValidation="True" TabIndex="4" ClientIDMode="Static"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td align="left">
                    <asp:Label ID="lblPARTYCODE" Text="Party" runat="server"> </asp:Label>
                </td>
                <td align="left" colspan="5">
                    <asp:TextBox ID="txtPARTYCODE" runat="server" Width="100px" MaxLength="10" CausesValidation="True" onkeydown="searchKeyDown(this,event)" onblur="FetchWebData('PARTY');" TabIndex="5"></asp:TextBox>
                    <asp:TextBox ID="txtPARTYNAME" runat="server" Width="418px" MaxLength="10" Enabled="false"></asp:TextBox>
                    <asp:TextBox ID="txtGridCurRow" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtGridHelp" runat="server" Width="0px" onblur="fnGridFill(this,event);"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td align="left">
                    <asp:Label ID="lblADDRESSCODE" Text="Shipping Address " runat="server"> </asp:Label>
                </td>
                <td colspan="5" align="left">
                    <asp:TextBox ID="txtADDRESSCODE" runat="server" Width="100px" onkeydown="searchKeyDown(this,event)" onblur="FetchWebData('ADDRESSCODE');" MaxLength="10" CausesValidation="True" TabIndex="6"></asp:TextBox>
                    <asp:TextBox ID="txtADDRESSDESC" runat="server" Width="418px" CausesValidation="True" BackColor="#FFCCCC"></asp:TextBox>
                    <asp:Label ID="lblMANDATORY7" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"></asp:Label>
                </td>
            </tr>
            <tr>
                <td align="left">
                    <asp:Label ID="lblADDRESSCODEBILL" Text="Billing Address " runat="server"> </asp:Label>
                </td>
                <td colspan="5" align="left">
                    <asp:TextBox ID="txtADDRESSCODEBILL" runat="server" Width="100px" onkeydown="searchKeyDown(this,event)" onblur="FetchWebData('ADDRESSCODEBILL');" MaxLength="10" CausesValidation="True" TabIndex="7"></asp:TextBox>
                    <asp:TextBox ID="txtADDRESSDESCBILL" runat="server" Width="418px" CausesValidation="True" BackColor="#FFCCCC"></asp:TextBox>
                    <asp:Label ID="lblMANDATORY8" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"></asp:Label>
                </td>
            </tr>
            <tr>
                <td align="left">
                    <asp:Label ID="lblBILLSTATE" Text="Billing State " runat="server"> </asp:Label>
                </td>
                <td colspan="5" align="left">
                    <asp:TextBox ID="txtBILLSTATECODE" runat="server" Width="100px" onkeydown="searchKeyDown(this,event)" onblur="FetchWebData('BILLSTATECODE');" MaxLength="30" CausesValidation="True" TabIndex="8"></asp:TextBox>
                    <asp:TextBox ID="txtBILLSTATEDESC" runat="server" Width="418px" CausesValidation="True" TabIndex="103" Enabled="False" BackColor="#FFCCCC" ReadOnly="true"></asp:TextBox>
                    <asp:Label ID="lblMANDATORY9" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"></asp:Label>
                </td>
            </tr>
            <tr>
                <td align="left">
                    <asp:Label ID="lblGATEPASSNO" Text="Challan No." runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtGATEPASSNO" runat="server" Width="180px" MaxLength="200" CausesValidation="True" TabIndex="9" Enabled="false"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblGATEPASSDATE" Text="Challan Date" runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="mskGATEPASSDATE" runat="server" Width="180px" MaxLength="10" CausesValidation="True" Enabled="False" TabIndex="10" ClientIDMode="Static"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblLORRYNO" Text="Lorry No." runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtLORRYNO" runat="server" Width="180px" MaxLength="30" CausesValidation="True" TabIndex="11" Enabled="False"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td align="left">
                    <asp:Label ID="lblWEIGHTSLIPNO" Text="Weight Slip Bill No." runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtWEIGHTSLIPNO" runat="server" Width="180px" MaxLength="20" CausesValidation="True" TabIndex="12" Enabled="False"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblLETTERNO" Text="Scrap Letter No." runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtLETTERNO" runat="server" Width="180px" MaxLength="10" CausesValidation="True" TabIndex="13" Enabled="False"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblLETTERDATE" Text="Scrap Letter Date" runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="mskLETTERDATE" runat="server" Width="180px" MaxLength="10" CausesValidation="True" Enabled="False" TabIndex="14" ClientIDMode="Static"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td align="left">
                    <asp:Label ID="lblPONO" Text="PCSO./Order No." runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtPONO" runat="server" Width="180px" MaxLength="50"  onkeydown="searchKeyDown(this,event)" CausesValidation="True" TabIndex="15"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblPODATE" Text="PCSO./Order Date" runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtPODATE" runat="server" Width="180px" MaxLength="10" CausesValidation="True" TabIndex="16" ClientIDMode="Static"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblMRNO" Text="MR No." runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtMRNO" runat="server" Width="180px" MaxLength="50" CausesValidation="True" TabIndex="17"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td align="left">
                    <asp:Label ID="lblMRDATE" Text="MR Date" runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtMRDATE" runat="server" Width="180px" MaxLength="10" CausesValidation="True" TabIndex="18" ClientIDMode="Static"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblAMENDMENT" Text="Amendment No & Dt." runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtAMENDMENT" runat="server" Width="180px" MaxLength="500" CausesValidation="True" TabIndex="19"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblDESTINATION" Text="Destination" runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtDESTINATION" runat="server" Width="180px" MaxLength="100" CausesValidation="True"  onkeydown="searchKeyDown(this,event)" TabIndex="20"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td colspan="6">
                    <table width="100%">
                        <tr>
                            <td>
                                <div>
                                    <asp:Panel ID="gridPanel" runat="server">
                                        <cc1:TabContainer ID="TabsView1" runat="server" ActiveTabIndex="0" Width="940px">
                                            <cc1:TabPanel runat="server" ID="TabPanelDetails">
                                                <HeaderTemplate>
                                                    <div class="tabsize">Details</div>
                                                </HeaderTemplate>
                                                <ContentTemplate>
                                                    <asp:UpdatePanel ID="UpdatePanelBill" runat="server">
                                                        <ContentTemplate>
                                                            <asp:Panel ID="PanelDetails" runat="server">
                                                                <table style="width: 100%; height: 99%">
                                                                    <tr>
                                                                        <td align="center">
                                                                            <div id="dtDetails" style="overflow: auto; border: 1px solid olive; width: 920px; height: 150px;">
                                                                            </div>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </asp:Panel>
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
                                                </ContentTemplate>
                                            </cc1:TabPanel>
                                            <cc1:TabPanel runat="server" ID="TabPanelChargeDetails">
                                                <HeaderTemplate>
                                                    <div class="tabsize">Charge Details</div>
                                                </HeaderTemplate>
                                                <ContentTemplate>
                                                    <asp:UpdatePanel ID="UpdatePanelChrg" runat="server">
                                                        <ContentTemplate>
                                                            <asp:Panel ID="PanelChrg" runat="server">
                                                                <table style="width: 100%; height: 99%">
                                                                    <tr>
                                                                        <td align="center">
                                                                            <div id="dtChargeDetails" style="overflow: auto; border: 1px solid olive; width: 920px; height: 150px;">
                                                                            </div>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </asp:Panel>
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
                                                </ContentTemplate>
                                            </cc1:TabPanel>
                                        </cc1:TabContainer>
                                    </asp:Panel>
                                </div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td align="left" colspan="2">
                    <asp:Label ID="lblTOTALQTY" Text="Total Quantity" runat="server" Style="font-weight: 700; display: none"> </asp:Label>
                    <asp:TextBox ID="txtTOTALQTY" runat="server" Width="100px" CausesValidation="True" Font-Bold="true" Style="display: none" BackColor="#FFCCCC"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblTOTALNETAMOUNT" Text="Total Net Amt." runat="server" Style="font-weight: 700"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtNETAMT" runat="server" Width="100px" CausesValidation="True" Font-Bold="true" BackColor="#FFCCCC" Enabled="false">0.00</asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblTOTALGROSSAMOUNT" Text="Total Gross Amt." runat="server" Style="font-weight: 700"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtGROSSAMT" runat="server" Width="100px" CausesValidation="True" Font-Bold="true" BackColor="#FFCCCC" Enabled="false">0.00</asp:TextBox>
                </td>
            </tr>
        </table>
    </div>
    <script type="text/javascript">
        var noneditablecolor = function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
            td.style.backgroundColor = '#FFCCCC';
            //td.style.fontWeight = 'bold';
            td.style.color = 'black';
        };
        function returnColIndex(searchStr) {
            var DataFields =
            [
               "SERIALNO", "ACCODE", "ACHEAD", "ITEMDESC", "HSNCODE", "NOOFPKG", "QUANTITY", "UOMCODE", "RATE", "AMOUNT",
               "CHANNELCODE", "SCRAPSERIALNO", "SALESBILLNO", "SALESBILLDATE",
               "COMPANYCODE", "DIVISIONCODE", "YEARCODE", "SYSROWID", "OPERATIONMODE", "USERNAME", "UOMDESC"
            ];
            for (var j = 0; j < DataFields.length; j++) {
                if (DataFields[j] == searchStr) {
                    return j;
                }
            }
            return -1;
        }
        var $container = $("div").find("#dtDetails");//$("#dataTable");
        $container.handsontable({
            data: [],
            colWidths: [60, 90, 150, 300, 100, 100, 80, 80, 80, 80,
                        1, 1, 1, 1,
                        1, 1, 1, 1, 1, 1, 1],
            startRows: 1,
            colHeaders: ['Sr.No.', 'Ledger<br\> Code [F2]', 'Ledger<br\> Head', 'Item Desc<br\>[F2]', 'HSN Cd<br\>[F2]', 'Pkg<br\>Details', 'Qty.', 'UOM Code', 'Rate', 'Amount'
            ],
            minSpareRows: 1,
            fillHandle: false,
            manualColumnResize: true,
            columns: [
            { data: "SERIALNO", type: 'text', readOnly: true, renderer: noneditablecolor, language: 'en' },
            { data: "ACCODE", type: 'text', readOnly: true, language: 'en' },
            { data: "ACHEAD", type: 'text', readOnly: true, renderer: noneditablecolor, language: 'en' },
            { data: "ITEMDESC", type: 'text', language: 'en' },
            { data: "HSNCODE", type: 'text', readOnly: true, language: 'en' },
            { data: "NOOFPKG", type: 'text', language: 'en' },
            { data: "QUANTITY", type: 'numeric', format: '0.000', language: 'en' },
            { data: "UOMCODE", type: 'autocomplete', source: AutoComplete_UOMCODE, strict: true, allowInvalid: false, language: 'en' },
            { data: "RATE", type: 'numeric', format: '0.000', language: 'en' },
            { data: "AMOUNT", type: 'numeric', format: '0.000', language: 'en' },
            { data: "CHANNELCODE", readOnly: true },
            { data: "SCRAPSERIALNO", readOnly: true },
            { data: "SALESBILLNO", readOnly: true },
            { data: "SALESBILLDATE", readOnly: true },
            { data: "COMPANYCODE", readOnly: true },
            { data: "DIVISIONCODE", readOnly: true },
            { data: "YEARCODE", readOnly: true },
            { data: "SYSROWID", readOnly: true },
            { data: "OPERATIONMODE", readOnly: true },
            { data: "USERNAME", readOnly: true },
            { data: "UOMDESC", readOnly: true }
            ],
            afterChange: AfterChange,
            beforeKeyDown: function (e) {
                if (e.which == 113) {
                    e.stopImmediatePropagation();
                    e.preventDefault();
                    var gridrowcolumns = $('#dtDetails').handsontable('getInstance');
                    var currRow = gridrowcolumns.getSelected();
                    var strComp1 = document.getElementById('<%=txtCOMPCODE.ClientID%>');
                    var strDiv1 = document.getElementById('<%=txtDIVCODE.ClientID%>');
                    if (currRow[1] == returnColIndex("ACCODE")) {
                        document.getElementById('<%=txtGridCurRow.ClientID%>').value = currRow[0] + ',' + currRow[1];
                        var strHelp = "3110^COMPANYCODE:" + strComp1.value + "~DIVISIONCODE:" + strDiv1.value + "~^^Ledger List^''"
                        InvokePop('mainContent_txtGridHelp', strHelp);
                    }
                    if (currRow[1] == returnColIndex("HSNCODE")) {
                        document.getElementById('<%=txtGridCurRow.ClientID%>').value = currRow[0] + ',' + currRow[1];
                        var strHelp = "9101^" + "~^" + "^" + "HSN INFORMATION";
                        InvokePop('mainContent_txtGridHelp', strHelp);
                    }
                    if (currRow[1] == returnColIndex("ITEMDESC")) {
                        document.getElementById('<%=txtGridCurRow.ClientID%>').value = currRow[0] + ',' + currRow[1];
                        var strHelp = "3200^COMPANYCODE:" + strComp1.value + "~DIVISIONCODE:" + strDiv1.value + "~^^OTHER QUALITY INFORMATION";
                        InvokePop('mainContent_txtGridHelp', strHelp);
                    }
                }
            }
        });
        function AfterChange(changes, data) {
            if (!changes) {
                return;
            }
            $.each(changes, function (index, element) {
                //alert(change[0]);
                var change = element;
                var rowIndex = change[0];
                var columnIndex = change[1];
                if (columnIndex == "UOMCODE") {
                    var gridrowcolumns = $('#dtDetails').handsontable('getInstance');
                    var currRow = gridrowcolumns.getSelected();
                    var UOM = $("#dtDetails").handsontable('getDataAtCell', currRow[0], returnColIndex("UOMCODE"));
                    $.ajax({
                        url: 'pgSalesOtherBillWOChallan_GST.aspx/GetUOMData',
                        contentType: "application/json; charset=utf-8",
                        dataType: 'json',
                        data: JSON.stringify({ strUOM: UOM }),
                        dataType: 'json',
                        type: 'POST',
                        success: function (response) {
                            var str1 = (response.d);
                            $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex("UOMDESC"), str1);
                        }
                    });
                }
                if (columnIndex == "ACCODE") {
                    var ACCODE = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex("ACCODE"));

                    $.ajax({
                        url: 'pgSalesOtherBillWOChallan_GST.aspx/fnGetACHEAD',
                        contentType: "application/json; charset=utf-8",
                        dataType: 'json',
                        data: JSON.stringify({ strACCODE: ACCODE }),
                        dataType: 'json',
                        type: 'POST',
                        success: function (response) {
                            var str1 = (response.d);
                            $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex("ACHEAD"), str1);
                        }
                    });
                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("CHANNELCODE")), document.getElementById('<%=txtCHANNELCODE.ClientID%>').value);
                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("SALESBILLNO")), document.getElementById('<%=txtSALESBILLNO.ClientID%>').value);
                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("SALESBILLDATE")), document.getElementById('<%=mskSALESBILLDATE.ClientID%>').value);
                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("SERIALNO")), ((parseInt(rowIndex) + 1)));
                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("SCRAPSERIALNO")), ((parseInt(rowIndex) + 1)));
                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("COMPANYCODE")), document.getElementById('<%=txtCOMPCODE.ClientID%>').value);
                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("DIVISIONCODE")), document.getElementById('<%=txtDIVCODE.ClientID%>').value);
                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("OPERATIONMODE")), document.getElementById('<%=txtOPTMODE.ClientID%>').value);
                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("USERNAME")), document.getElementById('<%=txtUSRNAME.ClientID%>').value);
                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("YEARCODE")), document.getElementById('<%=txtYRCODE.ClientID%>').value);
                }

                if (columnIndex == "RATE") {
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("CHANNELCODE")), document.getElementById('<%=txtCHANNELCODE.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("SALESBILLNO")), document.getElementById('<%=txtSALESBILLNO.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("SALESBILLDATE")), document.getElementById('<%=mskSALESBILLDATE.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("SERIALNO")), ((parseInt(rowIndex) + 1)));
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("SCRAPSERIALNO")), ((parseInt(rowIndex) + 1)));
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("COMPANYCODE")), document.getElementById('<%=txtCOMPCODE.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("DIVISIONCODE")), document.getElementById('<%=txtDIVCODE.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("OPERATIONMODE")), document.getElementById('<%=txtOPTMODE.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("USERNAME")), document.getElementById('<%=txtUSRNAME.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("YEARCODE")), document.getElementById('<%=txtYRCODE.ClientID%>').value);

                        fnCalcAmount(rowIndex);
                        //fnTotalQuantityAmount(rowIndex);
                    }
                if (columnIndex == "UOMCODE" || columnIndex == "QUANTITY" || columnIndex == "ITEMDESC") {
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("CHANNELCODE")), document.getElementById('<%=txtCHANNELCODE.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("SALESBILLNO")), document.getElementById('<%=txtSALESBILLNO.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("SALESBILLDATE")), document.getElementById('<%=mskSALESBILLDATE.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("SERIALNO")), ((parseInt(rowIndex) + 1)));
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("SCRAPSERIALNO")), ((parseInt(rowIndex) + 1)));
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("COMPANYCODE")), document.getElementById('<%=txtCOMPCODE.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("DIVISIONCODE")), document.getElementById('<%=txtDIVCODE.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("OPERATIONMODE")), document.getElementById('<%=txtOPTMODE.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("USERNAME")), document.getElementById('<%=txtUSRNAME.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, parseInt(returnColIndex("YEARCODE")), document.getElementById('<%=txtYRCODE.ClientID%>').value);
                    }
                if (columnIndex = "AMOUNT") {
                    fnTotalQuantityAmount(rowIndex);
   
                    //-----------------start effect on charges---------------------------
                    var ChargeGridData = document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value;
                    var TotalNetQuantity = document.getElementById('<%=txtTOTALQTY.ClientID%>').value;
                    var TotalNetAmount = document.getElementById('<%=txtNETAMT.ClientID%>').value;

                    $.ajax({
                        url: 'pgSalesOtherBillWOChallan_GST.aspx/prcChargeDetails',
                        contentType: "application/json; charset=utf-8",
                        type: 'POST',
                        dataType: 'json',
                        data: JSON.stringify({ strChargeGridData: ChargeGridData, strTotalNetQuantity: TotalNetQuantity, strTotalNetAmount: TotalNetAmount }),
                        success: function (response) {
                            part = response.d;
                            var data = JSON.parse(part);
                            $("div").find("#dtChargeDetails").handsontable('loadData', data);
                            document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value = part;

                                //------------- For Calculating Gross Amount
                                var TotalAmount = document.getElementById('<%=txtNETAMT.ClientID%>').value;
                                var ChargeAmount = 0;
                                var rowCount = $("#dtChargeDetails").handsontable('countRows');

                                for (var i = 0; i < rowCount; i++) {
                                    if ($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("ADDLESSSIGN")) == "?") {
                                    }
                                    else {
                                        if ($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("SELECTED")) == "YES") {
                                            ChargeAmount += Number($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("CHARGEAMOUNT")));
                                        }
                                    }
                                }
                                if ($("#dtChargeDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_ChargeDetails("ADDLESSSIGN")) == "+") {
                                    document.getElementById('<%=txtGROSSAMT.ClientID%>').value = Number(TotalAmount) + Number(ChargeAmount);
                                }
                                else if ($("#dtChargeDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_ChargeDetails("ADDLESSSIGN")) == "-") {
                                    document.getElementById('<%=txtGROSSAMT.ClientID%>').value = Number(TotalAmount) - Number(ChargeAmount);
                            }
                            }
                        });
                    //-----------------end effect on charges-----------------------------
                    fnTotalGrossAmount(rowIndex);
                }
            });
            document.getElementById('<%=txtGRIDDATA.ClientID%>').value = '';
            fn_GetGridData();
        }

        function AutoComplete_UOMCODE(query, process) {
            var gridrowcolumns = $('#dtDetails').handsontable('getInstance');
            var currRow = gridrowcolumns.getSelected();
            $.ajax({
                url: 'pgSalesOtherBillWOChallan_GST.aspx/GetUOMcodeDetails',
                contentType: "application/json; charset=utf-8",
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify(),
                success: function (response) {
                    var data = jQuery.parseJSON(response.d);
                    var ddColumns = [];
                    $.each(data, function (index, value) {
                        ddColumns.push(value.CourseName);
                    });
                    process(ddColumns);
                }
            });
        }

        function fnCalcAmount(rowIndex) {
            var QTY = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex("QUANTITY"));
            var RATE = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex("RATE"));
            if (RATE > 0) {
                $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex("AMOUNT"), (parseFloat(QTY) * parseFloat(RATE)));
            }
            fnTotalQuantityAmount(rowIndex);
            fnTotalGrossAmount(rowIndex);
        }
        function fnTotalQuantityAmount(rowIndex) {
            var TotalQuantity = 0;
            var TotalNetAmt = 0;

            document.getElementById('<%=txtTOTALQTY.ClientID%>').value = 0.00;
            document.getElementById('<%=txtNETAMT.ClientID%>').value = 0.00;

            var rowCount = $("#dtDetails").handsontable('countRows');
            for (var rowIndex = 0; rowIndex < rowCount - 1 ; rowIndex++) {
                TotalQuantity = parseFloat($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex("QUANTITY")));
                TotalNetAmt = parseFloat($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex("AMOUNT")));
                //alert(  document.getElementById('<%=txtTOTALQTY.ClientID%>').value + ''+ TotalQuantity + '' + TotalNetAmt);
                document.getElementById('<%=txtTOTALQTY.ClientID%>').value = parseFloat(document.getElementById('<%=txtTOTALQTY.ClientID%>').value) + parseFloat(TotalQuantity);
                document.getElementById('<%=txtNETAMT.ClientID%>').value = parseFloat(document.getElementById('<%=txtNETAMT.ClientID%>').value) + parseFloat(TotalNetAmt);
            }
        }
        function fnTotalGrossAmount(rowIndex) {
            //alert('x');
            var TotalAmount = document.getElementById('<%=txtNETAMT.ClientID%>').value;
            var ChargeAmount = 0;
            var rowCount = $("#dtChargeDetails").handsontable('countRows');

            for (var i = 0; i <= rowCount - 1; i++) {

                if ($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("ADDLESSSIGN")) == "?") {
                }
                else {
                    if ($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("SELECTED")) == "YES") {
                        ChargeAmount += parseFloat($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("CHARGEAMOUNT")));
                    }
                }
            }
            if ($("#dtChargeDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_ChargeDetails("ADDLESSSIGN")) == "+") {
                document.getElementById('<%=txtGROSSAMT.ClientID%>').value = parseFloat(TotalAmount) + parseFloat(ChargeAmount);
           }
           else if ($("#dtChargeDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_ChargeDetails("ADDLESSSIGN")) == "-") {
               document.getElementById('<%=txtGROSSAMT.ClientID%>').value = parseFloat(TotalAmount) - parseFloat(ChargeAmount);
            }
        //document.getElementById('<%=txtGROSSAMT.ClientID%>').value = Number(TotalAmount) + Number(ChargeAmount);

        }
        //This will execute 5 seconds later and clear the Error Message
        function fn_GetGridData() {
            var $container = $("div").find("#dtDetails");
            var handsontable = $container.data('handsontable');
            var myData = handsontable.getData();
            document.getElementById('<%=txtGRIDDATA.ClientID%>').value = JSON.stringify(myData);

           var rowCount = $("#dtDetails").handsontable('countRows');
           for (var rowIndex = 0; rowIndex < rowCount ; rowIndex++) {
               fnTotalQuantityAmount(rowIndex);
               fnTotalGrossAmount(rowIndex);
           }
       }

       function FetchGridData() {
           var challanno = document.getElementById('<%=txtSCRAPSALESBILLNO.ClientID%>').value;
            var billno = document.getElementById('<%=txtSALESBILLNO.ClientID%>').value;
            var operationmode = document.getElementById('<%=txtOPTMODE.ClientID%>').value;
            $.ajax({
                type: "POST",
                url: "pgSalesOtherBillWOChallan_GST.aspx/GetGridData",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ strchallanno: challanno, strbillno: billno, strOperationMode: operationmode }),
                dataType: "json",
                success: function (res) {
                    part = res.d;
                    var data = JSON.parse(part);
                    $("div").find("#dtDetails").handsontable('loadData', data);
                    document.getElementById('<%=txtGRIDDATA.ClientID%>').value = part
                }
            });
    }
    </script>

    <script type="text/javascript">
        function returnColIndex_ChargeDetails(searchStr) {
            var DataFields =
            [
                "SELECTED", "CHARGECODE", "CHARGEDESC", "CHARGENATURE",
                "FORMULA", "RATE", "ADDLESSSIGN", "CHARGEAMOUNT",
                "COMPANYCODE", "DIVISIONCODE", "DIVISIONCODEFOR", "YEARCODE",
                "CHANNELCODE", "DOCUMENTNO", "DOCUMENTDATE", "DOCUMENTTYPE",
                "ASSESSABLEAMOUNT", "SYSROWID", "USERNAME", "CHARGETYPE", "ADDLESS", "OPERATIONMODE", "UNIT", "UORCODE", "UNITQUANTITY"
            ];

            for (var j = 0; j < DataFields.length; j++) {
                if (DataFields[j] == searchStr) {
                    return j;
                }
            }
            return -1;
        }

        var $container = $("div").find("#dtChargeDetails");
        $container.handsontable({
            data: [],
            colWidths: ['60', '60', '230', '80',
                        '240', '70', '60', '115',
                        '1', '1', '1', '1',
                        '1', '1', '1', '1',
                        '1', '1', '1', '1', '1', '1',
                        '1', '1', '1'
            ],

            colHeaders: ['Y/N', 'Code', 'Description', 'Nature',
                         'Formula', 'Rate', '+/-', 'Amount',
                         'COMPANYCODE', 'DIVISIONCODE', 'DIVISIONCODEFOR', 'YEARCODE',
                         'CHANNELCODE', 'DOCUMENTNO', 'DOCUMENTDATE', 'DOCUMENTTYPE',
                         'ASSESSABLEAMOUNT', 'SYSROWID', 'USERNAME', 'CHARGETYPE', 'ADDLESS', 'OPERATIONMODE', "UNIT", "UORCODE", "UNITQUANTITY"
            ],

            fillHandle: false,
            manualColumnResize: true,
            columns: [
                { data: "SELECTED", type: 'checkbox', checkedTemplate: 'YES', uncheckedTemplate: 'NO' },
                { data: "CHARGECODE", type: 'text', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "CHARGEDESC", type: 'text', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "CHARGENATURE", type: 'text', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "FORMULA", type: 'text', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "RATE", type: 'numeric', format: '0.00', language: 'en', readonly: true, renderer: noneditablecolor },
                { data: "ADDLESSSIGN", type: 'text', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "CHARGEAMOUNT", type: 'numeric', format: '0.00', language: 'en', strict: true, allowInvalid: false },
                //----------- Hidden Columns
                { data: "COMPANYCODE", readOnly: true },
                { data: "DIVISIONCODE", readOnly: true },
                { data: "DIVISIONCODEFOR", readOnly: true },
                { data: "YEARCODE", readOnly: true },
                { data: "CHANNELCODE", readOnly: true },
                { data: "DOCUMENTNO", readOnly: true },
                { data: "DOCUMENTDATE", readOnly: true },
                { data: "DOCUMENTTYPE", readOnly: true },
                { data: "ASSESSABLEAMOUNT", readOnly: true },
                { data: "SYSROWID", readOnly: true },
                { data: "USERNAME", readOnly: true },
                { data: "CHARGETYPE", readOnly: true },
                { data: "ADDLESS", readOnly: true },
                { data: "OPERATIONMODE", readOnly: true },
                { data: "UNIT", readOnly: true },
                { data: "UORCODE", readOnly: true },
                { data: "UNITQUANTITY", readOnly: true }
            ],
            afterChange: AfterChange,
        });

        function AfterChange(changes, data) {
            if (!changes) {
                return;
            }

            $.each(changes, function (index, element) {
                var change = element;
                var rowIndex = change[0];
                var columnIndex = change[1];

                if ($("#dtChargeDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_ChargeDetails("SELECTED")) == "YES") {
                    //-------------- Filling Hidden Fields
                    if ((columnIndex == "SELECTED" || columnIndex == "CHARGEAMOUNT")) {
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('COMPANYCODE'), document.getElementById('<%=txtCOMPCODE.ClientID%>').value);
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('DIVISIONCODE'), document.getElementById('<%=txtDIVCODE.ClientID%>').value);
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('DIVISIONCODEFOR'), document.getElementById('<%=txtDIVCODE.ClientID%>').value);
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('YEARCODE'), document.getElementById('<%=txtYRCODE.ClientID%>').value);
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('CHANNELCODE'), document.getElementById('<%=txtCHANNELCODE.ClientID%>').value);
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('DOCUMENTNO'), document.getElementById('<%=txtSALESBILLNO.ClientID%>').value);
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('DOCUMENTDATE'), document.getElementById('<%=mskSALESBILLDATE.ClientID%>').value);
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('DOCUMENTTYPE'), document.getElementById('<%=txtDOCUMENTTYPE.ClientID%>').value);
                        if ($("#dtChargeDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_ChargeDetails('ASSESSABLEAMOUNT')) == null) {
                            $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('ASSESSABLEAMOUNT'), '0.00');
                        }
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('OPERATIONMODE'), 'A');
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('USERNAME'), document.getElementById('<%=txtUSRNAME.ClientID%>').value);

                        var ChargeGridData = document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value;
                        var TotalNetQuantity = document.getElementById('<%=txtTOTALQTY.ClientID%>').value;
                        var TotalNetAmount = document.getElementById('<%=txtNETAMT.ClientID%>').value;
                        $.ajax({
                            url: 'pgSalesOtherBillWOChallan_GST.aspx/prcChargeDetails',
                            contentType: "application/json; charset=utf-8",
                            type: 'POST',
                            dataType: 'json',
                            data: JSON.stringify({ strChargeGridData: ChargeGridData, strTotalNetQuantity: TotalNetQuantity, strTotalNetAmount: TotalNetAmount }),
                            success: function (response) {
                                part = response.d;
                                var data = JSON.parse(part);
                                $("div").find("#dtChargeDetails").handsontable('loadData', data);
                                document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value = part;
                                fnTotalGrossAmount(rowIndex);
                            }
                        });
                    }
                }
                else {
                    if (columnIndex == "SELECTED") {
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('DOCUMENTDATE'), 'null');
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('CHARGEAMOUNT'), '0.00');
                        fnTotalGrossAmount(rowIndex);
                    }
                }
            });

            document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value = '';
            fn_GetChargeGridData();
        }

        $("#save").click(function () {
            var $container = $("div").find("#dtChargeDetails");
            var handsontable = $container.data('handsontable');
            var myData = handsontable.getData();
            $.ajax({
                url: 'pgSalesOtherBillWOChallan_GST.aspx/GetChargeData',
                contentType: "application/json; charset=utf-8",
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify({ gridData: JSON.stringify(myData) }),
                success: function (res) {
                }
            });
        });

        function fn_GetChargeGridData() {
            var $container = $("div").find("#dtChargeDetails");
            var handsontable = $container.data('handsontable');
            var myData = handsontable.getData();
            document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value = JSON.stringify(myData);
        }

        function FetchChargeGridData() {
            var OperationMode = document.getElementById('<%=txtOPTMODE.ClientID%>').value;
            var ChannelCode = document.getElementById('<%=txtCHANNELCODE.ClientID%>').value;
            var SALEBILLNO = document.getElementById('<%=txtSALESBILLNO.ClientID%>').value;
            var doctype = document.getElementById('<%=txtDOCUMENTTYPE.ClientID%>').value;
            $.ajax({
                type: "POST",
                url: "pgSalesOtherBillWOChallan_GST.aspx/GetChargeGridData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ strOperationMode: OperationMode, strChannelCode: ChannelCode, strSALEBILLNO: SALEBILLNO, strdoctype: doctype }),
                success: function (res) {
                    part = res.d;
                    var data = JSON.parse(part);
                    $("div").find("#dtChargeDetails").handsontable('loadData', data);
                    document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value = part
                }
            });
        }
    </script>
</asp:Content>
