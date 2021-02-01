CREATE OR REPLACE PROCEDURE DALHOUSIE_WEB."PROC_PROFORMAINVDOCUMENT_LDW" 
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_proformainvno varchar2,
    p_logopath varchar2
)
as 
    lv_sqlstr           varchar2(10000);
begin
   delete from gtt_proformainvdocument_ldw;
   lv_sqlstr :=     'insert into gtt_proformainvdocument_ldw'|| chr(10)
                 || 'SELECT /*+ORDERED */ P.PROFORMAINVNO LORRYPASSNO, P.PROFORMAINVDATE LORRYPASSDATE, P.BUYERCODE, P.BUYERNAME, PA.PARTYADDRESS, PA.VATNO PARTYVATNO, PA.TINNO PARTYTINNO, ' || chr(10)
                 || '       PA.CSTNO PARTYCSTNO, P.QUALITYCODE, P.QUALITYMANUALDESC, P.NOOFPACKINGUNIT, P.PACKSTYLENAME,CASE WHEN MEASUREUNIT=''KGS'' THEN ROUND(P.TOTALWEIGHT/1000,3) ELSE ROUND(P.TOTALWEIGHT,3)  END ||'' MT'' NETWEIGHT, P.TOTALQUANTITY, P.MEASURENAME, ' || chr(10)
                 || '       NULL INVOICENO, NULL INVOICEDATE, P.SHIPPINGINSNO, P.SHIPPINGINSDATE, P.SAUDANO, P.SAUDADATE, CONTRACTNO, CONTRACTDATE, NULL DUEDATE, ' || chr(10)
                 || '       D.GSTNNO EX1, PA.GSTNNO EX2, NULL EX3, NULL EX4, NULL EX5, NULL EX6, NULL EX7, NULL EX8, NULL EX9, NULL EX10, '''|| p_logopath ||''' LOGOPATH, ' || chr(10)
                 || '       C.COMPANYNAME, C.COMPANYADDRESS, C.COMPANYADDRESS1, C.COMPANYADDRESS2, C.COMPANYADDRESS3, C.COMPANYFAX, C.COMPANYPHONE, C.CINNO, ' || chr(10)
                 || '       D.DIVISIONNAME, D.DIVISIONADDRESS, D.DIVISIONADDRESS1, D.DIVISIONADDRESS2, D.DIVISIONPHONE, D.DIVISIONFAX ' || chr(10)
                 || '   FROM SALESPROFORMAINVOICEVIEW P, COMPANYMAST C, PARTYMASTER PA, DIVISIONMASTER D, ' || chr(10)
                 || '       ( '|| chr(10)
                 || '        SELECT PROFORMAINVNO, SAUDANO||''/''||SUBSTR(TO_CHAR(SRL,''09''),2,2) SAUDANO '|| chr(10)
                 || '          FROM ( '|| chr(10)
                 || '                SELECT PROFORMAINVNO, SAUDANO, row_number() over(partition by SAUDANO order by PROFORMAINVDATE) SRL '|| chr(10)
                 || '                  FROM SALESPROFORMAINVOICEVIEW '|| chr(10)
                 || '                 WHERE COMPANYCODE='''|| p_companycode ||''' '|| chr(10)
                 || '                   AND DIVISIONCODE='''||p_divisioncode||''' '|| chr(10)
                 || '                 ORDER BY SAUDANO, PROFORMAINVDATE, PROFORMAINVNO '|| chr(10)
                 || '               ) '|| chr(10)
                 || '        ) X '|| chr(10)
                 || '  WHERE P.COMPANYCODE = '''|| p_companycode ||''' '|| chr(10)
                 || '    AND P.DIVISIONCODE = '''||p_divisioncode||''' '|| chr(10)
                 || '    AND P.COMPANYCODE=C.COMPANYCODE ' || chr(10)
                 || '    AND P.DIVISIONCODE=D.DIVISIONCODE ' || chr(10)
                 || '    AND P.COMPANYCODE=PA.COMPANYCODE(+) ' || chr(10)
                 || '    AND P.BUYERCODE=PA.PARTYCODE(+) ' || chr(10)
                 || '    AND PA.MODULE=''SALES'' ' || chr(10)
                 || '    AND P.PROFORMAINVNO=X.PROFORMAINVNO ' || chr(10);
                 if p_proformainvno is not null then
                     lv_sqlstr := lv_sqlstr || '   AND P.PROFORMAINVNO in ('|| p_proformainvno ||')' || chr(10);
                 end if;
                 lv_sqlstr := lv_sqlstr || '  ORDER BY P.PROFORMAINVNO ' || chr(10);
                 
   execute immediate lv_sqlstr;
   --dbms_output.put_line(' lv_sqlstr : ' ||lv_sqlstr);
end;
/
