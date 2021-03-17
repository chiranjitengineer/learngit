DROP PROCEDURE NJMCL_WEB.PROC_WPSWORKERRATE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSWORKERRATE (P_COMPCODE VARCHAR2, P_DIVCODE VARCHAR2, P_ASONDATE VARCHAR2,P_TABLE VARCHAR2,P_PROCESSTYPE  VARCHAR2 DEFAULT 'WAGES PROCESS')
as 
lv_AsOnDT  DATE := TO_DATE(P_ASONDATE,'DD/MM/YYYY');
lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_ProcName         varchar2(30) := 'PROC_WPSWORKERRATE';
lv_SqlStr           varchar2(4000);
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_MastComponent    varchar2(500) := '';
begin

    lv_Remarks := 'WORKERWISE RATE CREATION FROM RATEUPDATE TABLE';
    --DBMS_OUTPUT.PUT_LINE(LENGTH(lv_MastComponent));
    
   FOR C2 IN (
        SELECT A.COMPONENTCODE, A.COMPONENTSHORTNAME, A.COMPONENTNAME, A.COMPONENTTYPE, A.COMPONENTGROUP, A.PHASE, A.COMPONENTTAG, 
        A.FORMULA, A.CALCULATIONINDEX, nvl(MASTERCOMPONENT,'N') MASTERCOMPONENT 
        FROM WPSCOMPONENTMASTER A 
        WHERE A.COMPANYCODE = P_COMPCODE AND A.DIVISIONCODE = P_DIVCODE
          AND TAKEPARTINWAGES = 'Y' AND NVL(MASTERCOMPONENT,'N') = 'Y'
        ORDER BY CALCULATIONINDEX        
        ) 
   LOOP
       IF C2.MASTERCOMPONENT = 'Y' THEN
           if nvl(LENGTH(lv_MastComponent),0) = 0 then
               lv_MastComponent := 'NVL('||C2.COMPONENTSHORTNAME||',0) AS '||C2.COMPONENTSHORTNAME||' ';
           ELSE
               lv_MastComponent := lv_MastComponent ||', NVL('||C2.COMPONENTSHORTNAME||',0) AS '||C2.COMPONENTSHORTNAME||' ';
           END IF;
       end if;        
--        DBMS_OUTPUT.PUT_LINE (lv_MastComponent);
   END LOOP;
--    DBMS_OUTPUT.PUT_LINE('XX');
    lv_SqlStr := 'DROP TABLE WPSRATEUPDT_MAXDT';
   BEGIN 
        execute immediate lv_SqlStr;
   EXCEPTION WHEN OTHERS THEN NULL;
   END;
   lv_SqlStr := ' CREATE TABLE WPSRATEUPDT_MAXDT AS '||CHR(10)
               ||' SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, MAX(EFFECTIVEDATE) EFFECTIVEDATE '||CHR(10) ;
                if P_PROCESSTYPE='VOUCHER PROCESS' then
                    lv_SqlStr := lv_SqlStr ||' FROM WPSVOUCHERWORKERWISERATEUPDATE '||CHR(10);
                ELSE
                    lv_SqlStr := lv_SqlStr ||' FROM WPSWORKERWISERATEUPDATE '||CHR(10);
                END IF;
               lv_SqlStr := lv_SqlStr ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
               ||'   AND EFFECTIVEDATE <= TO_DATE('''||P_ASONDATE||''',''DD/MM/YYYY'') '||CHR(10)
               ||' GROUP BY COMPANYCODE, DIVISIONCODE, WORKERSERIAL '||CHR(10);
    
   EXECUTE IMMEDIATE lv_SqlStr;
   insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
   values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_AsOnDT,lv_AsOnDT, 'TABLE - WORKER WISE MAX EFFECTIVE DATE FROM WPSWORKERWISEEFFECTIVEDATE');
   COMMIT;    
 
   lv_SqlStr := 'DROP TABLE '||P_TABLE||' ';
   BEGIN 
       execute immediate lv_SqlStr;
   EXCEPTION WHEN OTHERS THEN NULL;
   END;
   --DBMS_OUTPUT.PUT_LINE ('MASTER COMPONENT 1 - '||LENGTH(RTRIM(LTRIM(lv_MastComponent))));
   IF LENGTH(RTRIM(LTRIM(NVL(lv_MastComponent,'X')))) <=1 THEN
        lv_MastComponent := 'FBASIC,DA,ADHOC'; 
   END IF; 
   --DBMS_OUTPUT.PUT_LINE ('MASTER COMPONENT 2 - '||LENGTH(RTRIM(LTRIM(lv_MastComponent))));
   lv_SqlStr := '';
   lv_SqlStr := ' CREATE TABLE '||P_TABLE||' AS '||CHR(10)
               ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.EFFECTIVEDATE, '||CHR(10)
               ||' '||lv_MastComponent||' '||CHR(10) ;
                if P_PROCESSTYPE='VOUCHER PROCESS' then
                  lv_SqlStr := lv_SqlStr ||' FROM WPSVOUCHERWORKERWISERATEUPDATE A, WPSRATEUPDT_MAXDT B '||CHR(10);
                ELSE
                lv_SqlStr := lv_SqlStr ||' FROM WPSWORKERWISERATEUPDATE A, WPSRATEUPDT_MAXDT B '||CHR(10);
                END IF;
               lv_SqlStr := lv_SqlStr ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
               ||'   AND A.COMPANYCODE =  B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
               ||'   AND A.WORKERSERIAL = B.WORKERSERIAL AND A.EFFECTIVEDATE = B.EFFECTIVEDATE '||CHR(10);
   EXECUTE IMMEDIATE lv_SqlStr;
   insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
   values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_AsOnDT,lv_AsOnDT, 'TABLE - WORKER WISE MAX EFFECTIVE DATE FROM WPSWORKERWISEEFFECTIVEDATE');
   COMMIT;
exception
when others then
 lv_sqlerrm := sqlerrm ;
 insert into WPS_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
 values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_AsOnDT,lv_AsOnDT, lv_Remarks);
END;
/


