CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPTPAYSLIP_STL_NJMCL
--exec PROC_RPTPAYSLIP_STL_NJMCL ('NJ0001', '0002', '01/02/2020','15/02/2020','''19'',''20''','''2'',''3''','''01'',''02''','''B'',''P''','''06738'',''00023''')
(
    P_COMPANYCODE       VARCHAR2,
    P_DIVISIONCODE      VARCHAR2,
    P_FORTNIGHTSTDATE   VARCHAR2,
    P_FORTNIGHTENDDATE  VARCHAR2,
    P_DEPT              VARCHAR2,
    P_SHIFT             VARCHAR2,
    P_SECTION           VARCHAR2,    
    P_CATEGORY          VARCHAR2,
    P_TOKEN             VARCHAR2,
    P_SLIPFROM          VARCHAR2,
    P_SLIPTO            VARCHAR2
)
AS 
/******************************************************************************
   NAME:      Ujjwal
   PURPOSE:   STL Pay slip - njmcl
   Date :     24.06.2020
   Modified : 15.07.2020 by Ujjwal
            
   NOTES:
   Implementing for Naihati Jute Mills 
******************************************************************************/

    LV_SQLSTR           VARCHAR2(32000); 
    LV_INSERTSTR VARCHAR2(4000); 
    LV_COMPANYNAME VARCHAR2(100);
    LV_SRL NUMBER(5); 
    LV_CATEGORYCODE VARCHAR2(100); 
    LV_DEPARTMENTNAME  VARCHAR2(100);
    LV_CNT      NUMBER(10);
    LV_PAGENO  NUMBER(10);    
    P_INT1  NUMBER(20);
    P_SLNO NUMBER:=0;
    P_RECORDNO NUMBER:=0;
    p_lsttoken varchar2(20);
    lv_SlipNo varchar2(100);
    
    lv_dept varchar2(20);
    lv_shift varchar2(20);    
    lv_lstDept varchar2(20);    
    lv_section varchar2(20);
    lv_newPage varchar2(20);    
    lv_count number:=0;
    LV_LASTC1 GTT_PAYSLIP_NJMCL%rowtype; 
    
    lv_CountRecd number:=0;
    lv_lstCountRecd number:=0;
    lv_recdCount number:=0;
     
    lv_sqlerrm          varchar2(500) := ''; 
    lv_remarks          varchar2(500) := 'Generate Payslip(STL) '; 
    lv_parvalues        varchar2(500) := ''; 
    lv_ProcName         varchar2(500) := 'PROC_RPTPAYSLIP_STL_NJMCL'; 

