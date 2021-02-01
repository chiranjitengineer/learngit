CREATE OR REPLACE PROCEDURE DALHOUSIE_WEB."PROC_SALESOTHERSBILLPRINTGST" 
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_billfrom varchar2,
    p_billto varchar2,
    p_billno varchar2,
    p_logopath varchar2,
    p_logopath2 varchar2,
    p_logopath3 varchar2
)
as 
    lv_sqlstr           varchar2(30000);
begin
    delete from gtt_salesotherbillprintgst;
    lv_sqlstr :=   'insert into gtt_salesotherbillprintgst'|| chr(10)
                || 'SELECT S.SALESBILLNO SALEBILLNO, S.SALESBILLDATE SALEBILLDATE, NULL EXCISEINVNO, NULL EXCISEINVDATE, M.SCRAPSALESBILLNO PROFORMAINVNO, M.SCRAPSALESBILLDATE PROFORMAINVDATE, NULL SAUDANO, NULL SAUDADATE, '|| chr(10)
                || '       M.PURCHASEORDERNO BUYERORDERNO, M.PURCHASEORDERDATE BUYERORDERDATE, NULL BROKERCODE, NULL BROKERNAME, M.PARTYCODE BUYERCODE, NULL BUYERNAME, NULL TRANSPORTERCODE, NULL PARTYNAME, '|| chr(10)
                || '       P1.ADDRESSNAME ADDRESSNAMEBILL, P1.ADDRESS ADDRESSBILL, P1.PIN PINBILL, P1.GSTSTATECODE||'' ''||P1.STATE STATEBILL, P1.GSTNNO GSTNNOBILL,  '|| chr(10)
                || '       P2.ADDRESSNAME ADDRESSNAMESHIP, P2.ADDRESS ADDRESSSHIP, P2.PIN PINSHIP, P2.GSTSTATECODE||'' ''||P2.STATE STATESHIP, P2.GSTNNO GSTNNOSHIP,  '|| chr(10)
                || '       M.DESTINATION, M.LORRYNO VEHICLENO, NULL VESSELORFLIGHT, NULL VESSELFLIGHTNO, NULL CNOTENO, NULL CNOTEDATE, NULL CHALLANNO, S.CHANNELCODE,  '|| chr(10)
                || '       S.SERIALNO BILLSERIALNO, NULL QUALITYCODE, S.HSNCODE, S.ITEMDESC QUALITYMANUALDESC, NULL PACKINGCODE, NULL PACKINGNAME, S.NOOFPKG NOOFPACKINGUNIT, S.UOMCODE UORCODE,   '|| chr(10)
                || '       NULL UORNAME, NULL MEASURECODE, S.QUANTITY TOTALQUANTITY, NULL TOTALWEIGHT, NULL PACKSHEETWEIGHT, NULL GROSSWEIGHT, S.RATE INDIANRATE, S.AMOUNT TOTALINDIANAMOUNT,  '|| chr(10)
                || '       M.GROSSAMT GROSSAMOUNTINR, fn_num_to_words(ROUND(M.GROSSAMT,2),''RS'') AMTINWORDS, CH.CHARGEDATA, T.SRL, T.TEXT, '|| chr(10)
                || '       C.BANKCODE, B.BANKNAME, B.BANKADDRESS, B.ACNO, C.IFSCCODE IFCSCODE,  '|| chr(10)
                || '       C.COMPANYNAME, C.COMPANYADDRESS, C.COMPANYADDRESS1, C.COMPANYADDRESS2, C.PANNO, C.COMPANYEMAIL,  '|| chr(10)
                || '       D.DIVISIONNAME, D.GSTNNO, D.GSTSTATECODE, '''||p_logopath||''' LOGOPATH, C.CINNO EX1,   '|| chr(10)
                || '       M.AMENDMENT EX2, M.EWAYBILLNO EX3, TO_CHAR(M.EWAYBILLDATE,''DD/MM/YYYY'')||'' ''||M.TIME_STAMP EX4, '''||p_logopath2||''' EX5  '|| chr(10)
                || 'FROM SALESOTHERBILLDETAIL S, SALESOTHERBILLMASTER M, COMPANYMAST C, DIVISIONMASTER D, PARTYADDRESS P1, PARTYADDRESS P2, SALESBANKMASTER B,  '|| chr(10)
                || '     (  '|| chr(10)
                || '      SELECT DOCUMENTNO, rtrim(xmlagg(xmlelement(e, X.CHARGESHORTNAME || X.CHARGEAMOUNT || ''~'')order by X.SERIALNO).extract (''//text()''),''~'') CHARGEDATA  '|| chr(10)
                || '        FROM (  '|| chr(10)
                || '        SELECT D.DOCUMENTNO, M.CHARGESHORTNAME, TO_CHAR(CHARGEAMOUNT,''9999999990.99'') CHARGEAMOUNT, TO_NUMBER(SERIALNO) SERIALNO  '|| chr(10)
                || '        FROM SALESCHARGEDETAILS D, CHARGEMASTER M  '|| chr(10)
                || '        WHERE D.COMPANYCODE=M.COMPANYCODE  '|| chr(10)
                || '        AND D.DIVISIONCODE=M.DIVISIONCODE  '|| chr(10)
                || '        AND D.CHARGECODE=M.CHARGECODE  '|| chr(10)
                || '        AND D.CHANNELCODE=M.CHANNELCODE  '|| chr(10)
                || '        AND M.MODULE=''SALES''  '|| chr(10)
                || '        AND M.CHARGETYPE NOT LIKE ''GST_%''  '|| chr(10)
                || '        AND D.COMPANYCODE='''||p_companycode||'''  '|| chr(10)
                || '        AND D.DIVISIONCODE='''||p_divisioncode||'''  '|| chr(10)
                || '        AND D.DOCUMENTTYPE IN(''SALE BILL'',''OTHERS BILL'',''SCRAP BILL'')  '|| chr(10)
                || '        UNION ALL  '|| chr(10)
                || '        SELECT D.DOCUMENTNO, ''Taxable Value'' CHARGESHORTNAME, TO_CHAR(MAX(NVL(ASSESSABLEAMOUNT,0)),''9999999990.99'') CHARGEAMOUNT, MIN(TO_NUMBER(SERIALNO))-0.1 SERIALNO  '|| chr(10)
                || '        FROM SALESCHARGEDETAILS D, CHARGEMASTER M  '|| chr(10)
                || '        WHERE D.COMPANYCODE=M.COMPANYCODE  '|| chr(10)
                || '        AND D.DIVISIONCODE=M.DIVISIONCODE  '|| chr(10)
                || '        AND D.CHARGECODE=M.CHARGECODE  '|| chr(10)
                || '        AND D.CHANNELCODE=M.CHANNELCODE  '|| chr(10)
                || '        AND M.MODULE=''SALES''  '|| chr(10)
                || '        AND M.CHARGETYPE LIKE ''GST_%''  '|| chr(10)
                || '        AND D.COMPANYCODE='''||p_companycode||'''  '|| chr(10)
                || '        AND D.DIVISIONCODE='''||p_divisioncode||'''  '|| chr(10)
                || '        AND D.DOCUMENTTYPE IN(''SALE BILL'',''OTHERS BILL'',''SCRAP BILL'')  '|| chr(10)
                || '        GROUP BY D.DOCUMENTNO  '|| chr(10)
                || '        UNION ALL  '|| chr(10)
                || '        SELECT D.DOCUMENTNO, M.CHARGESHORTNAME, TO_CHAR(CHARGEAMOUNT,''9999999990.99'') CHARGEAMOUNT, TO_NUMBER(SERIALNO) SERIALNO  '|| chr(10)
                || '        FROM SALESCHARGEDETAILS D, CHARGEMASTER M  '|| chr(10)
                || '        WHERE D.COMPANYCODE=M.COMPANYCODE  '|| chr(10)
                || '        AND D.DIVISIONCODE=M.DIVISIONCODE  '|| chr(10)
                || '        AND D.CHARGECODE=M.CHARGECODE  '|| chr(10)
                || '        AND D.CHANNELCODE=M.CHANNELCODE  '|| chr(10)
                || '        AND M.MODULE=''SALES''  '|| chr(10)
                || '        AND M.CHARGETYPE LIKE ''GST_%''  '|| chr(10)
                || '        AND D.COMPANYCODE='''||p_companycode||'''  '|| chr(10)
                || '        AND D.DIVISIONCODE='''||p_divisioncode||'''  '|| chr(10)
                || '        AND D.DOCUMENTTYPE IN (''SALE BILL'',''OTHERS BILL'',''SCRAP BILL'')  '|| chr(10)
                || '        ORDER BY SERIALNO  '|| chr(10)
                || '        ) X  '|| chr(10)
                || '        GROUP BY DOCUMENTNO  '|| chr(10)
                || '     ) CH,  '|| chr(10)
                || '     (  '|| chr(10)
                || '        SELECT 1 SRL, ''Original for Recipient'' TEXT FROM DUAL  '|| chr(10)
                || '        UNION ALL  '|| chr(10)
                || '        SELECT 2 SRL, ''Duplicate For Supplier'' TEXT FROM DUAL  '|| chr(10)
                || '        UNION ALL  '|| chr(10)
                || '        SELECT 4 SRL, ''Extra Copy'' TEXT FROM DUAL  '|| chr(10)
                || '     ) T '|| chr(10)
                || 'WHERE S.COMPANYCODE=M.COMPANYCODE '|| chr(10)
                || 'AND S.DIVISIONCODE=M.DIVISIONCODE  '|| chr(10)
                || 'AND S.SALESBILLNO=M.SALESBILLNO  '|| chr(10)
                || 'AND S.COMPANYCODE=C.COMPANYCODE  '|| chr(10)
                || 'AND S.COMPANYCODE=D.COMPANYCODE  '|| chr(10)
                || 'AND S.DIVISIONCODE=D.DIVISIONCODE  '|| chr(10)
                || 'AND C.COMPANYCODE=B.COMPANYCODE(+)  '|| chr(10)
                || 'AND B.DIVISIONCODE(+)='''||p_divisioncode||'''  '|| chr(10)
                || 'AND C.BANKCODE=B.BANKCODE(+)  '|| chr(10)
                || 'AND C.IFSCCODE=B.IFSCCODE(+)  '|| chr(10)
                || 'AND S.SALESBILLNO=CH.DOCUMENTNO(+)  '|| chr(10)
                || 'AND M.COMPANYCODE=P1.COMPANYCODE(+)  '|| chr(10)
                || 'AND M.PARTYCODE=P1.PARTYCODE(+)  '|| chr(10)
                || 'AND M.ADDRESSCODEBILL=P1.ADDRESSCODE(+)  '|| chr(10)
                || 'AND P1.MODULE(+)=''SALES''  '|| chr(10)
                || 'AND M.COMPANYCODE=P2.COMPANYCODE(+)  '|| chr(10)
                || 'AND M.PARTYCODE=P2.PARTYCODE(+)  '|| chr(10)
                || 'AND M.ADDRESSCODE=P2.ADDRESSCODE(+)  '|| chr(10)
                || 'AND P2.MODULE(+)=''SALES''  '|| chr(10)
                || 'AND S.COMPANYCODE='''||p_companycode||'''  '|| chr(10)
                || 'AND S.DIVISIONCODE='''||p_divisioncode||'''  '|| chr(10)
                || 'AND S.SALESBILLDATE>=TO_DATE('''||p_billfrom||''',''DD/MM/YYYY'')  '|| chr(10)
                || 'AND S.SALESBILLDATE<=TO_DATE('''||p_billto||''',''DD/MM/YYYY'')  '|| chr(10);
                if p_billno is not null then
                    lv_sqlstr := lv_sqlstr || ' AND S.SALESBILLNO IN ('||p_billno||') '|| chr(10);
                end if;
                lv_sqlstr := lv_sqlstr || 'ORDER BY S.SALESBILLNO, T.SRL, S.SERIALNO '|| chr(10);

    DBMS_OUTPUT.PUT_LINE(lv_sqlstr);
    execute immediate lv_sqlstr;
end;
/
