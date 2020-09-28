CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPT_ED_STATEMENT_NEW
--exec PROC_RPT_ED_STATEMENT_NEW('NJ0001','0002','2019-2020','01/02/2020','15/02/2020','REGULAR WORKER WITH CONTROL','','','')
(
    P_COMPANYCODE       VARCHAR2,
    P_DIVISIONCODE      VARCHAR2,
    P_YEARCODE          VARCHAR2,
    P_FROMDATE          VARCHAR2,
    P_TODATE            VARCHAR2,
    P_REPORTOPTION      VARCHAR2,
    P_CATEGORYCODE      VARCHAR2   DEFAULT NULL,
    P_DEPARTMENTCODE    VARCHAR2   DEFAULT NULL,
    P_TOKENNO           VARCHAR2   DEFAULT NULL    
)
AS 
/************* ADDED BY PRASUN ON 16062020 FOR NAIHATI JUTE MILL*****************/

    LV_SQLSTR           VARCHAR2(32000); 
    LV_INSERTSTR VARCHAR2(4000); 
    LV_COMPANYNAME VARCHAR2(100);
    LV_SRL NUMBER(5) := 0; 
    LV_CATEGORYCODE VARCHAR2(100); 
    LV_DEPARTMENTNAME  VARCHAR2(100);
    LV_CNT      NUMBER(10);
    LV_PAGENO  NUMBER(10) := 0;    
    P_INT1  NUMBER(20) := 0;
    LV_TOTCOLS VARCHAR2(20);
    LV_CNTRECORD INT;
   
    --added on 22/09/2020 EACH EMPLYEE LINE COUNT
    LV_EACHEMPLINECNT INT := 0;
    --added on 22/09/2020
BEGIN

        DELETE FROM GTT_TEXT_REPORT;
        DELETE FROM GTT_ED_TABLE1; 
        DELETE FROM GTT_ED_TABLE2;   
         
        SELECT COUNT(REPORTOPTION) INTO LV_CNTRECORD FROM SYS_RPT_QRY WHERE MENUCODE='0110040229' AND ORDERBY IN (1,3,5,7,9) AND REPORTOPTION=P_REPORTOPTION;        
          
       --regular with control 
       
        IF LV_CNTRECORD>0 THEN   
            /******************* Start Detail ***************************/ 

           -- DBMS_OUTPUT.PUT_LINE('SHOW 1');       

            DELETE FROM GTT_ED_TABLE1;        
            LV_SQLSTR := FN_RPT_ED_STATEMENT_NEW_GETSQL(P_COMPANYCODE,P_DIVISIONCODE,P_YEARCODE,P_FROMDATE,P_TODATE,P_REPORTOPTION,'DETAIL1',P_CATEGORYCODE,P_DEPARTMENTCODE,P_TOKENNO);        
            DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);           
            EXECUTE IMMEDIATE LV_SQLSTR;

                                    
            DELETE FROM GTT_ED_TABLE2;                 
            LV_SQLSTR := FN_RPT_ED_STATEMENT_NEW_GETSQL(P_COMPANYCODE,P_DIVISIONCODE,P_YEARCODE,P_FROMDATE,P_TODATE,P_REPORTOPTION,'DETAIL2',P_CATEGORYCODE,P_DEPARTMENTCODE,P_TOKENNO);  
            DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);           
            EXECUTE IMMEDIATE LV_SQLSTR;
               
                          
           /*******************Check Data Exist***************************/
            SELECT COUNT(*) INTO LV_CNT  FROM GTT_ED_TABLE1 ;
            
            IF LV_CNT = 0 THEN
                RAISE_APPLICATION_ERROR(-20111,'NO DATA FOUND !!!!!');
                RETURN;        
            END IF;
            /*******************End Check Data Exist***************************/
                            
                           
            
            FOR C1 IN (
                SELECT              
                DEPARTMENTCODE, SECTIONCODE, OCCUPATIONCODE, TOKENNO, WORKERSERIAL, WORKERNAME,FORTNIGHTENDDATE, ESINO, PFNO, PENSIONNO, BANKACNO,
                NVL(INCN,0) INCN, NVL(EPFL,0) EPFL, NVL(EPFN,0) EPFN, NVL(CBF,0) CBF, NVL(MPFGR,0) MPFGR, NVL(MBGR,0) MBGR,
                NVL(MTXGR,0) MTXGR, NVL(YBNGR,0) YBNGR, NVL(ESIGR,0) ESIGR, NVL(YFPFD,0) YFPFD, NVL(YPFD,0) YPFD, NVL(YDAYS,0) YDAYS,
                NVL(PFLBL,0) PFLBL, NVL(PFIBAL,0) PFIBAL, NVL(COBAL,0) COBAL, NVL(FSBAL,0) FSBAL, NVL(ELBAL,0) ELBAL, NVL(PF,0) PF,
                NVL(FPF,0) FPF, NVL(ESI,0) ESI, NVL(PTAX,0) PTAX, NVL(LWF,0) LWF, NVL(HRD,0) HRD, NVL(PFLND,0) PFLND, NVL(PFIND,0) PFIND,
                NVL(COLN,0) COLN, NVL(FSLN,0) FSLN, NVL(ELEINST,0) ELEINST, NVL(DPFLN,0) DPFLN, NVL(DPFN,0) DPFN, NVL(CCF,0) CCF,
                NVL(TOTALERN,0) TOTALERN, NVL(TOTDEDN,0) TOTDEDN, NVL(NETPAY,0) NETPAY
                FROM GTT_ED_TABLE1 ORDER BY SRLNO
                     )                        
            LOOP 
            
                   SELECT COUNT(*) INTO LV_EACHEMPLINECNT FROM GTT_ED_TABLE2 WHERE WORKERSERIAL = C1.WORKERSERIAL;
                               
                    /*******************Print Headert***************************/
