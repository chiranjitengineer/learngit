DROP PROCEDURE NJMCL_WEB.PROC_WPS_STL_IMPORT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPS_STL_IMPORT (P_COMPCODE VARCHAR2,
                                                       P_DIVCODE VARCHAR2,
                                                       P_YEARCODE VARCHAR2,
                                                       P_PAYMENTDATE VARCHAR2,
                                                       P_OVERWRITE_DATA_EXIST VARCHAR2 DEFAULT 'N')


AS 

   lv_cnt                  number;
   lv_row_cnt              number;
   lv_result               varchar2(10);
   lv_error_remark         varchar2(4000) := '' ;
    
   LV_WORKERSERIAL varchar2(15);
   LV_WORKERNAME varchar2(100);
   LV_WORKERCATEGORYCODE varchar2(10);
   LV_DEPARTMENTCODE varchar2(10);
   LV_SECTIONCODE varchar2(10);
   LV_DEPARTMENTNAME varchar2(50);
   LV_OCCUPATIONCODE varchar2(10);
   lv_MinOcpCode     varchar2(10);   
   LV_SHIFTCODE varchar2(1);
   lv_DATE DATE;
   lv_IsSanction   varchar2(1) := '';
   lv_LeaveDays    number(5) := 0;
   
   lv_NoofHoursInday  number(5) := 0;
   lv_DY    number(5) := 0;
    
   lv_DocumentNo           varchar2(100) := '';
   lv_FortnightStartDate   VARCHAR2(10) := '';
   lv_FortnightEndDate     VARCHAR2(10) := '';
   lv_OFFDAY               varchar2(10) :='';
   LV_FORTNIGHTAPPLICABLEDATE  VARCHAR2(10) := '';
   lv_LASTMAX_DATE DATE;
BEGIN

lv_result:='#SUCCESS#';

    if P_PAYMENTDATE is null then
        lv_error_remark := 'Validation Failure : [Payment Date Cannot be blank.]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    select count(*)
    into lv_cnt
    from WPSSTLRAWDATA
    WHERE 1=1--COMPANYCODE=P_COMPCODE AND DIVISIONCODE=P_DIVCODE 
    AND PAYMENTDATE=P_PAYMENTDATE;
    
    DELETE FROM WPSSTLRAWDATA WHERE TOKENNO IS NULL;
       
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found.Upload Again]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
     SELECT TO_CHAR(FORTNIGHTSTARTDATE,'DD/MM/YYYY'),  TO_CHAR(FORTNIGHTENDDATE,'DD/MM/YYYY') 
    INTO lv_FortnightStartDate, lv_FortnightEndDate FROM WPSWAGEDPERIODDECLARATION
    WHERE TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY') BETWEEN FORTNIGHTSTARTDATE AND FORTNIGHTENDDATE
    AND COMPANYCODE = P_COMPCODE
    AND DIVISIONCODE = P_DIVCODE
    AND YEARCODE = P_YEARCODE;
    
     if lv_FortnightStartDate IS NULL then
        lv_error_remark := 'Validation Failure : [Fortnight StartDate cannot be blank]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
     if lv_FortnightEndDate IS NULL then
        lv_error_remark := 'Validation Failure : [Fortnight EndDate cannot be blank]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
       SELECT COUNT(*) into lv_cnt FROM 
       WPSWAGEDPERIODDECLARATION WHERE COMPANYCODE=P_COMPCODE AND DIVISIONCODE =P_DIVCODE AND FORTNIGHTSTARTDATE=TO_DATE(lv_FortnightStartDate,'DD/MM/YYYY') AND FINALISEDANDLOCK='Y';
 
--COMMENT ON 22-08-2020      
        if lv_cnt>0 then
        lv_error_remark := 'Validation Failure : [Wages already finalized so STL data can not be modified/Uploaded]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
