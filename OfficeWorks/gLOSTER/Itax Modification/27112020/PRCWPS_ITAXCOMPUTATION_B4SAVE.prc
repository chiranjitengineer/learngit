CREATE OR REPLACE PROCEDURE GLOSTER_WEB."PRCWPS_ITAXCOMPUTATION_B4SAVE" 
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PISITAXCOMPUTATION%rowtype;
lv_MaxDRCRdate            date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);
lv_SqlStr               varchar2(1000);   
lv_ProcName             varchar2(50) := 'PRCWPS_ITAXCOMPUTATION_B4SAVE';

begin

    lv_result:='#SUCCESS#';
    
   -- RETURN;
   
    select *
    into lv_Master
    from GBL_PISITAXCOMPUTATION
    WHERE ROWNUM<=1;

    --delete previous records from actual table
  
                        
     IF lv_Master.OPERATIONMODE = 'A' THEN
     
        DELETE FROM PISITAXCOMPUTATION
        WHERE COMPANYCODE =  LV_MASTER.COMPANYCODE
        AND DIVISIONCODE =  LV_MASTER.DIVISIONCODE
--        AND CATEGORYCODE = LV_MASTER.CATEGORYCODE
--        AND GRADECODE = LV_MASTER.GRADECODE
        AND YEARCODE = LV_MASTER.YEARCODE
        and WORKERSERIAL= LV_MASTER.WORKERSERIAL;
                        
delete from PIS_ERROR_LOG where 1=1;
        IF lv_Master.ISPROCESSALL = 'Y' THEN
        
--            DELETE FROM PISITAXCOMPUTATION
--            WHERE COMPANYCODE =  LV_MASTER.COMPANYCODE
--            AND DIVISIONCODE =  LV_MASTER.DIVISIONCODE
----            AND CATEGORYCODE = LV_MASTER.CATEGORYCODE
----            AND GRADECODE = LV_MASTER.GRADECODE 
--            AND YEARCODE = LV_MASTER.YEARCODE
--            AND WORKERSERIAL IN 
--            (
--                select DISTINCT WORKERSERIAL
--                from PISEMPLOYEEMASTER 
--                WHERE COMPANYCODE =  lv_Master.COMPANYCODE
--                AND DIVISIONCODE =  lv_Master.DIVISIONCODE
--                AND CATEGORYCODE = lv_Master.CATEGORYCODE
--                AND GRADECODE = lv_Master.GRADECODE
--                AND EMPLOYEESTATUS ='ACTIVE' 
--            );
                    
            FOR C1 IN ( select CATEGORYCODE, GRADECODE, TOKENNO, WORKERSERIAL
                        from PISEMPLOYEEMASTER 
                        WHERE COMPANYCODE =  lv_Master.COMPANYCODE
                        AND DIVISIONCODE =  lv_Master.DIVISIONCODE
                        AND CATEGORYCODE = lv_Master.CATEGORYCODE
                        AND GRADECODE = lv_Master.GRADECODE
                        AND EMPLOYEESTATUS ='ACTIVE' 
                        )
                LOOP
                   -- DBMS_OUTPUT.PUT_LINE('TOKEN - '||C1.TOKENNO);
                       
                  -- IF C1.TOKENNO <> lv_Master.TOKENNO THEN   
                   
                    DELETE FROM PISITAXCOMPUTATION 
                    WHERE COMPANYCODE = lv_Master.COMPANYCODE 
                      AND DIVISIONCODE = lv_Master.DIVISIONCODE
                      AND YEARCODE = lv_Master.YEARCODE
                      AND WORKERSERIAL =  C1.WORKERSERIAL;
                     
                    lv_SqlStr := 'PROC_PISITAX_COMPUTATION ('''||lv_Master.COMPANYCODE||''', '''||lv_Master.DIVISIONCODE||''', '''||lv_Master.YEARCODE||''', '''||C1.CATEGORYCODE||''', '''||C1.GRADECODE||''', '''||C1.TOKENNO||''');'; 
                    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
                    values( lv_Master.COMPANYCODE, lv_Master.DIVISIONCODE, lv_ProcName,'',SYSDATE,lv_SqlStr,'', SYSDATE, SYSDATE, 'PROC_PISITAX_COMPUTATION');
                      
             

                     PROC_PISITAX_COMPUTATION (lv_Master.COMPANYCODE, lv_Master.DIVISIONCODE, lv_Master.YEARCODE,C1.CATEGORYCODE,C1.GRADECODE, C1.TOKENNO);
                     
--                     INSERT INTO GBL_PISITAXCOMPUTATION
--                     (
--                         COMPONENTHEADER, COMPONENTCODE, COMPACTUALVALUE, COMPPROJCTEDVALUE, COMPMANUALVALUE,COMPARREARVALUE, COLUMNFORSUBTOTAL, COLUMNNO, COMPVALUE,
--                         COMPONENTTYPE,  ACTUALCOMPCODE, FORMULARATE, MANUALFORMULA, SERIALNO, COMPANYCODE, DIVISIONCODE, YEARCODE,
--                         WORKERSERIAL, TOKENNO, USERNAME, SYSROWID, OPERATIONMODE, CATEGORYCODE, GRADECODE  
--                     )
--                     SELECT COMPONENTHEADER, COMPONENTCODE, COMPACTUALVALUE, COMPPROJCTEDVALUE, COMPMANUALVALUE,COMPARREARVALUE, COLUMNFORSUBTOTAL, COLUMNNO, COMPVALUE,
--                     COMPONENTTYPE,  ACTUALCOMPCODE, FORMULARATE, MANUALFORMULA, SERIALNO, COMPANYCODE, DIVISIONCODE, YEARCODE,
--                     WORKERSERIAL, TOKENNO, lv_Master.USERNAME, NULL SYSROWID, lv_Master.OPERATIONMODE, CATEGORYCODE, GRADECODE
--                     FROM GTTPISITAXCOMPUTATION
--                     WHERE NVL(DISPLAYINGRID,'N')='Y';
                    

                     INSERT INTO PISITAXCOMPUTATION
                     (
                         COMPONENTHEADER, COMPONENTCODE, COMPACTUALVALUE, COMPPROJCTEDVALUE, COMPMANUALVALUE,COMPARREARVALUE, COLUMNFORSUBTOTAL, COLUMNNO, COMPVALUE,
                         COMPONENTTYPE,  ACTUALCOMPCODE, FORMULARATE, MANUALFORMULA, SERIALNO, COMPANYCODE, DIVISIONCODE, YEARCODE,
                         WORKERSERIAL, TOKENNO, USERNAME, SYSROWID--,  CATEGORYCODE, GRADECODE
                     )
                     SELECT COMPONENTHEADER, COMPONENTCODE, COMPACTUALVALUE, COMPPROJCTEDVALUE, COMPMANUALVALUE,COMPARREARVALUE, COLUMNFORSUBTOTAL, COLUMNNO, COMPVALUE,
                     COMPONENTTYPE,  ACTUALCOMPCODE, FORMULARATE, MANUALFORMULA, SERIALNO, COMPANYCODE, DIVISIONCODE, YEARCODE,
                     WORKERSERIAL, TOKENNO, lv_Master.USERNAME, SYS_GUID() SYSROWID--, CATEGORYCODE, GRADECODE
                     FROM GTTPISITAXCOMPUTATION
                     WHERE NVL(DISPLAYINGRID,'N')='Y';
                    

                  --  END IF;
                      
                END LOOP;
            
        END IF;      
     
     END IF;
     
     
end;
/