--                    IF P_INT1 = 0 OR P_INT1 >=62  THEN 
                    IF P_INT1 = 0 OR (P_INT1+12+LV_EACHEMPLINECNT) >=62  THEN 
                                                                            
                        LV_PAGENO := LV_PAGENO + 1; 
                        
                        IF (P_INT1+12+LV_EACHEMPLINECNT) >=62  THEN
                        
                            P_INT1 := 0;
                            PROC_INSERT_TEXT_REPORT(PKG_PRINT_TEXT.p_NewPage);
                        
                        END IF;
                             
--                        LV_INSERTSTR := '  '||PKG_PRINT_TEXT.p_BoldOn||PKG_PRINT_TEXT.fnalign('NJM - HAZINAGAR',40,'L')
--                                ||PKG_PRINT_TEXT.fnalign('EARNING-DEDUCTION STATEMENT FOR THE PERIOD ENDING : '|| P_TODATE,84,'L')
--                                ||PKG_PRINT_TEXT.p_BoldOff||PKG_PRINT_TEXT.fnalign('Run Date '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),36,'R');
--                                
                                
                         --LV_INSERTSTR := '  '||PKG_PRINT_TEXT.p_BoldOn||PKG_PRINT_TEXT.fnalign('NJM - HAZINAGAR',27,'L')
                         -- changes 05.08.2020 
                         --LV_INSERTSTR := '  '||PKG_PRINT_TEXT.p_BoldOn||PKG_PRINT_TEXT.p_CompOn||PKG_PRINT_TEXT.p_NormalSmall||PKG_PRINT_TEXT.fnalign('NJM - HAZINAGAR',27,'L')
                         LV_INSERTSTR := '  '||PKG_PRINT_TEXT.p_BoldOn||PKG_PRINT_TEXT.p_NormalSmall||PKG_PRINT_TEXT.fnalign('NJM - HAZINAGAR',27,'L')
                                ||PKG_PRINT_TEXT.fnalign('EARNING-DEDUCTION STATEMENT FOR THE PERIOD ENDING : '|| P_TODATE|| '('||P_REPORTOPTION||')',110,'L')
                                --||PKG_PRINT_TEXT.p_BoldOff||PKG_PRINT_TEXT.p_CompOn||PKG_PRINT_TEXT.fnalign('Run Date '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),23,'R');
                                ||PKG_PRINT_TEXT.p_BoldOff||PKG_PRINT_TEXT.fnalign('Run Date '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),23,'R');                
                                
                                
                        P_INT1 := P_INT1 + 1;
                        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
                        
                        LV_INSERTSTR := '  ';
                        P_INT1 := P_INT1 + 1;
                        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
                                                                                                                      
                    END IF;          
                    /*******************End Print Headert***************************/
                    
                    /******************* Start Print Body***************************/
                    
                    LV_INSERTSTR := '  '||LPAD('-',160,'-');
                    P_INT1 := P_INT1 + 1;
                    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);

                    --change 05.08.2020
                    --LV_INSERTSTR := '  '||PKG_PRINT_TEXT.p_CompOn||PKG_PRINT_TEXT.p_NormalSmall||PKG_PRINT_TEXT.fnalign('EMPCODE:', 8, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.TOKENNO, 11, 'L')
                     LV_INSERTSTR := '  '||PKG_PRINT_TEXT.fnalign('EMPCODE:', 8, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.TOKENNO, 11, 'L')
                            ||' '||PKG_PRINT_TEXT.fnalign('NAME:', 5, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.WORKERNAME, 26, 'L')
                            ||' '||PKG_PRINT_TEXT.fnalign('ESINO:', 6, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.ESINO, 10, 'L')
                            ||' '||PKG_PRINT_TEXT.fnalign('PFNO:', 5, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.PFNO, 6, 'L')
                            ||' '||PKG_PRINT_TEXT.fnalign('EPSNO:', 6, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.PENSIONNO, 4, 'L')
                            ||' '||PKG_PRINT_TEXT.fnalign('BANK A/C:', 9, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.BANKACNO, 20, 'L')                            
                            ||' '||PKG_PRINT_TEXT.fnalign('BM:', 4, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.FORTNIGHTENDDATE, 10, 'L')  ;                                                    
                    P_INT1 := P_INT1 + 1;
                    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
                        
                    LV_INSERTSTR := '  '||LPAD('-',160,'-');
                    P_INT1 := P_INT1 + 1;
                    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
                        
                        
                    LV_INSERTSTR := '  '||'DPSCS OCC SRLN ATDYS ATHRS NSHRS OT_HRS OTNSH ATTREWD    BASIC       DA   ADHOC     TSA       FE '
                                        ||'   OTAMT   NSAMT    HRAMT  HOLIAMT   LFAMT  STLAMT';
                    P_INT1 := P_INT1 + 1;
                    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);                   
                        
                    LV_INSERTSTR := '  ';
                    P_INT1 := P_INT1 + 1;
                    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
                     
                       
                        FOR C2 IN  (
                                    SELECT SRL, WORKERSERIAL, DEPARTMENTCODE, SECTIONCODE,SHIFTCODE OCCUPATIONCODE, TOKENNO, DPSCS, OCC, SRLN,       
                                    NVL(ATDYS,0) ATDYS, NVL(ATHRS,0) ATHRS, NVL(NSHRS,0) NSHRS, NVL(OT_HRS,0) OT_HRS, NVL(OTNSH,0) OTNSH,
                                    NVL(ATTREWD,0) ATTREWD, NVL(BASIC,0) BASIC, NVL(DA,0) DA, NVL(ADHOC,0) ADHOC, NVL(TSA,0) TSA, NVL(FE,0) FE,
                                    NVL(OTAMT,0) OTAMT, NVL(NSAMT,0) NSAMT, NVL(HRAMT,0) HRAMT, NVL(HOLIAMT,0) HOLIAMT, NVL(LFAMT,0) LFAMT,
                                    NVL(STLAMT,0) STLAMT
                                    FROM GTT_ED_TABLE2
                                    WHERE WORKERSERIAL = C1.WORKERSERIAL
                                    --ORDER BY DEPARTMENTCODE, SECTIONCODE, SHIFTCODE, TO_NUMBER(SRLN)
                                    ORDER BY SRL 
                                   )   
                        LOOP
                            --change 05.08.2020
                            --LV_INSERTSTR := '  '||PKG_PRINT_TEXT.p_CompOn||PKG_PRINT_TEXT.p_NormalSmall||PKG_PRINT_TEXT.fnalign(C2.DPSCS, 5, 'L')||' '||PKG_PRINT_TEXT.fnalign(C2.OCC, 3, 'L')
                            LV_INSERTSTR := '  '||PKG_PRINT_TEXT.fnalign(C2.DPSCS, 5, 'L')||' '||PKG_PRINT_TEXT.fnalign(C2.OCC, 3, 'L') 
                                ||' '||PKG_PRINT_TEXT.fnalign(C2.SRLN, 4, 'R')||' '||PKG_PRINT_TEXT.fnalign(C2.ATDYS, 5, 'R',2)
                                ||' '||PKG_PRINT_TEXT.fnalign(C2.ATHRS, 5, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C2.NSHRS, 5, 'R',2)
                                ||' '||PKG_PRINT_TEXT.fnalign(C2.OT_HRS, 6, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C2.OTNSH, 5, 'R',2)
                                ||' '||PKG_PRINT_TEXT.fnalign(C2.ATTREWD, 7, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C2.BASIC, 8, 'R',2)
                                ||' '||PKG_PRINT_TEXT.fnalign(C2.DA, 8, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C2.ADHOC, 7, 'R',2)
                                ||' '||PKG_PRINT_TEXT.fnalign(C2.TSA, 7, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C2.FE, 8, 'R',2)
                                ||' '||PKG_PRINT_TEXT.fnalign(C2.OTAMT, 8, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C2.NSAMT, 7, 'R',2)
                                ||' '||PKG_PRINT_TEXT.fnalign(C2.HRAMT, 8, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C2.HOLIAMT, 8, 'R',2)
                                ||' '||PKG_PRINT_TEXT.fnalign(C2.LFAMT, 7, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C2.STLAMT, 7, 'R',2);                                                                           
                            P_INT1 := P_INT1 + 1;
                            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
                                
                        END LOOP;
                    
                    
                    
                        FOR C3 IN  
                        (
                            
                            SELECT SUM(NVL(ATDYS,0)) ATDYS, SUM(NVL(ATHRS,0)) ATHRS, SUM(NVL(NSHRS,0)) NSHRS, SUM(NVL(OT_HRS,0)) OT_HRS, SUM(NVL(OTNSH,0)) OTNSH,
                            SUM(NVL(ATTREWD,0)) ATTREWD, SUM(NVL(BASIC,0)) BASIC, SUM(NVL(DA,0)) DA, SUM(NVL(ADHOC,0)) ADHOC, SUM(NVL(TSA,0)) TSA, SUM(NVL(FE,0)) FE,
                            SUM(NVL(OTAMT,0)) OTAMT, SUM(NVL(NSAMT,0)) NSAMT, SUM(NVL(HRAMT,0)) HRAMT, SUM(NVL(HOLIAMT,0)) HOLIAMT, SUM(NVL(LFAMT,0)) LFAMT,SUM(NVL(STLAMT,0)) STLAMT
                            FROM GTT_ED_TABLE2 WHERE WORKERSERIAL = C1.WORKERSERIAL
                        )
                        LOOP
                               --change 05.08.2020
                               --LV_INSERTSTR := '  '||' '||PKG_PRINT_TEXT.p_CompOn||PKG_PRINT_TEXT.p_NormalSmall||PKG_PRINT_TEXT.fnalign(' TOTERN : ', 13, 'R')||' '||PKG_PRINT_TEXT.fnalign(C3.ATDYS, 5, 'R',2)
                               LV_INSERTSTR := '  '||' '||PKG_PRINT_TEXT.p_Normal||PKG_PRINT_TEXT.fnalign(' TOTERN : ', 13, 'R')||' '||PKG_PRINT_TEXT.fnalign(C3.ATDYS, 5, 'R',2)
                                ||' '||PKG_PRINT_TEXT.fnalign(C3.ATHRS, 5, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C3.NSHRS, 5, 'R',2)
                                ||' '||PKG_PRINT_TEXT.fnalign(C3.OT_HRS, 6, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C3.OTNSH, 5, 'R',2)
                                ||' '||PKG_PRINT_TEXT.fnalign(C3.ATTREWD, 7, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C3.BASIC, 8, 'R',2)
                                ||' '||PKG_PRINT_TEXT.fnalign(C3.DA, 8, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C3.ADHOC, 7, 'R',2)
                                ||' '||PKG_PRINT_TEXT.fnalign(C3.TSA, 7, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C3.FE, 8, 'R',2)
                                ||' '||PKG_PRINT_TEXT.fnalign(C3.OTAMT, 8, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C3.NSAMT, 7, 'R',2)
                                ||' '||PKG_PRINT_TEXT.fnalign(C3.HRAMT, 8, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C3.HOLIAMT, 8, 'R',2)
                                ||' '||PKG_PRINT_TEXT.fnalign(C3.LFAMT, 7, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C3.STLAMT, 7, 'R',2);                                                                           
                            P_INT1 := P_INT1 + 1;
                            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);                     
                        END LOOP;
                    
            
                    
                    
                    LV_INSERTSTR := '  ';
                    P_INT1 := P_INT1 + 1;
                    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
                        
                   -- LV_INSERTSTR := '  '||'               '||PKG_PRINT_TEXT.p_NormalSmall||PKG_PRINT_TEXT.fnalign('INCN:', 5, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.INCN, 8, 'R',2)
                   LV_INSERTSTR := '  '||'               '||PKG_PRINT_TEXT.fnalign('INCN:', 5, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.INCN, 8, 'R',2)
                        ||' '||PKG_PRINT_TEXT.fnalign(' EPFL:', 6, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.EPFL, 8, 'R',2)
                        ||' '||PKG_PRINT_TEXT.fnalign(' EPFN:', 6, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.EPFN, 8, 'R',2)
                        ||' '||PKG_PRINT_TEXT.fnalign('  CBF:', 6, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.CBF, 5, 'R',2)
                        ||' '||PKG_PRINT_TEXT.fnalign('     MPFGR:', 9, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.MPFGR, 10, 'R',2)
                        ||' '||PKG_PRINT_TEXT.fnalign(' MBGR:', 6, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.MBGR, 10, 'R',2)
                        ||' '||PKG_PRINT_TEXT.fnalign('MTXGR:', 6, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.MTXGR, 10, 'R',2)
                        ||' '||PKG_PRINT_TEXT.fnalign('YBNGR:', 6, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.YBNGR, 10, 'R',2);                                                                            
                    P_INT1 := P_INT1 + 1;
                    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
                        
                    LV_INSERTSTR := '  ';
                    P_INT1 := P_INT1 + 1;
                    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
                        
                    --LV_INSERTSTR := '  '||'               '||PKG_PRINT_TEXT.p_NormalSmall||PKG_PRINT_TEXT.fnalign('YPFD:', 5, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.YPFD, 8, 'R',2)
                    LV_INSERTSTR := '  '||'               '||PKG_PRINT_TEXT.fnalign('YPFD:', 5, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.YPFD, 8, 'R',2)
                        ||' '||PKG_PRINT_TEXT.fnalign('YFPFD:', 6, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.YFPFD, 8, 'R',2)
                        ||' '||PKG_PRINT_TEXT.fnalign('YDAYS:', 6, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.YDAYS, 8, 'R',2)
                        ||' '||PKG_PRINT_TEXT.fnalign('PFBAL:', 6, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.PFLBL, 9, 'R',2)
                        ||' '||PKG_PRINT_TEXT.fnalign('PFIBAL:', 7, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.PFIBAL, 9, 'R',2)
                        ||' '||PKG_PRINT_TEXT.fnalign('COBAL:', 6, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.COBAL, 9, 'R',2)
                        ||' '||PKG_PRINT_TEXT.fnalign('FSBAL:', 6, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.FSBAL, 10, 'R',2)
                        ||' '||PKG_PRINT_TEXT.fnalign('ELBAL:', 6, 'L')||' '||PKG_PRINT_TEXT.fnalign(C1.ELBAL, 10, 'R',2);                                                                            
                    P_INT1 := P_INT1 + 1;
                    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);  
                    
                    LV_INSERTSTR := '  ';
                    P_INT1 := P_INT1 + 1;
                    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);                                      
                        
                    LV_INSERTSTR := '  '||'                   PF     FPF     ESI    PTAX   LWF      HRD    PFLND    PFIND     COLN     FSLN  ELEINST    DPFLN     DPFN   CCF  TOTALERN   TOTDEDN    NETPAY';
                    P_INT1 := P_INT1 + 1;
                    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);   
                        
                        
                    --LV_INSERTSTR := '  '||PKG_PRINT_TEXT.p_CompOn||PKG_PRINT_TEXT.p_NormalSmall||PKG_PRINT_TEXT.fnalign('TOTDEDN :', 14, 'R')||' '||PKG_PRINT_TEXT.fnalign(C1.PF, 6, 'R',2)
                    LV_INSERTSTR := '  '||PKG_PRINT_TEXT.fnalign('TOTDEDN :', 14, 'R')||' '||PKG_PRINT_TEXT.fnalign(C1.PF, 6, 'R',2) 
                        ||' '||PKG_PRINT_TEXT.fnalign(C1.FPF, 7, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C1.ESI, 7, 'R',2)
                        ||' '||PKG_PRINT_TEXT.fnalign(C1.PTAX, 7, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C1.LWF, 5, 'R',2) 
                        ||' '||PKG_PRINT_TEXT.fnalign(C1.HRD, 8, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C1.PFLND, 8, 'R',2) 
                        ||' '||PKG_PRINT_TEXT.fnalign(C1.PFIND, 8, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C1.COLN, 8, 'R',2) 
                        ||' '||PKG_PRINT_TEXT.fnalign(C1.FSLN, 8, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C1.ELEINST, 8, 'R',2) 
                        ||' '||PKG_PRINT_TEXT.fnalign(C1.DPFLN, 8, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C1.DPFN, 8, 'R',2) 
                        ||' '||PKG_PRINT_TEXT.fnalign(C1.CCF, 5, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C1.TOTALERN, 9, 'R',2) 
                        ||' '||PKG_PRINT_TEXT.fnalign(C1.TOTDEDN, 9, 'R',2)||' '||PKG_PRINT_TEXT.fnalign(C1.NETPAY, 9, 'R',2)||PKG_PRINT_TEXT.p_CompOff;  
                                                                                                      
                    P_INT1 := P_INT1 + 1;
                    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
            
                    LV_INSERTSTR := '  '||LPAD('=',160,'=');
                    P_INT1 := P_INT1 + 1;
                    PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
                    
                    /******************* End Print Body***************************/
            
            END LOOP;
                  
        END IF;
        
        --end regular with control
        
       /******************* End Detail ***************************/ 
               
        
        --regular with control, only control
        /******************* Start Control ***************************/
        
       
        
            
            IF LV_PAGENO  > 0 THEN 
                LV_PAGENO := LV_PAGENO + 1;
                PROC_INSERT_TEXT_REPORT(PKG_PRINT_TEXT.p_NewPage);
             END IF;
        
            --LV_PAGENO := LV_PAGENO + 1; 
            P_INT1 := 0;
                                          
