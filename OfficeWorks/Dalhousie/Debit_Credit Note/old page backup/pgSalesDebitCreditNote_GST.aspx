<%@ Page Title="" Language="vb" ValidateRequest="false" AutoEventWireup="false" MasterPageFile="~/Site1.Master" CodeBehind="pgSalesDebitCreditNote_GST.aspx.vb" Inherits="swterp.pgSalesDebitCreditNote_GST" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">
    <link href="../../../Lib/jquery-ui-1.11.2/jquery-ui.min.css" rel="stylesheet" />
    <link href="../../../Scripts/jquery.handsontable.full.css" rel="stylesheet" />

    <script src="../../../Scripts/modernizr-2.6.2.js" type="text/javascript"></script>
    <script src="../../../Scripts/jquery-1.11.1.min.js" type="text/javascript"></script>
    <script src="../../../Lib/jquery-ui-1.11.2/jquery-ui.min.js" type="text/javascript"></script>
    <script src="../../../Scripts/jquery.handsontable.full.js" type="text/javascript"></script>
    <script src="../../../Scripts/globalSearch.js" type="text/javascript"></script>
    <script src="../../../Scripts/jquery.maskedinput.js"></script>

    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            $("#mskDEBITCREDITNOTEDATE").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
            $("#mskREMOVALDATE").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
            $("#mskISSUEDATE").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
            $("#mskCNOTEDATE").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });

            $('.trVehicle').hide();
            $('.trDestination').hide();
            $('.trBooking').hide();
            $('.trSealno').hide();
            $('.trVesselflightno').hide();
            $('.trContainerno').hide();
            $('.trPadlockkeyno').hide();
            $('.trReno').hide();

        });

        function searchKeyPress(obj, e) {
            var strComp = document.getElementById('<%=txtCOMPCODE.ClientID%>');
            var strDiv = document.getElementById('<%=txtDIVCODE.ClientID%>');
            var strPROJECTNAME = document.getElementById('<%=txtPROJNAME.ClientID%>');
            var strOPTMODE = document.getElementById('<%=txtOPTMODE.ClientID%>').value;
            var strChannelCode = document.getElementById('<%=txtCHANNELCODE.ClientID%>');
            var strPartyCode = document.getElementById('<%=txtBUYERCODE.ClientID%>');
            var strYearCode = document.getElementById('<%=txtYRCODE.ClientID%>');
            var strReferenceType = document.getElementById('<%=txtREFERENCETYPE.ClientID%>');

            var unicode = e.keyCode ? e.keyCode : e.charCode
            if (unicode == 113) {
                if (obj.id == "mainContent_txtCHANNELCODE") {
                    obj.value = '';
                    var strHelp = "3059^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~MODULE:" + strPROJECTNAME.value + "~^^Sales Channel Information"
                    InvokePop(obj.id, strHelp);
                }

                if (obj.id == "mainContent_txtREFEXCISEINVNO") {
                    obj.value = '';
                    var strHelp = "3097^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~CHANNELCODE:" + strChannelCode.value + "~^" + "^" + "Ref. Excise Invoice Information"
                    InvokePop(obj.id, strHelp);
                }

                if (obj.id == "mainContent_txtSALEBILLNO") {
                    if (strOPTMODE == "A") {
                        obj.value = '';
                        var strHelp = "3174^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~CHANNELCODE:" + strChannelCode.value + "~^" + "^" + "Ref. Invoice Information"
                        InvokePop(obj.id, strHelp);
                    }
                }
                
                if (obj.id == "mainContent_txtDEBITCREDITNOTENO") {
                    if (strOPTMODE != "A") {
                        obj.value = '';
                        var strHelp = "3175^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~CHANNELCODE:" + strChannelCode.value + "~REFERENCETYPE:" + strReferenceType.value + "~^" + "^" + "Debit/Credit Note Information"
                        InvokePop(obj.id, strHelp);
                    }
                }

                

                if (obj.id == "mainContent_txtBROKERCODE") {
                    obj.value = '';
                    var strHelp = "74^" + "COMPANYCODE:" + strComp.value + "~PARTYTYPE:BROKER~MODULE:" + strPROJECTNAME.value + "~^^Sales Broker Information"
                    InvokePop(obj.id, strHelp);
                }

                if (obj.id == "mainContent_txtBUYERCODE") {
                    obj.value = '';
                    var strHelp = "74^" + "COMPANYCODE:" + strComp.value + "~PARTYTYPE:BUYER~MODULE:" + strPROJECTNAME.value + "~^^Sales Buyer Information"
                    InvokePop(obj.id, strHelp);
                }

                if (obj.id == "mainContent_txtADDRESSCODE") {
                    obj.value = '';
                    var strHelp = "3049^" + "COMPANYCODE:" + strComp.value + "~MODULE:" + strPROJECTNAME.value + "~PARTYTYPE:BUYER" + "~PARTYCODE:" + strPartyCode.value + "~^^Sales Buyer Address Information"
                    InvokePop(obj.id, strHelp);
                }

                if (obj.id == "mainContent_txtVESSELFLIGHTNO") {
                    obj.value = '';
                    var strHelp = "3036^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~^^Vessel Information"
                    InvokePop(obj.id, strHelp);
                }

                if (obj.id == "mainContent_txtTRANSPORTERCODE") {
                    obj.value = '';
                    var strHelp = "3053^" + "COMPANYCODE:" + strComp.value + "~MODULE:" + strPROJECTNAME.value + "~PARTYTYPE:TRANSPORTER~^^Transporter Information"
                    InvokePop(obj.id, strHelp);
                }

                if (obj.id == "mainContent_txtDESTINATION") {
                    obj.value = '';
                    var strHelp = "3054^" + "1=1~^" + "^" + "Destination Information"
                    InvokePop(obj.id, strHelp);
                }
                
            }
        };


        function checkRadioBtn() {
            var strRbtDebitNote = document.getElementById('<%=RbtDebitNote.ClientID%>');
             var strRbtCreditNote = document.getElementById('<%=RbtCreditNote.ClientID%>');

             if (strRbtDebitNote.checked == true) {
                 document.getElementById('<%=txtREFERENCETYPE.ClientID%>').value = "DEBIT NOTE";
                 document.getElementById('<%=lblDEBITCREDITNOTENO.ClientID%>').innerHTML = "Debit Note No.";
                 document.getElementById('<%=lblDEBITCREDITNOTEDATE.ClientID%>').innerHTML = "Debit Note Date";
                 document.getElementById('<%=txtDOCUMENTTYPE.ClientID%>').innerHTML = "DEBIT NOTE";
                 
                 clearText("radioBtn");
             }
            if (strRbtCreditNote.checked == true) {
                document.getElementById('<%=txtREFERENCETYPE.ClientID%>').value = "CREDIT NOTE";
                document.getElementById('<%=lblDEBITCREDITNOTENO.ClientID%>').innerHTML = "Credit Note No.";
                document.getElementById('<%=lblDEBITCREDITNOTEDATE.ClientID%>').innerHTML = "Credit Note Date";
                document.getElementById('<%=txtDOCUMENTTYPE.ClientID%>').innerHTML = "CREDIT NOTE";
                 clearText("radioBtn");
             }
         }

         function clearText(strTag) {
             if (strTag == "radioBtn") {
                 document.getElementById('<%=txtCHANNELCODE.ClientID%>').value = "";
                 document.getElementById('<%=txtSALEBILLNO.ClientID%>').value = "";
                 document.getElementById('<%=mskSALEBILLDATE.ClientID%>').value = "";
                 document.getElementById('<%=txtREFEXCISEINVNO.ClientID%>').value = "";
                 document.getElementById('<%=mskREFEXCISEINVDATE.ClientID%>').value = "";
                 document.getElementById('<%=txtDEBITCREDITNOTENO.ClientID%>').value = "";
                 document.getElementById('<%=mskDEBITCREDITNOTEDATE.ClientID%>').value = "";
            }
         }

        function rePopulateGrid() {
            var data1 = document.getElementById('<%=txtDETAILSGRIDDATA.ClientID%>').value;
            var data = jQuery.parseJSON(data1);
            $("div").find("#dtdetails").handsontable("loadData", data);

            var data2 = document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value;
            var datacharge = jQuery.parseJSON(data2);
            $("div").find("#dtchargedetails").handsontable("loadData", datacharge);
        }

        function Validate(obj, e) {
            var strCODE = obj.value;
            if (strCODE != null && strCODE != "[New Entry]" && strCODE != "[Select]" && strCODE != "" && strCODE != "undefined") {
                __doPostBack(obj.id, "TextChanged");
            }
        };

        function FetchWebData(strParameter) {
            var Keydata = '';
            var operationmode = document.getElementById('<%=txtOPTMODE.ClientID%>').value;

            if (strParameter == 'CHANNEL') {
                Keydata = document.getElementById('<%=txtCHANNELCODE.ClientID%>').value;
            }

            if (strParameter == 'ADDRESS') {
                Keydata = document.getElementById('<%=txtADDRESSCODE.ClientID%>').value + '~' + document.getElementById('<%=txtBUYERCODE.ClientID%>').value;
            }

            if (strParameter == 'TRANSPORTER') {
                Keydata = document.getElementById('<%=txtTRANSPORTERCODE.ClientID%>').value;
            }

            if (strParameter == 'VESSEL') {
                Keydata = document.getElementById('<%=txtVESSELFLIGHTNO.ClientID%>').value;
            }

            if (Keydata.length > 0) {
                $.ajax({
                    type: "POST",
                    url: "pgSalesDebitCreditNote_GST.aspx/GetWebData",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: false,
                    data: JSON.stringify({ strKey: Keydata, strParam: strParameter }),
                    success: function (res) {
                        var strArray = new Array()
                        strArray = res.d.split("~");

                        if (strParameter == 'CHANNEL') {
                            document.getElementById('<%=txtCHANNELTAG.ClientID%>').value = strArray[0];
                            $("#popupdiv").dialog('close');

                            if (operationmode = 'A') {
                                document.getElementById('<%=txtREFEXCISEINVNO.ClientID%>').focus();
                            }
                            if (operationmode != 'A') {
                                document.getElementById('<%=txtDEBITCREDITNOTENO.ClientID%>').focus();
                            }
                        }

                        if (strParameter == 'ADDRESS') {
                            document.getElementById('<%=txtADDRESSDESC.ClientID%>').value = strArray[0];
                            $("#popupdiv").dialog('close');
                        }

                        if (strParameter == 'TRANSPORTER') {
                            document.getElementById('<%=txtTRANSPORTERDESC.ClientID%>').value = strArray[0];
                            $("#popupdiv").dialog('close');
                        }

                        if (strParameter == 'DESTINATION') {
                            $("#popupdiv").dialog('close');
                        }

                        if (strParameter == 'VESSEL') {
                            document.getElementById('<%=txtVESSELFLIGHTDESC.ClientID%>').value = strArray[0];
                            $("#popupdiv").dialog('close');
                        }
                    },
                    error: function (xhr, status) {
                        alert("An error occurred: " + status);
                    }
                });
            }
        }
    </script>

    <div align="center">
        <div id="popupdiv" title="Details Information" class="popstyle">
            <label id="search">Search : </label>
            <input id="SearchText" type="text" style='width: 600px;' />
            <div id='searchPanel' style='width: auto; height: 260px; overflow: scroll'></div>
        </div>
        <table cellpadding="1" cellspacing="0" class="box_shade">
            <tr class="box_heading">
                <td colspan="7" align="center">
                    <asp:Label ID="lblHeader" Text="Debit/Credit Note " runat="server"></asp:Label>
                    <asp:TextBox ID="txtCOMPCODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtDIVCODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtYRCODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtUSRNAME" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtOPTMODE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtPROJNAME" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtSYSROWID" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtDETAILSGRIDDATA" runat="server" style="display:none" ></asp:TextBox>
                    <asp:TextBox ID="txtCHANNELTAG" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtEXCHANGERATE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtTOTALNETWEIGHT" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtTOTALNOOFPACKING" runat="server" Style="display: none"></asp:TextBox>
                    
                    <%-- For Charge Grid --%>
                    <asp:TextBox ID="txtDOCUMENTTYPE" runat="server" Style="display: none"></asp:TextBox>
                    <asp:TextBox ID="txtCHARGEGRIDDATA" runat="server" style="display:none" ></asp:TextBox>
                </td>
            </tr>

            <tr>
                <td align="left" colspan="6">
                <asp:RadioButton ID="RbtDebitNote" runat="server" GroupName="grpReference" onchange="checkRadioBtn()" Text="Debit Note" Checked="true" />
                               &nbsp;&nbsp;&nbsp;&nbsp;<asp:RadioButton ID="RbtCreditNote" runat="server" GroupName="grpReference" onchange="checkRadioBtn()" Text="Credit Note" />
                </td>
                <td align="left">
                    <asp:TextBox ID="txtREFERENCETYPE" runat="server" style="display:none" Width="50px"></asp:TextBox>
                </td>
            </tr>

            <tr>
                <td align="left">
                    <asp:Label ID="lblSALESTYPE" Text="Sales Type" runat="server"> </asp:Label>
                </td>
                <td colspan="6" align="left">
                    <asp:TextBox ID="txtCHANNELCODE" runat="server" Width="535px" CausesValidation="True" onkeydown="searchKeyPress(this,event)" onblur="FetchWebData('CHANNEL');" MaxLength="100"></asp:TextBox>
                    <asp:Label ID="lblMANDATORY1" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"></asp:Label>
                </td>
            </tr>

            <tr>
                <td align="left">
                    <asp:Label ID="lblPROFORMAINVNO" Text="Ref. Invoice No" runat="server"></asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtSALEBILLNO" runat="server" Width="100px" MaxLength="50" CausesValidation="True" AutoPostBack="true" onkeydown="searchKeyPress(this,event)" onblur="Validate(this,event);" TabIndex="1"></asp:TextBox>
                    <asp:Label ID="lblM4" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"></asp:Label>
                </td>
                <td align="left">
                    <asp:Label ID="lblPROFORMAINVDATE" Text="Ref. Invoice Date" runat="server"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="mskSALEBILLDATE" runat="server" Width="100px" CausesValidation="True" TabIndex="100" MaxLength="10" BackColor="#FFCCCC" ReadOnly="true"></asp:TextBox>
                </td>
                <td>
                    <asp:TextBox ID="txtREFEXCISEINVNO" runat="server" Width="100px" MaxLength="50" CausesValidation="True" AutoPostBack="true" onkeydown="searchKeyPress(this,event)" onblur="Validate(this,event);" TabIndex="1" style="display:none"></asp:TextBox>
                    </td>
                <td align="left">
                <asp:TextBox ID="mskREFEXCISEINVDATE" runat="server" Width="100px" CausesValidation="True" TabIndex="100" MaxLength="10" BackColor="#FFCCCC" ReadOnly="true" style="display:none"></asp:TextBox>
                </td>
                
                
                <td></td>
            </tr>

            <tr>
                <td align="left">
                    <asp:Label ID="lblDEBITCREDITNOTENO" Text="" runat="server"></asp:Label>
                </td>
                <td align="left" >
                    <asp:TextBox ID="txtDEBITCREDITNOTENO" runat="server" Width="100px" MaxLength="50" CausesValidation="True" onkeydown="searchKeyPress(this,event)" onblur="Validate(this,event);" AutoPostBack="true" TabIndex="2"></asp:TextBox>
                    <asp:Label ID="lblMANDATORY4" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"></asp:Label>
                </td>
                <td align="left">
                    <asp:Label ID="lblDEBITCREDITNOTEDATE" Text="" runat="server"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="mskDEBITCREDITNOTEDATE" runat="server" Width="100px" CausesValidation="True" TabIndex="3" ClientIDMode="Static"></asp:TextBox>
                    <asp:Label ID="lblMANDATORY5" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"></asp:Label>
                </td>
                <td align="left">
                    <asp:Label ID="lblChallanNo" Text="Challan No." runat="server" style="display:none"></asp:Label>
                    &nbsp;&nbsp;&nbsp;
                    <asp:TextBox ID="txtCHALLANNO" runat="server" Width="100px" MaxLength="50" CausesValidation="True" TabIndex="4" ReadOnly="true" style="display:none"></asp:TextBox>
                    <asp:Label ID="lblMANDATORY6" Text="*" runat="server" ForeColor="Red" Font-Size="Medium" style="display:none" ></asp:Label>
                </td>
            </tr>
            
            <tr>
                <td align="left">
                    <asp:Label ID="lblBROKERCODE" Text="Broker Code" runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtBROKERCODE" runat="server" Width="100px" MaxLength="10" CausesValidation="True" TabIndex="100" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
                <td colspan="5" align="left">
                    <asp:TextBox ID="txtBROKERNAME" runat="server" Width="418px" CausesValidation="True" TabIndex="100" Enabled="False" BackColor="#FFCCCC" ReadOnly="true"></asp:TextBox>
                    <asp:Label ID="lblMANDATORY7" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"></asp:Label>
                </td>
            </tr>

            <tr>
                <td align="left">
                    <asp:Label ID="lblBUYERCODE" Text="Buyer Code" runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtBUYERCODE" runat="server" Width="100px" MaxLength="10" CausesValidation="True" TabIndex="100" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
                <td colspan="5" align="left">
                    <asp:TextBox ID="txtBUYERNAME" runat="server" Width="418px" CausesValidation="True" TabIndex="100" Enabled="False" BackColor="#FFCCCC" ReadOnly="true"></asp:TextBox>
                    <asp:Label ID="lblMANDATORY8" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"></asp:Label>
                </td>
            </tr>

            <tr>
                <td align="left">
                    <asp:Label ID="lblADDRESSCODE" Text="Address Code" runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtADDRESSCODE" runat="server" Width="100px" MaxLength="10" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
                <td colspan="5" align="left">
                    <asp:TextBox ID="txtADDRESSDESC" runat="server" Width="418px" CausesValidation="True" TabIndex="100" Enabled="False" BackColor="#FFCCCC" ReadOnly="true"></asp:TextBox>
                    <asp:Label ID="lblMANDATORY9" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"></asp:Label>
                </td>
            </tr>

            <tr>
                <td align="left">
                    <asp:Label ID="lblADDRESSCODEBILL" Text="Billing Address " runat="server"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtADDRESSCODEBILL" runat="server" Width="100px" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
                <td colspan="5" align="left">
                <asp:TextBox ID="txtADDRESSDESCBILL" runat="server" Width="418px" CausesValidation="True" TabIndex="103" Enabled="False" BackColor="#FFCCCC" ReadOnly="true"></asp:TextBox>
                    <asp:Label ID="Label1" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"></asp:Label>
                </td>
            </tr>

            <tr>
                <td align="left">
                <asp:Label ID="lblBILLSTATE" Text="Billing State " runat="server"> </asp:Label>
                </td>
                <td align="left">
                 <asp:TextBox ID="txtBILLSTATECODE" runat="server" Width="100px" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
                <td colspan="3" align="left">
                <asp:TextBox ID="txtBILLSTATEDESC" runat="server" Width="418px" CausesValidation="True" TabIndex="103" Enabled="False" BackColor="#FFCCCC" ReadOnly="true"></asp:TextBox>
                    <asp:Label ID="Label2" Text="*" runat="server" ForeColor="Red" Font-Size="Medium"></asp:Label>
                </td>
                <td align="left">
                    <asp:Label ID="lblEXCHRATE" Text="Excg. Rate Export" runat="server" Font-Bold="true" Font-Size="11" ForeColor="Red" ></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtEXCHRATE" runat="server" Width="80px" CausesValidation="True" Font-Size="Large" Text="1.00" onblur="fn_Rate();" TabIndex="5" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
            </tr>

            <tr>
                <td colspan="7">
                    <table width="100%">
                        <tr>
                            <td>
                                <asp:Panel ID="gridPanel" runat="server">
                                    <cc1:tabcontainer ID="TabsView1" runat="server" ActiveTabIndex="0" Width="875px">
                                            <%--DO Tab--%>
	                                        <cc1:TabPanel runat="server" ID="TabPanelDetails">
		                                        <HeaderTemplate>
			                                        <div class="tabsize">Details</div>
		                                        </HeaderTemplate>
		                                        <ContentTemplate>
			                                        <asp:UpdatePanel ID="UpdatePanelLedger" runat="server">
				                                        <ContentTemplate>
					                                        <asp:Panel ID="PanelDetails" runat="server">
						                                        <table style="width: 100%; height: 99%">
							                                        <tr>
								                                        <td align="left">
									                                        <div id="dtDetails" style="overflow: auto; border: 1px solid olive; width: 850px; height: 150px;">    
                                                                            </div>
								                                        </td>
							                                         </tr>
									                            </table>
					                                        </asp:Panel>
				                                        </ContentTemplate>
			                                        </asp:UpdatePanel>
		                                        </ContentTemplate>
	                                        </cc1:TabPanel>
                                            
                                            <%--Charge Tab--%>
                                            <cc1:TabPanel runat="server" ID="TabPanelChargeDetails">
		                                        <HeaderTemplate>
			                                        <div class="tabsize">Charge Details</div>
		                                        </HeaderTemplate>
		                                        <ContentTemplate>
			                                        <asp:UpdatePanel ID="PanelChargeDetails" runat="server">
				                                        <ContentTemplate>
					                                        <asp:Panel ID="Panel1" runat="server">
						                                        <table style="width: 100%; height: 99%">
							                                        <tr>
								                                        <td align="left">
									                                        <div id="dtChargeDetails" style="overflow: auto; border: 1px solid olive; width: 850px; height: 150px;">    
                                                                            </div>
								                                        </td>
							                                         </tr>
									                            </table>
					                                        </asp:Panel>
				                                        </ContentTemplate>
			                                        </asp:UpdatePanel>
		                                        </ContentTemplate>
	                                        </cc1:TabPanel>
                                        </cc1:tabcontainer>
                                </asp:Panel>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            
            <tr>
                <td>
                    &nbsp;
                </td>
                <td align="left">
                    <%--<asp:Label ID="lblTOTALNETQUANTITY" Text="Total Net Quantity" runat="server" Font-Bold="true"> </asp:Label>--%>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtTOTALNETQUANTITY" runat="server" Width="100px" CausesValidation="True" Style="display: none" Font-Bold="true" BackColor="#FFCCCC"></asp:TextBox>
                    <asp:TextBox ID="txtNETINDIANAMOUNT" runat="server" Width="100px" CausesValidation="True" Style="display: none" Font-Bold="true" BackColor="#FFCCCC"></asp:TextBox>

                    <%--<asp:TextBox ID="txtTOTALNETQUANTITY" runat="server" Width="100px" CausesValidation="True" ReadOnly="true" Font-Bold="true" BackColor="#FFCCCC" TabIndex="100"></asp:TextBox>--%>
                </td>

                <td align="left">
                    <asp:Label ID="lblTOTALNETAMOUNT" Text="Total Net Amount" runat="server" Font-Bold="true"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtNETAMOUNT" runat="server" Width="100px" CausesValidation="True" Font-Bold="true" BackColor="#FFCCCC" TabIndex="100"></asp:TextBox>
                </td>

                <td align="left">
                    <asp:Label ID="lblTOTALGROSSAMOUNT" Text="Total Gross Amount" runat="server" Font-Bold="true"> </asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtGROSSAMOUNT" runat="server" Width="100px" CausesValidation="True" Font-Bold="true" BackColor="#FFCCCC" TabIndex="100"></asp:TextBox>
                </td>
            </tr>

            <tr  class="trRemarks" style="height:30px;">
                <td align="left">
                    <asp:Label ID="lblREMARKS" Text="Remarks" runat="server"></asp:Label>
                </td>
                <td align="left" colspan="6">
                    <asp:TextBox ID="txtREMARKS" runat="server" Width="770px" MaxLength="500" CausesValidation="True" TabIndex="20" ></asp:TextBox>
                </td>
            </tr>

            <tr class="trVehicle">
                <td align="left">
                    <asp:Label ID="lblVEHICLE" Text="Vehicle No" runat="server"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtVEHICLENO" runat="server" Width="100px" MaxLength="50" CausesValidation="True" TabIndex="6" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblTRANSPORTERCODE" Text="Transporter Code" runat="server"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtTRANSPORTERCODE" runat="server" Width="100px" MaxLength="50" CausesValidation="True" TabIndex="7" onblur="FetchWebData('TRANSPORTER');" onkeydown="searchKeyPress(this,event)" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
                <td align="left" colspan="3">
                    <asp:TextBox ID="txtTRANSPORTERDESC" runat="server" Width="418px" MaxLength="50" CausesValidation="True" ReadOnly="true" BackColor="#FFCCCC" TabIndex="100"></asp:TextBox>
                </td>
            </tr>

            <tr  class="trDestination">
                <td align="left">
                    <asp:Label ID="lblDESTINATION" Text="Destination" runat="server"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtDESTINATION" runat="server" Width="100px" MaxLength="50" CausesValidation="True" TabIndex="8" onblur="FetchWebData('DESTINATION');" onkeydown="searchKeyPress(this,event)" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>

                <td align="left">
                    <asp:Label ID="lblCNOTENO" Text="CNote No" runat="server"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtCNOTENO" runat="server" Width="100px" MaxLength="50" CausesValidation="True" TabIndex="9" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblCNOTEDATE" Text="CNote Date" runat="server"></asp:Label>
                </td>
                <td align="left" colspan="2">
                    <asp:TextBox ID="mskCNOTEDATE" runat="server" Width="100px" MaxLength="50" CausesValidation="True" TabIndex="10" ClientIDMode="Static" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
            </tr>

            <tr   class="trBooking">
                <td align="left">
                    <asp:Label ID="lblBOOKING" Text="Booking" runat="server"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtBOOKING" runat="server" Width="100px" MaxLength="50" CausesValidation="True" TabIndex="11" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>

                <td align="left">
                    <asp:Label ID="lblREMOVALDATE" Text="Removal Date" runat="server"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="mskREMOVALDATE" runat="server" Width="100px" MaxLength="50" CausesValidation="True" TabIndex="12" ClientIDMode="Static" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblTIMEOFPREPARATION" Text="Time of Preparation" runat="server"></asp:Label>
                </td>
                <td align="left" colspan="2">
                    <asp:TextBox ID="txtTIMEOFPREPARATION" runat="server" Width="100px" MaxLength="50" CausesValidation="True" TabIndex="13" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
            </tr>

            <tr   class="trSealno">
                <td align="left">
                    <asp:Label ID="lblSEALNO" Text="Seal No" runat="server"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtSEALNO" runat="server" Width="100px" MaxLength="50" CausesValidation="True" TabIndex="14" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>

                <td align="left">
                    <asp:Label ID="lblISSUEDATE" Text="Issue Date" runat="server"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="mskISSUEDATE" runat="server" Width="100px" MaxLength="50" CausesValidation="True" TabIndex="15" ClientIDMode="Static" ReadOnly="true" BackColor="#FFCCCC" ></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblTIMEOFISSUE" Text="Time of Issue" runat="server"></asp:Label>
                </td>
                <td align="left" colspan="2">
                    <asp:TextBox ID="txtTIMEOFISSUE" runat="server" Width="100px" MaxLength="50" CausesValidation="True" TabIndex="16" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
            </tr>

            <tr  class="trVesselflightno">
                <td align="left">
                    <asp:Label ID="lblVESSELFLIGHTNO" Text="Vessel" runat="server"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtVESSELFLIGHTNO" runat="server" Width="100px" MaxLength="50" CausesValidation="True" TabIndex="17" onblur="FetchWebData('VESSEL');" onkeydown="searchKeyPress(this,event)" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
                <td align="left" colspan="2">
                    <asp:TextBox ID="txtVESSELFLIGHTDESC" runat="server" Width="218px" MaxLength="50" CausesValidation="True" TabIndex="100" BackColor="#FFCCCC" ReadOnly="True"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblCONTAINERTYPE" Text="Container Type" runat="server"></asp:Label>
                </td>
                <td align="left" colspan="2">
                    <asp:TextBox ID="txtCONTAINERTYPE" runat="server" Width="100px" CausesValidation="True" TabIndex="18" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
            </tr>

            <tr  class="trContainerno">
                <td align="left">
                    <asp:Label ID="lblCONTAINERNO" Text="Container No" runat="server"></asp:Label>
                </td>
                <td align="left" colspan="2">
                    <asp:TextBox ID="txtCONTAINERNO" runat="server" Width="225px" MaxLength="50" CausesValidation="True" TabIndex="19" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
                <td align="left">
                    &nbsp;</td>
                <td align="left" colspan="3">
                    &nbsp;</td>
            </tr>

            <tr   class="trPadlockkeyno">
                <td align="left">
                    <asp:Label ID="lblPADLOCKKEYNO" Text="Padlock Key No" runat="server"></asp:Label>
                </td>
                <td align="left" colspan="2">
                    <asp:TextBox ID="txtPADLOCKKEYNO" runat="server" Width="100px" MaxLength="50" CausesValidation="True" TabIndex="21" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblEX" Text="EX From To" runat="server"></asp:Label>
                </td>
                <td align="left">
                    <asp:TextBox ID="txtEXFROM" runat="server" Width="130px" MaxLength="50" CausesValidation="True" TabIndex="22" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
                <td align="left" colspan="2">
                    <asp:TextBox ID="txtEXTO" runat="server" Width="130px" MaxLength="50" CausesValidation="True" TabIndex="23" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
            </tr>

            <tr   class="trReno">
                <td align="left">
                    <asp:Label ID="lblRENO" Text="ARE No" runat="server"></asp:Label>
                </td>
                <td align="left" colspan="2">
                    <asp:TextBox ID="txtRENO" runat="server" Width="100px" MaxLength="50" CausesValidation="True" TabIndex="24" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
                <td align="left">
                    <asp:Label ID="lblFORM1NO" Text="Form 1 No" runat="server"></asp:Label>
                </td>
                <td align="left" colspan="3">
                    <asp:TextBox ID="txtFORM1NO" runat="server" Width="130px" MaxLength="50" CausesValidation="True" TabIndex="25" ReadOnly="true" BackColor="#FFCCCC"></asp:TextBox>
                </td>
            </tr>
                       
        </table>
    </div>

    <%-- Details Grid --%>

    <script type="text/javascript">
        function returnColIndex_Details(searchStr) {
            var DataFields =
            [
                "SELECTED", "QUALITYCODE", "QUALITYMANUALDESC", "PACKINGCODE",
                "PACKSTYLECODE", "UORCODE", "NOOFPACKINGUNIT", "NOFROM", "NOTO",
                "INDIANRATE", "TOTALQUANTITY", "TOTALWEIGHT", "PACKSHEETWEIGHT",
                "GROSSWEIGHT", "TOTALAMOUNT", "TOTALINDIANAMOUNT", "MARKS",
                "TAREWEIGHT", "NETWEIGHT", "COMPANYCODE", "DIVISIONCODE",
                "YEARCODE", "CHANNELCODE", "DEBITCREDITNOTENO", "DEBITCREDITNOTEDATE",
                "DEBITCREDITNOTESERIALNO", "PROFORMAINVNO", "PROFORMAINVDATE", "PROFORMASERIALNO",
                "SHIPPINGINSNO", "SHIPPINGINSDATE", "SHIPPINGSERIALNO", "SAUDANO",
                "SAUDADATE", "SAUDASERIALNO", "EXPORTWEIGHT", "CONTAINERSIZE",
                "RATE", "TRADINGGPNO", "TRADINGGPDATE", "TRADINGGPSERIALNO",
                "ORDERBYCODE", "HBPWT", "AGAINSTEXCISEINVDATE", "AGAINSTEXCISEINVNO",
                "SYSROWID", "USERNAME", "OPERATIONMODE"
            ];

            for (var j = 0; j < DataFields.length; j++) {
                if (DataFields[j] == searchStr) {
                    return j;
                }
            }
            return -1;
        }

        var noneditablecolor = function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
            td.style.backgroundColor = '#FFCCCC';
            td.style.color = 'black';
        };

        var $container = $("div").find("#dtDetails");
        $container.handsontable({
            data: [],
            colWidths: ['60', '80', '350', '80',
                        '80', '80', '80', '50', '50',
                        '80', '100', '80', '80',
                        '80', '100', '110', '100',
                        '1', '1', '1', '1',
                        '1', '1', '1', '1',
                        '1', '1', '1', '1',
                        '1', '1', '1', '1',
                        '1', '1', '1', '1',
                        '1', '1', '1', '1',
                        '1', '1', '1', '1',
                        '1', '1', '1'
            ],
            fillHandle: false,
            manualColumnResize: true,
            colHeaders: ['Select', 'Quality', 'Quality Description', 'Packing',
                        'Pack Style', 'UOR', 'Quantity <br/> (BS)', 'No. <br/> From', 'No. <br/> To',
                        'Rate', 'Total <br/> Quantity', 'Total <br/> Weight', 'Pack <br />Sheet Wt',
                        'Gross<br/> Weight', 'Total Amount', 'Total <br/>Indian Amt', 'Marks',
                        'TAREWEIGHT', 'NETWEIGHT', 'COMPANYCODE', 'DIVISIONCODE',
                        'YEARCODE', 'CHANNELCODE', 'DEBITCREDITNOTENO', 'DEBITCREDITNOTEDATE',
                        'DEBITCREDITNOTESERIALNO', 'PROFORMAINVNO', 'PROFORMAINVDATE', 'PROFORMASERIALNO',
                        'SHIPPINGINSNO', 'SHIPPINGINSDATE', 'SHIPPINGSERIALNO', 'SAUDANO',
                        'SAUDADATE', 'SAUDASERIALNO', 'EXPORTWEIGHT', 'CONTAINERSIZE',
                        'INDIANRATE', 'TRADINGGPNO', 'TRADINGGPDATE', 'TRADINGGPSERIALNO',
                        'ORDERBYCODE', 'HBPWT', 'AGAINSTEXCISEINVDATE', 'AGAINSTEXCISEINVNO',
                        'SYSROWID', 'USERNAME', 'OPERATIONMODE'
            ],
            columns: [
                { data: "SELECTED", type: 'checkbox', checkedTemplate: 'YES', uncheckedTemplate: 'NO' },
                { data: "QUALITYCODE", type: 'text', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "QUALITYMANUALDESC", type: 'text', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "PACKINGCODE", type: 'text', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "PACKSTYLECODE", type: 'text', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "UORCODE", type: 'text', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "NOOFPACKINGUNIT", type: 'numeric', format: '0.00', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "NOFROM", type: 'numeric', format: '0', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "NOTO", type: 'numeric', format: '0', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "INDIANRATE", type: 'numeric', format: '0.0000000000', language: 'en' },
                { data: "TOTALQUANTITY", type: 'numeric', format: '0.000', language: 'en', renderer: noneditablecolor },
                { data: "TOTALWEIGHT", type: 'numeric', format: '0.000', language: 'en', renderer: noneditablecolor },
                { data: "PACKSHEETWEIGHT", type: 'numeric', format: '0.000', language: 'en', renderer: noneditablecolor },
                { data: "GROSSWEIGHT", type: 'numeric', format: '0.000', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "TOTALAMOUNT", type: 'numeric', format: '0.00', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "TOTALINDIANAMOUNT", type: 'numeric', format: '0.00', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "MARKS" },

                //------------- Hidden Columns
                { data: "TAREWEIGHT", readOnly: true },
                { data: "NETWEIGHT", readOnly: true },
                { data: "COMPANYCODE", readOnly: true },
                { data: "DIVISIONCODE", readOnly: true },
                { data: "YEARCODE", readOnly: true },
                { data: "CHANNELCODE", readOnly: true },
                { data: "DEBITCREDITNOTENO", readOnly: true },
                { data: "DEBITCREDITNOTEDATE", readOnly: true },
                { data: "DEBITCREDITNOTESERIALNO", readOnly: true },
                { data: "PROFORMAINVNO", readOnly: true },
                { data: "PROFORMAINVDATE", readOnly: true },
                { data: "PROFORMASERIALNO", readOnly: true },
                { data: "SHIPPINGINSNO", readOnly: true },
                { data: "SHIPPINGINSDATE", readOnly: true },
                { data: "SHIPPINGSERIALNO", readOnly: true },
                { data: "SAUDANO", readOnly: true },
                { data: "SAUDADATE", readOnly: true },
                { data: "SAUDASERIALNO", readOnly: true },
                { data: "EXPORTWEIGHT", readOnly: true },
                { data: "CONTAINERSIZE", readOnly: true },
                { data: "RATE", readOnly: true },
                { data: "TRADINGGPNO", readOnly: true },
                { data: "TRADINGGPDATE", readOnly: true },
                { data: "TRADINGGPSERIALNO", readOnly: true },
                { data: "ORDERBYCODE", readOnly: true },
                { data: "HBPWT", readOnly: true },
                { data: "AGAINSTEXCISEINVDATE", readOnly: true },
                { data: "AGAINSTEXCISEINVNO", readOnly: true },
                { data: "SYSROWID", readOnly: true },
                { data: "USERNAME", readOnly: true },
                { data: "OPERATIONMODE", readOnly: true }
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
                var varReferanceType = document.getElementById('<%=txtREFERENCETYPE.ClientID%>').value;

                if ($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details("SELECTED")) == "YES") {
                    //-------------- Filling Hidden Fields
                    if ((columnIndex == "SELECTED" || columnIndex == "QUALITYMANUALDESC" || columnIndex == "NOOFPACKINGUNIT" || columnIndex == "NOFROM" || columnIndex == "NOTO"
                        || columnIndex == "TOTALQUANTITY" || columnIndex == "TOTALWEIGHT" || columnIndex == "PACKSHEETWEIGHT")) {
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('COMPANYCODE'), document.getElementById('<%=txtCOMPCODE.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('DIVISIONCODE'), document.getElementById('<%=txtDIVCODE.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('YEARCODE'), document.getElementById('<%=txtYRCODE.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('CHANNELCODE'), document.getElementById('<%=txtCHANNELCODE.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('DEBITCREDITNOTENO'), document.getElementById('<%=txtDEBITCREDITNOTENO.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('DEBITCREDITNOTEDATE'), document.getElementById('<%=mskDEBITCREDITNOTEDATE.ClientID%>').value);
                        if ($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('NETWEIGHT')) == null) {
                            $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('NETWEIGHT'), '0.00');
                        }
                        if ($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('INDIANRATE')) == null) {
                            $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('INDIANRATE'), '0.0000');
                        }
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('OPERATIONMODE'), document.getElementById('<%=txtOPTMODE.ClientID%>').value);
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('USERNAME'), document.getElementById('<%=txtUSRNAME.ClientID%>').value);

                        //---------- For Generating Excise Serial No
                        setSerialNo();
                    }

                    if (columnIndex == "SELECTED") {
                        //alert('selected');
                        var Weight = 0;
                        var PackWeight = 0;
                        var TotalQty = 0;
                        var Amount = 0;
                        var INAmount = 0;
                        var NoFrom = 0;
                        var NoTo = 0;
                        var ErrHndlNoOfPacking = true;
                        var TotalQuantity = -1;
                        var QualityCode = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('QUALITYCODE'));
                        var PackingCode = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('PACKINGCODE'));
                        var PackingWt = 0;
                        var UORCode = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('UORCODE'));
                        var Rate = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('RATE'));
                        var INRRate = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('INDIANRATE'));
                        var NoofPackingUnit = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('NOOFPACKINGUNIT'));
                        var NoofCalculation = 0;
                        var ChannelTag = document.getElementById('<%=txtCHANNELTAG.ClientID%>').value;
                        var TotalWt = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT'));
                        var ExchangeRate = document.getElementById('<%=txtEXCHANGERATE.ClientID%>').value;

                        $.ajax({
                            url: 'pgSalesDebitCreditNote_GST.aspx/fnSalesAllSolution',
                            contentType: "application/json; charset=utf-8",
                            type: 'POST',
                            dataType: 'json',
                            data: JSON.stringify({
                                rWeight: Weight, rPackWeight: PackWeight, rTotalQty: TotalQty, rAmount: Amount, rINAmount: INAmount, rNoFrom: NoFrom, rNoTo: NoTo,
                                vQualityCode: QualityCode, vPackingCode: PackingCode, vPackSheetWeight: PackingWt, vUORCode: UORCode, vRate: Rate,
                                vINRate: INRRate, vNoOfPackingUnit: NoofPackingUnit, vNoCalculation: NoofCalculation, oErrHndlNoOfPacking: ErrHndlNoOfPacking,
                                strChannelTag: ChannelTag, vTotalQuantity: TotalQuantity, vExchangeRate: ExchangeRate
                            }),
                            success: function (response) {
                                var RetVal = new Array()
                                RetVal = response.d.split("~");

                                $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT'), RetVal[0]);
                                $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('PACKSHEETWEIGHT'), RetVal[1]);
                                $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('TOTALQUANTITY'), RetVal[2]);
                                $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('TOTALAMOUNT'), RetVal[3]);
                                $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('TOTALINDIANAMOUNT'), RetVal[4]);
                                $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('NETWEIGHT'), (parseFloat($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT'))) + parseFloat(RetVal[1])));
                                $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('GROSSWEIGHT'), (parseFloat($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT'))) + parseFloat(RetVal[1])));
                                $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('INDIANRATE'), RetVal[12]);
                                $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('NOFROM'), 1);
                                $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('NOTO'), RetVal[6] + 1);
                            }
                        });
                        //--sleep(1000);
                        fnTotalQuantityAmount(rowIndex);

                        //-----------------start effect on charges---------------------------
                        var ChargeGridData = document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value;
                        var TotalNetQuantity = document.getElementById('<%=txtTOTALNETQUANTITY.ClientID%>').value;
                        var TotalNetAmount = document.getElementById('<%=txtNETAMOUNT.ClientID%>').value;
                        var TotalNetWeight = document.getElementById('<%=txtTOTALNETWEIGHT.ClientID%>').value;
                        var TotalNoofPacking = document.getElementById('<%=txtTOTALNOOFPACKING.ClientID%>').value;

                        $.ajax({
                            url: 'pgSalesDebitCreditNote_GST.aspx/prcChargeDetails',
                            contentType: "application/json; charset=utf-8",
                            type: 'POST',
                            dataType: 'json',
                            data: JSON.stringify({ strChargeGridData: ChargeGridData, strTotalNetQuantity: TotalNetQuantity, strTotalNetAmount: TotalNetAmount, strTotalNetWeight: TotalNetWeight, strTotalNoofPacking: TotalNoofPacking }),
                            success: function (response) {
                                part = response.d;
                                var data = JSON.parse(part);
                                $("div").find("#dtChargeDetails").handsontable('loadData', data);
                                document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value = part;

                                //------------- For Calculating Gross Amount
                                var TotalAmount = document.getElementById('<%=txtNETAMOUNT.ClientID%>').value;
                                var ChargeAmount = 0;
                                var rowCount = $("#dtChargeDetails").handsontable('countRows');

                                for (var i = 0; i < rowCount; i++) {
                                    if ($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("SELECTED")) == "YES") {
                                        ChargeAmount += Number($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("CHARGEAMOUNT")));
                                        if (Number($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("CHARGEAMOUNT"))) != 0) {
                                            $("#dtChargeDetails").handsontable('setDataAtCell', i, returnColIndex_ChargeDetails('DOCUMENTDATE'), document.getElementById('<%=mskDEBITCREDITNOTEDATE.ClientID%>').value);
                                        }
                                        else {
                                            $("#dtChargeDetails").handsontable('setDataAtCell', i, returnColIndex_ChargeDetails('DOCUMENTDATE'), 'null');
                                        }
                                    }
                                }
                                if ($("#dtChargeDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_ChargeDetails("ADDLESSSIGN")) == "+") {
                                    document.getElementById('<%=txtGROSSAMOUNT.ClientID%>').value = Number(TotalAmount) + Number(ChargeAmount);
                                }
                                else if ($("#dtChargeDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_ChargeDetails("ADDLESSSIGN")) == "-") {
                                    document.getElementById('<%=txtGROSSAMOUNT.ClientID%>').value = Number(TotalAmount) - Number(ChargeAmount);
                                }
                            }
                        });
                        //-----------------end effect on charges-----------------------------

                    fnTotalGrossAmount(rowIndex);
                }


                if (columnIndex == "INDIANRATE") {
                    //alert('rate');
                    var varINDIANRATE = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('INDIANRATE'));

                    if (Number(varINDIANRATE) >= 0) {
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('RATE'), $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('INDIANRATE')));
                        //alert('start');
                        var Weight = 0;
                        var PackWeight = 0;
                        var TotalQty = 0;
                        var Amount = 0;
                        var INAmount = 0;
                        var NoFrom = 0;
                        var NoTo = 0;
                        var ErrHndlNoOfPacking = true;
                        var TotalQuantity = -1;
                        var QualityCode = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('QUALITYCODE'));
                        var PackingCode = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('PACKINGCODE'));
                        var PackingWt = 0;
                        var UORCode = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('UORCODE'));
                        var Rate = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('RATE'));
                        var INRRate = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('INDIANRATE'));
                        var NoofPackingUnit = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('NOOFPACKINGUNIT'));
                        var ExchangeRate = document.getElementById('<%=txtEXCHANGERATE.ClientID%>').value;

                    var NoofCalculation = 0;
                    var ChannelTag = document.getElementById('<%=txtCHANNELTAG.ClientID%>').value;
                        var TotalWt = 0;
                        //alert('end');
                        $.ajax({
                            url: 'pgSalesDebitCreditNote_GST.aspx/fnSalesAllSolution',
                            contentType: "application/json; charset=utf-8",
                            type: 'POST',
                            dataType: 'json',
                            async: false,
                            data: JSON.stringify({
                                rWeight: Weight, rPackWeight: PackWeight, rTotalQty: TotalQty, rAmount: Amount, rINAmount: INAmount, rNoFrom: NoFrom, rNoTo: NoTo,
                                vQualityCode: QualityCode, vPackingCode: PackingCode, vPackSheetWeight: PackingWt, vUORCode: UORCode, vRate: Rate,
                                vINRate: INRRate, vNoOfPackingUnit: NoofPackingUnit, vNoCalculation: NoofCalculation, oErrHndlNoOfPacking: ErrHndlNoOfPacking,
                                strChannelTag: ChannelTag, vTotalQuantity: TotalQuantity, vExchangeRate: ExchangeRate
                            }),
                            success: function (response) {
                                var RetVal = new Array()
                                RetVal = response.d.split("~");
                                $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('TOTALAMOUNT'), RetVal[3]);
                                $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('TOTALINDIANAMOUNT'), RetVal[4]);
                            }
                        });
                        fnTotalGrossAmount(rowIndex);
                    }
                    else {
                       // alert('Rate can"t be less than or equal to Zero.');
                        //$("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('INDIANRATE'), 0);
                    }
                    ////if (varReferanceType == "CREDIT NOTE") {
                    ////    if (Number(varINDIANRATE) > 0) {
                    ////        varINDIANRATE = -varINDIANRATE;
                    ////        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('INDIANRATE'), varINDIANRATE);
                    ////    }
                    ////}
                    ////if (varReferanceType == "DEBIT NOTE") {
                    ////    if (Number(varINDIANRATE) < 0) {                            
                    ////        varINDIANRATE = Math.abs(varINDIANRATE);
                    ////       // alert('rate' + varINDIANRATE);
                    ////        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('INDIANRATE'), varINDIANRATE);
                    ////    }                        
                    ////}
                    
                }

                    if (columnIndex == "TOTALINDIANAMOUNT") {
                        //alert('indian amount');
                        //-------------- Calculating Total Quantity & Amount
                        //--sleep(1000);
                        fnTotalQuantityAmount(rowIndex);
                        fnTotalGrossAmount(rowIndex);

                        //-----------------start effect on charges---------------------------
                        var ChargeGridData = document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value;
                        var TotalNetQuantity = document.getElementById('<%=txtTOTALNETQUANTITY.ClientID%>').value;
                        var TotalNetAmount = document.getElementById('<%=txtNETAMOUNT.ClientID%>').value;
                        var TotalNetWeight = document.getElementById('<%=txtTOTALNETWEIGHT.ClientID%>').value;
                        var TotalNoofPacking = document.getElementById('<%=txtTOTALNOOFPACKING.ClientID%>').value;

                        $.ajax({
                            url: 'pgSalesDebitCreditNote_GST.aspx/prcChargeDetails',
                            contentType: "application/json; charset=utf-8",
                            type: 'POST',
                            dataType: 'json',
                            data: JSON.stringify({ strChargeGridData: ChargeGridData, strTotalNetQuantity: TotalNetQuantity, strTotalNetAmount: TotalNetAmount, strTotalNetWeight: TotalNetWeight, strTotalNoofPacking: TotalNoofPacking }),
                            success: function (response) {
                                part = response.d;
                                var data = JSON.parse(part);
                                $("div").find("#dtChargeDetails").handsontable('loadData', data);
                                document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value = part;

                                //------------- For Calculating Gross Amount
                                var TotalAmount = document.getElementById('<%=txtNETAMOUNT.ClientID%>').value;
                                var ChargeAmount = 0;
                                var rowCount = $("#dtChargeDetails").handsontable('countRows');

                                for (var i = 0; i < rowCount; i++) {
                                    if ($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("SELECTED")) == "YES") {
                                        ChargeAmount += Number($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("CHARGEAMOUNT")));
                                        if (Number($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("CHARGEAMOUNT"))) != 0) {
                                            $("#dtChargeDetails").handsontable('setDataAtCell', i, returnColIndex_ChargeDetails('DOCUMENTDATE'), document.getElementById('<%=mskDEBITCREDITNOTEDATE.ClientID%>').value);
                                        }
                                        else {
                                            $("#dtChargeDetails").handsontable('setDataAtCell', i, returnColIndex_ChargeDetails('DOCUMENTDATE'), 'null');
                                        }
                                    }
                                }
                                if ($("#dtChargeDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_ChargeDetails("ADDLESSSIGN")) == "+") {
                                    document.getElementById('<%=txtGROSSAMOUNT.ClientID%>').value = Number(TotalAmount) + Number(ChargeAmount);
                                }
                                else if ($("#dtChargeDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_ChargeDetails("ADDLESSSIGN")) == "-") {
                                    document.getElementById('<%=txtGROSSAMOUNT.ClientID%>').value = Number(TotalAmount) - Number(ChargeAmount);
                                }
                            }
                        });
                        //-----------------end effect on charges-----------------------------
                    }
                    if (columnIndex == "TOTALWEIGHT") {
                        var UORCode = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('UORCODE'));
                        var Qualitycode = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('QUALITYCODE'));
                        var PackingCode = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('PACKINGCODE'));

                        $.ajax({
                            url: 'pgSalesDebitCreditNote_GST.aspx/fnMeasurementInfo',
                            contentType: "application/json; charset=utf-8",
                            type: 'POST',
                            dataType: 'json',
                            data: JSON.stringify({ strUORCode: UORCode, strQualitycode: Qualitycode, strPackingCode: PackingCode }),
                            success: function (response) {
                                var RetVal = new Array()
                                RetVal = response.d.split("~");

                                if (RetVal[1] == "TOTAL WEIGHT") {
                                    if (RetVal[2] == RetVal[3]) {
                                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('TOTALAMOUNT'), Number($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT')) * $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('RATE')) / RetVal[0]).toFixed(2));
                                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('TOTALINDIANAMOUNT'), Number($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT')) * $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('RATE')) / RetVal[0]).toFixed(2));
                                    }
                                    if (RetVal[2] == "KGS" && RetVal[3] == "MT") {
                                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('TOTALAMOUNT'), Number($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT')) * $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('RATE')) * 1000 / RetVal[0]).toFixed(2));
                                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('TOTALINDIANAMOUNT'), Number($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT')) * $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('RATE')) * 1000 / RetVal[0]).toFixed(2));
                                    }
                                    if (RetVal[2] == "MT" && RetVal[3] == "KGS") {
                                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('TOTALAMOUNT'), Number($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT')) * $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('RATE')) / 1000 / RetVal[0]).toFixed(2));
                                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('TOTALINDIANAMOUNT'), Number($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT')) * $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('RATE')) / 1000 / RetVal[0]).toFixed(2));
                                    }
                                }
                                $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('NETWEIGHT'), (parseFloat($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT'))) + parseFloat($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('PACKSHEETWEIGHT')))));
                            }
                        });
                    }
                    
                    if (columnIndex == "TOTALQUANTITY") {
                        var Weight = 0;
                        var PackWeight = 0;
                        var TotalQty = 0;
                        var Amount = 0;
                        var INAmount = 0;
                        var NoFrom = 0;
                        var NoTo = 0;
                        var ErrHndlNoOfPacking = true;
                        var TotalQuantity = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALQUANTITY'));;
                        var QualityCode = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('QUALITYCODE'));
                        var PackingCode = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('PACKINGCODE'));
                        var PackingWt = 0;
                        var UORCode = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('UORCODE'));
                        var Rate = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('RATE'));
                        var INRRate = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('RATE'));
                        var NoofPackingUnit = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('NOOFPACKINGUNIT'));
                        var NoofCalculation = 0;
                        var ChannelTag = document.getElementById('<%=txtCHANNELTAG.ClientID%>').value;
                        var TotalWt = $("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT'));
                        var ExchangeRate = document.getElementById('<%=txtEXCHANGERATE.ClientID%>').value;

                        $.ajax({
                            url: 'pgSalesDebitCreditNote_GST.aspx/fnSalesAllSolution',
                            contentType: "application/json; charset=utf-8",
                            type: 'POST',
                            dataType: 'json',
                            data: JSON.stringify({
                                rWeight: Weight, rPackWeight: PackWeight, rTotalQty: TotalQty, rAmount: Amount, rINAmount: INAmount, rNoFrom: NoFrom, rNoTo: NoTo,
                                vQualityCode: QualityCode, vPackingCode: PackingCode, vPackSheetWeight: PackingWt, vUORCode: UORCode, vRate: Rate,
                                vINRate: INRRate, vNoOfPackingUnit: NoofPackingUnit, vNoCalculation: NoofCalculation, oErrHndlNoOfPacking: ErrHndlNoOfPacking,
                                strChannelTag: ChannelTag, vTotalQuantity: TotalQuantity, vExchangeRate: ExchangeRate
                            }),
                            success: function (response) {
                                var RetVal = new Array()
                                RetVal = response.d.split("~");
                                if (RetVal[19] != "TOTAL WEIGHT") {
                                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT'), RetVal[0]);
                                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('PACKSHEETWEIGHT'), RetVal[1]);
                                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('EXPORTWEIGHT'), RetVal[0]);
                                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('TOTALAMOUNT'), Number(RetVal[3]).toFixed(2));
                                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('TOTALINDIANAMOUNT'), Number(RetVal[4]).toFixed(2));
                                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('NETWEIGHT'), (parseFloat($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT'))) + parseFloat(RetVal[1])));
                                }
                            }
                        });
                    }
                    if (columnIndex == "PACKSHEETWEIGHT") {
                        $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('GROSSWEIGHT'), (parseFloat($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT'))) + parseFloat($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('PACKSHEETWEIGHT')))));
                    }
            }
            else {
                if (columnIndex == "SELECTED") {
                    fnTotalQuantityAmount(rowIndex);
                    fnTotalGrossAmount(rowIndex);
                    $("#dtDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_Details('DEBITCREDITNOTENO'), '');
                }
            }
            });

        document.getElementById('<%=txtDETAILSGRIDDATA.ClientID%>').value = '';
            fn_GetGridData();
        }
        
        $("#save").click(function () {
            var $container = $("div").find("#dtDetails");
            var handsontable = $container.data('handsontable');
            var myData = handsontable.getData();
            $.ajax({
                url: 'pgSalesDebitCreditNote_GST.aspx/GetData',
                contentType: "application/json; charset=utf-8",
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify({ gridData: JSON.stringify(myData) }),
                success: function (res) {
                }
            });
        });

        function fn_GetGridData() {
            var $container = $("div").find("#dtDetails");
            var handsontable = $container.data('handsontable');
            var myData = handsontable.getData();
            document.getElementById('<%=txtDETAILSGRIDDATA.ClientID%>').value = JSON.stringify(myData);
        }

        function fnTotalQuantityAmount(rowIndex) {
            var TotalAmount = 0;
            var TotalQuantity = 0;
            var TotalWeight = 0;
            var TotlaNoofpacking = 0;
            var rowCount = $("#dtDetails").handsontable('countRows');

            document.getElementById('<%=txtTOTALNETQUANTITY.ClientID%>').value = Number(TotalQuantity);
            document.getElementById('<%=txtNETAMOUNT.ClientID%>').value = Number(TotalAmount);
            document.getElementById('<%=txtTOTALNETWEIGHT.ClientID%>').value = Number(TotalWeight);
            document.getElementById('<%=txtTOTALNOOFPACKING.ClientID%>').value = Number(TotlaNoofpacking);

            if ($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details("SELECTED")) == "YES") {
                //--sleep(1000);
                for (var Temp = 0; Temp = 0;) {
                    Temp = Number($("#dtDetails").handsontable('getDataAtCell', Temp, returnColIndex_Details('TOTALAMOUNT')));
                }

                TotalAmount = Number(TotalAmount) + Number($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALINDIANAMOUNT')));
                TotalQuantity = Number(TotalQuantity) + Number($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALQUANTITY')));
                TotalWeight = Number(TotalWeight) + Number($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT')));
                TotlaNoofpacking = Number(TotlaNoofpacking) + Number($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('NOOFPACKINGUNIT')));
            }
            else {
                //--sleep(1000);
                for (var Temp = 0; Temp = 0;) {
                    Temp = Number($("#dtDetails").handsontable('getDataAtCell', Temp, returnColIndex_Details('TOTALAMOUNT')));
                }
                TotalAmount = Number(TotalAmount) - Number($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALINDIANAMOUNT')));
                TotalQuantity = Number(TotalQuantity) - Number($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALQUANTITY')));
                TotalWeight = Number(TotalWeight) - Number($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('TOTALWEIGHT')));
                TotlaNoofpacking = Number(TotlaNoofpacking) - Number($("#dtDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_Details('NOOFPACKINGUNIT')));
            }
            for (var Temp = 0; Temp = 0;) {
                Temp = Number($("#dtDetails").handsontable('getDataAtCell', Temp, returnColIndex_Details('TOTALAMOUNT')));
            }
            document.getElementById('<%=txtTOTALNETQUANTITY.ClientID%>').value = Number(document.getElementById('<%=txtTOTALNETQUANTITY.ClientID%>').value) + Number(TotalQuantity);
            document.getElementById('<%=txtNETAMOUNT.ClientID%>').value = Number(document.getElementById('<%=txtNETAMOUNT.ClientID%>').value) + Number(TotalAmount);
            document.getElementById('<%=txtNETINDIANAMOUNT.ClientID%>').value = Number(document.getElementById('<%=txtNETAMOUNT.ClientID%>').value);
            document.getElementById('<%=txtTOTALNETWEIGHT.ClientID%>').value = Number(document.getElementById('<%=txtTOTALNETWEIGHT.ClientID%>').value) + Number(TotalWeight);
            document.getElementById('<%=txtTOTALNOOFPACKING.ClientID%>').value = Number(document.getElementById('<%=txtTOTALNOOFPACKING.ClientID%>').value) + Number(TotlaNoofpacking);
        }

        function setSerialNo() {
            var $container = $("div").find("#dtDetails");
            var handsontable = $container.data('handsontable');
            var rowCount = $("#dtDetails").handsontable('countRows');
            var slNo = 0;

            for (var i = 0; i < rowCount; i++) {
                if ($("#dtDetails").handsontable('getDataAtCell', i, returnColIndex_Details("SELECTED")) == "YES") {
                    slNo++;
                    $("#dtDetails").handsontable('setDataAtCell', i, returnColIndex_Details("DEBITCREDITNOTESERIALNO"), slNo);
                }
            }
        }

        function fnTotalGrossAmount(rowIndex) {
            var TotalAmount = document.getElementById('<%=txtNETAMOUNT.ClientID%>').value;
            var ChargeAmount = 0;
            var rowCount = $("#dtChargeDetails").handsontable('countRows');

            for (var i = 0; i < rowCount; i++) {

                for (var Temp = 0; Temp = 0;) {
                    Temp = Number($("#dtChargeDetails").handsontable('getDataAtCell', Temp, returnColIndex_ChargeDetails("CHARGEAMOUNT")));
                }

                if ($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("SELECTED")) == "YES") {
                    if ($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("ADDLESSSIGN")) == "+") {
                        ChargeAmount += Number($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("CHARGEAMOUNT")));
                    }
                    else if ($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("ADDLESSSIGN")) == "-") {
                        ChargeAmount -= Number($("#dtChargeDetails").handsontable('getDataAtCell', i, returnColIndex_ChargeDetails("CHARGEAMOUNT")));
                    }
                }

            }
            document.getElementById('<%=txtGROSSAMOUNT.ClientID%>').value = Number(TotalAmount) + Number(ChargeAmount);


        }

        function FetchGridData() {
            var ProformaInvNo = document.getElementById('<%=txtREFEXCISEINVNO.ClientID%>').value;
            var OperationMode = document.getElementById('<%=txtOPTMODE.ClientID%>').value;
            var ChannelCode = document.getElementById('<%=txtCHANNELCODE.ClientID%>').value;
            var varDebitCreditNoteNo = document.getElementById('<%=txtDEBITCREDITNOTENO.ClientID%>').value;


            $.ajax({
                type: "POST",
                url: "pgSalesDebitCreditNote_GST.aspx/GetGridData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ strProformaInvNo: ProformaInvNo, strOperationMode: OperationMode, strChannelCode: ChannelCode, strDebitCreditNoteNo: varDebitCreditNoteNo }),
                success: function (res) {
                    part = res.d;
                    var data = JSON.parse(part);
                    $("div").find("#dtDetails").handsontable('loadData', data);
                    document.getElementById('<%=txtDETAILSGRIDDATA.ClientID%>').value = part
                },
                error: function (xhr, status) {
                    alert("An error occurred: " + status);
                }
            });
        }

        function fnFetchExistingDetailsGridData() {
            var txtData = document.getElementById('<%=txtDETAILSGRIDDATA.ClientID%>').value;
            var data = jQuery.parseJSON(txtData);
            $("div").find("#dtDetails").handsontable("loadData", data);
        }
    </script>

    <%-- Charge Grid --%>
    <script type="text/javascript">
        function returnColIndex_ChargeDetails(searchStr) {
            var DataFields =
            [
                "SELECTED", "CHARGECODE", "CHARGEDESC", "CHARGENATURE",
                "FORMULA", "RATE", "ADDLESSSIGN", "CHARGEAMOUNT",
                "COMPANYCODE", "DIVISIONCODE", "YEARCODE",
                "CHANNELCODE", "DOCUMENTNO", "DOCUMENTDATE", "DOCUMENTTYPE",
                "ASSESSABLEAMOUNT", "SYSROWID", "USERNAME", "CHARGETYPE", "ADDLESS", "OPERATIONMODE",
                "UNIT", "UORCODE", "UNITQUANTITY"
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
            colWidths: ['60', '1', '200', '120',
                        '200', '70', '70', '120',
                        '1', '1', '1',
                        '1', '1', '1', '1',
                        '1', '1', '1', '1',
                        '1', '1', '1', '1', '1'
            ],

            fillHandle: false,
            manualColumnResize: true,
            colHeaders: ['Select', 'Charge Code', 'Charge Description', 'Charge Nature',
                         'Formula', 'RATE', 'Add/Less', 'Charge Amount',
                         'COMPANYCODE', 'DIVISIONCODE', 'YEARCODE',
                         'CHANNELCODE', 'DOCUMENTNO', 'DOCUMENTDATE', 'DOCUMENTTYPE',
                         'ASSESSABLEAMOUNT', 'SYSROWID', 'USERNAME', 'CHARGETYPE',
                         'ADDLESS', 'OPERATIONMODE', 'UNIT', 'UORCODE', 'UNITQUANTITY'
            ],

            columns: [
                { data: "SELECTED", type: 'checkbox', checkedTemplate: 'YES', uncheckedTemplate: 'NO' },
                { data: "CHARGECODE", type: 'text', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "CHARGEDESC", type: 'text', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "CHARGENATURE", type: 'text', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "FORMULA", type: 'text', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "RATE", type: 'numeric', format: '0.00', readOnly: true, renderer: noneditablecolor },
                { data: "ADDLESSSIGN", type: 'text', language: 'en', readOnly: true, renderer: noneditablecolor },
                { data: "CHARGEAMOUNT", type: 'numeric', format: '0.00', language: 'en', strict: true, allowInvalid: false },
                //----------- Hidden Columns
                { data: "COMPANYCODE", readOnly: true },
                { data: "DIVISIONCODE", readOnly: true },
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
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('YEARCODE'), document.getElementById('<%=txtYRCODE.ClientID%>').value);
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('CHANNELCODE'), document.getElementById('<%=txtCHANNELCODE.ClientID%>').value);
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('DOCUMENTNO'), document.getElementById('<%=txtDEBITCREDITNOTENO.ClientID%>').value);
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('DOCUMENTDATE'), document.getElementById('<%=mskDEBITCREDITNOTEDATE.ClientID%>').value);
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('DOCUMENTTYPE'), document.getElementById('<%=txtDOCUMENTTYPE.ClientID%>').value);
                        if ($("#dtChargeDetails").handsontable('getDataAtCell', rowIndex, returnColIndex_ChargeDetails('ASSESSABLEAMOUNT')) == null) {
                            $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('ASSESSABLEAMOUNT'), '0.00');
                        }
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('OPERATIONMODE'), document.getElementById('<%=txtOPTMODE.ClientID%>').value);
                        $("#dtChargeDetails").handsontable('setDataAtCell', rowIndex, returnColIndex_ChargeDetails('USERNAME'), document.getElementById('<%=txtUSRNAME.ClientID%>').value);

                        var ChargeGridData = document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value;
                        var TotalNetQuantity = document.getElementById('<%=txtTOTALNETQUANTITY.ClientID%>').value;
                        var TotalNetAmount = document.getElementById('<%=txtNETAMOUNT.ClientID%>').value;
                        var TotalNetWeight = document.getElementById('<%=txtTOTALNETWEIGHT.ClientID%>').value;
                        var TotalNoofPacking = document.getElementById('<%=txtTOTALNOOFPACKING.ClientID%>').value;

                        $.ajax({
                            url: 'pgSalesDebitCreditNote_GST.aspx/prcChargeDetails',
                            contentType: "application/json; charset=utf-8",
                            type: 'POST',
                            dataType: 'json',
                            data: JSON.stringify({ strChargeGridData: ChargeGridData, strTotalNetQuantity: TotalNetQuantity, strTotalNetAmount: TotalNetAmount, strTotalNetWeight: TotalNetWeight, strTotalNoofPacking: TotalNoofPacking }),
                            success: function (response) {
                                part = response.d;
                                var data = JSON.parse(part);
                                $("div").find("#dtChargeDetails").handsontable('loadData', data);
                                document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value = part;

                                //------------- For Calculating Gross Amount
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
                url: 'pgSalesDebitCreditNote_GST.aspx/GetChargeData',
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
            if (OperationMode == 'A') {
                var Documentno = document.getElementById('<%=txtREFEXCISEINVNO.ClientID%>').value;
            }
            else {
                var Documentno = document.getElementById('<%=txtDEBITCREDITNOTENO.ClientID%>').value;
            }
            var DocumentDate = document.getElementById('<%=mskDEBITCREDITNOTEDATE.ClientID%>').value;
            var varDocumentType = document.getElementById('<%=txtDOCUMENTTYPE.ClientID%>').value;

            $.ajax({
                type: "POST",
                url: "pgSalesDebitCreditNote_GST.aspx/GetChargeGridData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ strOperationMode: OperationMode, strChannelCode: ChannelCode, strDocumentno: Documentno, strDocumentDate: DocumentDate, strDocumentType: varDocumentType }),
                success: function (res) {
                    part = res.d;
                    var data = JSON.parse(part);
                    $("div").find("#dtChargeDetails").handsontable('loadData', data);
                    document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value = part
                },
                error: function (xhr, status) {
                    alert("An error occurred: " + status);
                }
            });
        }

        function fnFetchExistingChargeGridData() {
            var txtData = document.getElementById('<%=txtCHARGEGRIDDATA.ClientID%>').value;
            var data = jQuery.parseJSON(txtData);
            $("div").find("#dtChargeDetails").handsontable("loadData", data);
        }

        
    </script>
</asp:Content>