BEGIN   
      
        if P_SLIPFROM is not null and P_SLIPTO is not null then
        
        --nvl(P_SLIPFROM,0)>0 AND nvl(P_SLIPTO,0)>0 then           
            lv_SlipNo:= ' (SLIPNO>= '||P_SLIPFROM ||' AND SLIPNO<= '||P_SLIPTO ||')';        
        else
            if nvl(P_SLIPFROM,0)>0 then
                lv_SlipNo:= ' SLIPNO>= '||P_SLIPFROM;
            end if;
            
            if nvl(P_SLIPTO,0)>0 then
                lv_SlipNo:= ' SLIPNO<= '||P_SLIPTO;
            end if;
        end if;
        
    
        DELETE FROM GTT_TEXT_PAYSLIPNJMCL;
        DELETE FROM GTT_PAYSLIP_NJMCL;
                         
        LV_SQLSTR := ' INSERT INTO GTT_PAYSLIP_NJMCL
            (SLIPNO, COMPANYCODE, DIVISIONCODE, FORTNIGHTENDDATE, DEPT, SRLNO, RECORDNO, WORKERNAME, EBDESIG, DSGCD, CT,ESINO,ATNHRS,
            STLDAYS,STLPERIOD,OTHR,DA,HRA, PBF,FPF,PF, ESI, P_TAX, PCO, GRERNG, GRDEDN, NETPAY,DEPARTMENTCODE,WORKERCATEGORYCODE,  WORKERCATEGORYNAME, SECTION, SHIFT) ';
  
    if lv_SlipNo is not null then
        lv_sqlstr := lv_sqlstr||chr(10)||'  SELECT * FROM (  ';         
    end if;
     
    lv_sqlstr := lv_sqlstr||chr(10)||'    
            SELECT ROW_NUMBER() OVER(ORDER BY DEPARTMENTCODE,SECTIONCODE, SHIFTCODE,TO_NUMBER(SRLNO), RECORDNO) SLIPNO,COMPANYCODE, DIVISIONCODE,
                TO_CHAR(PAYMENTDATE,''DD-MM-YY'')PAYMENTDATE, DEPT, SRLNO, RECORDNO, WORKERNAME,EBDESIG, DSGCD, CT, ESINO, ATNHRS, 
                STLDAYS, STLPERIOD, OTHR, DA, HRA,  PBF, FPF, PF,ESI, P_TAX,PCO,GRERNG, GRDEDN,NETPAY,DEPARTMENTCODE, WORKERCATEGORYCODE,  
                WORKERCATEGORYNAME, SECTIONCODE, SHIFTCODE
            FROM VW_WPSPAYSLIP_STL 
            WHERE COMPANYCODE='''||P_COMPANYCODE||'''
                AND DIVISIONCODE='''||P_DIVISIONCODE||'''
                AND PAYMENTDATE>=TO_DATE('''||P_FORTNIGHTSTDATE||''',''DD/MM/YYYY'')
                AND PAYMENTDATE<=TO_DATE('''||P_FORTNIGHTENDDATE||''',''DD/MM/YYYY'')         
                
       --       AND RECORDNO IN (''04202'',''04189'',''00060'',''05101'') 
       --       AND RECORDNO IN (''00053'',''95063'',''95013'',''95021'')  
       --   AND RECORDNO IN (''61257'',''61294'',''61296'')  
       --   AND RECORDNO IN (''64853'',''01507'',''01441'')  
       --   and departmentcode in (''01'',''04'')     
               ' ;
                
            if p_dept is not null then
               lv_sqlstr := lv_sqlstr||chr(10)||' AND DEPARTMENTCODE IN ('||p_dept||')'; 
            end if;        
           
            if p_section is not null then
               lv_sqlstr := lv_sqlstr||chr(10)||' AND SECTIONCODE IN ('||p_section||')'; 
            end if;        
           
            if p_category is not null then
               lv_sqlstr := lv_sqlstr||chr(10)||' AND WORKERCATEGORYCODE IN ('||p_category||')'; 
            end if;
           
            if p_shift is not null then
               lv_sqlstr := lv_sqlstr||chr(10)||' AND  decode(SHIFTCODE,''A'',''1'',''B'',''2'',''C'',''3'',''1'') IN ('||p_shift||')'; 
            end if;
           
            if p_token is not null then
               lv_sqlstr := lv_sqlstr||chr(10)||' AND RECORDNO IN ('||p_token||')'; 
            end if;
        
            if lv_SlipNo is not null then
                lv_sqlstr := lv_sqlstr||chr(10)||' ) where  '||lv_SlipNo;
            end if;                   
                  
            
            lv_sqlerrm := ''; --sqlerrm ;    
            insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS)
            values( P_COMPANYCODE, P_DIVISIONCODE, lv_ProcName,lv_sqlerrm, LV_SQLSTR, lv_parvalues,TO_DATE(P_FORTNIGHTSTDATE,'DD/MM/YYYY'),TO_DATE(P_FORTNIGHTENDDATE,'DD/MM/YYYY'),lv_remarks);
            
                  
       --DBMS_OUTPUT.PUT_LINE(' '||LV_SQLSTR);   
        EXECUTE IMMEDIATE LV_SQLSTR;        
        
        /*******************Check Data Exist*******************************/
        SELECT COUNT(*) INTO LV_CNT  FROM GTT_PAYSLIP_NJMCL ;
        
        IF LV_CNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20111,'NO DATA FOUND !!!!!');
            RETURN;        
        END IF;
        /*******************End Check Data Exist***************************/           
              
                        
        DELETE FROM GTT_TEXT_REPORT;
        
        LV_PAGENO := 0;
        P_INT1 := 0;
        LV_SRL := 0;
        
        p_lsttoken:=null;        
      
        
        FOR C1 IN (SELECT * FROM GTT_PAYSLIP_NJMCL ORDER BY SLIPNO)
        LOOP
        
         P_RECORDNO:=P_RECORDNO+1;           
        
            IF lv_dept IS NULL THEN
                lv_dept := C1.DEPARTMENTCODE ;
            END IF;
            
            IF lv_shift IS NULL THEN
                lv_shift := C1.SHIFT;
            END IF;
                  
            lv_CountRecd :=lv_CountRecd +1;        
          
         --   if NVL(lv_dept,'NA') <> C1.DEPARTMENTCODE or NVL(lv_shift,'NA') <> C1.SHIFT then                          
                
                
                select count(*) into lv_recdCount from GTT_TEXT_PAYSLIPNJMCL WHERE TOKEN=LV_LASTC1.RECORDNO;
                   
            
