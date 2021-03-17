DROP PROCEDURE NJMCL_WEB.PRCWPSSLTWKLY_BF_MAINSAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.prcWpssltWKLY_Bf_MainSave
is
lv_cnt                  number;
lv_cnt2                 number;
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
--lv_SECTIONCODE          varchar2(10) :='';
lv_MaxPAYMENTdate         date;


LV_FEDateExist  VARCHAR2(10) := '';
lv_AVAILABLE_STL_DAYS  number :=0;
lv_inc_rows  number :=0;

lv_Weekly_off  VARCHAR2(50) := '';   
lv_Min_Year             VARCHAR2(10) := ''; 

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
    
    select distinct CompanyCode, DivisionCode, YearCode, TO_CHAR(documentdate,'DD/MM/YYYY'), operationmode
    into lv_CompanyCode, lv_DivisionCode, lv_YearCode, lv_DOCUMENTDATE, lv_OperationMode
    from GBL_WPSSTLENTRY;
    
    SELECT DAYOFFDAY 
    INTO lv_Weekly_off 
    FROM WPSWORKERMAST
    WHERE COMPANYCODE=lv_CompanyCode
    AND DIVISIONCODE=lv_DivisionCode
    AND WORKERSERIAL=lv_Master.WORKERSERIAL;
    
    --lv_error_remark := 'lv_Weekly_off~'||lv_Weekly_off;
    --raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    
    if lv_Weekly_off is null then
        lv_error_remark := 'Validation Failure : [Weekly off Day Not Found in WPSWORKERMAST ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if; 
    
     FOR C22 
                IN(
                SELECT DOCUMENTNO,PAYMENTDATE,WORKERSERIAL,LEAVEDATE,DAY 
                FROM GBL_WPSSTLENTRYDETAILS
                where COMPANYCODE=lv_Master.COMPANYCODE
                AND DIVISIONCODE=lv_Master.DIVISIONCODE
                AND TOKENNO=lv_Master.TOKENNO
                  )
            LOOP 
                IF TRIM(lv_Weekly_off)=TRIM(C22.DAY) THEN
                UPDATE GBL_WPSSTLENTRYDETAILS
                 SET LEAVEDAYS=0,LEAVEHOURS=0
                WHERE   COMPANYCODE=lv_Master.COMPANYCODE
                    AND DIVISIONCODE=lv_Master.DIVISIONCODE  
                    AND PAYMENTDATE = C22.PAYMENTDATE
                    AND WORKERSERIAL=C22.WORKERSERIAL
                    AND LEAVEDATE=C22.LEAVEDATE;  
                END IF;
            END LOOP;
    
    UPDATE GBL_WPSSTLENTRY SET PAYMENTDATE=DOCUMENTDATE;

    UPDATE GBL_WPSSTLENTRYDETAILS SET STLSERIALNO=lv_Master.STLSERIALNO;
    
    UPDATE GBL_WPSSTLENTRYDETAILS SET DOCUMENTDATE=TO_DATE(lv_DOCUMENTDATE,'DD/MM/YYYY');
    
    UPDATE GBL_WPSSTLENTRY SET SHIFTCODE=case when SHIFTCODE='A' THEN '1' 
                                               when SHIFTCODE='B' THEN '2'
                                               when SHIFTCODE='C' THEN '3'
                                           END ;
                                           
    UPDATE GBL_WPSSTLENTRYDETAILS SET SHIFTCODE=case when SHIFTCODE='A' THEN '1' 
                                               when SHIFTCODE='B' THEN '2'
                                               when SHIFTCODE='C' THEN '3'
                                           END ;

  if nvl(lv_OperationMode,'NA') = 'A' then
 
      if lv_cnt > 0 then
            select COUNT(*) INTO lv_cnt
            from WPSSTLENTRYDETAILS
            where companycode = lv_Master.CompanyCode
              and divisioncode = lv_Master.DivisionCode
              and YearCode = lv_Master.YearCode;
            if lv_cnt > 0 then
                select max(PAYMENTDATE)
                into lv_MaxPAYMENTdate
                from WPSSTLENTRYDETAILS
                where companycode = lv_Master.CompanyCode
                  and divisioncode = lv_Master.DivisionCode
                  and YearCode = lv_Master.YearCode;
            
                if lv_Master.DOCUMENTDATE < lv_MaxPAYMENTdate then
                    lv_error_remark := 'Validation Failure : [Last STL Entry Date was : ' || to_char(lv_MaxPAYMENTdate,'dd/mm/yyyy') || ' You can not save any STL before this date.]';
                    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
                end if;     
            END IF;
