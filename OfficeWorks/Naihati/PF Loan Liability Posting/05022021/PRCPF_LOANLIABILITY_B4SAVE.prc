CREATE OR REPLACE PROCEDURE NJMCL_WEB.prcPF_LOANLIABILITY_b4Save
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PFLEDGERMAPPING%rowtype;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_CompCode             varchar2(10):='';
lv_DivCode             varchar2(10):='';
lv_YearCode             varchar2(10):='';
lv_YYYYMM               varchar2(6):=''; 
lv_Module               varchar2(10):='';                  
lv_SLNO                 number;
begin

    lv_result:='#SUCCESS#';
    
    
    
        select *
        into lv_Master
        from GBL_PFLEDGERMAPPING
        WHERE ROWNUM<=1;

        select count(*)
        into lv_cnt
        from GBL_PFLEDGERMAPPING;
        
        
--            lv_error_remark := 'Validation Failure : [COUNT ] = '||lv_cnt;
--            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
--       
        
        IF NVL(lv_cnt,0)=0 THEN
            lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;
        
        IF lv_Master.OPERATIONMODE IS NULL THEN
            lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;            
        
        --SELECT ALL VALUES AND ASSIGN TO VARIABLES 
--        SELECT DISTINCT COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, MODULE
--        INTO LV_COMPCODE, LV_DIVCODE, LV_YEARCODE, LV_YYYYMM, LV_MODULE
--        FROM GBL_PFLEDGERMAPPING;
        
        
--        PRC_PFBULKLOAN_POSTING ('NJ0002','0010','2020-2021', '01/05/2020','31/05/2020','P000014','SWT')



       IF (lv_Master.OPERATIONMODE = 'A') THEN

            for c1 in 
            ( 
                SELECT  COMPANYCODE, DIVISIONCODE,YEARCODE, TOKENNO, PFNO, LOANCODE, 
                TO_CHAR(PFLOANDATE,'DD/MM/YYYY') PFLOANDATE, TO_CHAR(PFLOANDATE,'DD/MM/YYYY') VOUCHERDATE, 
                USERNAME, ACCODE, YEARMONTH, FROMDATE,TODATE
                FROM GBL_PFLEDGERMAPPING
                ORDER BY PFLOANDATE, PFNO
            )  
            LOOP
                lv_SLNO := lv_SLNO+1;
                        
                --PROC_PF_LOAN_POSTING ('NJ0002','0010','2020-2021','202005','16/05/2020','SP1308','HBLDG','16/05/2020','P000014',NULL,NULL,'','SWT');
                --DBMS_OUTPUT.PUT_LINE ('SL NO -'||lv_SLNO||', PF NO - '||C1.PFNO||', LOAN CODE - '||C1.LOANCODE||', LOAN DATE - '||C1.PFLOANDATE);
                --           
                --           
                PROC_PF_LOAN_POSTING (C1.COMPANYCODE, C1.DIVISIONCODE,C1.YEARCODE,C1.YEARMONTH,c1.PFLOANDATE ,c1.PFNO,c1.LOANCODE,c1.VOUCHERDATE,C1.ACCODE,NULL,NULL,'',C1.USERNAME);
                --DBMS_OUTPUT.PUT_LINE ('PROC_PF_LOAN_POSTING ('''||C1.COMPANYCODE||''', '''||C1.DIVISIONCODE||''','''||C1.YEARCODE||''','''||C1.YEARMONTH||''','''||c1.PFLOANDATE||''','''||c1.PFNO||''','''||c1.LOANCODE||''','''||c1.VOUCHERDATE||''','''||C1.ACCODE||''',NULL,NULL,'''','''||C1.USERNAME||''')');
                --           

                --PROC_PF_LOAN_POSTING (P_COMPCODE,P_DIVCODE,P_YEARCODE,lv_YYYYMM,c1.PFLOANDATE ,c1.PFNO,c1.LOANCODE,c1.VOUCHERDATE,lv_LIABLITY_ACCODE,NULL,NULL,'',P_USER);
                --EXEC  PRC_PFBULKLOAN_POSTING ('NJ0002','0010','2020-2021', '01/05/2020','31/05/2020','P000014','SWT');

            END LOOP;   
       --*************ADDED ON 05/02/2021
       ELSIF (lv_Master.OPERATIONMODE = 'D') THEN
             insert into PFLEDGERMAPPING
             (
                 WORKERNAME, PFLOANDATE, TODATE, FROMDATE, PF_C, SYSROWID, TOKENNO, ACCODE, PF_E,  USERNAME, 
                 SANCTIONEDAMOUNT, PAYABLEDATE, LOANCODE, VPF, COMPANYCODE, DIVISIONCODE, PFNO, WORKERSERIAL, YEARCODE, YEARMONTH, MODULE
             )
             select WORKERNAME, PFLOANDATE, TODATE, FROMDATE, PF_C, SYSROWID, TOKENNO, ACCODE, PF_E, USERNAME, 
             SANCTIONEDAMOUNT, PAYABLEDATE, LOANCODE, VPF, COMPANYCODE, DIVISIONCODE, PFNO, WORKERSERIAL, YEARCODE, YEARMONTH, MODULE
             from GBL_PFLEDGERMAPPING;
             
            SELECT COUNT(A.ACCODE) INTO LV_CNT
            FROM ACVOUCHERDETAILS_ENTRY A, ACACLEDGER B
            WHERE SYSTEMVOUCHERNO=
            (
                SELECT MAX(SYSTEMVOUCHERNO) FROM PFLOANTRANSACTION A
                WHERE SYSTEMVOUCHERNO IS NOT NULL
                and NVL(a.ACTUALLOANDATE, a.LOANDATE) > LV_MASTER.TODATE
            )
            AND A.DRCR='C'
            AND A.ACCODE=B.ACCODE;
            
            IF LV_CNT > 0 THEN
                lv_error_remark := 'Validation Failure : [Delete Opearion is working only for last posting..]';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            END IF;
            
            FOR C1 IN 
            ( 
                SELECT A.COMPANYCODE, A.DIVISIONCODE,A.LOANCODE, A.LOANDATE, A.YEARCODE,
                A.WORKERSERIAL, A.TOKENNO, A.SYSTEMVOUCHERNO, A.SYSTEMVOUCHERDATE 
                FROM PFLOANTRANSACTION A, GBL_PFLEDGERMAPPING B
                WHERE A.SYSTEMVOUCHERNO IS NOT NULL
                and A.COMPANYCODE=B.COMPANYCODE
                AND A.DIVISIONCODE=B.DIVISIONCODE
                AND A.WORKERSERIAL=B.WORKERSERIAL
                AND NVL(A.ACTUALLOANDATE, A.LOANDATE)=B.PFLOANDATE
                AND A.LOANCODE=B.LOANCODE
                AND A.YEARMONTH=B.YEARMONTH
            )  
            LOOP
                lv_SLNO := lv_SLNO+1;
                        
                prc_delete_systemvoucher(C1.COMPANYCODE,C1.DIVISIONCODE, C1.YEARCODE, C1.SYSTEMVOUCHERNO, 'FORCED');
                
                                

                UPDATE PFLOANTRANSACTION
                SET  VOUCHERNO = NULL,
                VOUCHERDATE = NULL,
                SYSTEMVOUCHERNO = NULL,
                SYSTEMVOUCHERDATE = NULL
                WHERE SYSTEMVOUCHERNO IS NOT NULL
                AND SYSTEMVOUCHERNO = C1.SYSTEMVOUCHERNO; 


                UPDATE PFLOANAPPLICATION
                SET  VOUCHERNO = NULL,
                VOUCHERDATE = NULL,
                SYSTEMVOUCHERNO = NULL,
                SYSTEMVOUCHERDATE = NULL
                WHERE SYSTEMVOUCHERNO IS NOT NULL
                AND SYSTEMVOUCHERNO = C1.SYSTEMVOUCHERNO; 


                UPDATE PFTRANSACTIONDETAILS
                SET  VOUCHERNO = NULL,
                VOUCHERDATE = NULL,
                SYSTEMVOUCHERNO = NULL,
                SYSTEMVOUCHERDATE = NULL
                WHERE SYSTEMVOUCHERNO IS NOT NULL
                AND SYSTEMVOUCHERNO = C1.SYSTEMVOUCHERNO; 

               
            END LOOP; 
       --*************ENDED ON 05/02/2021
       END IF;
end;
/
