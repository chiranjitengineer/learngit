DROP PROCEDURE NJMCL_WEB.PRCWPS_ITAXCOMPUTATION_B4SAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_ITAXCOMPUTATION_B4SAVE" 
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PISITAXCOMPUTATION%rowtype;
lv_MaxDRCRdate            date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);      

begin

    lv_result:='#SUCCESS#';
    
    --RETURN;
   
    select *
    into lv_Master
    from GBL_PISITAXCOMPUTATION
    WHERE ROWNUM<=1;
    
    
     
     IF lv_Master.OPERATIONMODE = 'A' THEN
     
        IF lv_Master.ISPROCESSALL = 'Y' THEN
            
            FOR C1 IN ( select CATEGORYCODE, GRADECODE, TOKENNO
                        from PISEMPLOYEEMASTER 
                        WHERE COMPANYCODE =  lv_Master.COMPANYCODE
                        AND DIVISIONCODE =  lv_Master.DIVISIONCODE
                        AND CATEGORYCODE = lv_Master.CATEGORYCODE
                        AND GRADECODE = lv_Master.GRADECODE 
                        
                        )
                LOOP
                
                
                    IF C1.TOKENNO <> lv_Master.TOKENNO THEN   
                     
                     PROC_PISITAX_COMPUTATION (lv_Master.COMPANYCODE, lv_Master.DIVISIONCODE, lv_Master.YEARCODE,C1.CATEGORYCODE,C1.GRADECODE, C1.TOKENNO);
                     
                     INSERT INTO GBL_PISITAXCOMPUTATION
                     (
                         COMPONENTHEADER, COMPONENTCODE, COMPACTUALVALUE, COMPPROJCTEDVALUE, COMPMANUALVALUE,COMPARREARVALUE, COLUMNFORSUBTOTAL, COLUMNNO, COMPVALUE,
                         COMPONENTTYPE,  ACTUALCOMPCODE, FORMULARATE, MANUALFORMULA, SERIALNO, COMPANYCODE, DIVISIONCODE, YEARCODE,
                         WORKERSERIAL, TOKENNO, USERNAME, SYSROWID, OPERATIONMODE, CATEGORYCODE, GRADECODE  
                     )
                     SELECT COMPONENTHEADER, COMPONENTCODE, COMPACTUALVALUE, COMPPROJCTEDVALUE, COMPMANUALVALUE,COMPARREARVALUE, COLUMNFORSUBTOTAL, COLUMNNO, COMPVALUE,
                     COMPONENTTYPE,  ACTUALCOMPCODE, FORMULARATE, MANUALFORMULA, SERIALNO, COMPANYCODE, DIVISIONCODE, YEARCODE,
                     WORKERSERIAL, TOKENNO, lv_Master.USERNAME, NULL SYSROWID, lv_Master.OPERATIONMODE, CATEGORYCODE, GRADECODE
                     FROM GTTPISITAXCOMPUTATION
                     WHERE NVL(DISPLAYINGRID,'N')='Y';
                    
                     
                     END IF;
                      
                END LOOP;
            
        END IF;      
     
     END IF;
     
     
end;
/