--END COMMENT ON 22-08-2020 
       
       lv_row_cnt :=1;
    
     IF NVL(P_OVERWRITE_DATA_EXIST,'N')='Y' THEN
               
               SELECT COUNT(*) into lv_cnt 
               FROM WPSSTLENTRY WHERE 
               DOCUMENTDATE=TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY');
               --TOKENNO=C122.TOKENNO
               --AND (STLFROMDATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               --AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY') 
               --OR STLTODATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               --AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY')) 
               --AND LEAVECODE = 'STL'
               --AND YEARCODE=C122.STLTAKENFROMYEAR;
               
              if lv_cnt>0 then
                --IF DATA EXIST WHILE UPLOADING THEN DELETE THE PREVIOUS DATA IF P_OVERWRITE_DATA_EXIST='Y'
                DELETE FROM WPSSTLENTRYDETAILS WHERE DOCUMENTNO IN
                (
                SELECT DISTINCT DOCUMENTNO FROM WPSSTLENTRY WHERE 
               -- TOKENNO=C122.TOKENNO
               -- AND (STLFROMDATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY') 
               -- OR STLTODATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY')) 
               -- AND LEAVECODE = 'STL'
               -- AND YEARCODE=C122.STLTAKENFROMYEAR
               DOCUMENTDATE=TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY')
                );
                
                DELETE FROM WPSSTLENTRY WHERE 
               -- TOKENNO=C122.TOKENNO
               -- AND (STLFROMDATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY') 
               -- OR STLTODATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY')) 
               -- AND LEAVECODE = 'STL'
               -- AND YEARCODE=C122.STLTAKENFROMYEAR;
               DOCUMENTDATE=TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY');
                
                DELETE FROM WPSLEAVEAPPLICATION WHERE 
               -- TOKENNO=C122.TOKENNO
               -- AND (LEAVEFROM BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY') 
               -- OR LEAVETO BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
               -- AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY')) 
               -- AND LEAVECODE = 'STL'
               -- AND YEARCODE=C122.STLTAKENFROMYEAR;
               LEAVEAPPLIEDON=TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY');
            end if;
     END IF;
   
   FOR C122 IN 
     (
        select *
        from WPSSTLRAWDATA
        WHERE 1=1--COMPANYCODE=P_COMPCODE AND DIVISIONCODE=P_DIVCODE 
        AND PAYMENTDATE=P_PAYMENTDATE
     )
       LOOP  
       
       DELETE FROM GBL_WPSSTLENTRY;
       
       DELETE FROM GBL_WPSSTLENTRYDETAILS;
       
       
       SELECT count(*)
            into lv_cnt
            FROM WPSWORKERMAST A,WPSDEPARTMENTMASTER B
            WHERE A.COMPANYCODE = P_COMPCODE
            AND A.DIVISIONCODE = P_DIVCODE
            AND A.TOKENNO =C122.TOKENNO 
            AND A.COMPANYCODE=B.COMPANYCODE
            AND A.DEPARTMENTCODE=B.DEPARTMENTCODE;
       
        if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [Invalid Tokenno at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;
            
       SELECT A.WORKERSERIAL, A.WORKERNAME, A.WORKERCATEGORYCODE ,/*A.DEPARTMENTCODE*/C122.DEPARTMENTCODE,C122.SECTIONCODE,B.DEPARTMENTNAME DEPARTMENTDESC,A.OCCUPATIONCODE,nvl(c122.SHIFTCODE,'1')
             INTO LV_WORKERSERIAL,LV_WORKERNAME,LV_WORKERCATEGORYCODE,LV_DEPARTMENTCODE,LV_SECTIONCODE,LV_DEPARTMENTNAME,LV_OCCUPATIONCODE,LV_SHIFTCODE
            FROM WPSWORKERMAST A,WPSDEPARTMENTMASTER B
            WHERE A.COMPANYCODE = P_COMPCODE
            AND A.DIVISIONCODE = P_DIVCODE
            AND A.TOKENNO =C122.TOKENNO 
            AND A.COMPANYCODE=B.COMPANYCODE
            AND A.DEPARTMENTCODE=B.DEPARTMENTCODE;
            
       
       if NVL(C122.STLHOURS,0)<=0 then
        lv_error_remark := 'Validation Failure : [Hours Cannot be less than Zero at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
       
       if NVL(C122.STLDAYS,0)<=0 then
        lv_error_remark := 'Validation Failure : [Days Cannot be less than Zero at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
       
       if (NVL(C122.STLDAYS,0)*8)<>NVL(C122.STLHOURS,0) then
        lv_error_remark := 'Validation Failure : [Applicable days and Applicable Hours must be matched at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
       
       
       SELECT COUNT(*) into lv_cnt FROM 
       WPSSTLENTRY WHERE COMPANYCODE=P_COMPCODE AND DIVISIONCODE=P_DIVCODE AND TOKENNO=C122.TOKENNO AND YEAR=substr(lv_FortnightStartDate, -4) AND LEAVEENCASHMENT='Y';
        if lv_cnt>0 then
        lv_error_remark := 'Validation Failure : [Encashment already has been done at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
       
       SELECT COUNT(*) into lv_cnt FROM 
       WPSATTENDANCEDAYWISE WHERE COMPANYCODE=P_COMPCODE AND DIVISIONCODE=P_DIVCODE AND TOKENNO=C122.TOKENNO AND STATUSCODE='P' AND DATEOFATTENDANCE BETWEEN  TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY');
       
        if lv_cnt>0 then
        lv_error_remark := 'Validation Failure : [Data present in normal attendance. at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       end if;
       
       SELECT COUNT(*) into lv_cnt 
       FROM WPSSTLENTRY WHERE 
       TOKENNO=C122.TOKENNO
       AND (STLFROMDATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
       AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY') 
       OR STLTODATE BETWEEN TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY') 
       AND TO_DATE(C122.STLTODATE,'DD/MM/YYYY')) 
       AND LEAVECODE = 'STL'
       AND YEARCODE=C122.STLTAKENFROMYEAR;
               
        if lv_cnt>0 then
            lv_error_remark := 'Validation Failure : [STL Data Already Exist at line no '||lv_row_cnt||']';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;
                
       SELECT TO_CHAR(TO_DATE(''||lv_FortnightStartDate||'','DD/MM/RRRR') ,'DD/MM/YYYY')
       INTO LV_FORTNIGHTAPPLICABLEDATE
       FROM DUAL;
          
       select fn_autogen_params(P_COMPCODE,P_DIVCODE,P_YEARCODE,'WPS STL ENTRY',LV_FORTNIGHTAPPLICABLEDATE)
       into lv_DocumentNo
       from dual;
                
       if lv_DocumentNo IS NULL then
        lv_error_remark := 'Validation Failure : [Unable to generated Autogenerated Number at line no '||lv_row_cnt||']';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
       END IF;
       
        INSERT INTO GBL_WPSSTLENTRY
        (
        COMPANYCODE, DIVISIONCODE, YEARCODE, YEAR, DOCUMENTNO, DOCUMENTDATE, 
        FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, REMARKS, LEAVECODE, 
        TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, OCCUPATIONCODE, SHIFTCODE, 
        STLFROMDATE, STLTODATE, STLHOURS, STLDAYS, STLRATE, USERNAME, SYSROWID, 
        SECTIONCODE, TRANSACTIONTYPE, ADDLESS, LEAVEENCASHMENT
        )
        SELECT P_COMPCODE,P_DIVCODE,P_YEARCODE,/*TO_CHAR(TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY'),'YYYY')*/C122.STLTAKENFROMYEAR,/*C122.DOCUMENTNO*/lv_DocumentNo,TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY'),
        TO_DATE(lv_FortnightStartDate,'DD/MM/YYYY'),TO_DATE(lv_FortnightEndDate,'DD/MM/YYYY'),LV_WORKERSERIAL,NULL,'STL',
        C122.TOKENNO,LV_WORKERCATEGORYCODE,LV_DEPARTMENTCODE,LV_OCCUPATIONCODE,LV_SHIFTCODE,
        TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY'),TO_DATE(C122.STLTODATE,'DD/MM/YYYY'),C122.STLHOURS,C122.STLDAYS,C122.RATE,'SWT',FN_GENERATE_SYSROWID,
        LV_SECTIONCODE,'AVAILED','LESS','N' FROM DUAL;
       
       --------- start add on 11.08.2020 due to based on master data occupation not match with  department and section which upload through excel
       for c11 in (
--                   select distinct departmentcode, sectioncode, occupationcode GBL_WPSSTLENTRY
--                   minus
--                   select departmentcode, sectioncode, occupationcode from WPSOCCUPATIONMAST WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE= P_DIVCODE
                   SELECT DISTINCT DEPARTMENTCODE, SECTIONCODE, OCCUPATIONCODE
                   FROM GBL_WPSSTLENTRY
                   WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                     AND DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE NOT IN ( SELECT DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE FROM WPSOCCUPATIONMAST
                                                                               WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                                                                             )                       
                  )
       loop
            select min(OCCUPATIONCODE) INTO lv_MinOcpCode FROM WPSOCCUPATIONMAST
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND DEPARTMENTCODE = c11.DEPARTMENTCODE AND SECTIONCODE = c11.SECTIONCODE;
              
            UPDATE  GBL_WPSSTLENTRY SET OCCUPATIONCODE = lv_MinOcpCode 
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND DEPARTMENTCODE = c11.DEPARTMENTCODE AND SECTIONCODE = c11.SECTIONCODE;  
       end loop;            
       
       --------- end add on 11.08.2020 due to based on master data occupation not match with  department and section which upload through excel
       
        INSERT INTO WPSSTLENTRY
        (
        COMPANYCODE, DIVISIONCODE, YEARCODE, YEAR, DOCUMENTNO, DOCUMENTDATE, 
        FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, REMARKS, LEAVECODE, 
        TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, OCCUPATIONCODE, SHIFTCODE, 
        STLFROMDATE, STLTODATE, STLHOURS, STLDAYS, STLRATE, USERNAME, SYSROWID, 
        SECTIONCODE, TRANSACTIONTYPE, ADDLESS, LEAVEENCASHMENT,STLSERIALNO,PAYMENTDATE
        )
        SELECT 
        COMPANYCODE, DIVISIONCODE, YEARCODE, YEAR, DOCUMENTNO, DOCUMENTDATE, 
        FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, REMARKS, LEAVECODE, 
        TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, OCCUPATIONCODE, SHIFTCODE, 
        STLFROMDATE, STLTODATE, STLHOURS, STLDAYS, STLRATE, USERNAME, SYSROWID, 
        SECTIONCODE, TRANSACTIONTYPE, ADDLESS, LEAVEENCASHMENT,C122.SERIALNO, DOCUMENTDATE AS PAYMENTDATE
        FROM GBL_WPSSTLENTRY;
       

      
        ---
        SELECT MAX(LEAVEDATE)  INTO lv_LASTMAX_DATE 
        FROM WPSSTLENTRYDETAILS
        WHERE COMPANYCODE=P_COMPCODE
           AND DIVISIONCODE=P_DIVCODE
           AND YEARCODE=P_YEARCODE
           AND TOKENNO=C122.TOKENNO
           AND PAYMENTDATE=TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY')
           AND LEAVEDAYS>0;
        
        --
         IF lv_LASTMAX_DATE IS NULL THEN
          lv_DATE := TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY');
         ELSE
         lv_DATE := lv_LASTMAX_DATE+1;
         END IF;
        --lv_DATE := TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY');
        lv_IsSanction := 'Y';
        lv_LeaveDays := 1;
        lv_NoofHoursInday := 8;
        lv_DY    := 1;
        WHILE (lv_DATE <= TO_DATE(C122.STLTODATE,'DD/MM/YYYY'))
            loop    
                IF lv_LeaveDays > C122.STLDAYS THEN
                    lv_IsSanction := 'N';
                    lv_NoofHoursInday := 0;
                    lv_DY    := 0;
                END IF;
                 
                   
                insert into GBL_WPSSTLENTRYDETAILS (COMPANYCODE, DIVISIONCODE, YEARCODE, YEAR, LEAVECODE, DOCUMENTNO, DOCUMENTDATE, 
                FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, 
                OCCUPATIONCODE, SHIFTCODE, LEAVEFROMDATE, LEAVETODATE, LEAVEDATE, LEAVEHOURS, LEAVEDAYS, STLRATE, 
                ISSANCTIONED, TRANSACTIONTYPE, ADDLESS, USERNAME, LASTMODIFIEDDATE, SYSROWID,STLSERIALNO)
                
                values (P_COMPCODE, P_DIVCODE, P_YEARCODE, C122.STLTAKENFROMYEAR, 'STL' , lv_DocumentNo, TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY'), 
                TO_DATE(lv_FortnightStartDate,'DD/MM/YYYY'), TO_DATE(lv_FortnightEndDate,'DD/MM/YYYY'), LV_WORKERSERIAL, C122.TOKENNO, LV_WORKERCATEGORYCODE, LV_DEPARTMENTCODE, 
                LV_OCCUPATIONCODE, LV_SHIFTCODE, TO_DATE(C122.STLFROMDATE,'DD/MM/YYYY'), TO_DATE(C122.STLTODATE,'DD/MM/YYYY'), lv_DATE , lv_NoofHoursInday , lv_DY , C122.RATE, 
                lv_IsSanction , 'AVAILED', 'LESS','SWT', SYSDATE, FN_GENERATE_SYSROWID,C122.SERIALNO);
                
                lv_LeaveDays := lv_LeaveDays +1;    
                lv_DATE := lv_DATE+1;               
            end loop;
            
       --------- start add on 11.08.2020 due to based on master data occupation not match with  department and section which upload through excel
       for c51 in (
--                   select distinct departmentcode, sectioncode, occupationcode GBL_WPSSTLENTRYDETAILS
--                   minus
--                   select departmentcode, sectioncode, occupationcode from WPSOCCUPATIONMAST WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE= P_DIVCODE
                   SELECT DISTINCT DEPARTMENTCODE, SECTIONCODE, OCCUPATIONCODE
                   FROM GBL_WPSSTLENTRYDETAILS
                   WHERE COMPANYCODE =P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                     AND DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE NOT IN ( SELECT DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE FROM WPSOCCUPATIONMAST
                                                                               WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                                                                             )                       

                  )
       loop
            select min(OCCUPATIONCODE) INTO lv_MinOcpCode FROM WPSOCCUPATIONMAST
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND DEPARTMENTCODE = c51.DEPARTMENTCODE AND SECTIONCODE = c51.SECTIONCODE;
              
            UPDATE  GBL_WPSSTLENTRY SET OCCUPATIONCODE = lv_MinOcpCode 
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND DEPARTMENTCODE = c51.DEPARTMENTCODE AND SECTIONCODE = c51.SECTIONCODE;  
       end loop;            
       
       --------- end add on 11.08.2020 due to based on master data occupation not match with  department and section which upload through excel
              
       
                INSERT INTO WPSSTLENTRYDETAILS
                (
                SECTIONCODE, LASTMODIFIEDDATE, ISSANCTIONED, LEAVEHOURS, WORKERCATEGORYCODE, 
                OCCUPATIONCODE, LEAVETODATE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, STLRATE, ADDLESS, 
                USERNAME, DOCUMENTDATE, TRANSACTIONTYPE, LEAVEFROMDATE, LEAVEDAYS, SYSROWID, SHIFTCODE, 
                COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, DOCUMENTNO, 
                DEPARTMENTCODE, LEAVEDATE, YEARCODE, YEAR,LEAVECODE, PAYMENTDATE,STLSERIALNO
                )
                SELECT 
                SECTIONCODE, LASTMODIFIEDDATE, ISSANCTIONED, LEAVEHOURS, WORKERCATEGORYCODE, 
                OCCUPATIONCODE, LEAVETODATE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, STLRATE, ADDLESS, 
                USERNAME, DOCUMENTDATE, TRANSACTIONTYPE, LEAVEFROMDATE, LEAVEDAYS, FN_GENERATE_SYSROWID, SHIFTCODE, 
                COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, DOCUMENTNO, 
                DEPARTMENTCODE, LEAVEDATE, YEARCODE, YEAR,LEAVECODE, DOCUMENTDATE AS PAYMENTDATE,STLSERIALNO
                FROM GBL_WPSSTLENTRYDETAILS;
                
                INSERT INTO WPSLEAVEAPPLICATION
                    (COMPANYCODE, DIVISIONCODE, YEARCODE, WORKERSERIAL, TOKENNO, WOKERCATEGORYCODE, 
                    LEAVECODE, LEAVEAPPLIEDON, LEAVEFROM, LEAVETO, LEAVESANCTIONEDON, 
                    LEAVEDATE,LEAVEDAYS, LEAVEHOURS, LEAVEENCASHED, CALENDARYEAR)
                SELECT COMPANYCODE, DIVISIONCODE, YEARCODE,WORKERSERIAL, TOKENNO,WORKERCATEGORYCODE,
                    LEAVECODE,DOCUMENTDATE,LEAVEFROMDATE,LEAVETODATE,/*DOCUMENTDATE*/ FORTNIGHTENDDATE,
                    LEAVEDATE,LEAVEDAYS,LEAVEHOURS,0,YEAR
                FROM GBL_WPSSTLENTRYDETAILS;
--               
                
               
              
       UPDATE WPSLEAVEAPPLICATION 
       SET LEAVEDAYS=0,LEAVEHOURS=0
     WHERE COMPANYCODE=P_COMPCODE
       AND DIVISIONCODE=P_DIVCODE
       AND LEAVEAPPLIEDON = TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY')
       AND WORKERSERIAL=LV_WORKERSERIAL
       AND EXISTS --LEAVEDATE IN
       (   SELECT HOLIDAYDATE
             FROM WPSHOLIDAYMASTER 
            WHERE COMPANYCODE=P_COMPCODE
              AND DIVISIONCODE=P_DIVCODE 
              AND ISPAID='Y'
              AND WPSLEAVEAPPLICATION.LEAVEDATE=WPSHOLIDAYMASTER.HOLIDAYDATE
       );
       
      SELECT TRIM(DAYOFFDAY)
        INTO lv_OFFDAY
        FROM WPSWORKERMAST 
       WHERE COMPANYCODE=P_COMPCODE
         AND DIVISIONCODE=P_DIVCODE
         AND WORKERSERIAL=LV_WORKERSERIAL;
       
       UPDATE WPSLEAVEAPPLICATION 
          SET LEAVEDAYS=0,LEAVEHOURS=0
        WHERE COMPANYCODE=P_COMPCODE
          AND DIVISIONCODE=P_DIVCODE
          AND LEAVEAPPLIEDON =  TO_DATE(P_PAYMENTDATE,'DD/MM/YYYY')
          AND WORKERSERIAL=LV_WORKERSERIAL
          AND EXISTS 
            (
            SELECT TO_DATE(DATES,'DD/MM/YYYY') DATES  FROM --count(TO_CHAR(DATES,'DAY'))
            (
            WITH d AS
            (
            SELECT TRUNC ( TO_DATE( C122.STLFROMDATE,'DD/MM/YYYY')) -1  AS dt
            FROM dual
            )
            SELECT dt + LEVEL  DATES
            FROM d
            CONNECT BY LEVEL <=  ( TO_DATE(C122.STLTODATE,'DD/MM/YYYY') - TO_DATE( C122.STLFROMDATE,'DD/MM/YYYY') + 1 )
            )
            where TO_DATE(WPSLEAVEAPPLICATION.LEAVEDATE,'DD/MM/YYYY')=TO_DATE(DATES,'DD/MM/YYYY')
              --  AND trim(trim(TO_CHAR(DATES,'DAY'))) = UPPER(TRIM(lv_OFFDAY))
              AND ltrim(trim(TO_CHAR(WPSLEAVEAPPLICATION.LEAVEDATE,'DAY'))) = UPPER(LTRIM(TRIM(lv_OFFDAY)))
       );
       
       lv_row_cnt :=lv_row_cnt+1;
       END LOOP;

END;
/


