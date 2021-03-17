DROP PROCEDURE NJMCL_WEB.PRCWPS_WORKERUPD_B4SAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_WORKERUPD_B4SAVE" 
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_WPSWORKERWISERATEUPDATE%rowtype;
lv_Maxdate              date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);      

begin
    lv_result:='#SUCCESS#';
    
    select *
    into lv_Master
    from GBL_WPSWORKERWISERATEUPDATE
    WHERE ROWNUM<=1;

    select count(*)
    into lv_cnt
    from GBL_WPSWORKERWISERATEUPDATE;
        
     IF NVL(lv_cnt,0)=0 THEN
        lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
    END IF;
    
    select MAX(EFFECTIVEDATE)
    into lv_Maxdate
    from WPSWORKERWISERATEUPDATE;
    
    IF lv_Master.EFFECTIVEDATE < lv_Maxdate THEN
        lv_error_remark := 'Validation Failure : [You cannot Update Rate before.] '||TO_CHAR(lv_Maxdate,'DD/MM/YYYY');
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
    END IF;           

    if nvl(lv_Master.operationmode,'NA') = 'A' then 
        FOR C1 IN (SELECT * FROM GBL_WPSWORKERWISERATEUPDATE
                    ORDER BY WORKERSERIAL
            ) LOOP
            
            DELETE FROM WPSWORKERWISERATEUPDATE WHERE COMPANYCODE=C1.COMPANYCODE AND DIVISIONCODE=C1.DIVISIONCODE 
               AND WORKERSERIAL=C1.WORKERSERIAL AND EFFECTIVEDATE=C1.EFFECTIVEDATE;
               
            UPDATE WPSWORKERMAST SET FIXEDBASIC=DECODE(NVL(C1.FIXEDBASIC,0),0,FIXEDBASIC,C1.FIXEDBASIC),
                                     FIXEDBASIC_PEICERT=DECODE(NVL(C1.FIXEDBASIC_PEICERT,0),0,FIXEDBASIC_PEICERT,C1.FIXEDBASIC_PEICERT),
                                     DARATE=DECODE(NVL(C1.DARATE,0),0,DARATE,C1.DARATE),
                                     INCREMENTAMOUNT=DECODE(NVL(C1.INCREMENTAMOUNT,0),0,INCREMENTAMOUNT,C1.INCREMENTAMOUNT),
                                     CARATE=DECODE(NVL(C1.CARATE,0),0,CARATE,C1.CARATE),
                                     ADHOCRATE=DECODE(NVL(C1.ADHOCRATE,0),0,ADHOCRATE,C1.ADHOCRATE),
                                     SPL_ALLOW_RATE=DECODE(NVL(C1.SPL_ALLOW_RATE,0),0,SPL_ALLOW_RATE,C1.SPL_ALLOW_RATE),
                                     PPRATE=DECODE(NVL(C1.PPRATE,0),0,PPRATE,C1.PPRATE),
                                     COP_DEDN=DECODE(NVL(C1.COP_DEDN,0),0,COP_DEDN,C1.COP_DEDN),
                                     ELEC_DUE=DECODE(NVL(C1.ELEC_DUE,0),0,ELEC_DUE,C1.ELEC_DUE),
                                     ADDLBASIC_RATE=DECODE(NVL(C1.ADDLBASIC_RATE,0),0,ADDLBASIC_RATE,C1.ADDLBASIC_RATE),
                                     DAILYBASICRATE=DECODE(NVL(C1.DAILYBASICRATE,0),0,DAILYBASICRATE,C1.DAILYBASICRATE)
             WHERE COMPANYCODE=C1.COMPANYCODE AND DIVISIONCODE=C1.DIVISIONCODE 
               AND WORKERSERIAL=C1.WORKERSERIAL;
        END LOOP;
    end if;
end;
/


