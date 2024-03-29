CREATE OR REPLACE PROCEDURE HOOGHLY_WEB."PROC_SALESDOPRINTGST" 
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_dofrom varchar2,
    p_doto varchar2,
    p_dono varchar2,
    p_challan varchar2,
    p_logopath varchar2,
    p_logopath2 varchar2
)
as 
    lv_sqlstr           varchar2(30000);
    lv_Logo_Path                varchar(1000);
    lv_Logo_Path_BANKQRCODE        varchar(1000);
begin
    select substr(p_logopath,1,length(p_logopath)- 
    instr(reverse(p_logopath),'\')+1) into lv_Logo_Path from dual;
    
     SELECT lv_Logo_Path || LOGONAME INTO lv_Logo_Path_BANKQRCODE FROM MODULEWISELOGO
    WHERE COMPANYCODE=p_companycode AND DIVISIONCODE=p_divisioncode AND MODULE='SALES' AND LOGO_TYPE='BANKQRCODE' AND ROWNUM=1;
    
    delete from gtt_salesdoprintgst;
    lv_sqlstr :=   'insert into gtt_salesdoprintgst(SALEBILLNO, SALEBILLDATE, EXCISEINVNO, EXCISEINVDATE, PROFORMAINVNO, PROFORMAINVDATE, '|| chr(10)
                || 'SAUDANO, SAUDADATE, BUYERORDERNO, BUYERORDERDATE, BROKERCODE, BROKERNAME, BUYERCODE, '|| chr(10)
                || 'BUYERNAME, TRANSPORTERCODE, PARTYNAME, ADDRESSNAMEBILL, ADDRESSBILL, PINBILL, STATEBILL, '|| chr(10)
                || 'GSTNNOBILL, ADDRESSNAMESHIP, ADDRESSSHIP, PINSHIP, STATESHIP, GSTNNOSHIP, DESTINATION, VEHICLENO, '|| chr(10)
                || 'VESSELORFLIGHT, VESSELFLIGHTNO, CNOTENO, CNOTEDATE, CHALLANNO, CHANNELCODE, BILLSERIALNO, QUALITYCODE, '|| chr(10)
                || 'HSNCODE, QUALITYMANUALDESC, PACKINGCODE, PACKINGNAME, NOOFPACKINGUNIT, UORCODE, UORNAME, MEASURECODE, '|| chr(10)
                || 'TOTALQUANTITY, TOTALWEIGHT, PACKSHEETWEIGHT, GROSSWEIGHT, INDIANRATE, TOTALINDIANAMOUNT, GROSSAMOUNTINR, '|| chr(10)
                || 'AMTINWORDS, CHARGEDATA, SRL, TEXT, BANKCODE, BANKNAME, BANKADDRESS, ACNO, IFCSCODE, COMPANYNAME, '|| chr(10)
                || 'COMPANYADDRESS, COMPANYADDRESS1, COMPANYADDRESS2, PANNO, COMPANYEMAIL, DIVISIONNAME, GSTNNO, '|| chr(10)
                || 'GSTSTATECODE, LOGOPATH, EX1, EX2, EX3, EX4, EX5, EX6, EX7, EX8, EX9,EX11,EX12,EX14)'|| chr(10)
                || 'SELECT S.CONTRACTNO SALEBILLNO, S.CONTRACTDATE SALEBILLDATE,  S.PCONUMBER EXCISEINVNO, PCODATE EXCISEINVDATE, S.PROFORMAINVNO, S.PROFORMAINVDATE, S.SAUDANO, S.SAUDADATE,  '|| chr(10)
                || '       S.BUYERORDERNO, S.BUYERORDERDATE, S.BROKERCODE, S.BROKERNAME, S.BUYERCODE, S.BUYERNAME, NULL TRANSPORTERCODE, NULL PARTYNAME,  '|| chr(10)
                || '        P1.ADDRESSNAME ADDRESSNAMEBILL, P1.ADDRESS ||'' Pin : ''||P1.PIN ADDRESSBILL, P1.PIN PINBILL, P1.GSTSTATECODE||'' ''||P1.STATE STATEBILL, P1.GSTNNO GSTNNOBILL,  '|| chr(10)
                || '        P2.ADDRESSNAME ADDRESSNAMESHIP, P2.ADDRESS ||'' Pin : ''||P2.PIN ADDRESSSHIP, P2.PIN PINSHIP, P2.GSTSTATECODE||'' ''||P2.STATE STATESHIP, P2.GSTNNO GSTNNOSHIP,  '|| chr(10)
                || '       S.FINALDESTINATION DESTINATION, S.VESSELFLIGHTNO VEHICLENO, S.VESSELORFLIGHT, S.VESSELFLIGHTNO, NULL CNOTENO, NULL CNOTEDATE, NULL CHALLANNO, S.CHANNELCODE,  '|| chr(10)
                || '       S.PROFORMASERIALNO BILLSERIALNO, S.QUALITYCODE, H.HSNCODE,  S.QUALITYMANUALDESC||CHR(10)||S.MARKS QUALITYMANUALDESC, S.PACKINGCODE, S.PACKINGNAME, S.NOOFPACKINGUNIT, S.UORCODE,   '|| chr(10)
                || '       S.UORNAME, S.MEASURECODE, S.TOTALQUANTITY, DECODE(S.MEASUREUNIT,''KGS'',S.TOTALWEIGHT,S.TOTALWEIGHT*1) TOTALWEIGHT, DECODE(S.MEASUREUNIT,''KGS'',S.PACKSHEETWT,S.PACKSHEETWT*1) PACKSHEETWEIGHT, DECODE(S.MEASUREUNIT,''KGS'',S.NETWEIGHT,S.NETWEIGHT*1) GROSSWEIGHT, /*S.RATE*/ S.INDIANRATE, /*S.TOTALAMOUNT*/ S.TOTALINDIANAMOUNT,  '|| chr(10)
                || '       /*S.GROSSAMOUNT*/ S.GROSSAMOUNT, fn_num_to_words(ROUND(S.GROSSAMOUNT,2),''RS'') AMTINWORDS, CH.CHARGEDATA, T.SRL, T.TEXT,  '|| chr(10)
                || '       C.BANKCODE, B.BANKNAME, B.BANKADDRESS, B.ACNO, C.IFSCCODE IFCSCODE, '|| chr(10)
                || '       replace(C.companyname,''Unit : '', chr(10)||''Unit : '') COMPANYNAME, C.COMPANYADDRESS, C.COMPANYADDRESS1, C.COMPANYADDRESS2, C.PANNO, C.COMPANYEMAIL, '|| chr(10)
                || '       D.DIVISIONNAME, D.GSTNNO, D.GSTSTATECODE, '''||p_logopath||''' LOGOPATH, C.CINNO EX1, '|| chr(10)
                || '       NULL EX2, S.CURRENCYCODE EX3, S.PACKSTYLECODE EX4, '''||p_logopath2||''' EX5,  '|| chr(10)
                || '       C.COMPANYHOPHONE1 EX6, C.COMPANYFAX EX7, C.COMPANYCOUNTRY EX8, C.COMPANYSTATE EX9,''PROFORMA INVOICE CUM LORRY PASS'' EX11,D.DIVISIONADDRESS EX12,'''||lv_Logo_Path_BANKQRCODE||''' EX14'||CHR(10)
                || 'FROM SALESPROFORMAINVOICEVIEW S, COMPANYMAST C, DIVISIONMASTER D, PARTYADDRESS P1, PARTYADDRESS P2, GSTITEMVSHSNMAPPING H, SALESBANKMASTER B,  '|| chr(10)
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
                || '        AND D.DOCUMENTTYPE=''PROFORMA INVOICE''  '|| chr(10)
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
                || '        AND D.DOCUMENTTYPE=''PROFORMA INVOICE''  '|| chr(10)
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
                || '        AND D.DOCUMENTTYPE=''PROFORMA INVOICE'' '|| chr(10)
                || '        ORDER BY SERIALNO  '|| chr(10)
                || '        ) X  '|| chr(10)
                || '        GROUP BY DOCUMENTNO  '|| chr(10)
                || '     ) CH,  '|| chr(10)
                || '     (  '|| chr(10)
                || '        SELECT 1 SRL, ''Original for Buyer/Duplicate For Mill/Triplicate For HO'' TEXT FROM DUAL  '|| chr(10)
--               || '        UNION ALL  '|| chr(10)
--                || '        SELECT 2 SRL, ''Duplicate For Mill'' TEXT FROM DUAL  '|| chr(10)
--                || '        UNION ALL  '|| chr(10)
--                || '        SELECT 3 SRL, ''Triplicate For HO'' TEXT FROM DUAL  '|| chr(10)
               /*  || '        UNION ALL  '|| chr(10)
                || '        SELECT 4 SRL, ''Extra Copy'' TEXT FROM DUAL  '|| chr(10) */
                || '     ) T  '|| chr(10)
                || 'WHERE S.COMPANYCODE=C.COMPANYCODE  '|| chr(10)
                || 'AND S.COMPANYCODE=D.COMPANYCODE  '|| chr(10)
                || 'AND S.DIVISIONCODE=D.DIVISIONCODE  '|| chr(10)
                || 'AND S.COMPANYCODE=H.COMPANYCODE  '|| chr(10)
                || 'AND S.QUALITYCODE=H.ITEMCODE  '|| chr(10)
                || 'AND H.MODULE=''SALES''  '|| chr(10)
                || 'AND C.COMPANYCODE=B.COMPANYCODE(+)  '|| chr(10)
                || 'AND B.DIVISIONCODE(+)='''||p_divisioncode||'''  '|| chr(10)
                || 'AND C.BANKCODE=B.BANKCODE(+)  '|| chr(10)
                || 'AND C.IFSCCODE=B.IFSCCODE(+)  '|| chr(10)
                || 'AND S.PROFORMAINVNO=CH.DOCUMENTNO(+)  '|| chr(10)
                || 'AND S.COMPANYCODE=P1.COMPANYCODE(+)  '|| chr(10)
                || 'AND S.BUYERCODE=P1.PARTYCODE(+)  '|| chr(10)
                || 'AND S.ADDRESSCODEBILL=P1.ADDRESSCODE(+)  '|| chr(10)
                || 'AND P1.MODULE(+)=''SALES''  '|| chr(10)
                || 'AND S.COMPANYCODE=P2.COMPANYCODE(+)  '|| chr(10)
                || 'AND S.BUYERCODE=P2.PARTYCODE(+)  '|| chr(10)
                || 'AND S.ADDRESSCODE=P2.ADDRESSCODE(+)  '|| chr(10)
                || 'AND P2.MODULE(+)=''SALES''  '|| chr(10)
                || 'AND S.COMPANYCODE='''||p_companycode||'''  '|| chr(10)
                || 'AND S.DIVISIONCODE='''||p_divisioncode||'''  '|| chr(10)
                || 'AND S.PROFORMAINVDATE>=TO_DATE('''||p_dofrom||''',''DD/MM/YYYY'')  '|| chr(10)
                || 'AND S.PROFORMAINVDATE<=TO_DATE('''||p_doto||''',''DD/MM/YYYY'')  '|| chr(10);
                if p_challan is not null then
                    lv_sqlstr := lv_sqlstr || ' AND S.CHANNELCODE IN ('||p_challan||') '|| chr(10);
                end if;
                if p_dono is not null then
                    lv_sqlstr := lv_sqlstr || ' AND S.PROFORMAINVNO IN ('||p_dono||') '|| chr(10);
                end if;
                lv_sqlstr := lv_sqlstr || 'ORDER BY S.PROFORMAINVNO, T.SRL, S.PROFORMASERIALNO '|| chr(10);
    
    --DBMS_OUTPUT.PUT_LINE(lv_sqlstr);
    execute immediate lv_sqlstr;
    
    UPDATE gtt_salesdoprintgst SET EX10=
    (SELECT  SUBSTR (   RTRIM (
                                        XMLAGG(XMLELEMENT (
                                                  E,
                                                     TEXT ||' '
                                                  || CHR(10)
                                               )).EXTRACT ('//text()'),
                                        ','
                                     ),
                                     1,
                                     4000
                                  )
                                 FROM(
                                    SELECT TEXT
                                    FROM STATURITYTEXT
                                    WHERE COMPANYCODE = P_COMPANYCODE
                                      AND DIVISIONCODE = P_DIVISIONCODE
                                      AND REPORTTAG='DO TERMS AND CONDITIONS'
                                    ORDER BY SERIALNO 
                                    )
    );
--    UPDATE   
--    gtt_salesdoprintgst 
--    SET EX10=  DECODE(SUBSTR(RTRIM(EX10),-3),',',SUBSTR(RTRIM(EX10), 3, LENGTH(RTRIM(EX10)) - 3),RTRIM(EX10)) ;
--    
     UPDATE   
    gtt_salesdoprintgst 
    SET EX10=  SUBSTR(RTRIM(EX10),1,LENGTH(RTRIM(EX10)) - 2);
    
    
--    
--    UPDATE gtt_salesdoprintgst SET ex10 =  '1. Whenever goods are dispatched out of West Bengal, please furnish Consignment Note.'||chr(10)
--                                        || '2. Vehicle should have valid documents.'||chr(10)
--                                        || '3. Vehicle much reach mill before 12:00 noon. for same day loading.'||chr(10)
--                                        || '4. Mill remain closed on ''Sunday'' for dispatch.'
--where 1=1;  

        update gtt_salesdoprintgst a set (EX15,EX16,EX17)
        =
        (
        select TOTALWEIGHT,PACKSHEETWEIGHT,GROSSWEIGHT from(
        select PROFORMAINVNO,TEXT,sum(nvl(TOTALWEIGHT,0))TOTALWEIGHT,sum(nvl(PACKSHEETWEIGHT,0))PACKSHEETWEIGHT,sum(nvl(GROSSWEIGHT,0))GROSSWEIGHT 
        from gtt_salesdoprintgst 
        group by PROFORMAINVNO,TEXT
        )b
        where a.PROFORMAINVNO=b.PROFORMAINVNO
          and a.TEXT=b.TEXT
        );                                      
                                            
end;
/
