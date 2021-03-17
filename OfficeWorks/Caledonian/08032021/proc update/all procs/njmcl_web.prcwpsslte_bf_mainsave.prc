DROP PROCEDURE NJMCL_WEB.PRCWPSSLTE_BF_MAINSAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.prcWpssltE_Bf_MainSave
is
lv_cnt                  number;
lv_cnt2                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_WPSSTLENTRY%rowtype;
lv_DocumentNo           varchar2(100) := '';
lv_MaxDocumentDate      date;
lv_CompanyCode          varchar2(10) :='';
lv_DivisionCode         varchar2(10) :='';
lv_YearCode             varchar2(9) :='';
lv_DOCUMENTDATE         varchar2(10) :='';
lv_OperationMode        varchar2(1) :='';
lv_OFFDAY               varchar2(10) :='';
LV_FORTNIGHTAPPLICABLEDATE  VARCHAR2(10) := '';
lv_SECTIONCODE          varchar2(10) :='';


LV_FEDateExist  VARCHAR2(10) := '';

begin
    lv_result:='#SUCCESS#';
    --Master
    select count(*)
    into lv_cnt
    from GBL_WPSSTLENTRY;
    
    select *
    into lv_Master
    from GBL_WPSSTLENTRY
    WHERE ROWNUM<=1;
    
    
    SELECT FINALISEDANDLOCK into LV_FEDateExist 
    FROM WPSWAGEDPERIODDECLARATION WHERE FORTNIGHTSTARTDATE=(select FORTNIGHTSTARTDATE from GBL_WPSSTLENTRY)
    AND DIVISIONCODE = lv_Master.DIVISIONCODE;
    
     select count(*)
    into lv_cnt2
    from GBL_WPSSTLENTRYDETAILS;
    
    
    select SECTIONCODE into lv_SECTIONCODE from WPSWORKERMAST WHERE WORKERSERIAL=lv_Master.WORKERSERIAL AND DIVISIONCODE = lv_Master.DIVISIONCODE;
    
    
    if LV_FEDateExist = 'Y' then
        lv_error_remark := 'Validation Failure : [Applicable F.E. Date is Finalised and Locked]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
   
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found in Production Entry Count CV-MR entry]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    select distinct CompanyCode, DivisionCode, YearCode, TO_CHAR(documentdate,'DD/MM/YYYY'), operationmode
    into lv_CompanyCode, lv_DivisionCode, lv_YearCode, lv_DOCUMENTDATE, lv_OperationMode
    from GBL_WPSSTLENTRY;

    if lv_OperationMode is null then
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT / VIEW ? ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if; 
    
    if lv_Master.STLHOURS is null or  lv_Master.STLDAYS is null then
        lv_error_remark := 'Validation Failure : [STL Hours/Days should not be blank!]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    UPDATE GBL_WPSSTLENTRY
       SET TRANSACTIONTYPE ='AVAILED',ADDLESS='LESS',YEAR=TO_CHAR(FORTNIGHTSTARTDATE,'YYYY'),SECTIONCODE=lv_SECTIONCODE
     WHERE LEAVECODE='STL';
    
    FOR C1 IN (
                SELECT FORTNIGHTSTARTDATE,FORTNIGHTENDDATE
                  FROM WPSWAGEDPERIODDECLARATION
                 WHERE TO_DATE(lv_Master.FORTNIGHTSTARTDATE,'DD/MM/RRRR') BETWEEN FORTNIGHTSTARTDATE AND FORTNIGHTENDDATE
                 AND DIVISIONCODE = lv_Master.DIVISIONCODE
              )
        LOOP
            UPDATE GBL_WPSSTLENTRY
               SET FORTNIGHTSTARTDATE=C1.FORTNIGHTSTARTDATE,
                   FORTNIGHTENDDATE=C1.FORTNIGHTENDDATE;

        END LOOP;     

