DROP PROCEDURE NJMCL_WEB.PRCWPSADJHOURS_BF_MAINSAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPSADJHOURS_BF_MAINSAVE" 
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_WPSATTENDANCEDAYWISE%rowtype;
lv_DocumentNo           varchar2(100) := '';
lv_MaxDocumentDate      date;
lv_CompanyCode          varchar2(10) :='';
lv_DivisionCode         varchar2(10) :='';
lv_YearCode             varchar2(9) :='';
lv_DocumentDate         varchar2(10) :='';
lv_OperationMode        varchar2(1) :='';
lv_OccuCode             varchar2(10) :='';

begin
    lv_result:='#SUCCESS#';
    --Master
    select count(*)
    into lv_cnt
    from GBL_WPSATTENDANCEDAYWISE;
   
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found in Raw Jute Tenacity Test]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    select distinct CompanyCode, DivisionCode, YearCode, TO_CHAR(dateofattendance,'DD/MM/YYYY'), operationmode
    into lv_CompanyCode, lv_DivisionCode, lv_YearCode, lv_DocumentDate, lv_OperationMode
    from GBL_WPSATTENDANCEDAYWISE;

    if lv_OperationMode is null then
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT / VIEW ? ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;    

-----------------------  Auto Number

    if nvl(lv_OperationMode,'NA') = 'A' then
        select count(*)
        into lv_cnt
        from WPSATTENDANCEDAYWISE
        where companycode = lv_CompanyCode
          and divisioncode = lv_DivisionCode
          and YearCode = lv_YearCode;

        /*if lv_cnt > 0 then
            select max(dateofattendance)
            into lv_MaxDocumentDate
            from WPSATTENDANCEDAYWISE
            where companycode = lv_CompanyCode
              and divisioncode = lv_DivisionCode
              and YearCode = lv_YearCode;
            if TO_DATE(lv_DocumentDate,'DD/MM/YYYY') < lv_MaxDocumentDate then
                lv_error_remark := 'Validation Failure : [Last Date of Attendance was : ' || 

to_char(lv_MaxDocumentDate,'dd/mm/yyyy') || ' You can not save any Attandance before this date.]';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 

'COMMON',6,lv_error_remark));
            end if;     
        end if;*/

        select fn_autogen_params(lv_CompanyCode,lv_DivisionCode,lv_YearCode,'WPS ATTANDANCE DAY WISE',lv_DocumentDate) 
        into lv_DocumentNo
        from dual;
            
        update GBL_WPSATTENDANCEDAYWISE
        set bookno = lv_DocumentNo;
    end if;
    
    select *
    into lv_Master
    from GBL_WPSATTENDANCEDAYWISE
    WHERE ROWNUM=1;
    
    if nvl(lv_Master.operationmode,'NA') <> 'D' then
     FOR C1 IN (
           /*     SELECT TO_DATE(lv_Master.DATEOFATTENDANCE,'DD/MM/RRRR') DATEOFATTENDANCE,
                CASE WHEN 

TO_DATE(lv_Master.DATEOFATTENDANCE,'DD/MM/RRRR')>=TO_DATE('01/'||SUBSTR(lv_Master.DATEOFATTENDANCE,4),'DD/MM/RRRR') AND
                     

TO_DATE(lv_Master.DATEOFATTENDANCE,'DD/MM/RRRR')<=TO_DATE('16/'||SUBSTR(lv_Master.DATEOFATTENDANCE,4),'DD/MM/RRRR') THEN
                            TO_DATE('01/'||SUBSTR(lv_Master.DATEOFATTENDANCE,4),'DD/MM/RRRR')
                WHEN 

TO_DATE(lv_Master.DATEOFATTENDANCE,'DD/MM/RRRR')>=TO_DATE('16/'||SUBSTR(lv_Master.DATEOFATTENDANCE,4),'DD/MM/RRRR') AND
                     

TO_DATE(lv_Master.DATEOFATTENDANCE,'DD/MM/RRRR')<=LAST_DAY(TO_DATE(lv_Master.DATEOFATTENDANCE,'DD/MM/RRRR')) THEN
                            TO_DATE('16/'||SUBSTR(lv_Master.DATEOFATTENDANCE,4),'DD/MM/RRRR')
                END FORTNIGHTSTARTDATE, 
                CASE WHEN 

TO_DATE(lv_Master.DATEOFATTENDANCE,'DD/MM/RRRR')>=TO_DATE('01/'||SUBSTR(lv_Master.DATEOFATTENDANCE,4),'DD/MM/RRRR') AND
                     

TO_DATE(lv_Master.DATEOFATTENDANCE,'DD/MM/RRRR')<=TO_DATE('16/'||SUBSTR(lv_Master.DATEOFATTENDANCE,4),'DD/MM/RRRR') THEN
                            TO_DATE('15/'||SUBSTR(lv_Master.DATEOFATTENDANCE,4),'DD/MM/RRRR')
                WHEN 

TO_DATE(lv_Master.DATEOFATTENDANCE,'DD/MM/RRRR')>=TO_DATE('16/'||SUBSTR(lv_Master.DATEOFATTENDANCE,4),'DD/MM/RRRR') AND
                     

TO_DATE(lv_Master.DATEOFATTENDANCE,'DD/MM/RRRR')<=LAST_DAY(TO_DATE(lv_Master.DATEOFATTENDANCE,'DD/MM/RRRR')) THEN
                            LAST_DAY(TO_DATE(lv_Master.DATEOFATTENDANCE,'DD/MM/RRRR'))
                END FORTNIGHTENDDATE
                ,LAST_DAY(TO_DATE('22/01/2016','DD/MM/RRRR')) LASTDATE                      
                FROM DUAL */
                SELECT FORTNIGHTSTARTDATE,FORTNIGHTENDDATE
                          FROM WPSWAGEDPERIODDECLARATION
                         WHERE TO_DATE(lv_Master.DATEOFATTENDANCE,'DD/MM/RRRR') BETWEEN FORTNIGHTSTARTDATE AND FORTNIGHTENDDATE 
                
                
                
              )
        LOOP
            UPDATE GBL_WPSATTENDANCEDAYWISE
               SET FORTNIGHTSTARTDATE=C1.FORTNIGHTSTARTDATE,
                   FORTNIGHTENDDATE=C1.FORTNIGHTENDDATE;
        END LOOP;  
    end if;
    
    UPDATE GBL_WPSATTENDANCEDAYWISE
     SET SPELLTYPE='SPELL 1';
 
     SELECT Max(OCCUPATIONCODE) into lv_OccuCode
     from WPSOCCUPATIONMAST
     WHERE DEPARTMENTCODE IN(SELECT DISTINCT DEPARTMENTCODE FROM GBL_WPSATTENDANCEDAYWISE); 
    
    UPDATE GBL_WPSATTENDANCEDAYWISE
     SET OCCUPATIONCODE = lv_OccuCode;
      
    
    if lv_OperationMode = 'A' then
        insert into SYS_GBL_PROCOUTPUT_INFO
        values (' Attandance Book Number : ' || lv_DocumentNo || ' Dated : ' || lv_DocumentDate);
    end if; 
end;
/