--                if lv_recdCount<1 then 
--                                    
--                    ----DBMS_OUTPUT.PUT_LINE('REC 11 : '||lv_recdCount|| '....................'||LV_LASTC1.RECORDNO);  
--                
--                    ---0001)  
--                    LV_INSERTSTR := ' ';
--                    IF LV_LASTC1.ATREWARD>0 THEN
--                        LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',1)||fnAlignZeroVal(LV_LASTC1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ATREWARD, 5, 'C',2)||']';     
--                    ELSE
--                        LV_INSERTSTR := LPAD(' ',32);                            
--                    END IF;       
--                                                
--                    P_SLNO:=P_SLNO+1;                     
--                        INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                        VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
--                        
--                    
--                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.DEPT, 8, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(LV_LASTC1.RECORDNO, 8, 'C')||
--                    ' '||fnAlignZeroVal(LV_LASTC1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(LV_LASTC1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(LV_LASTC1.DSGCD, 3, 'L')||
--                    ' '||fnAlignZeroVal(LV_LASTC1.CT, 2, 'C')||' '||fnAlignZeroVal(LV_LASTC1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SLIPNO, 5, 'R'); 
--                                       
--                    P_SLNO:=P_SLNO+1;                             
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
--                               
--                                
--                    --       0002)    
--                    LV_INSERTSTR := ' '; 
--                    P_SLNO:=P_SLNO+1;                     
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
--                                                   
--                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ESINO, 8, 'L')||' '||fnAlignZeroVal(LV_LASTC1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.ATNHRS, 8, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBHR, 3, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 4, 'R',1)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 13, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ; 
--
--                    P_SLNO:=P_SLNO+1;                             
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
--                                 
--                   
--                    --       0003)   
--                     LV_INSERTSTR := ' '; 
--                    IF LV_LASTC1.FBWG>0 THEN
--                        LV_INSERTSTR := LPAD(' ',49);                              
--                    ELSE
--                        IF LV_LASTC1.FBWG1>0 THEN
--                            LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',38)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');
--                        ELSE
--                            LV_INSERTSTR := LPAD(' ',49);     
--                        END IF;                              
--                    END IF;                                                     
--                                                                     
--                    P_SLNO:=P_SLNO+1;                     
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
--                     
--                              
--                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.SE, 6, 'C')||' '||fnAlignZeroVal(LV_LASTC1.DA, 8, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBWG, 6, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.INCENTIVE, 5, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PBF, 3, 'R',2) ; 
--               
--                    P_SLNO:=P_SLNO+1;                             
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
--                                                
--                                      
--                    --       0004) 
--                    LV_INSERTSTR := ' '; 
--                    P_SLNO:=P_SLNO+1;                     
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);  
--                    
--                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LOC, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF, 7, 'R')||
--                    ' '||fnAlignZeroVal(LV_LASTC1.FPF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ESI, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_RCV, 6, 'R')||
--                    ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.HRENT, 6, 'R')||
--                    ' '||fnAlignZeroVal(LV_LASTC1.P_TAX,4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LWF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PCO, 4, 'R') ; 
--                    
--                    P_SLNO:=P_SLNO+1;                             
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
--                         
--
--                    --       0005) 
--                       LV_INSERTSTR := ' ';               
--                       LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',4)||fnAlignZeroVal(LV_LASTC1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                  
--                                                                     
--                    P_SLNO:=P_SLNO+1;                     
--                        INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                        VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO); 
--                    
--                    LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_BAL, 8, 'R',1)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(LV_LASTC1.INST, 2, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GR_FOR_BONUS, 8, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.GRD, 1, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.GRDEDN, 8, 'R',2)||
--                    ' '||fnAlignZeroVal(LV_LASTC1.NETPAY, 9, 'R',2);
--                                                        
--                    P_SLNO:=P_SLNO+1;                             
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
--                                    
--                    lv_newPage:= PKG_PRINT_TEXT.P_NEWPAGE;
--                    lv_CountRecd:=0;
--                    
--                    P_SLNO:=P_SLNO+1;                    
--                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) 
--                    VALUES(P_SLNO,'***',lv_newPage);
--                          
--                    LV_LASTC1 := NULL   ;
--                    LV_COUNT:=0; 
--                    
--                end if;                   
            --end if;                              
         
      
          
            if p_lsttoken is NOT null and LV_COUNT=1 and p_lsttoken<>c1.recordno then     
                LV_COUNT:=-1;                              
                                      