-----------------------  Auto Number

    if nvl(lv_OperationMode,'NA') = 'A' then
        SELECT TO_CHAR(TO_DATE(''||lv_Master.FORTNIGHTSTARTDATE||'','DD/MM/RRRR') ,'DD/MM/YYYY')
          INTO LV_FORTNIGHTAPPLICABLEDATE
          FROM DUAL;
        IF lv_Master.LEAVECODE ='STL' THEN
               select fn_autogen_params(lv_CompanyCode,lv_DivisionCode,lv_YearCode,'WPS STL ENTRY',LV_FORTNIGHTAPPLICABLEDATE)
                into lv_DocumentNo
                from dual;
        ELSIF lv_Master.LEAVECODE ='OL' THEN            
             select fn_autogen_params(lv_CompanyCode,lv_DivisionCode,lv_YearCode,'WPS OL ENTRY',LV_FORTNIGHTAPPLICABLEDATE) 
            into lv_DocumentNo
            from dual;
         ELSIF lv_Master.LEAVECODE ='CS' THEN            
             select fn_autogen_params(lv_CompanyCode,lv_DivisionCode,lv_YearCode,'WPS CS ENTRY',LV_FORTNIGHTAPPLICABLEDATE) 
            into lv_DocumentNo
            from dual;
        END IF;
            
        update GBL_WPSSTLENTRY
        set documentno = lv_DocumentNo;
        
        
        if lv_cnt2 > 0 then
            update GBL_WPSSTLENTRYDETAILS
            set documentno = lv_DocumentNo,YEAR=TO_CHAR(FORTNIGHTSTARTDATE,'YYYY'),SECTIONCODE=lv_SECTIONCODE,TRANSACTIONTYPE ='AVAILED',ADDLESS='LESS';
        end if;
        
    end if;
    
    
   if nvl(lv_OperationMode,'NA') = 'M' then
        DELETE FROM WPSLEAVEAPPLICATION
        WHERE COMPANYCODE=lv_Master.COMPANYCODE
          AND DIVISIONCODE=lv_Master.DIVISIONCODE  
          AND LEAVEAPPLIEDON = lv_Master.DOCUMENTDATE
          AND WORKERSERIAL=lv_Master.WORKERSERIAL;
    end if;
    
     FOR C1 IN (
                    SELECT TO_DATE(DATES,'DD/MM/RRRR') DATES FROM
                    (
                        WITH d AS
                        (
                        SELECT TRUNC ( TO_DATE( lv_Master.STLFROMDATE,'DD/MM/YYYY')) -1  AS dt
                        FROM dual
                        )
                        SELECT dt + LEVEL  DATES
                        FROM d
                        CONNECT BY LEVEL <=  ( TO_DATE(lv_Master.STLTODATE,'DD/MM/YYYY') - TO_DATE( lv_Master.STLFROMDATE,'DD/MM/YYYY') + 1 )
                    )
              )
     LOOP
        INSERT INTO WPSLEAVEAPPLICATION
                    (COMPANYCODE, DIVISIONCODE, YEARCODE, WORKERSERIAL, TOKENNO, WOKERCATEGORYCODE, 
                    LEAVECODE, LEAVEAPPLIEDON, LEAVEFROM, LEAVETO, LEAVESANCTIONEDON, 
                    LEAVEDATE,LEAVEDAYS, LEAVEHOURS, LEAVEENCASHED, CALENDARYEAR)
             SELECT COMPANYCODE, DIVISIONCODE, YEARCODE,WORKERSERIAL, TOKENNO,WORKERCATEGORYCODE,
                    LEAVECODE,DOCUMENTDATE,STLFROMDATE,STLTODATE,/*DOCUMENTDATE*/ FORTNIGHTENDDATE,
                    C1.DATES,1,8,0,TO_CHAR(FORTNIGHTENDDATE,'YYYY')
               FROM GBL_WPSSTLENTRY;
                       
     END LOOP;  
        
    UPDATE WPSLEAVEAPPLICATION 
       SET LEAVEDAYS=0,LEAVEHOURS=0
     WHERE COMPANYCODE=lv_Master.COMPANYCODE
       AND DIVISIONCODE=lv_Master.DIVISIONCODE  
       AND LEAVEAPPLIEDON = lv_Master.DOCUMENTDATE
       AND WORKERSERIAL=lv_Master.WORKERSERIAL
       AND EXISTS --LEAVEDATE IN
       (   SELECT HOLIDAYDATE
             FROM WPSHOLIDAYMASTER 
            WHERE COMPANYCODE=lv_Master.COMPANYCODE
              AND DIVISIONCODE=lv_Master.DIVISIONCODE  
              AND ISPAID='Y'
              AND WPSLEAVEAPPLICATION.LEAVEDATE=WPSHOLIDAYMASTER.HOLIDAYDATE
       );
       
      SELECT TRIM(DAYOFFDAY)
        INTO lv_OFFDAY
        FROM WPSWORKERMAST 
       WHERE COMPANYCODE=lv_Master.COMPANYCODE
         AND DIVISIONCODE=lv_Master.DIVISIONCODE  
         AND WORKERSERIAL=lv_Master.WORKERSERIAL;
       
       UPDATE WPSLEAVEAPPLICATION 
          SET LEAVEDAYS=0,LEAVEHOURS=0
        WHERE COMPANYCODE=lv_Master.COMPANYCODE
          AND DIVISIONCODE=lv_Master.DIVISIONCODE  
          AND LEAVEAPPLIEDON = lv_Master.DOCUMENTDATE
          AND WORKERSERIAL=lv_Master.WORKERSERIAL
          AND EXISTS 
            (
            SELECT TO_DATE(DATES,'DD/MM/YYYY') DATES  FROM --count(TO_CHAR(DATES,'DAY'))
            (
            WITH d AS
            (
            SELECT TRUNC ( TO_DATE( lv_Master.STLFROMDATE,'DD/MM/YYYY')) -1  AS dt
            FROM dual
            )
            SELECT dt + LEVEL  DATES
            FROM d
            CONNECT BY LEVEL <=  ( TO_DATE(lv_Master.STLTODATE,'DD/MM/YYYY') - TO_DATE( lv_Master.STLFROMDATE,'DD/MM/YYYY') + 1 )
            )
            where TO_DATE(WPSLEAVEAPPLICATION.LEAVEDATE,'DD/MM/YYYY')=TO_DATE(DATES,'DD/MM/YYYY')
              --  AND trim(trim(TO_CHAR(DATES,'DAY'))) = UPPER(TRIM(lv_OFFDAY))
              AND ltrim(trim(TO_CHAR(WPSLEAVEAPPLICATION.LEAVEDATE,'DAY'))) = UPPER(LTRIM(TRIM(lv_OFFDAY)))
       );
    
    if lv_OperationMode = 'A' then
        insert into SYS_GBL_PROCOUTPUT_INFO
        values (' DOCUMENT ENTRY NUMBER : ' || lv_DocumentNo || ' Dated : ' || lv_DOCUMENTDATE||lv_OFFDAY||lv_Master.STLFROMDATE||lv_Master.STLTODATE);
    end if; 
end;
/


