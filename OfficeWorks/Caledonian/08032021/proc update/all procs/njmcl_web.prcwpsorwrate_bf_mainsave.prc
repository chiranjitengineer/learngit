DROP PROCEDURE NJMCL_WEB.PRCWPSORWRATE_BF_MAINSAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPSORWRATE_BF_MAINSAVE" 
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_WPSWORKORDERWISERATEMASTER%rowtype;
lv_DocumentNo           varchar2(100) := '';
lv_MaxDocumentDate      date;
lv_CompanyCode          varchar2(10) :='';
lv_DivisionCode         varchar2(10) :='';
lv_YearCode             varchar2(9) :='';
lv_DocumentDate         varchar2(10) :='';
lv_OperationMode        varchar2(1) :='';

begin
    lv_result:='#SUCCESS#';
    --Master
    select count(*)
    into lv_cnt
    from GBL_WPSWORKORDERWISERATEMASTER;
   
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found in Leave Entry]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    select distinct CompanyCode, DivisionCode, YearCode, TO_CHAR(orderdate,'DD/MM/YYYY'), operationmode
    into lv_CompanyCode, lv_DivisionCode, lv_YearCode, lv_DocumentDate, lv_OperationMode
    from GBL_WPSWORKORDERWISERATEMASTER;

    if lv_OperationMode is null then
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT / VIEW ? ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;    

-----------------------  Auto Number

    if nvl(lv_OperationMode,'NA') = 'A' then
        select count(*)
        into lv_cnt
        from WPSWORKORDERWISERATEMASTER
        where companycode = lv_CompanyCode
          and divisioncode = lv_DivisionCode
          and YearCode = lv_YearCode;

        if lv_cnt > 0 then
            select max(ORDERDATE)
            into lv_MaxDocumentDate
            from WPSWORKORDERWISERATEMASTER
            where companycode = lv_CompanyCode
              and divisioncode = lv_DivisionCode
              and YearCode = lv_YearCode;
            if TO_DATE(lv_DocumentDate,'DD/MM/YYYY') < lv_MaxDocumentDate then
                lv_error_remark := 'Validation Failure : [Last Transaction Date was : ' || to_char(lv_MaxDocumentDate,'dd/mm/yyyy') || ' You can not save any Order before this date.]';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            end if;     
        end if;

        select fn_autogen_params(lv_CompanyCode,lv_DivisionCode,lv_YearCode,'WPS_ORWRATEENTRY',lv_DocumentDate) 
        into lv_DocumentNo
        from dual;
            
        update GBL_WPSWORKORDERWISERATEMASTER
        set ORDERNO = lv_DocumentNo;
    end if;
    
    if lv_OperationMode = 'A' then
        insert into SYS_GBL_PROCOUTPUT_INFO
        values (' ORDER NUMBER : ' || lv_DocumentNo || ' Dated : ' || lv_DocumentDate);
    end if; 
end;
/