--            LV_INSERTSTR := '  '||PKG_PRINT_TEXT.p_BoldOn||PKG_PRINT_TEXT.fnalign('NJM - HAZINAGAR',40,'L')
--                                ||PKG_PRINT_TEXT.fnalign('EARNING-DEDUCTION STATEMENT FOR THE PERIOD ENDING : '|| P_TODATE,84,'L')                               
--                                ||PKG_PRINT_TEXT.p_BoldOff||PKG_PRINT_TEXT.fnalign('Run Date '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),36,'R');
                                
            --LV_INSERTSTR := '  '||PKG_PRINT_TEXT.p_BoldOn||PKG_PRINT_TEXT.p_CompOn||PKG_PRINT_TEXT.p_NormalSmall||PKG_PRINT_TEXT.fnalign('NJM - HAZINAGAR',27,'L')
            LV_INSERTSTR := '  '||PKG_PRINT_TEXT.p_BoldOn||PKG_PRINT_TEXT.fnalign('NJM - HAZINAGAR',27,'L')
                                ||PKG_PRINT_TEXT.fnalign('EARNING-DEDUCTION STATEMENT FOR THE PERIOD ENDING : '|| P_TODATE|| '('||P_REPORTOPTION||')',110,'L')
                                --||PKG_PRINT_TEXT.p_BoldOff||PKG_PRINT_TEXT.p_CompOn||PKG_PRINT_TEXT.p_NormalSmall||PKG_PRINT_TEXT.fnalign('Run Date '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),23,'R');                                
                                ||PKG_PRINT_TEXT.p_BoldOff||PKG_PRINT_TEXT.fnalign('Run Date '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),23,'R');
                                 
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
                        
            LV_INSERTSTR := '  ';
            P_INT1 := P_INT1 + 1;
            PROC_INSERT_TEXT_REPORT(LV_INSERTSTR);
            
            
            DELETE FROM GTT_EARNING_DEDT;                 
            LV_SQLSTR := FN_RPT_ED_STATEMENT_NEW_GETSQL(P_COMPANYCODE,P_DIVISIONCODE,P_YEARCODE,P_FROMDATE,P_TODATE,P_REPORTOPTION,'CONTROL',P_CATEGORYCODE,P_DEPARTMENTCODE,P_TOKENNO);  
            DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);           
            EXECUTE IMMEDIATE LV_SQLSTR;
            
            
            /*******************Check Data Exist***************************/
            SELECT COUNT(*) INTO LV_CNT  FROM GTT_EARNING_DEDT ;
            
            IF LV_CNT = 0 THEN
                RAISE_APPLICATION_ERROR(-20111,'NO DATA FOUND !!!!!');
                RETURN;        
            END IF;
            /*******************End Check Data Exist***************************/
            
            
            FOR C4 IN (SELECT SERIAL, TOTCOLS, TOTAMT FROM GTT_EARNING_DEDT ORDER BY SERIAL )
            LOOP
                
                IF  INSTR(C4.TOTCOLS,'9090909090') > 0 THEN                
                    LV_TOTCOLS := ''; 
                ELSE
                    LV_TOTCOLS := C4.TOTCOLS;                   
                END IF;
            
            
                --LV_INSERTSTR := '  '||' '||PKG_PRINT_TEXT.p_CompOn||PKG_PRINT_TEXT.p_NormalSmall||PKG_PRINT_TEXT.fnalign(' ', 60, 'L')
                LV_INSERTSTR := '  '||' '||PKG_PRINT_TEXT.fnalign(' ', 60, 'L')
                            ||' '||PKG_PRINT_TEXT.fnalign(LV_TOTCOLS, 20, 'L')
                            ||' '||PKG_PRINT_TEXT.fnalign(C4.SERIAL, 5, 'R')
                            ||' '||PKG_PRINT_TEXT.fnalign(C4.TOTAMT, 15, 'R',2);
--                            ||' '||PKG_PRINT_TEXT.fnalign(' ', 60, 'L');                                                                          
                        P_INT1 := P_INT1 + 1;
                        PROC_INSERT_TEXT_REPORT(LV_INSERTSTR); 
                
            END LOOP;

         
        
        /******************* End Control ***************************/
        --end regular with control, only control
                          
         
END;
/