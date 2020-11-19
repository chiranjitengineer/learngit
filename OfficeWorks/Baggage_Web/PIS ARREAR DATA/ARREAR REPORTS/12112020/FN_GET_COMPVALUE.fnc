CREATE OR REPLACE function BAGGAGE_WEB.fn_get_compvalue
(
    p_compcode varchar2,
    p_divcode varchar2,
    p_yearmonth varchar2,
    p_workerserial varchar2,
    p_componentcode varchar2,
    p_option varchar2, 
    P_ARREAROPTION VARCHAR2 DEFAULT NULL
)
return number
as
lv_result   number:=0;
lv_strsql   varchar2(4000);   
begin
    lv_strsql:='select nvl('||p_componentcode||',0)'|| chr(10); 
    if p_option='MASTER ASSIGNMENT' then
        lv_strsql:=lv_strsql||'  from piscomponentassignment'|| chr(10);
    end if;
    if p_option='PIS COMPONENT REGISTER' then
        
        IF NVL(P_ARREAROPTION,'NA') = 'ARREAR' THEN
            lv_strsql:=lv_strsql||'  from pisarreartransaction'|| chr(10);
        ELSE
            lv_strsql:=lv_strsql||'  from pispaytransaction'|| chr(10);
        END IF;
    end if;
    lv_strsql:=lv_strsql||' where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' '|| chr(10);
    if p_option='MASTER ASSIGNMENT' then
        lv_strsql:=lv_strsql||'   and transactiontype=''ASSIGNMENT'''|| chr(10);
    end if;
    lv_strsql:=lv_strsql||'   and yearmonth='''||p_yearmonth||''' '|| chr(10);
    lv_strsql:=lv_strsql||'   and workerserial='''||p_workerserial||''' ';
    
    IF NVL(P_ARREAROPTION,'NA') = 'ARREAR' THEN
        lv_strsql:=lv_strsql||'   and transactiontype=''ARREAR'''|| chr(10);
    END IF;
--    --DBMS_OUTPUT.PUT_LINE(lv_strsql);
    begin
        execute immediate lv_strsql into lv_result;
    exception when others then null;
    end;
    return lv_result;
end;
/