--                --DBMS_OUTPUT.PUT_LINE('REC 2 : '||LV_LASTC1.RECORDNO);  
--                --DBMS_OUTPUT.PUT_LINE('REC 2 : '||C1.RECORDNO);  
                                
                --      0001)    
                LV_INSERTSTR := ' ';
                IF LV_LASTC1.ATREWARD>0 THEN
                    LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',1)||fnAlignZeroVal(LV_LASTC1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ATREWARD, 5, 'C',2)||']';     
                ELSE
                    LV_INSERTSTR := LPAD(' ',32);                            
                END IF;
                
                IF C1.ATREWARD>0 THEN
                   LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',55)||fnAlignZeroVal(C1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(C1.ATREWARD, 5, 'C',2)||']';                                    
                END IF;        
                                            
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                                                      
                
                          
                LV_INSERTSTR := fnAlignZeroVal(LV_LASTC1.DEPT, 8, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(LV_LASTC1.RECORDNO, 8, 'C')||
                ' '||fnAlignZeroVal(LV_LASTC1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(LV_LASTC1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(LV_LASTC1.DSGCD, 3, 'L')||
                ' '||fnAlignZeroVal(LV_LASTC1.CT, 2, 'C')||' '||fnAlignZeroVal(LV_LASTC1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SLIPNO, 5, 'R'); 
                                
                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',2)||fnAlignZeroVal(C1.DEPT, 8, 'C')||' '||fnAlignZeroVal(C1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(C1.RECORDNO, 8, 'C')||
                ' '||fnAlignZeroVal(C1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(C1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(C1.DSGCD, 3, 'L')||
                ' '||fnAlignZeroVal(C1.CT, 2, 'C')||' '||fnAlignZeroVal(C1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(C1.SLIPNO, 5, 'R'); 
                           
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT,LV_LASTC1.RECORDNO||':'||C1.RECORDNO);
                             

                --       0002)        
                LV_INSERTSTR := ' '; 
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO); 
                                           
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ESINO, 8, 'L')||' '||fnAlignZeroVal(LV_LASTC1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.ATNHRS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBHR, 3, 'R',2)||
                --' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 4, 'R',1)||
                --' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 13, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ; 
                ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 5, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 12, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ; 

                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',2)||fnAlignZeroVal(C1.ESINO, 8, 'L')||' '||fnAlignZeroVal(C1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(C1.ATNHRS, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(C1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(C1.FBHR, 3, 'R',2)||
--                ' '||fnAlignZeroVal(C1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(C1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(C1.STLDAYS, 4, 'R',1)||
--                ' '||fnAlignZeroVal(C1.STLPERIOD, 13, 'R',2)||' '||fnAlignZeroVal(C1.YTDDAYS, 11, 'R',1) ;
                ' '||fnAlignZeroVal(C1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(C1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(C1.STLDAYS, 5, 'R',1)||
                ' '||fnAlignZeroVal(C1.STLPERIOD, 12, 'R',2)||' '||fnAlignZeroVal(C1.YTDDAYS, 11, 'R',1) ;  
                                                       
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                         
                         
                --       0003)  
                LV_INSERTSTR := ' '; 
                IF LV_LASTC1.FBWG>0 THEN
                    LV_INSERTSTR := LPAD(' ',49);                              
                ELSE
                    IF LV_LASTC1.FBWG1>0 THEN
                        LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',38)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');
                    ELSE
                        LV_INSERTSTR := LPAD(' ',49);     
                    END IF;                              
                END IF;
                
                IF C1.FBWG>0 THEN
                 LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',32);                                
                ELSE
                    IF LV_LASTC1.FBWG1>0 THEN
                        LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',69)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');           
                    ELSE
                        LV_INSERTSTR := LPAD(' ',49);     
                    END IF;                                                        
                END IF;                                         
                                                                 
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                  
                 
                        
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.SE, 6, 'C')||' '||fnAlignZeroVal(LV_LASTC1.DA, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBWG1, 6, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.INCENTIVE, 5, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PBF, 3, 'R',2) ; 
                  
                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',2)||fnAlignZeroVal(C1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(C1.SE,6, 'C')||' '||fnAlignZeroVal(C1.DA, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(C1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(C1.FBWG1, 6, 'R',2)||
                ' '||fnAlignZeroVal(C1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(C1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(C1.INCENTIVE, 5, 'R',2)||
                ' '||fnAlignZeroVal(C1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(C1.PBF, 3, 'R',2) ; 
                                         
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                                        
                              
                --       0004) 
                LV_INSERTSTR := ' '; 
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO); 
                
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LOC, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF, 7, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.FPF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ESI, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_RCV, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.HRENT, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.P_TAX,4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LWF, 4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PCO, 4, 'R') ; 

                LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',3)||fnAlignZeroVal(C1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(C1.LOC, 6, 'R')||' '||fnAlignZeroVal(C1.PF, 7, 'R')||
                ' '||fnAlignZeroVal(C1.FPF, 5, 'R')||' '||fnAlignZeroVal(C1.ESI, 6, 'R')||' '||fnAlignZeroVal(C1.PF_LN_RCV, 6, 'R')||
                ' '||fnAlignZeroVal(C1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(C1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(C1.HRENT, 6, 'R')||
                ' '||fnAlignZeroVal(C1.P_TAX, 4, 'R')||' '||fnAlignZeroVal(C1.LWF, 4, 'R')||' '||fnAlignZeroVal(C1.PCO, 4, 'R') ; 
                                                
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                 

                --       0005)  
                 LV_INSERTSTR := ' ';               
                   LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',4)||fnAlignZeroVal(LV_LASTC1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                  
                   LV_INSERTSTR :=LV_INSERTSTR||LPAD(' ',5)||fnAlignZeroVal(C1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                                   
                                                                 
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                  
                
                
                LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_BAL, 8, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(LV_LASTC1.INST, 2, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GR_FOR_BONUS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.GRD, 1, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.GRDEDN, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NETPAY, 9, 'R',2) ;
               
                LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',3)||fnAlignZeroVal(C1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(C1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(C1.PF_LN_BAL, 8, 'R',1)||
                ' '||fnAlignZeroVal(C1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(C1.INST, 2, 'R')||' '||fnAlignZeroVal(C1.GR_FOR_BONUS, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.GRD, 1, 'R')||' '||fnAlignZeroVal(C1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(C1.GRDEDN, 8, 'R',2)||
                ' '||fnAlignZeroVal(C1.NETPAY, 9, 'R',2) ;               
                                                      
                P_SLNO:=P_SLNO+1;                             
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);
                    
                --'CHANGE -
--                LV_INSERTSTR := ' '; 
--                P_SLNO:=P_SLNO+1;                     
--                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
--                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);                 
--                       
                P_SLNO:=P_SLNO+1;                
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) VALUES(P_SLNO,'***','');           

                P_SLNO:=P_SLNO+1;                
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) VALUES(P_SLNO,'***','');       

         
            end if;   
            
                p_lsttoken:=P_RECORDNO;
                            
                if lv_count=1 then
                   p_lsttoken:=null;
                end if;

                lv_count:=lv_count+1;
                LV_LASTC1:=c1;    
                            
                lv_dept:=C1.DEPARTMENTCODE;
                lv_shift:=C1.SHIFT;
                   
--            if lv_CountRecd=12 then    
--                lv_newPage:= PKG_PRINT_TEXT.P_NEWPAGE;
--                
--                P_SLNO:=P_SLNO+1;   
--                
--                -- INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) VALUES(P_SLNO,'***',lv_newPage);
--                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) VALUES(P_SLNO,'***','');
--                                                
--                lv_CountRecd:=0;
--            else                 
--                 if mod(lv_CountRecd,2)=0 and lv_CountRecd<>0 then 
--                 
--                 P_SLNO:=P_SLNO+1;              
--                     INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINETEXT) 
--                       VALUES(P_SLNO,'');      
--                       
--                        --'CHANGE -
--            -- LV_INSERTSTR := ' '; 
--                P_SLNO:=P_SLNO+1;                     
----                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
----                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,C1.DEPARTMENTCODE,C1.WORKERCATEGORYCODE, C1.SECTION, C1.SHIFT, C1.RECORDNO);      
--                     INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINETEXT) 
--                       VALUES(P_SLNO,''); 
--                       
--                 end if;   
--            end if;                           
             
            
         END LOOP;         
        
        if lv_count=1 then       
            
