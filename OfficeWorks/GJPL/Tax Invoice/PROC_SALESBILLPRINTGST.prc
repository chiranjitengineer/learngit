CREATE OR REPLACE PROCEDURE GJPL_WEB."PROC_SALESBILLPRINTGST" 
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
    IRN_CNT             NUMBER := 0;
begin
    delete from gtt_salesbillprintgst;
    lv_sqlstr :=   'insert into gtt_salesbillprintgst'|| chr(10)
                || 'SELECT S.SALEBILLNO, S.SALEBILLDATE, S.EXCISEINVNO, S.EXCISEINVDATE, S.PROFORMAINVNO, S.PROFORMAINVDATE, S.SAUDANO, S.SAUDADATE, '|| chr(10)
                || '       S.BUYERORDERNO, S.BUYERORDERDATE, S.BROKERCODE, S.BROKERNAME, S.BUYERCODE, S.BUYERNAME, S.TRANSPORTERCODE, P.PARTYNAME, '|| chr(10)
                || '       P1.ADDRESSNAME ADDRESSNAMEBILL, P1.ADDRESS ADDRESSBILL, P1.PIN PINBILL, P1.GSTSTATECODE||'' ''||P1.STATE STATEBILL, P1.GSTNNO GSTNNOBILL, '|| chr(10)
                || '       P2.ADDRESSNAME ADDRESSNAMESHIP, P2.ADDRESS ADDRESSSHIP, P2.PIN PINSHIP, P2.GSTSTATECODE||'' ''||P2.STATE STATESHIP, P2.GSTNNO GSTNNOSHIP, '|| chr(10)
                || '       S.DESTINATION, S.VEHICLENO, S.VESSELORFLIGHT, S.VESSELFLIGHTNO, S.CNOTENO, S.CNOTEDATE, S.CHALLANNO, S.CHANNELCODE, '|| chr(10)
                || '       S.BILLSERIALNO, S.QUALITYCODE, H.HSNCODE, S.QUALITYMANUALDESC||CHR(10)||S.MARKS QUALITYMANUALDESC, S.PACKINGCODE, S.PACKINGNAME, S.NOOFPACKINGUNIT, S.UORCODE,  '|| chr(10)
                || '       S.UORNAME, S.MEASURECODE, S.TOTALQUANTITY, DECODE(S.MEASUREUNIT,''KGS'',S.TOTALWEIGHT,S.TOTALWEIGHT*1) TOTALWEIGHT, DECODE(S.MEASUREUNIT,''KGS'',S.PACKSHEETWEIGHT,S.PACKSHEETWEIGHT*1) PACKSHEETWEIGHT, DECODE(S.MEASUREUNIT,''KGS'',S.GROSSWEIGHT,S.GROSSWEIGHT*1) GROSSWEIGHT, /*S.RATE*/ S.INDIANRATE, /*S.TOTALAMOUNT*/ S.TOTALINDIANAMOUNT, '|| chr(10)
                || '       /*S.GROSSAMOUNT*/ S.GROSSAMOUNTINR, fn_num_to_words(ROUND(S.GROSSAMOUNTINR,2),''RS'') AMTINWORDS, CH.CHARGEDATA, T.SRL, T.TEXT, '|| chr(10)
                || '       C.BANKCODE, B.BANKNAME, B.BANKADDRESS, B.ACNO, C.IFSCCODE IFCSCODE, '|| chr(10)
                || '       C.COMPANYNAME, C.COMPANYADDRESS, C.COMPANYADDRESS1, C.COMPANYADDRESS2, C.PANNO, C.COMPANYEMAIL, '|| chr(10)
                || '       D.DIVISIONNAME, D.GSTNNO, D.GSTSTATECODE, '''||p_logopath||''' LOGOPATH, C.CINNO EX1,  '|| chr(10)
                || '       CASE WHEN CHANNELTAG=''EXPORT'' AND CH.CHARGEDATA LIKE ''%GST%'' THEN ''SUPPLY MEANT FOR EXPORT ON PAYMENT OF INTEGRATED TAX'' WHEN CHANNELTAG=''EXPORT'' AND CH.CHARGEDATA NOT LIKE ''%GST%'' THEN ''SUPPLY MEANT FOR EXPORT UNDER BOND OR LETTER OF UNDERTAKING WITHOUT PAYMENT OF INTERGREATED TAX'' ELSE '''' END EX2, S.CURRENCYCODE EX3, S.PACKSTYLECODE EX4, '''||p_logopath2||''' EX5, '|| chr(10)
                || '       S.EWAYBILLNO, S.EWAYBILLDATE, S.TIME_STAMP, TO_CHAR(S.SALEBILLDATE,''DD/MM/YYYY'')||''  ''||S.TIMEOFPREPARATION EX6,S.SUPPLYORDERNO EX7, TO_CHAR(S.SUPPORDERDATE,''DD/MM/YYYY'') EX8, REMARKSPRO EX9, S.CHANNELTAG EX10, '|| chr(10)
                ||'        '''||p_logopath3||''' EX11, NULL EX12, NULL EX13, NULL EX14, NULL EZ15,    '||CHR(10)
                ||'        NULL EX16, NULL EX17, NULL EX18,NULL EX19,NULL EX20,NULL EX21,NULL EX22,NULL EX23,NULL EX24,NULL EX25,NULL EX26,NULL EX27,NULL EX28,NULL EX29,NULL EX30,NULL EX31,NULL EX32,NULL EX33,NULL EX34,NULL EX35,NULL EX36,NULL EX37,NULL EX38,NULL EX39,NULL EX40'||CHR(10)
                || 'FROM SALESBILLVIEW S, COMPANYMAST C, DIVISIONMASTER D, PARTYADDRESS P1, PARTYADDRESS P2, PARTYMASTER P, GSTITEMVSHSNMAPPING H, SALESBANKMASTER B, '|| chr(10)
                || '     ( '|| chr(10)
                || '      SELECT DOCUMENTNO, rtrim(xmlagg(xmlelement(e, X.CHARGESHORTNAME || ''             ''|| X.CHARGEAMOUNT || ''~'')order by X.SERIALNO).extract (''//text()''),''~'') CHARGEDATA '|| chr(10)
                || '        FROM ( '|| chr(10)
                || '        SELECT D.DOCUMENTNO, M.CHARGESHORTNAME, TO_CHAR(CHARGEAMOUNT,''9999999990.99'') CHARGEAMOUNT, TO_NUMBER(SERIALNO) SERIALNO '|| chr(10)
                || '        FROM SALESCHARGEDETAILS D, CHARGEMASTER M '|| chr(10)
                || '        WHERE D.COMPANYCODE=M.COMPANYCODE '|| chr(10)
                || '        AND D.DIVISIONCODE=M.DIVISIONCODE '|| chr(10)
                || '        AND D.CHARGECODE=M.CHARGECODE '|| chr(10)
                || '        AND D.CHANNELCODE=M.CHANNELCODE '|| chr(10)
                || '        AND M.MODULE=''SALES'' '|| chr(10)
                || '        AND M.CHARGETYPE NOT LIKE ''GST_%'' '|| chr(10)
                || '        AND D.COMPANYCODE='''||p_companycode||''' '|| chr(10)
                || '        AND D.DIVISIONCODE='''||p_divisioncode||''' '|| chr(10)
                || '        AND D.DOCUMENTTYPE=''SALE BILL'' '|| chr(10)
                || '        UNION ALL '|| chr(10)
                || '        SELECT D.DOCUMENTNO, ''TAXABLE VALUE'' CHARGESHORTNAME, TO_CHAR(MAX(NVL(ASSESSABLEAMOUNT,0)),''9999999990.99'') CHARGEAMOUNT, MIN(TO_NUMBER(SERIALNO))-0.1 SERIALNO '|| chr(10)
                || '        FROM SALESCHARGEDETAILS D, CHARGEMASTER M '|| chr(10)
                || '        WHERE D.COMPANYCODE=M.COMPANYCODE '|| chr(10)
                || '        AND D.DIVISIONCODE=M.DIVISIONCODE '|| chr(10)
                || '        AND D.CHARGECODE=M.CHARGECODE '|| chr(10)
                || '        AND D.CHANNELCODE=M.CHANNELCODE '|| chr(10)
                || '        AND M.MODULE=''SALES'' '|| chr(10)
                || '        AND M.CHARGETYPE LIKE ''GST_%'' '|| chr(10)
                || '        AND D.COMPANYCODE='''||p_companycode||''' '|| chr(10)
                || '        AND D.DIVISIONCODE='''||p_divisioncode||''' '|| chr(10)
                || '        AND D.DOCUMENTTYPE=''SALE BILL'' '|| chr(10)
                || '        GROUP BY D.DOCUMENTNO '|| chr(10)
                || '        UNION ALL '|| chr(10)
                || '        SELECT D.DOCUMENTNO, M.CHARGESHORTNAME, TO_CHAR(CHARGEAMOUNT,''9999999990.99'') CHARGEAMOUNT, TO_NUMBER(SERIALNO) SERIALNO '|| chr(10)
                || '        FROM SALESCHARGEDETAILS D, CHARGEMASTER M '|| chr(10)
                || '        WHERE D.COMPANYCODE=M.COMPANYCODE '|| chr(10)
                || '        AND D.DIVISIONCODE=M.DIVISIONCODE '|| chr(10)
                || '        AND D.CHARGECODE=M.CHARGECODE '|| chr(10)
                || '        AND D.CHANNELCODE=M.CHANNELCODE '|| chr(10)
                || '        AND M.MODULE=''SALES'' '|| chr(10)
                || '        AND M.CHARGETYPE LIKE ''GST_%'' '|| chr(10)
                || '        AND D.COMPANYCODE='''||p_companycode||''' '|| chr(10)
                || '        AND D.DIVISIONCODE='''||p_divisioncode||''' '|| chr(10)
                || '        AND D.DOCUMENTTYPE=''SALE BILL'' '|| chr(10)
                || '        ORDER BY SERIALNO '|| chr(10)
                || '        ) X '|| chr(10)
                || '        GROUP BY DOCUMENTNO '|| chr(10)
                || '     ) CH, '|| chr(10)
                || '     ( '|| chr(10)
                || '        SELECT 1 SRL, ''Original for Recipient'' TEXT FROM DUAL '|| chr(10)
                || '        UNION ALL '|| chr(10)
                || '        SELECT 2 SRL, ''Duplicate For Transporter'' TEXT FROM DUAL '|| chr(10)
                || '        UNION ALL '|| chr(10)
                || '        SELECT 3 SRL, ''Triplicate For Supplier'' TEXT FROM DUAL '|| chr(10)
                || '        UNION ALL '|| chr(10)
                || '        SELECT 4 SRL, ''Extra Copy'' TEXT FROM DUAL '|| chr(10)
                || '     ) T '|| chr(10)
                || 'WHERE S.COMPANYCODE=C.COMPANYCODE '|| chr(10)
                || 'AND S.COMPANYCODE=D.COMPANYCODE '|| chr(10)
                || 'AND S.DIVISIONCODE=D.DIVISIONCODE '|| chr(10)
                || 'AND S.COMPANYCODE=H.COMPANYCODE '|| chr(10)
                || 'AND S.QUALITYCODE=H.ITEMCODE '|| chr(10)
                || 'AND H.MODULE=''SALES'' '|| chr(10)
                || 'AND C.COMPANYCODE=B.COMPANYCODE(+) '|| chr(10)
                || 'AND B.DIVISIONCODE(+)='''||p_divisioncode||''' '|| chr(10)
                || 'AND C.BANKCODE=B.BANKCODE(+) '|| chr(10)
                || 'AND C.IFSCCODE=B.IFSCCODE(+) '|| chr(10)
                || 'AND S.SALEBILLNO=CH.DOCUMENTNO(+) '|| chr(10)
                || 'AND S.COMPANYCODE=P1.COMPANYCODE(+) '|| chr(10)
                || 'AND S.BUYERCODE=P1.PARTYCODE(+) '|| chr(10)
                || 'AND S.ADDRESSCODEBILL=P1.ADDRESSCODE(+) '|| chr(10)
                || 'AND P1.MODULE(+)=''SALES'' '|| chr(10)
                || 'AND S.COMPANYCODE=P2.COMPANYCODE(+) '|| chr(10)
                || 'AND S.BUYERCODE=P2.PARTYCODE(+) '|| chr(10)
                || 'AND S.ADDRESSCODE=P2.ADDRESSCODE(+) '|| chr(10)
                || 'AND P2.MODULE(+)=''SALES'' '|| chr(10)
                || 'AND S.COMPANYCODE=P.COMPANYCODE(+) '|| chr(10)
                || 'AND S.TRANSPORTERCODE=P.PARTYCODE(+) '|| chr(10)
                || 'AND P.MODULE(+)=''SALES'' '|| chr(10)
                || 'AND P.PARTYTYPE(+)=''TRANSPORTER'' '|| chr(10)
                || 'AND S.COMPANYCODE='''||p_companycode||''' '|| chr(10)
                || 'AND S.DIVISIONCODE='''||p_divisioncode||''' '|| chr(10)
                || 'AND S.SALEBILLDATE>=TO_DATE('''||p_billfrom||''',''DD/MM/YYYY'') '|| chr(10)
                || 'AND S.SALEBILLDATE<=TO_DATE('''||p_billto||''',''DD/MM/YYYY'') '|| chr(10);
                if p_billno is not null then
                    lv_sqlstr := lv_sqlstr || ' AND S.SALEBILLNO IN ('||p_billno||') '|| chr(10);
                end if;
                lv_sqlstr := lv_sqlstr || 'ORDER BY S.SALEBILLNO, T.SRL, S.BILLSERIALNO '|| chr(10);
    
--    DBMS_OUTPUT.PUT_LINE(lv_sqlstr);
    execute immediate lv_sqlstr;
    
    
         -----IRN DATA UPDATE -----------------------
    lv_sqlstr:=' SELECT COUNT(*)    '||CHR(10)
             ||'   FROM EINVOICE_MAIN   '||CHR(10)
             ||'  WHERE DOCNO IN ('||p_billno||')    '||CHR(10)
             ||'    AND SIGNEDQRCODE IS NOT NULL     '||CHR(10);

--DBMS_OUTPUT.PUT_LINE(lv_sqlstr);
    execute immediate lv_sqlstr INTO IRN_CNT;


    IF IRN_CNT > 0 THEN
        lv_sqlstr:='      UPDATE gtt_salesbillprintgst  '||CHR(10)
                 ||'         SET (EX12, EX13) = (SELECT IRN, SIGNEDQRCODE FROM EINVOICE_MAIN WHERE DOCNO IN ('||p_billno||'))  '||CHR(10); 
    
--     DBMS_OUTPUT.PUT_LINE(lv_sqlstr);
    execute immediate lv_sqlstr;
    
        
    
    END IF;
    
end;
/
