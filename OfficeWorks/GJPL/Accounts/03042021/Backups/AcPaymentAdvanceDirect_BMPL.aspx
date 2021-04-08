<%@ Page Title="" Language="vb" ValidateRequest="false" AutoEventWireup="false" MasterPageFile="~/Site1.Master" CodeBehind="AcPaymentAdvanceDirect_BMPL.aspx.vb" Inherits="swterp.AcPaymentAdvanceDirect_BMPL" %>
<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">
    <link href="../../../Lib/jquery-ui-1.11.2/jquery-ui.min.css" rel="stylesheet" />
    <link href="../../../Scripts/jquery.handsontable.full.css" rel="stylesheet" />
    <script src="../../../Scripts/modernizr-2.6.2.js"></script>
    <script src="../../../Scripts/jquery-1.11.1.min.js"></script>
    <script src="../../../Lib/jquery-ui-1.11.2/jquery-ui.min.js"></script>
    <script src="../../../Scripts/jquery.handsontable.full.js"></script>
    <script src="../../../Scripts/jquery-ui.custom.js"></script>
    <script src="../../../Scripts/globalSearch.js"></script>
    
    <script src="../../../Scripts/Calendar.js" type="text/javascript"></script>
    <link href="../../../Styles/Calendar.css" rel="stylesheet" type="text/css" />    
    <script src="../../../Scripts/jquery.maskedinput.js"></script>  

    <script src="../../../Scripts/jquery.qtip.js"></script>  
    <link href="../../../Scripts/jquery.qtip.css" rel="stylesheet" />
   
    <style> 
       .ui-autocomplete 
       { 
           font-size:12px; 
           text-align:left; 
           width:700px;    
       } 
   </style> 

     <script type="text/javascript" language="javascript">
         ////------------------------------

         $(document).ready(function () {
             $("#mskORDERDATE").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
             $("#txtSYSTEMVOUCHERDATE").mask("99/99/9999", { placeholder: "dd/mm/yyyy" });
             // $("#mskORDERDATE").mask("99/99/9999");
         });

         function fn_getCashBankType() {
             var strMenuTag1 = document.getElementById("<%= DirectCast(Master.FindControl("txtMENUTAG"), TextBox).ClientID%>").value; //PAYMENTS/RECEIPTS/CONTRA/JOURNAL  
             var strMenuTag2 = document.getElementById("<%= DirectCast(Master.FindControl("txtMENUTAG1"), TextBox).ClientID%>").value; //Memorandum/pass 
             var strMenuTag3 = document.getElementById("<%= DirectCast(Master.FindControl("txtMENUTAG2"), TextBox).ClientID%>").value; //PAYMENTS BANK          
             //alert('strMenuTag ' + strMenuTag1 +" ~ "+ strMenuTag2 +" ~ "+strMenuTag3);
             //strMenuTag PAYMENTS ENTRY ~ MEMORANDUM ~ PAYMENTS BANK - DIRECT
                          
             if (strMenuTag3 == "PAYMENTS BANK - DIRECT") {
                 document.getElementById('<%=txtVoucherType.ClientID%>').value = "PAYMENTS";
                 document.getElementById('<%=lblForHeader.ClientID%>').innerHTML = "ADVANCE PAYMENT DIRECT - BANK"; // Set Table Header label                  
                 document.getElementById('<%=txtDOCUMENTTYPE.ClientID%>').value = "ADVANCE PAYMENTS - DIRECT";
                 document.getElementById('<%=txtPAYMENTTYPE.ClientID%>').value = "PAYMENTS BANK";

                 document.getElementById('<%=lblCashBankAc.ClientID%>').innerHTML = "Bank A/c.";
             }

             if (strMenuTag3 == "PAYMENTS CASH - DIRECT") {
                 document.getElementById('<%=txtVoucherType.ClientID%>').value = "PAYMENTS";
                 document.getElementById('<%=lblForHeader.ClientID%>').innerHTML = "ADVANCE PAYMENT DIRECT - CASH"; // Set Table Header label                  
                 document.getElementById('<%=txtDOCUMENTTYPE.ClientID%>').value = "ADVANCE PAYMENTS - DIRECT";
                 document.getElementById('<%=txtPAYMENTTYPE.ClientID%>').value = "PAYMENTS CASH";

                 document.getElementById('<%=lblCashBankAc.ClientID%>').innerHTML = "Cash A/c.";
                 $('.tr8').hide();
                 $('.tr9').hide();
                 $('.tr10').hide();
             }

         }

         //----------------Press F1 on TextBox inside Grid Cell
         function searchKeyDown(obj, e) {
            var strComp = document.getElementById('<%=txtCOMPCODE.ClientID%>');
            var strDiv = document.getElementById('<%=txtDIVCODE.ClientID%>');
            var strYear = document.getElementById('<%=txtYEARCODE1.ClientID%>');
             var strPaymentType = document.getElementById('<%=txtPAYMENTTYPE.ClientID%>').value; //PAYMENTS BANK - DIRECT
            var strVoucherType = document.getElementById('<%=txtVoucherType.ClientID%>').value; //Payment/Receipt/Contra/Journal
            var strCHANNELCODE = document.getElementById('<%=txtCHANNELCODE.ClientID%>');
            var strPARTYCODE = document.getElementById('<%=txtPARTYCODE.ClientID%>');
            var strREFFTYPE = document.getElementById('<%=txtREFERENCETYPE.ClientID%>');
            var strGroupType = document.getElementById('<%=txtGROUPTYPE.ClientID%>').value; // Debtors/Creditos
            var strMainGroupCode = document.getElementById('<%=txtMAINGROUPCODE.ClientID%>').value;

            var strOPTMODE = document.getElementById('<%=txtOPTMODE.ClientID%>').value;
            var strCashBankCode = document.getElementById('<%=txtCASHBANKACCODE.ClientID%>').value;
             
             document.getElementById("<%= DirectCast(Master.FindControl("lblMasterMessage"), Label).ClientID%>").innerHTML = '';

             if (strPaymentType == "PAYMENTS CASH") {
                 strPaymentCashBankType = "CASH"
             }

             if (strPaymentType == "PAYMENTS BANK") {
                 strPaymentCashBankType = "BANK"
             }

                                   
            var unicode = e.keyCode ? e.keyCode : e.charCode
            if (unicode == 113) // F1=112, Enter=13, F2=113
            {
                if (obj.id == "mainContent_txtSYSTEMVOUCHERNO") {
                    obj.value = '';
                    //if (strOPTMODE == "M" || strOPTMODE == "D") {
                    //    var strHelp = "2020^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~YEARCODE:" + strYear.value + "~TRANSACTIONTYPE:" + 'ADVANCE' + "~^" + "^" + "System Voucher Listing^''"
                    //    InvokePop(obj.id, strHelp);
                    //}
                    if (strOPTMODE == "V" || strOPTMODE == "P" || strOPTMODE == "M" || strOPTMODE == "D") {
                        var strHelp = "2024^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~YEARCODE:" + strYear.value + "~TRANSACTIONTYPE:" + strPaymentType + "~^" + "^" + "System Voucher Listing^''"
                        InvokePop(obj.id, strHelp);
                    }
                }

                if (obj.id == "mainContent_txtPARTYNAME") {
                    if (strOPTMODE == "A") {
                        obj.value = '';
                        var strHelp = "2017^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + '%' + strDiv.value + '%' + "~^" + "^" + "Party Name Listing^''"
                        InvokePop(obj.id, strHelp);
                    }
                }

                if (obj.id == "mainContent_txtMANUALVOUCHERNO" && strREFFTYPE.value != "MANUAL") {
                    obj.value = '';
                    var strHelp = "2083^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~ACCODE:" + strPARTYCODE.value + "~^" + "^" + "Party Name Listing^''"
                    InvokePop(obj.id, strHelp);
                }
                             
                if (obj.id == "mainContent_txtVOUCHERNATURE") {
                    var strModuleName = document.getElementById('<%=txtMODULENAME.ClientID%>').value;
                    obj.value = '';
                    var strHelp = "2058^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~MODULENAME:" + strModuleName + "~^" + "^" + "Liability Nature Listing^''"
                    InvokePop(obj.id, strHelp);
                }

                if (obj.id == "mainContent_txtCASHBANKAC") {
                    obj.value = '';
                    var strHelp = "2012^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~PAYMENTTYPE:" + strPaymentCashBankType + "~^" + "^" + "Cash/Bank Ledger Listing^''"
                    InvokePop(obj.id, strHelp);
                    
                }

                if (obj.id == "mainContent_txtCHEQUEBOOKSLNO") {
                    obj.value = '';
                    var strHelp = "2026^" + "COMPANYCODE:" + strComp.value + "~DIVISIONCODE:" + strDiv.value + "~ACCODE:" + strCashBankCode + "~^" + "^" + "Book Serial^''"
                    InvokePop(obj.id, strHelp);
                }

            }
        };

        function Validate(obj, e) {
            var strOPTMODE = document.getElementById('<%=txtOPTMODE.ClientID%>').value;
             if (obj.id == "mainContent_txtSYSTEMVOUCHERNO") {
                 var strCODE = obj.value;
                 if (strCODE != null && strCODE != "") {
                     GetVoucherHeaderData();
                     FetchTDSGridBySysVoucherNo();
                     //GetVoucherDtlsData();
                 }
             }
             if (obj.id == "mainContent_txtVOUCHERNO") {
                 var strCODE = obj.value;
                 if (strCODE != null && strCODE != "") {
                 }
             }
             if (obj.id == "mainContent_txtPARTYNAME") {
                 var strCODE = obj.value;
                 if (strCODE != null && strCODE != "") {
                     if (strOPTMODE == "A") {
                         clearText("partyname");
                         setTimeout(GetPartyDtlsData(), 100);                                         
                         setTimeout(FetchTDSGridBySysVoucherNo(), 200);
                     }
                 }
             }

             if (obj.id == "mainContent_txtCASHBANKAC") {
                 var strCODE = obj.value;
                 if (strCODE != null && strCODE != "") {
                     GetCashBankLedgerData();                    
                 }
             }

             if (obj.id == "mainContent_txtCHEQUENO") {
                 var strCODE = obj.value;
                 if (obj.value != null && obj.value != "") {
                     document.getElementById('<%=txtINSTRUCTIONNO.ClientID%>').value = "";
                    document.getElementById('<%=txtINSTRUCTIONNO.ClientID%>').disabled = true;
                    document.getElementById('<%=txtCHEQUEDATE.ClientID%>').focus();
                }
                else {
                    document.getElementById('<%=txtINSTRUCTIONNO.ClientID%>').disabled = false;
                }
            }

            if (obj.id == "mainContent_txtINSTRUCTIONNO") {
                var strCODE = obj.value;
                if (obj.value != null && obj.value != "") {
                    document.getElementById('<%=txtCHEQUENO.ClientID%>').value = "";
                     document.getElementById('<%=txtCHEQUENO.ClientID%>').disabled = true;
                     document.getElementById('<%=txtCHEQUEDATE.ClientID%>').focus();
                 }
                 else {
                     document.getElementById('<%=txtCHEQUENO.ClientID%>').disabled = false;
                 }
             }

             if (obj.id == "mainContent_txtCHEQUEBOOKSLNO") {
                 var strCODE = obj.value;
                 if (strCODE != null && strCODE != "") {
                     if (strOPTMODE == "A") {
                         var strCashBankCode = document.getElementById('<%=txtCASHBANKACCODE.ClientID%>').value;
                        GetChequeNo(strCashBankCode, strCODE);
                    }
                }
            }

             if (obj.id == "mainContent_txtMANUALVOUCHERNO") {
                 var strCODE = obj.value;
                 if (strCODE != null && strCODE != "") {
                     GenerateReferenceNo();                    
                }
            }


             if (obj.id == "mainContent_txtORDERNO") {
                 var strCODE = obj.value;
                 if (strCODE != null && strCODE != "") {
                     GetOrderDtlsData();
                 }
             }


             if (obj.id == "mainContent_txtAMOUNTTOPAY") {
                 var strCODE = obj.value;
                 if (strCODE != null && strCODE != "") {
                     var varOrderno = document.getElementById('<%=txtORDERNO.ClientID%>').value;
                    if (varOrderno.length > 0) {
                        var isTDSApplicable = document.getElementById('<%=txtISTDSAPPLICABLE.ClientID%>').value;
                        if (isTDSApplicable == "Y") {                            
                            document.getElementById('<%=txtTDSONAMOUNT.ClientID%>').readOnly = false;
                            document.getElementById('<%=txtTDSONAMOUNT.ClientID%>').focus();
                        } else {
                            document.getElementById('<%=txtTDSONAMOUNT.ClientID%>').value = '';
                            document.getElementById('<%=txtTDSONAMOUNT.ClientID%>').readOnly = true;
                            document.getElementById('<%=txtCASHBANKAC.ClientID%>').focus();
                        }
                        document.getElementById('<%=txtDRCR.ClientID%>').value = "D";
                        totalLiability();
                    }
                    else {
                        alert('Reference No can not be blank !!');
                        document.getElementById('<%=txtORDERNO.ClientID%>').focus();
                        document.getElementById('<%=txtORDERNO.ClientID%>').value = '';
                    }
                }
            }

            if (obj.id == "mainContent_txtTDSONAMOUNT") {
                var strTDSOn = Number(obj.value);
                var amtToPay = Number(document.getElementById('<%=txtAMOUNTTOPAY.ClientID%>').value);
                if (strTDSOn < 0) {
                    alert('TDS On Can not be less than 0');
                    document.getElementById('<%=txtTDSONAMOUNT.ClientID%>').value = '';
                    //document.getElementById('<%=txtTDSONAMOUNT.ClientID%>').value = amtToPay;
                }
            }

         };

         //-------------------------------AutoComplete Narration--------------------------------------
         $(function () {
             $('#<%=txtNARRATION.ClientID%>').autocomplete({
                 minLength: 2,
                 source: function (request, response) {
                     $.ajax({
                         url: "AcPaymentAdvanceDirect_BMPL.aspx/GetCompletionList",
                         data: "{ 'prefixText':'" + request.term + "','listCnt':'5'}",
                         dataType: "json",
                         type: "POST",
                         contentType: "application/json; charset=utf-8",
                         success: function (data) {
                             response($.map(data.d, function (item) {
                                 return { value: item }
                             }))
                         }
                         //,
                         //error: function (XMLHttpRequest, textStatus, errorThrown) {
                         //    alert(textStatus);
                         //}
                     });
                 },
                 position: { collision: "flip" }
             });
         });
         //-----------------------------------------------------


         function fn_EnableDisableFields() {
             var varAutomanual = document.getElementById('<%=txtAUTOMANUALMARK.ClientID%>').value;

             if (varAutomanual.indexOf("AUTO") != -1) {

                 document.getElementById('<%=txtPARTYNAME.ClientID%>').readOnly = "readonly";
                 document.getElementById('<%=txtORDERNO.ClientID%>').readOnly = "readonly";
                 document.getElementById('<%=mskORDERDATE.ClientID%>').readOnly = "readonly";
                 document.getElementById('<%=txtAMOUNTTOPAY.ClientID%>').readOnly = "readonly";
                 document.getElementById('<%=RbtManualRef.ClientID%>').disabled = true;

                 //document.getElementById('<%=txtORDERNO.ClientID%>').setattribute("class", "readonly");

             }
             else {
                 // document.getElementById('<%=RbtSysRef.ClientID%>').disabled = true;
                 //document.getElementById('<%=RbtManualRef.ClientID%>').disabled = false;
             }
             document.getElementById('<%=txtVOUCHERNATURE.ClientID%>').focus();
         }


         function checkRadioBtn() {
             var strRbtSysRef = document.getElementById('<%=RbtSysRef.ClientID%>');
             var strRbtManualRef = document.getElementById('<%=RbtManualRef.ClientID%>');
             if (strRbtSysRef.checked == true) {
                 document.getElementById('<%=txtREFERENCETYPE.ClientID%>').value = "ORDER";
                 clearText("radioBtn");
                 document.getElementById('<%=txtMANUALVOUCHERNO.ClientID%>').readOnly = true;
             }
             if (strRbtManualRef.checked == true) {
                 document.getElementById('<%=txtREFERENCETYPE.ClientID%>').value = "MANUAL";
                 clearText("radioBtn");
                 document.getElementById('<%=txtMANUALVOUCHERNO.ClientID%>').readOnly = false;
             }
         }



         function clearText(strTag) {
             if (strTag == "radioBtn") {
                 document.getElementById('<%=txtMANUALVOUCHERNO.ClientID%>').value = "";
                 document.getElementById('<%=txtORDERNO.ClientID%>').value = "";
                 document.getElementById('<%=mskORDERDATE.ClientID%>').value = "";
                 document.getElementById('<%=txtAMOUNTTOPAY.ClientID%>').value = "";
                 document.getElementById('<%=txtTDSONAMOUNT.ClientID%>').value = "";
                 document.getElementById('<%=txtMODULE.ClientID%>').value = "";
                 document.getElementById('<%=txtDRCR.ClientID%>').value = "";
             }
             if (strTag == "partyname") {
                 document.getElementById('<%=txtMANUALVOUCHERNO.ClientID%>').value = "";
                 document.getElementById('<%=txtORDERNO.ClientID%>').value = "";
                 document.getElementById('<%=mskORDERDATE.ClientID%>').value = "";
                 document.getElementById('<%=txtAMOUNTTOPAY.ClientID%>').value = "";
                 document.getElementById('<%=txtTDSONAMOUNT.ClientID%>').value = "";
                 document.getElementById('<%=txtMODULE.ClientID%>').value = "";
             }

         }
         //----------------------------------------
    </script> 
        <div align="center">
             <div id="popupdiv" title="Details Information" class="popstyle">
                <label id="search">Search : </label>
                <input id="SearchText" type="text" style='width: 600px;' />
                <div id='searchPanel' style='width: auto; height: 260px; overflow: scroll'></div>
            </div>
            <table cellpadding="1" cellspacing="0" class="box_shade" style="width:60%">
            <tr class="box_heading">
                <td colspan="2" align="center">
                    <asp:Label ID="lblForHeader" runat="server" Text=""></asp:Label>
                    <asp:TextBox ID="txtCOMPCODE" runat="server" style="display:none"></asp:TextBox>
                    <asp:TextBox ID="txtDIVCODE" runat="server" style="display:none"></asp:TextBox>
                     <asp:TextBox ID="txtDIVISIONNAME" runat="server" style="display:none"></asp:TextBox>
                     <asp:TextBox ID="txtYEARCODE1" runat="server" style="display:none"></asp:TextBox>
                    <asp:TextBox ID ="txtOPTMODE" runat="server" style="display:none"></asp:TextBox>
                    <asp:TextBox ID="txtUSRNAME" runat="server" style="display:none"></asp:TextBox>
                    <asp:TextBox ID="txtSYSROWID" runat="server" style="display:none"></asp:TextBox>                        
                    <asp:TextBox ID="txtTDSGRIDDATA" runat="server"  Width="300px" style="display:none" ></asp:TextBox>    
                    <asp:TextBox ID="txtACLIABILITYDETAILS" runat="server"  Width="300px" style="display:none" ></asp:TextBox>    
                    <asp:TextBox ID="txtSTARTDATE" runat="server"  Width="100px" style="display:none" ></asp:TextBox>   
                    <asp:TextBox ID="txtENDDATE" runat="server"  Width="100px" style="display:none" ></asp:TextBox>  
                    <asp:TextBox ID="txtDIVISIONCODEFOR" runat="server"  Width="100px" style="display:none" ></asp:TextBox> 
                    
                </td>
            </tr>
                <tr>
              <td colspan="2" style="height: 12px; text-align:center"><asp:Label ID="lblErrorMsg" runat="server" BackColor="#FFFFCC" Font-Bold="True" Font-Size="12px" ForeColor="#CC0000"></asp:Label>
               </td>
              </tr>
              <tr>
                <td colspan="2">                    
                <asp:Panel ID="Panel1" runat="server" BorderStyle="Solid" style="width:99%" BorderWidth="2px"> 
                   <table style="width:99%" cellpadding="2" cellspacing="2" >             
                      <tr class="tr1">
                        <td>
                              <asp:Label ID="lblSystemVoucherNo" runat="server" Text="Sys. Voucher No." CssClass="labelcaption"></asp:Label>
                        </td>
                        <td>  
                            <asp:TextBox ID="txtSYSTEMVOUCHERNO" runat="server" onblur="Validate(this,event);" onkeydown="searchKeyDown(this,event);" ToolTip="Press F2 to select" Width="200px" CssClass="readonly"></asp:TextBox>
                          </td>
                          <td>
                          <asp:Label ID="lblSystemVoucherdate" runat="server" Text="Date"  CssClass="labelcaption"></asp:Label>
                          </td>
                        <td><asp:TextBox ID="txtSYSTEMVOUCHERDATE" runat="server" Width="80px" ClientIDMode="Static" CssClass="readonly"></asp:TextBox>
                        </td>
                          <td>
                              <asp:Label ID="lblVoucherNo" runat="server" CssClass="labelcaption" Text="Voucher No."></asp:Label>
                          </td>
                          <td>
                              <asp:TextBox ID="txtVOUCHERNO" runat="server" CssClass="readonly" onblur="Validate(this,event);" onkeydown="searchKeyDown(this,event);" Width="200px"></asp:TextBox>
                          </td>
                          <td>
                              <asp:Label ID="lblVoucherDate" runat="server" CssClass="labelcaption" Text="Date"></asp:Label>
                          </td>
                          <td>
                              <asp:TextBox ID="txtVOUCHERDATE" runat="server" CssClass="readonly" Width="80px"></asp:TextBox>
                          </td>
                      </tr>                     

                       <tr>
                           <td><asp:Label ID="lblParty" runat="server" Text="Party"  CssClass="labelcaption"></asp:Label></td>
                           <td colspan="7">
                               <asp:TextBox ID="txtPARTYNAME" runat="server" AutoPostBack="true" onblur="Validate(this,event);" 
                                    onkeydown="searchKeyDown(this,event);" ToolTip="Press F2 to select" Width="500px" TabIndex="1"></asp:TextBox>
                               <asp:TextBox ID="txtPARTYCODE" runat="server" style="display:none" Width="50px"></asp:TextBox>
                               <asp:TextBox ID="txtACCODE" runat="server" style="display:none" Width="50px"></asp:TextBox>
                               <asp:TextBox ID="txtISTDSAPPLICABLE" runat="server" style="display:none" Width="50px"></asp:TextBox>
                               <asp:TextBox ID="txtMAINGROUPCODE" runat="server" style="display:none" Width="50px"></asp:TextBox>
                           </td>
                       </tr>
                       <tr>
                           <td>
                               <asp:Label ID="lblNatureType" runat="server" CssClass="labelcaption" Text="Voucher Nature"></asp:Label>
                           </td>
                           <td colspan="3">
                               <asp:TextBox ID="txtVOUCHERNATURE" runat="server" onblur="Validate(this,event);" onkeydown="searchKeyDown(this,event);" ToolTip="Press F2 to select" Width="300px" TabIndex="2"></asp:TextBox>
                           </td>
                           <td>
                               
                           </td>
                           <td colspan="3">
                               
                           </td>
                       </tr>
                       <tr>
                           <td><asp:Label ID="lblReference" runat="server" Text="Reference"  CssClass="labelcaption"></asp:Label></td>
                           <td colspan="3">
                               <asp:RadioButton ID="RbtManualRef" runat="server" GroupName="grpReference" onchange="checkRadioBtn()" Text="Manual Reference"  />
                               &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                               <asp:RadioButton ID="RbtSysRef" runat="server" GroupName="grpReference" Text="Against System Order" onchange="checkRadioBtn()"  />                              
                               
                               <asp:TextBox ID="txtREFERENCETYPE" runat="server" style="display:none" Width="50px"></asp:TextBox>
                           </td>
                           <td><asp:Label ID="lblManualOrderNo" runat="server" Text="Order No"  CssClass="labelcaption"></asp:Label></td>
                           <td><asp:TextBox ID="txtMANUALVOUCHERNO" runat="server"  Width="200px" onblur="Validate(this,event);" 
                                    onkeydown="searchKeyDown(this,event);" ToolTip="Press F2 to select" ></asp:TextBox></td>
                           <td>&nbsp;</td>
                           <td>&nbsp;</td>
                       </tr>

                       <tr>
                           <td><asp:Label ID="lblRefNo" runat="server" Text="Reference No."  CssClass="labelcaption"></asp:Label></td>
                           <td><asp:TextBox ID="txtORDERNO" runat="server"  Width="200px" onblur="Validate(this,event);"></asp:TextBox></td>
                           <td><asp:Label ID="lblRefDate" runat="server" Text="Dated"  CssClass="labelcaption"></asp:Label></td>
                           <td><asp:TextBox ID="mskORDERDATE" runat="server"  Width="100px" ClientIDMode="Static" ></asp:TextBox></td>
                           <td>
                               <asp:Label ID="lblAmtToPay" runat="server" CssClass="labelcaption" Text="Amt. to Pay"></asp:Label>
                           </td>
                           <td>
                               <asp:TextBox ID="txtAMOUNTTOPAY" runat="server" onblur="Validate(this,event);" Width="100px" style="text-align:right" ></asp:TextBox>
                               &nbsp;&nbsp;&nbsp;
                               <asp:Label ID="lblTDSOn" runat="server" CssClass="labelcaption" Text="TDS On" style="display:none"></asp:Label>
                           </td>
                           <td colspan="2">
                               <asp:TextBox ID="txtTDSONAMOUNT" runat="server" onblur="Validate(this,event);" style="text-align:right ;display:none" Width="100px"></asp:TextBox>
                               <asp:TextBox ID="txtDRCR" runat="server" style="display:none" Width="30px" ></asp:TextBox>
                           </td>
                       </tr>
                                                         
                      <tr class="tr4">
                      <td colspan="8">       

                      <div id="divTDS">   <%---------------TDS Details-- --%>       
                        <table cellpadding="0" cellspacing="0" >    
                            <tr>
                                <td>                                
                                    <asp:Panel ID="PanelTDS" runat="server">
                                        <div id="gridTDS" style="overflow: auto; border: 1px solid olive; width: 900px; height: 150px ;"> </div>                                         
                                    </asp:Panel>                                    
                                </td>
                            </tr>                            
                        </table>    
                      </div>                                                
                       </td>
                       
                      </tr>   
                       <tr>               
                         <td> </td>
                         <td><asp:TextBox ID="txtTotAdjustingAmt" runat="server"  Width="100px" style="display:none" ></asp:TextBox> </td>
                         <td>&nbsp;</td>
                         <td>
                             <asp:Label ID="lblTotTDSON" runat="server" CssClass="labelcaption" Text="Total TDS On"></asp:Label>
                           </td>
                         <td>
                             <asp:TextBox ID="txtTOTALTDSON" runat="server" CssClass="readonly" Width="100px" style="text-align:right"></asp:TextBox>
                           </td>
                         <td style="text-align: right">
                             <asp:Label ID="lblNetTDSAmt" runat="server" CssClass="labelcaption" Text="Net TDS Amount"></asp:Label>
                           </td>
                           <td colspan="2" style="text-align: left">
                               <asp:TextBox ID="txtTOTALTDSAMOUNT" runat="server" CssClass="readonly" Width="100px" style="text-align:right"></asp:TextBox>
                           </td>
                          
                      </tr> 
                       
                       <tr>
                           <td colspan="8">
                               <table cellpadding="1" cellspacing="1" style="width: 100%">
                                   <tr  class="tr7">
                                       <td style="width:90px">
                                           <asp:Label ID="lblCashBankAc" runat="server" CssClass="labelcaption" Text=""></asp:Label>
                                       </td>
                                       <td colspan="5">
                                           <asp:TextBox ID="txtCASHBANKAC" runat="server" onblur="Validate(this,event);" onkeydown="searchKeyDown(this,event);" ToolTip="Press F2 to select" Width="500px"></asp:TextBox>
                                           <asp:TextBox ID="txtCASHBANKACCODE" runat="server" style="display:none" Width="50px"></asp:TextBox>
                                            <asp:TextBox ID="txtCASHBANKGROUPTYPE" runat="server" style="display:none" Width="50px"></asp:TextBox> 
                                       </td>
                                       <td>
                                           <asp:Label ID="lblAmount" runat="server" CssClass="labelcaption" Text="Payable Amount"></asp:Label>
                                       </td>
                                       <td>
                                           <asp:TextBox ID="txtAMOUNT" runat="server" CssClass="readonly" Width="100px" style="text-align:right"></asp:TextBox>
                                       </td>
                                   </tr>
                                   <tr class="tr8">
                                       <td>
                                           <asp:Label ID="lblBookSlNo" runat="server" CssClass="labelcaption" Text="Book Sl. No."></asp:Label>
                                       </td>
                                       <td>
                                           <asp:TextBox ID="txtCHEQUEBOOKSLNO" runat="server" onblur="Validate(this,event);" onkeydown="searchKeyDown(this,event);" ToolTip="Press F2 to select" Width="200px" CssClass="readonly" ></asp:TextBox>
                                       </td>
                                       <td>
                                           <asp:Label ID="lblChequeNo" runat="server" CssClass="labelcaption" Text="Cheque No"></asp:Label>
                                       </td>
                                       <td>
                                           <asp:TextBox ID="txtCHEQUENO" runat="server" onblur="Validate(this,event);" Width="100px" ></asp:TextBox>
                                       </td>
                                       <td>
                                           <asp:Label ID="lblInstructionNo" runat="server" CssClass="labelcaption" Text="Instruction No"></asp:Label>
                                       </td>
                                       <td>
                                           <asp:TextBox ID="txtINSTRUCTIONNO" runat="server" onblur="Validate(this,event);" Width="100px"></asp:TextBox>
                                       </td>
                                       <td>
                                           <asp:Label ID="lblChequeDate" runat="server" CssClass="labelcaption" Text="Cheque/Inst. Date"></asp:Label>
                                       </td>
                                       <td>
                                           <asp:TextBox ID="txtCHEQUEDATE" runat="server" ClientIDMode="Static" Width="100px" ></asp:TextBox>
                                       </td>
                                   </tr>
                                   <tr class="tr9">
                                       <td>
                                           <asp:Label ID="lblDrawnon" runat="server" CssClass="labelcaption" Text="Drawn On"></asp:Label>
                                       </td>
                                       <td colspan="7">
                                           <asp:TextBox ID="txtCHEQUEDRAWNON" runat="server" CssClass="readonly" Width="500px" ></asp:TextBox>
                                       </td>
                                   </tr>
                                   <tr class="tr10">
                                       <td><asp:Label ID="lblPaidTo" runat="server" CssClass="labelcaption" Text="Payee Name"></asp:Label></td>
                                       <td colspan="7">
                                           <asp:TextBox ID="txtPAIDTO" runat="server" Width="500px" ></asp:TextBox>
                                       </td>
                                   </tr>                                   
                               </table>

                           </td>
                       </tr>
                                    
                     
                       <tr>
                           <td>
                               <asp:Label ID="lblNarration" runat="server" CssClass="labelcaption" Text="Narration"></asp:Label>
                           </td>
                           <td colspan="7">
                               <asp:TextBox ID="txtNARRATION" runat="server"  Width="650px"></asp:TextBox>
                           </td>
                       </tr>
                       <tr>
                           <td>
                               <asp:TextBox ID="txtVoucherType" runat="server" style="display:none" Width="100px"></asp:TextBox>
                               <asp:TextBox ID="txtPAYMENTTYPE" runat="server" style="display:none" Width="100px"></asp:TextBox>
                               <asp:TextBox ID="txtAllDiv" runat="server" style="display:none" Width="100px"></asp:TextBox>
                               <asp:TextBox ID="txtBillType" runat="server" style="display:none" Width="100px"></asp:TextBox>                               
                           </td>
                           <td>
                               <asp:TextBox ID="txtAUTOMANUALMARK" runat="server" style="display:none" Width="100px"></asp:TextBox>
                               <asp:TextBox ID="txtMODULENAME" runat="server" style="display:none" Width="100px"></asp:TextBox>
                               <asp:TextBox ID="txtDOCUMENTTYPE" runat="server" style="display:none" Width="100px"></asp:TextBox>
                           </td>
                           <td></td>
                           <td>
                               <asp:TextBox ID="txtCHANNELCODE" runat="server" style="display:none" Width="50px"></asp:TextBox>
                           </td>
                           <td>
                               <asp:TextBox ID="txtGROUPTYPE" runat="server" style="display:none" Width="50px"></asp:TextBox>
                           </td>
                           <td>
                               <asp:TextBox ID="txtACTYPE" runat="server" style="display:none" Width="50px"></asp:TextBox>
                               <asp:TextBox ID="txtMODULE" runat="server" style="display:none" Width="50px"></asp:TextBox>
                           </td>
                           <td>&nbsp;</td>
                           <td>&nbsp;</td>
                       </tr>

                      </table>
                     </asp:Panel>
                </td>                              
              </tr>              
            </table>  
        </div>

    <script type="text/javascript">

        function GetPartyDtlsData() {
            var varPartyName = document.getElementById('<%=txtPARTYNAME.ClientID%>').value;
            $.ajax(
            {
                type: "POST",
                url: "AcPaymentAdvanceDirect_BMPL.aspx/fetchPartyDtls",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                data: JSON.stringify({ strPartyName: varPartyName }),
                success: function (response) {
                    var str1 = (response.d);
                    var strDataArr = new Array();
                    if (str1 != '' && typeof str1 != null && str1 != 'undefined') {
                        strDataArr = str1.split("~");
                        // PARTYCODE || '~' || ACCODE  || '~' || ACTYPE|| '~' || GROUPTYPE|| '~' || MODULENAME||'~'||B.MAINGROUPCODE
                        document.getElementById('<%=txtPARTYCODE.ClientID%>').value = strDataArr[0];
                        document.getElementById('<%=txtACCODE.ClientID%>').value = strDataArr[1];
                        document.getElementById('<%=txtACTYPE.ClientID%>').value = strDataArr[2];
                        document.getElementById('<%=txtGROUPTYPE.ClientID%>').value = strDataArr[3];
                        document.getElementById('<%=txtISTDSAPPLICABLE.ClientID%>').value = strDataArr[4];
                        document.getElementById('<%=txtMODULENAME.ClientID%>').value = strDataArr[5];
                        document.getElementById('<%=txtMAINGROUPCODE.ClientID%>').value = strDataArr[6];                        
                    }
                    if (document.getElementById('<%=txtPAIDTO.ClientID%>').value.length <= 0) {
                        document.getElementById('<%=txtPAIDTO.ClientID%>').value = varPartyName;
                    }

                    fn_EnableDisableFields();

                },
                error: function (xhr, status) {
                    alert("An error occurred: GetPartyDtlsData " + status);
                }
            });
        }

        function GenerateReferenceNo() {
            var varManualVoucherNo = document.getElementById('<%=txtMANUALVOUCHERNO.ClientID%>').value;
            var varReffType = document.getElementById('<%=txtREFERENCETYPE.ClientID%>').value;
            var varSysVoucherNo = document.getElementById('<%=txtSYSTEMVOUCHERNO.ClientID%>').value;
            var varAccode = document.getElementById('<%=txtACCODE.ClientID%>').value;

            $.ajax(
            {
                type: "POST",
                url: "AcPaymentAdvanceDirect_BMPL.aspx/getReferenceNo",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                asycn: false,
                data: JSON.stringify({ strManualVoucherNo: varManualVoucherNo, strrReffType: varReffType, strSysVoucherNo: varSysVoucherNo, strAccode: varAccode }),
                success: function (response) {
                    var str1 = (response.d);
                    var strDataArr = new Array();
                    if (str1 != '' && str1 != null && str1 != 'undefined') {
                        document.getElementById('<%=txtORDERNO.ClientID%>').value = varManualVoucherNo + "/" + (Number(str1) + 1);
            }
                },
                error: function (xhr, status) {
                    alert("An error occurred: GetOrderDtlsData " + status);
                }
            });
        }

        function GetOrderDtlsData() {
            var varOrderNo = document.getElementById('<%=txtMANUALVOUCHERNO.ClientID%>').value;
            var varReffType = document.getElementById('<%=txtREFERENCETYPE.ClientID%>').value;
            var varSysVoucherNo = document.getElementById('<%=txtSYSTEMVOUCHERNO.ClientID%>').value;
            var varAccode = document.getElementById('<%=txtACCODE.ClientID%>').value;

            $.ajax(
            {
                type: "POST",
                url: "AcPaymentAdvanceDirect_BMPL.aspx/fetchOrderDtls",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                asycn: false,
                data: JSON.stringify({ strOrderNo: varOrderNo, strrReffType: varReffType, strSysVoucherNo: varSysVoucherNo, strAccode: varAccode }),
                success: function (response) {
                    var str1 = (response.d);
                    var strDataArr = new Array();
                    if (str1 != '' && str1 != null && str1 != 'undefined') {
                        if (str1 == "Reference No. already exist!!") {
                            alert(str1);
                            document.getElementById('<%=txtORDERNO.ClientID%>').value = '';
                            document.getElementById('<%=txtORDERNO.ClientID%>').focus();
                        }
                        else {
                            strDataArr = str1.split("~");
                            // ORDERDATE || '~' || SUM(A.GRADEAMOUNT) || '~' || MODULE                        
                            document.getElementById('<%=mskORDERDATE.ClientID%>').value = strDataArr[0];
                        document.getElementById('<%=txtAMOUNTTOPAY.ClientID%>').value = Number(strDataArr[1]).toFixed(2);
                            document.getElementById('<%=txtTDSONAMOUNT.ClientID%>').value = Number(strDataArr[1]).toFixed(2);
                            document.getElementById('<%=txtMODULE.ClientID%>').value = strDataArr[2];
                            document.getElementById('<%=txtDRCR.ClientID%>').value = "D";
                        }
                    }
                    else {
                        if (str1 == "Reference No. already exist!!") {
                            alert(str1);
                            document.getElementById('<%=txtORDERNO.ClientID%>').value = '';
                            document.getElementById('<%=txtORDERNO.ClientID%>').focus();
                        }
                    }
                },
                error: function (xhr, status) {
                    alert("An error occurred: GetOrderDtlsData " + status);
                }
            });
        }
              
        function GetCashBankLedgerData() {
            var varAcHead = document.getElementById('<%=txtCASHBANKAC.ClientID%>').value;
            $.ajax(
            {
                type: "POST",
                url: "AcPaymentAdvanceDirect_BMPL.aspx/fetchLiabilityDtls",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ strAcHead: varAcHead }),
                success: function (response) {
                    var str1 = (response.d);
                    var strDataArr = new Array();
                    if (str1 != '') {
                        strDataArr = str1.split("~");
                        document.getElementById('<%=txtCASHBANKACCODE.ClientID%>').value = strDataArr[0];
                        document.getElementById('<%=txtCASHBANKGROUPTYPE.ClientID%>').value = strDataArr[1];
                    }
                    document.getElementById('<%=txtCHEQUEDRAWNON.ClientID%>').value = document.getElementById('<%=txtCASHBANKAC.ClientID%>').value;                    
                },
                error: function (xhr, status) {
                    alert("An error occurred: " + status);
                }
            });
        }

        //---------------------------------------------------------------------
        function GetChequeNo(varCashBankCode, varBookSlNo) {
            var strCompCode = document.getElementById('<%=txtCOMPCODE.ClientID%>').value;
             $.ajax(
             {
                 type: "POST",
                 url: "AcPaymentAdvanceDirect_BMPL.aspx/fetchChequeNo",
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 data: JSON.stringify({ strCashBankCode: varCashBankCode, strBookSlNo: varBookSlNo }),
                 success: function (response) {
                     var str1 = (response.d);
                     var strDataArr = new Array();
                     var strInstrumentType = "";
                     var strLogic = "";
                     var strColumnToStore = "";
                     if (str1 != '') {
                         strDataArr = str1.split("~");
                         strLogic = strDataArr[0];
                         strInstrumentType = strDataArr[2];
                         strColumnToStore = strDataArr[3];
                         //lv_return_value || '~' || to_char(trunc(sysdate), 'dd/mm/yyyy') || '~' || lv_instrumenttype || '~' || lv_column_to_store
                         //220376~19/05/2016~CHEQUE LEAF - SINGLE~CHEQUENO


                         if (strLogic == "MANUAL") {
                             if (strColumnToStore == "CHEQUENO") {
                                 document.getElementById('<%=txtINSTRUCTIONNO.ClientID%>').value = "";
                                 document.getElementById('<%=txtCHEQUENO.ClientID%>').readOnly = false;
                                 document.getElementById('<%=txtCHEQUENO.ClientID%>').value = "";
                             } else {
                                 document.getElementById('<%=txtCHEQUENO.ClientID%>').value = "";
                                 document.getElementById('<%=txtINSTRUCTIONNO.ClientID%>').readOnly = false;
                                 document.getElementById('<%=txtINSTRUCTIONNO.ClientID%>').value = "";
                             }
                         }
                         else {
                             if (strColumnToStore == "CHEQUENO") {
                                 document.getElementById('<%=txtINSTRUCTIONNO.ClientID%>').value = "";
                                 document.getElementById('<%=txtCHEQUENO.ClientID%>').readOnly = true;
                                 document.getElementById('<%=txtCHEQUENO.ClientID%>').value = strLogic;
                             } else {
                                 document.getElementById('<%=txtCHEQUENO.ClientID%>').value = "";
                                 document.getElementById('<%=txtINSTRUCTIONNO.ClientID%>').readOnly = true;
                                 document.getElementById('<%=txtINSTRUCTIONNO.ClientID%>').value = strLogic;
                             }
                         }
                         document.getElementById('<%=txtCHEQUEDATE.ClientID%>').value = strDataArr[1];
                     }
                 },
                 error: function (xhr, status) {
                     alert("An error occurred: " + status);
                 }
             });
         }
         //---------------------------------------------------------------------

         function GetVoucherHeaderData() {
             var varSysVoucherNo = document.getElementById('<%=txtSYSTEMVOUCHERNO.ClientID%>').value;
            $.ajax(
            {
                type: "POST",
                url: "AcPaymentAdvanceDirect_BMPL.aspx/fetchVoucherHeaderData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ strSysVoucherNo: varSysVoucherNo }),
                success: function (response) {
                    var str1 = (response.d);
                    var strDataArr = new Array();
                    if (str1 != '') {
                        strDataArr = str1.split("~");
                        //TO_CHAR(A.SYSTEMVOUCHERDATE, 'DD/MM/YYYY') || '~' || A.VOUCHERNO || '~' || TO_CHAR(A.VOUCHERDATE, 'DD/MM/YYYY')
                        //|| '~' ||A.ACCODE|| '~' ||B.PARTYNAME|| '~' ||B.PARTYCODE|| '~' || B.ACTYPE|| '~' ||B.GROUPTYPE|| '~' ||A.AMOUNT|| '~' ||A.DRCR 
                        //|| '~' || A.REFERENCETYPE || '~' || A.REFBILLNO || '~' || TO_CHAR(A.REFBILLDATE, 'DD/MM/YYYY') || '~' || A.TDSONAMOUNT || '~' || A.TOTALTDSAMOUNT || '~' || A.NARRATION
                        //|| '~' ||A.AUTOMANUALMARK|| '~' ||A.DOCUMENTTYPE|| '~' ||MODULENAME|| '~' ||A.SYSROWID|| '~' ||B.ISTDSAPPLICABLE|| '~' ||A.VOUCHERNATURE|| '~' ||A.MANUALVOUCHERNO
                        //|| '~' ||A.CASHBANKACCODE|| '~' ||C.ACHEAD|| '~' ||NVL(A.CHEQUENO,'')|| '~' ||NVL(A.INSTRUCTIONNO,'')|| '~' ||A.CHEQUEBOOKSLNO|| '~' ||TO_CHAR(A.CHEQUEDATE,'DD/MM/YYYY')
                        //|| '~' ||A.CHEQUEDRAWNON|| '~' ||A.PARTY|| '~' ||(NVL(A.AMOUNT,0)+NVL(A.TOTALTDSAMOUNT,0))
                        document.getElementById('<%=txtSYSTEMVOUCHERDATE.ClientID%>').value = strDataArr[0];
                        document.getElementById('<%=txtVOUCHERNO.ClientID%>').value = strDataArr[1];
                        document.getElementById('<%=txtVOUCHERDATE.ClientID%>').value = strDataArr[2];

                        document.getElementById('<%=txtACCODE.ClientID%>').value = strDataArr[3];
                        document.getElementById('<%=txtPARTYNAME.ClientID%>').value = strDataArr[4];
                        document.getElementById('<%=txtPARTYCODE.ClientID%>').value = strDataArr[5];
                        document.getElementById('<%=txtACTYPE.ClientID%>').value = strDataArr[6];
                        document.getElementById('<%=txtGROUPTYPE.ClientID%>').value = strDataArr[7];
                        
                        document.getElementById('<%=txtAMOUNT.ClientID%>').value = Number(strDataArr[8]).toFixed(2);                        
                        document.getElementById('<%=txtDRCR.ClientID%>').value = strDataArr[9];

                        document.getElementById('<%=txtREFERENCETYPE.ClientID%>').value = strDataArr[10];
                        document.getElementById('<%=txtORDERNO.ClientID%>').value = strDataArr[11];
                        document.getElementById('<%=mskORDERDATE.ClientID%>').value = strDataArr[12];
                        document.getElementById('<%=txtTOTALTDSON.ClientID%>').value = Number(strDataArr[13]).toFixed(2);
                        document.getElementById('<%=txtTOTALTDSAMOUNT.ClientID%>').value = strDataArr[14];
                        document.getElementById('<%=txtNARRATION.ClientID%>').value = strDataArr[15];

                        document.getElementById('<%=txtAUTOMANUALMARK.ClientID%>').value = strDataArr[16];
                        document.getElementById('<%=txtDOCUMENTTYPE.ClientID%>').value = strDataArr[17];
                        document.getElementById('<%=txtMODULENAME.ClientID%>').value = strDataArr[18];
                        document.getElementById('<%=txtSYSROWID.ClientID%>').value = strDataArr[19];
                        document.getElementById('<%=txtISTDSAPPLICABLE.ClientID%>').value = strDataArr[20];
                        document.getElementById('<%=txtVOUCHERNATURE.ClientID%>').value = strDataArr[21];
                        //document.getElementById('<%=txtMANUALVOUCHERNO.ClientID%>').value = strDataArr[22];

                        if (document.getElementById('<%=txtREFERENCETYPE.ClientID%>').value == "MANUAL") {
                            document.getElementById('<%=RbtManualRef.ClientID%>').checked = true;
                        } else {
                            document.getElementById('<%=RbtSysRef.ClientID%>').checked = true;
                        }

                        document.getElementById('<%=txtCASHBANKACCODE.ClientID%>').value = strDataArr[23];
                        document.getElementById('<%=txtCASHBANKAC.ClientID%>').value = strDataArr[24];
                        document.getElementById('<%=txtCHEQUENO.ClientID%>').value = strDataArr[25];
                        document.getElementById('<%=txtINSTRUCTIONNO.ClientID%>').value = strDataArr[26];
                        document.getElementById('<%=txtCHEQUEBOOKSLNO.ClientID%>').value = strDataArr[27];
                        document.getElementById('<%=txtCHEQUEDATE.ClientID%>').value = strDataArr[28];
                        document.getElementById('<%=txtCHEQUEDRAWNON.ClientID%>').value = strDataArr[29];
                        document.getElementById('<%=txtPAIDTO.ClientID%>').value = strDataArr[30];
                        document.getElementById('<%=txtAMOUNTTOPAY.ClientID%>').value = Number(strDataArr[31]).toFixed(2);

                        document.getElementById('<%=txtNARRATION.ClientID%>').focus();
                    }

                },
                error: function (xhr, status) {
                    alert("An error occurred:GetVoucherHeaderData " + status);
                }
            });
        }

  
        /////////////////////////////////////////////For TDS Grid////////////////
        $(document).ready(function () {
            //alert(document.getElementById('<%=txtAllDiv.ClientID%>').value);
            hideVoucherGridColumn();
        });

        function hideVoucherGridColumn() {
            //// alert('hideVoucherGridColumn');      
            //for (var i = 7; i <= 37; i++) {
            //    $('#gridVoucherDetails td:nth-child(' + i + '),th:nth-child(' + i + ')').hide();
            //    $('#gridVoucherDetails td:nth-child(' + i + ') > div').remove();
            //}
        }
        /////////////////////////////////////////////For TDS Grid////////////////   

        function returnColIndexTDS(searchStr) {
            var DataFields =
            [
                "SELECTED",
                "TDSNATURE",
                "TDSPERCENTAGE",
                "YEARLYLIMIT",
                "SINGLETRANSACTIONLIMIT",
                "ALWAYSDEDUCT",
                "TDSDEDUCTEDON",
                "TDSAMT",
                "NETAMT",
                "SURCHARGEPERCENTAGE",
                "SERVICETAXAMOUNT",
                "EDUCATIONCESS",
                "EDUCESSAMT",
                "SREDUCATIONCESS",
                "SREEDUCESSAMT",
                "NETTDSAMT",
                "DRCR",
                "BILLNO",
                "BILLDATE",
                "BILLAMOUNT",
                "CERTIFICATENO",
                "CERTIFICATEDATE",
                "TRANSACTIONTYPE",
                "MANUALAUTO",
                "TDSCODE",
                "ACCODE",
                "PARTYCODE",
                "USERNAME",
                "COMPANYCODE",
                "DIVISIONCODE",
                "YEARCODE",
                "OPERATIONMODE",
                "SYSTEMVOUCHERNO",
                "NETPERCENTAGE"
            ];

            for (var j = 0; j < DataFields.length; j++) {
                if (DataFields[j] == searchStr) {
                    return j;
                }
            }
            return -1;
        }

        var $container = $("div").find("#gridTDS");
        $container.handsontable({
            data: [],
            //stretchH: 'all',
            colWidths: [1, 400, 50, 100, 100, 75, 100, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,1],
            startRows: 1,
            colHeaders: ['', 'TDS Nature', '% age', 'Yearly Limit', 'Single Trans<br/>Limit', 'Always<br/>Deduct', 'TDS On', 'TDS Amt', 'Net Amt', 'Service Tax %', 'Service Tax Amt', 'Edu Cess %', 'Edu Cess', 'SRE Edu Cess%', 'SRE Edu Cess', 'Net TDS Amt', 'Dr/Cr', 'Bill No', 'Bill Date', 'Bill Amount', 'Certificate No', 'Certificate Date', 'Transaction Type', 'AutoManual', 'Tds Code', 'Ac Code', 'Party Code', 'User Name', 'Company Code', 'Division Code', 'Year Code', 'OpMode', 'Sys VoucherNo','Net Percentage' ],
            //minSpareRows: 1,
            //contextMenu: ["row_above", "row_below", "remove_row"],
            //contextMenu: ["remove_row"],
            fillHandle: false,
            columns: [
              { data: "SELECTED", type: 'checkbox', checkedTemplate: 'YES', uncheckedTemplate: 'NO' },
              { data: "TDSNATURE", type: 'text', readOnly: true },
              { data: "TDSPERCENTAGE", readOnly: true },
              { data: "YEARLYLIMIT", readOnly: true },
              { data: "SINGLETRANSACTIONLIMIT", readOnly: true },
              { data: "ALWAYSDEDUCT", readOnly: true },
              { data: "TDSDEDUCTEDON", type: 'numeric', format: '0.00', language: 'en' },
              { data: "TDSAMT", readOnly: true, type: 'numeric', format: '0.00', language: 'en' },
              { data: "NETAMT", readOnly: true, type: 'numeric', format: '0.00', language: 'en' },
              { data: "SURCHARGEPERCENTAGE", readOnly: true, type: 'numeric', format: '0.00', language: 'en' },
              { data: "SERVICETAXAMOUNT", readOnly: true, type: 'numeric', format: '0.00', language: 'en' },
              { data: "EDUCATIONCESS", readOnly: true, type: 'numeric', format: '0.00', language: 'en' },
              { data: "EDUCESSAMT", readOnly: true, type: 'numeric', format: '0.00', language: 'en' },
              { data: "SREDUCATIONCESS", readOnly: true, type: 'numeric', format: '0.00', language: 'en' },
              { data: "SREEDUCESSAMT", readOnly: true, type: 'numeric', format: '0.00', language: 'en' },
              { data: "NETTDSAMT", readOnly: true, type: 'numeric', format: '0.00', language: 'en' },
              { data: "DRCR", readOnly: true },
              { data: "BILLNO", readOnly: true },
              { data: "BILLDATE", readOnly: true },
              { data: "BILLAMOUNT", readOnly: true },
              { data: "CERTIFICATENO", readOnly: true },
              { data: "CERTIFICATEDATE", readOnly: true },
              { data: "TRANSACTIONTYPE", readOnly: true },
              { data: "MANUALAUTO", readOnly: true },
              { data: "TDSCODE", readOnly: true },
              { data: "ACCODE", readOnly: true },
              { data: "PARTYCODE", readOnly: true },
              { data: "USERNAME", readOnly: true },
              { data: "COMPANYCODE", readOnly: true },
              { data: "DIVISIONCODE", readOnly: true },
              { data: "YEARCODE", readOnly: true },
              { data: "OPERATIONMODE", readOnly: true },
              { data: "SYSTEMVOUCHERNO", readOnly: true },
              { data: "NETPERCENTAGE", readOnly: true }
              

            ],
            afterChange: TDSGridAfterChange,
            afterOnCellMouseOver: handleAfterOnCellMouseOver
        });

        function TDSGridAfterChange(changes, data) {
            if (!changes) {
                return;
            }
            $.each(changes, function (index, element) {
                var change = element;
                var rowIndex = change[0];
                var columnIndex = change[1];
                var gridrowcolumns = $('#gridTDS').handsontable('getInstance');
                var str1 = '';
                var strDataArr = new Array();

                if (columnIndex == "TDSDEDUCTEDON") {
                    var varTDSDEDUCTEDON = $("#gridTDS").handsontable('getDataAtCell', rowIndex, returnColIndexTDS("TDSDEDUCTEDON"));
                    if (Number(varTDSDEDUCTEDON) < 0) {
                        alert('Amount should be greater than 0');
                        $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("TDSDEDUCTEDON"), '0.00');
                        gridrowcolumns.selectCell(rowIndex, returnColIndexTDS("TDSDEDUCTEDON"));
                    } else {
                        validateTotalTDSAmount(rowIndex);
                        //fn_calcTDSAmount(rowIndex);
                    }
                }//   End amount

                if (columnIndex == "NETTDSAMT") {
                    totalTDSAmount();
                }
            });

            document.getElementById('<%=txtTDSGRIDDATA.ClientID%>').value = '';
            fn_GetGridData("gridTDS");
        }

        function fn_GetGridData(id) {
            if (id == "gridTDS") {
                var $container = $("div").find("#gridTDS");
                var handsontable = $container.data('handsontable');
                var myData = handsontable.getData();
                document.getElementById('<%=txtTDSGRIDDATA.ClientID%>').value = JSON.stringify(myData);
            }
        }

        function FetchTDSGridData() {
            var varAcCode = document.getElementById('<%=txtACCODE.ClientID%>').value;
            var varSysVoucherDt = document.getElementById('<%=txtSYSTEMVOUCHERDATE.ClientID%>').value;
            var varGroupType = document.getElementById('<%=txtGROUPTYPE.ClientID%>').value;
            $.ajax(
            {
                type: "POST",
                url: "AcPaymentAdvanceDirect_BMPL.aspx/getTDSGridData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                data: JSON.stringify({ strAcCode: varAcCode, strSysVoucherDt: varSysVoucherDt, strGroupType: varGroupType }),
                success: function (res) {
                    part = res.d;
                    var data = JSON.parse(part);
                    $("div").find("#gridTDS").handsontable('loadData', data);
                    // to initialize grid text box data after data fetching for later update without grid after event change
                    document.getElementById('<%=txtTDSGRIDDATA.ClientID%>').value = part;
                }
                //,
                //error: function (xhr, status) {
                //    alert("Too many data: " + status.toString());
                //}
            });
        }


        function FetchTDSGridBySysVoucherNo() {
            var varSysVoucherNo = document.getElementById('<%=txtSYSTEMVOUCHERNO.ClientID%>').value;
            var varOperationMode = document.getElementById('<%=txtOPTMODE.ClientID%>').value;
            var varAcCode = document.getElementById('<%=txtACCODE.ClientID%>').value;
            var varSysVoucherDt = document.getElementById('<%=txtSYSTEMVOUCHERDATE.ClientID%>').value;
            var varGroupType = document.getElementById('<%=txtGROUPTYPE.ClientID%>').value;
            var ORDERDATE = document.getElementById('<%=mskORDERDATE.ClientID%>').value;
            $.ajax(
            {
                type: "POST",
                url: "AcPaymentAdvanceDirect_BMPL.aspx/getTDSGridBySysVoucherNo",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                data: JSON.stringify({ strSysVoucherNo: varSysVoucherNo, strOperationMode: varOperationMode, strAcCode: varAcCode, strSysVoucherDt: varSysVoucherDt, strGroupType: varGroupType, strORDERDATE: ORDERDATE }),
                success: function (res) {
                    part = res.d;
                    var data = JSON.parse(part);
                    $("div").find("#gridTDS").handsontable('loadData', data);
                    // to initialize grid text box data after data fetching for later update without grid after event change
                    document.getElementById('<%=txtTDSGRIDDATA.ClientID%>').value = part;
                    totalTDSAmount();
                }
                //,
                //error: function (xhr, status) {
                //    alert("Too many data: " + status.toString());
                //}
            });
        }



        //======================================Calculate TDS amt============================================
        function fn_calcTDSAmount(rowIndex) {
            //var gridrowcolumns = $('#gridTDS').handsontable('getInstance');
            var tdsPercent = $("#gridTDS").handsontable('getDataAtCell', rowIndex, returnColIndexTDS("TDSPERCENTAGE"));
            var tdsOnAmt = $("#gridTDS").handsontable('getDataAtCell', rowIndex, returnColIndexTDS("TDSDEDUCTEDON"));
            var serviceTaxPercent = $("#gridTDS").handsontable('getDataAtCell', rowIndex, returnColIndexTDS("SURCHARGEPERCENTAGE"));
            var eduCessPercent = $("#gridTDS").handsontable('getDataAtCell', rowIndex, returnColIndexTDS("EDUCATIONCESS"));
            var sreduCessPercent = $("#gridTDS").handsontable('getDataAtCell', rowIndex, returnColIndexTDS("SREDUCATIONCESS"));


            var varcompcode = $("#gridTDS").handsontable('getDataAtCell', rowIndex, returnColIndexTDS("COMPANYCODE"));
            var vardivcode = $("#gridTDS").handsontable('getDataAtCell', rowIndex, returnColIndexTDS("DIVISIONCODE"));
            var varyearcode = $("#gridTDS").handsontable('getDataAtCell', rowIndex, returnColIndexTDS("YEARCODE"));
            var varSysVoucherNo = document.getElementById('<%=txtSYSTEMVOUCHERNO.ClientID%>').value;
            var varaccode = document.getElementById('<%=txtACCODE.ClientID%>').value;
            //var varbillno = $("#gridTDS").handsontable('getDataAtCell', rowIndex, returnColIndexTDS("BILLNO"));
            var vartdscode = $("#gridTDS").handsontable('getDataAtCell', rowIndex, returnColIndexTDS("TDSCODE"));
            var vartdsnature = $("#gridTDS").handsontable('getDataAtCell', rowIndex, returnColIndexTDS("TDSNATURE"));
            var varTDSOnAmt = $("#gridTDS").handsontable('getDataAtCell', rowIndex, returnColIndexTDS("TDSDEDUCTEDON"));
            var ORDERDATE = document.getElementById('<%=mskORDERDATE.ClientID%>').value;

            $.ajax(
            {
                type: "POST",
                url: "AcPaymentAdvanceDirect_BMPL.aspx/calcTDSAmount",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                data: JSON.stringify({
                    strcompcode: varcompcode, strdivcode: vardivcode, stryearcode: varyearcode,
                    straccode: varaccode, strtdscode: vartdscode, strTDSOnAmt: varTDSOnAmt, strORDERDATE: ORDERDATE
                }),
                success: function (response) {
                    var str1 = (response.d);
                    var strDataArr = new Array();
                    if (str1 != '') {
                        strDataArr = str1.split("~");
                        //TDSDEDUCTEDON||'~'||BILLAMOUNT||'~'||DRCR||'~'||PERCENTAGE||'~'||HSEDUCATIONCESSAMOUNT ||'~'||SERVICETAXAMOUNT||'~'||EDUCATIONCESSAMOUNT||'~'||NETTDSAMOUNT||'~'||NETAMOUNT||'~'||TOTALTDSAMOUNT||'~'||PARTYCODE||'~'||TRANSACTIONTYPE||'~'||ACCODE
                        //100~100~C~10~0~0~0~10~90~10~C000093~TDS LIABILITY~T000022
                        // $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("TDSDEDUCTEDON"), strDataArr[0]); // TDSDEDUCTEDON
                        $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("BILLAMOUNT"), strDataArr[1]); // BILLAMOUNT
                        $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("DRCR"), strDataArr[2]); // DRCR
                        $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("TDSPERCENTAGE"), strDataArr[3]); // TDSPERCENTAGE
                        $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("NETPERCENTAGE"), strDataArr[3]); // NETPERCENTAGE
                        $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("SREEDUCESSAMT"), strDataArr[4]); // SREEDUCESSAMT
                        $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("SERVICETAXAMOUNT"), strDataArr[5]); // surchargeAmt  
                        $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("EDUCESSAMT"), strDataArr[6]); // eduCessAmt  
                        $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("NETTDSAMT"), strDataArr[7]); // netTDSAmt   
                        $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("NETAMT"), strDataArr[8]); // netAmt
                        $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("TDSAMT"), strDataArr[9]); // TDSAmt
                        $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("PARTYCODE"), strDataArr[10]); // PARTYCODE
                        $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("TRANSACTIONTYPE"), strDataArr[11]); // TRANSACTIONTYPE 
                        $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("ACCODE"), strDataArr[12]); // ACCODE 
                    }
                    //totalTDSAmount();
                }
                //,
                //error: function (xhr, status) {
                //    alert("An error occurred: " + status);
                //}
            });
            //-------------------------------------------------

            $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("BILLNO"), document.getElementById('<%=txtORDERNO.ClientID%>').value);
            $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("BILLDATE"), document.getElementById('<%=mskORDERDATE.ClientID%>').value);
            //$("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("OPERATIONMODE"), document.getElementById('<%=txtOPTMODE.ClientID%>').value);
            $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("USERNAME"), document.getElementById('<%=txtUSRNAME.ClientID%>').value);
            $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("MANUALAUTO"), document.getElementById('<%=txtAUTOMANUALMARK.ClientID%>').value);


        }

        //======================================Calculate Total TDS amt============================================
        function totalTDSAmount() {
            var $container = $("div").find("#gridTDS");
            var handsontable = $container.data('handsontable');
            var rowCount = $("#gridTDS").handsontable('countRows');
            var netTDSAmt = 0;
            var TdsOnAmt = 0;
            var totalTdsAmount = 0;
            var totalTdsOnAmt = 0;
            var varTDSON = document.getElementById('<%=txtTDSONAMOUNT.ClientID%>').value;

            for (var i = 0; i < rowCount; i++) {
                TdsOnAmt = $("#gridTDS").handsontable('getDataAtCell', i, returnColIndexTDS("TDSDEDUCTEDON")) // TDSDEDUCTEDON 
                if (TdsOnAmt > 0) {
                    totalTdsOnAmt += Number(TdsOnAmt);
                }

                netTDSAmt = $("#gridTDS").handsontable('getDataAtCell', i, returnColIndexTDS("NETTDSAMT")) // netTDSAmt 
                if (netTDSAmt > 0) {
                    totalTdsAmount += Number(netTDSAmt);
                }
            }

            document.getElementById('<%=txtTOTALTDSON.ClientID%>').value = "";
            document.getElementById('<%=txtTOTALTDSON.ClientID%>').value = totalTdsOnAmt.toFixed(2);

            document.getElementById('<%=txtTDSONAMOUNT.ClientID%>').value = "";
            document.getElementById('<%=txtTDSONAMOUNT.ClientID%>').value = totalTdsOnAmt.toFixed(2);

            document.getElementById('<%=txtTOTALTDSAMOUNT.ClientID%>').value = "";
            document.getElementById('<%=txtTOTALTDSAMOUNT.ClientID%>').value = totalTdsAmount.toFixed(2);
            totalLiability();
        }

        //======================================Calculate Total TDS amt============================================
        function validateTotalTDSAmount(rowIndex) {
            var $container = $("div").find("#gridTDS");
            var handsontable = $container.data('handsontable');
            var rowCount = $("#gridTDS").handsontable('countRows');
            var netTDSAmt = 0;
            var TdsOnAmt = 0;
            var totalTdsAmount = 0;
            var totalTdsOnAmt = 0;
            var varTDSON = document.getElementById('<%=txtTDSONAMOUNT.ClientID%>').value;
            var varAmounttopay = document.getElementById('<%=txtAMOUNTTOPAY.ClientID%>').value;

            for (var i = 0; i < rowCount; i++) {
                TdsOnAmt = $("#gridTDS").handsontable('getDataAtCell', i, returnColIndexTDS("TDSDEDUCTEDON")) // TDSDEDUCTEDON 
                totalTdsOnAmt += Number(TdsOnAmt);

                netTDSAmt = $("#gridTDS").handsontable('getDataAtCell', i, returnColIndexTDS("NETTDSAMT")) // netTDSAmt 
                totalTdsAmount += Number(netTDSAmt);
            }
            //if (totalTdsOnAmt > Number(varAmounttopay)) {
            //    alert("Total TDS On Amount can not be greater than Payment Amount ");
            //    $("#gridTDS").handsontable('setDataAtCell', rowIndex, returnColIndexTDS("TDSDEDUCTEDON"), '0.00');
            //    gridrowcolumns.selectCell(rowIndex, returnColIndexTDS("TDSDEDUCTEDON"));
            //}
            //else {
            //    fn_calcTDSAmount(rowIndex);
            //}
            fn_calcTDSAmount(rowIndex);
        }

        function totalLiability() {
            var varPayableAmt = document.getElementById('<%=txtAMOUNTTOPAY.ClientID%>').value;
            var varNetTDSAmt = document.getElementById('<%=txtTOTALTDSAMOUNT.ClientID%>').value;
            if (Number(varPayableAmt) > 0 && Number(varNetTDSAmt) > 0) {
                document.getElementById('<%=txtAMOUNT.ClientID%>').value = (Number(varPayableAmt) - Number(varNetTDSAmt)).toFixed(2);
                document.getElementById('<%=txtTotAdjustingAmt.ClientID%>').value = (Number(varPayableAmt) - Number(varNetTDSAmt)).toFixed(2);
            }
            else {
                document.getElementById('<%=txtAMOUNT.ClientID%>').value = Number(varPayableAmt).toFixed(2);
                document.getElementById('<%=txtTotAdjustingAmt.ClientID%>').value = Number(varPayableAmt).toFixed(2);
            }

        }

        function PopulateTDSdetailsGrid() {
            var data1 = document.getElementById('<%=txtTDSGRIDDATA.ClientID%>').value;
            var data = jQuery.parseJSON(data1);
            $("div").find("#gridTDS").handsontable("loadData", data);
        }

        ////////////////////////////////////////////End TDS Grid////////////////

        //=============================roundOff=========
        function roundoff(num, decimals) {
            return Math.round(num * Math.pow(10, decimals)) / Math.pow(10, decimals);
        }



 </script>

</asp:Content>
