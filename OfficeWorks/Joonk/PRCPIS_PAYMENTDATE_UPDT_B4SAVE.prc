CREATE OR REPLACE PROCEDURE JOONK.PRCPIS_PAYMENTDATE_UPDT_B4SAVE
IS
LV_CNT                  NUMBER;
LV_RESULT               VARCHAR2(10);
LV_ERROR_REMARK         VARCHAR2(4000) := '' ;
LV_MASTER               GBL_PISPAYMENTDATEUPDATE%ROWTYPE; 
BEGIN

    LV_RESULT:='#SUCCESS#';
        SELECT *
        INTO LV_MASTER
        FROM GBL_PISPAYMENTDATEUPDATE
        WHERE ROWNUM<=1;

        SELECT COUNT(*)
        INTO LV_CNT
        FROM GBL_PISPAYMENTDATEUPDATE;
        
         IF NVL(LV_CNT,0)=0 THEN
            LV_ERROR_REMARK := 'Validation Failure : [Blank data not allowded to save!]';
            RAISE_APPLICATION_ERROR(TO_NUMBER(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,LV_ERROR_REMARK));
        END IF;
       
        
        IF LV_MASTER.OPERATIONMODE IS NULL THEN
            LV_ERROR_REMARK := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            RAISE_APPLICATION_ERROR(TO_NUMBER(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,LV_ERROR_REMARK));
        END IF;
        
        
         
        
        -- GENERATING APPLICATIONNO
        IF LV_MASTER.OPERATIONMODE ='A' THEN
        
            
            
            SELECT COUNT(*) INTO LV_CNT FROM PISPAYTRANSACTION
            WHERE COMPANYCODE=LV_MASTER.COMPANYCODE
            AND DIVISIONCODE=LV_MASTER.DIVISIONCODE
            AND YEARMONTH=LV_MASTER.YEARMONTH
            AND UNITCODE=NVL(LV_MASTER.UNITCODE,UNITCODE)
            AND CATEGORYCODE=NVL(LV_MASTER.CATEGORYCODE,CATEGORYCODE)
            AND GRADECODE=NVL(LV_MASTER.GRADECODE,GRADECODE);
        
            UPDATE PISPAYTRANSACTION A SET
            PAYMENTDATE = LV_MASTER.PAYMENTDATE
            WHERE COMPANYCODE=LV_MASTER.COMPANYCODE
            AND DIVISIONCODE=LV_MASTER.DIVISIONCODE
            AND YEARMONTH=LV_MASTER.YEARMONTH
            AND UNITCODE=NVL(LV_MASTER.UNITCODE,UNITCODE)
            AND CATEGORYCODE=NVL(LV_MASTER.CATEGORYCODE,CATEGORYCODE)
            AND GRADECODE=NVL(LV_MASTER.GRADECODE,GRADECODE);

            SELECT COUNT(*) INTO LV_CNT  FROM SYS_GBL_PROCOUTPUT_INFO;

--            DELETE FROM SYS_GBL_PROCOUTPUT_INFO

            IF LV_CNT = 0 THEN
                INSERT INTO SYS_GBL_PROCOUTPUT_INFO
                VALUES ('[PAYMENT DATE UPDATE FOR THE MONTH OF ' || TO_CHAR(TO_DATE(LV_MASTER.YEARMONTH,'YYYYMM'),'MON-YYYY') || ' Dated : ' || LV_MASTER.PAYMENTDATE ||'  ( UNIT - '|| LV_MASTER.UNITCODE||', CATEGORY - '|| LV_MASTER.CATEGORYCODE||', GRADE - '|| LV_MASTER.GRADECODE  || ')]');
            ELSE
                UPDATE SYS_GBL_PROCOUTPUT_INFO
                SET SYS_SAVE_INFO = NVL(SYS_SAVE_INFO,'') || ('[PAYMENT DATE UPDATE FOR THE MONTH OF ' || TO_CHAR(TO_DATE(LV_MASTER.YEARMONTH,'YYYYMM'),'MON-YYYY') || ' Dated : ' || LV_MASTER.PAYMENTDATE||'  ( UNIT - '|| LV_MASTER.UNITCODE||', CATEGORY - '|| LV_MASTER.CATEGORYCODE||', GRADE - '|| LV_MASTER.GRADECODE ||  ')]');
            END IF;   
            
            UPDATE GBL_PISPAYMENTDATEUPDATE SET
            CATEGORYCODE = NVL(CATEGORYCODE,'NA'),
            CATEGORYDESCRIPTION = NVL(CATEGORYDESCRIPTION,'NA'),
            GRADECODE = NVL(GRADECODE,'NA'),
            GRADEDESCRIPTION = NVL(GRADEDESCRIPTION,'NA') WHERE 1=1;
            
            SELECT *
            INTO LV_MASTER
            FROM GBL_PISPAYMENTDATEUPDATE
            WHERE ROWNUM<=1;
            
            DELETE FROM PISPAYMENTDATEUPDATE
            WHERE COMPANYCODE=LV_MASTER.COMPANYCODE
            AND DIVISIONCODE=LV_MASTER.DIVISIONCODE
            AND YEARMONTH=LV_MASTER.YEARMONTH
            AND UNITCODE=LV_MASTER.UNITCODE
            AND CATEGORYCODE= LV_MASTER.CATEGORYCODE 
            AND GRADECODE= LV_MASTER.GRADECODE ;



       END IF;
       
--    RETURN LV_RESULT;
end;
/