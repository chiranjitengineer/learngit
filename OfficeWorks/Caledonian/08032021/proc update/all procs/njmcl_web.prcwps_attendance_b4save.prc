DROP PROCEDURE NJMCL_WEB.PRCWPS_ATTENDANCE_B4SAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_ATTENDANCE_B4SAVE" 
is
lv_cnt                  number;
lv_cnt1                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_WPSATTENDANCEDAYWISE%rowtype;
lv_MaxDRCRdate          date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);  
lv_AttnTag              varchar2(50); 
  

begin

    lv_result:='#SUCCESS#';
        
        SELECT DISTINCT ATTENDANCETAG INTO lv_AttnTag FROM GBL_WPSATTENDANCEDAYWISE WHERE ATTENDANCETAG IS NOT NULL;

        select *
        into lv_Master
        from GBL_WPSATTENDANCEDAYWISE
        WHERE ROWNUM<=1;

        select count(*)
        into lv_cnt
        from GBL_WPSATTENDANCEDAYWISE;
        
         IF NVL(lv_cnt,0)=0 THEN
            lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;
        
       
        IF lv_Master.DATEOFATTENDANCE > TRUNC(SYSDATE) THEN
            lv_error_remark := 'Validation Failure : [Date of attendance cannot be greater than current date.]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;
 /*       
        IF  lv_AttnTag <> 'MANUAL' and NVL(lv_cnt,0)> 0 THEN
        
            lv_cnt1 :=0;
            SELECT COUNT(*) 
            INTO lv_cnt1
            FROM
            (
                SELECT DATEOFATTENDANCE,WORKERSERIAL
                FROM WPSATTENDANCEDAYWISE
                WHERE DATEOFATTENDANCE||WORKERSERIAL = lv_Master.DATEOFATTENDANCE||lv_Master.WORKERSERIAL 
             );
             
             IF NVL(lv_cnt,0) <> NVL(lv_cnt1,0) THEN
                lv_error_remark := 'Validation Failure : [Invalid etry!Improper cell value!.]';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
             END IF;
        
        END IF;
*/
        
        IF lv_Master.OPERATIONMODE IS NULL THEN
            lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;
        
        lv_cnt :=0;
        SELECT COUNT(*) 
        INTO lv_cnt
        FROM
        (
        SELECT DATEOFATTENDANCE, TOKENNO,SHIFTCODE, SPELLTYPE
        FROM GBL_WPSATTENDANCEDAYWISE
        GROUP BY DATEOFATTENDANCE, TOKENNO,SHIFTCODE, SPELLTYPE
        HAVING count(*)>1
        );
        
        IF nvl(lv_cnt,0)>0 THEN
               lv_error_remark := 'Validation Failure : [Duplicate TOKENNO : ' ||' You can not save duplicate TOKENNO.]';
               raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;
        
        lv_cnt :=0;
        SELECT COUNT(*) 
        INTO lv_cnt
        FROM
        (
            SELECT DISTINCT DEPARTMENTCODE||OCCUPATIONCODE
              FROM GBL_WPSATTENDANCEDAYWISE
             WHERE DEPARTMENTCODE||OCCUPATIONCODE NOT IN
                   (SELECT DISTINCT DEPARTMENTCODE||OCCUPATIONCODE FROM WPSOCCUPATIONMAST)
        );
        
        IF nvl(lv_cnt,0)>0 THEN
               lv_error_remark := 'Validation Failure : [Invalid Department/Occupation : ' ||' Check Dept/Occu. Code.]';
               raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;
        
        lv_cnt1 :=0;
        SELECT COUNT(*) 
        INTO lv_cnt1
        FROM
        (
        SELECT DATEOFATTENDANCE, TOKENNO,SHIFTCODE, SPELLTYPE
        FROM WPSATTENDANCEDAYWISE
        WHERE DATEOFATTENDANCE||TOKENNO||SHIFTCODE||SPELLTYPE IN 
                        (SELECT DATEOFATTENDANCE||TOKENNO||SHIFTCODE||SPELLTYPE 
                           FROM GBL_WPSATTENDANCEDAYWISE) 
         );
        
        if nvl(lv_Master.operationmode,'NA') = 'A'  then
           IF nvl(lv_cnt1,0)>0 THEN
                lv_error_remark := 'Validation Failure : [Duplicate TOKENNO : ' ||' DATEOFATTENDANCE||TOKENNO||SHIFTCODE||SPELLTYPE Combination already exist.]';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            END IF;   
        END IF;
        
        lv_cnt1 :=0;
        SELECT COUNT(*) 
        INTO lv_cnt1
        FROM
        (
        SELECT DATEOFATTENDANCE, TOKENNO,SHIFTCODE, SPELLTYPE
        FROM WPSATTENDANCEDAYWISE
        WHERE DATEOFATTENDANCE||TOKENNO||SHIFTCODE||SPELLTYPE IN 
                        (SELECT DATEOFATTENDANCE||TOKENNO||SHIFTCODE||SPELLTYPE 
                           FROM GBL_WPSATTENDANCEDAYWISE
                          WHERE BOOKNO IS NULL)
         AND ATTENDANCETAG <> 'HD'                 
         );
        
        if nvl(lv_Master.operationmode,'NA') = 'M'  then
           IF nvl(lv_cnt1,0)>0 THEN
                lv_error_remark := 'Validation Failure : [Duplicate NEW TOKENNO : ' ||' DATEOFATTENDANCE||TOKENNO||SHIFTCODE||SPELLTYPE Combination already exist.]';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            END IF;   
        END IF; 

        if nvl(lv_Master.operationmode,'NA') = 'A' OR nvl(lv_Master.operationmode,'NA') = 'M' then
             FOR C1 IN (
                        SELECT FORTNIGHTSTARTDATE,FORTNIGHTENDDATE
                          FROM WPSWAGEDPERIODDECLARATION
                         WHERE TO_DATE(lv_Master.DATEOFATTENDANCE,'DD/MM/RRRR') BETWEEN FORTNIGHTSTARTDATE AND FORTNIGHTENDDATE
                      )
                LOOP
                    UPDATE GBL_WPSATTENDANCEDAYWISE
                       SET FORTNIGHTSTARTDATE=C1.FORTNIGHTSTARTDATE,
                           FORTNIGHTENDDATE=C1.FORTNIGHTENDDATE;
                    
                    /*UPDATE GBL_WPSATTENDANCEDAYWISE
                       SET BOOKNO='ATTN/'||TO_CHAR(DATEOFATTENDANCE,'DDMMRRRR')||'/'||SHIFTCODE||'/'||TOKENNO;*/
                    IF lv_AttnTag='MANUAL' THEN
                        UPDATE GBL_WPSATTENDANCEDAYWISE
                           SET BOOKNO='ATTN/MANUAL/'||TO_CHAR(DATEOFATTENDANCE,'DDMMRRRR')||'/'||TOKENNO;
                    ELSE
                        UPDATE GBL_WPSATTENDANCEDAYWISE
                           SET BOOKNO='ATTN/'||TO_CHAR(DATEOFATTENDANCE,'DDMMRRRR')||'/'||TOKENNO;
                    END IF;

                           
                END LOOP;  
                
            UPDATE GBL_WPSATTENDANCEDAYWISE
              SET MODULE='WPS';    
              --COMMIT;
        end if;

--exception when others then
--    lv_error_remark:= lv_error_remark || '#UNSUCC#ESSFULL#';
--    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
end;
/