--            --DBMS_OUTPUT.PUT_LINE('REC 3 : '||LV_LASTC1.RECORDNO);  
--            --DBMS_OUTPUT.PUT_LINE('REC F : '||LV_LASTC1.PBF); 
--            --DBMS_OUTPUT.PUT_LINE('REC O : '||LV_LASTC1.PCO); 
                          
            ---0001)     
            LV_INSERTSTR := ' ';
                IF LV_LASTC1.ATREWARD>0 THEN
                    LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',1)||fnAlignZeroVal(LV_LASTC1.ATREWARD_HEAD, 24, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ATREWARD, 5, 'C',2)||']';     
                ELSE
                    LV_INSERTSTR := LPAD(' ',32);                            
                END IF;               
        
                                            
                P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);  
                    
                                         
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.DEPT, 8, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SRLNO, 5, 'C')||' '||fnAlignZeroVal(LV_LASTC1.RECORDNO, 8, 'C')||
                ' '||fnAlignZeroVal(LV_LASTC1.WORKERNAME, 19, 'L')||' '||fnAlignZeroVal(LV_LASTC1.EBDESIG, 10, 'L')||' '||fnAlignZeroVal(LV_LASTC1.DSGCD, 3, 'L')||
                ' '||fnAlignZeroVal(LV_LASTC1.CT, 2, 'C')||' '||fnAlignZeroVal(LV_LASTC1.FORTNIGHTENDDATE, 10, 'C')||' '||fnAlignZeroVal(LV_LASTC1.SLIPNO, 5, 'R'); 

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                   
                   
            --       0002)    
            LV_INSERTSTR := ' '; 
            P_SLNO:=P_SLNO+1;                     
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                                           
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ESINO, 8, 'L')||' '||fnAlignZeroVal(LV_LASTC1.ATNDAY, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.ATNHRS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLHR, 4, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBHR, 3, 'R',2)||
--                ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 4, 'R',1)||
--                ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 13, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ;
                ' '||fnAlignZeroVal(LV_LASTC1.OTHR, 5, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.LAYOFF, 3, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.STLDAYS, 5, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.STLPERIOD, 12, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.YTDDAYS, 11, 'R',1) ;  

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                     
                    
            --       0003)   
              LV_INSERTSTR := ' '; 
                IF LV_LASTC1.FBWG>0 THEN
                    LV_INSERTSTR := LPAD(' ',49);                              
                ELSE
                    IF LV_LASTC1.FBWG1>0 THEN
                        LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',38)||fnAlignZeroVal(LV_LASTC1.ELECTRIC_HEAD, 10, 'L');
                    ELSE
                        LV_INSERTSTR := LPAD(' ',49);     
                    END IF;                              
                END IF;                                                     
                                                                 
                P_SLNO:=P_SLNO+1;                     
                INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);   
                 
                      
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.BASIC, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.SE, 6, 'C')||' '||fnAlignZeroVal(LV_LASTC1.DA, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.FIXER, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.HOLWG, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.FBWG, 6, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NSA, 6, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.OT_AMOUNT, 8, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.INCENTIVE, 5, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.HRA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PBF, 3, 'R',2) ; 
              

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                                    
                          
            --       0004) 
            LV_INSERTSTR := ' '; 
            P_SLNO:=P_SLNO+1;                     
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
            
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.ADJERNG, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LOC, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF, 7, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.FPF, 5, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ESI, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_RCV, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_RCV, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.ADJDEDN, 6, 'R')||' '||fnAlignZeroVal(LV_LASTC1.HRENT, 6, 'R')||
                ' '||fnAlignZeroVal(LV_LASTC1.P_TAX,4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.LWF, 4, 'R')||' '||fnAlignZeroVal(LV_LASTC1.PCO, 4, 'R',2) ; 
                
            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
             
          
            --       0005) 
               LV_INSERTSTR := ' ';               
               LV_INSERTSTR := LV_INSERTSTR||LPAD(' ',4)||fnAlignZeroVal(LV_LASTC1.TSA_HEAD, 5, 'L')||LPAD(' ',61)||''||fnAlignZeroVal(LV_LASTC1.NETPAY_HEAD, 9, 'L');                  
                                                                 
               P_SLNO:=P_SLNO+1;                     
                    INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
                    VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO); 
                    
            
            LV_INSERTSTR := ' '||fnAlignZeroVal(LV_LASTC1.TSA, 7, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.PF_OWN_YTD, 8, 'R',1)||' '||fnAlignZeroVal(LV_LASTC1.PF_LN_BAL, 8, 'R',1)||
                ' '||fnAlignZeroVal(LV_LASTC1.PL_INT_BAL, 8, 'R')||' '||fnAlignZeroVal(LV_LASTC1.INST, 2, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GR_FOR_BONUS, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.GRD, 1, 'R')||' '||fnAlignZeroVal(LV_LASTC1.GRERNG, 9, 'R',2)||' '||fnAlignZeroVal(LV_LASTC1.GRDEDN, 8, 'R',2)||
                ' '||fnAlignZeroVal(LV_LASTC1.NETPAY, 9, 'R',2) ;

            P_SLNO:=P_SLNO+1;                             
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO, RECORDNO, LINETEXT, DEPT, CATEGORY, SECTION, SHIFT, TOKEN) 
            VALUES(P_SLNO,P_RECORDNO, LV_INSERTSTR,LV_LASTC1.DEPARTMENTCODE,LV_LASTC1.WORKERCATEGORYCODE, LV_LASTC1.SECTION, LV_LASTC1.SHIFT, LV_LASTC1.RECORDNO);
                                    
            lv_newPage:= PKG_PRINT_TEXT.P_NEWPAGE;
            lv_CountRecd:=0;
                         
--            P_SLNO:=P_SLNO+1;   
--            --INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) VALUES(P_SLNO,'***',lv_newPage);                        
--            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) VALUES(P_SLNO,'***','');

            P_SLNO:=P_SLNO+1;                
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) VALUES(P_SLNO,'***','');           

            P_SLNO:=P_SLNO+1;                
            INSERT INTO GTT_TEXT_PAYSLIPNJMCL(LINENO,LINESPCHAR,LINETEXT) VALUES(P_SLNO,'***','');    
    
            LV_LASTC1 := NULL   ;
            LV_COUNT:=-1; 
                        
        end if;                  
             
        COMMIT;
END;
/
