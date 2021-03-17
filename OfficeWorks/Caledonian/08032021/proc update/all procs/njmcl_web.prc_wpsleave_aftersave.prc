DROP PROCEDURE NJMCL_WEB.PRC_WPSLEAVE_AFTERSAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRC_WPSLEAVE_AFTERSAVE
IS
lv_Master               GBL_WPSSTLENTRY%rowtype;
lv_DATE                 DATE    :=SYSDATE;
lv_WORKERSERIAL         VARCHAR2(10) := '';
lv_LeaveDays            number(5) := 0;
lv_IsSanction           varchar2(1) := '';
--LV_SECTION              VARCHAR2(10) :='';
lv_cnt                  number:=0;
lv_error_remark           VARCHAR2(5000);  
BEGIN
    select *
    into lv_Master
    from GBL_WPSSTLENTRY
    WHERE ROWNUM<=1;
    
    IF NVL(lv_Master.OPERATIONMODE,'NA') = 'A' THEN
    
        lv_DATE:=lv_Master.STLFROMDATE;
    
        FOR C1 IN ( SELECT * FROM GBL_WPSSTLENTRY)
        LOOP
            lv_WORKERSERIAL := C1.WORKERSERIAL;
            lv_DATE := C1.STLFROMDATE;
            lv_IsSanction := 'Y';
            lv_LeaveDays := 1;
            
            --SELECT SECTIONCODE into LV_SECTION FROM WPSWORKERMAST WHERE WORKERSERIAL = lv_WORKERSERIAL;
            
            WHILE (lv_WORKERSERIAL = C1.WORKERSERIAL AND lv_DATE <= C1.STLTODATE)
                loop
                
                    SELECT COUNT(1) INTO lv_cnt FROM WPSSTLENTRYDETAILS 
                    WHERE COMPANYCODE=C1.COMPANYCODE
                        AND DIVISIONCODE=C1.DIVISIONCODE
                        AND YEARCODE=C1.YEARCODE
                        AND YEAR=C1.YEAR
                        AND WORKERSERIAL=C1.WORKERSERIAL
                        AND LEAVEDATE=lv_DATE;
                        
                    IF lv_cnt>0 THEN
                        lv_error_remark := ' LEAVE IS EXIST ON '||lv_DATE||'.';--||SQLERRM ;
                        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
                    END IF; 
                                           
                    insert into WPSSTLENTRYDETAILS (COMPANYCODE, DIVISIONCODE, YEARCODE, YEAR, LEAVECODE, DOCUMENTNO, DOCUMENTDATE, 
                FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, 
                OCCUPATIONCODE, SHIFTCODE, LEAVEFROMDATE, LEAVETODATE, LEAVEDATE, LEAVEHOURS, LEAVEDAYS, STLRATE, 
                ISSANCTIONED, TRANSACTIONTYPE, ADDLESS, USERNAME, LASTMODIFIEDDATE, SYSROWID,SECTIONCODE)
                values (C1.COMPANYCODE, C1.DIVISIONCODE, C1.YEARCODE, C1.YEAR, C1.LEAVECODE , C1.DOCUMENTNO, C1.DOCUMENTDATE, 
                C1.FORTNIGHTSTARTDATE, C1.FORTNIGHTENDDATE, C1.WORKERSERIAL, C1.TOKENNO, C1.WORKERCATEGORYCODE, C1.DEPARTMENTCODE, 
                C1.OCCUPATIONCODE, C1.SHIFTCODE, C1.STLFROMDATE, C1.STLTODATE, lv_DATE , 8 , 1 , C1.STLRATE, 
                lv_IsSanction , C1.TRANSACTIONTYPE, C1.ADDLESS, C1.USERNAME, SYSDATE, C1.SYSROWID,C1.SECTIONCODE);
                    
                      
                    lv_DATE := lv_DATE+1;               
                end loop;
        END LOOP;
    ELSIF NVL(lv_Master.OPERATIONMODE,'NA') = 'M' THEN
        DELETE FROM WPSSTLENTRYDETAILS WHERE COMPANYCODE=lv_Master.COMPANYCODE AND DIVISIONCODE=lv_Master.DIVISIONCODE AND DOCUMENTNO =lv_Master.DOCUMENTNO;
        
        lv_DATE:=lv_Master.STLFROMDATE;
    
        FOR C1 IN ( SELECT * FROM GBL_WPSSTLENTRY)
        LOOP
            lv_WORKERSERIAL := C1.WORKERSERIAL;
            lv_DATE := C1.STLFROMDATE;
            lv_IsSanction := 'Y';
            lv_LeaveDays := 1;
            WHILE (lv_WORKERSERIAL = C1.WORKERSERIAL AND lv_DATE <= C1.STLTODATE)
                loop 
                                           
                    insert into WPSSTLENTRYDETAILS (COMPANYCODE, DIVISIONCODE, YEARCODE, YEAR, LEAVECODE, DOCUMENTNO, DOCUMENTDATE, 
                FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, 
                OCCUPATIONCODE, SHIFTCODE, LEAVEFROMDATE, LEAVETODATE, LEAVEDATE, LEAVEHOURS, LEAVEDAYS, STLRATE, 
                ISSANCTIONED, TRANSACTIONTYPE, ADDLESS, USERNAME, LASTMODIFIEDDATE, SYSROWID,SECTIONCODE)
                values (C1.COMPANYCODE, C1.DIVISIONCODE, C1.YEARCODE, C1.YEAR, C1.LEAVECODE , C1.DOCUMENTNO, C1.DOCUMENTDATE, 
                C1.FORTNIGHTSTARTDATE, C1.FORTNIGHTENDDATE, C1.WORKERSERIAL, C1.TOKENNO, C1.WORKERCATEGORYCODE, C1.DEPARTMENTCODE, 
                C1.OCCUPATIONCODE, C1.SHIFTCODE, C1.STLFROMDATE, C1.STLTODATE, lv_DATE , 8 , 1 , C1.STLRATE, 
                lv_IsSanction , C1.TRANSACTIONTYPE, C1.ADDLESS, C1.USERNAME, SYSDATE, C1.SYSROWID,C1.SECTIONCODE);
                    
                      
                    lv_DATE := lv_DATE+1;               
                end loop;
        END LOOP;
        
    ELSE
        DELETE FROM WPSSTLENTRYDETAILS WHERE COMPANYCODE=lv_Master.COMPANYCODE AND DIVISIONCODE=lv_Master.DIVISIONCODE AND DOCUMENTNO =lv_Master.DOCUMENTNO; 
    
    END IF;
     
END;
/


