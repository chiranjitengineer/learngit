DROP PROCEDURE NJMCL_WEB.PRCWPS_HOLIDAY_B4SAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_HOLIDAY_B4SAVE" 
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_WPSWPSHOLIDAYMASTER%rowtype;
lv_MaxDRCRdate          date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);      

begin

    lv_result:='#SUCCESS#';
    
        select *
        into lv_Master
        from GBL_WPSWPSHOLIDAYMASTER
        WHERE ROWNUM<=1;

        select count(*)
        into lv_cnt
        from GBL_WPSWPSHOLIDAYMASTER;
        
         IF NVL(lv_cnt,0)=0 THEN
            lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;
        
       
        IF lv_Master.HOLIDAYDATE > TRUNC(SYSDATE) THEN
            lv_error_remark := 'Validation Failure : [Date of attendance cannot be greater than current date.]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;

        
        IF lv_Master.OPERATIONMODE IS NULL THEN
            lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;
        
        if nvl(lv_Master.operationmode,'NA') = 'A' OR nvl(lv_Master.operationmode,'NA') = 'M' then
             FOR C1 IN (
                        SELECT TO_DATE(lv_Master.HOLIDAYDATE,'DD/MM/RRRR') HOLIDAYDATE,
                        CASE WHEN TO_DATE(lv_Master.HOLIDAYDATE,'DD/MM/RRRR')>=TO_DATE('01/'||SUBSTR(lv_Master.HOLIDAYDATE,4),'DD/MM/RRRR') AND
                             TO_DATE(lv_Master.HOLIDAYDATE,'DD/MM/RRRR')<=TO_DATE('16/'||SUBSTR(lv_Master.HOLIDAYDATE,4),'DD/MM/RRRR') THEN
                                    TO_DATE('01/'||SUBSTR(lv_Master.HOLIDAYDATE,4),'DD/MM/RRRR')
                        WHEN TO_DATE(lv_Master.HOLIDAYDATE,'DD/MM/RRRR')>=TO_DATE('16/'||SUBSTR(lv_Master.HOLIDAYDATE,4),'DD/MM/RRRR') AND
                             TO_DATE(lv_Master.HOLIDAYDATE,'DD/MM/RRRR')<=LAST_DAY(TO_DATE(lv_Master.HOLIDAYDATE,'DD/MM/RRRR')) THEN
                                    TO_DATE('16/'||SUBSTR(lv_Master.HOLIDAYDATE,4),'DD/MM/RRRR')
                        END FORTNIGHTSTARTDATE, 
                        CASE WHEN TO_DATE(lv_Master.HOLIDAYDATE,'DD/MM/RRRR')>=TO_DATE('01/'||SUBSTR(lv_Master.HOLIDAYDATE,4),'DD/MM/RRRR') AND
                             TO_DATE(lv_Master.HOLIDAYDATE,'DD/MM/RRRR')<=TO_DATE('16/'||SUBSTR(lv_Master.HOLIDAYDATE,4),'DD/MM/RRRR') THEN
                                    TO_DATE('15/'||SUBSTR(lv_Master.HOLIDAYDATE,4),'DD/MM/RRRR')
                        WHEN TO_DATE(lv_Master.HOLIDAYDATE,'DD/MM/RRRR')>=TO_DATE('16/'||SUBSTR(lv_Master.HOLIDAYDATE,4),'DD/MM/RRRR') AND
                             TO_DATE(lv_Master.HOLIDAYDATE,'DD/MM/RRRR')<=LAST_DAY(TO_DATE(lv_Master.HOLIDAYDATE,'DD/MM/RRRR')) THEN
                                    LAST_DAY(TO_DATE(lv_Master.HOLIDAYDATE,'DD/MM/RRRR'))
                        END FORTNIGHTENDDATE
                        ,LAST_DAY(TO_DATE(lv_Master.HOLIDAYDATE,'DD/MM/RRRR')) LASTDATE                      
                        FROM DUAL
                      )
                LOOP
                    UPDATE GBL_WPSWPSHOLIDAYMASTER
                       SET FORTNIGHTSTARTDATE=C1.FORTNIGHTSTARTDATE,
                           FORTNIGHTENDDATE=C1.FORTNIGHTENDDATE;
                END LOOP;  
        end if;

--exception when others then
--    lv_error_remark:= lv_error_remark || '#UNSUCC#ESSFULL#';
--    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
end;
/