--            if TRUNC(lv_Master.DOCUMENTDATE) > TRUNC(SYSDATE) then
--                lv_error_remark := 'Validation Failure : STL Entry Date cannot be greater than current date.['|| trunc(sysdate) ||'.]';
--                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
--            end if;

        end if;
      


        SELECT COUNT(*) INTO lv_cnt FROM WPSSTLENTRYDETAILS 
        WHERE COMPANYCODE=lv_Master.COMPANYCODE
        AND DIVISIONCODE=lv_Master.DIVISIONCODE
        AND WORKERSERIAL=lv_Master.WORKERSERIAL
        AND LEAVEDATE BETWEEN lv_Master.STLFROMDATE AND lv_Master.STLTODATE;
        
         --lv_error_remark := 'lv_cnt'||lv_cnt;
          --  raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        
        if lv_cnt > 0 then
            lv_error_remark := 'Validation Failure : [STL Date Exist for this range in STL Details.]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;
 END IF;
  
  
    SELECT count(*)
    into lv_cnt FROM WPSSECTIONMAST 
    WHERE companycode=lv_Master.COMPANYCODE
      AND DIVISIONCODE=lv_Master.DIVISIONCODE
      and DEPARTMENTCODE=lv_Master.DEPARTMENTCODE
      and SECTIONCODE=lv_Master.SECTIONCODE;
      if lv_cnt = 0 then
            lv_error_remark := 'Validation Failure : [Section Does not Exist in this Department.]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
      end if;
      
  
       
        

        select count(*)
        into lv_cnt
        from GBL_WPSSTLENTRY;  
   

    
    
    SELECT FINALISEDANDLOCK into LV_FEDateExist 
    FROM WPSWAGEDPERIODDECLARATION WHERE FORTNIGHTSTARTDATE=(select FORTNIGHTSTARTDATE from GBL_WPSSTLENTRY)
    AND DIVISIONCODE = lv_Master.DIVISIONCODE;
    
     select count(*)
    into lv_cnt2
    from GBL_WPSSTLENTRYDETAILS;
    
    
   -- select SECTIONCODE into lv_SECTIONCODE from WPSWORKERMAST WHERE WORKERSERIAL=lv_Master.WORKERSERIAL AND DIVISIONCODE = lv_Master.DIVISIONCODE;
    
    
    if LV_FEDateExist = 'Y' then
        lv_error_remark := 'Validation Failure : [Applicable F.E. Date is Finalised and Locked]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
   
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found in STL Entry Details.]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
   

    if lv_OperationMode is null then
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT / VIEW ? ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if; 
    
    if lv_Master.STLHOURS is null or  lv_Master.STLDAYS is null then
        lv_error_remark := 'Validation Failure : [STL Hours/Days should not be blank!]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
     if lv_Master.STLSERIALNO is null then
        lv_error_remark := 'Validation Failure : [Serial No should not be blank!]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    UPDATE GBL_WPSSTLENTRY
       SET TRANSACTIONTYPE ='AVAILED',ADDLESS='LESS'--,/*YEAR=TO_CHAR(FORTNIGHTSTARTDATE,'YYYY'),*/SECTIONCODE=lv_SECTIONCODE
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
            set documentno = lv_DocumentNo,/*YEAR=TO_CHAR(FORTNIGHTSTARTDATE,'YYYY'),*//*SECTIONCODE=lv_SECTIONCODE,*/SECTIONCODE=lv_Master.SECTIONCODE,TRANSACTIONTYPE ='AVAILED',ADDLESS='LESS';
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
                    C1.DATES,1,8,0,YEAR--TO_CHAR(FORTNIGHTENDDATE,'YYYY')
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
    
  If nvl(lv_OperationMode,'NA') = 'A' then
      --Previous Year Balance Update in Year field ........................
     UPDATE GBL_WPSSTLENTRYDETAILS 
     SET YEAR=NULL 
     WHERE 
     COMPANYCODE=lv_Master.COMPANYCODE
     AND DIVISIONCODE=lv_Master.DIVISIONCODE
     AND TOKENNO=lv_Master.TOKENNO;
     
     DELETE FROM GBL_STLBAL;
      PRC_STLBAL_YEARWISE(lv_Master.COMPANYCODE,lv_Master.DIVISIONCODE,TO_CHAR(SYSDATE,'DD/MM/YYYY'),lv_Master.TOKENNO);
      
                            
     FOR C1 
        IN(
            SELECT A.*,ROW_NUMBER() OVER(PARTITION BY WORKERSERIAL order by A.YEAR )SRL  
            FROM GBL_STLBAL A
            WHERE COMPANYCODE = lv_Master.COMPANYCODE
            AND DIVISIONCODE = lv_Master.DIVISIONCODE
            AND TOKENNO = lv_Master.TOKENNO 
            AND STLBAL_DAYS>0
            )
      LOOP

        lv_AVAILABLE_STL_DAYS :=C1.STLBAL_DAYS;                  
        lv_inc_rows :=1;
            FOR C2 
                IN(
                SELECT DOCUMENTNO,PAYMENTDATE,WORKERSERIAL,LEAVEDATE 
                FROM GBL_WPSSTLENTRYDETAILS
                where year is null
                AND COMPANYCODE=lv_Master.COMPANYCODE
                AND DIVISIONCODE=lv_Master.DIVISIONCODE
                AND TOKENNO=lv_Master.TOKENNO
                AND LEAVEDAYS>0
                  )
            LOOP 
                    IF lv_inc_rows<=lv_AVAILABLE_STL_DAYS THEN
                            SELECT COUNT(*) 
                            INTO lv_cnt 
                            FROM GBL_WPSSTLENTRYDETAILS B
                            WHERE  YEAR IS NOT NULL
                            AND B.DOCUMENTNO=C2.DOCUMENTNO
                            AND B.PAYMENTDATE=C2.PAYMENTDATE
                            AND B.WORKERSERIAL=C2.WORKERSERIAL
                            AND B.LEAVEDATE=C2.LEAVEDATE
                            AND B.LEAVEDAYS>0;
                            --lv_error_remark := 'lv_cnt~'||lv_cnt;
                            --raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
                                if lv_cnt=0 then
                                update GBL_WPSSTLENTRYDETAILS set year=C1.year
                                where DOCUMENTNO=C2.DOCUMENTNO
                                and PAYMENTDATE=C2.PAYMENTDATE
                                and WORKERSERIAL=C2.WORKERSERIAL
                                and LEAVEDATE=C2.LEAVEDATE;
                                end if;
                    END IF;
                  lv_inc_rows :=lv_inc_rows+1;
       
            END LOOP;

    END LOOP;
    
    --End of Year Update...........................


        select count(*) into lv_cnt 
        from GBL_WPSSTLENTRYDETAILS;
        
         SELECT MIN(YEAR) 
         INTO  LV_MIN_YEAR
         FROM  GBL_WPSSTLENTRYDETAILS
         WHERE YEAR IS NOT NULL
         AND LEAVEDAYS>0;
    
         UPDATE GBL_WPSSTLENTRYDETAILS SET YEAR=LV_MIN_YEAR
         WHERE  LEAVEDAYS=0 AND YEAR IS NULL;
        
    If lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found in  STL Entry Details.]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    FOR C11 IN(SELECT a.*,ROW_NUMBER() OVER(PARTITION BY companycode order by companycode,LEAVEDATE )SRL FROM GBL_WPSSTLENTRYDETAILS a WHERE  a.LEAVEDAYS>0)
    LOOP 
        if C11.year is null then
            lv_error_remark := 'Validation Failure : [Year should not be blank at line '||c11.SRL || '].';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;
    END LOOP;
  END IF;
    
        
     
                    
    if lv_OperationMode = 'A' then
        insert into SYS_GBL_PROCOUTPUT_INFO
        values (' DOCUMENT ENTRY NUMBER : ' || lv_DocumentNo || ' Dated : ' || lv_DOCUMENTDATE||lv_OFFDAY||lv_Master.STLFROMDATE||lv_Master.STLTODATE);
    end if; 
end;
/


