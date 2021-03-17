DROP PROCEDURE PRCPISCOMPNT_BF_MAINSAVE;

CREATE OR REPLACE procedure             prcPISCompnt_Bf_MainSave
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PISCOMPONENTMASTER%rowtype;
lv_ComponentCd          varchar2(100) := '';
lv_MaxYearMonth         varchar2(10);
lv_CompanyCode          varchar2(10) :='';
lv_DivisionCode         varchar2(10) :='';
lv_YearMonth            varchar2(9) :='';
lv_OperationMode        varchar2(1) :='';
lv_calculationIndex     number(10) :=0;

begin
    lv_result:='#SUCCESS#';
    --Master
    select count(*)
    into lv_cnt
    from GBL_PISCOMPONENTMASTER;
   
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found in Component Master entry]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    select distinct companycode, divisioncode, yearmonth, componentcode, operationmode, nvl(calculationindex,0)
    into lv_CompanyCode, lv_DivisionCode, lv_YearMonth, lv_ComponentCd, lv_OperationMode, lv_calculationIndex
    from GBL_PISCOMPONENTMASTER;

    if lv_OperationMode is null then
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT / VIEW ? ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;    

-----------------------  Componet Master Logic
    if nvl(lv_OperationMode,'NA') = 'A' then
        select count(*)
          into lv_cnt
          from PISCOMPONENTMASTER
         where companycode = lv_CompanyCode
           and divisioncode = lv_DivisionCode
           and to_number(yearmonth) > to_number(lv_YearMonth);

        if lv_cnt > 0 then
            select to_char(max(to_number(yearmonth)))
            into lv_MaxYearMonth
              from PISCOMPONENTMASTER
             where companycode = lv_CompanyCode
               and divisioncode = lv_DivisionCode;
               
            lv_error_remark := 'Validation Failure : [Last Component Entered YearMonth was : ' || to_char(to_date(lv_MaxYearMonth,'yyyymm'),'MON-YYYY') || ' You can not save any Component Entry before this YearMonth.]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));   
        end if;
        
        select count(*)
          into lv_cnt
          from PISCOMPONENTMASTER
         where companycode = lv_CompanyCode
           and divisioncode = lv_DivisionCode
           and componentcode <> lv_ComponentCd
           and nvl(calculationindex,0)=lv_calculationIndex
           and nvl(calculationindex,0) > 0;
         
        if lv_cnt > 0 then
            lv_error_remark := 'Validation Failure : [Calculation Index Already Used for another Component.]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;
        
        update gbl_piscomponentmaster set dependencytype=nvl(dependencytype,'N'),validationtype=nvl(validationtype,'N'),roundofftype=nvl(roundofftype,'N'),roundoffrs=nvl(roundoffrs,0),carryforwardtype=nvl(carryforwardtype,'N'),includepayroll=nvl(includepayroll,'N'),includearrear=nvl(includearrear,'N'),
                   userentryapplicable=nvl(userentryapplicable,'N'),attendanceentryapplicable=nvl(attendanceentryapplicable,'N'),limitapplicable=nvl(limitapplicable,'N'),rolloverapplicable=nvl(rolloverapplicable,'N'),employeespecific=nvl(employeespecific,'N'),slabapplicable=nvl(slabapplicable,'N'),
                   allowreimbursement=nvl(allowreimbursement,'N'),allowcumulativecompcreation=nvl(allowcumulativecompcreation,'N'),miscpayment=nvl(miscpayment,'N'),finalsettlement=nvl(finalsettlement,'N'),iscostcentrewiseposting=nvl(iscostcentrewiseposting,'N'),accodereimburseliability=nvl(accodereimburseliability,'N'),
                   ratecomponent=nvl(ratecomponent,'N'),systemcomponent=nvl(systemcomponent,'N'),editableformula=nvl(editableformula,'N'),salaryregisterrowno=nvl(salaryregisterrowno,0),salaryregistercolstart=nvl(salaryregistercolstart,0),
                   salaryregistercolwidth=nvl(salaryregistercolwidth,0),paysliprowno=nvl(paysliprowno,0),payslipcolstart=nvl(payslipcolstart,0),payslipcolwidth=nvl(payslipcolwidth,0);
        
        select count(*)
          into lv_cnt
          from PISCOMPONENTMASTER
         where companycode = lv_CompanyCode
           and divisioncode = lv_DivisionCode
           and to_number(yearmonth) = to_number(lv_YearMonth);
           
         if lv_cnt = 0 then
            insert into GBL_PISCOMPONENTMASTER
            select companycode,divisioncode,lv_YearMonth yearmonth,componentcode,componentshortname,componentdesc,componenttype,calculationindex,phase,
                   payformula,nvl(dependencytype,'N'),nvl(validationtype,'N'),nvl(roundofftype,'N'),nvl(roundoffrs,0),nvl(carryforwardtype,'N'),nvl(includepayroll,'N'),nvl(includearrear,'N'),
                   nvl(userentryapplicable,'N'),nvl(attendanceentryapplicable,'N'),nvl(limitapplicable,'N'),nvl(rolloverapplicable,'N'),nvl(employeespecific,'N'),nvl(slabapplicable,'N'),
                   nvl(allowreimbursement,'N'),nvl(allowcumulativecompcreation,'N'),nvl(miscpayment,'N'),nvl(finalsettlement,'N'),nvl(iscostcentrewiseposting,'N'),nvl(accodereimburseliability,'N'),
                   nvl(ratecomponent,'N'),acccode,subcode,expensecode,nvl(systemcomponent,'N'),nvl(editableformula,'N'),nvl(salaryregisterrowno,0),nvl(salaryregistercolstart,0),
                   nvl(salaryregistercolwidth,0),nvl(paysliprowno,0),nvl(payslipcolstart,0),nvl(payslipcolwidth,0),null sysrowid,'A' operationmode,username,componentgroup
             from PISCOMPONENTMASTER
            where companycode = lv_CompanyCode
              and divisioncode = lv_DivisionCode
              and componentcode <> lv_ComponentCd
              and to_number(yearmonth) = (
                                          select max(to_number(yearmonth))
                                            from PISCOMPONENTMASTER
                                           where companycode = lv_CompanyCode
                                             and divisioncode = lv_DivisionCode
                                             and to_number(yearmonth) < to_number(lv_YearMonth)
                                         );
         end if;
    end if;
-----------------------  Componet Master Logic    
exception
when others then
    lv_error_remark := sqlerrm;
    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));    
end;
/


DROP PROCEDURE PRCPISGRADECOMPOMAPP_B4SAVE;

CREATE OR REPLACE PROCEDURE prcPISGradeCompoMapp_b4Save
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PISGRADECOMPONENTMAPPING%rowtype;
lv_MaxDRCRdate            date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);      

begin

       lv_result:='#SUCCESS#';
        select *
        into lv_Master
        from GBL_PISGRADECOMPONENTMAPPING
        WHERE ROWNUM=1;

        select count(*)
        into lv_cnt
        from GBL_PISGRADECOMPONENTMAPPING;
        
         IF NVL(lv_cnt,0)=0 THEN
            lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;
        
        
        IF lv_Master.OPERATIONMODE IS NULL THEN
            lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;            

       /* if nvl(lv_Master.operationmode,'NA') = 'A' or nvl(lv_Master.operationmode,'NA') = 'M' then
            UPDATE GBL_PISGRADECOMPONENTMAPPING A
               SET A.APPLICABLE='Y'
             WHERE A.COMPONENTCODE = (SELECT DISTINCT COMPONENTCODE FROM PISCOMPONENTMASTER B WHERE B.SYSTEMCOMPONENT='Y' AND A.COMPONENTCODE = B.COMPONENTCODE )
               AND A.APPLICABLE='N';  
        end if;*/

end;
/


DROP PROCEDURE PRCPIS_EMPRATE_B4SAVE;

CREATE OR REPLACE PROCEDURE             prcPIS_EmpRate_b4Save
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PISEMPLOYEEMASTER%rowtype;
lv_MaxDRCRdate          date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);      
lv_YearCode             varchar2(10);

begin

    lv_result:='#SUCCESS#';
    
    
        select *
        into lv_Master
        from GBL_PISEMPLOYEEMASTER
        WHERE ROWNUM<=1;

        select count(*)
        into lv_cnt
        from GBL_PISEMPLOYEEMASTER;
        
        
         IF NVL(lv_cnt,0)=0 THEN
            lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;
        
        IF lv_Master.OPERATIONMODE IS NULL THEN
            lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;            

        select YEARCODE into lv_YearCode 
        from financialyear
        where COMPANYCODE = lv_Master.COMPANYCODE AND DIVISIONCODE = lv_Master.DIVISIONCODE
        AND STARTDATE <= SYSDATE AND ENDDATE >= SYSDATE; 

        if nvl(lv_Master.operationmode,'NA') = 'A' then
           
            select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_YearCode,'PIS_WORKERSERIAL',to_char(SYSDATE,'dd/mm/yyyy')) 
            into lv_TransactionNo
            from dual;
            
            IF nvl(lv_TransactionNo,'NA') <>'NA' then
                update GBL_PISEMPLOYEEMASTER
                set WORKERSERIAL = lv_TransactionNo;
                
                update GBL_PISCOMPONENTASSIGNMENT
                set WORKERSERIAL= lv_TransactionNo;
            else
                lv_error_remark := 'WORKERSERIAL No not generated. Check Parameters for Auto Gen.';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            end if;
            
        end if;
        
 --exception when others then
--    lv_error_remark:= lv_error_remark || '#UNSUCC#ESSFULL#';
--    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
end;
/


DROP PROCEDURE PRCPIS_EMP_B4SAVE;

CREATE OR REPLACE PROCEDURE          prcPIS_Emp_b4Save
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PISEMPLOYEEMASTER%rowtype;
lv_MaxDRCRdate          date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);      
lv_YearCode             varchar2(10);
begin

    lv_result:='#SUCCESS#';
    
    
        select yearcode into lv_YearCode from financialyear
        where SYSDATE between startdate and enddate
        and rownum=1;

        select *
        into lv_Master
        from GBL_PISEMPLOYEEMASTER
        WHERE ROWNUM<=1;

        select count(*)
        into lv_cnt
        from GBL_PISEMPLOYEEMASTER;
        
         IF NVL(lv_cnt,0)=0 THEN
            lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;
        
        IF lv_Master.OPERATIONMODE IS NULL THEN
            lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;            

        if nvl(lv_Master.operationmode,'NA') = 'A' then
           
            select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_YearCode,'PIS_WORKERSERIAL',to_char(SYSDATE,'dd/mm/yyyy')) 
            into lv_TransactionNo
            from dual;
            
            IF nvl(lv_TransactionNo,'NA') <>'NA' then
                update GBL_PISEMPLOYEEMASTER
                set WORKERSERIAL = lv_TransactionNo;
            else
                lv_error_remark := 'WORKERSERIAL No not generated. Check Parameters for Auto Gen.';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            end if;
            
        end if;
        
        
 --exception when others then
--    lv_error_remark:= lv_error_remark || '#UNSUCC#ESSFULL#';
--    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
end;
/


DROP PROCEDURE PRCPIS_EMP_B4SAVE_BK;

CREATE OR REPLACE PROCEDURE          prcPIS_Emp_b4Save_BK
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PISEMPLOYEEMASTER%rowtype;
lv_MaxDRCRdate          date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);      

begin

    lv_result:='#SUCCESS#';
    
    
        select *
        into lv_Master
        from GBL_PISEMPLOYEEMASTER
        WHERE ROWNUM<=1;

        select count(*)
        into lv_cnt
        from GBL_PISEMPLOYEEMASTER;
        
         IF NVL(lv_cnt,0)=0 THEN
            lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;
        
        IF lv_Master.OPERATIONMODE IS NULL THEN
            lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;            

        if nvl(lv_Master.operationmode,'NA') = 'A' then
           
            select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,'2016-2017','PIS_WORKERSERIAL',to_char(SYSDATE,'dd/mm/yyyy')) 
            into lv_TransactionNo
            from dual;
            
            IF nvl(lv_TransactionNo,'NA') <>'NA' then
                update GBL_PISEMPLOYEEMASTER
                set WORKERSERIAL = lv_TransactionNo;
            else
                lv_error_remark := 'WORKERSERIAL No not generated. Check Parameters for Auto Gen.';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            end if;
            
        end if;
        
 --exception when others then
--    lv_error_remark:= lv_error_remark || '#UNSUCC#ESSFULL#';
--    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
end;
/


DROP PROCEDURE PRCPIS_OFFDAY_ADJUST_B4SAVE;

CREATE OR REPLACE PROCEDURE "PRCPIS_OFFDAY_ADJUST_B4SAVE" 
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PISOFFDAYWORKINGADJUSTMENT%rowtype;
lv_MaxDRCRdate          date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);      
lv_message varchar2(250);
lv_yearcode varchar2(10 byte);
begin

    lv_result:='#SUCCESS#';
    
    
    select *
    into lv_Master
    from GBL_PISOFFDAYWORKINGADJUSTMENT
    WHERE ROWNUM =1;           
    
    select yearcode into lv_yearcode from financialyear  where lv_Master.DOCUMENTDATE between startdate and enddate    
    and companycode=lv_Master.companycode and divisioncode=lv_Master.divisioncode ;
        
    -- year code not mentioned in original table .
    if nvl(lv_Master.OPERATIONMODE,'NA') = 'A' then
        select fn_autogen_params(lv_Master.companycode,lv_Master.divisioncode,lv_yearcode,
        'PIS OFF DAY ADJUSTMENT',TO_CHAR(lv_Master.DOCUMENTDATE,'DD/MM/YYYY')) 
        into lv_TransactionNo
        from dual;                          
        
        UPDATE GBL_PISOFFDAYWORKINGADJUSTMENT SET DOCUMENTNO=lv_TransactionNo;
        lv_message := ' [DAY OFF ADJUSTMENT NO GENERATED : ' || lv_TransactionNo || ' Dated : ' || TO_CHAR(lv_Master.DOCUMENTDATE,'DD/MM/YYYY') || ']';
        insert into SYS_GBL_PROCOUTPUT_INFO(SYS_SAVE_INFO) values(lv_message);      
          
    end if;
 
end;
/


DROP PROCEDURE PRCPIS_PFSETTLEMENT_AFTRSAVE;

CREATE OR REPLACE PROCEDURE             prcPIS_PFSettlement_AftrSave
AS
BEGIN
--RETURN;

    DELETE FROM GBL_PFSETTLEMENT;

END;
/


DROP PROCEDURE PRCPIS_PFSETTLEMENT_B4SAVE;

CREATE OR REPLACE PROCEDURE prcPIS_PFSettlement_b4Save
is
lv_cnt                  number;
lv_result               varchar2(10);
LV_TEMPSTR               varchar2(100);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PFSETTLEMENT%rowtype;
lv_PFSettlementNo       varchar2(50);
lv_PFSystemVoucherNo    varchar2(50);
lv_PFVoucherNo          varchar2(50);
lv_STR_SQL              varchar2(1000);
begin


--RETURN;

    lv_result:='#SUCCESS#';
    
    select *
    into lv_Master
    from GBL_PFSETTLEMENT
    WHERE ROWNUM<=1;

    select count(*)
    into lv_cnt
    from GBL_PFSETTLEMENT;
        
     IF NVL(lv_cnt,0)=0 THEN
        lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
    END IF;
        
    IF lv_Master.OPERATIONMODE IS NULL THEN
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    END IF;            

    if nvl(lv_Master.OPERATIONMODE,'NA') = 'A' then
        
        select fn_autogen_params(lv_Master.companycode,lv_Master.divisioncode,lv_Master.yearcode,'PF SETTLEMENT NO',TO_CHAR(lv_Master.SETTLEMENTDATE,'DD/MM/YYYY')) 
        into lv_PFSettlementNo
        from dual;
--        select fn_autogen_params(lv_Master.companycode,lv_Master.divisioncode,lv_Master.yearcode,'PF SETTLEMENT NO',TO_CHAR(lv_Master.SETTLEMENTDATE,'DD/MM/YYYY')) 
--        into lv_PFSystemVoucherNo
--        from dual;
--        select fn_autogen_params(lv_Master.companycode,lv_Master.divisioncode,lv_Master.yearcode,'PF SETTLEMENT NO',TO_CHAR(lv_Master.SETTLEMENTDATE,'DD/MM/YYYY')) 
--        into lv_PFVoucherNo
--        from dual;
        
    
        update GBL_PFSETTLEMENT
        set PFSETTLEMENTNO = lv_PFSettlementNo;--, SYSTEMVOUCHERNO = lv_PFSystemVoucherNo, VOUCHERNO = lv_PFVoucherNo;
                
      end if;
    
    
    --RETURN;
    
    --raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,'SETTLEMENTDATE'||TO_DATE(lv_Master.SettlementDate,'DD/MM/YYYY')));
    IF NVL(lv_Master.SettlementDate,TO_DATE('01/01/1900','DD/MM/YYYY'))<>TO_DATE('01/01/1900','DD/MM/YYYY') THEN
    --raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,'SETTLEMENTDATE'||TO_DATE(lv_Master.SettlementDate,'DD/MM/YYYY')));

     
        EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_INSUPD_WPSWORKERMAST DISABLE';
        EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_INSUPD_WPSWORKERMAST DISABLE';


         UPDATE PFEMPLOYEEMASTER SET
         PFSETTLEMENTDATE= lv_Master.SettlementDate WHERE MODULE=''||lv_Master.Module||'' AND WORKERSERIAL=''||lv_Master.WorkerSerial||'';

         UPDATE WPSWORKERMAST SET 
         PFSETTELMENTDATE= lv_Master.SettlementDate,PFAPPLICABLE='N',EPFAPPLICABLE='N' WHERE MODULE=''||lv_Master.Module||'' AND WORKERSERIAL=''||lv_Master.WorkerSerial||'';
         
         UPDATE PISEMPLOYEEMASTER SET 
         PFSETTELMENTDATE= lv_Master.SettlementDate,PFAPPLICABLE='N', EPFAPPLICABLE='N' WHERE MODULE=''||lv_Master.Module||'' AND WORKERSERIAL=''||lv_Master.WorkerSerial||'';
     
         
        EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_INSUPD_WPSWORKERMAST ENABLE';
        EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_INSUPD_WPSWORKERMAST ENABLE';
     
    END IF;
    
         
    if nvl(lv_Master.OPERATIONMODE,'NA') = 'A' then
        insert into SYS_GBL_PROCOUTPUT_INFO
        values (' PF SETTLEMENT NO : ' || lv_PFSettlementNo || ' Dated : ' || to_date(lv_Master.SettlementDate,'dd/mm/yyyy'));
--        insert into SYS_GBL_PROCOUTPUT_INFO
--        values (' PF LOAN SYSTEM VOUCHER NO : ' || lv_PFSystemVoucherNo || ' Dated : ' || TO_CHAR(lv_Master.SYSTEMVOUCHERDATE,'DD/MM/YYYY'));
--        insert into SYS_GBL_PROCOUTPUT_INFO
--        values (' PF LOAN VOUCHER NO : ' || lv_PFVoucherNo || ' Dated : ' || TO_CHAR(lv_Master.VOUCHERDATE,'DD/MM/YYYY'));
    end if; 
        

end;
/


DROP PROCEDURE PRCPIS_REIMBURSMENT_B4SAVE;

CREATE OR REPLACE PROCEDURE             PRCPIS_REIMBURSMENT_B4SAVE
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PISREIMBURSEMENTDETAILS%rowtype;
lv_ApplicationNo        varchar2(50);
lv_PrvYrCode            varchar2(50);
lv_BillAmountNw           number(18,2):=0;
lv_BillAmountUp           number(18,2):=0;
lv_SqlStr           varchar2(4000);

begin

    lv_result:='#SUCCESS#';
    
    select *
    into lv_Master
    from GBL_PISREIMBURSEMENTDETAILS
    WHERE ROWNUM<=1;

    select count(*)
    into lv_cnt
    from GBL_PISREIMBURSEMENTDETAILS;
    
     IF NVL(lv_cnt,0)=0 THEN
        lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
    END IF;
        
    IF lv_Master.OPERATIONMODE IS NULL THEN
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    END IF;            
    
    select count(*)
    into lv_cnt
    from PISREIMBURSEMENTDETAILS
    where companycode=lv_Master.companycode
    and divisioncode=lv_Master.divisioncode
    and yearcode=lv_Master.yearcode
    and yearmonth=lv_Master.yearmonth
    and componentcode=lv_Master.componentcode
    and categorycode=lv_Master.categorycode
    and gradecode=lv_Master.gradecode;
   

     IF NVL(lv_cnt,0)>0 THEN  
     
         for C2 in ( SELECT *   from PISREIMBURSEMENTDETAILS
                        where companycode=lv_Master.companycode
                        and divisioncode=lv_Master.divisioncode
                        and yearcode=lv_Master.yearcode
                        and yearmonth=lv_Master.yearmonth
                        and componentcode=lv_Master.componentcode
                        and categorycode=lv_Master.categorycode
                        and gradecode=lv_Master.gradecode ) loop
                        
               lv_SqlStr :=  ' delete from PISREIMBURSEMENTDETAILS'|| CHR(10)
                    ||' WHERE COMPANYCODE= '''||C2.COMPANYCODE||''' '|| CHR(10)
                    ||' AND DIVISIONCODE='''||C2.DIVISIONCODE||''' '||CHR(10)
                    ||' AND YEARCODE='''||C2.YEARCODE||''' '||CHR(10)
                    ||' AND WORKERSERIAL='''||C2.WORKERSERIAL||''' '||CHR(10)
                    ||' AND YEARMONTH='''||C2.YEARMONTH||''' '||CHR(10);
                    execute immediate lv_SqlStr;    
            END LOOP;
     end if;
       
        for c1 in ( SELECT * FROM GBL_PISREIMBURSEMENTDETAILS  
                    WHERE PAIDAMOUNT > COMPONENTAMOUNT  ) loop
                    
         lv_BillAmountNw:=c1.PAIDAMOUNT-(c1.COMPONENTAMOUNT/2);    
         lv_BillAmountUp:=c1.COMPONENTAMOUNT/2;     
         lv_PrvYrCode:= (SUBSTR(c1.YEARCODE,1,4)-1)||'-'||(SUBSTR(c1.YEARCODE,6,4)-1) ;
                    
         lv_SqlStr :=  'INSERT INTO GBL_PISREIMBURSEMENTDETAILS '|| CHR(10)  
                ||' ( COMPANYCODE, DIVISIONCODE, YEARCODE, FORYEARCODE, YEARMONTH, WORKERSERIAL, TOKENNO, CATEGORYCODE, GRADECODE, COMPONENTCODE, COMPONENTAMOUNT, TRANSACTIONTYPE, ADDLESS, REMARKS, ' || CHR(10) 
                ||' PAIDAMOUNT, BILLAMOUNT, LEAVEDATEFROM, LEAVEDATETO, SYSROWID, USERNAME, OPERATIONMODE ) ' || CHR(10)       
                ||'  SELECT '''||C1.COMPANYCODE||''' COMPANYCODE ,'''||C1.DIVISIONCODE||''' DIVISIONCODE, '''||c1.YEARCODE||''' YEARCODE, '''||lv_PrvYrCode||'''  FORYEARCODE, '''||c1.YEARMONTH||''' YEARMONTH, ' || CHR(10)
                ||'  '''||C1.WORKERSERIAL||''' WORKERSERIAL, '''||c1.TOKENNO||'''TOKENNO, '''||C1.CATEGORYCODE||''' CATEGORYCODE, '''||C1.GRADECODE||''' GRADECODE, '|| CHR(10) 
                ||'  '''||c1.COMPONENTCODE||''' COMPONENTCODE, '||c1.COMPONENTAMOUNT||' COMPONENTAMOUNT,'''||c1.TRANSACTIONTYPE||''' TRANSACTIONTYPE, '''||c1.ADDLESS||''' ADDLESS,'|| CHR(10)
                ||'  '''||c1.REMARKS||''' REMARKS, '||lv_BillAmountNw||'PAIDAMOUNT , 0 BILLAMOUNT, '''||c1.LEAVEDATEFROM ||''' LEAVEDATEFROM , '''||c1.LEAVEDATEFROM ||''' LEAVEDATEFROM ,null SYSROWID ,'|| CHR(10)
                ||'  '''||c1.USERNAME||''' USERNAME,'''||c1.OPERATIONMODE||''' OPERATIONMODE '|| CHR(10)                
                ||'   FROM DUAL '|| CHR(10);
                 execute immediate lv_SqlStr;   
                 
                 
         lv_SqlStr:= 'UPDATE GBL_PISREIMBURSEMENTDETAILS SET PAIDAMOUNT='||lv_BillAmountUp||  CHR(10)
                    ||' WHERE COMPANYCODE= '''||C1.COMPANYCODE||''' '|| CHR(10)
                    ||' AND DIVISIONCODE='''||C1.DIVISIONCODE||''' '||CHR(10)
                    ||' AND YEARCODE='''||C1.YEARCODE||''' '||CHR(10)
                    ||' AND WORKERSERIAL='''||C1.WORKERSERIAL||''' '||CHR(10)
                    ||' AND FORYEARCODE='''||C1.YEARCODE||''' '||CHR(10)
                    ||' AND YEARMONTH='''||C1.YEARMONTH||''' '||CHR(10);
                    execute immediate lv_SqlStr;                      
                    
        end loop;                    
                
    --  end if;     
end;
/


DROP PROCEDURE PRCPIS_REIMBURSMENT_LTA_B4SAVE;

CREATE OR REPLACE PROCEDURE             PRCPIS_REIMBURSMENT_LTA_B4SAVE
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PISREIMBURSEMENTDETAILS%rowtype;
lv_ApplicationNo        varchar2(50);
lv_PrvYrCode            varchar2(50);
lv_BillAmountNw           number(18,2):=0;
lv_BillAmountUp           number(18,2):=0;
lv_SqlStr           varchar2(4000);

begin

    lv_result:='#SUCCESS#';
    
    select *
    into lv_Master
    from GBL_PISREIMBURSEMENTDETAILS
    WHERE ROWNUM<=1;

    select count(*)
    into lv_cnt
    from GBL_PISREIMBURSEMENTDETAILS;
    
     IF NVL(lv_cnt,0)=0 THEN
        lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
    END IF;
        
    IF lv_Master.OPERATIONMODE IS NULL THEN
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    END IF;            
    
    select count(*)
    into lv_cnt
    from PISREIMBURSEMENTDETAILS
    where companycode=lv_Master.companycode
    and divisioncode=lv_Master.divisioncode
    and yearcode=lv_Master.yearcode
    and yearmonth=lv_Master.yearmonth
    and componentcode=lv_Master.componentcode
    and categorycode=lv_Master.categorycode
    and gradecode=lv_Master.gradecode;
   

     IF NVL(lv_cnt,0)>0 THEN  
     
         for C2 in ( SELECT *   from PISREIMBURSEMENTDETAILS
                        where companycode=lv_Master.companycode
                        and divisioncode=lv_Master.divisioncode
                        and yearcode=lv_Master.yearcode
                        and yearmonth=lv_Master.yearmonth
                        and componentcode=lv_Master.componentcode
                        and categorycode=lv_Master.categorycode
                        and gradecode=lv_Master.gradecode ) loop
                        
               lv_SqlStr :=  ' delete from PISREIMBURSEMENTDETAILS'|| CHR(10)
                    ||' WHERE COMPANYCODE= '''||C2.COMPANYCODE||''' '|| CHR(10)
                    ||' AND DIVISIONCODE='''||C2.DIVISIONCODE||''' '||CHR(10)
                    ||' AND YEARCODE='''||C2.YEARCODE||''' '||CHR(10)
                    ||' AND WORKERSERIAL='''||C2.WORKERSERIAL||''' '||CHR(10)
                    ||' AND YEARMONTH='''||C2.YEARMONTH||''' '||CHR(10);
                    execute immediate lv_SqlStr;    
            END LOOP;
     end if;
       
        
    --  end if;     
end;
/


DROP PROCEDURE PRC_CREATE_DYNAMICVIEWPISRATE;

CREATE OR REPLACE PROCEDURE             prc_create_dynamicviewpisRATE
(
    p_compcode   varchar2, 
    p_divcode    varchar2,
    p_impexptype varchar2, 
    p_impexpqry  varchar2,
    p_yearmonth  varchar2,
    p_category   varchar2,
    p_grade      varchar2,
    p_readonly   varchar2 default null
)

as
lv_SqlStr       varchar2(30000) := '';
lv_temp_table   varchar2(30) := 'GBL_TBL_G_DYNAMIC';
lv_tabexists    number;
lv_result       varchar2(10);
lv_error_remark varchar2(4000) := '';
lv_readonly     varchar2(100);
begin
    lv_result:='#SUCCESS#';
    if p_readonly is null then
        lv_readonly := 'true';
    end if;
    
    if p_readonly ='true' then
     lv_readonly := 'true , nedit';
    else
     lv_readonly := 'false'; 
    end if; 
    
    ----- Checking for Global Table Exists or not and recreate table
    select count(*) into lv_tabexists from user_tables where table_name = UPPER(lv_temp_table) ;
    if lv_tabexists > 0 then
        lv_sqlstr := 'DROP TABLE ' || lv_temp_table ;
       execute immediate lv_sqlstr ;         
    end if;
    lv_SqlStr := 'CREATE GLOBAL TEMPORARY TABLE ' || lv_temp_table || CHR(10)
               ||'AS ' || CHR(10) || p_impexpqry;
   dbms_output.put_line('TX'||lv_SqlStr);
  execute immediate lv_SqlStr;
    
    ----Checking for Global Table Exists or not and recreate table
    
    ----- for Dynamic View for variable column as per Global Table
    lv_SqlStr := 'create or replace force view vw_auto_dynamicgrid'|| chr(10);
    lv_SqlStr := lv_SqlStr || '('|| chr(10);
    lv_SqlStr := lv_SqlStr || '   companycode,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_name,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_header,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_length,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_data,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   qry_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || ')'|| chr(10);
    lv_SqlStr := lv_SqlStr || 'as'|| chr(10);
    lv_SqlStr := lv_SqlStr || 'select  '''||p_compcode||''' companycode,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_name || '','')order by x.serialno).extract (''//text()''),'','') column_name'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select ''^'' ||cname||''^'' column_name, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) column_name,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_header || '','')order by x.serialno).extract (''//text()''),'','') column_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select initcap(cname) column_header, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) column_header,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);          
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_length || '','')order by x.serialno).extract (''//text()''),'','') column_length'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select case when upper(cname) in (''COMPANYCODE'',''DIVISIONCODE'',''YEARCODE'',''SERIALNO'',''USERNAME'',''SYSROWID'', ''LASTMODIFIED'',''WORKERSERIAL'',''UNITCODE'',''TOKENNO'',''CATEGORYCODE'',''GRADECODE'',''TRANSACTIONTYPE'',''CALCULATIONDAYS'',''ADJUSTMENTDAYS'',''DEPARTMENTCODE'', ''DEPARTMENTDESC'',''OPERATIONMODE'') then 1 else'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                        decode(coltype,''VARCHAR2'',120,''CHAR'',80,''DATE'',100,''NUMBER'',100,1) end column_length, colno serialno from col '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) column_length,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ''[''||('|| chr(10);         
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_data || '','')order by x.serialno).extract (''//text()''),'','') column_data'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select trim(''{ data: ^''||cname|| ''^, type: $''||'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                             decode(coltype,''VARCHAR2'',''text'',''NUMBER'',''numeric$,format:$0.00'',''text'')|| ''$''||'|| chr(10);
---lv_SqlStr := lv_SqlStr || '                             case when cname in (select substr(columnname,instr(columnname,''.'')+1) from pistagwisefixedcolumnshow where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and tagtype='''||p_impexptype||''') then '', readOnly: true, nedit''  ELSE  '', readOnly: false '' end ||  '|| chr(10);
   lv_SqlStr := lv_SqlStr || '                             case when cname in (select substr(columnname,instr(columnname,''.'')+1) from pistagwisefixedcolumnshow where companycode='''||p_compcode||'''  and tagtype='''||p_impexptype||''') then '', readOnly: true, nedit''  ELSE  '', readOnly: ''|| '''||lv_readonly||'''  end ||  '|| chr(10);
   lv_SqlStr := lv_SqlStr || '                             case when cname in (''YEARMONTH'')then '', readOnly: true, nedit''   end ||    '|| chr(10);
--    lv_SqlStr := lv_SqlStr || '                             case when cname in (select substr(columnname,instr(columnname,''.'')+1) from pistagwisefixedcolumnshow where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and tagtype='''||p_impexptype||''') then '', readOnly: true, nedit'' '|| chr(10);
--    lv_SqlStr := lv_SqlStr || '                                  when cname in (select componentcode from pisgradecomponentmapping where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and categorycode='''||p_category||''' and gradecode='''||p_grade||''' '|| chr(10);
--    lv_SqlStr := lv_SqlStr || '                                                    and yearmonth=(select max(yearmonth) from pisgradecomponentmapping where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and categorycode='''||p_category||''' '|| chr(10);
--    lv_SqlStr := lv_SqlStr || '                                                                      and gradecode='''||p_grade||''' and to_number(yearmonth)<=to_number('''||p_yearmonth||'''))) then '', readOnly: '||lv_readonly||''' '|| chr(10);
--    lv_SqlStr := lv_SqlStr || '                                  when instr((select columnname from pistagwisefixedcolumnshow where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and tagtype='''||p_impexptype||''' and columnname like ''%,%'' and rownum=1),cname)>0 then '', readOnly: '||lv_readonly||''' else '', readOnly: true, nedit'' end ||'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                             '' }'') column_data, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x)||'']'' column_data,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);          
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.qry_header || '','')order by x.serialno).extract (''//text()''),'','') qry_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select case when coltype=''DATE'' then ''TO_CHAR(''||cname||'',$DD/MM/YYYY$) ''||cname else cname end qry_header, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) qry_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || ' from dual';
    dbms_output.put_line('TX'||lv_SqlStr);
   execute immediate lv_SqlStr;
    
    -- for Dynamic View for variable column as per Global Table
    
--exception
--when others then
--    lv_error_remark := sqlerrm;
--    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
--  dbms_output.put_line('TX'||sqlerrm ||'lv_SqlStr'||lv_SqlStr);
end;
/


DROP PROCEDURE PRC_CREATE_DYNAMIC_VIEW_PIS;

CREATE OR REPLACE PROCEDURE             prc_create_dynamic_view_pis
(
    p_compcode   varchar2, 
    p_divcode    varchar2,
    p_impexptype varchar2, 
    p_impexpqry  varchar2,
    p_yearmonth  varchar2,
    p_category   varchar2,
    p_grade      varchar2,
    p_readonly   varchar2 default null
)
as
lv_SqlStr       varchar2(30000) := '';
lv_temp_table   varchar2(30) := 'GBL_TBL_G_DYNAMIC';
lv_tabexists    number;
lv_result       varchar2(10);
lv_error_remark varchar2(4000) := '';
lv_readonly     varchar2(10);
begin
    lv_result:='#SUCCESS#';
    
    if p_readonly is null then
        lv_readonly := 'true';
    else
        lv_readonly := p_readonly;
    end if;
    
    ----- Checking for Global Table Exists or not and recreate table
    select count(*) into lv_tabexists from user_tables where table_name = UPPER(lv_temp_table) ;
    if lv_tabexists > 0 then
        lv_sqlstr := 'DROP TABLE ' || lv_temp_table ;
        execute immediate lv_sqlstr ;
    end if;
    
    lv_SqlStr := 'CREATE GLOBAL TEMPORARY TABLE ' || lv_temp_table || CHR(10)
               ||'AS ' || CHR(10) || p_impexpqry;
    execute immediate lv_SqlStr;
    ----- Checking for Global Table Exists or not and recreate table
    
    ----- for Dynamic View for variable column as per Global Table
    lv_SqlStr := 'create or replace force view vw_auto_dynamicgrid'|| chr(10);
    lv_SqlStr := lv_SqlStr || '('|| chr(10);
    lv_SqlStr := lv_SqlStr || '   companycode,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_name,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_header,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_length,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_data,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   qry_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || ')'|| chr(10);
    lv_SqlStr := lv_SqlStr || 'as'|| chr(10);
    lv_SqlStr := lv_SqlStr || 'select  '''||p_compcode||''' companycode,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_name || '','')order by x.serialno).extract (''//text()''),'','') column_name'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select ''^'' ||cname||''^'' column_name, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) column_name,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_header || '','')order by x.serialno).extract (''//text()''),'','') column_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select initcap(cname) column_header, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) column_header,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);          
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_length || '','')order by x.serialno).extract (''//text()''),'','') column_length'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select case when upper(cname) in (''COMPANYCODE'',''DIVISIONCODE'',''YEARCODE'',''SERIALNO'',''USERNAME'',''SYSROWID'',''LASTMODIFIED'',''WORKERSERIAL'',''UNITCODE'',''YEARMONTH'',''CATEGORYCODE'',''GRADECODE'',''TOTALDAYS'',''CALCULATIONDAYS'',''ADJUSTMENTDAYS'',''DEPARTMENTCODE'', ''DEPARTMENTDESC'') then 1 '||CHR(10);
    lv_SqlStr := lv_SqlStr || '                        WHEN UPPER(CNAME) = ''TOKENNO'' THEN 70 '||CHR(10);
    lv_SqlStr := lv_SqlStr || '                        WHEN UPPER(CNAME) = ''EMPLOYEENAME'' THEN 150 '||CHR(10);
    lv_SqlStr := lv_SqlStr || '                        else'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                        decode(coltype,''VARCHAR2'',120,''DATE'',80,''NUMBER'',70,''CHAR'',80,1) end column_length, colno serialno from col '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) column_length,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ''[''||('|| chr(10);         
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_data || '','')order by x.serialno).extract (''//text()''),'','') column_data'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select trim(''{ data: ^''||cname|| ''^, type: $''||'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                             decode(coltype,''VARCHAR2'',''text'',''NUMBER'',''numeric$,format:$0.00'',''text'')|| ''$''||'|| chr(10);    
    lv_SqlStr := lv_SqlStr || '                             case when cname in (select substr(columnname,instr(columnname,''.'')+1) from pistagwisefixedcolumnshow where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and tagtype='''||p_impexptype||''') then '', readOnly: true, nedit'' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                                  when cname in (select componentcode from pisgradecomponentmapping where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and categorycode='''||p_category||''' and gradecode='''||p_grade||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                                                    and yearmonth=(select max(yearmonth) from pisgradecomponentmapping where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and categorycode=UPPER('''||p_category||''') '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                                                                      and gradecode=UPPER('''||p_grade||''') and to_number(yearmonth)<=to_number('''||p_yearmonth||'''))) then '', readOnly: '||lv_readonly||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                                  when instr((select columnname from pistagwisefixedcolumnshow where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and tagtype='''||p_impexptype||''' and columnname like ''%,%'' and rownum=1),cname)>0 then '', readOnly: '||lv_readonly||''' else '', readOnly: true, nedit'' end ||'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                             '' }'') column_data, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x)||'']'' column_data,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);          
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.qry_header || '','')order by x.serialno).extract (''//text()''),'','') qry_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select case when coltype=''DATE'' then ''TO_CHAR(''||cname||'',$DD/MM/YYYY$) ''||cname else cname end qry_header, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) qry_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || ' from dual';
   DBMS_OUTPUT.PUT_LINE(lv_SqlStr); 
   execute immediate lv_SqlStr;
   -- DELETE FROM QRY_LOG;
   -- INSERT INTO QRY_LOG VALUES (lv_SqlStr);
 
    -- for Dynamic View for variable column as per Global Table
    
--exception
--when others then
--    lv_error_remark := sqlerrm;
--    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark)A);
    --dbms_output.put_line(sqlerrm);
end;
/


DROP PROCEDURE PRC_CREATE_VIEW_PIS_WITH_LEAVE;

CREATE OR REPLACE PROCEDURE          prc_create_view_pis_with_leave
(
    p_compcode   varchar2, 
    p_divcode    varchar2,
    p_impexptype varchar2, 
    p_impexpqry  varchar2,
    p_yearmonth  varchar2,
    p_category   varchar2,
    p_grade      varchar2,
    p_readonly   varchar2 default null
)
as
lv_SqlStr       varchar2(30000) := '';
lv_temp_table   varchar2(30) := 'GBL_TBL_G_DYNAMIC';
lv_tabexists    number;
lv_result       varchar2(10);
lv_error_remark varchar2(4000) := '';
lv_readonly     varchar2(10);
begin
    lv_result:='#SUCCESS#';
    
    if p_readonly is null then
        lv_readonly := 'true';
    else
        lv_readonly := p_readonly;
    end if;
    
    ----- Checking for Global Table Exists or not and recreate table
    select count(*) into lv_tabexists from user_tables where table_name = UPPER(lv_temp_table) ;
    if lv_tabexists > 0 then
        lv_sqlstr := 'DROP TABLE ' || lv_temp_table ;
        execute immediate lv_sqlstr ;
    end if;
    
    lv_SqlStr := 'CREATE GLOBAL TEMPORARY TABLE ' || lv_temp_table || CHR(10)
               ||'AS ' || CHR(10) || p_impexpqry;
     --DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
    execute immediate lv_SqlStr;
    ----- Checking for Global Table Exists or not and recreate table
    
    ----- for Dynamic View for variable column as per Global Table
    lv_SqlStr := 'create or replace force view vw_auto_dynamicgrid'|| chr(10);
    lv_SqlStr := lv_SqlStr || '('|| chr(10);
    lv_SqlStr := lv_SqlStr || '   companycode,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_name,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_header,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_length,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_data,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   qry_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || ')'|| chr(10);
    lv_SqlStr := lv_SqlStr || 'as'|| chr(10);
    lv_SqlStr := lv_SqlStr || 'select  '''||p_compcode||''' companycode,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_name || '','')order by x.serialno).extract (''//text()''),'','') column_name'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select ''^'' ||cname||''^'' column_name, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) column_name,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, REPLACE(REPLACE(x.column_header,''TOKENNO'',''EMP NO''),''WORKINGDAYS'',''WRK DAYS'') || '','')order by x.serialno).extract (''//text()''),'','') column_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select UPPER(cname) column_header, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) column_header,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);          
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_length || '','')order by x.serialno).extract (''//text()''),'','') column_length'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select case when upper(cname) in (''COMPANYCODE'',''DIVISIONCODE'',''YEARCODE'',''SERIALNO'',''USERNAME'',''SYSROWID'',''LASTMODIFIED'',''WORKERSERIAL'',''UNITCODE'',''YEARMONTH'',''CATEGORYCODE'',''GRADECODE'',''TOTALDAYS'',''CALCULATIONDAYS'',''ADJUSTMENTDAYS'',''DEPARTMENTCODE'', ''DEPARTMENTDESC'',''CALCULATIONFACTORDAYS'') then 1'||chr(10);
    lv_SqlStr := lv_SqlStr || '                       WHEN upper(cname) LIKE ''%_LWP'' THEN 1 WHEN UPPER(CNAME) LIKE ''%TOKENNO%'' THEN 70 else'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                        decode(coltype,''VARCHAR2'',120,''DATE'',100,''NUMBER'',70,1) end column_length, colno serialno from col '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) column_length,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ''[''||('|| chr(10);         
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_data || '','')order by x.serialno).extract (''//text()''),'','') column_data'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select trim(''{ data: ^''||cname|| ''^, type: $''||'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                             decode(coltype,''VARCHAR2'',''text'',''NUMBER'',''numeric$,format:$0.00'',''text'')|| ''$''||'|| chr(10);    
    lv_SqlStr := lv_SqlStr || '                             case when cname in (select substr(columnname,instr(columnname,''.'')+1) from pistagwisefixedcolumnshow where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and tagtype='''||p_impexptype||''') then '', readOnly: true, nedit'' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                                  when cname in (select componentcode from pisgradecomponentmapping where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and categorycode='''||p_category||''' and gradecode='''||p_grade||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                                                    and yearmonth=(select max(yearmonth) from pisgradecomponentmapping where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and categorycode='''||p_category||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                                                                      and gradecode='''||p_grade||''' and to_number(yearmonth)<=to_number('''||p_yearmonth||'''))) then '', readOnly: '||lv_readonly||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                                  when instr((select columnname from pistagwisefixedcolumnshow where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and tagtype='''||p_impexptype||''' and columnname like ''%,%'' and rownum=1),cname)>0 then '', readOnly: '||lv_readonly||''' else '', readOnly: true, nedit'' end ||'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                             '' }'') column_data, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x)||'']'' column_data,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);          
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.qry_header || '','')order by x.serialno).extract (''//text()''),'','') qry_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select case when coltype=''DATE'' then ''TO_CHAR(''||cname||'',$DD/MM/YYYY$) ''||cname else cname end qry_header, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) qry_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || ' from dual';
    execute immediate lv_SqlStr;
    DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
    -- for Dynamic View for variable column as per Global Table
    
exception
when others then
    lv_error_remark := sqlerrm;
    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    --dbms_output.put_line(sqlerrm);
end;
/


DROP PROCEDURE PRC_CREATE_VIEW_PIS_WITH_LV_O;

CREATE OR REPLACE PROCEDURE             prc_create_view_pis_with_lv_O
(
    p_compcode   varchar2, 
    p_divcode    varchar2,
    p_impexptype varchar2, 
    p_impexpqry  varchar2,
    p_yearmonth  varchar2,
    p_category   varchar2,
    p_grade      varchar2,
    p_readonly   varchar2 default null
)
as
lv_SqlStr       varchar2(30000) := '';
lv_temp_table   varchar2(30) := 'GBL_TBL_G_DYNAMIC';
lv_tabexists    number;
lv_result       varchar2(10);
lv_error_remark varchar2(4000) := '';
lv_readonly     varchar2(10);
begin
    lv_result:='#SUCCESS#';
    
    if p_readonly is null then
        lv_readonly := 'true';
    else
        lv_readonly := p_readonly;
    end if;
    
    ----- Checking for Global Table Exists or not and recreate table
    select count(*) into lv_tabexists from user_tables where table_name = UPPER(lv_temp_table) ;
    if lv_tabexists > 0 then
        lv_sqlstr := 'DROP TABLE ' || lv_temp_table ;
        execute immediate lv_sqlstr ;
    end if;
    
    lv_SqlStr := 'CREATE GLOBAL TEMPORARY TABLE ' || lv_temp_table || CHR(10)
               ||'AS ' || CHR(10) || p_impexpqry;
     --DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
    execute immediate lv_SqlStr;
    ----- Checking for Global Table Exists or not and recreate table
    
    ----- for Dynamic View for variable column as per Global Table
    lv_SqlStr := 'create or replace force view vw_auto_dynamicgrid'|| chr(10);
    lv_SqlStr := lv_SqlStr || '('|| chr(10);
    lv_SqlStr := lv_SqlStr || '   companycode,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_name,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_header,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_length,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   column_data,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '   qry_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || ')'|| chr(10);
    lv_SqlStr := lv_SqlStr || 'as'|| chr(10);
    lv_SqlStr := lv_SqlStr || 'select  '''||p_compcode||''' companycode,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_name || '','')order by x.serialno).extract (''//text()''),'','') column_name'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select ''^'' ||cname||''^'' column_name, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) column_name,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_header || '','')order by x.serialno).extract (''//text()''),'','') column_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select initcap(cname) column_header, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) column_header,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);          
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_length || '','')order by x.serialno).extract (''//text()''),'','') column_length'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select case when upper(cname) in (''COMPANYCODE'',''DIVISIONCODE'',''YEARCODE'',''SERIALNO'',''USERNAME'',''SYSROWID'',''LASTMODIFIED'',''WORKERSERIAL'',''UNITCODE'',''YEARMONTH'',''CATEGORYCODE'',''GRADECODE'',''TOTALDAYS'',''CALCULATIONDAYS'',''ADJUSTMENTDAYS'',''DEPARTMENTCODE'', ''DEPARTMENTDESC'',''CALCULATIONFACTORDAYS'') then 1'||chr(10);
    lv_SqlStr := lv_SqlStr || '                       WHEN upper(cname) LIKE ''%_LWP'' THEN 1 else'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                        decode(coltype,''VARCHAR2'',120,''DATE'',100,''NUMBER'',70,1) end column_length, colno serialno from col '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) column_length,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ''[''||('|| chr(10);         
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.column_data || '','')order by x.serialno).extract (''//text()''),'','') column_data'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select trim(''{ data: ^''||cname|| ''^, type: $''||'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                             decode(coltype,''VARCHAR2'',''text'',''NUMBER'',''numeric$,format:$0.00'',''text'')|| ''$''||'|| chr(10);    
    lv_SqlStr := lv_SqlStr || '                             case when cname in (select substr(columnname,instr(columnname,''.'')+1) from pistagwisefixedcolumnshow where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and tagtype='''||p_impexptype||''') then '', readOnly: true, nedit'' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                                  when cname in (select componentcode from pisgradecomponentmapping where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and categorycode='''||p_category||''' and gradecode='''||p_grade||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                                                    and yearmonth=(select max(yearmonth) from pisgradecomponentmapping where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and categorycode='''||p_category||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                                                                      and gradecode='''||p_grade||''' and to_number(yearmonth)<=to_number('''||p_yearmonth||'''))) then '', readOnly: '||lv_readonly||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                                  when instr((select columnname from pistagwisefixedcolumnshow where companycode='''||p_compcode||''' and divisioncode='''||p_divcode||''' and tagtype='''||p_impexptype||''' and columnname like ''%,%'' and rownum=1),cname)>0 then '', readOnly: '||lv_readonly||''' else '', readOnly: true, nedit'' end ||'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                             '' }'') column_data, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x)||'']'' column_data,'|| chr(10);
    lv_SqlStr := lv_SqlStr || '        ('|| chr(10);          
    lv_SqlStr := lv_SqlStr || '         select rtrim(xmlagg(xmlelement(e, x.qry_header || '','')order by x.serialno).extract (''//text()''),'','') qry_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || '           from (select case when coltype=''DATE'' then ''TO_CHAR(''||cname||'',$DD/MM/YYYY$) ''||cname else cname end qry_header, colno serialno from col'|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
    lv_SqlStr := lv_SqlStr || '                  order by colno) x) qry_header'|| chr(10);
    lv_SqlStr := lv_SqlStr || ' from dual';
    execute immediate lv_SqlStr;
    --DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
    -- for Dynamic View for variable column as per Global Table
    
exception
when others then
    lv_error_remark := sqlerrm;
    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    --dbms_output.put_line(sqlerrm);
end;
/


DROP PROCEDURE PRC_PISCOMPONENTMERGE;

CREATE OR REPLACE procedure PRC_PISCOMPONENTMERGE
(
    p_companycode  varchar2,
    p_divisioncode varchar2,
    p_yearmonth    varchar2,
    p_phase_upto   int,
    p_adjustment_type varchar2 DEFAULT 'ADJUSTMENT' ,
    p_adjumsment_table varchar2   DEFAULT 'PISOTHERTRANSACTION',
    p_phase_table varchar2 DEFAULT 'PISPAYTRANSACTION_SWT'
)
as
   /*
   BEGIN
    prc_PISCOMPONENTMERGE
    (
        'LJ0054' ,
        '0001' ,
        '201612',
        6,
        'ADJUSTMENT'
        'PISOTHERTRANSACTION_T',
        'PISPAYTRANSACTION_T'
    ) ;
   END;
   */
    lv_upd_collist_d varchar2(4000) ;
    lv_upd_collist_s varchar2(4000) ;
    lv_upd_sql varchar2(30000) ;
    lv_rows int;
    lv_cnt int ;
    lv_sqlerrm varchar2(4000);
begin
    lv_upd_sql := 'update '||p_phase_table||' A '||chr(10)
                    ||' set '||chr(10)
                    ||' ( ' ;
    select count(*) into lv_rows from PISCOMPONENTMASTER 
    where companycode =  p_companycode
     and divisioncode = p_divisioncode
     AND YEARMONTH = ( SELECT MAX(YEARMONTH) FROM PISCOMPONENTMASTER
                       WHERE companycode =  p_companycode
                         and divisioncode = p_divisioncode
                         AND YEARMONTH <= p_yearmonth
                    )      
     AND phase < p_phase_upto 
     and includepayroll='Y' 
     and ATTENDANCEENTRYAPPLICABLE <> 'Y';
  
    lv_cnt := 0;                            
    for c1 in (  select COMPONENTCODE Col from PISCOMPONENTMASTER 
                 WHERE companycode =  p_companycode
                 and divisioncode = p_divisioncode
                 AND YEARMONTH = ( SELECT MAX(YEARMONTH) FROM PISCOMPONENTMASTER
                                   WHERE companycode =  p_companycode
                                     and divisioncode = p_divisioncode
                                     AND YEARMONTH <= p_yearmonth
                                 )      
                 AND phase < p_phase_upto 
                 and includepayroll='Y' 
                 and ATTENDANCEENTRYAPPLICABLE <> 'Y'
              ) loop
      lv_cnt:=lv_cnt+1;
      if lv_cnt < lv_rows then       
         lv_upd_collist_d := lv_upd_collist_d||c1.col||' , '  ;       
         lv_upd_collist_s := lv_upd_collist_s||' A.'||c1.col||'+SUM(B.'||c1.col||') ,'  ;  
      else
         lv_upd_collist_d := lv_upd_collist_d||c1.col||' ) '  ;       
         lv_upd_collist_s := lv_upd_collist_s||' A.'||c1.col||'+SUM(B.'||c1.col||') '  ; 
      end if;              
    end loop;               
   lv_upd_sql := lv_upd_sql||lv_upd_collist_d||' = ( SELECT '||lv_upd_collist_s||' FROM '||p_adjumsment_table||' B WHERE '||chr(10)
                 ||' B.COMPANYCODE = A.COMPANYCODE  '||chr(10)
                 ||' AND B.DIVISIONCODE = A.DIVISIONCODE '||chr(10)
                 ||' AND B.EFFECT_YEARMONTH = A.YEARMONTH '||chr(10)
                 ||' AND B.TRANSACTIONTYPE =  '''||p_adjustment_type||''' '||chr(10)
                 ||' AND A.WORKERSERIAL = B.WORKERSERIAL '||chr(10)
                 ||'  ) '||chr(10)
                 ||' WHERE '||chr(10)
                 ||'   COMPANYCODE = '''||p_companycode||'''  '||chr(10)
                 ||'   AND DIVISIONCODE = '''||p_divisioncode||'''  '||chr(10)
                 ||'   AND YEARMONTH = '''||p_yearmonth||'''  '||chr(10)
                 --||'   AND WORKERSERIAL IN ( SELECT WORKERSERIAL FROM '||p_adjumsment_table||' WHERE COMPANYCODE = '''||p_companycode||''' AND DIVISIONCODE = '''||p_divisioncode||''' AND EFFECT_YEARMONTH <= '''||p_yearmonth||''' ) ';
                 ||'   AND EXISTS ( SELECT WORKERSERIAL FROM '||p_adjumsment_table||' B  WHERE B.COMPANYCODE = A.COMPANYCODE AND B.DIVISIONCODE = A.DIVISIONCODE AND B.EFFECT_YEARMONTH = A.YEARMONTH  AND B.TRANSACTIONTYPE =  '''||p_adjustment_type||'''   AND B.WORKERSERIAL=A.WORKERSERIAL) ';
        --      dbms_output.put_line(lv_upd_sql); 
      execute immediate lv_upd_sql ;
exception
 WHEN OTHERS THEN
    lv_sqlerrm := sqlerrm ;
    INSERT INTO WPS_ERROR_LOG(PROC_NAME, ORA_ERROR_MESSG, ERROR_QUERY) VALUES('PRC_PISCOMPONENTMERGE',lv_sqlerrm,lv_upd_sql);
end ;
/


DROP PROCEDURE PRC_PISLEAVEEARN_INSERT;

CREATE OR REPLACE PROCEDURE PRC_PISLEAVEEARN_INSERT 
( 
    P_COMPCODE Varchar2, 
    P_DIVCODE Varchar2,
    P_TRANTYPE Varchar2, 
    P_PHASE  number, 
    P_YEARMONTH Varchar2,
    P_EFFECTYEARMONTH Varchar2, 
    P_TABLENAME Varchar2,
    P_PHASE_TABLENAME Varchar2,
    P_UNIT  Varchar2,
    P_CATEGORY    Varchar2  DEFAULT NULL,
    P_GRADE       Varchar2  DEFAULT NULL,
    P_DEPARTMENT  Varchar2  DEFAULT NULL,
    P_WORKERSERIAL VARCHAR2 DEFAULT NULL
)
as 
lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY'));

lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_AttnComponent    varchar2(4000) := ''; 
lv_CompWithZero     varchar2(1000) := '';
lv_CompWithValue    varchar2(4000) := '';
lv_CompCol          varchar2(1000) := '';
lv_SQLCompView      varchar2(4000) := '';
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName         varchar2(30)   := 'PRC_PISLEAVEEARN_INSERT';
lv_TranType         varchar2(20) := 'ATTENDANCE';
begin

--select * from pisleavetransaction

--select * from pisleaveapplication


--select * from pisleaveentitlement

--select * from sys_parameter
--WHERE PARAMETER_NAME='LEAVE BALANCE MAINTAIN PROPORTIONATE'




--SET DEFINE OFF;
--Insert into SYS_PARAMETER
--   (PARAMETER_NAME, PARAMETER_DESC, PARAMETER_VALUE, PROJECTNAME, COMPANYCODE, LASTMODIFIED, SYSROWID, DIVISIONCODE, USERNAME, ALLOW_CHANGE_FROM_INTERFACE)
-- Values
--   ('LEAVE BALANCE MAINTAIN PROPORTIONATE', 'LEAVE BALANCE MAINTAIN PROPORTIONATE', 'Y', 'PIS', 'BJ0056', 
--    TO_DATE('02/28/2015 22:45:18', 'MM/DD/YYYY HH24:MI:SS'), '9', '0001', 'SWT', 'SWT TO SET');
--COMMIT;


--SELECT * FROM PISLEAVEENTITLEMENT

--SELECT * FROM PISLEAVETRANSACTION

--INSERT INTO PISLEAVETRANSACTION

--SELECT A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE,A.CALENDARYEAR, '202101' YEARMONTH, 
--A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL, A.TOKENNO, LEAVECODE,round(ENTITLEMENTS/12,2) NOOFDAYS,
--'ADD' ADDLESS,'ENT' TRANSACTIONTYPE,SYSDATE WITHEFFECTFROM,'SWT' USERNAME,SYSDATE LASTMODIFIED,fn_generate_sysrowid SYSROWID 
--FROM PISLEAVEENTITLEMENT A, PISEMPLOYEEMASTER  B
--WHERE A.COMPANYCODE='BJ0056'
--AND A.DIVISIONCODE='0001'
--AND A.YEARCODE='2020-2021'
--AND A.DIVISIONCODE=B.DIVISIONCODE
--AND A.COMPANYCODE=B.COMPANYCODE
--AND A.DIVISIONCODE=B.DIVISIONCODE
--AND A.WORKERSERIAL=B.WORKERSERIAL


--SELECT * FROM PISLEAVETRANSACTION A
--WHERE A.COMPANYCODE='BJ0056'
--AND A.DIVISIONCODE='0001'
--AND A.YEARCODE='2020-2021'
--AND A.YEARMONTH='202101'
--AND A.WORKERSERIAL IN 
--(
--    SELECT WORKERSERIAL FROM PISEMPLOYEEMASTER
--    WHERE COMPANYCODE='BJ0056'
--    AND DIVISIONCODE='0001'
--    AND UNITCODE = '10'
--    AND CATEGORYCODE = '10'
--    AND GRADECODE = '10'
--)
--AND A.CATEGORYCODE = '10'
--AND A.GRADECODE = '10'



    lv_SqlStr := ' DELETE FROM '||P_TABLENAME;
    BEGIN
        execute immediate lv_SqlStr;
      EXCEPTION WHEN OTHERS THEN NULL;
    END;
    --INSERT INTO PISPAYTRANSACTION_SWT (
    lv_SqlStr := ' INSERT INTO '||P_TABLENAME||' ( '||CHR(10)
               ||' COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, EFFECT_YEARMONTH,UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO, '||CHR(10)  
               ||' TRANSACTIONTYPE, PAYMODE, ATTN_SALD, ATTN_WPAY, ATTN_ADJD, ATTN_TOTD, ATTN_LDAY, ATTN_HOLD, ATTN_CALCF, ATTN_OFFD, LDAY_PL, LDAY_CL, LDAY_SL '||CHR(10)
               ||' ,LV_ENCASH_DAYS '||CHR(10)
               ||'     ) '||CHR(10)
               ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE, A.YEARMONTH, '''||P_EFFECTYEARMONTH||''' EFFECT_YEARMONTH, A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL, B.TOKENNO, '||CHR(10) 
               ||' '''||P_TRANTYPE||''' TRANSACTIONTYPE, B.PAYMODE,  A.SALARYDAYS ATTN_SALD, NVL(A.WITHOUTPAYDAYS,0) ATTN_WPAY, NVL(A.ADJUSTMENTDAYS,0) ATTN_ADJD, '||CHR(10) 
               ||' NVL(A.TOTALDAYS,0) ATTN_TOTD, 0 ATTN_LDAY, NVL(A.HOLIDAYS,0) ATTN_HOLD, NVL(A.CALCULATIONFACTORDAYS,0) ATTN_CALCF, NVL(NOOFOFFDAYS,0) ATTN_OFFD, 0 LDAY_PL, 0 LDAY_CL, 0 LDAY_SL '||CHR(10)
               ||' ,NVL(LV_ENCASH_DAYS,0) LV_ENCASH_DAYS '||CHR(10)    
               ||'  FROM PISMONTHATTENDANCE A, PISEMPLOYEEMASTER B '||CHR(10)
               ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
               ||'   AND A.TRANSACTIONTYPE = '''||lv_TranType||''' '||chr(10)
               ||'   AND A.YEARMONTH = '''||P_YEARMONTH||'''    '||CHR(10)
               ||'   AND A.UNITCODE = '''||P_UNIT||'''        '||CHR(10);
    if NVL(P_CATEGORY,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.CATEGORYCODE = '''||P_CATEGORY||''' '||CHR(10);
    end if;
    if NVL(P_GRADE,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.GRADECODE = '''||P_GRADE||''' '||CHR(10);
    end if;
    if NVL(P_DEPARTMENT,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.DEPARTMENTCODE = '''||P_DEPARTMENT||''' '||CHR(10);
    end if;
    if NVL(P_WORKERSERIAL,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10);
    end if;
    if P_TRANTYPE = 'SALARY' OR P_TRANTYPE = 'ARREAR' THEN
        lv_SqlStr := lv_SqlStr ||'   AND (NVL(A.SALARYDAYS,0) + NVL(A.ADJUSTMENTDAYS,0)) > 0 '||CHR(10);
    end if;
    lv_SqlStr := lv_SqlStr||'   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
               ||' AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)  
               ||' ORDER BY A.TOKENNO  '||CHR(10); 
               
               
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    execute immediate lv_SqlStr; COMMIT;                      
exception
when others then
 lv_sqlerrm := sqlerrm ;
 insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
 values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
end;
/


DROP PROCEDURE PRC_PISLVDAYBEFORESAVE;

CREATE OR REPLACE procedure               prc_pislvdaybeforesave
as
lv_LEAVEDAYS number(5,2) ;
lv_rownum int;
lv_cnt int;
lv_fromdate date;
lv_error_messg varchar2(4000);
lv_error_event varchar2(2000):='Spliting the records by (Leave days)days difference';
PROCEDURE DEL_PISLEAVEAPPLICATION(P_COMPANYCODE VARCHAR2, P_DIVISIONCODE VARCHAR2, P_YEARCODE VARCHAR2, P_CATEGORYCODE VARCHAR2, P_GRADECODE VARCHAR2, P_LEAVECODE VARCHAR2, P_EMPLOYEEID VARCHAR2, P_EMPLOYEECODE VARCHAR2 , P_LEAVEAPPLIEDON DATE  )
AS
BEGIN
 DELETE FROM PISLEAVEAPPLICATION 
 WHERE
 COMPANYCODE=P_COMPANYCODE
 AND DIVISIONCODE=P_DIVISIONCODE
 AND YEARCODE=P_YEARCODE
 AND CATEGORYCODE=P_CATEGORYCODE
 AND GRADECODE=P_GRADECODE
 AND LEAVECODE=P_LEAVECODE
 AND WORKERSERIAL=P_EMPLOYEEID
 AND TOKENNO=P_EMPLOYEECODE
 AND LEAVEAPPLIEDON=P_LEAVEAPPLIEDON ; 
 --COMMIT;
END;
begin
   for c1 in ( select * from GBL_PISLEAVEAPPLICATION ) loop
      lv_cnt := 0;
      IF c1.OPERATIONMODE <> 'D' THEN
        if c1.OPERATIONMODE = 'A' THEN
            select count(*) into lv_cnt from PISLEAVEAPPLICATION 
            where 
            COMPANYCODE=c1.COMPANYCODE
             AND DIVISIONCODE=c1.DIVISIONCODE
             AND YEARCODE=c1.YEARCODE
             AND CATEGORYCODE=c1.CATEGORYCODE
             AND GRADECODE=c1.GRADECODE
             AND LEAVECODE=c1.LEAVECODE
             AND WORKERSERIAL=c1.WORKERSERIAL
             AND TOKENNO=c1.TOKENNO
             AND LEAVEAPPLIEDON=c1.LEAVEAPPLIEDON ;
            if lv_cnt > 0 then
              raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,'ABORTING .. DATA ALREADY EXISTS' ));
            end if;   
        end if; 
        IF c1.OPERATIONMODE <> 'A' THEN
          DEL_PISLEAVEAPPLICATION(C1.COMPANYCODE  , C1.DIVISIONCODE  , C1.YEARCODE , C1.CATEGORYCODE , C1.GRADECODE , C1.LEAVECODE , C1.WORKERSERIAL , C1.TOKENNO  , C1.LEAVEAPPLIEDON );
        END IF;
        lv_fromdate := c1.LEAVEAPPLIEDFROM ;        
        while lv_fromdate <= c1.LEAVEAPPLIEDTO loop
         lv_LEAVEDAYS := 1 ;          
         if c1.ADJUSTMENTTAG = 'F' then
          if lv_fromdate = c1.LEAVEAPPLIEDFROM then
            lv_LEAVEDAYS := 0.5 ;            
          end if;
         elsif c1.ADJUSTMENTTAG = 'L' then
          if lv_fromdate = c1.LEAVEAPPLIEDTO then
            lv_LEAVEDAYS := 0.5 ;            
          end if;
         end if;
         INSERT INTO PISLEAVEAPPLICATION
         ( 
          COMPANYCODE, DIVISIONCODE, YEARCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO, LEAVECODE, LEAVEAPPLIEDON, LEAVESANCTIONEDON, LEAVEDATE, LEAVEENCASHED, LEAVEAPPLICATIONREMARKS, LEAVESANCTIONREMARKS, LEAVEDAYS, ADJUSTMENTTAG, FINALSETTLEMENTTAG, TAXABLE, CALENDARYEAR,  USERNAME, SYSROWID
         )
         values
         ( 
          c1.COMPANYCODE, c1.DIVISIONCODE, c1.YEARCODE, c1.CATEGORYCODE, c1.GRADECODE, c1.WORKERSERIAL, c1.TOKENNO, c1.LEAVECODE, c1.LEAVEAPPLIEDON, c1.LEAVESANCTIONEDON, lv_fromdate, c1.LEAVEENCASHED, c1.LEAVEAPPLICATIONREMARKS, c1.LEAVESANCTIONREMARKS, lv_LEAVEDAYS, c1.ADJUSTMENTTAG, c1.FINALSETTLEMENTTAG, c1.TAXABLE, c1.CALENDARYEAR,  c1.USERNAME, c1.SYSROWID
         );
         lv_fromdate := lv_fromdate + 1;
        end loop;
      ELSE -- OPERATIONMODE  = 'D'
       DEL_PISLEAVEAPPLICATION(C1.COMPANYCODE  , C1.DIVISIONCODE  , C1.YEARCODE , C1.CATEGORYCODE , C1.GRADECODE , C1.LEAVECODE , C1.WORKERSERIAL , C1.TOKENNO  , C1.LEAVEAPPLIEDON );
      END IF;       
   end loop; -- select * from GBL_PISLEAVEAPPLICATION
   commit;
exception
when others then
 --dbms_output.put_line(sqlerrm);
 lv_error_messg := sqlerrm;
  insert into proc_error_log(PROC_NAME,ORA_ERROR_MESSG,PAR_VALUES,REMARKS) VALUES('prc_pislvdaybeforesave',lv_error_messg,null,lv_error_event);
 --NULL;
end;
/


DROP PROCEDURE PRC_PISSALARYPROCESS_ARREAR;

CREATE OR REPLACE PROCEDURE             PRC_PISSALARYPROCESS_ARREAR 
(
      P_COMPCODE Varchar2,  
      P_DIVCODE Varchar2,
      P_TRANTYPE Varchar2, 
      P_PHASE  number, 
      P_YEARMONTH_FR Varchar2,
      P_YEARMONTH_TO Varchar2,
      P_EFFECTYEARMONTH Varchar2, 
      P_TABLENAME Varchar2,
      P_PHASE_TABLENAME Varchar2,
      P_UNIT  Varchar2,
      P_CATEGORY    Varchar2  DEFAULT NULL,
      P_GRADE       Varchar2  DEFAULT NULL,
      P_DEPARTMENT  Varchar2  DEFAULT NULL,
      P_WORKERSERIAL VARCHAR2 DEFAULT NULL
)
as
/*
BEGIN
PRC_PISSALARYPROCESS_ARREAR 
(
      'JT0069',  
      '0001',
      'ARREAR', 
      0, 
      '201904',
      '201908',
      '201909', 
      '',
      '',
      'HO',
      'HO',
      'MANAGERIAL',
      '',
      '00013'
);
END;
*/
LV_SQLSTR VARCHAR2(4000);
lv_companycode varchar2(10) := LTRIM(TRIM(P_COMPCODE)) ; -- 'LJ0054'    
lv_locationcode varchar2(10) := LTRIM(TRIM(P_DIVCODE))  ; -- 0001'
lv_yearmonth varchar2(6) :=  LTRIM(TRIM(P_EFFECTYEARMONTH)) ;      --'201705';
lv_yearmonth_fr varchar2(6) := LTRIM(TRIM(P_YEARMONTH_FR));
lv_yearmonth_to varchar2(6) :=  LTRIM(TRIM(P_YEARMONTH_TO));
--lv_yearmonth_fr varchar2(6) := substr(lv_yearmonth,1,4)||'04';
--lv_yearmonth_to varchar2(6) := substr(lv_yearmonth,1,4)||lpad(substr(lv_yearmonth,-2)-1,2,'0') ;
lv_workerserial varchar2(10):=  LTRIM(TRIM(P_WORKERSERIAL)) ;           --'000040' ;
lv_totarrcomp int;
lv_rowcnt int:=1;
lv_cnt int;
lv_per number := 80;
lv_sql varchar2(20000);
lv_inssql_cols varchar2(10000)  ;
lv_inssql_vals varchar2(10000)  ;     
lv_inssql_cols_1  varchar2(10000)  ;
lv_inssql_vals_1 varchar2(10000)  ;
lv_col_val varchar2(10000);
lv_colval_str varchar2(10000);
lv_sum_grossdedn_colval varchar2(10000);
lv_sum_netsalary_colval varchar2(10000);
lv_colval_sum_str varchar2(10000);
lv_dedcolsum_str varchar2(10000);
lv_dedcolval_sum_str varchar2(10000);
lv_netsalcolval_sum_str varchar2(10000);
lv_colval_sum_str_val varchar2(10000);
lv_colval_neg_str varchar2(10000);
lv_comparrearamt number(19,2);
lv_yearmonth_tmp varchar2(6) := '';
lv_insert_fixed_col varchar2(10000) ;
lv_insert_fixed_col_val varchar2(10000) ;
lv_effective_ym varchar2(10)   ;
lv_yearcode varchar2(10)   ;
lv_startdate varchar2(10);
lv_enddate   varchar2(10);

-- to generate as arrear row with yearmonth > '201704'
--- non comp cols remaining same as '201704'
--- 
--BEGIN
--PRC_PISSALARYPROCESS_ARREAR ('LJ0054', '0001','','','201704','201704','201704','','','') ;
-- EXEC PRC_PISSALARYPROCESS_ARREAR('LJ0054', '0001','','','201704','201704','201705','','','');
--END;
--
BEGIN
--select count(distinct COMPONENTCODE) into lv_totarrcomp from piscomponentmaster where INCLUDEARREAR = 'Y' ;

select count(*) into lv_totarrcomp from ( select  distinct COMPONENTCODE COL from piscomponentmaster WHERE COMPONENTCODE NOT LIKE 'SARR_%'
                     --where INCLUDEARREAR = 'Y' 
                      intersect 
                      select column_name col from cols where table_name = 'PISARREARTRANSACTION'   
                      );


/*LV_SQLSTR := 'UPDATE PISARREARTRANSACTION_TEMP SET ' ;
for c1 in ( select distinct COMPONENTCODE from piscomponentmaster
where INCLUDEARREAR = 'Y' ) loop
  if lv_rowcnt < lv_totarrcomp then
   LV_SQLSTR := LV_SQLSTR||c1.COMPONENTCODE||' = '||c1.COMPONENTCODE||'+ ('||c1.COMPONENTCODE||'*('||lv_per||'/100)) , '||chr(10) ;
  else
   LV_SQLSTR := LV_SQLSTR||c1.COMPONENTCODE||' = '||c1.COMPONENTCODE||'+ ('||c1.COMPONENTCODE||'*('||lv_per||'/100))'||chr(10) ;
  end if;
  lv_rowcnt:=lv_rowcnt+1;
end loop;
  LV_SQLSTR := LV_SQLSTR||' WHERE COMPANYCODE = '''||lv_companycode||''' '||chr(10)
                        ||' AND DIVISIONCODE = '''||lv_locationcode||'''  '||chr(10)
                        ||' AND YEARMONTH = '''||lv_yearmonth||'''  '||chr(10)  
                        ||' AND WORKERSERIAL = '''||lv_workerserial||'''  '||chr(10) ;
 ---DBMS_output.put_line( LV_SQLSTR );
 --execute immediate LV_SQLSTR ; */
 
-- yearmonth , WORHER loop

DELETE GTT_PISARREARTRANSACTION;
 
        DELETE FROM PISARREARTRANSACTION
         WHERE companycode = NVL2(lv_companycode,lv_companycode ,companycode )
           and divisioncode = NVL2(lv_locationcode,lv_locationcode ,divisioncode )
           and WORKERSERIAL = NVL2(lv_workerserial,lv_workerserial ,WORKERSERIAL )
           AND UNITCODE =  NVL2(P_UNIT , P_UNIT , UNITCODE)
           AND CATEGORYCODE = NVL2(P_CATEGORY , P_CATEGORY , CATEGORYCODE )
           AND GRADECODE  =  NVL2(P_GRADE , P_GRADE , GRADECODE)
           and DEPARTMENTCODE =  NVL2(P_DEPARTMENT,P_DEPARTMENT,DEPARTMENTCODE)
          -- and ( YEARMONTH BETWEEN  lv_yearmonth_fr AND lv_yearmonth_to or YEARMONTH = lv_yearmonth  ) 
           AND EFFECT_YEARMONTH = lv_yearmonth
           and WORKERSERIAL = NVL2(lv_workerserial,lv_workerserial ,WORKERSERIAL ) 
           and TRANSACTIONTYPE <> 'NEW SALARY'  ;      


----DBMS_OUTPUT.PUT_LINE('ABC' || lv_yearmonth_fr || ',' || lv_yearmonth_to || ',' || lv_companycode  || ',' || lv_locationcode  || ',' || lv_workerserial) ;

--DBMS_OUTPUT.PUT_LINE(' WORKER WISE YEARMONTH WISE INSERT INTO GTT QUERY :- ') ;   
 

for c1 in (select companycode , DIVISIONCODE , UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE , YEARMONTH , EFFECT_YEARMONTH ,WORKERSERIAL  from PISARREARTRANSACTION
           where EFFECT_YEARMONTH = lv_yearmonth  AND YEARMONTH <= lv_yearmonth_to
           /*YEARMONTH between lv_yearmonth_fr and lv_yearmonth_to*/
           AND companycode = NVL2(lv_companycode,lv_companycode ,companycode )
           and divisioncode = NVL2(lv_locationcode,lv_locationcode ,divisioncode )
           and WORKERSERIAL = NVL2(lv_workerserial,lv_workerserial ,WORKERSERIAL )
           AND UNITCODE =  NVL2(P_UNIT , P_UNIT , UNITCODE)
           AND CATEGORYCODE = NVL2(P_CATEGORY , P_CATEGORY , CATEGORYCODE )
           AND GRADECODE  =  NVL2(P_GRADE , P_GRADE , GRADECODE)
           and DEPARTMENTCODE =  NVL2(P_DEPARTMENT,P_DEPARTMENT,DEPARTMENTCODE)
           order by companycode , DIVISIONCODE , UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE , YEARMONTH , WORKERSERIAL ) loop      
       
    --  --DBMS_OUTPUT.PUT_LINE('INSIDE LOOP 1') ;       
       

       lv_inssql_cols := 'INSERT INTO GTT_PISARREARTRANSACTION( ' ;
       lv_inssql_vals  := ' VALUES( ';             
       lv_col_val := '';
       lv_colval_str := '''';
       
   
       for c3 in (
                   select column_name col from cols where table_name = 'PISARREARTRANSACTION'
                   minus
                   select distinct COMPONENTCODE from piscomponentmaster
                    --where INCLUDEARREAR = 'Y'  
                 ) loop                    
                 lv_inssql_cols := lv_inssql_cols||c3.col||' , '||chr(10) ;
                 if ltrim(trim(c3.col)) = 'TRANSACTIONTYPE' then
                   lv_colval_str := lv_colval_str||'''''''||''MONTHLYARR''||'''''','  ;
                  else
                   lv_colval_str := lv_colval_str||'''''''||'||c3.col||'||'''''','  ;
                  end if;                           
        end loop;
        lv_colval_str := lv_colval_str||'''' ;        
        lv_sql := 'select '||lv_colval_str||'  from PISARREARTRANSACTION  where  companycode = '''||c1.companycode||'''  and DIVISIONCODE = '''||c1.DIVISIONCODE||''' and  UNITCODE = '''||c1.UNITCODE||''' and  DEPARTMENTCODE = '''||c1.DEPARTMENTCODE||''' and  CATEGORYCODE = '''||c1.CATEGORYCODE||''' and  GRADECODE  = '''||c1.GRADECODE||''' and YEARMONTH = '''||c1.YEARMONTH||''' and WORKERSERIAL = '''||c1.WORKERSERIAL||'''  ';
        
      --  DBMS_OUTPUT.PUT_LINE(  lv_sql );       
        execute immediate lv_sql into lv_col_val;
        
        lv_inssql_vals := lv_inssql_vals||lv_col_val;        
      
        ----DBMS_OUTPUT.PUT_LINE(lv_inssql_vals);
          
      --  exit; 
         lv_colval_str := '';
         lv_colval_sum_str := '';
         lv_colval_neg_str := '';
         lv_rowcnt :=1;
         for c2 in ( select distinct COMPONENTCODE COL from piscomponentmaster WHERE COMPONENTCODE NOT LIKE 'SARR_%'
                     --where INCLUDEARREAR = 'Y' 
                     intersect 
                      select column_name col from cols where table_name = 'PISARREARTRANSACTION'         
         ) loop   
              if lv_rowcnt < lv_totarrcomp then
                lv_inssql_cols := lv_inssql_cols||c2.col||' , '||chr(10) ;
                lv_colval_str := lv_colval_str||''||c2.col||','  ;
                lv_colval_sum_str := lv_colval_sum_str||'''''''||SUM('||c2.col||')||'''''','  ;
                lv_colval_neg_str := lv_colval_neg_str||''||c2.col||'*-1,'  ;
              else
                lv_inssql_cols := lv_inssql_cols||c2.col||' ) '||chr(10) ;
                lv_colval_str := lv_colval_str||''||c2.col  ;
                lv_colval_sum_str := lv_colval_sum_str||'''''''||SUM('||c2.col||')||'''''''  ;
                lv_colval_neg_str := lv_colval_neg_str||''||c2.col||'*-1'  ;
              end if;  
              --dbms_output.put_line ('amalesh '||lv_colval_sum_str);
              lv_rowcnt:=lv_rowcnt+1;
--             select c2.COMPONENTCODE into x from tab a where --- ;
--             select c2.COMPONENTCODE into y from tab b where --- ;
--             lv_comparrearamt = x-y ;
--             lv_insertsql =
--             insert into gtt_arreartab( c2.COMPONENTCODE ,
--                                   values(  lv_comparrearamt ,           
         end loop;
          
          lv_inssql_cols_1 := replace(lv_inssql_cols,'GTT_PISARREARTRANSACTION' ,'PISARREARTRANSACTION') ;
          --lv_inssql_vals_1 := replace(lv_inssql_vals ,'MONTHLYARR','ARREAR'); 
          --lv_inssql_vals_1 := replace(lv_inssql_vals ,'MONTHLYARR','TOT ARREAR');         
          lv_sql := 'select '''||lv_colval_sum_str||''' from (
                            (      
                            select '||lv_colval_str||' from PISARREARTRANSACTION where companycode = '''||c1.companycode||'''  and DIVISIONCODE = '''||c1.DIVISIONCODE||''' and  UNITCODE = '''||c1.UNITCODE||''' and  DEPARTMENTCODE = '''||c1.DEPARTMENTCODE||''' and  CATEGORYCODE = '''||c1.CATEGORYCODE||''' and  GRADECODE  = '''||c1.GRADECODE||''' and YEARMONTH = '''||c1.YEARMONTH||''' and TRANSACTIONTYPE = ''NEW SALARY'' and WORKERSERIAL = '''||c1.WORKERSERIAL||''' 
                            union all
                            select '||lv_colval_neg_str||' from PISPAYTRANSACTION  where companycode = '''||c1.companycode||'''  and DIVISIONCODE = '''||c1.DIVISIONCODE||''' and  UNITCODE = '''||c1.UNITCODE||''' and  DEPARTMENTCODE = '''||c1.DEPARTMENTCODE||''' and  CATEGORYCODE = '''||c1.CATEGORYCODE||''' and  GRADECODE  = '''||c1.GRADECODE||''' and YEARMONTH = '''||c1.YEARMONTH||''' and TRANSACTIONTYPE = ''SALARY'' and WORKERSERIAL = '''||c1.WORKERSERIAL||'''  
                            ) )' ;     
          DBMS_OUTPUT.PUT_LINE('xxx'||lv_sql);   
           --RETURN;             
           
           
                
           execute immediate lv_sql into lv_colval_sum_str_val ;      
           lv_inssql_vals := lv_inssql_vals||lv_colval_sum_str_val||')' ;
           --DBMS_OUTPUT.PUT_LINE(lv_inssql_cols||lv_inssql_vals);
           execute immediate lv_inssql_cols||lv_inssql_vals;
           
           
           ----DBMS_OUTPUT.PUT_LINE(lv_inssql_cols||lv_inssql_vals) ;     
        --  --DBMS_OUTPUT.PUT_LINE('INSIDE LOOP 2') ;      
end loop; -- c1    
commit; 

--DBMS_OUTPUT.PUT_LINE(' query for consolidation from ARRIL till ARREAR PROCESSING MONTH for above arrear processed workers :- ') ;   

-- end yearmonth , WORKER loop 
-- start consolidation from ARRIL till ARREAR PROCESSING MONTH for above arrear processed workers --
insert into PISARREARTRANSACTION select * from GTT_PISARREARTRANSACTION ;
--return;
lv_effective_ym   := lv_yearmonth ; 
begin    
  for c1 in ( select distinct COMPANYCODE, DIVISIONCODE, YEARCODE, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO from GTT_PISARREARTRANSACTION WHERE transactiontype = 'MONTHLYARR') loop
  lv_yearcode := c1.yearcode ;
  lv_insert_fixed_col := 'INSERT INTO PISARREARTRANSACTION (COMPANYCODE, DIVISIONCODE, YEARCODE, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO , YEARMONTH, EFFECT_YEARMONTH,TRANSACTIONTYPE ,' ;
  lv_insert_fixed_col_val :=   ' VALUES ( '''||c1.COMPANYCODE||''','''|| c1.DIVISIONCODE||''','''||lv_yearcode||''','''||c1.UNITCODE||''','''||c1.DEPARTMENTCODE||''','''||c1.CATEGORYCODE||''','''||c1.GRADECODE||''','''||c1.WORKERSERIAL||''','''||c1.TOKENNO||''','''||lv_effective_ym||''','''||lv_effective_ym||''',''ARREAR'' , ';
  lv_inssql_cols :=''  ;
  lv_inssql_vals :=''  ; 
  lv_colval_str  :='' ;
  lv_colval_sum_str := '' ;
  lv_dedcolval_sum_str := '';
  lv_dedcolsum_str := '';
  lv_rowcnt :=1;
        
        
  select count(distinct COMPONENTCODE) into lv_totarrcomp from piscomponentmaster a where COMPANYCODE = c1.COMPANYCODE and DIVISIONCODE = c1.DIVISIONCODE and
               INCLUDEARREAR = 'Y'  
               and yearmonth = (select max(yearmonth) from PISCOMPONENTMASTER b where 
                               a.COMPANYCODE = b.companycode
                               and a.DIVISIONCODE = b.DIVISIONCODE
                               and a.COMPONENTCODE = b.COMPONENTCODE 
                               --and COMPONENTTYPE = 'DEDUCTION' 
                               AND INCLUDEARREAR = 'Y' );
  for c3 in ( SELECT distinct COMPONENTCODE COL
              FROM PISCOMPONENTMASTER a
              WHERE COMPANYCODE = c1.COMPANYCODE
              and   DIVISIONCODE = c1.DIVISIONCODE
              and COMPONENTTYPE = 'DEDUCTION' 
              AND INCLUDEARREAR = 'Y'
              and yearmonth = (select max(yearmonth) from PISCOMPONENTMASTER b where 
                               a.COMPANYCODE = b.companycode
                               and a.DIVISIONCODE = b.DIVISIONCODE
                               and a.COMPONENTCODE = b.COMPONENTCODE 
                               and COMPONENTTYPE = 'DEDUCTION' 
                               AND INCLUDEARREAR = 'Y' )  
                    
                    
                    ) loop       
      if lv_rowcnt = 1 then
        lv_dedcolval_sum_str :=  lv_dedcolval_sum_str||'''''''||SUM('||c3.col||')' ; 
        lv_dedcolsum_str := lv_dedcolsum_str||'SUM(NVL('||c3.col||',0))' ;               
      else
        lv_dedcolval_sum_str :=  lv_dedcolval_sum_str||'+SUM('||c3.col||')' ;
        lv_dedcolsum_str := lv_dedcolsum_str||'+SUM(NVL('||c3.col||',0))' ; 
      end if;                    
  lv_rowcnt := lv_rowcnt+1;
  end loop; -- c3
  lv_netsalcolval_sum_str := '''''''||( SUM(NVL(GROSSEARN,0)) - ('||lv_dedcolsum_str||'))||'''''' '; 
  lv_dedcolval_sum_str:= '''''''||('||lv_dedcolsum_str||')||'''''' ';
  ----DBMS_output.put_line(lv_netsalcolval_sum_str);
  ----DBMS_output.put_line(lv_dedcolval_sum_str);
  --return;
  lv_rowcnt :=1;
  for c2 in ( select distinct COMPONENTCODE COL from piscomponentmaster a
              where COMPANYCODE = c1.COMPANYCODE and DIVISIONCODE = c1.DIVISIONCODE and
               INCLUDEARREAR = 'Y'  
               and yearmonth = (select max(yearmonth) from PISCOMPONENTMASTER b where 
                               a.COMPANYCODE = b.companycode
                               and a.DIVISIONCODE = b.DIVISIONCODE
                               and a.COMPONENTCODE = b.COMPONENTCODE 
                               --and COMPONENTTYPE = 'DEDUCTION' 
                               --AND INCLUDEARREAR = 'Y' 
                               )         
               ) loop   
              if lv_rowcnt < lv_totarrcomp then
                lv_inssql_cols := lv_inssql_cols||c2.col||' , '||chr(10) ;
                lv_colval_str := lv_colval_str||''||c2.col||','  ;
                lv_colval_sum_str := lv_colval_sum_str||'''''''||SUM('||c2.col||')||'''''','  ;                 
              else
                lv_inssql_cols := lv_inssql_cols||c2.col||'  '||chr(10) ; -- prev )
                lv_colval_str := lv_colval_str||''||c2.col  ;
                lv_colval_sum_str := lv_colval_sum_str||'''''''||SUM('||c2.col||')||'''''''  ;                 
              end if;  
              lv_rowcnt:=lv_rowcnt+1;                
         end loop;      -- c2    
   -- --DBMS_output.put_line(   lv_inssql_cols );
   -- --DBMS_output.put_line(   lv_colval_str );
    ----DBMS_output.put_line(   lv_colval_sum_str );  
    lv_sql := 'select '''||lv_colval_sum_str||/*','||*/lv_netsalcolval_sum_str||','||lv_dedcolval_sum_str||''' from GTT_PISARREARTRANSACTION where  '||chr(10)
               ||' COMPANYCODE = '''||c1.COMPANYCODE ||'''  '||chr(10)
               ||' AND DIVISIONCODE = '''||c1.DIVISIONCODE ||'''  '||chr(10)
               ||' AND UNITCODE = '''||c1.UNITCODE ||'''  '||chr(10)
               ||' AND DEPARTMENTCODE = '''||c1.DEPARTMENTCODE ||'''  '||chr(10)
               ||' AND CATEGORYCODE = '''||c1.CATEGORYCODE ||'''  '||chr(10)
               ||' AND GRADECODE = '''||c1.GRADECODE ||'''  '||chr(10)
               ||' AND WORKERSERIAL = '''||c1.WORKERSERIAL ||'''  '||chr(10)
               ||' AND  TOKENNO = '''||c1.TOKENNO ||'''  '||chr(10) ;       
    --DBMS_output.put_line( ' nEt sal - ' || lv_sql ); 
--    DBMS_OUTPUT.PUT_LINE('lv_colval_sum_str -  '||lv_colval_sum_str);
--    dbms_output.Put_line('lv_netsalcolval_sum_str -  '||lv_netsalcolval_sum_str);
--    dbms_output.Put_line('lv_dedcolval_sum_str -  '|| lv_dedcolval_sum_str);
    --return;  
    
    
    execute immediate  lv_sql into lv_colval_str   ;
   --DBMS_output.put_line(  lv_insert_fixed_col||lv_inssql_cols||lv_insert_fixed_col_val||lv_colval_str||')' ); 
   --DBMS_output.put_line( lv_insert_fixed_col||lv_inssql_cols||',NETSALARY,GROSSDEDN)'||lv_insert_fixed_col_val||lv_colval_str||')' ) ;
   --return;
   
--    DBMS_output.put_line(lv_insert_fixed_col);
--    DBMS_output.put_line(lv_inssql_cols);
----    DBMS_output.put_line(',NETSALARY,GROSSDEDN)');
--    DBMS_output.put_line(lv_insert_fixed_col_val);
--   DBMS_output.put_line(lv_colval_str);
    
   
   --DBMS_OUTPUT.PUT_LINE ('DAS '||lv_insert_fixed_col||lv_inssql_cols||'NETSALARY,GROSSDEDN)'||lv_insert_fixed_col_val||lv_colval_str||')' ); 
   
   
   execute immediate lv_insert_fixed_col||lv_inssql_cols||'NETSALARY,GROSSDEDN)'||lv_insert_fixed_col_val||lv_colval_str||')' ;
    
--   DBMS_output.put_line('1111'||lv_insert_fixed_col||lv_inssql_cols||',NETSALARY,GROSSDEDN)'||lv_insert_fixed_col_val||lv_colval_str||')' );
   
   --execute immediate lv_insert_fixed_col||lv_inssql_cols||',NETSALARY,TOTALDED)'||lv_insert_fixed_col_val||lv_colval_str||')' ;
   
   --DBMS_output.put_line('1111'||lv_insert_fixed_col||lv_inssql_cols||lv_insert_fixed_col_val||lv_colval_str||')' );
    
  end loop; --c1
  RETURN;
  --- update CAPREPAYAMOUNT , loanintamount , grossdeduction , netsalary ---
  for c_wrk in( select COMPANYCODE, DIVISIONCODE, YEARCODE, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO from PISARREARTRANSACTION 
                        WHERE yearmonth = lv_effective_ym
                        and transactiontype = 'ARREAR'
                        AND UNITCODE =  P_UNIT 
                        AND CATEGORYCODE =  P_CATEGORY 
                        AND GRADECODE  =   P_GRADE  
                        -- and WORKERSERIAL = '00013' 
              ) loop               
      lv_sql := 'UPDATE PISARREARTRANSACTION set '||chr(10) ; 
      lv_cnt := 1;
      select count(*) into lv_rowcnt from LOANADJFROMARREAR
                      where   companycode  = c_wrk.COMPANYCODE
                           and   divisioncode = c_wrk.DIVISIONCODE
                           and   yearmonth    = lv_effective_ym
                           and   workerserial = c_wrk.WORKERSERIAL ;  
     
    IF lv_rowcnt > 0 THEN                             
      for c_lint in(  select LOANCODE, CAPREPAYAMOUNT, INTREPAYAMOUNT from LOANADJFROMARREAR
                      where   companycode  = c_wrk.COMPANYCODE
                           and   divisioncode = c_wrk.DIVISIONCODE
                           and   yearmonth    = lv_effective_ym
                           and   workerserial = c_wrk.WORKERSERIAL ) loop
                              
       if lv_cnt < lv_rowcnt then
        lv_sql :=  lv_sql||' LOAN_'||c_lint.LOANCODE||' = '||nvl(c_lint.CAPREPAYAMOUNT,0)||' , LINT_'||c_lint.LOANCODE||' = '||nvl(c_lint.INTREPAYAMOUNT,0)||' , GROSSDEDN = NVL(GROSSDEDN,0) + NVL('||c_lint.CAPREPAYAMOUNT||',0) + NVL('||c_lint.INTREPAYAMOUNT||',0) , NETSALARY = NETSALARY -'||nvl(c_lint.CAPREPAYAMOUNT,0)||'-'||nvl(c_lint.INTREPAYAMOUNT,0)||' , ';
       else
        lv_sql :=  lv_sql||' LOAN_'||c_lint.LOANCODE||' = '||nvl(c_lint.CAPREPAYAMOUNT,0)||' , LINT_'||c_lint.LOANCODE||' = '||nvl(c_lint.INTREPAYAMOUNT,0)||' , GROSSDEDN = NVL(GROSSDEDN,0) + NVL('||c_lint.CAPREPAYAMOUNT||',0) + NVL('||c_lint.INTREPAYAMOUNT||',0) , NETSALARY = NETSALARY -'||nvl(c_lint.CAPREPAYAMOUNT,0)||'-'||nvl(c_lint.INTREPAYAMOUNT,0)||'  '||chr(10);
       end if;
       lv_cnt:=lv_cnt+1;
      end loop;              
      lv_sql :=  lv_sql||' WHERE  COMPANYCODE = '''||c_wrk.COMPANYCODE||''' '||chr(10)
                       ||' AND    DIVISIONCODE = '''||c_wrk.DIVISIONCODE||''' '||chr(10)    
                       ||' AND    YEARCODE =     '''||c_wrk.YEARCODE||''' '||chr(10)   
                       ||' AND    YEARMONTH =     '''||lv_effective_ym||''' '||chr(10)  
                       ||' AND    TRANSACTIONTYPE =     ''ARREAR'' '||chr(10)
                       ||' AND    WORKERSERIAL =     '''||c_wrk.WORKERSERIAL||''' ' ;
     --dbms_output.put_line( ' UPDATE LOAN / DEDN '||lv_sql);         
     execute immediate  lv_sql;   
       
    END IF; 
  end loop;
  
  lv_startdate := '01/' || SUBSTR(P_EFFECTYEARMONTH,5,2) || '/' || SUBSTR(P_EFFECTYEARMONTH,1,4);   
  lv_enddate := TO_CHAR(ADD_MONTHS(to_date(lv_startdate,'dd/mm/yyyy'),1) -1,'DD/MM/YYYY');
    
  PRC_LOANBREAKUP_INSERT_WAGES 
  ( 
      P_COMPCODE ,  
      P_DIVCODE ,
      'XXXX-YYYY',
      lv_startdate, 
      lv_enddate,
      'PIS',
      'PISARREARTRANSACTION',
      'SALARY',
      NULL,
      NULL,
      NULL,
      'ARREAR'
  );
  
end;
commit;
-- end consolidation from ARRIL till ARREAR PROCESSING MONTH   --
----DBMS_output.put_line(lv_inssql_cols||lv_inssql_vals); 
END;
/


DROP PROCEDURE PRC_PISSALARYPROCESS_TRANSFER;

CREATE OR REPLACE PROCEDURE          PRC_PISSALARYPROCESS_TRANSFER (
                                                  P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_TRANTYPE Varchar2, 
                                                  P_PHASE  number, 
                                                  P_YEARMONTH Varchar2,
                                                  P_EFFECTYEARMONTH Varchar2, 
                                                  P_TABLENAME Varchar2,
                                                  P_PHASE_TABLENAME Varchar2,
                                                  P_UNIT  Varchar2,
                                                  P_CATEGORY    Varchar2  DEFAULT NULL,
                                                  P_GRADE       Varchar2  DEFAULT NULL,
                                                  P_DEPARTMENT  Varchar2  DEFAULT NULL,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL
)
as

lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,0,4),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,0,4),'DD/MM/YYYY'));
lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName     varchar2(30) := 'PRC_PISSALARYPROCESS_TRANSFER';
lv_Sql_TblCreate    varchar2(4000) := '';
lv_Component        varchar2(4000) := ''; 
lv_SqlComponent     varchar2(2000) := '';
lv_YearCode         varchar2(20):='';

begin
    lv_remarks := 'PHASE - '||P_PHASE||' START';
    lv_parvalues := 'COMP='||P_COMPCODE||',DIV = '||P_DIVCODE||', YEARMONTH = '||P_YEARMONTH||', EFF.YEARMONTH'||P_EFFECTYEARMONTH||',PHASE='||P_PHASE;
    
    lv_SqlStr:='SELECT YEARCODE FROM FINANCIALYEAR WHERE COMPANYCODE='''||P_COMPCODE||''' AND DIVISIONCODE='''||P_DIVCODE||''' '||CHR(10)
               ||'AND STARTDATE<=TO_DATE('''||TO_char(lv_fn_stdt,'DD/MM/YYYY')||''',''DD/MM/YYYY'') AND ENDDATE>=TO_DATE('''||TO_char(lv_fn_stdt,'DD/MM/YYYY')||''',''DD/MM/YYYY'')'||CHR(10);
               
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
    EXECUTE IMMEDIATE lv_SqlStr;
               
    EXECUTE IMMEDIATE lv_SqlStr into lv_YearCode;
    
    lv_SqlStr := ' delete from '||P_TABLENAME||' WHERE COMPANYCODE = '''||P_COMPCODE||''' '||CHR(10)
               ||' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10) 
--               ||' AND EFFECT_YEARMONTH = '''||P_EFFECTYEARMONTH||''' '||CHR(10) -- FOR ARREAR PROCESS INSTEADE OF EFFECTYEARMONTH YEARMONTH IS USE BISHWANATH 02/11/2019
               ||' AND YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
               ||' AND TRANSACTIONTYPE =  '''||P_TRANTYPE||''' '||CHR(10)
               ||' AND UNITCODE = '''||P_UNIT||''' '||CHR(10);
        IF NVL(P_CATEGORY,'AMALESH_SWT') <> 'AMALESH_SWT' THEN                   
               lv_SqlStr := lv_SqlStr||' AND NVL(CATEGORYCODE,'''||P_CATEGORY||''') = '''||P_CATEGORY||''' '||CHR(10);
        end if;
        IF NVL(P_GRADE,'AMALESH_SWT') <> 'AMALESH_SWT' THEN                   
               lv_SqlStr := lv_SqlStr||' AND GRADECODE = '''||P_GRADE||''' '||CHR(10);
        end if;            
        IF NVL(P_WORKERSERIAL,'XX') <> 'XX' THEN
               lv_SqlStr := lv_SqlStr||' AND WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10); 
        END IF;
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
    EXECUTE IMMEDIATE lv_SqlStr;                   
    lv_SqlStr := 'INSERT INTO '||P_TABLENAME||' SELECT * FROM '||P_PHASE_TABLENAME||' ';
    lv_remarks := 'PHASE - '||P_PHASE||' SUCESSFULLY COMPLETE';
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
    EXECUTE IMMEDIATE lv_SqlStr;
            
commit;
-------------------------------------------------ADD FOR PF TRANSFER-----------------------------------------------------------------------
--    IF P_TRANTYPE ='SALARY' THEN --- IT'S NOT REQUIRE AT THE TIME  OF ARREAR PROCESS
--        PRCMONTHLYPFCONTDATATRANSFER(P_COMPCODE,P_DIVCODE,lv_YearCode,lv_fn_stdt,lv_fn_endt,'PIS');
--    END IF;        
exception
    when others then
    lv_sqlerrm := sqlerrm ;
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt, lv_fn_endt,lv_remarks);
    commit;

    --dbms_output.put_line('PROC - PROC_WPSWAGESPROCESS_UPDATE : ERROR !! WHILE WAGES PROCESS '||P_FNSTDT||' AND PHASE -> '||ltrim(trim(P_PHASE))||' : '||sqlerrm);
end;
/


DROP PROCEDURE PRC_PISSALARYPROCESS_UPDTARR;

CREATE OR REPLACE PROCEDURE PRC_PISSALARYPROCESS_UPDTARR ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_TRANTYPE Varchar2, 
                                                  P_PHASE  number, 
                                                  P_YEARMONTH Varchar2,
                                                  P_EFFECTYEARMONTH Varchar2, 
                                                  P_TABLENAME Varchar2,
                                                  P_PHASE_TABLENAME Varchar2,
                                                  P_UNIT  Varchar2,
                                                  P_CATEGORY    Varchar2  DEFAULT NULL,
                                                  P_GRADE       Varchar2  DEFAULT NULL,
                                                  P_DEPARTMENT  Varchar2  DEFAULT NULL,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
as 
lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY'));

lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_AttnComponent    varchar2(4000) := ''; 
lv_CompWithZero     varchar2(1000) := '';
lv_CompWithValue    varchar2(4000) := '';
lv_CompCol          varchar2(1000) := '';
lv_SQLCompView      varchar2(4000) := '';
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName         varchar2(30)   := 'PRC_PISSALARYPROCESS_UPDTARR';
lv_TranType         varchar2(20) := 'ATTENDANCE';
begin
    
    --DBMS_OUTPUT.PUT_LINE('DD');

    lv_SqlStr := '';
    lv_SqlStr := lv_SqlStr || CHR(10) || ' UPDATE ' || P_PHASE_TABLENAME || ' A ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '    SET (SARR_ARRE, SARR_ARRD, SARR_PFARRE, SARR_NPFARRE) = ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '        ( ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '          SELECT GROSSEARN, GROSSDEDN, PF_GROSS, GROSSEARN - PF_GROSS ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '            FROM ' || P_TABLENAME || ' ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '           WHERE COMPANYCODE = A.COMPANYCODE ';    
    lv_SqlStr := lv_SqlStr || CHR(10) || '             AND DIVISIONCODE = A.DIVISIONCODE ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '             AND YEARMONTH = A.YEARMONTH ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '             AND TRANSACTIONTYPE = ''ARREAR'' '; 
    lv_SqlStr := lv_SqlStr || CHR(10) || '             AND UNITCODE = A.UNITCODE ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '             AND CATEGORYCODE = A.CATEGORYCODE ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '             AND GRADECODE = A.GRADECODE ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '             AND DEPARTMENTCODE = A.DEPARTMENTCODE ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '             AND WORKERSERIAL = A.WORKERSERIAL ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '        ) ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '  WHERE COMPANYCODE = ''' || P_COMPCODE || ''' ';    
    lv_SqlStr := lv_SqlStr || CHR(10) || '    AND DIVISIONCODE = ''' || P_DIVCODE || ''' ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '    AND YEARMONTH = ''' || P_YEARMONTH || ''' ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '    AND UNITCODE = ''' || P_UNIT || ''' ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '    AND CATEGORYCODE = NVL2(''' || P_CATEGORY || ''' , ''' || P_CATEGORY || ''' , CATEGORYCODE ) ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '    AND GRADECODE = NVL2(''' || P_GRADE || ''' , ''' || P_GRADE || ''' , GRADECODE) ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '    AND DEPARTMENTCODE = NVL2(''' || P_DEPARTMENT || ''',''' || P_DEPARTMENT || ''',DEPARTMENTCODE) ';
    lv_SqlStr := lv_SqlStr || CHR(10) || '    AND WORKERSERIAL = NVL2(''' || P_WORKERSERIAL || ''',''' || P_WORKERSERIAL || ''',WORKERSERIAL)';
    
    --DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
    
    --RETURN;
    
    insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    execute immediate lv_SqlStr;
    
    COMMIT;                      
exception
when others then
 --insert into error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'ERROR SQL',lv_sqlstr,lv_sqlstr,lv_parvalues,lv_remarks);
 lv_sqlerrm := sqlerrm ;
 --dbms_output.put_line(lv_sqlerrm);
 insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
end;
/


DROP PROCEDURE PRC_PISSALARY_NONARREAR_UPDT;

CREATE OR REPLACE PROCEDURE PRC_PISSALARY_NONARREAR_UPDT ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_TRANTYPE Varchar2, 
                                                  P_PHASE  number, 
                                                  P_YEARMONTH Varchar2,
                                                  P_EFFECTYEARMONTH Varchar2, 
                                                  P_TABLENAME Varchar2,
                                                  P_PHASE_TABLENAME Varchar2,
                                                  P_UNIT  Varchar2,
                                                  P_CATEGORY    Varchar2  DEFAULT NULL,
                                                  P_GRADE       Varchar2  DEFAULT NULL,
                                                  P_DEPARTMENT  Varchar2  DEFAULT NULL,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
as 
lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY'));
lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_Sql              varchar2(10000) := '';
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName         varchar2(30)   := 'PRC_PISSALARY_NONARREAR_UPDT';
lv_Component        varchar2(4000) := '';
lv_UpdtDestnComp    varchar2(300) := '';
lv_UpdtSourceComp   varchar2(300) := ''; 
 
begin
    lv_parvalues := 'COMP='||P_COMPCODE||',DIV = '||P_DIVCODE||', YEARMONTH = '||P_YEARMONTH||', EFF.YEARMONTH'||P_EFFECTYEARMONTH||',PHASE='||P_PHASE;
    
     
    BEGIN
        SELECT WM_CONCAT('NVL('||COMPONENTCODE||',0) AS '||COMPONENTCODE), WM_CONCAT('A.'||COMPONENTCODE), WM_CONCAT('B.'||COMPONENTCODE)
        INTO  lv_Component, lv_UpdtDestnComp, lv_UpdtSourceComp
        FROM PISCOMPONENTMASTER
        WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
        AND PHASE = P_PHASE
        AND NVL(INCLUDEPAYROLL,'N') = 'Y'
        AND NVL(INCLUDEARREAR,'N') <> 'Y'
        AND YEARMONTH = ( 
                          SELECT MAX(YEARMONTH) YEARMONTH FROM PISCOMPONENTMASTER
                          WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                            AND YEARMONTH <= P_YEARMONTH
                        )  
       ORDER BY NVL(CALCULATIONINDEX,0);
    EXCEPTION
        WHEN OTHERS THEN RETURN;   
    END;   
   
                 
    lv_Remarks := 'NON ARREARE COMPONENTS VALUE UPDATE ACTUAL VALUE PAID IN ACTUAL MONTH';
    
    lv_Sql := ' UPDATE '||P_TABLENAME||' A  SET ( '||lv_UpdtDestnComp||' ) = '||chr(10) 
            ||' ( '||chr(10)
            ||'     SELECT '||lv_UpdtSourceComp||' FROM PISPAYTRANSACTION B '||chr(10) 
            ||'     WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'       AND B.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
            ||'       AND B.TRANSACTIONTYPE LIKE ''%SALARY%'' '||CHR(10)
            ||'       AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
            ||'       AND A.YEARMONTH = B.YEARMONTH '||CHR(10)
            ||'      AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
            ||'  )  '||CHR(10)   
            ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'   AND WORKERSERIAL IN ( SELECT WORKERSERIAL FROM PISPAYTRANSACTION '||CHR(10)
            ||'                         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'                           AND YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
            ||'                           AND TRANSACTIONTYPE LIKE ''%SALARY%'' '||CHR(10)
            ||'                       ) '||CHR(10);                   
                            
                  
--   dbms_output.put_line('2_1 :- '||lv_Sql);
--   RETURN;
     

    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
    EXECUTE IMMEDIATE lv_Sql;  
    COMMIT;

exception
when others then
 lv_sqlerrm := sqlerrm ;
 insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
 values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
end;
/


DROP PROCEDURE PRC_PISSALARY_OTHCOMP_UPDATE;

CREATE OR REPLACE PROCEDURE          PRC_PISSALARY_OTHCOMP_UPDATE ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_TRANTYPE Varchar2, 
                                                  P_PHASE  number, 
                                                  P_YEARMONTH Varchar2,
                                                  P_EFFECTYEARMONTH Varchar2, 
                                                  P_TABLENAME Varchar2,
                                                  P_PHASE_TABLENAME Varchar2,
                                                  P_UNIT  Varchar2,
                                                  P_CATEGORY    Varchar2  DEFAULT NULL,
                                                  P_GRADE       Varchar2  DEFAULT NULL,
                                                  P_DEPARTMENT  Varchar2  DEFAULT NULL,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
as 
lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY'));
lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName         varchar2(30)   := 'PRC_PISSALARY_OTHCOMP_UPDATE';
lv_Sql_TblCreate    varchar2(4000) := '';
lv_Component        varchar2(4000) := ''; 
lv_SqlComponent     varchar2(2000) := ''; 

lv_MaxPensionGrossAmt   number(11,2) := 0;
lv_MaxPensionAmt        number(11,2) := 0;
lv_PensionPercentage    number(11,2) := 0;
lv_ESI_C_Percentage     number(11,2) := 0;
lv_updtable             varchar2(30)    := '';

Begin
    ---  update Pension Gross, pension and pf company contribution 
    SELECT MAXIMUMPENSIONGROSS, PENSION_PERCENTAGE, ESI_C_PERCENT 
    INTO lv_MaxPensionGrossAmt, lv_PensionPercentage, lv_ESI_C_Percentage
    FROM PISALLPARAMETER
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE;
    
    select SUBSTR( ( 'PIS_OTH_COMP'||SYS_CONTEXT('USERENV', 'SESSIONID')) ,1,30) into lv_updtable  from dual ;   
    
    lv_SqlStr := ' CREATE TABLE '||lv_updtable||' AS '||CHR(10)
                ||' SELECT COMPANYCODE, DIVISIONCODE, UNITCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, YEARMONTH, PFAPPLICABLE, EPFAPPLICABLE, PF_GROSS, PEN_GROSS, PF_E, FPF, PF_E- FPF PF_C, ESI_GROSS, ESI_E, ESI_C '||CHR(10)
                ||' FROM (  '||CHR(10)
                ||'         SELECT A.COMPANYCODE, A.DIVISIONCODE, A.UNITCODE, A.CATEGORYCODE, A.GRADECODE,A.WORKERSERIAL,YEARMONTH, NVL(A.PFAPPLICABLE,''N'') PFAPPLICABLE, NVL(A.EPFAPPLICABLE,''N'') EPFAPPLICABLE, NVL(B.PF_GROSS,0) PF_GROSS,  '||CHR(10) 
                ||'         CASE WHEN  NVL(A.EPFAPPLICABLE,''N'') = ''Y'' AND  NVL(A.EPFAPPLICABLE,''N'') =''Y'' THEN   '||CHR(10)
                ||'                        CASE WHEN NVL(B.PF_E,0) > 0 THEN CASE WHEN B.PF_GROSS > '||lv_MaxPensionGrossAmt||' THEN '||lv_MaxPensionGrossAmt||' ELSE PF_GROSS END ELSE 0 END ELSE 0 END PEN_GROSS,  '||CHR(10)
                ||'         NVL(B.PF_E,0) PF_E,  '||CHR(10)               
                ||'         CASE WHEN  NVL(A.PFAPPLICABLE,''N'') = ''Y'' AND  NVL(A.EPFAPPLICABLE,''N'') = ''Y'' THEN  '||CHR(10) 
                ||'                        CASE WHEN NVL(B.PF_E,0) > 0 THEN ROUND(CASE WHEN NVL(B.PF_GROSS,0) > '||lv_MaxPensionGrossAmt||' THEN '||lv_MaxPensionGrossAmt||' ELSE NVL(PF_GROSS,0) END * '||lv_PensionPercentage||'/100,0) ELSE 0 END ELSE 0 END FPF,  '||CHR(10) 
                ||'                         B.PF_C, NVL(B.ESI_GROSS,0) ESI_GROSS, NVL(B.ESI_E,0) ESI_E, CASE WHEN NVL(ESI_E,0) > 0 THEN CEIL(NVL(ESI_GROSS,0)*'||lv_ESI_C_Percentage||'/100) ELSE 0 END ESI_C   '||CHR(10)
                ||'         FROM PISEMPLOYEEMASTER A, '||P_TABLENAME||' B   '||CHR(10)
                ||'         WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10) 
                ||'           AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE  '||CHR(10) 
                ||'           AND A.WORKERSERIAL = B.WORKERSERIAL   '||CHR(10)
                ||'           AND B.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10);
            if NVL(P_UNIT,'AMALESH_SWT') <> 'AMALESH_SWT' THEN
                lv_SqlStr := lv_SqlStr ||'           AND B.UNITCODE = '''||P_UNIT||''' '||CHR(10);
            end if;                
            if NVL(P_CATEGORY,'AMALESH_SWT') <> 'AMALESH_SWT' THEN
                lv_SqlStr := lv_SqlStr ||'           AND B.CATEGORYCODE = '''||P_CATEGORY||''' '||CHR(10);
            end if;
            if NVL(P_GRADE,'AMALESH_SWT') <> 'AMALESH_SWT' THEN
                lv_SqlStr := lv_SqlStr ||'           AND B.GRADECODE = '''||P_GRADE||''' '||CHR(10);
            end if; 
            if NVL(P_WORKERSERIAL,'AMALESH_SWT') <> 'AMALESH_SWT' THEN
                lv_SqlStr := lv_SqlStr ||'           AND B.WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10);
            end if;       
    lv_SqlStr := lv_SqlStr ||'      )  '||CHR(10);
                
    insert into PIS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,'',lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_SqlStr;
    COMMIT;
    
    lv_SqlStr := 'UPDATE '||P_TABLENAME||' A SET (PEN_GROSS, FPF, PF_C, ESI_C  ) = ( SELECT PEN_GROSS, FPF, PF_C, ESI_C  FROM '||lv_updtable||' B '||CHR(10) 
            ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||' AND A.YEARMONTH = '''||P_YEARMONTH||'''   '||CHR(10)
            ||' AND A.UNITCODE = B.UNITCODE AND A.CATEGORYCODE = B.CATEGORYCODE AND A.GRADECODE = B.GRADECODE '||CHR(10) 
            ||' AND A.WORKERSERIAL = B.WORKERSERIAL )'||CHR(10)
            ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'   AND A.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10);
    lv_remarks := NVL(lv_remarks,'XX ') ||' UPDATE PENSION GROSS, FPF, PF_C, ESI_C';
    INSERT INTO PIS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,'',sysdate,lv_SqlStr,'', lv_fn_stdt, lv_fn_endt, lv_remarks);    
    COMMIT;
    EXECUTE IMMEDIATE lv_SqlStr;
    --COMMIT;
    lv_SqlStr := 'DROP TABLE '||lv_updtable||'';     
    EXECUTE IMMEDIATE lv_SqlStr;
    COMMIT;
    
    
  --ADDED ON 24/12/2020 FOR RETIREMENT EMPLOYEE FOR THIS MONTH
    lv_SqlStr := NULL;
    lv_SqlStr := lv_SqlStr || 'UPDATE '||P_TABLENAME||' A SET (PEN_GROSS,FPF, PF_C) = ('|| CHR(10);
    lv_SqlStr := lv_SqlStr || '    SELECT NEW_PEN_GR, (NEW_PEN_GR* FPF_PERC) FPF, (PF_E-FPF) PF_C'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '    FROM '|| CHR(10);
    lv_SqlStr := lv_SqlStr || '    ('|| CHR(10);
    lv_SqlStr := lv_SqlStr || '        SELECT A.TOKENNO, A.WORKERSERIAL,ROUND((PF_GROSS/MONTHDAYS)*PENDAYS,2) NEW_PEN_GR, B.PEN_GROSS, ROUND(('||lv_PensionPercentage||'/100),2) FPF_PERC FROM '|| CHR(10);
    lv_SqlStr := lv_SqlStr || '        ('|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            SELECT TOKENNO,WORKERSERIAL, DATEOFBIRTH,DATEOFRETIRE,RETIRE_DATE,MONTH_START_DATE, TO_CHAR(MONTH_END_DATE,''MON-YYYY'') MM ,'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            (RETIRE_DATE-MONTH_START_DATE)+1 PENDAYS, (MONTH_END_DATE-MONTH_START_DATE)+1 MONTHDAYS'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            FROM '|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            ('|| CHR(10);
    lv_SqlStr := lv_SqlStr || '                SELECT TOKENNO,WORKERSERIAL,EMPLOYEENAME, DATEOFBIRTH,DATEOFRETIRE, '|| CHR(10);
    lv_SqlStr := lv_SqlStr || '                ADD_MONTHS(DATEOFBIRTH, 58*12) RETIRE_DATE , TO_DATE('''||P_YEARMONTH||''',''YYYYMM'') MONTH_START_DATE,'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '                LAST_DAY(TO_DATE('''||P_YEARMONTH||''',''YYYYMM'')) MONTH_END_DATE'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '                FROM PISEMPLOYEEMASTER'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            ) '|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            WHERE 1=1'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            AND RETIRE_DATE BETWEEN MONTH_START_DATE AND MONTH_END_DATE'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '        ) A,'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '        ('|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            SELECT TOKENNO, WORKERSERIAL, YEARMONTH, PF_GROSS,PEN_GROSS, PF_E '|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            FROM '||P_TABLENAME|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            WHERE YEARMONTH='''||P_YEARMONTH||''''|| CHR(10);
    lv_SqlStr := lv_SqlStr || '        ) B'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '        WHERE A.WORKERSERIAL=B.WORKERSERIAL'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '    )'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '    WHERE A.WORKERSERIAL=WORKERSERIAL'|| CHR(10);
    lv_SqlStr := lv_SqlStr || ')'|| CHR(10);
    lv_SqlStr := lv_SqlStr || 'WHERE YEARMONTH='''||P_YEARMONTH||''''|| CHR(10);
    lv_SqlStr := lv_SqlStr || 'AND NVL(FPF,0) > 0'|| CHR(10);
    
    
    lv_remarks := NVL(lv_remarks,'XX ') ||' UPDATE PENSION GROSS, FPF, PF_C, ESI_C FOR RETIRE EMPLYEE';
    INSERT INTO PIS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,'',sysdate,lv_SqlStr,'', lv_fn_stdt, lv_fn_endt, lv_remarks);    
    COMMIT;
    EXECUTE IMMEDIATE lv_SqlStr;
        COMMIT;
  --ENDED ON 24/12/2020  
    
    
    
end;
/


DROP PROCEDURE PRC_PISSALARY_WRKDAY_LV_UPDT;

CREATE OR REPLACE PROCEDURE             PRC_PISSALARY_WRKDAY_LV_UPDT ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_TRANTYPE Varchar2, 
                                                  P_PHASE  number, 
                                                  P_YEARMONTH Varchar2,
                                                  P_EFFECTYEARMONTH Varchar2, 
                                                  P_TABLENAME Varchar2,
                                                  P_PHASE_TABLENAME Varchar2,
                                                  P_UNIT  Varchar2,
                                                  P_CATEGORY    Varchar2  DEFAULT NULL,
                                                  P_GRADE       Varchar2  DEFAULT NULL,
                                                  P_DEPARTMENT  Varchar2  DEFAULT NULL,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
as 
lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,1,4),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,1,4),'DD/MM/YYYY'));
P_fn_stdt    varchar2(10) := '01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,1,4);
P_fn_endt    varchar2(10) := to_char(LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,1,4),'DD/MM/YYYY')),'DD/MM/YYYY');
lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(8000);
lv_parvalues        varchar2(500); 
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName         varchar2(30)   := 'PRC_PISSALARY_WRKDAY_LV_UPDT';
lv_Sql_TblCreate    varchar2(4000) := '';
lv_Component        varchar2(4000) := ''; 
lv_SqlComponent     varchar2(2000) := ''; 
lv_cnt                  number(10):=0;
lv_MaxPensionGrossAmt   number(11,2) := 0;
lv_MaxPensionAmt        number(11,2) := 0;
lv_PensionPercentage    number(11,2) := 0;
lv_ESI_C_Percentage     number(11,2) := 0;
lv_updtable             varchar2(30)    := '';
lv_LeaveSUM             varchar2(20000):='';
lv_LeaveComp            varchar2(20000):='';
lv_leaveQuery           varchar2(20000):='';
lv_YearCode             varchar2(20):='';
Begin
    -------------- LEAVE DAY AND LEAVE BALANCE UPDATE ---------------------
    --select SUBSTR( ( 'PIS_OTH_COMP'||SYS_CONTEXT('USERENV', 'SESSIONID')) ,1,30) into lv_updtable  from dual ;
    lv_updtable := 'GTT_LV_UPDT_AMD';
    lv_parvalues := 'COMPANY '||P_COMPCODE||',DIV-'||P_DIVCODE||',TRANTYPE-'||P_TRANTYPE||', YEARMONTH-'||P_YEARMONTH||',TABLE-'||P_TABLENAME||',UNIT-'||P_UNIT||',CATEGORY'||P_CATEGORY||',GRADE-'||P_GRADE;   
    BEGIN
        lv_SqlStr := 'DELETE FROM GTT_PIS_OFF_LV_UPDT_AMD';
        EXECUTE IMMEDIATE lv_SqlStr; 
    EXCEPTION
        WHEN OTHERS THEN NULL;    
    END;
    
    lv_SqlStr := ' INSERT INTO GTT_PIS_OFF_LV_UPDT_AMD (YEARMONTH, WORKERSERIAL, PRIORITY, ATTENDANCETYPE, NOFODAYS) '||CHR(10)
        ||' SELECT '''||P_YEARMONTH||''' AS YEARMONTH,A.WORKERSERIAL, A.PRIORITY, B.ATTENDANCETYPE, /*COUNT(DT)*/ SUM(NOOFDAYS) NOFODAYS '||CHR(10)
        ||' FROM '||CHR(10)
        ||' ( '||CHR(10)
        ||'     SELECT WORKERSERIAL,DT,MAX(PRIORITY) PRIORITY, SUM(NOOFDAYS) NOOFDAYS '||CHR(10) 
        ||'     FROM  '||CHR(10) 
        ||'     ( '||CHR(10)
        --Change 02032020
        ||'        SELECT  WORKERSERIAL, DT, DAYS, DATATYPE, PRIORITY, NOOFDAYS FROM '||CHR(10)
        ||'            (   '||CHR(10)             
         --End Change 02032020                    
        ||'         SELECT A.WORKERSERIAL,   TO_DATE(DT,''DD/MM/YYYY'') DT, NVL(C.WEEKLYOFFDAY,B.WEEKLYOFFDAY) DAYS, P.ATTENDANCETYPE DATATYPE, P.PRIORITY, 1 NOOFDAYS '||CHR(10)
        ||'         FROM PISMONTHATTENDANCE A, PISEMPLOYEEMASTER B, PISCATEGORYMASTER C, PISATTENDANCEPRIORITY P,  '||CHR(10)
        ||'         (  '||CHR(10)
        ||'             SELECT TO_CHAR(DT + LEVEL,''DD/MM/YYYY'') DT, LTRIM(RTRIM(TO_CHAR(DT + LEVEL,''DAY'')))  DAYS, ''GENERAL'',''0''  '||CHR(10)   
        ||'             FROM (    '||CHR(10)
        ||'                     SELECT TO_DATE('''||P_fn_stdt||''',''DD/MM/YYYY'') -1  AS DT  '||CHR(10)  
        ||'                     FROM DUAL    '||CHR(10)
        ||'                  )   '||CHR(10)
        ||'             CONNECT BY LEVEL <= TO_DATE('''||P_fn_endt||''',''DD/MM/YYYY'') - TO_DATE('''||P_fn_stdt||''',''DD/MM/YYYY'') + 1  '||CHR(10)  
        ||'         ) D  '||CHR(10)
        ||'         WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
        ||'           AND A.YEARMONTH = '''||P_YEARMONTH||'''  '||CHR(10)
        ||'           AND P.COMPANYCODE = '''||P_COMPCODE||''' AND P.DIVISIONCODE = '''||P_DIVCODE||''' AND P.ATTENDANCETYPE = ''OFFDAY''  '||CHR(10)
        ||'           AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE AND A.WORKERSERIAL = B.WORKERSERIAL  '||CHR(10)
        ||'           AND A.COMPANYCODE = C.COMPANYCODE AND A.DIVISIONCODE = C.DIVISIONCODE AND A.CATEGORYCODE = C.CATEGORYCODE   '||CHR(10)
        ||'           AND NVL(C.WEEKLYOFFDAY,B.WEEKLYOFFDAY) = D.DAYS  '||CHR(10)
                --Change 02032020
        ||'           )L WHERE DT NOT IN      '||CHR(10)
        ||'               (                '||CHR(10)    
        ||'               SELECT LEAVEDATE    '||CHR(10)
        ||'                 FROM PISLEAVEAPPLICATION A, PISLEAVEMASTER B, PISATTENDANCEPRIORITY P   '||CHR(10)
        ||'               WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
        ||'                 AND A.LEAVESANCTIONEDON IS NOT NULL     '||CHR(10)
        ||'                 AND NVL(A.LEAVEENCASHED,''N'') <> ''Y''    '||CHR(10)
        ||'                 AND A.LEAVEDATE >= '''||lv_fn_stdt||'''  '||CHR(10)
        ||'                 AND A.LEAVEDATE <= '''||lv_fn_endt||'''  '||CHR(10)
        ||'                 AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE AND A.LEAVECODE = B.LEAVECODE  '||CHR(10)
        ||'                 AND NVL(B.WITHOUTPAYLEAVE,''N'') <> ''Y''  '||CHR(10)
        ||'                 AND P.COMPANYCODE = '''||P_COMPCODE||''' AND P.DIVISIONCODE = '''||P_DIVCODE||''' AND P.ATTENDANCETYPE = ''LEAVEDAY''  '||CHR(10)
        ||'                     AND A.WORKERSERIAL=L.WORKERSERIAL  )    '||CHR(10)
                --End Change 02032020                      
        ||'         UNION ALL  '||CHR(10)
        ||'         SELECT A.WORKERSERIAL,   HOLIDAYDATE DT, TO_CHAR(HOLIDAYDATE,''DAY'') DAYS, P.ATTENDANCETYPE DATATYPE, P.PRIORITY, 1 NOOFDAYS '||CHR(10)
        ||'         FROM PISMONTHATTENDANCE A, HOLIDAYMASTER B, PISATTENDANCEPRIORITY P  '||CHR(10)
        ||'         WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
        ||'           AND A.YEARMONTH = '''||P_YEARMONTH||'''  '||CHR(10)
        ||'           AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE  '||CHR(10) 
        ||'           AND B.HOLIDAYDATE >= '''||lv_fn_stdt||'''  '||CHR(10)
        ||'           AND B.HOLIDAYDATE <= '''||lv_fn_endt||'''  '||CHR(10)
        ||'           AND P.COMPANYCODE = '''||P_COMPCODE||''' AND P.DIVISIONCODE = '''||P_DIVCODE||''' AND P.ATTENDANCETYPE = ''HOLIDAY''  '||CHR(10)
        ||'         UNION ALL    '||CHR(10)
        ||'         SELECT A.WORKERSERIAL,   LEAVEDATE DT, TO_CHAR(LEAVEDATE,''DAY'') DAYS, P.ATTENDANCETYPE DATATYPE, P.PRIORITY,LEAVEDAYS NOOFDAYS    '||CHR(10)
        ||'         FROM PISLEAVEAPPLICATION A, PISLEAVEMASTER B, PISATTENDANCEPRIORITY P   '||CHR(10)
        ||'         WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
        ||'           AND A.LEAVESANCTIONEDON IS NOT NULL  '||CHR(10)
        ||'           AND NVL(A.LEAVEENCASHED,''N'') <> ''Y''    '||CHR(10)
        ||'           AND A.LEAVEDATE >= '''||lv_fn_stdt||'''  '||CHR(10)
        ||'           AND A.LEAVEDATE <= '''||lv_fn_endt||'''  '||CHR(10)
        ||'           AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE AND A.LEAVECODE = B.LEAVECODE  '||CHR(10)
        ||'           AND NVL(B.WITHOUTPAYLEAVE,''N'') <> ''Y''  '||CHR(10)
        ||'           AND P.COMPANYCODE = '''||P_COMPCODE||''' AND P.DIVISIONCODE = '''||P_DIVCODE||''' AND P.ATTENDANCETYPE = ''LEAVEDAY''  '||CHR(10)
        ||'     ) A  '||CHR(10)
        ||'     GROUP BY WORKERSERIAL,DT  '||CHR(10)
        ||' ) A, PISATTENDANCEPRIORITY B, '||P_TABLENAME||' C  '||CHR(10)
        ||' WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10) 
        ||'   AND A.PRIORITY = B.PRIORITY  '||CHR(10)
        ||'   AND C.COMPANYCODE = '''||P_COMPCODE||''' AND C.DIVISIONCODE = '''||P_DIVCODE||''' AND C.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
        ||'   AND A.WORKERSERIAL = C.WORKERSERIAL '||CHR(10)
        ||' GROUP BY A.WORKERSERIAL, A.PRIORITY, B.ATTENDANCETYPE  '||CHR(10)
        ||' ORDER BY WORKERSERIAL, PRIORITY DESC      '||CHR(10);
    
  --dbms_output.put_line(lv_SqlStr);
   
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_SqlStr;
    COMMIT;
    --RETURN;
    
    FOR c1 in ( SELECT * FROM GTT_PIS_OFF_LV_UPDT_AMD)
    loop
        
        if c1.ATTENDANCETYPE = 'OFFDAY' THEN
            lv_SqlStr := ' UPDATE '||P_TABLENAME||' SET ATTN_OFFD = '||c1.NOFODAYS||' '||CHR(10)
                        ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                        ||'   AND YEARMONTH = '''||c1.YEARMONTH||''' AND WORKERSERIAL = '''||c1.WORKERSERIAL||''' '||chr(10);
        elsif c1.ATTENDANCETYPE = 'HOLIDAY' THEN
            lv_SqlStr := ' UPDATE '||P_TABLENAME||' SET ATTN_HOLD = '||c1.NOFODAYS||' '||CHR(10)
                        ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                        ||'   AND YEARMONTH = '''||c1.YEARMONTH||''' AND WORKERSERIAL = '''||c1.WORKERSERIAL||''' '||chr(10);
        elsif c1.ATTENDANCETYPE = 'LEAVEDAY' THEN
            lv_SqlStr := ' UPDATE '||P_TABLENAME||' SET ATTN_LDAY = '||c1.NOFODAYS||' '||CHR(10)
                        ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                        ||'   AND YEARMONTH = '''||c1.YEARMONTH||''' AND WORKERSERIAL = '''||c1.WORKERSERIAL||''' '||chr(10);
        end if;
        if length(lv_SqlStr) > 10 then
            lv_remarks := 'UPDATE '||c1.ATTENDANCETYPE||' FOR WOKRERSERIAL - '||c1.WORKERSERIAL||' FOR THE YEARMONTH '||c1.YEARMONTH ; 
            INSERT INTO PIS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE,PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
            VALUES (P_COMPCODE, P_DIVCODE, lv_ProcName,'',sysdate,lv_SqlStr,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
            COMMIT;
            execute immediate lv_SqlStr;
            COMMIT;
        end if;
        lv_SqlStr := '';
        
    end loop;
    --lv_SqlStr := ' UPDATE '||P_TABLENAME||' SET ATTN_WRKD = ATTN_SALD - ATTN_HOLD - ATTN_OFFD - ATTN_LDAY '||CHR(10)
    lv_SqlStr := ' UPDATE '||P_TABLENAME||' SET ATTN_WRKD = ATTN_SALD - ATTN_HOLD - ATTN_LDAY '||CHR(10)
                ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10);
    if NVL(P_UNIT,'XX') <> 'XX' then
        lv_SqlStr := lv_SqlStr ||' AND UNITCODE = '''||P_UNIT||''' '||CHR(10);                        
    end if;                     
    if NVL(P_CATEGORY,'XX') <> 'XX' then
        lv_SqlStr := lv_SqlStr ||' AND CATEGORYCODE = '''||P_CATEGORY||''' '||CHR(10);                        
    end if;
    if NVL(P_GRADE,'XX') <> 'XX' then
        lv_SqlStr := lv_SqlStr ||' AND GRADECODE = '''||P_GRADE||''' '||CHR(10);                        
    end if;    
    if NVL(P_WORKERSERIAL,'XX') <> 'XX' then
        lv_SqlStr := lv_SqlStr ||' AND WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10);                        
    end if;    
    lv_remarks := 'UPDATE WORKING DAYS';
    INSERT INTO PIS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    VALUES (P_COMPCODE, P_DIVCODE,lv_ProcName,'',sysdate,lv_SqlStr,'', lv_fn_stdt, lv_fn_endt, lv_remarks);    
    COMMIT;

    execute immediate lv_SqlStr;
    commit;

     SELECT YEARCODE INTO lv_YearCode FROM FINANCIALYEAR
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
      AND STARTDATE <= lv_fn_stdt and ENDDATE >= lv_fn_stdt;

     FOR C1 IN (SELECT LEAVECODE from PISLEAVEMASTER WHERE COMPANYCODE=P_COMPCODE AND DIVISIONCODE=P_DIVCODE ORDER BY LEAVECODE)
    LOOP
         lv_SqlStr :=' UPDATE '||P_TABLENAME||' A SET A.LDAY_'||C1.LEAVECODE||'=0 '||CHR(10)
                    ||' WHERE COMPANYCODE='''||P_COMPCODE||'''  '||CHR(10)
                    ||' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
                    ||' AND YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10) ;
                    
         lv_remarks := 'UPDATE LEAVE DAYS 0';
         INSERT INTO PIS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
         VALUES (P_COMPCODE, P_DIVCODE,lv_ProcName,'',sysdate,lv_SqlStr,'', lv_fn_stdt, lv_fn_endt, lv_remarks);    
         
         EXECUTE IMMEDIATE lv_SqlStr;   
                    
    
        lv_SqlStr :='UPDATE '||P_TABLENAME||' A SET A.LDAY_'||C1.LEAVECODE||'='||CHR(10)
                    ||'('||CHR(10)
                    ||'    SELECT B.LEAVEDAYS'||CHR(10)
                    ||'    FROM ('||CHR(10)
                    ||'            SELECT WORKERSERIAL, SUM(LEAVEDAYS) LEAVEDAYS'||CHR(10)
                    ||'            FROM PISLEAVEAPPLICATION'||CHR(10)
                    ||'            WHERE COMPANYCODE='''||P_COMPCODE||''''||CHR(10)
                    ||'                 AND DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
                    ||'                 AND LEAVECODE ='''||C1.LEAVECODE||''''||CHR(10)
                    ||'                 AND LEAVEDATE >= TO_DATE('''||TO_CHAR(lv_fn_stdt,'DD/MM/YYYY')||''',''DD/MM/YYYY'')'||CHR(10)
                    ||'                 AND LEAVEDATE <= TO_DATE('''||TO_CHAR(lv_fn_endt,'DD/MM/YYYY')||''',''DD/MM/YYYY'')'||CHR(10)
                    ||'                 AND LEAVESANCTIONEDON IS NOT NULL'||CHR(10)
                    ||'                 AND NVL(LEAVEENCASHED,''N'') <> ''Y''    '||CHR(10)
                    ||'            GROUP BY WORKERSERIAL'||CHR(10)
                    ||'         ) B'||CHR(10)
                    ||'         WHERE A.WORKERSERIAL = B.WORKERSERIAL'||CHR(10)
                    ||')'||CHR(10)
                    ||'WHERE A.COMPANYCODE='''||P_COMPCODE||''''||CHR(10)
                    ||'     AND A.DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
                    ||'     AND A.YEARCODE ='''||lv_YearCode||''''||CHR(10)
                    ||'     AND A.YEARMONTH = '''||P_YEARMONTH||''''||CHR(10)
                    ||'     AND A.WORKERSERIAL IN ( SELECT WORKERSERIAL FROM PISLEAVEAPPLICATION'||CHR(10)
                    ||'                             WHERE COMPANYCODE='''||P_COMPCODE||''''||CHR(10)
                    ||'                                 AND DIVISIONCODE = '''||P_DIVCODE||''''||CHR(10)
                    ||'                                 AND LEAVECODE ='''||C1.LEAVECODE||''''||CHR(10)
                    ||'                                 AND LEAVEDATE >= TO_DATE('''||TO_CHAR(lv_fn_stdt,'DD/MM/YYYY')||''',''DD/MM/YYYY'')'||CHR(10)
                    ||'                                 AND LEAVEDATE <= TO_DATE('''||TO_CHAR(lv_fn_endt,'DD/MM/YYYY')||''',''DD/MM/YYYY'')'||CHR(10)
                    ||'                                 AND LEAVESANCTIONEDON IS NOT NULL'||CHR(10)
                    ||'                                 AND NVL(LEAVEENCASHED,''N'') <> ''Y''    '||CHR(10)
                    ||'                             GROUP BY WORKERSERIAL'||CHR(10)
                    ||'                            )'||CHR(10);
        
        
         lv_remarks := 'UPDATE LEAVE DAYS';
         INSERT INTO PIS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
         VALUES (P_COMPCODE, P_DIVCODE,lv_ProcName,'',sysdate,lv_SqlStr,'', lv_fn_stdt, lv_fn_endt, lv_remarks);    
         
         EXECUTE IMMEDIATE lv_SqlStr;
          
     END LOOP;
     
    
--    lv_SqlStr := 'DROP TABLE '||lv_updtable||'';     
--    EXECUTE IMMEDIATE lv_SqlStr;
    COMMIT;
EXCEPTION
    when others then
     lv_remarks := 'PIS - ERROR' ;
     lv_sqlerrm := sqlerrm ;
     insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE, ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE,REMARKS ) 
     values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,SYSDATE, lv_SqlStr,lv_parvalues,lv_fn_stdt, lv_fn_endt, lv_remarks);    
            
end;
/


DROP PROCEDURE PRC_PISUPDATE_NA_COMP;

CREATE OR REPLACE PROCEDURE PRC_PISUPDATE_NA_COMP( p_compcode varchar2, p_divcode varchar2,p_yearmonth varchar2, p_process_table varchar2, p_phase_table varchar2, p_UpdateDummytable varchar2 DEFAULT NULL, P_APPLICABLE varchar2 default 'Y' )
as
lv_updsql varchar2(32767);
lv_tab varchar2(30) := ltrim(trim(upper(p_phase_table)));
-- declare  -- for view creration from outside 
lv_colstr varchar2(32767);
lv_sqlstr varchar2(32767) :=  'CREATE OR REPLACE FORCE VIEW vw_PIS_category_comp_NA as ( '||chr(10) ;
lv_sqlerrm varchar(2000);
lv_remarks varchar(2000);
lv_parvalues varchar2(4000);
lv_c2cnt int ;
lv_cnt2 int := 0;
begin
--------------------- view creation -------------

    lv_sqlstr := lv_sqlstr||' SELECT NVL(UNITCODE,''01'') UNITCODE, GRADECODE,CATEGORYCODE,COMPONENTCODE '||CHR(10)
                          ||' FROM PISGRADECOMPONENTMAPPING '||CHR(10)
                          ||'   WHERE  COMPANYCODE = '''||p_compcode||''' and DIVISIONCODE = '''||p_divcode||''' '||CHR(10)
                          ||'     AND APPLICABLE = ''NO'' '||CHR(10)
                          ||'     AND YEARMONTH = ( SELECT MAX(YEARMONTH) FROM PISGRADECOMPONENTMAPPING '||chr(10)
                          ||'                       WHERE COMPANYCODE = '''||p_compcode||''' and DIVISIONCODE = '''||p_divcode||''' '||CHR(10)
                          ||'                         AND YEARMONTH <= '''||p_yearmonth||''' '||CHR(10)
                          ||'                     )  '
                          ||' )'||CHR(10);
--    execute immediate lv_sqlstr;
--------------------------------AMALESH
--select count(*) into lv_c2cnt from (
--SELECT column_name FROM COLS  WHERE TABLE_NAME = p_phase_table
--AND COLUMN_NAME NOT IN( 'YEARMONTH','WORKERSERIAL','UNITCODE','TOKENNO','GRADECODE','CATEGORYCODE','ATTN_SALD','ATTN_CALCF') );
--for c2 in (
--SELECT COLUMN_NAME cn FROM COLS  WHERE TABLE_NAME = p_phase_table
--AND COLUMN_NAME NOT IN( 'YEARMONTH','WORKERSERIAL','UNITCODE','TOKENNO','GRADECODE','CATEGORYCODE','ATTN_SALD','ATTN_CALCF')) loop
--lv_cnt2 := lv_cnt2 +1;
-- if  lv_cnt2 = lv_c2cnt then
--   lv_sqlstr := lv_sqlstr||' SELECT UNITCODE, GRADECODE , CATEGORYCODE,'''||c2.cn||''' COMPONENTCODE FROM '||p_phase_table||' WHERE '||c2.cn||' > 0 ';
-- else
--   lv_sqlstr := lv_sqlstr||' SELECT UNITCODE, GRADECODE , CATEGORYCODE, '''||c2.cn||''' COMPONENTCODE FROM '||p_phase_table||' WHERE '||c2.cn||' > 0  UNION  '||CHR(10) ;
-- end if;   
--end loop ;
--lv_sqlstr := lv_sqlstr||chr(10)||' ) MINUS ';
--dbms_output.put_line( lv_sqlstr );
--lv_sqlstr := lv_sqlstr||chr(10)||' SELECT NVL(UNITCODE,''01'') UNITCODE, GRADECODE,CATEGORYCODE,COMPONENTCODE '||CHR(10)
--                               ||' FROM PISGRADECOMPONENTMAPPING '||CHR(10)
--                               ||'   WHERE  COMPANYCODE = '''||p_compcode||''' and DIVISIONCODE = '''||p_divcode||''' '||CHR(10)
--                               ||'     AND APPLICABLE = ''NO'' '||CHR(10)
--                               ||'     AND YEARMONTH = ( SELECT MAX(YEARMONTH) FROM PISGRADECOMPONENTMAPPING '||chr(10)
--                               ||'                       WHERE COMPANYCODE = '''||p_compcode||''' and DIVISIONCODE = '''||p_divcode||''' '||CHR(10)
--                               ||'                         AND YEARMONTH <= '''||p_yearmonth||''' '||CHR(10)
--                               ||'                     )  ';
dbms_output.put_line(lv_sqlstr);
execute immediate lv_sqlstr;
--return ;
-- end for view creration from outside
----------------------------------------- end view creation -----------
for c1 in( select distinct unitcode, gradecode, categorycode  from vw_PIS_category_comp_NA   ) loop
lv_updsql := 'UPDATE '||lv_tab||' SET ' ;
for c2 in(select column_name cn from cols where table_name = lv_tab
intersect
select COMPONENTCODE cn from vw_PIS_category_comp_NA where  unitcode = c1.unitcode and gradecode = c1.gradecode and CATEGORYCODE = c1.CATEGORYCODE
) loop
lv_updsql := lv_updsql||c2.cn||' = 0 , ' ;
end loop ; -- c2
lv_updsql := lv_updsql||' CATEGORYCODE=CATEGORYCODE where unitcode = '''||c1.unitcode||''' and gradecode = '''||c1.gradecode||''' and CATEGORYCODE = '''||c1.CATEGORYCODE||'''  ';
-- dbms_output.put_line(lv_updsql);
--insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'proc_wps_update_NA_comp',lv_updsql,lv_updsql,'','');
--COMMIT;
execute immediate lv_updsql ;
end loop ; -- c1
--RETURN;
---------------------  update dummy
if p_UpdateDummytable = 'Y' THEN 
    for u1 in(
    select column_name cn from cols where table_name = p_phase_table and column_name not in( 'YEARMONTH','WORKERSERIAL','UNITCODE','TOKENNO','GRADECODE','CATEGORYCODE')
    intersect 
    select column_name cn from cols where table_name = p_process_table and column_name not in( 'YEARMONTH','WORKERSERIAL','UNITCODE','TOKENNO','GRADECODE','CATEGORYCODE' )
    )
    loop
    lv_colstr := lv_colstr||u1.cn||',' ;
    end loop;
    lv_colstr := lv_colstr||' CATEGORYCODE' ;
    lv_updsql := 'update '||p_process_table||' a set ('||lv_colstr||' ) = ( select '||lv_colstr||' from '||p_phase_table||' b '||chr(10) 
                  ||' where a.TOKENNO = b.TOKENNO '||CHR(10)
                  ||' AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
                  ||' AND A.YEARMONTH = B.YEARMONTH '||CHR(10)
                  ||' AND A.UNITCODE = B.UNITCODE '||CHR(10)
                  ||' AND A.GRADECODE = B.GRADECODE '||CHR(10)
                  ||' AND A.CATEGORYCODE = B.CATEGORYCODE )';
 --   insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE,FORTNIGHTENDDATE,REMARKS ) values( 'proc_wps_update_NA_comp','',lv_updsql,'',lv_fn_stdt, lv_fn_endt, p_phase_table);
 --  dbms_output.put_line(lv_updsql);
   execute immediate lv_updsql ;
  -- COMMIT;
end if;     
--------------------- end update dummy 
/*exception
when others then
 lv_remarks := 'PIS - ERROR' ;
 lv_sqlerrm := sqlerrm ;
 insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'proc_PIS_update_NA_comp',lv_updsql,lv_sqlstr,lv_parvalues,lv_remarks);
 --dbms_output.put_line(lv_sqlerrm);
 --insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'proc_wps_update_NA_comp',lv_sqlerrm,lv_updsql,'',lv_fn_stdt,lv_fn_endt, p_phase_table);
 */
end;
/


DROP PROCEDURE PRC_PISVIEWCREATION;

CREATE OR REPLACE PROCEDURE             PRC_PISVIEWCREATION ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_ViewName Varchar2,
                                                  P_Phase Number,
                                                  P_YEARMONTH Varchar2,
                                                  P_EFFECTYEARMONTH Varchar2,
                                                  P_TRANTYPE VARCHAR2 DEFAULT 'SALARY', 
                                                  P_SALRAYTABLENAME VARCHAR2 DEFAULT 'PISPAYTRANSACTION_SWT')
as 
lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY'));
lv_TableName        varchar2(50)   := '' ;
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_CompMast_Rec PISCOMPONENTMASTER%ROWTYPE;
lv_AttnComponent    varchar2(32000) := '';
lv_AssignComponent  varchar2(32000) := ''; 
lv_PayComponent     varchar2(32000) := '';
lv_parvalues        varchar2(500)  := '' ;
lv_sqlerrm          varchar2(500)  := '';
lv_ProcName         varchar2(30)   := 'PRC_PISVIEWCREATION';
lv_AttnTranType     varchar2(30);     
lv_PhaseTableName   varchar2(25);
lv_ProcessType      varchar2(50) := 'SALARY';
lv_Lday_Cols        varchar2(100) := '';

--lv_AttnComponent    varchar2(32000) := '';
--lv_AssignComponent  varchar2(32000) := '';
lv_AssignCompWithArrear varchar2(10000) := '';
lv_AssignCompWithOutArrear varchar2(10000) := '';
lv_AssignCompSum           varchar2(10000) := '';
--lv_AssignComponent  varchar2(32000):=''; 
begin
    
    --lv_TableName := 'PISPAYTRANSACTION_SWT';    
    lv_TableName := P_SALRAYTABLENAME;
    if P_SALRAYTABLENAME is null then
        lv_TableName := 'PISPAYTRANSACTION_SWT';
    end if;
    
    lv_AttnTranType := P_TRANTYPE;
    --DBMS_OUTPUT.PUT_LINE ('TRAN TYPE '||P_TRANTYPE);
--    IF P_TRANTYPE = 'ARREAR' OR  P_TRANTYPE = 'SALARY' THEN
--        lv_AttnTranType := 'ATTENDANCE';
--    END IF;
    if NVL(P_TRANTYPE,'N') <> 'FINAL SETTLEMENT' THEN
        lv_AttnTranType := 'ATTENDANCE';        
    end if;
    
    -- the below variable use in component view, 
    -- because at the time of arrear process we store the data in'NEW SALRY' TRANSACTIONTYPE (FORCE FULLY)
    -- DUE TO CLRIFY THE SALARY WITH NEW RATE IN ARREAR TRANSACTION TYPE  
    --DBMS_OUTPUT.PUT_LINE ('0_0');
    IF P_TRANTYPE = 'ARREAR' THEN
        lv_ProcessType := 'NEW SALARY';
    ELSE
        lv_ProcessType := P_TRANTYPE;
    END IF;    
    
--    if NVL(P_TRANTYPE,'N') <> 'FINAL SETTLEMENT' THEN
--        lv_AttnTranType := 'ATTENDANCE';        
--    end if;
    
    --DBMS_OUTPUT.PUT_LINE('STARTDATE: '||lv_fn_stdt||', ENDDATE  '||lv_fn_endt);
    lv_parvalues := 'VIEWNAME = '||P_ViewName||', YEARMONTH = '||P_YEARMONTH;
    FOR C1 IN (
                SELECT COMPONENTCODE, NVL(ROLLOVERAPPLICABLE,'N') ROLLOVERAPPLICABLE, NVL(ATTENDANCEENTRYAPPLICABLE,'N') ATTENDANCEENTRYAPPLICABLE,
                    NVL(INCLUDEARREAR,'N') INCLUDEARREAR
                FROM PISCOMPONENTMASTER
                WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                  AND INCLUDEPAYROLL = 'Y'
                  --AND ROLLOVERAPPLICABLE = 'Y'
                  AND YEARMONTH = ( 
                                    SELECT MAX(YEARMONTH) YEARMONTH FROM PISCOMPONENTMASTER
                                    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                                      AND YEARMONTH <= P_YEARMONTH
                                      --AND INCLUDEPAYROLL = 'Y'
                                  )        
                ) 
    loop
        if C1.ROLLOVERAPPLICABLE = 'Y' THEN
            if lv_AssignComponent = '' then
                lv_AssignComponent := ', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;
            else
                lv_AssignComponent := lv_AssignComponent ||', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;
            end if;
            --- BELOW PART IS REQUIRED AT THE TIME ARREAR CALCULATION ---
            --- WHEN USER NOT CLAULATE THE ARREAR ON SOME MASTER COMPONENT THEN THOSE COMPONENT RATE SHOULD BE TAKEN FROM OLD SALARY MONTH (NOT EFFECTED YEARMONTH) 
            IF C1.INCLUDEARREAR = 'Y' THEN
                if lv_AssignCompSum = '' then
                    lv_AssignCompSum := ', SUM('||C1.COMPONENTCODE||') AS '||C1.COMPONENTCODE;
                else
                    lv_AssignCompSum := lv_AssignCompSum||', SUM('||C1.COMPONENTCODE||') AS '||C1.COMPONENTCODE;
                end if;
                IF lv_AssignCompWithArrear = '' THEN
                    lv_AssignCompWithArrear := ', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;            
                ELSE
                    lv_AssignCompWithArrear := lv_AssignCompWithArrear ||', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;
                END IF;
                
                IF lv_AssignCompWithOutArrear = '' THEN
                    lv_AssignCompWithOutArrear := ', 0 AS '||C1.COMPONENTCODE;
                ELSE
                    lv_AssignCompWithOutArrear := lv_AssignCompWithOutArrear ||', 0 AS '||C1.COMPONENTCODE;
                END IF;
            ELSE
                if lv_AssignCompSum = '' then
                    lv_AssignCompSum := ', SUM('||C1.COMPONENTCODE||') AS '||C1.COMPONENTCODE;
                else
                    lv_AssignCompSum := lv_AssignCompSum||', SUM('||C1.COMPONENTCODE||') AS '||C1.COMPONENTCODE;
                end if;
                
                IF lv_AssignCompWithArrear = '' THEN
                    lv_AssignCompWithArrear := ', 0 AS '||C1.COMPONENTCODE;
                ELSE
                    lv_AssignCompWithArrear := lv_AssignCompWithArrear ||', 0 AS '||C1.COMPONENTCODE;
                END IF;            
                
                IF lv_AssignCompWithOutArrear = '' THEN
                    lv_AssignCompWithOutArrear := ', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;            
                ELSE
                    lv_AssignCompWithOutArrear := lv_AssignCompWithOutArrear ||', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;
                END IF;            
            END IF;            
        elsif c1.ATTENDANCEENTRYAPPLICABLE = 'Y' THEN
            if lv_AttnComponent = '' then
                lv_AttnComponent := ', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;
            else
                lv_AttnComponent := lv_AttnComponent ||', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;
            end if;            
        end if;    
        IF SUBSTR(C1.COMPONENTCODE,1,5) <> 'ATTN_' AND SUBSTR(C1.COMPONENTCODE,1,5) <> 'LDAY_' THEN
            if lv_PayComponent = '' then
                lv_PayComponent := ', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;
            else
                lv_PayComponent := lv_PayComponent ||', NVL(A.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTCODE;
            end if;    
        END IF;
    END LOOP;
   --DBMS_OUTPUT.PUT_LINE ('0_1');
    if P_ViewName = 'PISMAST' OR NVL(P_ViewName,'ALL') = 'ALL' then
        lv_Remarks := 'VIEW - PISMAST';
        lv_SqlStr := ' CREATE OR REPLACE VIEW PISMAST '||CHR(10)
           ||' AS '||CHR(10)
           ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.UNITCODE, A.TOKENNO, A.CATEGORYCODE, A.GRADECODE, NVL(A.PFAPPLICABLE,''N'') PFAPPLICABLE, NVL(A.EPFAPPLICABLE,''N'') EPFAPPLICABLE, '||CHR(10)
           ||' NVL(A.PTAXAPPLICABLE,''N'') PTAXAPPLICABLE,  NVL(A.QUARTERALLOTED,''N'') QUARTERALLOTED, A.EMPLOYEESTATUS, A.DEPARTMENTCODE, A.DESIGNATIONCODE, '||CHR(10)
           ||' A.PFNO, A.PENSIONNO, A.ESINO, A.BANKACCNUMBER, NVL(A.PAYMODE,''CASH'') PAYMODE, '||CHR(10)
           ||' A.DATEOFBIRTH, A.DATEOFJOIN, A.PFENTITLEDATE, A.STATUSDATE, A.EXTENDEDRETIREDATE, NVL(A.PTAXSTATE,''WEST BENGAL'') PTAXSTATE '||CHR(10)
           ||' FROM PISEMPLOYEEMASTER A, PISMONTHATTENDANCE B '||CHR(10)
           ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
           ||'   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
           ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
           ||'   AND B.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
           ||'   AND B.TRANSACTIONTYPE = '''||lv_AttnTranType||''' '||CHR(10)
           ||' ORDER BY B.TOKENNO '||CHR(10);
       
       insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
       values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
       EXECUTE IMMEDIATE lv_SqlStr;
       
       COMMIT;
    end if;
--    DBMS_OUTPUT.PUT_LINE ('1_0');
--    DBMS_OUTPUT.PUT_LINE('PISMAST: '||lv_SqlStr);
    if P_ViewName = 'PISATTN' OR NVL(P_ViewName,'ALL') = 'ALL' then
        lv_Remarks := 'VIEW - PISATTN';
        lv_SqlStr := ' CREATE OR REPLACE VIEW PISATTN '||CHR(10)
           ||' AS '||CHR(10)
           ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, B.UNITCODE, B.YEARMONTH, B.CATEGORYCODE, B.GRADECODE, B.WORKERSERIAL, B.TOKENNO, '||CHR(10) 
           ||' NVL(B.PRESENTDAYS,0) PRESENTDAYS, NVL(B.WITHOUTPAYDAYS,0) WITHOUTPAYDAYS, NVL(B.HOLIDAYS,0) HOLIDAYS, NVL(B.SALARYDAYS,0) SALARYDAYS, '||CHR(10) 
           ||' NVL(B.LV_ENCASH_DAYS,0) LV_ENCASH_DAYS, NVL(B.LVDAYS_RET,0) LVDAYS_RET, NVL(B.TOTALDAYS,0) TOTALDAYS, NVL(B.CALCULATIONFACTORDAYS,0) CALCULATIONFACTORDAYS '||CHR(10)
           ||' '||lv_AttnComponent||' '||CHR(10)
           ||' FROM PISMONTHATTENDANCE B, '||CHR(10) 
           ||' ( '||CHR(10)
           ||'     SELECT * FROM PISCOMPONENTASSIGNMENT '||CHR(10) 
           ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
           ||'       AND YEARMONTH = '''||P_YEARMONTH||'''  '||CHR(10)
           ||'       AND TRANSACTIONTYPE = '''||lv_AttnTranType||''' '||CHR(10)
           ||' )  A '||CHR(10)
           ||' WHERE B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
           ||'   AND B.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
           ||'   AND B.TRANSACTIONTYPE = '''||lv_AttnTranType||''' '||CHR(10)
           ||'   AND B.COMPANYCODE = A.COMPANYCODE (+) AND B.DIVISIONCODE = A.DIVISIONCODE (+) '||CHR(10)
           ||'   AND B.YEARMONTH = A.YEARMONTH (+) '||CHR(10)
           ||'   AND B.WORKERSERIAL = A.WORKERSERIAL (+) '||CHR(10)
           ||' ORDER BY B.TOKENNO  '||CHR(10);
  --      DBMS_OUTPUT.PUT_LINE('PISATTN: '||lv_SqlStr);
       insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
       values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
       EXECUTE IMMEDIATE lv_SqlStr;
       COMMIT;

    end if;
    --DBMS_OUTPUT.PUT_LINE ('1_1');
    if P_ViewName = 'PISASSIGN' OR NVL(P_ViewName,'ALL') = 'ALL' then
        lv_Remarks := 'VIEW - PISASSIGN';
        IF P_YEARMONTH = P_EFFECTYEARMONTH THEN
            lv_SqlStr := ' CREATE OR REPLACE VIEW PISASSIGN '||CHR(10)
               ||' AS '||CHR(10)
               ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.YEARMONTH '||CHR(10)
               ||' '||lv_AssignComponent||' '||chr(10)
               ||' FROM PISCOMPONENTASSIGNMENT A, '||chr(10) 
               ||' ( '||chr(10)
               ||'     SELECT WORKERSERIAL, MAX(YEARMONTH) YEARMONTH '||chr(10)
               ||'     FROM PISCOMPONENTASSIGNMENT '||chr(10)
               ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
               ||'       AND YEARMONTH <= '''||P_EFFECTYEARMONTH||''' '||chr(10)
               ||'       AND TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10)
               ||'     GROUP BY WORKERSERIAL '||chr(10)
               ||' ) B '||CHR(10)
               ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
               ||'   AND A.TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10)
               ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||chr(10)
               ||'   AND A.YEARMONTH = B.YEARMONTH '||chr(10)
               ||' ORDER BY A.YEARMONTH '||CHR(10);
        else
            lv_SqlStr := ' CREATE OR REPLACE VIEW PISASSIGN '||CHR(10)
               ||' AS '||CHR(10)
               ||' SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, YEARMONTH '||CHR(10)
               ||' '||lv_AssignCompSum||' '||chr(10)
               ||' FROM ('||CHR(10)
               ||'         SELECT  A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, '''|| P_EFFECTYEARMONTH ||''' YEARMONTH '||CHR(10)
               ||'         '||lv_AssignCompWithArrear||' '||chr(10)
               ||'         FROM PISCOMPONENTASSIGNMENT A, '||chr(10) 
               ||'         ( '||chr(10)
               ||'           SELECT WORKERSERIAL, MAX(YEARMONTH) YEARMONTH '||chr(10)
               ||'           FROM PISCOMPONENTASSIGNMENT '||chr(10)
               ||'           WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
               ||'             AND YEARMONTH <= '''||P_EFFECTYEARMONTH||''' '||chr(10)
               ||'             AND TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10)
               ||'          GROUP BY WORKERSERIAL '||chr(10)
               ||'         ) B '||CHR(10)
               ||'         WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
               ||'           AND A.TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10)
               ||'           AND A.WORKERSERIAL = B.WORKERSERIAL '||chr(10)
               ||'           AND A.YEARMONTH = B.YEARMONTH '||chr(10)
               ||'        /* ORDER BY A.YEARMONTH */'||CHR(10);
            IF LENGTH(TRIM(lv_AssignCompWithOutArrear)) > 0 THEN
            
               lv_SqlStr := lv_SqlStr ||' UNION ALL '||CHR(10);
            
               lv_SqlStr := lv_SqlStr ||'         SELECT  A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, '''|| P_EFFECTYEARMONTH ||''' YEARMONTH '||CHR(10)
                   ||'         '||lv_AssignCompWithOutArrear||' '||chr(10)
                   ||'         FROM PISCOMPONENTASSIGNMENT A, '||chr(10) 
                   ||'         ( '||chr(10)
                   ||'           SELECT WORKERSERIAL, MAX(YEARMONTH) YEARMONTH '||chr(10)
                   ||'           FROM PISCOMPONENTASSIGNMENT '||chr(10)
                   ||'           WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
                   ||'             AND YEARMONTH <= '''||P_YEARMONTH||''' '||chr(10)
                   ||'             AND TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10)
                   ||'          GROUP BY WORKERSERIAL '||chr(10)
                   ||'         ) B '||CHR(10)
                   ||'         WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
                   ||'           AND A.TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10)
                   ||'           AND A.WORKERSERIAL = B.WORKERSERIAL '||chr(10)
                   ||'           AND A.YEARMONTH = B.YEARMONTH '||chr(10)
                   ||'         /*ORDER BY A.YEARMONTH */'||CHR(10);
                        
            END IF;   
            lv_SqlStr := lv_SqlStr ||' ) '||CHR(10)
                   ||' GROUP BY COMPANYCODE, DIVISIONCODE, WORKERSERIAL, YEARMONTH '||CHR(10)
                   ||' ORDER BY YEARMONTH '||CHR(10);
        
        end if;                     
--        DBMS_OUTPUT.PUT_LINE('PISASSIGN: '||lv_SqlStr);
       insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
       values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
       EXECUTE IMMEDIATE lv_SqlStr;
       COMMIT;

        lv_Remarks := 'VIEW - PISPRVRT';
        lv_SqlStr := ' CREATE OR REPLACE VIEW PISPRVRT '||CHR(10)
           ||' AS '||CHR(10)
           ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.YEARMONTH '||CHR(10)
           ||' '||lv_AssignComponent||' '||chr(10)
           ||' FROM PISCOMPONENTASSIGNMENT A, '||chr(10) 
           ||' ( '||chr(10)
           ||'     SELECT WORKERSERIAL, MAX(YEARMONTH) YEARMONTH '||chr(10)
           ||'     FROM PISCOMPONENTASSIGNMENT '||chr(10)
           ||'     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
           ||'       AND YEARMONTH < '''||P_EFFECTYEARMONTH||''' '||chr(10)
           ||'       AND TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10)
           ||'     GROUP BY WORKERSERIAL '||chr(10)
           ||' ) B '||CHR(10)
           ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
           ||'   AND A.TRANSACTIONTYPE = ''ASSIGNMENT'' '||chr(10)
           ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||chr(10)
           ||'   AND A.YEARMONTH = B.YEARMONTH '||chr(10)
           ||' ORDER BY A.YEARMONTH '||CHR(10);               
--        DBMS_OUTPUT.PUT_LINE('PISASSIGN: '||lv_SqlStr);
       insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
       values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
       EXECUTE IMMEDIATE lv_SqlStr;
       COMMIT;



    end if;

    if P_ViewName = 'PISCOMP' OR NVL(P_ViewName,'ALL') = 'ALL' then

        lv_Lday_Cols := '';
        FOR cLvCode in (
                        SELECT LEAVECODE FROM PISLEAVEMASTER WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                        INTERSECT
                        SELECT LTRIM(RTRIM(REPLACE(COLUMN_NAME,'LDAY_',''))) FROM COLS WHERE TABLE_NAME = 'PISPAYTRANSACTION' AND COLUMN_NAME LIKE 'LDAY_%' 
                       )
        loop
           lv_Lday_Cols := lv_Lday_Cols||'A.LDAY_'||cLvCode.LEAVECODE||','; 
        end loop;                         
        lv_Lday_Cols := SUBSTR(lv_Lday_Cols,1,LENGTH(lv_Lday_Cols)-1);
    
        lv_Remarks := 'VIEW - PISCOMP';
        lv_SqlStr := ' CREATE OR REPLACE VIEW PISCOMP '||CHR(10)
           ||' AS '||CHR(10)
           ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.TOKENNO, A.YEARMONTH, '||CHR(10)
           ||' A.ATTN_SALD, A.ATTN_WRKD, A.ATTN_WPAY, A.ATTN_ADJD, A.ATTN_TOTD, ATTN_CALCF, A.ATTN_LDAY, A.ATTN_OFFD,'||lv_Lday_Cols||' /*A.LDAY_PL, A.LDAY_CL, A.LDAY_SL*/ '||CHR(10)
           ||' '||lv_PayComponent||' '||chr(10)
           ||' FROM '||lv_TableName||' A '||CHR(10)           -- PISPAYTRANSACTION
           ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
           ||'   AND A.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
           ||'   AND A.TRANSACTIONTYPE = '''||lv_ProcessType||''' '||CHR(10)            -- P_TRANTYPE REPLACE WITH lv_ProcessType
           ||' ORDER BY A.WORKERSERIAL '||CHR(10);
           --DBMS_OUTPUT.PUT_LINE('PISCOMP: '||lv_SqlStr);
       insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
       values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
       EXECUTE IMMEDIATE lv_SqlStr;
       COMMIT;
    end if;
    
    if P_ViewName = 'PISPREV' OR NVL(P_ViewName,'ALL') = 'ALL' then
        lv_Remarks := 'VIEW - PISPREV';
        lv_SqlStr := ' CREATE OR REPLACE VIEW PISPREV AS '||CHR(10)
                   ||' SELECT A.WORKERSERIAL, A.YEARMONTH, A.MISC_CF AS MISC_CF '||CHR(10)
                   ||' FROM PISPAYTRANSACTION A, '||CHR(10)
                   ||' ( '||CHR(10)
                   ||'   SELECT WORKERSERIAL, MAX(YEARMONTH) YEARMONTH '||CHR(10)
                   ||'   FROM PISPAYTRANSACTION '||CHR(10)
                   ||'   WHERE YEARMONTH < '''||P_YEARMONTH||''' '||CHR(10)
                   ||'   GROUP BY WORKERSERIAL '||CHR(10)
                   ||' ) B '||CHR(10)
                   ||' WHERE A.WORKERSERIAL = B.WORKERSERIAL AND A.YEARMONTH = B.YEARMONTH AND TRANSACTIONTYPE = ''SALARY'' '||CHR(10);
       insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
       values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
       EXECUTE IMMEDIATE lv_SqlStr;
       COMMIT;
    end if;    
exception
when others then
 lv_sqlerrm := sqlerrm ;
 insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
 values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
end;
/


DROP PROCEDURE PRC_PIS_CUMCOMP_UPDATE;

CREATE OR REPLACE PROCEDURE             PRC_PIS_CUMCOMP_UPDATE ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_TRANTYPE Varchar2, 
                                                  P_PHASE  number, 
                                                  P_YEARMONTH Varchar2,
                                                  P_EFFECTYEARMONTH Varchar2, 
                                                  P_TABLENAME Varchar2,
                                                  P_PHASE_TABLENAME Varchar2,
                                                  P_UNIT  Varchar2,
                                                  P_CATEGORY    Varchar2  DEFAULT NULL,
                                                  P_GRADE       Varchar2  DEFAULT NULL,
                                                  P_DEPARTMENT  Varchar2  DEFAULT NULL,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
as 
lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,1,4),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,1,4),'DD/MM/YYYY'));
lv_TableName        varchar2(50);
lv_TempTable        varchar2(30) := 'PIS_TEMP_CUM_UPDT_'||P_DIVCODE;
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_Sql              varchar2(4000) := '';
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName         varchar2(30)   := 'PRC_PIS_CUMCOMP_UPDATE';
lv_Component        varchar2(4000) := '';
lv_CompColumn       varchar2(1000) := '';
lv_UpDtCol          varchar2(200) := ''; 
lv_CompFormula      varchar2(100) := '';
lv_updtable             varchar2(30)    := '';
lv_CalendarYYYYMM       varchar2(10) :=substr(P_YEARMONTH,1,4)||'01';
lv_FinYYYYMM            varchar2(10) :='';
lv_QueryFetchYYYMM      varchar2(10) :='';

Begin
    ---  update Pension Gross, pension and pf company contribution 
    
    DBMS_OUTPUT.PUT_LINE(lv_fn_stdt||','||lv_fn_endt);
--    

    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE '||lv_TempTable||'';
    EXCEPTION
        WHEN OTHERS THEN NULL;        
    END;
    
    select TO_CHAR(STARTDATE,'YYYYMM') INTO lv_FinYYYYMM
    from financialyear
    where companycode = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
      AND STARTDATE <= lv_fn_stdt
      AND ENDDATE >= lv_fn_endt;
    if lv_FinYYYYMM >= lv_CalendarYYYYMM then
        lv_QueryFetchYYYMM := lv_CalendarYYYYMM;
    else
        lv_QueryFetchYYYMM := lv_FinYYYYMM;
    end if;
    
    FOR C1 IN (
                SELECT COMPONENTCODE, PAYFORMULA 
                FROM PISCOMPONENTMASTER
                WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                  AND YEARMONTH = (SELECT MAX(YEARMONTH) FROM PISCOMPONENTMASTER
                                   WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                                  )
                  AND NVL(ALLOWCUMULATIVECOMPCREATION,'N') = 'Y'
              )
    LOOP     
         lv_CompFormula := replace(C1.PAYFORMULA,'PISCOMP.','');
         --lv_Component := lv_Component||','|| C1.COMPONENTCODE||' NUMBER(11,2)';
         IF LENGTH(lv_Component) > 1 THEN 
            lv_Component := lv_Component||',A.' ||C1.COMPONENTCODE||' ';
            lv_UpDtCol := lv_UpDtCol||',B.' ||C1.COMPONENTCODE||' ';
         ELSE
            lv_Component := 'A.'||C1.COMPONENTCODE||' ';
            lv_UpDtCol := 'B.' ||C1.COMPONENTCODE||' ';
         END IF;
         
         lv_CompColumn := lv_CompColumn||', SUM('||C1.COMPONENTCODE||') AS '||C1.COMPONENTCODE||' '||CHR(10);   
         IF INSTR(lv_CompFormula,'ATTN_SALD',1) > 0 THEN
            lv_SqlStr := lv_SqlStr||', CASE WHEN  B.LEAVECALENDARORFINYRWISE = ''F'' THEN CASE WHEN YEARMONTH < '||lv_FinYYYYMM||' THEN 0 ELSE '||lv_CompFormula||' END '||CHR(10)  
                                  ||'  ELSE  CASE WHEN YEARMONTH < '||lv_CalendarYYYYMM||' THEN 0 ELSE '||lv_CompFormula||' END END AS '||C1.COMPONENTCODE||' ' ||CHR(10);
         ELSE
            lv_SqlStr := lv_SqlStr||', CASE WHEN YEARMONTH >= '||lv_FinYYYYMM||' THEN '||lv_CompFormula||' ELSE 0 END AS '||C1.COMPONENTCODE||''; 
         END IF;                                                             
    END LOOP;
    
--    DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
    
    
    
    --lv_Component := 'CREATE TABLE '||lv_TempTable||'( WORKERSERIAL VARCHAR2(10)'||lv_Component||', YEARMONTH VARCHAR2(10))';
    
    --DBMS_OUTPUT.PUT_LINE(lv_Component);
    --EXECUTE IMMEDIATE lv_Component;

    lv_CompColumn := SUBSTR(lv_CompColumn,1,LENGTH(lv_CompColumn)-1);
    
    lv_Sql := ' create table  '||lv_TempTable||' as SELECT WORKERSERIAL '||CHR(10)
            ||' '||lv_CompColumn||', '''||P_EFFECTYEARMONTH||''' YEARMONTH '||CHR(10)
            ||' FROM ( '||CHR(10)
            ||'         SELECT A.WORKERSERIAL, YEARMONTH '||lv_SqlStr||'  '||CHR(10) 
            ||'         FROM PISPAYTRANSACTION A, PISCATEGORYMASTER B '||CHR(10)
            ||'         WHERE A.COMPANYCODE = '''||P_COMPCODE||''' '||chr(10)
            ||'           AND A.YEARMONTH >= '''||lv_QueryFetchYYYMM||''' '||chr(10) 
            ||'           AND A.YEARMONTH < '''||P_EFFECTYEARMONTH||''' '||CHR(10)
            ||'           AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE AND A.CATEGORYCODE = B.CATEGORYCODE '||CHR(10)
            ||'         UNION ALL '||CHR(10)          
            ||'         SELECT WORKERSERIAL,YEARMONTH, ATTN_SALD CUMM_DAYS, PF_GROSS CUM_PFGROS '||CHR(10)
            ||'         FROM '||P_PHASE_TABLENAME||' '||CHR(10)
            ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'           AND YEARMONTH='''||P_EFFECTYEARMONTH||''' '||CHR(10)
            ||'     ) '||CHR(10)
            ||' GROUP BY WORKERSERIAL '||CHR(10);    
    
    --DBMS_OUTPUT.PUT_LINE(lv_Sql);
    lv_remarks := 'TEMP TABLE CREATION FOR CUMULATIVE DATA UPDATE';
    INSERT INTO PIS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    VALUES (lv_ProcName,'',sysdate,lv_Sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);  
    EXECUTE IMMEDIATE lv_Sql;
    COMMIT;
    lv_Sql := 'UPDATE '||P_TABLENAME||' A SET ('||lv_Component||' ) = ( SELECT '||lv_UpDtCol||' FROM '||lv_TempTable||' B '||CHR(10) 
            ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||' AND A.YEARMONTH = '''||P_YEARMONTH||'''   '||CHR(10)
            ||' AND A.WORKERSERIAL = B.WORKERSERIAL AND A.YEARMONTH = B.YEARMONTH)'||CHR(10)
            ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'   AND A.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
            ||'   AND A.WORKERSERIAL IN (SELECT WORKERSERIAL FROM '||lv_TempTable||') '||CHR(10); 
    
    --DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
    lv_remarks := NVL(lv_remarks,'XX ') ||' UPDATE CUMMULATIVE DATA';
    EXECUTE IMMEDIATE lv_Sql;
    INSERT INTO PIS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    VALUES (lv_ProcName,'',sysdate,lv_SqlStr,'', lv_fn_stdt, lv_fn_endt, lv_remarks);    
    COMMIT;
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
     lv_sqlerrm := sqlerrm ;
     insert into PIS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,lv_sqlerrm,lv_Sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    
end;
/


DROP PROCEDURE PRC_PIS_ITAXPREVYRSAVE;

CREATE OR REPLACE PROCEDURE PRC_PIS_ITAXPREVYRSAVE (P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_YEARCODE varchar2,
                                                  P_TABLENAME varchar2,
                                                  P_USERNAME varchar2 DEFAULT NULL
                                                 )
AS
lv_error_remark     varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_Count            number;
lv_result           varchar2(10);
lv_YearCode         varchar2(10);

begin

 lv_result:='#SUCCESS#'; 
 
 select (substr(P_YEARCODE,0,4)-1)||'-'||(substr(P_YEARCODE,6,4)-1)
into lv_YearCode
from dual;

 lv_SqlStr := 'SELECT COUNT(*) '||CHR(10)
                ||'  FROM '||P_TABLENAME||' '||CHR(10)
                ||'  WHERE COMPANYCODE='''||P_COMPCODE ||''' '||CHR(10)
                ||'  AND DIVISIONCODE='''||P_DIVCODE ||''' '||CHR(10)
                ||'  AND YEARCODE='''||lv_YearCode||''' '||CHR(10);
    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);   ---------------------------------------------|||||
     EXECUTE IMMEDIATE lv_SqlStr INTO lv_Count;  
  
 
    if lv_Count = 0 then
        lv_error_remark := 'Validation Failure : [No Component Mapping Found For Category ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;

   IF P_TABLENAME='PISITAXPARAM' THEN 
    
    lv_SqlStr := ' INSERT INTO  '|| P_TABLENAME ||' ( COMPANYCODE, DIVISIONCODE,  YEARCODE, COLUMNNO, COLUMNNOTOPRINT, COLUMNHEADING,  '||CHR(10)    
                ||' COLUMNSUBHEADING, COLUMNSUBHEADING1, COLUMNSUBHEADING2, COLUMNSUBHEADING3, COLUMNSOURCE, '||CHR(10)    
                ||' COLUMNATTRIBUTE, COLUMNBASIS, COLUMNFORMULA, QUALIFIEDAMOUNT, MAXAMOUNT, MONTHLYEXMTLIMIT, '||CHR(10)    
                ||' SHORTDESCRIPTION, COLUMNFORTAX, UPPERLIMITAPP, COLUMNFORSUBTOTAL, COLUMNFORPRQST, INCLUDEINFORM16, '||CHR(10)    
                ||' DISPLAYINGRID, USERNAME )   '||CHR(10)    
                ||' SELECT COMPANYCODE, DIVISIONCODE, '''||P_YEARCODE||''' YEARCODE, COLUMNNO, COLUMNNOTOPRINT, COLUMNHEADING,  '||CHR(10)    
                ||' COLUMNSUBHEADING, COLUMNSUBHEADING1, COLUMNSUBHEADING2, COLUMNSUBHEADING3, COLUMNSOURCE, '||CHR(10)    
                ||' COLUMNATTRIBUTE, COLUMNBASIS, COLUMNFORMULA, QUALIFIEDAMOUNT, MAXAMOUNT, MONTHLYEXMTLIMIT, '||CHR(10)    
                ||' SHORTDESCRIPTION, COLUMNFORTAX, UPPERLIMITAPP, COLUMNFORSUBTOTAL, COLUMNFORPRQST, INCLUDEINFORM16, '||CHR(10)    
                ||' DISPLAYINGRID, '''||P_USERNAME||''' USERNAME  '||CHR(10)   
                ||' FROM PISITAXPARAM  '||CHR(10)
                ||'  WHERE COMPANYCODE='''||P_COMPCODE ||''' '||CHR(10)
                ||'  AND DIVISIONCODE='''||P_DIVCODE ||''' '||CHR(10)
                ||'  AND YEARCODE='''||lv_YearCode||''' '||CHR(10);
                  --lv_SqlStr := lv_SqlStr || '   AND A.workerserial=''000581'' '||CHR(10);
   -- DBMS_OUTPUT.PUT_LINE(lv_SqlStr);  
     EXECUTE IMMEDIATE lv_SqlStr;
    END IF;    
                
end;
/


DROP PROCEDURE PRC_PIS_LEAVEBALANCE;

CREATE OR REPLACE PROCEDURE          PRC_PIS_LEAVEBALANCE (P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_YEARCODE varchar2,
                                                  P_YEARMONTH Varchar2,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL
                                                 )
as
lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,1,4),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,1,4),'DD/MM/YYYY'));
lv_CalendarYear     VARCHAR2(4) := SUBSTR(P_YEARMONTH,1,4);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName         varchar2(30)   := 'PRC_PIS_LEAVEBALANCE';
begin

    DELETE FROM GBL_PISLEAVEBALANCE;
--    COMMIT;
 --- BELOW CRITERIA FOR LEAVE MAINTAING FINANCIAL YEAR WISE IN CATEGORY MASTER WHICH MAINTAINC IN  THE COLUMN -LEAVECALENDARORFINANCIALYRWISE IS 'F'  
    lv_SqlStr := 'INSERT INTO GBL_PISLEAVEBALANCE (COMPANYCODE, DIVISIONCODE, YEARMONTH, WORKERSERIAL, TOKENNO, LEAVECODE, LV_BAL, LV_TAKEN) '||CHR(10)
            ||' SELECT B.COMPANYCODE, B.DIVISIONCODE, '''||P_YEARMONTH||''' YEARMONTH,A.WORKERSERIAL, B.TOKENNO, A.LEAVECODE,  SUM(NOOFDAYS) LV_BAL, SUM(LV_TAKEN) LV_TAKEN '||chr(10)
            ||' FROM ( '||chr(10)
            ||'         SELECT WORKERSERIAL, LEAVECODE, NOOFDAYS, 0 LV_TAKEN '||chr(10)  -- THIS QUERY FOR OPENING DATA 
            ||'         FROM  PISLEAVETRANSACTION '||chr(10)
            ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
            ||'           AND YEARCODE = '''||P_YEARCODE||'''  '||chr(10)
            ||'           AND TRANSACTIONTYPE = ''BF''  '||chr(10)
            ||'         UNION ALL  '||chr(10)
            ||'         SELECT WORKERSERIAL, LEAVECODE, ENTITLEMENTS NOOFDAYS, 0 LV_TAKEN  '||chr(10) -- THIS QUERY FOR ENDTILEMENT DATA 
            ||'         FROM  PISLEAVEENTITLEMENT  '||chr(10)
            ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
            ||'         AND YEARCODE = '''||P_YEARCODE||'''  '||chr(10)
            ||'         UNION ALL  '||chr(10)
            ||'         SELECT WORKERSERIAL, LEAVECODE, -1* SUM(LEAVEDAYS) NOOFDAYS, 0 LV_TAKEN  '||chr(10) -- THIS QUERY FOR LEAVE TAKEN DATA
            ||'         FROM PISLEAVEAPPLICATION  '||chr(10)
            ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
            ||'         AND LEAVEDATE <= '''||lv_fn_endt||'''  '||chr(10)
            ||'         AND LEAVESANCTIONEDON IS NOT NULL  '||chr(10)
            ||'         AND YEARCODE = '''||P_YEARCODE||'''  '||chr(10)
            ||'         GROUP BY WORKERSERIAL, LEAVECODE  '||chr(10)  
            ||'         UNION ALL  '||chr(10)
            ||'         SELECT WORKERSERIAL, LEAVECODE, 0 NOOFDAYS, SUM(LEAVEDAYS) LV_TAKEN  '||chr(10)  -- THIS QUERY FOR TAKEN CURRENT MONTH DATA
            ||'         FROM PISLEAVEAPPLICATION  '||chr(10)
            ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
            ||'         AND LEAVEDATE >= '''||lv_fn_stdt||''' '||chr(10)
            ||'         AND LEAVEDATE <= '''||lv_fn_endt||''' '||chr(10)
            ||'         AND LEAVESANCTIONEDON IS NOT NULL  '||chr(10)
            ||'         AND YEARCODE = '''||P_YEARCODE||'''  '||chr(10)
            ||'         GROUP BY WORKERSERIAL, LEAVECODE  '||chr(10)
            ||' ) A, PISEMPLOYEEMASTER B, PISCATEGORYMASTER C, PISLEAVEMASTER L  '||chr(10)
            ||' WHERE B.COMPANYCODE =  '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
            ||'   AND A.WORKERSERIAL = B.WORKERSERIAL  '||chr(10)
            ||'   AND B.COMPANYCODE = C.COMPANYCODE AND B.DIVISIONCODE = C.DIVISIONCODE  '||chr(10)
            ||'   AND B.CATEGORYCODE = C.CATEGORYCODE  '||chr(10)
            ||'   AND NVL(C.LEAVECALENDARORFINYRWISE,''F'') = ''F''  '||chr(10)
            ||'   AND L.COMPANYCODE =  '''||P_COMPCODE||''' AND L.DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
            ||'   AND A.LEAVECODE = L.LEAVECODE '||CHR(10)
            ||'   /*AND NVL(WITHOUTPAYLEAVE,''N'') <> ''Y'' */'||CHR(10)  
            ||'   GROUP BY B.COMPANYCODE, B.DIVISIONCODE, A.WORKERSERIAL, B.TOKENNO, A.LEAVECODE  '||chr(10);
    insert into PIS_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    execute immediate lv_SqlStr;
    dbms_output.put_line (lv_SqlStr);            
    COMMIT;        
 --- BELOW CRITERIA FOR LEAVE MAINTAING CALENDATE YEAR WISE IN CATEGORY MASTER WHICH MAINTAINC IN  THE COLUMN -LEAVECALENDARORFINANCIALYRWISE IS 'C'  
    lv_SqlStr := 'INSERT INTO GBL_PISLEAVEBALANCE (COMPANYCODE, DIVISIONCODE, YEARMONTH, WORKERSERIAL, TOKENNO, LEAVECODE, LV_BAL, LV_TAKEN) '||CHR(10)
            ||' SELECT B.COMPANYCODE, B.DIVISIONCODE, '''||P_YEARMONTH||''' YEARMONTH, A.WORKERSERIAL, B.TOKENNO, A.LEAVECODE,  SUM(NOOFDAYS) LV_BAL, SUM(LV_TAKEN) LV_TAKEN '||chr(10)
            ||' FROM ( '||chr(10)
            ||'         SELECT WORKERSERIAL, LEAVECODE, NOOFDAYS, 0 LV_TAKEN '||chr(10)  -- THIS QUERY FOR OPENING DATA 
            ||'         FROM  PISLEAVETRANSACTION '||chr(10)
            ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
            ||'           AND CALENDARYEAR = '''||lv_CalendarYear||'''  '||chr(10)
            ||'           AND TRANSACTIONTYPE = ''BF''  '||chr(10)
            ||'         UNION ALL  '||chr(10)
            ||'         SELECT WORKERSERIAL, LEAVECODE, ENTITLEMENTS NOOFDAYS, 0 LV_TAKEN  '||chr(10) -- THIS QUERY FOR ENDTILEMENT DATA 
            ||'         FROM  PISLEAVEENTITLEMENT  '||chr(10)
            ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
            ||'         AND CALENDARYEAR = '''||lv_CalendarYear||'''  '||chr(10)
            ||'         UNION ALL  '||chr(10)
            ||'         SELECT WORKERSERIAL, LEAVECODE, -1* SUM(LEAVEDAYS) NOOFDAYS, 0 LV_TAKEN  '||chr(10) -- THIS QUERY FOR LEAVE TAKEN DATA
            ||'         FROM PISLEAVEAPPLICATION  '||chr(10)
            ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
            ||'         AND LEAVEDATE <= '''||lv_fn_endt||''' '||chr(10)
            ||'         AND LEAVESANCTIONEDON IS NOT NULL  '||chr(10)
            ||'         AND CALENDARYEAR = '''||lv_CalendarYear||'''  '||chr(10)
            ||'         GROUP BY WORKERSERIAL, LEAVECODE  '||chr(10)  
            ||'         UNION ALL  '||chr(10)
            ||'         SELECT WORKERSERIAL, LEAVECODE, 0 NOOFDAYS, SUM(LEAVEDAYS) LV_TAKEN  '||chr(10)  -- THIS QUERY FOR TAKEN CURRENT MONTH DATA
            ||'         FROM PISLEAVEAPPLICATION  '||chr(10)
            ||'         WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
            ||'         AND LEAVEDATE >= '''||lv_fn_stdt||''' '||chr(10)
            ||'         AND LEAVEDATE <= '''||lv_fn_endt||''' '||chr(10)
            ||'         AND LEAVESANCTIONEDON IS NOT NULL  '||chr(10)
            ||'         AND CALENDARYEAR = '''||lv_CalendarYear||'''  '||chr(10)
            ||'         GROUP BY WORKERSERIAL, LEAVECODE  '||chr(10)
            ||' ) A, PISEMPLOYEEMASTER B, PISCATEGORYMASTER C, PISLEAVEMASTER L  '||chr(10)
            ||' WHERE B.COMPANYCODE =  '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
            ||'   AND A.WORKERSERIAL = B.WORKERSERIAL  '||chr(10)
            ||'   AND B.COMPANYCODE = C.COMPANYCODE AND B.DIVISIONCODE = C.DIVISIONCODE  '||chr(10)
            ||'   AND B.CATEGORYCODE = C.CATEGORYCODE  '||chr(10)
            ||'   AND NVL(C.LEAVECALENDARORFINYRWISE,''F'') = ''C''  '||chr(10)
            ||'   AND L.COMPANYCODE =  '''||P_COMPCODE||''' AND L.DIVISIONCODE = '''||P_DIVCODE||'''  '||chr(10)
            ||'   AND A.LEAVECODE = L.LEAVECODE '||CHR(10)
            ||'   AND NVL(WITHOUTPAYLEAVE,''N'') <> ''Y'' '||CHR(10)  
            ||'   GROUP BY B.COMPANYCODE, B.DIVISIONCODE, A.WORKERSERIAL, B.TOKENNO, A.LEAVECODE  '||chr(10);
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    execute immediate lv_SqlStr;
    dbms_output.put_line (lv_SqlStr);
    COMMIT;
exception    
when others then
 --insert into error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'ERROR SQL',lv_sqlstr,lv_sqlstr,lv_parvalues,lv_remarks);
 lv_sqlerrm := sqlerrm ;
 --dbms_output.put_line(lv_sqlerrm);
 insert into PIS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);        
end;
/


DROP PROCEDURE PRC_PIS_PHASE_DEDN_ROWISE;

CREATE OR REPLACE PROCEDURE          PRC_PIS_PHASE_DEDN_ROWISE (
   P_COMPCODE           VARCHAR2,
   P_DIVCODE            VARCHAR2,
   P_YEARMONTH          VARCHAR2,
   P_PHASE_TABLENAME    VARCHAR2,
   P_PHASE              NUMBER
)
AS
   lv_sql         VARCHAR2 (32767);
   lv_val         NUMBER;
   lv_SqlErr      VARCHAR2 (2000) := '';
   lv_parvalues   VARCHAR2 (100);
   lv_ProcName    VARCHAR2 (30) := 'PRC_PIS_PHASE_DEDN_ROWISE';
   lv_Remarks     VARCHAR2 (100) := '';
   lv_fn_stdt DATE
         := TO_DATE (
                  '01/'
               || SUBSTR (P_YEARMONTH, 5, 2)
               || '/'
               || SUBSTR (P_YEARMONTH, 5, 2),
               'DD/MM/YYYY'
            ) ;
   lv_fn_endt DATE
         := LAST_DAY(TO_DATE (
                           '01/'
                        || SUBSTR (P_YEARMONTH, 5, 2)
                        || '/'
                        || SUBSTR (P_YEARMONTH, 5, 2),
                        'DD/MM/YYYY'
                     )) ;
   lv_sql_bulk_ins   VARCHAR2 (32767);                  
BEGIN
   lv_parvalues :=
         'COMP ='
      || P_COMPCODE
      || ', DIV = '
      || P_DIVCODE
      || ',YEARMONTH = '
      || P_YEARMONTH;

   DELETE FROM   PIS_GTT_SWT_PHASE_DEDN;

   COMMIT;

--DBMS_OUTPUT.PUT_LINE('P_PHASE_TABLENAME '|| P_PHASE_TABLENAME || '    P_PHASE '|| P_PHASE);

   FOR c1 IN (SELECT   * FROM PIS_SWT_PHASE_DEDN)        --  P_PHASE_TABLENAME
   LOOP
      lv_sql_bulk_ins := '';
      FOR c2
      IN (SELECT   column_name cn
            FROM   cols
           WHERE   table_name = P_PHASE_TABLENAME           --'SWT_PHASE_DEDN'
          INTERSECT
          SELECT   COMPONENTCODE cn
            FROM   PISCOMPONENTMASTER
           WHERE       COMPANYCODE = P_COMPCODE
                   AND DIVISIONCODE = P_DIVCODE
                   AND COMPONENTCODE <> 'GROSSEARN'
                   AND YEARMONTH =
                         (SELECT   MAX (YEARMONTH)
                            FROM   PISCOMPONENTMASTER
                           WHERE       COMPANYCODE = P_COMPCODE
                                   AND DIVISIONCODE = P_DIVCODE
                                   AND YEARMONTH <= P_YEARMONTH)
                   AND PHASE = P_PHASE)
      LOOP
--       DBMS_OUTPUT.PUT_LINE(lv_sql_bulk_ins);
       
--                     lv_sql := 'select '||c2.cn||' from  SWT_PHASE_DEDN where WORKERSERIAL = '''||c1.WORKERSERIAL||''' and WORKERCATEGORYCODE = '''||c1.WORKERCATEGORYCODE||''' ' ;
         lv_sql :=
               'select NVL('
            || c2.cn
            || ',0) from '
            || P_PHASE_TABLENAME
            || ' where WORKERSERIAL = '''
            || c1.WORKERSERIAL
            || ''' '; --and WORKERCATEGORYCODE = '''||c1.WORKERCATEGORYCODE||''' ' ;

         EXECUTE IMMEDIATE lv_sql INTO   lv_val;
         
         lv_sql_bulk_ins := lv_sql_bulk_ins|| ' INTO  PIS_GTT_SWT_PHASE_DEDN (YEARMONTH,UNITCODE,CATEGORYCODE,GRADECODE,WORKERSERIAL,TOKENNO, ATTN_SALD,ATTN_CALCF,GROSSEARN,TOTEARN,COMPONENTCODE,COMPONENTAMOUNT)  '
            || CHR (10)
            || ' VALUES ( '''
            || c1.YEARMONTH
            || ''','''   
            || c1.UNITCODE
            || ''','''
            || c1.CATEGORYCODE
            || ''','''
            || c1.GRADECODE
            || ''','''
            || c1.WORKERSERIAL
            || ''',''' 
            || c1.TOKENNO
            || ''','            
            || c1.attn_sald
            || ','            
            || c1.attn_calcf
            ||','
            || c1.grossearn
            ||','
            || c1.totearn
            || ','''
            || c2.cn
            || ''','
            || lv_val
            || ' ) '
            || CHR (10);
        /*
         INSERT INTO PIS_GTT_SWT_PHASE_DEDN (YEARMONTH,
                                             UNITCODE,
                                             CATEGORYCODE,
                                             GRADECODE,
                                             WORKERSERIAL,
                                             TOKENNO,
                                             ATTN_SALD,
                                             ATTN_CALCF,
                                             GROSSEARN,
                                             TOTEARN,
                                             COMPONENTCODE,
                                             COMPONENTAMOUNT)
           VALUES   ('' || c1.YEARMONTH || '',
                     '' || c1.UNITCODE || '',
                     '' || c1.categorycode || '',
                     '' || c1.gradecode || '',
                     '' || c1.workerserial || '',
                     '' || c1.tokenno || '',
                     c1.attn_sald,
                     c1.attn_calcf,
                     c1.grossearn,
                     c1.totearn,
                     '' || c2.cn || '',
                     lv_val); */
      END LOOP;
      lv_sql_bulk_ins := 'INSERT ALL ' ||lv_sql_bulk_ins || ' SELECT * FROM DUAL ';
      
--      DBMS_OUTPUT.PUT_LINE(lv_sql_bulk_ins);
      EXECUTE IMMEDIATE lv_sql_bulk_ins;

      COMMIT;
   END LOOP;

   INSERT INTO PIS_error_log (PROC_NAME,
                              ORA_ERROR_MESSG,
                              ERROR_QUERY,
                              PAR_VALUES,
                              FORTNIGHTSTARTDATE,
                              FORTNIGHTENDDATE,
                              REMARKS)
     VALUES   (lv_ProcName,
               '',
               lv_sql_bulk_ins,
               lv_parvalues,
               lv_fn_stdt,
               lv_fn_endt,
               'ROW WISE COMPONENT MERGE SUCCESSFULLY DONE');

   COMMIT;
--EXCEPTION
--   WHEN OTHERS
--   THEN
--      lv_SqlErr := SQLERRM;

--      INSERT INTO wps_error_log (PROC_NAME,
--                                 ORA_ERROR_MESSG,
--                                 ERROR_QUERY,
--                                 PAR_VALUES,
--                                 FORTNIGHTSTARTDATE,
--                                 FORTNIGHTENDDATE,
--                                 REMARKS)
--        VALUES   (lv_ProcName,
--                  lv_SqlErr,
--                  '',
--                  '',
--                  lv_fn_stdt,
--                  lv_fn_endt,
--                  'ROW WISE COMPONENT MERGE ERROR');

--      COMMIT;
END;
/


DROP PROCEDURE PRC_PIS_PREVMONTHCOINBF;

CREATE OR REPLACE PROCEDURE             PRC_PIS_PREVMONTHCOINBF ( P_COMPCODE VARCHAR2, P_DIVCODE VARCHAR2, P_YEARMONTH VARCHAR2, P_CATEGORY VARCHAR2 DEFAULT NULL,
                                                      P_GRADE VARCHAR2 DEFAULT NULL, P_WORKERSERIAL VARCHAR2 DEFAULT NULL
                                                    )
AS
lv_Sql      Varchar2(5000) :='';
lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,1,4),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,1,4),'DD/MM/YYYY'));
lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName         varchar2(30)   := 'PRC_PIS_PREVMONTHCOINBF';
lv_CoinBf       number(11,2) := 0;
lv_CoinCf       number(11,2) := 0;

begin

     lv_parvalues := 'COMPANY : '||P_COMPCODE||', DIVISIONCODE : '||P_DIVCODE||', YEARMONTH : '||P_YEARMONTH;
     lv_Remarks := 'COINBF DATA PREPARATION';
     
     lv_Sql := ' INSERT INTO PIS_PREV_FN_COIN(WORKERSERIAL, YEARMONTH, COINCF) '||CHR(10) 
        ||' SELECT B.WORKERSERIAL, B.YEARMONTH, CASE WHEN B.YEARMONTH = ''202002'' THEN NVL(C.COMPONENTAMOUNT,0) ELSE NVL(A.MISC_CF,0) END COINCF '||CHR(10) 
        ||' FROM PISPAYTRANSACTION A, '||CHR(10) 
        ||' ( '||CHR(10) 
        ||'     SELECT WORKERSERIAL, MAX(YEARMONTH) YEARMONTH '||CHR(10)
        ||'     FROM ( '||CHR(10)
        ||'             SELECT WORKERSERIAL, MAX(YEARMONTH) YEARMONTH '||CHR(10)  
        ||'             FROM PISPAYTRANSACTION '||CHR(10)  
        ||'             WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
        ||'               AND YEARMONTH < '''||P_YEARMONTH||'''  '||CHR(10)  
        ||'             GROUP BY WORKERSERIAL '||CHR(10)
        ||'             UNION ALL '||CHR(10)
        ||'             SELECT WORKERSERIAL, YEARMONTH '||CHR(10)
        ||'             FROM PISCOMPONENTOPENING '||CHR(10)
        ||'             WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
        ||'               AND COMPONENTCODE = ''MISC_CF'' '||CHR(10)
        ||'          ) '||CHR(10)
        ||'     GROUP BY WORKERSERIAL '||CHR(10)            
        ||' ) B, '||CHR(10)
        ||' ( SELECT * FROM PISCOMPONENTOPENING '||CHR(10)
        ||'   WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
        ||'     AND COMPONENTCODE=''MISC_CF'' '||CHR(10) 
        ||'  ) C '||CHR(10) 
        ||' WHERE 1=1 '||CHR(10)
        ||'   AND B.WORKERSERIAL = A.WORKERSERIAL (+) '||CHR(10)  
        ||'   AND B.YEARMONTH = A.YEARMONTH (+) '||CHR(10)
        ||'   AND B.WORKERSERIAL = C.WORKERSERIAL (+) '||CHR(10);

--    BEGIN
        insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
        values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks );

        DELETE FROM PIS_PREV_FN_COIN; --WHERE FORTNIGHTSTARTDATE = lv_fn_stdt;
        EXECUTE IMMEDIATE lv_Sql;
        COMMIT;
--    exception
--        WHEN OTHERS THEN
--            EXECUTE IMMEDIATE lv_Sql;        
--    END;



exception
when others then
 lv_sqlerrm := sqlerrm ;
 insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE, ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
 values( P_COMPCODE, P_DIVCODE,lv_ProcName,lv_sqlerrm,SYSDATE, lv_Sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
 
    
    
END;
/


DROP PROCEDURE PRC_PIS_REIMBURSMENT_ENT;

CREATE OR REPLACE PROCEDURE             PRC_PIS_REIMBURSMENT_ENT (P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_YEARCODE varchar2,
                                                  P_YEARMONTH Varchar2,
                                                  P_COMPONENTCODE varchar2,
                                                  P_CATEGORYCODE varchar2 DEFAULT NULL,
                                                  P_GRADECODE varchar2 DEFAULT NULL,
                                                  P_USERNAME varchar2 DEFAULT NULL
                                                 )
AS
lv_error_remark     varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_Count            number;
lv_result           varchar2(10);
lv_YearCode         varchar2(10);
lv_NumMonth         number;
lv_NumDays          number;
lv_NumWorkDays      number;
lv_FinStartDate     date;
lv_FinEndDate     date;
lv_ReimbsAmt_NwEmp  number(15,2);
lv_TokenNo          varchar2(50);
lv_CatCode          varchar2(50);
lv_Grade            varchar2(50);
lv_BasicAmt         number(15,2);

begin

 lv_result:='#SUCCESS#'; 

 lv_SqlStr := 'SELECT COUNT(*) '||CHR(10)
                ||'  FROM PISGRADECOMPONENTMAPPING '||CHR(10)
                ||'  WHERE COMPANYCODE='''||P_COMPCODE ||''' '||CHR(10)
                ||'  AND DIVISIONCODE='''||P_DIVCODE ||''' '||CHR(10)
                ||'  AND COMPONENTCODE='''||P_COMPONENTCODE||''' '||CHR(10);
     IF NVL(P_CATEGORYCODE,'NA') <> 'NA' THEN
         lv_SqlStr := lv_SqlStr || '   AND CATEGORYCODE = '''||P_CATEGORYCODE||''' '||CHR(10);
     END IF;
      IF NVL(P_GRADECODE,'NA') <> 'NA' THEN
         lv_SqlStr := lv_SqlStr || '   AND GRADECODE = '''||P_GRADECODE||''' '||CHR(10);
     END IF;
    --DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);   ---------------------------------------------|||||
     EXECUTE IMMEDIATE lv_SqlStr INTO lv_Count;  
  
 
    if lv_Count = 0 then
        lv_error_remark := 'Validation Failure : [No Component Mapping Found For Category ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
     PRC_PISVIEWCREATION (P_COMPCODE,P_DIVCODE,'PISASSIGN',0,P_YEARMONTH,P_YEARMONTH, 'SALARY', 'PISPAYTRANSACTION_SWT');
               lv_SqlStr := ' DELETE FROM PISREIMBURSEMENT_ENTITLE '||CHR(10)
                          ||' WHERE COMPANYCODE='''||P_COMPCODE||''' '||CHR(10)
                          ||' AND DIVISIONCODE='''||P_DIVCODE||''' '||CHR(10)
                          ||' AND YEARCODE='''||P_YEARCODE||''' '||CHR(10);
                 execute immediate lv_SqlStr;   
               
                lv_SqlStr :=  'INSERT INTO PISREIMBURSEMENT_ENTITLE '|| CHR(10)
                             ||' ( COMPANYCODE, DIVISIONCODE, YEARCODE, WORKERSERIAL, TOKENNO, CATEGORYCODE, GRADECODE, COMPONENTCODE, COMPONENTAMOUNT, TRANSACTIONTYPE, ADDLESS ,USERNAME)' ||CHR(10)
                             ||'   SELECT DISTINCT A.COMPANYCODE, A.DIVISIONCODE,'''||P_YEARCODE||''' YEARCODE, A.WORKERSERIAL, A.TOKENNO,'|| CHR(10)
                             ||'  A.CATEGORYCODE,A.GRADECODE,'''||P_COMPONENTCODE||''' COMPONENTCODE,B.BASIC,''ENTITLEMEN'' TRANSACTIONTYPE,''ADD'' ADDLESS ,'''||P_USERNAME||''' USERNAME '|| CHR(10)
                             ||'  FROM PISEMPLOYEEMASTER A,PISASSIGN B '|| CHR(10)
                             ||'  WHERE A.COMPANYCODE=B.COMPANYCODE '|| CHR(10)
                             ||'  AND A.DIVISIONCODE=B.DIVISIONCODE '|| CHR(10)
                             ||'  AND A.WORKERSERIAL=B.WORKERSERIAL '|| CHR(10)
                             ||'  AND A.EMPLOYEESTATUS=''ACTIVE'' '|| CHR(10)
                             ||'  AND A.COMPANYCODE='''||P_COMPCODE ||''' '|| CHR(10)
                             ||'  AND A.DIVISIONCODE='''||P_DIVCODE ||''' '|| CHR(10);
                            IF NVL(P_CATEGORYCODE,'NA') <> 'NA' THEN
                                 lv_SqlStr := lv_SqlStr || '   AND A.CATEGORYCODE = '''||P_CATEGORYCODE||''' '||CHR(10);
                             END IF;
                              IF NVL(P_GRADECODE,'NA') <> 'NA' THEN
                                 lv_SqlStr := lv_SqlStr || '   AND A.GRADECODE = '''||P_GRADECODE||''' '||CHR(10);
                             END IF;
                           --lv_SqlStr := lv_SqlStr || '   AND A.WORKERSERIAL IN (''000581'')  '||CHR(10);
                           DBMS_OUTPUT.PUT_LINE('MEDIACAL'||lv_SqlStr);  
                             execute immediate lv_SqlStr;
                                 
    
    lv_SqlStr := 'DELETE FROM TEMP_REIMBURSMENT' ||CHR(10);
    
     EXECUTE IMMEDIATE lv_SqlStr;
    
    lv_SqlStr := ' INSERT INTO  TEMP_REIMBURSMENT  '||CHR(10)
                    ||' SELECT DISTINCT A.WORKERSERIAL,A.DATEOFJOIN ,A.CATEGORYCODE, A.GRADECODE,B.BASIC '||CHR(10)
                    ||' FROM PISEMPLOYEEMASTER A,PISASSIGN B '||CHR(10)
                    ||' WHERE A.COMPANYCODE=B.COMPANYCODE '||CHR(10)
                    ||' AND A.DIVISIONCODE=B.DIVISIONCODE '||CHR(10)
                    ||' AND A.WORKERSERIAL=B.WORKERSERIAL '||CHR(10)
                    ||' AND A.COMPANYCODE='''||P_COMPCODE ||''' '||CHR(10)
                    ||' AND A.DIVISIONCODE='''||P_DIVCODE ||'''  '||CHR(10)  
                    ||' AND A.EMPLOYEESTATUS=''ACTIVE'' '||CHR(10);
       IF NVL(P_CATEGORYCODE,'NA') <> 'NA' THEN
         lv_SqlStr := lv_SqlStr || '   AND A.CATEGORYCODE = '''||P_CATEGORYCODE||''' '||CHR(10);
     END IF;
      IF NVL(P_GRADECODE,'NA') <> 'NA' THEN
         lv_SqlStr := lv_SqlStr || '   AND A.GRADECODE = '''||P_GRADECODE||''' '||CHR(10);
     END IF;
      --lv_SqlStr := lv_SqlStr || '   AND A.workerserial=''000581'' '||CHR(10);
   -- DBMS_OUTPUT.PUT_LINE(lv_SqlStr);  
     EXECUTE IMMEDIATE lv_SqlStr;
                    

for c1 in ( SELECT * FROM TEMP_REIMBURSMENT
              --   WHERE WORKERSERIAL='000581'
                  ) loop
             lv_YearCode:='';          
             SELECT COUNT(*)
            INTO lv_Count
            FROM FINANCIALYEAR 
            WHERE COMPANYCODE=P_COMPCODE 
            AND DIVISIONCODE=P_DIVCODE 
            AND STARTDATE <=C1.DATEOFJOIN 
            AND ENDDATE >=C1.DATEOFJOIN ;
                        
           IF lv_Count>0 THEN
                                  
            SELECT YEARCODE
            INTO lv_YearCode FROM FINANCIALYEAR 
            WHERE STARTDATE <=C1.DATEOFJOIN 
            AND ENDDATE >=C1.DATEOFJOIN 
            AND ROWNUM=1;
                        
            END IF;
                SELECT STARTDATE , ENDDATE INTO lv_FinStartDate,lv_FinEndDate FROM FINANCIALYEAR 
                WHERE COMPANYCODE=P_COMPCODE
                   AND DIVISIONCODE=P_DIVCODE
                   AND YEARCODE=P_YEARCODE
                   AND ROWNUM=1;                   
    
--            SELECT TO_DATE('01/'|| SUBSTR(P_YEARMONTH,5,2)||'/'|| SUBSTR(P_YEARMONTH,1,4),'DD/MM/YYYY')  
--            INTO lv_FinStartDate
--            FROM DUAL ;
            DBMS_OUTPUT.PUT_LINE(P_YEARCODE||'P_YEARCODE ' ||lv_YearCode||' lv_YearCode WOKER '||C1.WORKERSERIAL );
              if P_YEARCODE=lv_YearCode then
                                                                       
                select TRUNC(MONTHS_BETWEEN (TO_DATE(lv_FinEndDate,'DD/MM/YY'),TO_DATE(C1.DATEOFJOIN ,'DD/MM/YY')),0)
                --select TRUNC(MONTHS_BETWEEN (TO_DATE(C1.DATEOFJOIN,'DD/MM/YY'),TO_DATE(lv_FinEndDate ,'DD/MM/YY')),0) 
                into lv_NumMonth from dual;   
                      DBMS_OUTPUT.PUT_LINE(lv_NumMonth||'lv_NumMonth '||lv_FinEndDate||'   lv_FinEndDate'||C1.DATEOFJOIN||'C1.DATEOFJOIN' );    
                 
               IF ABS(lv_NumMonth) <12 THEN
                           
                            SELECT CAST(to_char(LAST_DAY(to_date(c1.DATEOFJOIN,'dd/mm/yyyy')),'dd') AS INT),CAST(to_char(LAST_DAY(to_date(c1.DATEOFJOIN,'dd/mm/yyyy')),'dd') AS INT) -
                            cast(to_char(to_date(c1.DATEOFJOIN,'dd/mm/yyyy'),'dd') as int)+1
                            into lv_NumWorkDays,lv_NumDays
                            FROM dual;  
                           -- DBMS_OUTPUT.PUT_LINE(lv_BasicAmt||'   lv_BasicAmt  '||lv_NumMonth||' lv_NumMonth '||lv_NumDays||'lv_NumDays' ); 
                       IF lv_NumWorkDays= lv_NumDays  THEN
                                lv_ReimbsAmt_NwEmp := (c1.BASIC*lv_NumMonth)/12;                       
                       ELSE
                            lv_ReimbsAmt_NwEmp := ((c1.BASIC*lv_NumMonth)/12)+( (c1.BASIC /12)/( lv_NumWorkDays/lv_NumDays));
                       
                       END IF; 
                            
                            --lv_BasicAmt:=lv_BasicAmt+lv_ReimbsAmt_NwEmp;     
                           -- DBMS_OUTPUT.PUT_LINE(lv_ReimbsAmt_NwEmp||'   lv_ReimbsAmt_NwEmp'||lv_BasicAmt||'lv_BasicAmt' );                                 
                           
                            lv_SqlStr :=  'UPDATE PISREIMBURSEMENT_ENTITLE SET COMPONENTAMOUNT='||lv_ReimbsAmt_NwEmp||' '|| CHR(10)
                                          ||' WHERE COMPANYCODE='''||P_COMPCODE||''' '||CHR(10)
                                          ||' AND DIVISIONCODE='''||P_DIVCODE||''' '||CHR(10)
                                          ||' AND YEARCODE='''||P_YEARCODE||''' '||CHR(10) 
                                          ||' AND WORKERSERIAL= '''||C1.WORKERSERIAL||''' '||CHR(10);
                            --DBMS_OUTPUT.PUT_LINE(lv_SqlStr);                              
                            execute immediate lv_SqlStr;  
               END IF;               
                      
              end if;
          
      end loop;       
                 
end;
/


DROP PROCEDURE PRC_PIS_SALARY_OTHER_COMP_UPDT;

CREATE OR REPLACE PROCEDURE PRC_PIS_SALARY_OTHER_COMP_UPDT (P_COMPCODE Varchar2, 
                                                          P_DIVCODE Varchar2,
                                                          P_TRANTYPE Varchar2, 
                                                          P_PHASE  number, 
                                                          P_YEARMONTH Varchar2,
                                                          P_EFFECTYEARMONTH Varchar2, 
                                                          P_TABLENAME Varchar2,
                                                          P_PHASE_TABLENAME Varchar2,
                                                          P_UNIT  Varchar2,
                                                          P_CATEGORY    Varchar2  DEFAULT NULL,
                                                          P_GRADE       Varchar2  DEFAULT NULL,
                                                          P_DEPARTMENT  Varchar2  DEFAULT NULL,
                                                          P_WORKERSERIAL VARCHAR2 DEFAULT NULL
                                                              )
as
lv_Component            varchar2(32767) := '';
lv_Sql                  varchar2(32767) := '';
lv_upd1_sql             varchar2(32767) := '';
lv_upd2_sql             varchar2(32767) := '';
lv_colstr               varchar2(32767) := '';
lv_Sql_TblCreate        varchar2(3000) := '';  
lv_sqlerrm              varchar2(1000) := ''; 
lv_remarks              varchar2(1000) := '';
lv_parvalues            varchar2(1000) := '';
lv_SqlTemp              varchar2 (2000) := '';
lv_Cols                 varchar2 (1000) := '';
lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY'));
lv_ProcName             varchar2(30) := 'PROC_PIS_SALARY_OTHER_COMP_UPDT';
lv_YYYYMM               varchar2(10) := P_YEARMONTH; 
lv_updtable             varchar2(30) ;
lv_pf_cont_col          varchar2(30) ;
lv_MaxPensionGrossAmt   number(12,2) := 0;
lv_MaxPensionAmt        number(12,2) := 0;
lv_PensionPercentage    number(7,2) := 0;
lv_ESI_C_Percentage     number(7,2) := 0;
lv_cnt                  int;
begin
    lv_parvalues := 'COMP='||P_COMPCODE||',DIV = '||P_DIVCODE||', YEARMONTH = '||P_YEARMONTH||', YEARMONTH '||P_YEARMONTH||',PAHSE='||P_PHASE;
    lv_sql := 'drop table '||P_PHASE_TABLENAME;
    
    BEGIN 
        execute immediate lv_sql;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    
    --------- for pension part ---------
    
    --- START ADD ON 31.01.2017 ------
    select MAXIMUMPENSIONGROSS,  PENSION_PERCENTAGE 
    into lv_MaxPensionGrossAmt,  lv_PensionPercentage
    from PISALLPARAMETER 
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE;
    
    select SUBSTR( ( 'WPS_'||SYS_CONTEXT('USERENV', 'SESSIONID')) ,1,30) into lv_updtable  from dual ;
    
    lv_sql := ' CREATE TABLE '||lv_updtable||' AS  '||CHR(10)
            ||' SELECT WORKERSERIAL, CATEGORYCODE, GRADECODE, PF_GROSS, PF_E, PEN_GROSS, ROUND(PEN_GROSS * '||lv_PensionPercentage||'/100,0) FPF, PF_E - ROUND(PEN_GROSS * '||lv_PensionPercentage||'/100,0) PF_C '||chr(10)
            ||' FROM ( '||chr(10) 
            ||' SELECT A.WORKERSERIAL, A.CATEGORYCODE, A.GRADECODE,PF_GROSS, PF_E, '||chr(10) 
            ||' CASE WHEN NVL(B.EPFAPPLICABLE,''N'') = ''Y'' THEN CASE WHEN PF_GROSS >= '||lv_MaxPensionGrossAmt||' THEN '||lv_MaxPensionGrossAmt||' ELSE PF_GROSS END ELSE 0 END PEN_GROSS '||chr(10) 
            ||' FROM PISPAYTRANSACTION_SWT A, PISEMPLOYEEMASTER B '||chr(10)
            ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
            ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||chr(10)
            ||'   AND PF_E > 0 '||chr(10) 
            ||' ) '||CHR(10);    
    --dbms_output.put_line( lv_sql );
    INSERT INTO WPS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks); 
    EXECUTE IMMEDIATE lv_sql  ;
    lv_sql := 'UPDATE '||P_TABLENAME||' A SET (PEN_GROSS, FPF, PF_C  ) = ( SELECT PEN_GROSS, FPF, PF_C FROM '||lv_updtable||' B '||CHR(10) 
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.YEARMONTH = '''||P_YEARMONTH||'''       '||CHR(10)
        ||' AND A.WORKERSERIAL = B.WORKERSERIAL )'||CHR(10)
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.YEARMONTH = '''||P_YEARMONTH||'''       '||CHR(10);
    --- END ADD ON 29.09.2016 -----------
    --dbms_output.put_line( lv_sql );
    lv_remarks := NVL(lv_remarks,'XX ') ||' UPDATE PENSION GROSS, FPF, PF_COM';
    INSERT INTO WPS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);    
    EXECUTE IMMEDIATE lv_sql;
       BEGIN
        execute immediate 'DROP TABLE '||lv_updtable ;
       EXCEPTION
        WHEN OTHERS THEN
          lv_sqlerrm := sqlerrm;
          raise_application_error(-20101, lv_sqlerrm||'ERROR WHILE UPDATING '||P_TABLENAME||' FROM TABLE '||lv_updtable);
       END ;                          
   ---------------- ESI COMPANY CONTRIBUTION UPDATE ---------    
   lv_remarks := 'PHASE - '||P_PHASE||' START UPDATE ESI_C';
   /*lv_Sql := ' UPDATE '||P_TABLENAME||' SET ESI_C = CEIL(ROUND(ESI_GROSS * '||lv_ESI_C_Percentage||'/100,2)) '||CHR(10)
        ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||'   AND FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')       '||CHR(10)
        ||'   AND FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')               '||CHR(10)
        ||'   AND NVL(ESI_CONT,0) > 0 '||CHR(10);
    INSERT INTO WPS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);    
    EXECUTE IMMEDIATE lv_sql;
   */         
end;
/


DROP PROCEDURE PRC_PIS_SALARY_PROCESS;

CREATE OR REPLACE PROCEDURE          PRC_PIS_SALARY_PROCESS( P_COMPCODE varchar2,
                                                    P_DIVCODE varchar2, 
                                                    P_PROCESSTYPE varchar2, 
                                                    P_USERNAME VARCHAR2,
                                                    P_YEARMONTH VARCHAR2, 
                                                    P_EFFECTYEARMONTH Varchar2,
                                                    P_UNIT  Varchar2,
                                                    P_CATEGORY    Varchar2  DEFAULT NULL,
                                                    P_GRADE       Varchar2  DEFAULT NULL,
                                                    P_DEPARTMENT  Varchar2  DEFAULT NULL,
                                                    P_WORKERSERIAL VARCHAR2 DEFAULT NULL
)
as
lv_SqlStr VARCHAR2(4000) := '';
lv_result VARCHAR2(10);
lv_error_remark varchar2(4000) := '' ;
begin
    lv_result:='#SUCCESS#';
    DELETE FROM PIS_ERROR_LOG;
    DELETE FROM WPS_ERROR_LOG;
    ----------- START ADJUSTMENT SALARY PROCESS CALLING ------------- 
--    if P_PROCESSTYPE = 'SALARY' OR P_PROCESSTYPE = 'ARREAR' then
--        for cur_proc_Adj in ( SELECT DISTINCT ADJYEARMONTH FROM PISMONTHADJUSTMENT 
--                              WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
--                                AND YEARMONTH = P_EFFECTYEARMONTH
--                            )    
--        loop
--            for cur_proc_Adj_params in( select COMPANYCODE, DIVISIONCODE, DECODE(P_PROCESSTYPE,'ARREAR','NEW SALARY',PROCESSTYPE) PROCESSTYPE, PROCEDURE_NAME, PHASE, CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3 
--                                    from WAGESPROCESSTYPE_PHASE  
--                                    where COMPANYCODE = P_COMPCODE 
--                                      and DIVISIONCODE = P_DIVCODE
--                                      and PROCESSTYPE = 'ADJUSTMENT'
--                                    ORDER BY PHASE, CALCULATIONINDEX
--                                  )     
--            loop
--                if cur_proc_Adj_params.PROCEDURE_NAME = 'PRC_PISSALARYPROCESS_TRANSFER' then
--                    lv_SqlStr := cur_proc_Adj_params.PROCEDURE_NAME||'('''||P_COMPCODE||''','''||P_DIVCODE||''',''ADJUSTMENT'', '''||cur_proc_Adj_params.PHASE||''','''||P_YEARMONTH||''','''||P_EFFECTYEARMONTH||''','''||cur_proc_Adj_params.PARAM_1||''','''||cur_proc_Adj_params.PARAM_2||''','''||P_UNIT||''','''||P_CATEGORY||''','''||P_GRADE||''','''||P_DEPARTMENT||''','''||P_WORKERSERIAL||''')';
--                else
--                    lv_SqlStr := cur_proc_Adj_params.PROCEDURE_NAME||'('''||P_COMPCODE||''','''||P_DIVCODE||''',''ADJUSTMENT'', '''||cur_proc_Adj_params.PHASE||''','''||cur_proc_Adj.ADJYEARMONTH||''','''||P_EFFECTYEARMONTH||''','''||cur_proc_Adj_params.PARAM_1||''','''||cur_proc_Adj_params.PARAM_2||''','''||P_UNIT||''','''||P_CATEGORY||''','''||P_GRADE||''','''||P_DEPARTMENT||''','''||P_WORKERSERIAL||''')';
--                end if;                    
--                dbms_output.put_line(lv_sqlstr);
--                execute immediate 'BEGIN '||lv_SqlStr||'; END ;';
--            end loop;        
--        end loop;   
--    
--    end if;
    ----------- END ADJUSTMENT SALARY PROCESS CALLING -------------
    for cur_proc_params in( select COMPANYCODE, DIVISIONCODE,DECODE(PROCESSTYPE,'ARREAR','NEW SALARY',PROCESSTYPE) PROCESSTYPE, PROCEDURE_NAME, PHASE, CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3 
                            from WAGESPROCESSTYPE_PHASE  
                            where COMPANYCODE = P_COMPCODE 
                              and DIVISIONCODE = P_DIVCODE
                              and PROCESSTYPE = P_PROCESSTYPE
                            ORDER BY PHASE, CALCULATIONINDEX
                          )     
    loop
        lv_SqlStr := cur_proc_params.PROCEDURE_NAME||'('''||P_COMPCODE||''','''||P_DIVCODE||''','''||cur_proc_params.PROCESSTYPE||''', '''||cur_proc_params.PHASE||''','''||P_YEARMONTH||''','''||P_EFFECTYEARMONTH||''','''||cur_proc_params.PARAM_1||''','''||cur_proc_params.PARAM_2||''','''||P_UNIT||''','''||P_CATEGORY||''','''||P_GRADE||''','''||P_DEPARTMENT||''','''||P_WORKERSERIAL||''')';
--        dbms_output.put_line('EXEC '||lv_sqlstr||';');
        execute immediate 'BEGIN '||lv_SqlStr||'; END ;';
/*P_COMPCODE Varchar2, P_DIVCODE Varchar2, P_TRANTYPE Varchar2, P_PHASE  number, P_YEARMONTH Varchar2, P_EFFECTYEARMONTH Varchar2, P_TABLENAME Varchar2, P_PHASE_TABLENAME Varchar2, P_UNIT  Varchar2, P_CATEGORY    Varchar2  DEFAULT NULL, P_GRADE       Varchar2  DEFAULT NULL, P_DEPARTMENT  Varchar2  DEFAULT NULL,
P_WORKERSERIAL VARCHAR2 DEFAULT NULL*/        
        
        
    end loop;
exception
when others then
    lv_error_remark := sqlerrm;
    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    --dbms_output.put_line(sqlerrm);
end;
/


DROP PROCEDURE PROC_PISBANKMASTER;

CREATE OR REPLACE procedure proc_pisbankmaster
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_bankcode varchar2
    )
as 
    lv_sqlstr           varchar2(4000);
begin
    delete from GTT_PISBANKMASTER;
    
                    lv_sqlstr :=    'insert into GTT_PISBANKMASTER'|| chr(10)
                    || ' select a.companycode,a.divisioncode,a.bankcode,a.bankdesc,a.bankaddress,a.bankbsr,a.bankindex,a.banksalaryadvise,a.salaryaccountno,a.micrno,a.branchname,a.acno,a.ifsccode, '|| chr(10)
                    || ' companyname,companyaddress, companyaddress1,companyaddress2,companyaddress3,companycity,companystate,companycountry '|| chr(10)
                    || ' from pisbankmaster a, companymast c  '|| chr(10)
                    || ' where a.companycode='''|| p_companycode ||''' '|| chr(10)
                    || '   and a.divisioncode='''||p_divisioncode||'''  '|| chr(10)
                    || '   and a.companycode=c.companycode  '|| chr(10);
                      if p_bankcode is not null then
                      lv_sqlstr := lv_sqlstr || '   and bankcode in ('|| p_bankcode ||')' || chr(10);
                      end if;
                    lv_sqlstr := lv_sqlstr || '    order by bankcode,bankdesc '|| chr(10);
    execute immediate lv_sqlstr;
end;
/


DROP PROCEDURE PROC_PISCATEGORYMAST;

CREATE OR REPLACE procedure proc_piscategorymast
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_categorycode varchar2
)
as 
    lv_sqlstr           varchar2(4000);
begin
    delete from GTT_PISCATEGORYMAST;
    
                    lv_sqlstr :=    'insert into GTT_PISCATEGORYMAST'|| chr(10)
                    || ' select a.companycode,a.divisioncode,categorycode,categorydesc,categoryindex,leavecalendarorfinyrwise,calculationdays,offdaysnotconsiderinsalaryday, '|| chr(10)
                    || '       holidayworked_attn,attendanceentry,exgratiaapplicable,bonusapplicable,roundoffamount,roundoffapplicable,companyname,companyaddress, '|| chr(10)
                    || '       companyaddress1,companyaddress2,companyaddress3,companycity,companystate,companycountry  '|| chr(10)
                    || '       from piscategorymaster a, companymast c '|| chr(10)
                    || '        where a.companycode='''|| p_companycode ||''' '|| chr(10)
                    || '          and a.divisioncode='''||p_divisioncode||''' '|| chr(10)
                    || '          and a.companycode=c.companycode '|| chr(10);
                      if p_categorycode is not null then
                      lv_sqlstr := lv_sqlstr || '   and categorycode in ('|| p_categorycode ||')' || chr(10);
                      end if;
                    lv_sqlstr := lv_sqlstr || '          order by categorycode,categorydesc '|| chr(10);
    execute immediate lv_sqlstr;
end;
/


DROP PROCEDURE PROC_PISCOMPONENTASSIGNED;

CREATE OR REPLACE procedure               proc_piscomponentassigned( 
p_companycode varchar2, 
p_divisioncode varchar2, 
p_yearmonth varchar2,
p_category   varchar2,
p_grade      varchar2,
p_unit      varchar2,
p_workerserial varchar2 DEFAULT NULL
)
/*
begin
proc_piscomponentassigned( 
'AJ0050', 
'0002', 
'201606',
'01',
'MGR',
'01',
'0098324'
);
end;

*/
as
lv_cnt int;
lv_sqlstr varchar2(4000);
lv_sql varchar2(4000);
lv_val_curr number;
lv_val_prev number;
lv_maxyearmonth varchar2(10) ;
lv_rollover_collist varchar2(4000);
lv_test varchar2(40);
begin
select count(*) into lv_cnt from piscomponentassignment_t where
COMPANYCODE = p_companycode
and DIVISIONCODE = p_divisioncode
and YEARMONTH = p_yearmonth
and UNITCODE = p_unit
and CATEGORYCODE = p_category
and GRADECODE = p_grade
and INSTR(NVL2(p_workerserial,p_workerserial,WORKERSERIAL),WORKERSERIAL) > 0 ;
if lv_cnt = 0 then
     select nvl(max(YEARMONTH),'~NA~')  into lv_maxyearmonth from piscomponentassignment_t where
    COMPANYCODE = p_companycode
    and DIVISIONCODE = p_divisioncode
    and UNITCODE = p_unit
    and CATEGORYCODE = p_category
    and GRADECODE = p_grade
    and INSTR(NVL2(p_workerserial,p_workerserial,WORKERSERIAL),WORKERSERIAL) > 0 ;
    if lv_maxyearmonth = '~NA~' then
       raise_application_error(-20101, 'NO DATA TO ROLLOVER FROM');
    end if;
    select listagg_swt1(rownum||';'||col||',') into lv_rollover_collist from 
    (
    select column_name col from cols where table_name = 'PISCOMPONENTASSIGNMENT' and column_id > 14  
    intersect
    select COMPONENTCODE from PISCOMPONENTMASTER   where ROLLOVERAPPLICABLE = 'Y'
    );
    lv_sqlstr := 'insert into piscomponentassignment_t(COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO, TRANSACTIONTYPE,'||lv_rollover_collist||') '||CHR(10)
                 ||' select '''||p_companycode||''','''||p_divisioncode||''',YEARCODE,'''||p_yearmonth||''','''||p_unit||''',DEPARTMENTCODE,'''||p_category||''','''||p_grade||''',A.WORKERSERIAL,TOKENNO, TRANSACTIONTYPE,'||lv_rollover_collist||' '||chr(10) 
                 ||' from piscomponentassignment_t A, '||chr(10)
                 ||'  ( '||chr(10)
                 ||'    SELECT WORKERSERIAL FROM PISEMPLOYEEMASTER '||chr(10)
                 ||'    WHERE  '||chr(10)
                 ||'    COMPANYCODE = '''||p_companycode||''' '||chr(10)
                 ||'    AND DIVISIONCODE = '''||p_divisioncode||''' '||chr(10)
                 ||'    AND UNITCODE = '''||p_unit||''' '||chr(10)
                 ||'    AND CATEGORYCODE = '''||p_category||''' '||chr(10)
                 ||'    AND GRADECODE = '''||p_grade||''' '||chr(10)
                 ||'    AND EMPLOYEESTATUS = ''ACTIVE'' '||chr(10)
                 ||'    AND ( (STATUSDATE IS  NULL  AND   DATEOFRETIRE > TO_DATE(''01/''||SUBSTR('''||p_yearmonth||''',-2)||''/''||SUBSTR('''||p_yearmonth||''',1,4),''DD/MM/YYYY'')     '||chr(10)   
                 ||'                                AND  EXTENDEDRETIREDATE  > TO_DATE(''01/''||SUBSTR('''||p_yearmonth||''',-2)||''/''||SUBSTR('''||p_yearmonth||''',1,4),''DD/MM/YYYY'')   '||chr(10)
                 ||'           ) '||chr(10)
                 ||'           OR '||chr(10)
                 ||'           (  STATUSDATE >  TO_DATE(''01/''||SUBSTR('''||p_yearmonth||''',-2)||''/''||SUBSTR('''||p_yearmonth||''',1,4),''DD/MM/YYYY'')  )     '||chr(10)                      
                 ||'        ) '||chr(10)
                 ||'   ) B '||chr(10)
                 ||' where '||chr(10)
                 ||' COMPANYCODE = '''||p_companycode||'''  '||chr(10)
                 ||' and DIVISIONCODE = '''||p_divisioncode||'''  '||chr(10)
                 ||' and UNITCODE = '''||p_unit||'''  '||chr(10)
                 ||' and CATEGORYCODE = '''||p_category||'''  '||chr(10)
                 ||' and GRADECODE = '''||p_grade||'''  '||chr(10)
                 ||' and YEARMONTH  = '''||lv_maxyearmonth||'''  '||chr(10)
                 ||' and A.WORKERSERIAL = B.WORKERSERIAL  '||chr(10)
                 ||' and INSTR(NVL2('''||p_workerserial||''','''||p_workerserial||''',A.WORKERSERIAL),A.WORKERSERIAL) > 0 ';
   -- dbms_output.put_line(lv_sqlstr) ;   
     execute immediate lv_sqlstr ;
else
   select nvl(max(YEARMONTH),'~NA~')  into lv_maxyearmonth from piscomponentassignment_t where
    COMPANYCODE = p_companycode
    and DIVISIONCODE = p_divisioncode
    and UNITCODE = p_unit
    and CATEGORYCODE = p_category
    and GRADECODE = p_grade
    and INSTR(NVL2(p_workerserial,p_workerserial,WORKERSERIAL),WORKERSERIAL) > 0
    and YEARMONTH <> p_yearmonth ;
 /* for c1 in ( select * from  piscomponentassignment_t where
                COMPANYCODE = p_companycode
                and DIVISIONCODE = p_divisioncode
                and YEARMONTH = p_yearmonth
                and UNITCODE = p_unit
                and CATEGORYCODE = p_category
                and GRADECODE = p_grade
                and INSTR(NVL2(p_workerserial,p_workerserial,WORKERSERIAL),WORKERSERIAL) > 0
             )
  loop    
    for c2  in( select column_name col from cols where table_name = 'PISCOMPONENTASSIGNMENT' and column_id > 14  
                 intersect
                select COMPONENTCODE from PISCOMPONENTMASTER   where ROLLOVERAPPLICABLE = 'Y' ) loop   
                      
     lv_sqlstr := 'select '||c2.col||'  from piscomponentassignment_t  where '||chr(10)
                  ||' COMPANYCODE = '''||c1.COMPANYCODE||''' '||chr(10)               
                  ||' and DIVISIONCODE = '''||c1.DIVISIONCODE||''' '||chr(10)
                  ||' and YEARMONTH = '''||lv_maxyearmonth||''' '||chr(10) 
                  ||' and UNITCODE = '''||c1.UNITCODE||''' '||chr(10) 
                  ||' and CATEGORYCODE = '''||c1.CATEGORYCODE||''' '||chr(10) 
                  ||' and GRADECODE = '''||c1.GRADECODE||''' '||chr(10)  
                  ||' and WORKERSERIAL = '''||c1.WORKERSERIAL||''' ';
       execute immediate lv_sqlstr into lv_val_prev ;
       lv_sqlstr := 'select '||c2.col||'  from piscomponentassignment_t  where '||chr(10)
                  ||' COMPANYCODE = '''||c1.COMPANYCODE||''' '||chr(10)               
                  ||' and DIVISIONCODE = '''||c1.DIVISIONCODE||''' '||chr(10)
                  ||' and YEARMONTH = '''||p_yearmonth||''' '||chr(10) 
                  ||' and UNITCODE = '''||c1.UNITCODE||''' '||chr(10) 
                  ||' and CATEGORYCODE = '''||c1.CATEGORYCODE||''' '||chr(10) 
                  ||' and GRADECODE = '''||c1.GRADECODE||''' '||chr(10)  
                  ||' and WORKERSERIAL = '''||c1.WORKERSERIAL||''' ';
       execute immediate lv_sqlstr into lv_val_curr ; 
       if lv_val_curr is null or lv_val_curr = 0 then
          lv_sqlstr := 'update piscomponentassignment_t set '||c2.col||'='||lv_val_prev||' '||chr(10)
                       ||'WHERE  COMPANYCODE = '''||c1.COMPANYCODE||''' '||chr(10)               
                  ||' and DIVISIONCODE = '''||c1.DIVISIONCODE||''' '||chr(10)
                  ||' and YEARMONTH = '''||p_yearmonth||''' '||chr(10) 
                  ||' and UNITCODE = '''||c1.UNITCODE||''' '||chr(10) 
                  ||' and CATEGORYCODE = '''||c1.CATEGORYCODE||''' '||chr(10) 
                  ||' and GRADECODE = '''||c1.GRADECODE||''' '||chr(10)  
                  ||' and WORKERSERIAL = '''||c1.WORKERSERIAL||''' ';  
        --   execute immediate lv_sqlstr ;       
         dbms_output.put_line(lv_sqlstr) ; 
       end if; 
    end loop;  
  end loop;   */
  
   for c1  in( select column_name col from cols where table_name = 'PISCOMPONENTASSIGNMENT' and column_id > 14  
                 intersect
                select COMPONENTCODE from PISCOMPONENTMASTER   where ROLLOVERAPPLICABLE = 'Y' ) loop   
      
      lv_sqlstr := 'update piscomponentassignment_t a set '||c1.col||' = '||chr(10) 
                   ||' (  '||chr(10) 
                   ||'  select '||c1.col||' from  piscomponentassignment_t b where '||chr(10) 
                   ||'                 b.COMPANYCODE = a.companycode '||chr(10) 
                   ||'                  and b.DIVISIONCODE = a.divisioncode '||chr(10) 
                   ||'                  and b.YEARMONTH = '''||lv_maxyearmonth||''' '||chr(10) 
                   ||'                  and b.UNITCODE = a.unitcode '||chr(10) 
                   ||'                  and b.CATEGORYCODE = a.CATEGORYCODE '||chr(10) 
                   ||'                  and b.GRADECODE = b.GRADECODE '||chr(10) 
                   ||'                  and b.WORKERSERIAL = a.WORKERSERIAL '||chr(10) 
                   ||'  ) '||chr(10) 
                   ||'  WHERE  COMPANYCODE = '''||p_companycode||'''  '||chr(10) 
                   ||'   and DIVISIONCODE = '''||p_divisioncode||'''  '||chr(10) 
                   ||'   and YEARMONTH = '''||p_yearmonth||'''  '||chr(10) 
                   ||'   and UNITCODE = '''||p_unit||'''  '||chr(10) 
                   ||'   and CATEGORYCODE = '''||p_category||'''  '||chr(10) 
                   ||'   and GRADECODE = '''||p_grade||'''  '||chr(10) 
                   ||'   and ('||c1.col||' is null or '||c1.col||' = 0 ) '||chr(10) 
                   ||'   and INSTR(NVL2('||p_workerserial||','||p_workerserial||',WORKERSERIAL),WORKERSERIAL) > 0 ' ;
    end loop;  
end if; 
end ;
/


DROP PROCEDURE PROC_PISDEPARTMENTMASTER;

CREATE OR REPLACE procedure proc_pisdepartmentmaster
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_departmentcode varchar2
    )
as 
    lv_sqlstr           varchar2(4000);
begin
    delete from GTT_PISDEPARTMENTMASTER;
    
                    lv_sqlstr :=    'insert into GTT_PISDEPARTMENTMASTER'|| chr(10)
                    || '  select a.companycode,a.divisioncode,departmentcode,departmentdesc,departmentindex, '|| chr(10)
                    || '                    companyname,companyaddress, companyaddress1,companyaddress2,companyaddress3,companycity,companystate,companycountry '|| chr(10)
                    || '  from pisdepartmentmaster a, companymast c  '|| chr(10)
                    || ' where a.companycode='''|| p_companycode ||'''  '|| chr(10)
                    || '   and a.divisioncode='''||p_divisioncode||'''  '|| chr(10)
                    || '   and a.companycode=c.companycode  '|| chr(10);
                      if p_departmentcode is not null then
                      lv_sqlstr := lv_sqlstr || '   and departmentcode in ('|| p_departmentcode ||')' || chr(10);
                      end if;
                    lv_sqlstr := lv_sqlstr || '    order by departmentcode,departmentdesc '|| chr(10);
    execute immediate lv_sqlstr;
end;
/


DROP PROCEDURE PROC_PISDESIGNATIONMASTER;

CREATE OR REPLACE procedure proc_pisdesignationmaster
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_designationcode varchar2
    )
as 
    lv_sqlstr           varchar2(4000);
begin
    delete from GTT_PISDESIGNATIONMASTER;
    
                    lv_sqlstr :=    'insert into GTT_PISDESIGNATIONMASTER'|| chr(10)
                    || ' select a.companycode,a.divisioncode,designationcode,designationdesc,designationindex,includenightshift, '|| chr(10)
                    || ' companyname,companyaddress, companyaddress1,companyaddress2,companyaddress3,companycity,companystate,companycountry '|| chr(10)
                    || ' from pisdesignationmaster a, companymast c  '|| chr(10)
                    || ' where a.companycode='''|| p_companycode ||''' '|| chr(10)
                    || '   and a.divisioncode='''||p_divisioncode||'''  '|| chr(10)
                    || '   and a.companycode=c.companycode  '|| chr(10);
                      if p_designationcode is not null then
                      lv_sqlstr := lv_sqlstr || '   and designationcode in ('|| p_designationcode ||')' || chr(10);
                      end if;
                    lv_sqlstr := lv_sqlstr || '    order by designationcode,designationdesc '|| chr(10);
    execute immediate lv_sqlstr;
end;
/


DROP PROCEDURE PROC_PISDOCTORMASTER;

CREATE OR REPLACE procedure proc_pisdoctormaster
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_doctorcode varchar2
    )
as 
    lv_sqlstr           varchar2(4000);
begin
    delete from GTT_PISDOCTORMASTER;
    
                    lv_sqlstr :=    'insert into GTT_PISDOCTORMASTER'|| chr(10)
                    || ' select a.companycode,a.divisioncode,doctorcode,doctorname, '|| chr(10)
                    || ' companyname,companyaddress, companyaddress1,companyaddress2,companyaddress3,companycity,companystate,companycountry '|| chr(10)
                    || ' from pisdoctormaster a, companymast c  '|| chr(10)
                    || ' where a.companycode='''|| p_companycode ||''' '|| chr(10)
                    || '   and a.divisioncode='''||p_divisioncode||'''  '|| chr(10)
                    || '   and a.companycode=c.companycode  '|| chr(10);
                      if p_doctorcode is not null then
                      lv_sqlstr := lv_sqlstr || '   and doctorcode in ('|| p_doctorcode ||')' || chr(10);
                      end if;
                    lv_sqlstr := lv_sqlstr || '    order by doctorcode,doctorname '|| chr(10);
    execute immediate lv_sqlstr;
end;
/


DROP PROCEDURE PROC_PISGRADEMAST;

CREATE OR REPLACE procedure proc_pisgrademast
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_categorycode varchar2,
    p_gradecode varchar2
)
as 
    lv_sqlstr           varchar2(4000);
begin
    delete from GTT_PISGRADEMASTER;
    
                    lv_sqlstr :=    'insert into GTT_PISGRADEMASTER'|| chr(10)
                    || ' select a.companycode,a.divisioncode,categorycode,gradecode,gradedesc,gradeindex, '|| chr(10)
                    || '      companyname,companyaddress, companyaddress1,companyaddress2,companyaddress3,companycity,companystate,companycountry  '|| chr(10)
                    || '       from pisgrademaster a, companymast c '|| chr(10)
                    || '        where a.companycode='''|| p_companycode ||''' '|| chr(10)
                    || '          and a.divisioncode='''||p_divisioncode||''' '|| chr(10)
                    || '          and a.companycode=c.companycode '|| chr(10);
                      if p_categorycode is not null then
                      lv_sqlstr := lv_sqlstr || '   and categorycode in ('|| p_categorycode ||')' || chr(10);
                      end if;
                       if p_gradecode is not null then
                      lv_sqlstr := lv_sqlstr || '   and gradecode in ('|| p_gradecode ||')' || chr(10);
                      end if;
                    lv_sqlstr := lv_sqlstr || '    order by categorycode,gradecode,gradedesc '|| chr(10);
    execute immediate lv_sqlstr;
end;
/


DROP PROCEDURE PROC_PISITAX_COMPUTATION;

CREATE OR REPLACE PROCEDURE PROC_PISITAX_COMPUTATION
(
    P_COMPANYCODE    VARCHAR2,
    P_DIVISIONCODE   VARCHAR2,
    P_YEARCODE       VARCHAR2,
    P_CATEGORY       VARCHAR2 DEFAULT NULL,
    P_GRADE          VARCHAR2 DEFAULT NULL,
    P_TOKENNO        VARCHAR2 DEFAULT NULL
)
 AS
  LV_SQLSTR           VARCHAR2(3000) := '';
  LV_CNT              NUMBER         := 0;
  LV_ACTLY            NUMBER(15,2)   := 0;
  LV_PRJCT            NUMBER(15,2)   := 0;
  LV_COLUMNNO         VARCHAR2(50)   :='';
  LV_COLNO            VARCHAR2(50)   :='';
  LV_TEMPTAB          VARCHAR2(50)   :='';
  LV_YEARMONTH        VARCHAR2(50)   :='';
  LV_NOOFMONTH        VARCHAR2(10)   :='';
  LV_FIN_STARTDATE        VARCHAR2(10)   :='';
  LV_FIN_ENDDATE        VARCHAR2(10)   :='';
  BEGIN
  
  
     SELECT DISTINCT STARTDATE, ENDDATE INTO LV_FIN_STARTDATE, LV_FIN_ENDDATE  FROM FINANCIALYEAR
     WHERE YEARCODE = P_YEARCODE;
  
  
  
      SELECT COUNT(*) INTO LV_CNT 
        FROM PISITAXPARAM
        WHERE COMPANYCODE=P_COMPANYCODE
        AND DIVISIONCODE=P_DIVISIONCODE
        AND YEARCODE=P_YEARCODE
        AND NVL(DISPLAYINGRID,'N')<>'N';
--       DBMS_OUTPUT.PUT_LINE('LV_CNT : '||LV_CNT); 
  
      IF LV_CNT>0 THEN
      
       DELETE FROM GTTPISITAXCOMPUTATION ;
       
       LV_SQLSTR:= ' DELETE FROM PISITAXATTRIBUTEVALUE '||CHR(10)
            ||' WHERE COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
            ||' AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
            ||' AND YEARCODE='''||P_YEARCODE||''' '||CHR(10);              
--             IF NVL(P_TOKENNO,'NA')<>'NA' THEN
--                LV_SQLSTR:= LV_SQLSTR ||' AND TOKENNO='''||P_TOKENNO||''' '|| CHR(10);
--             END IF;
     
             EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT;  
             
             --------- FOR YEARMONTH BY SWEETY
              LV_SQLSTR:= ' SELECT MAX(YEARMONTH) FROM PISPAYTRANSACTION  '||CHR(10)
            ||' WHERE COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
            ||' AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
            ||' AND YEARCODE='''||P_YEARCODE||''' '||CHR(10);              
             IF NVL(P_CATEGORY,'NA')<>'NA' THEN
                    LV_SQLSTR:= LV_SQLSTR ||' AND CATEGORYCODE='''||P_CATEGORY||''' '|| CHR(10);
                 END IF;
             IF NVL(P_GRADE,'NA')<>'NA' THEN
                LV_SQLSTR:= LV_SQLSTR ||' AND GRADECODE='''||P_GRADE||''' '|| CHR(10);
             END IF;              
             
               EXECUTE IMMEDIATE LV_SQLSTR INTO LV_YEARMONTH;
             ---------END YEARMONTH
                            
--       DBMS_OUTPUT.PUT_LINE('1_1');                
       ------------ALL-----------------
       
       
      LV_SQLSTR:= ' INSERT INTO GTTPISITAXCOMPUTATION (COMPANYCODE,DIVISIONCODE,YEARCODE,WORKERSERIAL,TOKENNO,COLUMNNO,COMPONENTHEADER, COMPONENTCODE,COMPFORMULA,DISPLAYINGRID, CATEGORYCODE, GRADECODE) '||CHR(10)  
                ||' SELECT DISTINCT A.COMPANYCODE,A.DIVISIONCODE,A.YEARCODE , '||CHR(10)
                ||' B.WORKERSERIAL,B.TOKENNO,A.COLUMNNO,A.COLUMNSUBHEADING ,COLUMNSUBHEADING1,COLUMNFORMULA,DISPLAYINGRID, B.CATEGORYCODE, B.GRADECODE '||CHR(10)
                ||' FROM PISITAXPARAM A ,PISEMPLOYEEMASTER B  '||CHR(10)
                ||' WHERE A.COMPANYCODE=B.COMPANYCODE  '||CHR(10)
                ||' AND A.DIVISIONCODE=B.DIVISIONCODE '||CHR(10)
                ||' AND A.COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
                ||' AND A.DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
                ||' AND A.YEARCODE='''||P_YEARCODE||''' '||CHR(10)
                ||' AND NVL(DISPLAYINGRID,''N'')<>''N'' '||CHR(10);
                --||' and B.WORKERSERIAL IS NOT NULL '||CHR(10);
                 IF NVL(P_CATEGORY,'NA')<>'NA' THEN
                    LV_SQLSTR:= LV_SQLSTR ||' AND B.CATEGORYCODE='''||P_CATEGORY||''' '|| CHR(10);
                 END IF;
                 IF NVL(P_GRADE,'NA')<>'NA' THEN
                    LV_SQLSTR:= LV_SQLSTR ||' AND B.GRADECODE='''||P_GRADE||''' '|| CHR(10);
                 END IF;
                 IF NVL(P_TOKENNO,'NA')<>'NA' THEN
                    LV_SQLSTR:= LV_SQLSTR ||' AND B.TOKENNO = '''||P_TOKENNO||''' '|| CHR(10);
                 END IF;                 
               --  DBMS_OUTPUT.PUT_LINE('ALL : '||LV_SQLSTR);
                 EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT;
                       
--        DBMS_OUTPUT.PUT_LINE('1_2');
            
        FOR T1 IN ( SELECT DISTINCT WORKERSERIAL,TOKENNO FROM GTTPISITAXCOMPUTATION )
        LOOP                
       
          FOR C1 IN ( SELECT DISTINCT COLUMNNO, COLUMNFORMULA ,COLUMNSOURCE,COLUMNATTRIBUTE ,COLUMNBASIS,COLUMNSUBHEADING1 ,COLUMNSUBHEADING2,decode(TRIM(TYPE),'YEARLY',1,'HALF YEARLY',6,'QUATERLY',3,1) TYPE
                    FROM PISITAXPARAM
                    WHERE COMPANYCODE= P_COMPANYCODE
                    AND DIVISIONCODE=P_DIVISIONCODE
                    AND YEARCODE=P_YEARCODE  
                    AND (COLUMNFORMULA IS NOT NULL OR COLUMNSOURCE IS NOT NULL)         
                    ORDER BY COLUMNNO)
             LOOP
              ------------------------ FOR ATTRIBUTE VALUE------------------------- 
                IF NVL(C1.COLUMNSOURCE,'NA')<>'NA' THEN
              
                    LV_SQLSTR:= ' SELECT COUNT(*)  '  ||CHR(10)
                              ||' FROM '||C1.COLUMNSOURCE|| ' '||CHR(10) 
                              ||' WHERE COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
                              ||' AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
                              ||' AND YEARCODE='''||P_YEARCODE||''' '||CHR(10)
                              ||' AND WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10);
--                              DBMS_OUTPUT.PUT_LINE('INSERT ALL ROW : '||LV_SQLSTR); 
                        EXECUTE IMMEDIATE LV_SQLSTR INTO LV_CNT;
                      --  DBMS_OUTPUT.PUT_LINE('2_1 - '||C1.COLUMNNO||' QRY - '||LV_SQLSTR);
                  
                  IF LV_CNT>0 THEN
                    IF  C1.COLUMNSOURCE='PISPAYTRANSACTION' THEN
                        LV_SQLSTR:= 'INSERT INTO PISITAXATTRIBUTEVALUE  '||CHR(10)
                                  ||' (COMPANYCODE, DIVISIONCODE, YEARCODE, COLUMNNO, COLUMNATTRIBUTE, COMPACTUALVALUE,WORKERSERIAL,TOKENNO,YEARMONTH,CATEGORYCODE,GRADECODE) '||CHR(10)
                                  ||' SELECT '''||P_COMPANYCODE||''' COMPANYCODE , '''||P_DIVISIONCODE||''' DIVISIONCODE, '||CHR(10)
                                  ||' '''||P_YEARCODE||''' YEARCODE, '''||C1.COLUMNNO||''' COLUMNNO,'''||C1.COLUMNATTRIBUTE||''' COLUMNATTRIBUTE ,'|| CHR(10)
                                  ||' SUM(COMPACTUALVALUE) COMPACTUALVALUE ,A.WORKERSERIAL ,B.TOKENNO,MAX(A.YEARMONTH) ,'''||P_CATEGORY||''','''||P_GRADE||''' '||CHR(10)
                                  ||' FROM ( '||CHR(10)
                                  ||'         SELECT WORKERSERIAL, SUM('||C1.COLUMNATTRIBUTE||') COMPACTUALVALUE, '''||LV_YEARMONTH||''' YEARMONTH '||CHR(10)
                                  ||'         FROM '||C1.COLUMNSOURCE|| ' '||CHR(10)
                                  ||'         WHERE COMPANYCODE = '''||P_COMPANYCODE||''' '||CHR(10)
                                  ||'           AND YEARCODE = '''||P_YEARCODE||''' '||CHR(10)
                                  ||'           AND WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10)
                                  ||'           GROUP BY WORKERSERIAL  '||CHR(10)
                                  ||'         UNION ALL '||CHR(10)
                                  ||'         SELECT WORKERSERIAL, SUM('||C1.COLUMNATTRIBUTE||') COMPACTUALVALUE ,'''||LV_YEARMONTH||''' YEARMONTH '||CHR(10)
                                  ||'         FROM PISARREARTRANSACTION '||CHR(10)
                                  ||'         WHERE COMPANYCODE = '''||P_COMPANYCODE||''' '||CHR(10)
                                  ||'           AND YEARCODE = '''||P_YEARCODE||''' '||CHR(10)
                                  --CHANGE HERE 07.04.2020
--                                  ||'           AND TRANSACTIONTYPE =''MONTHLYARR'' '||CHR(10)
                                  ||'           AND TRANSACTIONTYPE =''ARREAR'' '||CHR(10)
                                  --end change
                                  ||'           AND WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10)
                                  ||'           GROUP BY WORKERSERIAL  '||CHR(10)
                                  ||'      ) A, PISEMPLOYEEMASTER B' ||CHR(10)
                                  ||' WHERE B.COMPANYCODE = '''||P_COMPANYCODE||''' '||CHR(10)
                                  ||'   AND B.DIVISIONCODE = '''||P_DIVISIONCODE||''' '||CHR(10)
                                  ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
                                  ||' GROUP BY  A.WORKERSERIAL ,B.TOKENNO '||CHR(10);
                                  
                                  EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT; 
                                     
--                        DBMS_OUTPUT.PUT_LINE('2_2 - ' ||LV_SQLSTR ); 
                    
                    -- ADD BY PRASUN ON 14.01.2020
                    ELSIF C1.COLUMNSOURCE='PISBONUSDETAILS' THEN
                            
                        LV_SQLSTR:= 'INSERT INTO PISITAXATTRIBUTEVALUE  '||CHR(10)
                              ||' (COMPANYCODE, DIVISIONCODE, YEARCODE, COLUMNNO, COLUMNATTRIBUTE, COMPACTUALVALUE,WORKERSERIAL,TOKENNO,YEARMONTH,CATEGORYCODE,GRADECODE) '||CHR(10)       
                              ||' SELECT '''||P_COMPANYCODE||''' COMPANYCODE , '''||P_DIVISIONCODE||''' DIVISIONCODE, '||CHR(10)
                              ||' '''||P_YEARCODE||''' YEARCODE, '''||C1.COLUMNNO||''' COLUMNNO,'''||C1.COLUMNATTRIBUTE||''' COLUMNATTRIBUTE ,'|| CHR(10)
                              ||' NVL(SUM('||C1.COLUMNATTRIBUTE||'),0) COMPACTUALVALUE, WORKERSERIAL,TOKENNO, '''||LV_YEARMONTH||''' YEARMONTH ,'''||P_CATEGORY||''','''||P_GRADE||''' '||CHR(10)
                              ||' FROM PISBONUSDETAILS   '|| CHR(10)
                              ||' WHERE TRANSACTIONTYPE = ''BONUS PAYMENT'' '|| CHR(10)
                              ||' AND PAYMENTDATE BETWEEN  '''||LV_FIN_STARTDATE||''' AND '''||LV_FIN_ENDDATE||''' '|| CHR(10);
                           
                              -- DBMS_OUTPUT.PUT_LINE('2_3 ' || LV_SQLSTR);  -------------
                                EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT; 
                                
                                
                    ELSIF C1.COLUMNSOURCE='PISREIMBURSEMENTDETAILS' THEN
                    
                          LV_SQLSTR:= 'INSERT INTO PISITAXATTRIBUTEVALUE  '||CHR(10)
                                  ||' (COMPANYCODE, DIVISIONCODE, YEARCODE, COLUMNNO, COLUMNATTRIBUTE, COMPACTUALVALUE,WORKERSERIAL,TOKENNO,YEARMONTH,CATEGORYCODE,GRADECODE) '||CHR(10)
                                  ||' SELECT '''||P_COMPANYCODE||''' COMPANYCODE , '''||P_DIVISIONCODE||''' DIVISIONCODE, '||CHR(10)
                                  ||' '''||P_YEARCODE||''' YEARCODE, '''||C1.COLUMNNO||''' COLUMNNO,'''||C1.COLUMNATTRIBUTE||''' COLUMNATTRIBUTE ,'|| CHR(10)
                                  ||' NVL(SUM('||C1.COLUMNATTRIBUTE||'),0) COMPACTUALVALUE ,B.WORKERSERIAL ,B.TOKENNO,'''||LV_YEARMONTH||''' YEARMONTH ,'''||P_CATEGORY||''','''||P_GRADE||''' '||CHR(10)
                                  ||' FROM '||C1.COLUMNSOURCE||' A, PISEMPLOYEEMASTER B'||CHR(10) 
                                  ||' WHERE B.COMPANYCODE ='''||P_COMPANYCODE||''' '||CHR(10)
                                  ||' AND A.YEARCODE (+)='''||P_YEARCODE||''' '||CHR(10)
                                  ||' AND B.WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10)
                                  ||' AND B.COMPANYCODE = A.COMPANYCODE (+) AND B.WORKERSERIAL = A.WORKERSERIAL (+) '||CHR(10)
                                  ||' AND A.COMPONENTCODE (+)= '''||C1.COLUMNSUBHEADING1||''' '||CHR(10)
                                  ||' GROUP BY B.WORKERSERIAL, B.TOKENNO '||CHR(10);
                        IF NVL(C1.COLUMNBASIS,'NA')<>'NA' THEN          
                           IF NVL(C1.COLUMNATTRIBUTE,'NA')<> NVL(C1.COLUMNBASIS,'NA') THEN
                                LV_SQLSTR:= LV_SQLSTR ||' AND '||C1.COLUMNBASIS|| '='''||C1.COLUMNSUBHEADING2||''' '|| CHR(10);
                           END IF;
                       END IF;
                     --  DBMS_OUTPUT.PUT_LINE('LV_SQLSTR ' || LV_SQLSTR);  -------------
                        --DBMS_OUTPUT.PUT_LINE('2_4 ' || LV_SQLSTR);  -------------
                       EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT;      
                              
                    --  END  ADD BY PRASUN ON 14.01.2020                                  
                    ELSE
                                                                    
                        LV_SQLSTR:= 'INSERT INTO PISITAXATTRIBUTEVALUE  '||CHR(10)
                                  ||' (COMPANYCODE, DIVISIONCODE, YEARCODE, COLUMNNO, COLUMNATTRIBUTE, COMPACTUALVALUE,WORKERSERIAL,TOKENNO,YEARMONTH,CATEGORYCODE,GRADECODE) '||CHR(10)
                                  ||' SELECT '''||P_COMPANYCODE||''' COMPANYCODE , '''||P_DIVISIONCODE||''' DIVISIONCODE, '||CHR(10)
                                  ||' '''||P_YEARCODE||''' YEARCODE, '''||C1.COLUMNNO||''' COLUMNNO,'''||C1.COLUMNATTRIBUTE||''' COLUMNATTRIBUTE ,'|| CHR(10)
                                  ||' NVL(SUM('||C1.COLUMNATTRIBUTE||'),0) COMPACTUALVALUE ,A.WORKERSERIAL ,B.TOKENNO,'''||LV_YEARMONTH||''' YEARMONTH ,'''||P_CATEGORY||''','''||P_GRADE||''' '||CHR(10)
                                  ||' FROM '||C1.COLUMNSOURCE||' A, PISEMPLOYEEMASTER B'||CHR(10) 
                                  ||' WHERE A.COMPANYCODE (+)='''||P_COMPANYCODE||''' '||CHR(10)
                                  ||' AND A.YEARCODE (+)='''||P_YEARCODE||''' '||CHR(10)
                                  ||' AND B.WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10)
                                  ||' AND B.COMPANYCODE = A.COMPANYCODE AND B.WORKERSERIAL = A.WORKERSERIAL (+) '||CHR(10)
                                  ||' GROUP BY A.WORKERSERIAL, B.TOKENNO '||CHR(10);
                        IF NVL(C1.COLUMNBASIS,'NA')<>'NA' THEN          
                           IF NVL(C1.COLUMNATTRIBUTE,'NA')<> NVL(C1.COLUMNBASIS,'NA') THEN
                                LV_SQLSTR:= LV_SQLSTR ||' AND '||C1.COLUMNBASIS|| '='''||C1.COLUMNSUBHEADING2||''' '|| CHR(10);
                           END IF;
                       END IF;
                     --  DBMS_OUTPUT.PUT_LINE('LV_SQLSTR ' || LV_SQLSTR);  -------------
--                        DBMS_OUTPUT.PUT_LINE('2_4 ' || LV_SQLSTR);  -------------
                       EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT; 
                    END IF;
                     --DBMS_OUTPUT.PUT_LINE('ATTRI INSERT : COL NO. '||C1.COLUMNNO||' -  '||LV_SQLSTR);
                     --EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT;   
                  ELSE
                  /*
                    LV_SQLSTR:= 'INSERT INTO PISITAXATTRIBUTEVALUE  '||CHR(10)
                              ||' (COMPANYCODE, DIVISIONCODE, YEARCODE, COLUMNNO, COLUMNATTRIBUTE, COMPACTUALVALUE,WORKERSERIAL,TOKENNO,YEARMONTH,CATEGORYCODE,GRADECODE) '||CHR(10)
                              ||' SELECT '''||P_COMPANYCODE||''' COMPANYCODE , '''||P_DIVISIONCODE||''' DIVISIONCODE, '||CHR(10)
                              ||' '''||P_YEARCODE||''' YEARCODE, '''||C1.COLUMNNO||''' COLUMNNO,'''||C1.COLUMNATTRIBUTE||''' COLUMNATTRIBUTE ,'|| CHR(10)
                              ||' 0 COMPACTUALVALUE ,WORKERSERIAL ,TOKENNO,MAX(YEARMONTH) ,'''||P_CATEGORY||''','''||P_GRADE||''' '||CHR(10)
                              ||' FROM PISEMPLOYEEMASTER '||CHR(10) 
                              ||' WHERE COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
                              ||' AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
                              ||' AND WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10);  */
                              
                    LV_SQLSTR:= 'INSERT INTO PISITAXATTRIBUTEVALUE  '||CHR(10)
                              ||' (COMPANYCODE, DIVISIONCODE, YEARCODE, COLUMNNO, COLUMNATTRIBUTE, COMPACTUALVALUE,WORKERSERIAL,TOKENNO,YEARMONTH,CATEGORYCODE,GRADECODE) '||CHR(10)
                              ||' SELECT '''||P_COMPANYCODE||''' COMPANYCODE , '''||P_DIVISIONCODE||''' DIVISIONCODE, '||CHR(10)
                              ||' '''||P_YEARCODE||''' YEARCODE, '''||C1.COLUMNNO||''' COLUMNNO,'''||C1.COLUMNATTRIBUTE||''' COLUMNATTRIBUTE ,'|| CHR(10)
                              ||' 0 COMPACTUALVALUE ,A.WORKERSERIAL ,B.TOKENNO,'''||LV_YEARMONTH||''' YEARMONTH ,'''||P_CATEGORY||''','''||P_GRADE||''' '||CHR(10)
                              ||' FROM '||C1.COLUMNSOURCE||' A, PISEMPLOYEEMASTER B  '||CHR(10) 
                              ||' WHERE A.COMPANYCODE (+)= '''||P_COMPANYCODE||''' '||CHR(10)
                              ||' AND A.DIVISIONCODE (+)= '''||P_DIVISIONCODE||''' '||CHR(10)
                              ||' AND A.YEARCODE (+)='''||P_YEARCODE||''' '||CHR(10)
                              ||' AND B.WORKERSERIAL(+) ='''||T1.WORKERSERIAL||''' '||CHR(10)
                              ||' AND B.COMPANYCODE = A.COMPANYCODE (+) AND B.WORKERSERIAL = A.WORKERSERIAL (+)  '||CHR(10)
                              ||' GROUP BY A.WORKERSERIAL, B.TOKENNO      '||CHR(10);                

                   --DBMS_OUTPUT.PUT_LINE('ATTRI INSERT : COL NO. '||C1.COLUMNNO||' -  '||LV_SQLSTR);
--                   DBMS_OUTPUT.PUT_LINE('2_5 ' || LV_SQLSTR);  -------------
                     EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT;  
                  END IF;   
                  --  LV_SQLSTR:= LV_SQLSTR  ||' GROUP BY WORKERSERIAL ,TOKENNO '||CHR(10);
--                 DBMS_OUTPUT.PUT_LINE('ATTRI INSERT : COL NO. '||C1.COLUMNNO||' -  '||LV_SQLSTR);
--                     EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT;   
                                              
                 --COMMENTED BY SWEETY FOR YEAR MONTH
                 ---SELECT MAX(YEARMONTH) INTO LV_YEARMONTH FROM PISITAXATTRIBUTEVALUE;
                -- DBMS_OUTPUT.PUT_LINE('2_5');
                                                   
                --CHANGE 07.04.2020                 
--                 select TRUNC(MONTHS_BETWEEN (TO_DATE('31/03/'||(SUBSTR(LV_YEARMONTH,0,4)+1),'DD/MM/YY'),TO_DATE('01/'||SUBSTR(LV_YEARMONTH,5,2)||SUBSTR(LV_YEARMONTH,0,4) ,'DD/MM/YY')),0)
--                 INTO LV_NOOFMONTH   FROM DUAL;
                  select 
                 TRUNC(MONTHS_BETWEEN (CASE WHEN TO_NUMBER(SUBSTR('202002',5,2)) <=3  THEN TO_DATE('31/03/'||(SUBSTR('202002',0,4)),'DD/MM/YYYY') ELSE TO_DATE('31/03/'||(SUBSTR('202002',0,4)+1),'DD/MM/YYYY') END ,TO_DATE('01/'||SUBSTR('202002',5,2)||SUBSTR('202002',0,4) ,'DD/MM/YY')),0) B
                  INTO LV_NOOFMONTH  FROM DUAL;
                  
                      
                 --DBMS_OUTPUT.PUT_LINE('2_6');              
                 PRC_PISVIEWCREATION (P_COMPANYCODE,P_DIVISIONCODE,'PISASSIGN',0,LV_YEARMONTH,LV_YEARMONTH, 'SALARY', 'PISPAYTRANSACTION_SWT');
                                                             
                                 
                 LV_SQLSTR:= ' SELECT COUNT(*) FROM COLS  '  ||CHR(10)
                           ||' WHERE TABLE_NAME = ''PISASSIGN'' AND COLUMN_NAME='''||C1.COLUMNATTRIBUTE||''' '||CHR(10);
                 EXECUTE IMMEDIATE LV_SQLSTR INTO LV_CNT;                                                                  
--                 DBMS_OUTPUT.PUT_LINE('2_7');            
                   IF LV_CNT> 0 THEN         
                    --CHANGE 07.04.2020                       
--                           LV_SQLSTR:= 'UPDATE  PISITAXATTRIBUTEVALUE SET COMPPROJCTEDVALUE = COMPACTUALVALUE + '||CHR(10)
                    LV_SQLSTR:= 'UPDATE  PISITAXATTRIBUTEVALUE SET COMPPROJCTEDVALUE =  '||CHR(10)
                    --End CHANGE 07.04.2020           
                           ||'  ( SELECT SUM('||C1.COLUMNATTRIBUTE||'  * '||LV_NOOFMONTH||')  FROM PISASSIGN A ,PISEMPLOYEEMASTER B   '||CHR(10)
                           ||'        WHERE A.COMPANYCODE=B.COMPANYCODE  '||CHR(10)
                           ||'        AND A.DIVISIONCODE=B.DIVISIONCODE '||CHR(10)
                           ||'        AND A.WORKERSERIAL =B.WORKERSERIAL '||CHR(10)
                           ||'        AND A.COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
                           ||'        AND A.DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
                           ||'        AND A.WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10)
                           ||'        AND B.EMPLOYEESTATUS=''ACTIVE'')'||CHR(10)
                           ||' WHERE COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
                           ||' AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
                           ||' AND YEARCODE='''||P_YEARCODE||''' '||CHR(10)
                           ||' AND COLUMNATTRIBUTE='''||C1.COLUMNATTRIBUTE||''' ' ||CHR(10)
                           ||' AND WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10);   
--                               DBMS_OUTPUT.PUT_LINE('SEEE : '||LV_SQLSTR); 
                           EXECUTE IMMEDIATE LV_SQLSTR ;                                    
                   ELSE
                           
                        IF NVL(C1.COLUMNSOURCE,'NA')='PISPAYTRANSACTION' THEN 
                            LV_SQLSTR:= 'UPDATE  PISITAXATTRIBUTEVALUE SET COMPPROJCTEDVALUE =  '||CHR(10)
                           ||'  ( SELECT (SUM('||C1.COLUMNATTRIBUTE||' * '||LV_NOOFMONTH||')/ '||C1.TYPE||') FROM '||C1.COLUMNSOURCE||' A ,PISEMPLOYEEMASTER B '||CHR(10)
                             ||'        WHERE A.COMPANYCODE=B.COMPANYCODE  '||CHR(10)
                           ||'        AND A.DIVISIONCODE=B.DIVISIONCODE '||CHR(10)
                           ||'        AND A.WORKERSERIAL =B.WORKERSERIAL '||CHR(10)
                           ||'        AND A.COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
                           ||'        AND A.DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
                           ||'        AND A.WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10)
                           ||'        AND B.EMPLOYEESTATUS=''ACTIVE'' '||CHR(10);
--                           ||'        WHERE COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
--                           ||'        AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
--                           ||'       AND WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10);
                           IF C1.COLUMNSOURCE='PISCOMPONENTASSIGNMENT' THEN
                               LV_SQLSTR:= LV_SQLSTR  ||' AND TRANSACTIONTYPE=''ASSIGNMENT'' '|| CHR(10);
                           END IF;
                            LV_SQLSTR:= LV_SQLSTR||'       ) '||CHR(10)
                           ||' WHERE COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
                           ||' AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
                           ||' AND YEARCODE='''||P_YEARCODE||''' '||CHR(10)
                           ||' AND COLUMNATTRIBUTE='''||C1.COLUMNATTRIBUTE||''' ' ||CHR(10)
                           ||' AND WORKERSERIAL ='''||T1.WORKERSERIAL||''' '||CHR(10);   
--                               DBMS_OUTPUT.PUT_LINE('SEEE : '||LV_SQLSTR); 
                               EXECUTE IMMEDIATE LV_SQLSTR ;         
                      END IF;  
                    END IF;  
                                                                                           
                             
                ELSE
                    LV_SQLSTR:= 'INSERT INTO PISITAXATTRIBUTEVALUE  '||CHR(10)
                          ||' (COMPANYCODE, DIVISIONCODE, YEARCODE, COLUMNNO, COLUMNATTRIBUTE, COMPACTUALVALUE,WORKERSERIAL,TOKENNO,YEARMONTH,CATEGORYCODE,GRADECODE) '||CHR(10)
                          ||' SELECT '''||P_COMPANYCODE||''' COMPANYCODE , '''||P_DIVISIONCODE||''' DIVISIONCODE, '||CHR(10)
                          ||' '''||P_YEARCODE||''' YEARCODE, '''||C1.COLUMNNO||''' COLUMNNO,'''||C1.COLUMNATTRIBUTE||''' COLUMNATTRIBUTE ,'|| CHR(10)
                          ||' 0 COMPACTUALVALUE ,'''||T1.WORKERSERIAL||'''  ,'''||T1.TOKENNO||''' ,NULL ,'''||P_CATEGORY||''','''||P_GRADE||''' '||CHR(10)
                          ||' FROM DUAL '||CHR(10);
                        --   DBMS_OUTPUT.PUT_LINE('2_6 : '||LV_SQLSTR);
                         EXECUTE IMMEDIATE LV_SQLSTR ;COMMIT;   
                                                    
                   END IF;      
                                
--                DBMS_OUTPUT.PUT_LINE('2_8'); 
                UPDATE PISITAXATTRIBUTEVALUE SET COMPMANUALVALUE=COMPPROJCTEDVALUE; 
                COMMIT;       
                
                --DBMS_OUTPUT.PUT_LINE('COLUMNSUBHEADING1 '||C1.COLUMNSUBHEADING1);
--                DBMS_OUTPUT.PUT_LINE('COLUMNFORMULA '||C1.COLUMNFORMULA);
              
              
               -- START ADDED BY PRASUN ON 13.01.2020
               
               IF  C1.COLUMNSOURCE <> 'PISPAYTRANSACTION' THEN
                       
                   LV_SQLSTR:= ' UPDATE PISITAXATTRIBUTEVALUE A ' || CHR(10)
                   ||' SET A.COMPPROJCTEDVALUE = A.COMPACTUALVALUE, A.COMPMANUALVALUE = A.COMPACTUALVALUE ' ||CHR(10)
                   ||' WHERE COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
                   ||' AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
                   ||' AND YEARCODE='''||P_YEARCODE||''' '||CHR(10)
                   ||' AND COLUMNATTRIBUTE='''||C1.COLUMNATTRIBUTE||''' ' ||CHR(10);
                   --||' AND A.WORKERSERIAL = (SELECT WORKERSERIAL FROM PISEMPLOYEEMASTER WHERE WORKERSERIAL = '''||T1.WORKERSERIAL||'''  AND EMPLOYEESTATUS = ''Y''  ) ' ||CHR(10);
                        
--                     DBMS_OUTPUT.PUT_LINE('LV_SQLSTR ' || LV_SQLSTR);              
                     EXECUTE IMMEDIATE LV_SQLSTR;COMMIT; 
                       
                END IF;  
                     
              --  END ADDED BY PRASUN ON 13.01.2020  
              
                
                
               IF NVL(C1.COLUMNFORMULA,'NA')<>'NA' THEN     
--                             DBMS_OUTPUT.PUT_LINE('FUNCTION C1.COLUMNNO '||C1.COLUMNNO||' C1.COLUMNFORMULA '||C1.COLUMNFORMULA);
--                    DBMS_OUTPUT.PUT_LINE('2_8_1 - '||C1.COLUMNNO||', '||C1.COLUMNFORMULA);
                    LV_ACTLY:=round(nvl(fn_get_itax_calc_value(P_COMPANYCODE ,P_DIVISIONCODE,C1.COLUMNNO,C1.COLUMNFORMULA,'ACTUAL'),0),2);
--                    DBMS_OUTPUT.PUT_LINE('2_8_2');
                    
                   
                   
                    LV_PRJCT:=round(nvl(fn_get_itax_calc_value(P_COMPANYCODE ,P_DIVISIONCODE,C1.COLUMNNO,C1.COLUMNFORMULA,'PROJECTED'),0),2)  ;  
                    
                    
--                    IF C1.COLUMNNO = '01_02_99' THEN
--                        
--                        DBMS_OUTPUT.PUT_LINE('C1.COLUMNFORMULA '||C1.COLUMNFORMULA);
--                        --DBMS_OUTPUT.PUT_LINE('LV_PRJCT '||LV_PRJCT);
--                    END IF;
                    
                                         
--                    DBMS_OUTPUT.PUT_LINE('2_8_3');  
                  
                  -- START ADDED BY PRASUN ON 14.01.2020 TO AVOID DUPLICATION
                  
                   LV_SQLSTR:= 'DELETE FROM PISITAXATTRIBUTEVALUE '||CHR(10)
                              ||'WHERE COMPANYCODE = '''||P_COMPANYCODE||'''   '||CHR(10)
                              ||'AND DIVISIONCODE = '''||P_DIVISIONCODE||''' '||CHR(10)
                              ||'AND YEARCODE = '''||P_YEARCODE||''' '||CHR(10)
                              ||'AND WORKERSERIAL = '''||T1.WORKERSERIAL||''' '||CHR(10)
                              ||'AND COLUMNNO = '''||C1.COLUMNNO||'''  '||CHR(10);
                           
                    EXECUTE IMMEDIATE LV_SQLSTR;           
                  
                  --  END ADDED BY PRASUN ON 14.01.2020  
                             
                    LV_SQLSTR:= 'INSERT INTO PISITAXATTRIBUTEVALUE  '||CHR(10)
                             ||' (COMPANYCODE, DIVISIONCODE, YEARCODE, COLUMNNO ,WORKERSERIAL,TOKENNO,CATEGORYCODE,GRADECODE ,'||CHR(10)
                             ||' COMPACTUALVALUE,COMPPROJCTEDVALUE,COMPMANUALVALUE ) '||CHR(10)
                             ||' SELECT '''||P_COMPANYCODE||''' COMPANYCODE , '''||P_DIVISIONCODE||''' DIVISIONCODE, '||CHR(10)
                             ||' '''||P_YEARCODE||''' YEARCODE, '''||C1.COLUMNNO||''' COLUMNNO,'''||T1.WORKERSERIAL||''' ,'||CHR(10)
                             ||' '''||T1.TOKENNO||''' ,'''||P_CATEGORY||''','''||P_GRADE||''' , '||CHR(10)
                             ||' '||LV_ACTLY||'  COMPACTUALVALUE, '||CHR(10) 
                             ||' '||LV_PRJCT||' COMPPROJCTEDVALUE, '||CHR(10)
                             ||' '||LV_PRJCT||' COMPMANUALVALUE '||CHR(10)
                             ||' FROM DUAL '||CHR(10);  
    --                              DBMS_OUTPUT.PUT_LINE('LV_SQLSTR: '||LV_SQLSTR);          
--                 DBMS_OUTPUT.PUT_LINE('2_7 : '||LV_SQLSTR);    
                   EXECUTE IMMEDIATE LV_SQLSTR;COMMIT;                         
               END IF;
               
             END LOOP;         
--              DBMS_OUTPUT.PUT_LINE('LV_CNT: '||LV_CNT); 
              --  IF LV_CNT>0 THEN
                        
        END LOOP;
        
     FOR T2 IN  ( SELECT WORKERSERIAL,COLUMNNO
                        FROM GTTPISITAXCOMPUTATION
                        WHERE COMPANYCODE= P_COMPANYCODE
                        AND DIVISIONCODE=P_DIVISIONCODE
                        AND YEARCODE=P_YEARCODE   )
      LOOP
       -- DBMS_OUTPUT.PUT_LINE('T2.COLUMNNO '||T2.COLUMNNO||'T2.WORKERSERIAL '||T2.WORKERSERIAL);
        UPDATE GTTPISITAXCOMPUTATION  SET 
         (COMPACTUALVALUE,COMPPROJCTEDVALUE,COMPMANUALVALUE)=
         (select distinct sum(COMPACTUALVALUE),sum(COMPPROJCTEDVALUE),sum(COMPMANUALVALUE)
         FROM PISITAXATTRIBUTEVALUE 
         WHERE COMPANYCODE=P_COMPANYCODE
         AND DIVISIONCODE=P_DIVISIONCODE
         and YEARCODE=P_YEARCODE
         AND COLUMNNO=T2.COLUMNNO
         AND WORKERSERIAL=T2.WORKERSERIAL
         group by WORKERSERIAL,COLUMNNO )
         WHERE COMPANYCODE=P_COMPANYCODE
         AND DIVISIONCODE=P_DIVISIONCODE
         and YEARCODE=P_YEARCODE
         AND COLUMNNO=T2.COLUMNNO
         AND WORKERSERIAL=T2.WORKERSERIAL; 
      END LOOP;
--        

        
--        DBMS_OUTPUT.PUT_LINE('AWT: '); 
--        UPDATE GTTPISITAXCOMPUTATION A SET 
--         (A.COMPACTUALVALUE,A.COMPPROJCTEDVALUE,A.COMPMANUALVALUE)=
--         (SELECT B.COMPACTUALVALUE,B.COMPPROJCTEDVALUE,B.COMPMANUALVALUE
--         FROM PISITAXATTRIBUTEVALUE B
--         WHERE A.COMPANYCODE=B.COMPANYCODE
--         AND A.DIVISIONCODE=B.DIVISIONCODE
--         AND A.COLUMNNO=B.COLUMNNO );
--        DBMS_OUTPUT.PUT_LINE('CIII ');
        commit;
    END IF;       
        
    
  END;
/


DROP PROCEDURE PROC_PISLEAVEMASTER;

CREATE OR REPLACE procedure proc_pisleavemaster
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_leavecode varchar2
    )
as 
    lv_sqlstr           varchar2(4000);
begin
    delete from GTT_PISLEAVEMASTER;
    
                    lv_sqlstr :=    'insert into GTT_PISLEAVEMASTER'|| chr(10)
                    || ' select a.companycode,a.divisioncode,leavecode,leavedesc,leavecf,leaveencash,leaveindex,leaveentitlementapplicable,withoutpayleave,includenightshift, '|| chr(10)
                    || ' companyname,companyaddress, companyaddress1,companyaddress2,companyaddress3,companycity,companystate,companycountry '|| chr(10)
                    || ' from pisleavemaster a, companymast c  '|| chr(10)
                    || ' where a.companycode='''|| p_companycode ||''' '|| chr(10)
                    || '   and a.divisioncode='''||p_divisioncode||'''  '|| chr(10)
                    || '   and a.companycode=c.companycode  '|| chr(10);
                      if p_leavecode is not null then
                      lv_sqlstr := lv_sqlstr || '   and leavecode in ('|| p_leavecode ||')' || chr(10);
                      end if;
                    lv_sqlstr := lv_sqlstr || '    order by leavecode,leavedesc '|| chr(10);
    execute immediate lv_sqlstr;
end;
/


DROP PROCEDURE PROC_PISLEAVEREGISTER;

CREATE OR REPLACE PROCEDURE proc_PISLeaveRegister
(
p_companycode VARCHAR2, 
p_divisioncode VARCHAR2,
p_yearcode VARCHAR2, 
p_fromdt VARCHAR2,
p_todt VARCHAR2,
p_Category VARCHAR2 DEFAULT NULL,
p_Grade VARCHAR2  DEFAULT NULL,
p_Employee VARCHAR2  DEFAULT NULL
)
AS 
lv_sqlstr VARCHAR2(30000);
begin
    delete from GTT_PISLEAVEREGISTER;
    
    lv_sqlstr :=  'INSERT INTO GTT_PISLEAVEREGISTER '|| chr(10) 
                ||' SELECT E.COMPANYNAME,A.COMPANYCODE,A.CATEGORYCODE, A.GRADECODE,D.TOKENNO  EMPLOYEECODE,D.EMPLOYEENAME,A.LEAVECODE,A.LEAVEAPPLIEDON, '|| chr(10) 
                ||'        APPLIED_FORM,APPLIED_TO,APPLIED_DAYS,SANCTIONED_FORM,SANCTIONED_TO,SANCTIONED_DAYS,LEAVESANCTIONREMARKS, '|| chr(10) 
                ||'        OPENING, ENTITLED, (OPENING+ENTITLED) TOTAL_AVL, '|| chr(10) 
                ||'        '''||p_fromdt||'''||'' to ''||'''||p_todt||''' PRINTDATE , '|| chr(10) 
                ||'        NULL EX1 ,NULL EX2 ,NULL EX3 ,NULL EX4 ,NULL EX5 '|| chr(10) 
                ||'   FROM  '|| chr(10) 
                ||'        ( '|| chr(10) 
                ||'         SELECT COMPANYCODE,CATEGORYCODE, GRADECODE,WORKERSERIAL,LEAVECODE,LEAVEAPPLIEDON, '|| chr(10) 
                ||'                MIN(LEAVEDATE) APPLIED_FORM, MAX(LEAVEDATE) APPLIED_TO, SUM(LEAVEDAYS) APPLIED_DAYS '|| chr(10) 
                ||'           FROM PISLEAVEAPPLICATION '|| chr(10) 
                ||'          WHERE COMPANYCODE = '''||p_companycode||'''  '|| chr(10) 
                ||'            AND DIVISIONCODE = '''||p_divisioncode||''' '|| chr(10) 
                ||'            AND YEARCODE = '''||p_yearcode||''' '|| chr(10) 
                ||'          GROUP BY COMPANYCODE,CATEGORYCODE, GRADECODE,WORKERSERIAL,LEAVECODE,LEAVEAPPLIEDON '|| chr(10) 
                ||'        ) A, '|| chr(10) 
                ||'        ( '|| chr(10) 
                ||'         SELECT COMPANYCODE,CATEGORYCODE, GRADECODE,WORKERSERIAL,LEAVECODE,LEAVEAPPLIEDON, '|| chr(10) 
                ||'                SUM(LEAVEDAYS) SANCTIONED_DAYS,MIN(LEAVEDATE) SANCTIONED_FORM, MAX(LEAVEDATE) SANCTIONED_TO,LEAVESANCTIONREMARKS '|| chr(10) 
                ||'           FROM PISLEAVEAPPLICATION '|| chr(10) 
                ||'          WHERE LEAVESANCTIONEDON IS NOT NULL '|| chr(10) 
                ||'            AND COMPANYCODE = '''||p_companycode||'''  '|| chr(10) 
                ||'            AND DIVISIONCODE = '''||p_divisioncode||''' '|| chr(10) 
                ||'            AND YEARCODE = '''||p_yearcode||''' '|| chr(10) 
                ||'          GROUP BY COMPANYCODE,CATEGORYCODE, GRADECODE,WORKERSERIAL,LEAVECODE,LEAVEAPPLIEDON,LEAVESANCTIONREMARKS '|| chr(10) 
                ||'        ) B, '|| chr(10) 
                ||'        ( '|| chr(10) 
                ||'         SELECT COMPANYCODE, CATEGORYCODE, GRADECODE,WORKERSERIAL, LEAVECODE, SUM(OPENING) OPENING, SUM(ENTITLED) ENTITLED '|| chr(10) 
                ||'           FROM ( '|| chr(10) 
                ||'                 SELECT COMPANYCODE,CATEGORYCODE, GRADECODE,WORKERSERIAL, LEAVECODE,NULL DOCUMENTNO, NOOFDAYS OPENING, 0 ENTITLED, 0 AVAIL '|| chr(10) 
                ||'                   FROM PISLEAVETRANSACTION  '|| chr(10) 
                ||'                  WHERE COMPANYCODE = '''||p_companycode||'''  '|| chr(10) 
                ||'                    AND DIVISIONCODE = '''||p_divisioncode||''' '|| chr(10) 
                ||'                    AND YEARCODE = '''||p_yearcode||''' '|| chr(10) 
                ||'                    AND TRANSACTIONTYPE=''BF'' '|| chr(10) 
                ||'                 UNION ALL '|| chr(10) 
                ||'                 SELECT COMPANYCODE,CATEGORYCODE, GRADECODE,WORKERSERIAL, LEAVECODE,NULL DOCUMENTNO, SUM(NOOFDAYS) OPENING, 0 ENTITLED, 0 AVAIL '|| chr(10) 
                ||'                   FROM PISLEAVETRANSACTION  '|| chr(10) 
                ||'                  WHERE COMPANYCODE = '''||p_companycode||'''  '|| chr(10) 
                ||'                    AND DIVISIONCODE = '''||p_divisioncode||''' '|| chr(10) 
                ||'                    AND YEARCODE = '''||p_yearcode||''' '|| chr(10) 
                ||'                    AND YEARMONTH < TO_CHAR(TO_DATE('''||p_fromdt||''',''DD/MM/YYYY''),''YYYYMM'') '|| chr(10) 
                ||'                    AND TRANSACTIONTYPE = ''ENTITLED'' '|| chr(10) 
                ||'                  GROUP BY COMPANYCODE,CATEGORYCODE, GRADECODE,WORKERSERIAL, LEAVECODE '|| chr(10) 
                ||'                 UNION ALL  '|| chr(10) 
                ||'                 SELECT COMPANYCODE,CATEGORYCODE, GRADECODE,WORKERSERIAL, LEAVECODE,NULL DOCUMENTNO, -1*SUM(LEAVEDAYS) OPENING, 0 ENTITLED, 0 AVAIL  '|| chr(10) 
                ||'                   FROM PISLEAVEAPPLICATION  '|| chr(10) 
                ||'                  WHERE COMPANYCODE = '''||p_companycode||'''   '|| chr(10) 
                ||'                    AND DIVISIONCODE = '''||p_divisioncode||'''  '|| chr(10) 
                ||'                    AND YEARCODE = '''||p_yearcode||'''  '|| chr(10) 
                ||'                    AND LEAVEDATE < TO_DATE('''||p_fromdt||''',''DD/MM/YYYY'')  '|| chr(10) 
                ||'                  GROUP BY COMPANYCODE,CATEGORYCODE, GRADECODE,WORKERSERIAL, LEAVECODE  '|| chr(10) 
                ||'                 UNION ALL  '|| chr(10) 
                ||'                 SELECT COMPANYCODE,CATEGORYCODE, GRADECODE,WORKERSERIAL, LEAVECODE,NULL DOCUMENTNO, 0 OPENING, SUM(NOOFDAYS) ENTITLED, 0 AVAIL  '|| chr(10) 
                ||'                   FROM PISLEAVETRANSACTION   '|| chr(10) 
                ||'                  WHERE COMPANYCODE = '''||p_companycode||'''   '|| chr(10) 
                ||'                    AND DIVISIONCODE = '''||p_divisioncode||'''  '|| chr(10) 
                ||'                    AND YEARCODE = '''||p_yearcode||'''  '|| chr(10) 
                ||'                    AND YEARMONTH >= TO_CHAR(TO_DATE('''||p_fromdt||''',''DD/MM/YYYY''),''YYYYMM'') AND YEARMONTH <= TO_CHAR(TO_DATE('''||p_fromdt||''',''DD/MM/YYYY''),''YYYYMM'')  '|| chr(10) 
                ||'                    AND TRANSACTIONTYPE = ''ENTITLED''  '|| chr(10) 
                ||'                  GROUP BY COMPANYCODE,CATEGORYCODE, GRADECODE,WORKERSERIAL, LEAVECODE  '|| chr(10) 
                ||'                 )  '|| chr(10) 
                ||'           GROUP BY  COMPANYCODE,CATEGORYCODE, GRADECODE,WORKERSERIAL, LEAVECODE  '|| chr(10) 
                ||'       ) C, PISEMPLOYEEMASTER D, COMPANYMAST E  '|| chr(10) 
                ||' WHERE  1=1  '|| chr(10) 
                ||'   AND A.CATEGORYCODE=B.CATEGORYCODE  '|| chr(10) 
                ||'   AND A.GRADECODE=B.GRADECODE  '|| chr(10) 
                ||'   AND A.WORKERSERIAL=B.WORKERSERIAL  '|| chr(10) 
                ||'   AND A.LEAVECODE=B.LEAVECODE  '|| chr(10) 
                ||'   AND A.LEAVEAPPLIEDON=B.LEAVEAPPLIEDON  '|| chr(10) 
                ||'   AND A.CATEGORYCODE=C.CATEGORYCODE(+)  '|| chr(10) 
                ||'   AND A.GRADECODE=C.GRADECODE(+)  '|| chr(10) 
                ||'   AND A.WORKERSERIAL=C.WORKERSERIAL(+)  '|| chr(10) 
                ||'   AND A.LEAVECODE=C.LEAVECODE(+)  '|| chr(10) 
                ||'   AND A.COMPANYCODE=D.COMPANYCODE  '|| chr(10) 
                ||'   AND A.WORKERSERIAL=D.WORKERSERIAL  '|| chr(10) 
                ||'   AND A.COMPANYCODE=E.COMPANYCODE  '|| chr(10) 
                ||'   AND A.LEAVEAPPLIEDON BETWEEN TO_DATE('''||p_fromdt||''',''DD/MM/YYYY'') AND TO_DATE('''||p_todt||''',''DD/MM/YYYY'')  '|| chr(10); 
                if p_Category is not null then
                    lv_sqlstr := lv_sqlstr ||'   AND A.CATEGORYCODE IN ( '''||p_Category||''')  '||chr(10);
                end if;  
                if p_Grade is not null then
                    lv_sqlstr := lv_sqlstr ||'   AND A.GRADECODE IN ( '''||p_Grade||''')  '||chr(10);
                end if; 
                if p_Employee is not null then
                    lv_sqlstr := lv_sqlstr ||'   AND A.WORKERSERIAL IN ( '''||p_Employee||''')  '||chr(10);
                end if; 
                lv_sqlstr := lv_sqlstr ||'   ORDER BY D.TOKENNO, LEAVECODE,TO_CHAR(LEAVEAPPLIEDON,''DD/MM/YYYY'')  '|| chr(10) ;
 
     -- dbms_output.put_line(lv_sqlstr);
     execute  immediate lv_sqlstr;
     
end;
/


DROP PROCEDURE PROC_PISLOANMASTER;

CREATE OR REPLACE procedure proc_pisloanmaster
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_loancode varchar2
    )
as 
    lv_sqlstr           varchar2(4000);
begin
    delete from GTT_PISLOANMASTER;
    
                    lv_sqlstr :=    'insert into GTT_PISLOANMASTER'|| chr(10)
                    || ' select a.companycode,a.divisioncode,loancode,loandesc,loancf,loanindex,refundtype,againstcomponent,ratiopercent,remarks,witheffectfrom,regulardeduction, '|| chr(10)
                    || ' companyname,companyaddress, companyaddress1,companyaddress2,companyaddress3,companycity,companystate,companycountry '|| chr(10)
                    || ' from pisloanmaster a, companymast c  '|| chr(10)
                    || ' where a.companycode='''|| p_companycode ||''' '|| chr(10)
                    || '   and a.divisioncode='''||p_divisioncode||'''  '|| chr(10)
                    || '   and a.companycode=c.companycode  '|| chr(10);
                      if p_loancode is not null then
                      lv_sqlstr := lv_sqlstr || '   and loancode in ('|| p_loancode ||')' || chr(10);
                      end if;
                    lv_sqlstr := lv_sqlstr || '    order by loancode,loandesc '|| chr(10);
    execute immediate lv_sqlstr;
end;
/


DROP PROCEDURE PROC_PISVIEWCREATION;

CREATE OR REPLACE PROCEDURE               PROC_PISVIEWCREATION ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_ViewName Varchar2,
                                                  P_Phase Number,
                                                  P_YEARMONTH Varchar2,
                                                  P_ARRYEARMONTH Varchar2,
                                                  P_MODULE Varchar2,
                                                  P_TABLENAME Varchar2,
                                                  P_TRANSACTIONTYPE Varchar2 DEFAULT NULL)
as 
------ in this procedure we are FOLLOW TABLE NAME WITH ALIAS NAME ( WHEN USER MULTIPLE TABLE NAME IN A SINGLE QUERY) AS FOLLOWING
------ PISEMPLOYEEMASTER  => M
------ PISCOMPONENTMASTER => C
------ PISCOMPONENTASSIGNMENT => R
------ PISMONTHATTENDANCE => A 
------ PISPAYTRANSACTION = T
lv_fn_stdt DATE := TO_DATE('01/'||substr(P_YEARMONTH,5,2)||'/'||substr(P_YEARMONTH,1,4),'DD/MM/YYYY');
lv_fn_endt DATE;
lv_TableName        varchar2(50) := 'PISPAYTRANSACTION';
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_CompMast_Rec     WPSCOMPONENTMASTER%ROWTYPE;
lv_AttnComponent    varchar2(4000) := '';
lv_MastComponent    varchar2(4000) := ''; 
lv_CompWithZero     varchar2(1000) := '';
lv_CompWithValue    varchar2(4000) := '';
lv_CompCol          varchar2(1000) := '';
lv_SQLCompView      varchar2(4000) := '';
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_PhaseTableName   varchar2(25);
lv_YYYYMM           varchar2(10)  := '';  
begin
    
    if P_YEARMONTH = P_ARRYEARMONTH then
        lv_YYYYMM := P_YEARMONTH;
    else
        lv_YYYYMM := P_ARRYEARMONTH;
    end if;    
    SELECT ADD_MONTHS(lv_fn_stdt,1)-1 INTO lv_fn_endt FROM DUAL;
    lv_parvalues := 'VIEWNAME = '||P_ViewName||', YEARMONTH = '||P_YEARMONTH;
    --DBMS_OUTPUT.PUT_LINE('View Name: '||lv_parvalues||' XXX '||NVL(P_ViewName,'YYYY'));
    FOR C1 IN (
            SELECT C.COMPONENTCODE, C.COMPONENTSHORTNAME, C.COMPONENTDESC, NVL(C.COMPONENTTYPE,'OTHERS') COMPONENTTYPE, NVL(C.COMPONENTGROUP,'N') COMPONENTGROUP, C.PHASE, C.PAYFORMULA, C.CALCULATIONINDEX,
            C.DEPENDENCYTYPE, C.ROUNDOFFTYPE, C.ROUNDOFFRS, C.INCLUDEPAYROLL, C.INCLUDEARREAR, C.USERENTRYAPPLICABLE, C.ATTENDANCEENTRYAPPLICABLE, C.LIMITAPPLICABLE, 
            C.ROLLOVERAPPLICABLE, C.SLABAPPLICABLE, C.MISCPAYMENT, C.FINALSETTLEMENT
            FROM PISCOMPONENTMASTER C 
            WHERE C.COMPANYCODE = P_COMPCODE AND C.DIVISIONCODE = P_DIVCODE
              AND YEARMONTH = ( SELECT MAX(YEARMONTH) FROM PISCOMPONENTMASTER
                                WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                                  AND YEARMONTH <= lv_YYYYMM
                              )  
            AND NVL(INCLUDEPAYROLL,'N') = 'Y' 
        ) 
    loop
       DBMS_OUTPUT.PUT_LINE('COMPONENT : '||c1.COMPONENTCODE);
        --- FOR COMPONENT ASSIGNMENT TABLE WHERE DEFINED ROLLOVER COMPONENT 
        if c1.INCLUDEPAYROLL = 'Y' AND nvl(c1.ROLLOVERAPPLICABLE,'N') = 'Y' THEN
            if lv_MastComponent = '' then
                lv_MastComponent:= ', nvl(R.'||c1.COMPONENTCODE||',0) AS '|| c1.COMPONENTCODE;          -- R for PISCOMPONENTASSIGNMENT
            else 
                lv_MastComponent:= lv_MastComponent ||', nvl(R.'||c1.COMPONENTCODE||',0) AS '|| c1.COMPONENTCODE;          -- R for PISCOMPONENTASSIGNMENT
            end if;
        end if;
        -- FOR ATTENDANCE ENTRY APPLICABLE COLUMN IN ATTENDANCE VIEW
        if NVL(c1.ATTENDANCEENTRYAPPLICABLE,'N') = 'Y' then
            if lv_AttnComponent = '' then
                lv_AttnComponent := ', nvl(R.'||c1.COMPONENTCODE||',0) AS '|| c1.COMPONENTCODE;          -- R for PISCOMPONENTASSIGNMENT , ATTENDANCEENTRY COMPONENT COMPONENT ASSIGNMENT TABLE
            else
                lv_AttnComponent := lv_AttnComponent||', nvl(R.'||c1.COMPONENTCODE||',0) AS '|| c1.COMPONENTCODE;          -- R for PISCOMPONENTASSIGNMENT , ATTENDANCEENTRY COMPONENT COMPONENT ASSIGNMENT TABLE            
            end if;
        end if;
        lv_CompWithValue := lv_CompWithValue ||', SUM(NVL(T.'||c1.COMPONENTCODE||',0)) AS '|| c1.COMPONENTCODE;          -- T for PISPAYTRANSACTION
                
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('COMPONENT WITH VALUE : '||lv_CompWithValue);
    
    if P_ViewName = 'PMAST' OR NVL(P_ViewName,'ALL') = 'ALL' then
        lv_SqlStr := ' CREATE OR REPLACE VIEW PMAST  '||CHR(10)
                   ||' AS '||CHR(10)
                   ||' SELECT M.COMPANYCODE, M.DIVISIONCODE, M.WORKERSERIAL, M.TOKENNO, M.EMPLOYEENAME, M.ATTNIDENTIFICATION, M.CATEGORYCODE, M.GRADECODE, M.DEPARTMENTCODE,' ||CHR(10)
                   ||' M.DESIGNATIONCODE, M.PFCODE, M.PFNO, M.SEX, M.MARRIED, M.EMPLOYEESTATUS, M.DATEOFBIRTH, M.DATEOFJOIN, M.DATEOFCONFIRMATION, M.PFENTITLEDATE, '||CHR(10)
                   ||' M.STATUSDATE, M.DATEOFRETIRE, M.EXTENDEDRETIREDATE, M.BANKCODE, M.BANKACCNUMBER, M.CHEQUECASH, M.QUARTERALLOTED, M.QUARTERNO, M.PAYMENTSTATUS '||CHR(10)
                   ||' '||lv_MastComponent||' ' ||CHR(10)
                   ||' FROM PISEMPLOYEEMASTER M, '||CHR(10)
                   ||' ( '||CHR(10)
                   ||'   SELECT * FROM PISCOMPONENTASSIGNMENT '||CHR(10) 
                   ||'   WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                   ||'   AND WORKERSERIAL||YEARMONTH IN ( SELECT WORKERSERIAL||MAX(YEARMONTH) '||CHR(10)
                   ||'                                      FROM PISCOMPONENTASSIGNMENT '||CHR(10) 
                   ||'                                     WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                   ||'                                       AND YEARMONTH <= TO_NUMBER('''||lv_YYYYMM||''') '||CHR(10)
                   ||'                                    GROUP BY WORKERSERIAL '||CHR(10)
                   ||'                                  ) '||CHR(10)
                   ||' )  R '||CHR(10)                               
                   ||' WHERE M.COMPANYCODE = '''||P_COMPCODE||''' AND M.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
                   ||'   AND M.WORKERSERIAL = R.WORKERSERIAL (+)  '||CHR(10);    
       EXECUTE IMMEDIATE lv_SqlStr;
       insert into PIS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_PISVIEWCREATION',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, 'PMAST');
       COMMIT;
    END IF;   
    
    IF P_ViewName  = 'PATTN' OR NVL(P_ViewName,'ALL') = 'ALL' then
        lv_SqlStr := ' CREATE OR REPLACE VIEW PATTN '||CHR(10)
                   ||' AS  '||CHR(10)
                   ||' SELECT WORKERSERIAL, TOKENNO, YEARMONTH, UNITCODE, CATEGORYCODE, GRADECODE,  '||CHR(10)
                   ||' NVL(PRESENTDAYS,0) PRESENTDAYS, NVL(ADJUSTMENTDAYS,0) ADJUSTMENTDAYS, NVL(LEAVEDAYS,0) LEAVEDAYS,  '||CHR(10)
                   ||' NVL(HOLIDAYS,0) HOLIDAYS, NVL(WITHOUTPAYDAYS,0) WITHOUTPAYDAYS, NVL(SALARYDAYS,0) SALARYDAYS,  '||CHR(10)
                   ||' NVL(TOTALDAYS,0) TOTALDAYS, NVL(DAYOFF,0) DAYOFF, NVL(INCLUDEOFFDAY,0) INCLUDEOFFDAY, NVL(CARDREADINGDAYS,0) CARDREADINGDAYS, '||CHR(10)
                   ||' NVL(CALCULATIONFACTORDAYS,0) CALCULATIONFACTORDAYS, TRANSACTIONTYPE, MODULE '||CHR(10)
                   ||' FROM PISMONTHATTENDANCE  '||CHR(10)
                   ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                   ||'   AND YEARMONTH = '''||lv_YYYYMM||''' '||CHR(10)
                   ||'   AND MODULE = '''||P_MODULE||'''  '||CHR(10)
                   ||' ORDER BY WORKERSERIAL '||CHR(10); 
       insert into PIS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_PISVIEWCREATION',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, 'PISATTN');
       EXECUTE IMMEDIATE lv_SqlStr;
       COMMIT;
    END IF;
    
    IF P_ViewName  = 'PCOMP' OR NVL(P_ViewName,'ALL') = 'ALL' then
         lv_SqlStr := ' CREATE OR REPLACE VIEW PCOMP '||CHR(10)
                   || ' AS ('||CHR(10)
                   || '     SELECT '''|| P_YEARMONTH ||''' AS YEARMONTH, T.WORKERSERIAL, T.TOKENNO '||CHR(10)
                   || '     '|| lv_CompWithValue ||' '||chr(10)
                   || '     FROM '||lv_TableName||' T '||CHR(10)
                   || '     WHERE T.COMPANYCODE = '''||P_COMPCODE||''' AND T.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                   || '     AND T.YEARMONTH = '''||lv_YYYYMM||'''  '||chr(10)
                   || '     AND T.TRANSACTIONTYPE = '''||P_TRANSACTIONTYPE||''' '||CHR(10)
                   || '     GROUP BY T.WORKERSERIAL, T.TOKENNO '||CHR(10)
                   || '  ) '||chr(10);
       insert into PIS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_PISVIEWCREATION',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, 'COMP');
       EXECUTE IMMEDIATE lv_SqlStr;
       COMMIT;
    END IF;   
    RETURN;                          
exception
when others then
 --insert into error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'ERROR SQL',lv_sqlstr,lv_sqlstr,lv_parvalues,lv_remarks);
 lv_sqlerrm := sqlerrm ;
 --dbms_output.put_line(lv_sqlerrm);
 insert into PIS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_PISVIEWCREATION',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
end;
/


DROP PROCEDURE PROC_PIS_CHECKLIST;

CREATE OR REPLACE PROCEDURE PROC_PIS_CHECKLIST
(
P_COMPANYCODE VARCHAR2, 
P_DIVISIONCODE VARCHAR2,
P_YEARCODE     VARCHAR2, 
P_FROMDATE VARCHAR2,
P_TODATE VARCHAR2,
P_COMPONENT VARCHAR2,
P_CATEGORY VARCHAR2,
P_GRADE VARCHAR2,
p_DEPT VARCHAR2,
p_YEARMONTH VARCHAR2 DEFAULT NULL
)
AS 
LV_SQLSTR VARCHAR2(30000);
LV_HEADER VARCHAR2(4000);
LV_TBLHD VARCHAR2(4000);
LV_YEARCODE VARCHAR2(10);


LV_YEARMONTH VARCHAR2(10); 
LV_sqlCol VARCHAR2(10000);

BEGIN
    
    IF p_YEARMONTH IS NOT NULL THEN
        LV_YEARMONTH := p_YEARMONTH;
    ELSE
        LV_YEARMONTH := TO_CHAR(TO_DATE(P_FROMDATE,'DD/MM/YYYY'),'YYYYMM');
    END IF;


    LV_SQLSTR:='SELECT RTRIM (XMLAGG (XMLELEMENT (E, X.COMPONENTCODE || '','')ORDER BY X.srl).EXTRACT (''//text()''), '','') COMPONENTNAMELIST'||CHR(10)
              ||'FROM ('||CHR(10)
              ||'   select nvl(phase,999)+nvl(calculationindex,9999) srl, ''PISCOMP.''||COMPONENTCODE COMPONENTCODE from piscomponentmaster'||CHR(10)
              ||'   where companycode='''||P_COMPANYCODE||''''||CHR(10)
              ||'       and divisioncode='''||P_DIVISIONCODE||''''||CHR(10)
              ||'       and componentcode||yearmonth in'||CHR(10)
              ||'           (   select distinct componentcode||max(yearmonth) from piscomponentmaster'||CHR(10)
              ||'               where companycode='''||P_COMPANYCODE||''''
              ||'                   and divisioncode='''||P_DIVISIONCODE||''''
              ||'                   and nvl(ATTENDANCEENTRYAPPLICABLE,''N'') = ''Y'''||CHR(10)
              ||'                   and to_number(yearmonth)<='||LV_YEARMONTH||CHR(10);
              IF P_COMPONENT IS NOT NULL THEN
    LV_SQLSTR:=LV_SQLSTR||'                   and componentcode in ('||P_COMPONENT||')'||CHR(10);
              ELSE
     LV_SQLSTR:=LV_SQLSTR||'                   and componentcode in (''XXX'')'||CHR(10);
              end if;
    LV_SQLSTR:=LV_SQLSTR||'               group by componentcode'||CHR(10)
              ||'           )'||CHR(10)
              ||') X';
    ---DBMS_OUTPUT.PUT_LINE(Lv_SQLSTR);
   EXECUTE  IMMEDIATE LV_SQLSTR INTO LV_HEADER;
   
   
    LV_SQLSTR:='SELECT RTRIM (XMLAGG (XMLELEMENT (E, X.COLNAME||SRL || '','')ORDER BY X.COLNAME).EXTRACT (''//text()''), '','') COMPONENTNAMELIST'||CHR(10)
              ||'FROM ('||CHR(10)
              ||'SELECT ROWNUM SRL, ''COMP'' COLNAME FROM('||CHR(10)
              ||'   select nvl(phase,999)+nvl(calculationindex,9999) srl, ''PISCOMP.''||componentcode componentcode from piscomponentmaster'||CHR(10)
              ||'   where companycode='''||P_COMPANYCODE||''''||CHR(10)
              ||'       and divisioncode='''||P_DIVISIONCODE||''''||CHR(10)
              ||'       and componentcode||yearmonth in'||CHR(10)
              ||'           (   select distinct componentcode||max(yearmonth) from piscomponentmaster'||CHR(10)
              ||'               where companycode='''||P_COMPANYCODE||''''||chr(10)
              ||'                   and divisioncode='''||P_DIVISIONCODE||''''
              ||'                   and nvl(ATTENDANCEENTRYAPPLICABLE,''N'') = ''Y'''||CHR(10)
              ||'                   and to_number(yearmonth)<='||LV_YEARMONTH||CHR(10);
              IF P_COMPONENT IS NOT NULL THEN
    LV_SQLSTR:=LV_SQLSTR||'                   and componentcode in ('||P_COMPONENT||')'||CHR(10);
             ELSE
     LV_SQLSTR:=LV_SQLSTR||'                   and componentcode in (''XXX'')'||CHR(10);
             end if;
    LV_SQLSTR:=LV_SQLSTR||'               group by componentcode'||CHR(10)
              ||'           )'||CHR(10)||')'||CHR(10)
              ||') X';
    --DBMS_OUTPUT.PUT_LINE(Lv_SQLSTR);
    EXECUTE  IMMEDIATE LV_SQLSTR INTO LV_TBLHD;
    
    DELETE FROM GTT_PISCHECK_LIST;
    
    LV_SQLSTR:= 'INSERT INTO GTT_PISCHECK_LIST(comp100, WORKERSERIAL, TOKENNO, EMPLOYEENAME, UNITCODE, CATEGORYCODE, GRADECODE, DEPARTMENTCODE, DEPARTMENTDESC,COMPANYNAME, DIVISIONNAME, FROMTODATE, SALARYDAYS, PRESENTDAYS, HOLIDAYS ';
                IF P_COMPONENT IS NOT NULL THEN
    LV_SQLSTR:=LV_SQLSTR||','||CHR(10)
                ||LV_TBLHD||CHR(10);
                END IF;
                LV_SQLSTR:=LV_SQLSTR||')'||CHR(10)||'SELECT 0 comp100,  ''0'' WORKERSERIAL,NULL TOKENNO,NULL EMPLOYEENAME,NULL UNITCODE,NULL CATEGORYCODE,NULL GRADECODE,NULL DEPARTMENTCODE,NULL DEPARTMENTDESC,C.COMPANYNAME, D.DIVISIONNAME,''Check list For the month ''||TO_CHAR(TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY''),''MM-YYYY'') FROMTODATE,NULL SALARYDAYS,NULL PRESENTDAYS,NULL HOLIDAYS ';
                 IF P_COMPONENT IS NOT NULL THEN
                 LV_SQLSTR:=LV_SQLSTR||','||CHR(10)
                ||''''||REPLACE(REPLACE(LV_HEADER,'PISCOMP.',''),',',''',''')||''''||CHR(10);
                END IF;
                LV_SQLSTR:=LV_SQLSTR||'FROM COMPANYMAST C, DIVISIONMASTER D WHERE C.COMPANYCODE=D.COMPANYCODE AND C.COMPANYCODE= '''||P_COMPANYCODE||''' AND D.DIVISIONCODE = '''||P_DIVISIONCODE||''' '||CHR(10) 
                ||'UNION ALL'||CHR(10)
                ||'SELECT  1 comp100, A.WORKERSERIAL,A.TOKENNO,E.EMPLOYEENAME,A.UNITCODE,A.CATEGORYCODE,A.GRADECODE,A.DEPARTMENTCODE,D.DEPARTMENTDESC,M.COMPANYNAME, V.DIVISIONNAME,''Check list For the month ''||TO_CHAR(TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY''),''MM-YYYY'') FROMTODATE,A.SALARYDAYS,A.PRESENTDAYS,A.HOLIDAYS ';
                  IF P_COMPONENT IS NOT NULL THEN
                LV_SQLSTR:=LV_SQLSTR||' ,'||CHR(10)
                ||'TO_CHAR('||REPLACE(LV_HEADER,',','),TO_CHAR(')||') '||CHR(10);
                end if;
                LV_SQLSTR:=LV_SQLSTR||'FROM PISMONTHATTENDANCE A,PISEMPLOYEEMASTER E, PISDEPARTMENTMASTER D,COMPANYMAST M, DIVISIONMASTER V,'
                ||' ('||CHR(10)||'      SELECT * FROM PISCOMPONENTASSIGNMENT'||CHR(10)
                ||'     WHERE COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
                ||'         AND DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
                ||'         AND TRANSACTIONTYPE=''ATTENDANCE'''||CHR(10)
                ||'         AND WORKERSERIAL||YEARMONTH IN ('||CHR(10)
                ||'             SELECT WORKERSERIAL||MAX(YEARMONTH) FROM PISCOMPONENTASSIGNMENT'||CHR(10)
                ||'             WHERE COMPANYCODE='''||P_COMPANYCODE||''' AND DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
                ||'                 AND TO_NUMBER(YEARMONTH)<='||LV_YEARMONTH||CHR(10)
                ||'                 AND TRANSACTIONTYPE=''ATTENDANCE'''||CHR(10)
                ||'             GROUP BY WORKERSERIAL'||CHR(10)
                ||'         )'||CHR(10)
                ||' ) PISCOMP'||CHR(10)
                ||'WHERE A.COMPANYCODE=E.COMPANYCODE'||CHR(10)
                ||'AND A.DIVISIONCODE=E.DIVISIONCODE'||CHR(10)
                ||'AND A.WORKERSERIAL=E.WORKERSERIAL'||CHR(10)
                ||'AND A.COMPANYCODE=D.COMPANYCODE'||CHR(10)
                ||'AND A.DIVISIONCODE=D.DIVISIONCODE'||CHR(10)
                ||'AND A.DEPARTMENTCODE=D.DEPARTMENTCODE'||CHR(10)
                ||'AND A.WORKERSERIAL=PISCOMP.WORKERSERIAL'||CHR(10)
                ||'AND A.COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
                ||'AND A.DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
                ||'AND A.COMPANYCODE=M.COMPANYCODE'||CHR(10)
                ||'AND A.COMPANYCODE=V.COMPANYCODE'||CHR(10)
                ||'AND A.DIVISIONCODE=V.DIVISIONCODE'||CHR(10)
                ||'AND A.YEARCODE='''||P_YEARCODE||''''||CHR(10)
                ||'AND TO_NUMBER(A.YEARMONTH)='||LV_YEARMONTH||CHR(10);
                IF P_CATEGORY is not null then
LV_SQLSTR:= LV_SQLSTR||'AND A.CATEGORYCODE IN ('||P_CATEGORY||')'||CHR(10);
                end if;
                IF P_GRADE IS NOT NULL THEN
LV_SQLSTR:= LV_SQLSTR||'AND A.GRADECODE IN ('||P_GRADE||')'||CHR(10);
                END IF;
                IF p_DEPT IS NOT NULL THEN
LV_SQLSTR:= LV_SQLSTR||'AND A.DEPARTMENTCODE IN ('||p_DEPT||')'||CHR(10);
                END IF;      
      
    DBMS_OUTPUT.PUT_LINE(Lv_SQLSTR);
    EXECUTE  IMMEDIATE LV_SQLSTR;     
    
    --change 23022021  
        
        
    if length(nvl(lv_tblhd,0))>1 then
     lv_sqlstr:=' select ''select ''|| wm_concat(name) || '' from gtt_pischeck_list '' from
                (   
                select ''sum(''||names||'')'' name from(
                select regexp_substr('''||lv_tblhd||''',''[^,]+'',1,level) names from dual
                connect by level <= length(regexp_replace('''||lv_tblhd||''',''[^,]+''))+1
                )                       
            ) ';        
     execute  immediate lv_sqlstr into lv_sqlcol;     
        
     lv_sqlstr := 'insert into gtt_pischeck_list(comp100,employeename,'||lv_tblhd||')
                  select 2,''TOTAL'' total,a.* from (
                    '||lv_sqlcol||'where nvl(workerserial,0)<>0  
                  )a ';
                  
        --dbms_output.put_line(lv_sqlstr);              
        execute  immediate lv_sqlstr ;
    end if;
           
    --change 23022021
END;
/


DROP PROCEDURE PROC_PIS_CUMM_DATA_MIGRATE;

CREATE OR REPLACE procedure             PROC_PIS_CUMM_DATA_MIGRATE
(
  p_schema varchar2,
  p_divisioncode varchar2,
  p_yearcode varchar2,
  p_effectivedate varchar2
)
as 
/******************************************************************************
   NAME:      Ujjwal
   PURPOSE:   PF GROSS xx UPDATE
   Date :    27.02.2020
  
   NOTES:
   Implementing for Gloster Jute Mills 
******************************************************************************/

lv_sqlstr varchar(3000);    
lv_ProcName varchar(50):='PROC_PIS_CUMULATIVEDATA_MIGRATE';
lv_Remarks varchar(200):='ERROR';
lv_SqlErr   varchar2(200) := '';
begin  
        
      --DELETE FROM PISPAYTRANSACTION_PREVDATA;

        lv_sqlstr :='
        INSERT INTO PISPAYTRANSACTION_PREVDATA(
    COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH,EFFECT_YEARMONTH, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL,  
    TOKENNO, BASIC, DA, ADHOC, HRA, ATTN_SALD,CUMM_DAYS, CUM_PFGROS, PF_GROSS,MISC_BF,SYSROWID, LASTMODIFIED, USERNAME)

    SELECT  COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH,YEARMONTH, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, 
    TOKENNO, SUM(BASIC)BASIC, SUM(DA)DA , SUM(ADHOC)ADHOC, SUM(HRA)HRA, SUM(ATTNCUMD)ATTNCUMD, SUM(ATTNCUMD)ATTNCUMD,
    SUM(PF_GROSSCUMM)PF_GROSSCUMM,SUM(PF_GROSSCUMM)PF_GROSSCUMM,SUM(MISCBF)MISCBF, SYS_GUID() SYSROWID, SYSDATE LASTMODIFIED,''SWT'' USERNAME FROM (   
         SELECT DISTINCT
        C.COMPANYCODE, C.DIVISIONCODE, A.YEARCODE, A.YEARMONTH,  A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, C.WORKERSERIAL, A.EMPLOYEECODE,
        C.TOKENNO, 
        CASE WHEN COMPONENTCODE IN (''BASIC'') THEN NVL(COMPONENTAMOUNT,0) END AS BASIC,
        CASE WHEN COMPONENTCODE IN (''DA'') THEN NVL(COMPONENTAMOUNT,0) END AS DA,
        CASE WHEN COMPONENTCODE IN (''ADHOC_AMT'',''ADHOC_INC'') THEN NVL(COMPONENTAMOUNT,0) END AS ADHOC,
        CASE WHEN COMPONENTCODE IN (''HRA'') THEN NVL(COMPONENTAMOUNT,0) END AS HRA,
            CASE WHEN A.COMPONENTCODE IN (''ATTN.CUMD'') THEN
                CASE WHEN  D.LEAVECALENDARORFINANCIALYRWISE=''C''  AND  SUBSTR(YEARMONTH,0,4)<SUBSTR('''||p_effectivedate||''',0,4)
                    THEN 0 ELSE NVL(COMPONENTAMOUNT,0) END 
          END AS ATTNCUMD,
        CASE WHEN COMPONENTCODE IN (''PF_GROSS.CUMM'') THEN NVL(COMPONENTAMOUNT,0) END AS PF_GROSSCUMM,
        CASE WHEN COMPONENTCODE IN (''MISC.CF'') THEN NVL(COMPONENTAMOUNT,0)*-1 END AS MISCBF   
        FROM 
        '||p_schema||'.PISEMPLOYEEPAYTRANSACTION A, '||p_schema||'.PISEMPLOYEEMASTER B, PISEMPLOYEEMASTER C,'||p_schema||'.PISCATEGORYMASTER D
        WHERE A.COMPANYCODE=B.COMPANYCODE
        AND A.LOCATIONCODE=B.LOCATIONCODE
        AND A.EMPLOYEECODE =B.EMPLOYEECODE
        AND B.COMPANYCODE=C.COMPANYCODE
        AND B.LOCATIONCODE=C.DIVISIONCODE
        AND B.EMPLOYEEID =C.TOKENNO
        AND A.COMPANYCODE=D.COMPANYCODE
        AND A.LOCATIONCODE=D.LOCATIONCODE
        AND B.CATEGORYCODE=D.CATEGORYCODE
        AND A.TRANSACTIONTYPE LIKE ''%SALARY%''
        AND A.LOCATIONCODE='''||p_divisioncode||'''
        AND A.YEARMONTH=(SELECT MAX(YEARMONTH) FROM '||p_schema||'.PISEMPLOYEEPAYTRANSACTION P WHERE P.EMPLOYEECODE=A.EMPLOYEECODE AND yearmonth<='''||p_effectivedate||''')
        AND YEARCODE='''||p_yearcode||'''  
    )
    GROUP BY COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, 
    EMPLOYEECODE, TOKENNO  ';
            
    -- dbms_output.put_line(lv_sqlstr);
    execute immediate lv_sqlstr;
         
    INSERT INTO PIS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( '0001', p_divisioncode, lv_ProcName,'',SYSDATE, lv_sqlstr,'', '', '', lv_Remarks);
    commit;
    
    
    INSERT INTO PISCOMPONENTOPENING (COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, WORKERSERIAL, TOKENNO,
     COMPONENTCODE, COMPONENTAMOUNT, USERNAME, SYSROWID, LASTMODIFIED)        
     SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, WORKERSERIAL, TOKENNO,
     'MISC_CF' COMPONENTCODE, MISC_BF*-1 COMPONENTAMOUNT, 
     USERNAME, SYSROWID, LASTMODIFIED
     FROM  PISPAYTRANSACTION_PREVDATA WHERE DIVISIONCODE=p_divisioncode;  
    
     COMMIT;
exception    
    when others then
        lv_SqlErr := sqlerrm;
    INSERT INTO PIS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( '0001', p_divisioncode, lv_ProcName,lv_SqlErr,SYSDATE, lv_sqlstr,'', '', '', lv_Remarks);    
        
   commit;    
END;
/


DROP PROCEDURE PROC_PIS_CUMM_PF_ASON_UPDT;

CREATE OR REPLACE PROCEDURE             PROC_PIS_CUMM_PF_ASON_UPDT(P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_TRANTYPE Varchar2, 
                                                  P_PHASE  number, 
                                                  P_YEARMONTH Varchar2,
                                                  P_EFFECTYEARMONTH Varchar2, 
                                                  P_TABLENAME Varchar2,
                                                  P_PHASE_TABLENAME Varchar2,
                                                  P_UNIT  Varchar2,
                                                  P_CATEGORY    Varchar2  DEFAULT NULL,
                                                  P_GRADE       Varchar2  DEFAULT NULL,
                                                  P_DEPARTMENT  Varchar2  DEFAULT NULL,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
as
lv_Component varchar2(32767) := '';
lv_Sql       varchar2(32767) := '';
lv_upd1_sql  varchar2(32767) := '';
lv_upd2_sql  varchar2(32767) := '';
lv_colstr    varchar2(32767) := '';
lv_Sql_TblCreate    varchar2(3000) := '';  
lv_sqlerrm      varchar2(1000) := ''; 
lv_remarks      varchar2(1000) := '';
lv_parvalues    varchar2(1000) := '';
lv_SqlTemp      varchar2 (2000) := '';
lv_Cols         varchar2 (1000) := '';
lv_fn_stdt      date ;
lv_fn_endt      date ;
lv_YearCode     varchar2(10):= '';
lv_FirtstDt     date; 
lv_ProcName     varchar2(30) := 'PROC_PIS_CUMM_PF_ASON_UPDT';
lv_updtable varchar2(30) ;
lv_pf_cont_col varchar2(30) ;
lv_cnt int;
lv_FNYearStartdate varchar2(10) :='';
lv_CalenderYearStartdate varchar2(10) :='';
begin
    
    
    --dbms_output.put_line('1_0');    
    lv_fn_stdt := TO_DATE('01/'||SUBSTR(P_EFFECTYEARMONTH,5,2)||'/'||SUBSTR(P_EFFECTYEARMONTH,1,4),'DD/MM/YYYY');   
    lv_fn_endt := last_day(lv_fn_stdt);

    --dbms_output.put_line('1_1 - '||lv_fn_stdt||', '||lv_fn_endt);
    SELECT YEARCODE INTO lv_YearCode FROM FINANCIALYEAR
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
      AND STARTDATE <= lv_fn_stdt and ENDDATE >= lv_fn_stdt;
       
    --dbms_output.put_line('1_2');
    select SUBSTR( ( 'PIS1_'||SYS_CONTEXT('USERENV', 'SESSIONID')) ,1,30) into lv_updtable  from dual ;
    --dbms_output.put_line('1_3');
    
    lv_cnt :=0;
    SELECT COUNT(*)
    INTO 
    lv_cnt
    FROM USER_TABLES
    WHERE TABLE_NAME =lv_updtable;
    
    IF lv_cnt>0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE '|| lv_updtable;
    END IF;
    
    --dbms_output.put_line('2_0');
    lv_sql := ' CREATE TABLE '||lv_updtable||' AS  '||CHR(10)
            ||' SELECT WORKERSERIAL, SUM(PF_E) PF_E, SUM(PF_C) PF_C, SUM(CUM_WORKINGDAYS) CUM_WORKINGDAYS, SUM(CUM_WORKINGHRS) CUM_WORKINGHRS, SUM(VPF) VPF '||CHR(10)
            ||' FROM ( '||CHR(10)
            ||'         SELECT WORKERSERIAL, SUM(PF_E) PF_E, SUM(PF_C) PF_C, 0 CUM_WORKINGDAYS, 0 CUM_WORKINGHRS ,SUM(VPF) VPF '||CHR(10)
            ||'         FROM ( '||CHR(10)
            ||'                 SELECT WORKERSERIAL, PFNO, DECODE(COMPONENTCODE,''PF_E'',COMPONENTAMOUNT,0) PF_E, '||CHR(10)
            ||'                 DECODE(COMPONENTCODE,''PF_C'',COMPONENTAMOUNT,0) PF_C, '||CHR(10)
            ||'                 DECODE(COMPONENTCODE,''VPF'',COMPONENTAMOUNT,0) VPF '||CHR(10)
            ||'                 FROM PFTRANSACTIONDETAILS '||CHR(10)
            ||'                 WHERE COMPANYCODE = ''0002'' AND DIVISIONCODE = ''0010'' '||CHR(10)
            ||'                   AND YEARCODE = '''||lv_YearCode||''' '||CHR(10)
            ||'                   AND YEARMONTH <= '''||P_EFFECTYEARMONTH||''' '||CHR(10)
            ||'                   AND TRANSACTIONTYPE <> ''SALARY'' '||CHR(10) 
            ||'                 UNION ALL '||CHR(10)
            ||'                 SELECT WORKERSERIAL, PFNO, DECODE(COMPONENTCODE,''PF_E'',COMPONENTAMOUNT,0) PF_E, '||CHR(10)
            ||'                 DECODE(COMPONENTCODE,''PF_C'',COMPONENTAMOUNT,0) PF_C, '||CHR(10)
            ||'                 DECODE(COMPONENTCODE,''VPF'',COMPONENTAMOUNT,0) VPF '||CHR(10)
            ||'                 FROM PFTRANSACTIONDETAILS '||CHR(10)
            ||'                 WHERE COMPANYCODE = ''0002'' AND DIVISIONCODE = ''0010'' '||CHR(10)
            ||'                   AND YEARCODE = '''||lv_YearCode||''' '||CHR(10)
            ||'                   AND YEARMONTH < '''||P_EFFECTYEARMONTH||''' '||CHR(10)
            ||'                   AND TRANSACTIONTYPE LIKE ''%SALARY%'' '||CHR(10)
            ||'                 UNION ALL '||CHR(10)
            ||'                 SELECT A.WORKERSERIAL, B.PFNO, NVL(PF_E,0) PF_E, NVL(PF_C,0) PF_C, NVL(VPF,0) VPF '||CHR(10)
            ||'                 FROM '||P_PHASE_TABLENAME||' A, PISEMPLOYEEMASTER B '||CHR(10)
            ||'                 WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'                   AND YEARCODE = '''||lv_YearCode||'''  '||CHR(10)
            ||'                   AND YEARMONTH = '''||P_EFFECTYEARMONTH||''' '||CHR(10)
            ||'                   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
            ||'                   AND A.WORKERSERIAL = B.WORKERSERIAL  '||CHR(10)
            ||'             )  '||CHR(10)
            ||'             GROUP BY WORKERSERIAL, PFNO  '||CHR(10)     
/*            ||'             UNION ALL  '||CHR(10)
            ||'             SELECT WORKERSERIAL, 0 PF_E, 0 PF_C, SUM(CUM_WORKINGDAYS) CUM_WORKINGDAYS,  SUM(CUM_WORKINGHRS) CUM_WORKINGHRS , 0 VPF  '||CHR(10)
            ||'             FROM (  '||CHR(10)
            ||'                     SELECT WORKERSERIAL, FORTNIGHTENDDATE, ROUND(SUM(NVL(ATTENDANCEHOURS,0))/8,2) CUM_WORKINGDAYS  , SUM(NVL(ATTENDANCEHOURS,0)) CUM_WORKINGHRS '||CHR(10)
            ||'                     FROM PISPAYTRANSACTION A, PISEMPLOYEEMASTER B '||CHR(10)
            ||'                     WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''      '||CHR(10)
            ||'                       AND A.FORTNIGHTSTARTDATE >= TO_DATE('''||lv_CalenderYearStartdate||''',''DD/MM/YYYY'') '||CHR(10)
            ||'                       AND A.FORTNIGHTSTARTDATE < TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')  '||CHR(10)
            ||'                       AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
            ||'                       AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE '||CHR(10)
            ||'                       AND (B.STLAPPLICABLE = ''Y'' OR B.CALC_CUMULATIVEWORKDAYS = ''Y'') '||CHR(10)   
            ||'                     GROUP BY A.WORKERSERIAL, A.FORTNIGHTENDDATE  '||CHR(10)
            ||'                     UNION ALL  '||CHR(10)
            ||'                     SELECT WORKERSERIAL, FORTNIGHTENDDATE, ROUND(NVL(ATTENDANCEHOURS,0)/8,2) CUM_WORKINGDAYS , NVL(ATTENDANCEHOURS,0) CUM_WORKINGHRS '||CHR(10)
            ||'                     FROM '||P_PHASE_TABLENAME||' A, WPSWORKERCATEGORYMAST B '||CHR(10)
            ||'                     WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''   '||CHR(10)
            ||'                       AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_FNSTDT||''',''DD/MM/YYYY'')   '||CHR(10)
            ||'                       AND A.FORTNIGHTENDDATE = TO_DATE('''||P_FNENDT||''',''DD/MM/YYYY'')    '||CHR(10)
            ||'                       AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
            ||'                       AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE '||CHR(10)
            ||'                       AND (B.STLAPPLICABLE = ''Y'' OR B.CALC_CUMULATIVEWORKDAYS = ''Y'') '||CHR(10)      
            ||'                 )  '||CHR(10)  
            ||'             GROUP BY WORKERSERIAL  '||CHR(10)
*/
            ||'        )  '||CHR(10)
            ||'         GROUP BY WORKERSERIAL  '||CHR(10);

      
    --dbms_output.put_line('2_1');  
    --dbms_output.put_line(lv_sql );       
    INSERT INTO PIS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE,PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    VALUES (P_COMPCODE, P_DIVCODE,lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks); 
    EXECUTE IMMEDIATE lv_sql  ;
    COMMIT;
    --RETURN;
--    
lv_sql := 'UPDATE '||P_TABLENAME||' A SET (A.CUMM_PF_E, A.CUMM_PF_C, A.CUMM_VPF)  '||CHR(10)  
        ||' = ( SELECT B.PF_E, B.PF_C, B.VPF FROM '||lv_updtable||' B '||CHR(10) 
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.YEARCODE = '''||lv_YearCode||'''   '||CHR(10) 
        ||' AND A.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
        ||' AND A.WORKERSERIAL = B.WORKERSERIAL )'||CHR(10)
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.YEARMONTH = '''||P_YEARMONTH||'''       '||CHR(10)
        ||'AND A.WORKERSERIAL IN (SELECT WORKERSERIAL FROM '||lv_updtable||')'||CHR(10);
        
   lv_remarks := NVL(lv_remarks,'XX ') ||' UPDATE CUMM_PF_E, CUMM_PF_C, CUMM_VPF';
 --dbms_output.put_line(lv_sql );   
   INSERT INTO PIS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
   VALUES (P_COMPCODE, P_DIVCODE,lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
   COMMIT;    
    EXECUTE IMMEDIATE lv_sql;
       BEGIN
        execute immediate 'DROP TABLE '||lv_updtable ;
       EXCEPTION
        WHEN OTHERS THEN
          lv_sqlerrm := sqlerrm;
          raise_application_error(-20101, lv_sqlerrm||'ERROR WHILE UPDATING '||P_TABLENAME||' FROM TABLE '||lv_updtable);
       END ;
EXCEPTION
    WHEN OTHERS THEN
    lv_sqlerrm := sqlerrm;
    INSERT INTO PIS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    VALUES (P_COMPCODE, P_DIVCODE,lv_ProcName,lv_sqlerrm,sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
                                  
end;
/


DROP PROCEDURE PROC_PIS_LEAVEBAL;

CREATE OR REPLACE PROCEDURE             PROC_PIS_LEAVEBAL(P_COMPANYCODE VARCHAR2,P_DIVISIONCODE VARCHAR2,P_YEARCODE VARCHAR2,P_FROMDATE VARCHAR2,P_TODATE VARCHAR2, P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
as
lv_sql  varchar2(20000);
lv_cnt int;
BEGIN
    
     BEGIN
           EXECUTE IMMEDIATE 'DROP TABLE TEMP_LEAVE';
          
            EXCEPTION WHEN OTHERS THEN
                NULL;                 
        END;
    
    
    lv_sql:='CREATE TABLE TEMP_LEAVE'||CHR(10)
            ||'AS'||CHR(10)
            ||'SELECT WORKERSERIAL,LEAVECODE,SUM(OPENING) OPENING,SUM(ENT) ENT,SUM(AVAIL) AVAIL'||CHR(10)
            ||'FROM'||CHR(10)
            ||'('||CHR(10)
            ||'     SELECT A.CATEGORYCODE, A.WORKERSERIAL, LEAVECODE, SUM(NOOFDAYS) OPENING, 0 ENT, 0 AVAIL'||CHR(10)
            ||'     FROM PISEMPLOYEEMASTER A, PISCATEGORYMASTER C,PISLEAVETRANSACTION B'||CHR(10)
            ||'     WHERE A.COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
            ||'         AND A.DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
            ||'         AND A.COMPANYCODE=C.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=C.DIVISIONCODE'||CHR(10)
            ||'         AND A.CATEGORYCODE=C.CATEGORYCODE'||CHR(10)
            ||'         AND C.LEAVECALENDARORFINYRWISE=''F'''||CHR(10)
            ||'         AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
            ||'         AND A.WORKERSERIAL=B.WORKERSERIAL'||CHR(10)
            ||'         AND B.TRANSACTIONTYPE=''BF'''||CHR(10)
            ||'         AND B.YEARCODE='''||P_YEARCODE||''''||CHR(10)
            ||'         AND B.YEARMONTH<=TO_CHAR(TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY''),''YYYYMM'')'||CHR(10)
            ||'     GROUP BY A.CATEGORYCODE,A.WORKERSERIAL,B.LEAVECODE'||CHR(10)
            ||'     UNION ALL'||CHR(10)
            ||'     SELECT A.CATEGORYCODE, A.WORKERSERIAL, LEAVECODE, SUM(NOOFDAYS) OPENING, 0 ENT, 0 AVAIL'||CHR(10)
            ||'     FROM PISEMPLOYEEMASTER A, PISCATEGORYMASTER C,PISLEAVETRANSACTION B'||CHR(10)
            ||'     WHERE A.COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
            ||'         AND A.DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
            ||'         AND A.COMPANYCODE=C.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=C.DIVISIONCODE'||CHR(10)
            ||'         AND A.CATEGORYCODE=C.CATEGORYCODE'||CHR(10)
            ||'         AND C.LEAVECALENDARORFINYRWISE=''C'''||CHR(10)
            ||'         AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
            ||'         AND A.WORKERSERIAL=B.WORKERSERIAL'||CHR(10)
            ||'         AND B.TRANSACTIONTYPE=''BF'''||CHR(10)
            ||'         AND B.CALENDARYEAR=TO_CHAR(TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY''),''YYYY'')'||CHR(10)
            ||'         AND B.YEARMONTH<=TO_CHAR(TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY''),''YYYYMM'')'||CHR(10)
            ||'     GROUP BY A.CATEGORYCODE,A.WORKERSERIAL,B.LEAVECODE'||CHR(10)
            ||'     UNION ALL'||CHR(10)
            ||'     SELECT A.CATEGORYCODE, A.WORKERSERIAL, LEAVECODE, 0 OPENING, SUM(ENTITLEMENTS) ENT, 0 AVAIL'||CHR(10)
            ||'     FROM PISEMPLOYEEMASTER A, PISCATEGORYMASTER C,PISLEAVEENTITLEMENT B'||CHR(10)
            ||'     WHERE A.COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
            ||'         AND A.DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
            ||'         AND A.COMPANYCODE=C.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=C.DIVISIONCODE'||CHR(10)
            ||'         AND A.CATEGORYCODE=C.CATEGORYCODE'||CHR(10)
            ||'         AND C.LEAVECALENDARORFINYRWISE=''F'''||CHR(10)
            ||'         AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
            ||'         AND A.WORKERSERIAL=B.WORKERSERIAL'||CHR(10)
            ||'         AND B.YEARCODE='''||P_YEARCODE||''''||CHR(10)
            ||'     GROUP BY A.CATEGORYCODE,A.WORKERSERIAL,B.LEAVECODE'||CHR(10)
            ||'     UNION ALL'||CHR(10)
            ||'     SELECT A.CATEGORYCODE, A.WORKERSERIAL, LEAVECODE, 0 OPENING, SUM(ENTITLEMENTS) ENT, 0 AVAIL'||CHR(10)
            ||'     FROM PISEMPLOYEEMASTER A, PISCATEGORYMASTER C,PISLEAVEENTITLEMENT B'||CHR(10)
            ||'     WHERE A.COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
            ||'         AND A.DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
            ||'         AND A.COMPANYCODE=C.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=C.DIVISIONCODE'||CHR(10)
            ||'         AND A.CATEGORYCODE=C.CATEGORYCODE'||CHR(10)
            ||'         AND C.LEAVECALENDARORFINYRWISE=''C'''||CHR(10)
            ||'         AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
            ||'         AND A.WORKERSERIAL=B.WORKERSERIAL'||CHR(10)
            ||'         AND B.CALENDARYEAR=TO_CHAR(TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY''),''YYYY'')'||CHR(10)
            ||'     GROUP BY A.CATEGORYCODE,A.WORKERSERIAL,B.LEAVECODE'||CHR(10)
            ||'     UNION ALL'||CHR(10)
            ||'     SELECT A.CATEGORYCODE, A.WORKERSERIAL, LEAVECODE, 0 OPENING, 0 ENT, SUM(LEAVEDAYS) AVAIL'||CHR(10)
            ||'     FROM PISEMPLOYEEMASTER A, PISLEAVEAPPLICATION B, PISCATEGORYMASTER C'||CHR(10)
            ||'     WHERE A.COMPANYCODE = '''||P_COMPANYCODE||''''||CHR(10)
            ||'         AND A.DIVISIONCODE = '''||P_DIVISIONCODE||''''||CHR(10)
            ||'         AND A.COMPANYCODE=C.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=C.DIVISIONCODE'||CHR(10)
            ||'         AND A.CATEGORYCODE = C.CATEGORYCODE'||CHR(10)
            ||'         AND C.LEAVECALENDARORFINYRWISE =''F'''||CHR(10)
            ||'         AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
            ||'         AND A.WORKERSERIAL = B.WORKERSERIAL'||CHR(10)
            ||'         AND B.YEARCODE = '''||P_YEARCODE||''''||CHR(10)
            ||'         AND B.LEAVESANCTIONEDON IS NOT NULL'||CHR(10)
--            ||'         AND B.LEAVEAPPLIEDON <= TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'||CHR(10)
            ||'         AND B.LEAVEDATE <= TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'||CHR(10)            
            ||'     GROUP BY A.CATEGORYCODE, A.WORKERSERIAL, B.LEAVECODE'||CHR(10)
            ||'     UNION ALL'||CHR(10)
            ||'     SELECT A.CATEGORYCODE, A.WORKERSERIAL, LEAVECODE, 0 OPENING, 0 ENT, SUM(LEAVEDAYS) AVAIL'||CHR(10)
            ||'     FROM PISEMPLOYEEMASTER A, PISLEAVEAPPLICATION B, PISCATEGORYMASTER C'||CHR(10)
            ||'     WHERE A.COMPANYCODE = '''||P_COMPANYCODE||''''||CHR(10)
            ||'         AND A.DIVISIONCODE = '''||P_DIVISIONCODE||''''||CHR(10)
            ||'         AND A.COMPANYCODE=C.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=C.DIVISIONCODE'||CHR(10)
            ||'         AND A.CATEGORYCODE = C.CATEGORYCODE'||CHR(10)
            ||'         AND C.LEAVECALENDARORFINYRWISE =''C'''||CHR(10)
            ||'         AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10)
            ||'         AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10)
            ||'         AND A.WORKERSERIAL = B.WORKERSERIAL'||CHR(10)
            ||'         AND B.CALENDARYEAR = TO_CHAR(TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY''),''YYYY'')'||CHR(10)
            ||'         AND B.LEAVESANCTIONEDON IS NOT NULL'||CHR(10)   
      --    ||'         AND B.LEAVEAPPLIEDON <= TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'||CHR(10)
            ||'         AND B.LEAVEDATE <= TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'||CHR(10)
            ||'     GROUP BY A.CATEGORYCODE, A.WORKERSERIAL, B.LEAVECODE'||CHR(10)
            ||')'||CHR(10)
            ||'GROUP BY WORKERSERIAL, LEAVECODE'||CHR(10);
            
    --  DBMS_OUTPUT.PUT_LINE(lv_sql);
      EXECUTE IMMEDIATE lv_sql;
      
      
        BEGIN
           EXECUTE IMMEDIATE 'DROP TABLE TEMP_NOOFDAYS_DEDUCT';
          
            EXCEPTION WHEN OTHERS THEN
                NULL;                 
        END;
      
        lv_sql:= '     CREATE TABLE TEMP_NOOFDAYS_DEDUCT AS           '||CHR(10)
            ||'    SELECT S.COMPANYCODE, S.DIVISIONCODE, L.WORKERSERIAL,L.LEAVECODE, NVL(OPENING,0) OPENING, NVL(ENT,0) ENT, NVL(AVAIL,0) AVAIL,NVL(CARRYFORWARD,0)CARRYFORWARD,'||CHR(10) 
            ||'    CASE WHEN (NVL(OPENING,0)+NVL(ENT,0)-NVL(CARRYFORWARD,0)>0 AND CARRYFORWARD>0) THEN NVL(OPENING,0)+NVL(ENT,0)-NVL(CARRYFORWARD,0) ELSE 0 END DEDUC'||CHR(10)
            ||'    FROM TEMP_LEAVE T,PISLEAVEENTITLEMENT S,(    '||CHR(10)
            ||'                        SELECT A.WORKERSERIAL,B.LEAVECODE'||CHR(10)
            ||'                        FROM ('||CHR(10)
            ||'                                SELECT DISTINCT WORKERSERIAL'||CHR(10)
            ||'                                FROM TEMP_LEAVE'||CHR(10)
            ||'                             ) A,'||CHR(10)
            ||'                             ('||CHR(10)
            ||'                                SELECT LEAVECODE from PISLEAVEMASTER'||CHR(10)
            ||'                                WHERE COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
            ||'                                    AND DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
            ||'                                    AND WITHOUTPAYLEAVE<>''Y'''||CHR(10)
            ||'                              ) B'||CHR(10)
            ||'                      ) L'||CHR(10)
            ||'    WHERE L.WORKERSERIAL=T.WORKERSERIAL(+)'||CHR(10)
            ||'        AND L.LEAVECODE=T.LEAVECODE(+)'||CHR(10)
            ||'        AND L.WORKERSERIAL=S.WORKERSERIAL'||CHR(10)
            ||'        AND L.LEAVECODE=S.LEAVECODE     '||CHR(10)
            ||'         AND S.YEARCODE='''||P_YEARCODE||'''     '||CHR(10)                    
            ||'         AND (NVL(OPENING,0)+NVL(ENT,0)-NVL(CARRYFORWARD,0))>0 AND  NVL(CARRYFORWARD,0)>0'||CHR(10);
                 
                
          --        DBMS_OUTPUT.PUT_LINE(lv_sql);
                  EXECUTE IMMEDIATE lv_sql;    
            
            
            lv_sql:= '    UPDATE PISLEAVETRANSACTION A'||CHR(10)
            ||'    SET NOOFDAYS='||CHR(10)
            ||'        ('||CHR(10)
            ||'            SELECT A.NOOFDAYS-B.DEDUC FROM TEMP_NOOFDAYS_DEDUCT B'||CHR(10)
            ||'            WHERE '||CHR(10)
            ||'            B.DIVISIONCODE=A.DIVISIONCODE'||CHR(10)
            ||'           AND B.WORKERSERIAL=A.WORKERSERIAL'||CHR(10)
            ||'            AND B.LEAVECODE=A.LEAVECODE'||CHR(10)
            ||'        )       '||CHR(10)
            ||'    WHERE A.DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
            ||'    AND A.LEAVECODE=''PL'''||CHR(10)
            ||'    AND A.WORKERSERIAL IN (SELECT WORKERSERIAL FROM TEMP_NOOFDAYS_DEDUCT)   '||CHR(10)  ;   
                    
                
                  
     -- DBMS_OUTPUT.PUT_LINE(lv_sql);
      EXECUTE IMMEDIATE lv_sql;
            
      
      EXECUTE IMMEDIATE 'TRUNCATE TABLE GBL_PIS_LEAVEBAL';
             
      lv_sql:= 'INSERT INTO GBL_PIS_LEAVEBAL'||CHR(10)
               ||'SELECT '''||P_COMPANYCODE||''' COMPANYCODE,'''||P_DIVISIONCODE||''' DVISIONCODE,TO_CHAR(TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY''),''YYYYMM'') YEARMONTH,D.WORKERSERIAL,E.TOKENNO,E.CATEGORYCODE,E.GRADECODE,D.LEAVECODE,D.OPENING OPENING,D.ENT ENTITLE,D.AVAIL AVAILED,(D.OPENING+D.ENT-D.AVAIL) BALANCE'||CHR(10)
               ||'FROM ('||CHR(10)
               ||'        SELECT L.WORKERSERIAL,L.LEAVECODE, NVL(OPENING,0) OPENING, NVL(ENT,0) ENT, NVL(AVAIL,0) AVAIL'||CHR(10)
               ||'        FROM TEMP_LEAVE T,('||CHR(10)
               ||'                            SELECT A.WORKERSERIAL,B.LEAVECODE'||CHR(10)
               ||'                            FROM ('||CHR(10)
               ||'                                    SELECT DISTINCT WORKERSERIAL'||CHR(10)
               ||'                                    FROM TEMP_LEAVE'||CHR(10)
               ||'                                 ) A,'||CHR(10)
               ||'                                 ('||CHR(10)
               ||'                                    SELECT LEAVECODE from PISLEAVEMASTER'||CHR(10)
               ||'                                    WHERE COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
               ||'                                        AND DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
               ||'                                        AND WITHOUTPAYLEAVE<>''Y'''||CHR(10)
               ||'                                  ) B'||CHR(10)
               ||'                           ) L'||CHR(10)
               ||'        WHERE L.WORKERSERIAL=T.WORKERSERIAL(+)'||CHR(10)
               ||'            AND L.LEAVECODE=T.LEAVECODE(+)'||CHR(10)
               ||'     ) D, PISEMPLOYEEMASTER E'||CHR(10)
               ||'WHERE D.WORKERSERIAL=E.WORKERSERIAL'||CHR(10);
     IF P_WORKERSERIAL IS NOT NULL THEN
        lv_sql:= lv_sql ||' D.WORKERSERIAL IN ('||P_WORKERSERIAL||')'||CHR(10) ;
     END IF;
     
      --  DBMS_OUTPUT.PUT_LINE(lv_sql);
       EXECUTE IMMEDIATE lv_sql;
        
        EXECUTE IMMEDIATE 'DROP TABLE TEMP_LEAVE';
END;
/


DROP PROCEDURE PROC_PIS_LEAVE_UPDATE;

CREATE OR REPLACE PROCEDURE             PROC_PIS_LEAVE_UPDATE(P_COMPCODE Varchar2,
                                        P_DIVCODE Varchar2,
                                        P_TRANTYPE Varchar2,
                                        P_PHASE  number,
                                        P_YEARMONTH Varchar2,
                                        P_EFFECTYEARMONTH Varchar2,
                                        P_TABLENAME Varchar2,
                                        P_PHASE_TABLENAME Varchar2,
                                        P_UNIT  Varchar2,
                                        P_CATEGORY    Varchar2  DEFAULT NULL,
                                        P_GRADE       Varchar2  DEFAULT NULL,
                                        P_DEPARTMENT  Varchar2  DEFAULT NULL,
                                        P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
as
lv_Component varchar2(32767) := '';
lv_Sql       varchar2(32767) := '';
lv_upd1_sql  varchar2(32767) := '';
lv_upd2_sql  varchar2(32767) := '';
lv_colstr    varchar2(32767) := '';
lv_Sql_TblCreate    varchar2(3000) := '';  
lv_sqlerrm      varchar2(1000) := ''; 
lv_remarks      varchar2(1000) := '';
lv_parvalues    varchar2(1000) := '';
lv_SqlTemp      varchar2 (2000) := '';
lv_Cols         varchar2 (1000) := '';
lv_fn_stdt      date ;
lv_fn_endt      date ;
lv_YearCode     varchar2(10):= '';
lv_FirtstDt     date; 
lv_ProcName     varchar2(30) := 'PROC_PIS_LEAVE_UPDATE';
lv_updtable varchar2(30):='PIS_LEAVE' ;
lv_pf_cont_col varchar2(30) ;
lv_cnt int;
lv_FNYearStartdate varchar2(10) :='';
lv_CalenderYearStartdate varchar2(10) :='';
lv_LeaveSUM VARCHAR2(2000):='';
lv_LeaveComp VARCHAR2(2000):='';
lv_leaveQuery VARCHAR2(2000):='';
lv_strfn_enddt VARCHAR2(20):='';
begin

    lv_fn_stdt := TO_DATE('01/'||SUBSTR(P_EFFECTYEARMONTH,5,2)||'/'||SUBSTR(P_EFFECTYEARMONTH,1,4),'DD/MM/YYYY');   
    lv_fn_endt := last_day(lv_fn_stdt);
    
    SELECT YEARCODE INTO lv_YearCode FROM FINANCIALYEAR
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
      AND STARTDATE <= lv_fn_stdt and ENDDATE >= lv_fn_stdt;
      
   lv_cnt :=0;
    SELECT COUNT(*)
    INTO 
    lv_cnt
    FROM USER_TABLES
    WHERE TABLE_NAME =lv_updtable;
    
    IF lv_cnt>0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE '|| lv_updtable;
    END IF;
    lv_strfn_enddt:=TO_CHAR(lv_fn_endt,'DD/MM/YYYY');
    PROC_PIS_LEAVEBAL(P_COMPCODE,P_DIVCODE,lv_YearCode,lv_strfn_enddt,lv_strfn_enddt);
    
    FOR C1 IN (SELECT LEAVECODE from PISLEAVEMASTER WHERE COMPANYCODE=P_COMPCODE AND DIVISIONCODE=P_DIVCODE AND WITHOUTPAYLEAVE<>'Y' ORDER BY LEAVECODE)
    LOOP
        lv_LeaveSUM:=lv_LeaveSUM||', SUM(LDAY_'||C1.LEAVECODE||') LDAY_'||C1.LEAVECODE||', SUM(LVBL_'||C1.LEAVECODE||') LVBL_'||C1.LEAVECODE;
        IF LENGTH(lv_LeaveComp)> 0 THEN
            lv_LeaveComp:=lv_LeaveComp||',/*LDAY_'||C1.LEAVECODE||',*/LVBL_'||C1.LEAVECODE;
        ELSE
            lv_LeaveComp:='/*LDAY_'||C1.LEAVECODE||',*/LVBL_'||C1.LEAVECODE;
        END IF;
        IF LENGTH(lv_leaveQuery)> 0 THEN
            lv_leaveQuery:=lv_leaveQuery||'UNION ALL'||CHR(10)
                            ||fn_GET_LEAVEQUERRY(P_COMPCODE,P_DIVCODE,C1.LEAVECODE,'GBL_PIS_LEAVEBAL');
        ELSE
            lv_leaveQuery:=fn_GET_LEAVEQUERRY(P_COMPCODE,P_DIVCODE,C1.LEAVECODE,'GBL_PIS_LEAVEBAL');
        END IF;  
           
    
     END LOOP;
     lv_remarks:='CRAEATE TEMP TABLE';
     lv_Sql_TblCreate:='CREATE TABLE '||lv_updtable||CHR(10)
                      ||'AS'||CHR(10)
                      ||'SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL'||lv_LeaveSUM||CHR(10)
                      ||'FROM('||CHR(10)||lv_leaveQuery||'   )'||CHR(10)
                      ||'GROUP BY COMPANYCODE,DIVISIONCODE,WORKERSERIAL'||CHR(10);
                      
     --dbms_output.put_line(lv_Sql_TblCreate ); 
     INSERT INTO PIS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE,PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
        VALUES (P_COMPCODE, P_DIVCODE,lv_ProcName,'',sysdate,lv_Sql_TblCreate,'', lv_fn_stdt, lv_fn_endt, lv_remarks);               
     EXECUTE IMMEDIATE lv_Sql_TblCreate;
     
     lv_remarks:='UPDATE LEAVE';
     lv_sql := 'UPDATE '||P_TABLENAME||' A SET ('||lv_LeaveComp||')  '||CHR(10)  
        ||' = ( SELECT '||lv_LeaveComp||' FROM '||lv_updtable||' B '||CHR(10) 
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.YEARCODE = '''||lv_YearCode||'''   '||CHR(10) 
        ||' AND A.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
        ||' AND A.WORKERSERIAL = B.WORKERSERIAL )'||CHR(10)
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||' AND A.YEARMONTH = '''||P_YEARMONTH||'''       '||CHR(10);
     lv_remarks := NVL(lv_remarks,'XX ') ||' UPDATE LDAY_CL,LDAY_PL,LDAY_SL,LVBL_CL,LVBL_PL,LVBL_SL';
    --dbms_output.put_line(lv_sql );   
   INSERT INTO PIS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
   VALUES (P_COMPCODE, P_DIVCODE,lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
   COMMIT;    
    EXECUTE IMMEDIATE lv_sql;
    
    lv_remarks:='DROP TEMP TABLE';
    EXECUTE IMMEDIATE 'DROP TABLE '||lv_updtable;

EXCEPTION
    WHEN OTHERS THEN
    lv_sqlerrm := sqlerrm;
    INSERT INTO PIS_ERROR_LOG ( COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    VALUES (P_COMPCODE, P_DIVCODE,lv_ProcName,lv_sqlerrm,sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);
end;
/


DROP PROCEDURE PROC_PIS_UPDATE_NA_COMP;

CREATE OR REPLACE PROCEDURE proc_PIS_update_NA_comp( p_yearmonth varchar2, p_phase_table varchar2  ,p_process_table varchar2 DEFAULT NULL, p_UpdateDummytable varchar2 DEFAULT NULL  )
as
lv_updsql varchar2(32767);
lv_tab varchar2(30) := ltrim(trim(upper(p_phase_table)));
-- declare  -- for view creration from outside 
lv_colstr varchar2(32767);
lv_sqlstr varchar2(32767) :=  'CREATE OR REPLACE FORCE VIEW vw_PIS_category_comp_NA as ( '||chr(10) ;
lv_sqlerrm varchar(2000);
lv_remarks varchar(2000);
lv_parvalues varchar2(4000);
lv_c2cnt int ;
lv_cnt2 int := 0;
begin
--------------------- view creation -------------
select count(*) into lv_c2cnt from (
SELECT column_name FROM COLS  WHERE TABLE_NAME = p_phase_table
AND COLUMN_NAME NOT IN( 'YEARMONTH','WORKERSERIAL','UNITCODE','TOKENNO','GRADECODE','CATEGORYCODE') );
for c2 in (
SELECT COLUMN_NAME cn FROM COLS  WHERE TABLE_NAME = p_phase_table
AND COLUMN_NAME NOT IN( 'YEARMONTH','WORKERSERIAL','UNITCODE','TOKENNO','GRADECODE','CATEGORYCODE')) loop
lv_cnt2 := lv_cnt2 +1;
 if  lv_cnt2 = lv_c2cnt then
   lv_sqlstr := lv_sqlstr||' SELECT UNITCODE, GRADECODE , CATEGORYCODE,'''||c2.cn||''' COMPONENTCODE FROM '||p_phase_table||' WHERE '||c2.cn||' > 0 ';
 else
   lv_sqlstr := lv_sqlstr||' SELECT UNITCODE, GRADECODE , CATEGORYCODE, '''||c2.cn||''' COMPONENTCODE FROM '||p_phase_table||' WHERE '||c2.cn||' > 0  UNION  '||CHR(10) ;
 end if;   
 --dbms_output.put_line( lv_sqlstr );
 --lv_sqlstr := v_sqlstr||' SELECT '''||c1.UNITCODE||''' UNITCODE ,'''||c1.GRADECODE||''' GRADECODE ,'''||c1.CATEGORYCODE||''' CATEGORYCODE,'''||c2.cn||''' COMPONENTCODE FROM
end loop ;
lv_sqlstr := lv_sqlstr||chr(10)||' ) MINUS ';
--dbms_output.put_line( lv_sqlstr );
lv_sqlstr := lv_sqlstr||chr(10)||'  SELECT ''01'' UNITCODE , GRADECODE,CATEGORYCODE,COMPONENTCODE '||CHR(10)
                               ||' FROM PISGRADECOMPONENTMAPPING '||CHR(10)
                               ||'   WHERE   '||CHR(10)
                            --   ||'  COMPANYCODE = ''AJ0050'' '||CHR(10)
                            --   ||' AND DIVISIONCODE = ''0001''  '||CHR(10)
                               ||'  YEARMONTH = ( SELECT MAX(YEARMONTH) FROM PISGRADECOMPONENTMAPPING WHERE /*COMPANYCODE = ''AJ0050''  AND DIVISIONCODE = ''0001'' AND*/  YEARMONTH <= '''||p_yearmonth||''')  ';
execute immediate lv_sqlstr;
--dbms_output.put_line(lv_sqlstr);
--return ;
-- end for view creration from outside
----------------------------------------- end view creation -----------
for c1 in( select distinct unitcode, gradecode, categorycode  from vw_PIS_category_comp_NA   ) loop
lv_updsql := 'UPDATE '||lv_tab||' SET ' ;
for c2 in(select column_name cn from cols where table_name = lv_tab
intersect
select COMPONENTCODE cn from vw_PIS_category_comp_NA where  unitcode = c1.unitcode and gradecode = c1.gradecode and CATEGORYCODE = c1.CATEGORYCODE
) loop
lv_updsql := lv_updsql||c2.cn||' = 0 , ' ;
end loop ; -- c2
lv_updsql := lv_updsql||' CATEGORYCODE=CATEGORYCODE where unitcode = '''||c1.unitcode||''' and gradecode = '''||c1.gradecode||''' and CATEGORYCODE = '''||c1.CATEGORYCODE||'''  ';
-- dbms_output.put_line(lv_updsql);
--insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'proc_wps_update_NA_comp',lv_updsql,lv_updsql,'','');
--COMMIT;
execute immediate lv_updsql ;
end loop ; -- c1
--RETURN;
---------------------  update dummy
if p_UpdateDummytable = 'YES' THEN 
    for u1 in(
    select column_name cn from cols where table_name = p_phase_table and column_name not in( 'YEARMONTH','WORKERSERIAL','UNITCODE','TOKENNO','GRADECODE','CATEGORYCODE')
    intersect 
    select column_name cn from cols where table_name = p_process_table and column_name not in( 'YEARMONTH','WORKERSERIAL','UNITCODE','TOKENNO','GRADECODE','CATEGORYCODE' )
    )
    loop
    lv_colstr := lv_colstr||u1.cn||',' ;
    end loop;
    lv_colstr := lv_colstr||' CATEGORYCODE' ;
    lv_updsql := 'update '||p_process_table||' a set ('||lv_colstr||' ) = ( select '||lv_colstr||' from '||p_phase_table||' b '||chr(10) 
                  ||' where a.TOKENNO = b.TOKENNO '||CHR(10)
                  ||' AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
                  ||' AND A.YEARMONTH = B.YEARMONTH '||CHR(10)
                  ||' AND A.UNITCODE = B.UNITCODE '||CHR(10)
                  ||' AND A.GRADECODE = B.GRADECODE '||CHR(10)
                  ||' AND A.CATEGORYCODE = B.CATEGORYCODE )';
 --   insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE,FORTNIGHTENDDATE,REMARKS ) values( 'proc_wps_update_NA_comp','',lv_updsql,'',lv_fn_stdt, lv_fn_endt, p_phase_table);
 --  dbms_output.put_line(lv_updsql);
   execute immediate lv_updsql ;
  -- COMMIT;
end if;     
--------------------- end update dummy 
exception
when others then
 lv_remarks := 'PIS - ERROR' ;
 lv_sqlerrm := sqlerrm ;
 insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) values( 'proc_PIS_update_NA_comp',lv_updsql,lv_sqlstr,lv_parvalues,lv_remarks);
 --dbms_output.put_line(lv_sqlerrm);
 --insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'proc_wps_update_NA_comp',lv_sqlerrm,lv_updsql,'',lv_fn_stdt,lv_fn_endt, p_phase_table);
end;
/


DROP PROCEDURE PROC_PREPARE_PAYSLIPRAWDATAPIS;

CREATE OR REPLACE procedure             proc_prepare_paysliprawdataPIS
(
    p_companycode varchar2,
    p_divisioncode varchar2 ,
    p_yearmonth  varchar2
)
as
    lv_sqlstr varchar2(32767);
    lv_inscolnstr varchar2(32767)   ;
    lv_inscolvstr varchar2(32767)   ;
    lv_maxyearmonth varchar2(6);
    lv_col_name varchar2(30);
    lv_col_name_in_val varchar2(30);
    lv_col_val  varchar2(100);
    lv_fyearcode varchar2(10);
    lv_salarydatefrom varchar2(10);
    lv_salarydateto varchar2(10);
begin
  
  select '01/'||substr(p_yearmonth,-2)||'/'||substr(p_yearmonth,1,4),
       to_char(last_day(  to_date('01/'||substr(p_yearmonth,-2)||substr(p_yearmonth,1,4),'DD/MM/YYYY') ),'dd/mm/yyyy')
       into lv_salarydatefrom,lv_salarydateto
  from dual;
  select yearcode into lv_fyearcode from financialyear 
    where companycode = p_companycode  
    and divisioncode = p_divisioncode
    and to_date('01/'||substr(p_yearmonth,-2)||'/'||substr(p_yearmonth,1,4),'DD/MM/YYYY')  
    between startdate and enddate ; 
    delete PISPAYSLIPRAWDATA  A    
                  WHERE A.COMPANYCODE = p_companycode  
                  AND A.DIVISIONCODE = p_divisioncode                  
                  AND A.YEARMONTH = p_yearmonth ;   
   ---- EARNIMG/DEDUCTION COMPONENT DATA POPULATION ---------
   
    INSERT INTO PISPAYSLIPRAWDATA (ATTN_WRKD, ATTN_SALD, COMPANYNAME, DIVISIONNAME, MON_YR, EMPLOYEENAME, PFNO, ESINO, COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, EFFECT_YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO, TRANSACTIONTYPE, PAYMODE, ATTN_SALD_PPTRANS, ATTN_WPAY, ATTN_ADJD, ATTN_TOTD, ATTN_LDAY, ATTN_CALCF, ATTN_OFFD, ATTN_HOLD, ATTN_WRKD_PPTRANS, LDAY_CL, LDAY_PL, LDAY_SL, LVBL_CL, LVBL_PL, LVBL_SL, LV_ENCASH_DAYS, LV_ENCASH, BASIC, DA, HRA_GROSS, HRA_PER, HRA, PF_GROSS, PEN_GROSS, ESI_GROSS, PTAX_GROSS, PF_E, PF_C, FPF, VPF_PERC, VPF, ESI_E, ESI_C, PTAX, LWF, ITAX, ESI_RT, SARR_ARRE, SARR_ARRD, SARR_PFARRE, SARR_NPFARRE, GROSSEARN, GROSSDEDN, MISC_BF, MISC_CF, TOTEARN, TOTDEDN, NETSALARY, ADHOC, SPL_ALLOW, NS_HRS, OT_HRS, OT_DAYS, NS_ALLOW, OT_AMT, SERV_PERC, SERV_ALW, CONV_PERC, CONV_ALOW, OEPF, OE_NPF, ESI_ADJERN, HRA_PERC, ACT_PF_GRS, LIC, ELECTRIC, MESS, LTP, SUSP_DEDN, MISC_DEDN, HRA_AMT, ADHOC_NPF, OTHR_DEDN, PROF_BONUS, MEDICAL, LTA, LOAN_SPL, LINT_SPL, LNBL_SPL, LIBL_SPL, LNBL_SPL1, LIBL_SPL1, LOAN_STADV, LINT_STADV, LNBL_STADV, LIBL_STADV, LOAN_OTADV, LINT_OTADV, LNBL_OTADV, LIBL_OTADV, LOAN_PJADV, LINT_PJADV, LNBL_PJADV, LIBL_PJADV, LOAN_SA, LINT_SA, LNBL_SA, LIBL_SA, LOAN_FEADV, LINT_FEADV, LNBL_FEADV, LIBL_FEADV, LOAN_OLADV, LINT_OLADV, LNBL_OLADV, LIBL_OLADV, LOAN_PFL, LINT_PFL, LNBL_PFL, LIBL_PFL, ATN_INCAMT, CLUB, DEPARTMENTDESC, DESIGNATIONDESC, TOT_PF_C, TOT_PF_E, TOT_VPF, RT_BASIC, CUMM_DAYS, CUM_PFGROS, OT_HRS_DAY, LEAVE_ENC, AADHARNO,  FORTNIGHTSTARTDATE , FORTNIGHTENDDATE ,  DEPARTMENTNAME , SECTIONCODE , WORKERCATEGORYCODE , WORKERCATEGORYNAME,LOAN_SPL1,LINT_SPL1,ATN_INCNT )
    SELECT ATTN_WRKD,ATTN_SALD, COM.COMPANYNAME,DIV.DIVISIONNAME,TO_CHAR(TO_DATE(B.YEARMONTH, 'YYYYMM'), 'MON-YY') MON_YR, A.EMPLOYEENAME,A.PFNO,A.ESINO,B.COMPANYCODE, 
    B.DIVISIONCODE, B.YEARCODE, B.YEARMONTH, B.EFFECT_YEARMONTH, B.UNITCODE, B.DEPARTMENTCODE, B.CATEGORYCODE, B.GRADECODE, B.WORKERSERIAL,
        B.TOKENNO, B.TRANSACTIONTYPE, B.PAYMODE, B.ATTN_SALD ATTN_SALD_PPTRANS , B.ATTN_WPAY, B.ATTN_ADJD, B.ATTN_TOTD, B.ATTN_LDAY, B.ATTN_CALCF, B.ATTN_OFFD, B.ATTN_HOLD,
         B.ATTN_WRKD ATTN_WRKD_PPTRANS, B.LDAY_CL, B.LDAY_PL, B.LDAY_SL, B.LVBL_CL, B.LVBL_PL, B.LVBL_SL, B.LV_ENCASH_DAYS, B.LV_ENCASH, B.BASIC, B.DA, B.HRA_GROSS, 
         B.HRA_PER, B.HRA, B.PF_GROSS, B.PEN_GROSS,    B.ESI_GROSS, B.PTAX_GROSS, B.PF_E, B.PF_C, B.FPF, B.VPF_PERC, B.VPF, B.ESI_E, B.ESI_C, B.PTAX, B.LWF, 
            B.ITAX, B.ESI_RT, B.SARR_ARRE, B.SARR_ARRD, B.SARR_PFARRE, B.SARR_NPFARRE, B.GROSSEARN, B.GROSSDEDN, B.MISC_BF,B.MISC_CF, B.TOTEARN, B.TOTDEDN, B.NETSALARY, 
        B.ADHOC, B.SPL_ALLOW, B.NS_HRS, NVL(B.OT_HRS,0)OT_HRS, NVL(B.OT_DAYS,0)OT_DAYS, B.NS_ALLOW, B.OT_AMT, B.SERV_PERC, B.SERV_ALW, B.CONV_PERC, B.CONV_ALOW, 
        B.OEPF, B.OE_NPF, B.ESI_ADJERN, B.HRA_PERC, B.ACT_PF_GRS, B.LIC, B.ELECTRIC,B.MESS, B.LTP, B.SUSP_DEDN, B.MISC_DEDN, B.HRA_AMT, B.ADHOC_NPF, B.OTHR_DEDN, 
        B.PROF_BONUS, B.MEDICAL, B.LTA, B.LOAN_SPL, B.LINT_SPL, NVL(B.LNBL_SPL,0)LNBL_SPL, NVL(B.LIBL_SPL,0)LIBL_SPL,NVL(B.LNBL_SPL1,0)LNBL_SPL1, 
        NVL(B.LIBL_SPL1,0)LIBL_SPL1,  B.LOAN_STADV, B.LINT_STADV, B.LNBL_STADV, B.LIBL_STADV, B.LOAN_OTADV, B.LINT_OTADV, 
        B.LNBL_OTADV, B.LIBL_OTADV, B.LOAN_PJADV, B.LINT_PJADV, B.LNBL_PJADV, B.LIBL_PJADV, B.LOAN_SA, B.LINT_SA, B.LNBL_SA, B.LIBL_SA, 
        B.LOAN_FEADV, B.LINT_FEADV, B.LNBL_FEADV, B.LIBL_FEADV, B.LOAN_OLADV, B.LINT_OLADV, B.LNBL_OLADV, B.LIBL_OLADV, B.LOAN_PFL, 
        B.LINT_PFL, B.LNBL_PFL, B.LIBL_PFL, B.ATN_INCAMT,B.CLUB, C.DEPARTMENTDESC,D.DESIGNATIONDESC,NVL(B.CUMM_PF_C,0) TOT_PF_C,NVL(B.CUMM_PF_E,0) TOT_PF_E,
        NVL(B.CUMM_VPF,0) TOT_VPF,NVL(B.RT_BASIC,0) RT_BASIC,CUMM_DAYS,CUM_PFGROS, NVL(B.OT_HRS,0)/8 OT_HRS_DAY
        ,LEAVE_ENC, A.AADHARNO ,  to_date(lv_salarydatefrom,'DD/MM/YYYY') , to_date(lv_salarydateto,'DD/MM/YYYY') ,   
    SUBSTR(C.DEPARTMENTDESC,1,50) DEPARTMENTNAME , 'N/A' AS SECTIONCODE ,  WCAT.CATEGORYCODE ,  SUBSTR(WCAT.CATEGORYDESC,1,50),B.LOAN_SPL1, B.LINT_SPL1,B.ATN_INCNT
    FROM PISEMPLOYEEMASTER A,PISPAYTRANSACTION B,PISDEPARTMENTMASTER C,PISDESIGNATIONMASTER D,COMPANYMAST COM, DIVISIONMASTER DIV , PISCATEGORYMASTER WCAT
    WHERE A.COMPANYCODE = p_companycode AND A.DIVISIONCODE = p_divisioncode 
      AND A.COMPANYCODE = B.COMPANYCODE
      AND A.DIVISIONCODE=B.DIVISIONCODE
      AND A.WORKERSERIAL=B.WORKERSERIAL
      AND B.YEARMONTH=p_yearmonth
      AND A.COMPANYCODE=C.COMPANYCODE
      AND A.DIVISIONCODE=C.DIVISIONCODE
      AND A.DEPARTMENTCODE=C.DEPARTMENTCODE
      AND A.COMPANYCODE=D.COMPANYCODE
      AND A.DIVISIONCODE=D.DIVISIONCODE
      AND A.DESIGNATIONCODE=D.DESIGNATIONCODE
      AND A.COMPANYCODE=COM.COMPANYCODE
      AND A.COMPANYCODE=DIV.COMPANYCODE
      AND A.DIVISIONCODE=DIV.DIVISIONCODE
      AND A.COMPANYCODE = WCAT.COMPANYCODE
      AND A.DIVISIONCODE= WCAT.DIVISIONCODE
      AND A.CATEGORYCODE = WCAT.CATEGORYCODE
      AND B.TRANSACTIONTYPE='SALARY'
    --  and B.WORKERSERIAL IN('013982')
    ORDER BY B.TOKENNO ;
end;
/


DROP PROCEDURE PROC_PREPARE_PRINT_DATA_PIS;

CREATE OR REPLACE PROCEDURE             PROC_PREPARE_PRINT_DATA_PIS
(
 p_company varchar2 ,
 p_division varchar2,
 p_yearcode varchar2,
 p_fnstdt   varchar2,
 p_fnendt   varchar2,
 p_dept     varchar2 DEFAULT NULL, 
 p_workerserial varchar2 DEFAULT NULL
)
 as
  lv_fnstdt date := to_date(p_fnstdt,'DD/MM/YYYY') ;
  lv_fnendt date := to_date(p_fnendt,'DD/MM/YYYY') ;
  lv_payslip_row_str varchar2(50);
  lv_fyearcode varchar2(10);
  lv_yearmonth varchar2(10) := substr(p_fnstdt,-4)||substr(p_fnstdt,4,2) ;
  lv_PRINTROWSEQ int;
  lv_sql VARCHAR2(4000);
  /*      BEGIN
        PROC_PREPARE_PRINT_DATA_PIS
        (
          '0001' ,
         '0005',
         '2018-2019',
         '01/01/2018',
         '31/01/2018'
        ); 
        END; */
  -- '''02971'',''02642''' 
BEGIN
    select yearcode into lv_fyearcode from financialyear 
    where companycode = p_company  
    and divisioncode = p_division
    and to_date(p_fnstdt,'DD/MM/YYYY')  between startdate and enddate ; 

     if length(p_fnstdt) <> 10 or length(p_fnendt) <> 10 then
      raise_application_error(-20101,'date parameters should be in DD/MM/YYYY format  ');   
     end if;
      if p_fnstdt <> '01'||substr(p_fnstdt,3) then
      raise_application_error(-20101,'start date should be first day of the month in DD/MM/YYYY format');    
     end if;
     --if p_fnendt <> to_char(last_day(to_date(p_fnstdt,'DD/MM/YYYY')),'DD/MM/YYYY') then
      --raise_application_error(-20101,'end date should be last day of the month in DD/MM/YYYY format');    
     --end if;
     /*delete FROM PISPAYSILPPRINTDATA  
     WHERE companycode = p_company
     and divisioncode = p_division  
     and yearcode = lv_yearmonth 
     and FORTNIGHTSTARTDATE = to_date(p_fnstdt,'DD/MM/YYYY')
     and FORTNIGHTENDDATE   = to_date(p_fnendt,'DD/MM/YYYY') ;   */     
     delete FROM WPSPAYSILPPRINTDATA  
     WHERE companycode = p_company
     and divisioncode = p_division  
     and yearcode = lv_fyearcode 
     and FORTNIGHTSTARTDATE = to_date(p_fnstdt,'DD/MM/YYYY')
     and FORTNIGHTENDDATE   = to_date(p_fnendt,'DD/MM/YYYY') ;    
--    return
    lv_sql := 'DROP SEQUENCE SEQ_PAYSLIPROW ';
    BEGIN
    execute immediate lv_sql ;
    EXCEPTION
     WHEN OTHERS THEN
     NULL;
    END;    
    lv_sql := 'CREATE SEQUENCE SEQ_PAYSLIPROW   START WITH 1  MAXVALUE 1000000000  MINVALUE 1  CYCLE  CACHE 100  NOORDER ' ;
    BEGIN
     execute immediate lv_sql ;
    EXCEPTION
     WHEN OTHERS THEN
     NULL;
    END; 
      
  for c1 in ( select distinct COMPANYCODE, DIVISIONCODE, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, DEPARTMENTCODE, TOKENNO , WORKERSERIAL from  PISPAYSLIPRAWDATA 
              where companycode = p_company
                 and divisioncode = p_division
                 and yearmonth = lv_yearmonth 
                 and FORTNIGHTSTARTDATE = to_date(p_fnstdt,'DD/MM/YYYY')
                 and FORTNIGHTENDDATE   = to_date(p_fnendt,'DD/MM/YYYY')               
            ) loop
       --- for testing ---   
       
      lv_PRINTROWSEQ := SEQ_PAYSLIPROW.nextval;
     -- insert into PISPAYSILPPRINTDATA( COMPANYCODE, DIVISIONCODE, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, DEPARTMENTCODE, WORKERSERIAL, TOKENNO, PRINTROWSEQ , PRINTROWSTR )
     --  VALUES( c1.COMPANYCODE  ,c1.DIVISIONCODE,c1.YEARCODE, c1.FORTNIGHTSTARTDATE , c1.FORTNIGHTENDDATE,c1.DEPARTMENTCODE,c1.WORKERSERIAL,c1.tokenno  ,lv_PRINTROWSEQ,lv_payslip_row_str) ;
      -- end for testing --           
      for c2 in ( select distinct ROW_INDEX, ROW_PRINT_WIDTH from PISPAYSLIP_PRINT_PARAMS where COL_PRINT_INCLUDE = 'Y'  order by ROW_INDEX ) loop
         lv_PRINTROWSEQ := SEQ_PAYSLIPROW.nextval;
         lv_payslip_row_str := fn_prepare_print_row_PIS( c1.COMPANYCODE  ,c1.DIVISIONCODE,c1.YEARCODE, to_char(c1.FORTNIGHTSTARTDATE,'DD/MM/YYYY') , to_char(c1.FORTNIGHTENDDATE,'DD/MM/YYYY'),c1.DEPARTMENTCODE,c1.WORKERSERIAL,c2.ROW_INDEX,c2.ROW_PRINT_WIDTH) ;  
       --dbms_output.put_line('lv_payslip_row_str'||c2.ROW_INDEX||' - '||length(lv_payslip_row_str)) ;
        /* insert into PISPAYSILPPRINTDATA( COMPANYCODE, DIVISIONCODE, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, DEPARTMENTCODE, WORKERSERIAL, TOKENNO, PRINTROWSEQ, PRINTROWSTR )
                                 VALUES( c1.COMPANYCODE  ,c1.DIVISIONCODE,c1.YEARCODE, c1.FORTNIGHTSTARTDATE , c1.FORTNIGHTENDDATE,c1.DEPARTMENTCODE,c1.WORKERSERIAL,c1.tokenno  ,lv_PRINTROWSEQ,lv_payslip_row_str);  */                       
         insert into WPSPAYSILPPRINTDATA( COMPANYCODE, DIVISIONCODE, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, DEPARTMENTCODE, WORKERSERIAL, TOKENNO, PRINTROWSEQ, PRINTROWSTR )
                                 VALUES( c1.COMPANYCODE  ,c1.DIVISIONCODE,lv_fyearcode, c1.FORTNIGHTSTARTDATE , c1.FORTNIGHTENDDATE,c1.DEPARTMENTCODE,c1.WORKERSERIAL,c1.tokenno  ,lv_PRINTROWSEQ,lv_payslip_row_str);
      end loop;  
  end loop; 
  commit;
end;
/


DROP PROCEDURE PROC_RPT_ACTUARIAL_PLSTL_PIS;

CREATE OR REPLACE PROCEDURE             PROC_RPT_ACTUARIAL_PLSTL_PIS
(
    P_COMPANY               VARCHAR2,
    P_DIVISION              VARCHAR2,
    P_YEARCODE              VARCHAR2,
    P_CURRENTDATE           VARCHAR2,
    P_REPORTOPTION          VARCHAR2,
    P_TOKENNO               VARCHAR2,
    P_TEMPTABLENAME         VARCHAR2
)
AS
    LV_STRSQL           VARCHAR2(30000);
    LV_CURRENTYEARMONTH      VARCHAR2(10) :=  TO_CHAR(TO_DATE(P_CURRENTDATE,'DD/MM/YYYY'),'YYYYMM');
    LV_CURRENTMONTH_YEAR     VARCHAR2(10)  :=  TO_CHAR(TO_DATE(P_CURRENTDATE,'DD/MM/YYYY'),'MM_YY');
    LV_CURRENTJANMONTH       VARCHAR2(10) :=   SUBSTR(LV_CURRENTYEARMONTH,1,4) || '01';
    LV_CURRENTAPRMONTH       VARCHAR2(10) :=   SUBSTR(P_YEARCODE,1,4) || '04';
BEGIN
       
/******************************************************************************
   NAME:      Prasun
   Date :     04.01.2020
   Implementing for Gloster Jute Mills 
******************************************************************************/
     

    LV_STRSQL :='   CREATE TABLE  GTT_ACTUARIAL_PLSTL_PIS AS '|| CHR(10) 
   || '  SELECT TOKENNO,EMPLOYEENAME NAME, TO_CHAR(DATEOFBIRTH,''DD/MM/YYYY'') DATEOFBIRTH, TO_CHAR(DATEOFJOIN,''DD/MM/YYYY'') EMPLOYEEDATEOFJOINING, '|| CHR(10) 
   || '  SAL_'||LV_CURRENTMONTH_YEAR||',  AGE RET_AGE,ENTITLEMENTS MX_ENT,ACCUMULATION MX_ACCUM, OPENING, AVAILED,    '|| CHR(10)
   || '  CASE WHEN LEAVECALENDARORFINYRWISE=''F'' THEN ENTITLEMENTS ELSE ROUND((ENTITLEMENTS*3)/12,0) END AS PL_LV_PROPDAY ,  '|| CHR(10) 
   || '  LV_EN_DAYS,LV_ENCASH, LEAVECALENDARORFINYRWISE LEAVE_TAG   '|| CHR(10)
   || '   FROM (    '|| CHR(10)
   || '       SELECT L.CATEGORYCODE,L.GRADECODE, H.TOKENNO,L.WORKERSERIAL,ENTITLEMENTS, OPENING, E.ACCUMULATION, AVAILED,LV_EN_DAYS,LV_ENCASH,L.EMPLOYEENAME,L.DATEOFBIRTH,L.DATEOFJOIN,SUBSTR(DIVISIONNAME,1,15) DIVISIONNAME,  '|| CHR(10)  
   || '       L.SEX,CASE WHEN L.DIVISIONCODE IN(''0001'',''0004'',''0006'') THEN ''60'' ELSE CASE WHEN SEX=''MALE'' THEN ''58'' ELSE ''55'' END END AGE,   '|| CHR(10)
   || '       SAL_'||LV_CURRENTMONTH_YEAR||',''PIS'' MODULE, LEAVECALENDARORFINYRWISE   '|| CHR(10)
   || '      FROM   '|| CHR(10)
   || '       (  '|| CHR(10)
   || '       SELECT TOKENNO, SUM(SAL_'||LV_CURRENTMONTH_YEAR||') SAL_'||LV_CURRENTMONTH_YEAR||'  '|| CHR(10)
   || '       FROM (      '|| CHR(10)
   || '        SELECT  X.YEARMONTH,A.TOKENNO, SUM(NVL(BASIC,0)+NVL(DA,0)+NVL(ADHOC,0)) SAL_'||LV_CURRENTMONTH_YEAR||'  '|| CHR(10)
   || '               FROM PISCOMPONENTASSIGNMENT A,   '|| CHR(10)
   || '               (   '|| CHR(10)
   || '                   SELECT TOKENNO, MAX(YEARMONTH) YEARMONTH  '|| CHR(10)  
   || '                   FROM PISCOMPONENTASSIGNMENT P   '|| CHR(10)
   || '                   WHERE YEARMONTH <= '''||LV_CURRENTYEARMONTH||'''   '|| CHR(10)
   || '                   AND TRANSACTIONTYPE=''ASSIGNMENT''   '|| CHR(10);
    IF P_TOKENNO IS NOT NULL THEN
          LV_STRSQL := LV_STRSQL ||'       AND   P.TOKENNO IN  ('||P_TOKENNO||')   '|| CHR(10);
    END IF;
   LV_STRSQL := LV_STRSQL ||'                   GROUP BY TOKENNO   '|| CHR(10)
   || '               ) X   '|| CHR(10)
   || '             WHERE   A.TOKENNO = X.TOKENNO  '|| CHR(10)  
   || '               AND A.YEARMONTH = X.YEARMONTH   '|| CHR(10)
   || '               AND TRANSACTIONTYPE=''ASSIGNMENT''   '|| CHR(10);
    IF P_TOKENNO IS NOT NULL THEN
        LV_STRSQL := LV_STRSQL ||'                AND   X.TOKENNO IN  ('||P_TOKENNO||')  '|| CHR(10);
    END IF;
   LV_STRSQL := LV_STRSQL ||'                GROUP BY A.TOKENNO,X.YEARMONTH   '|| CHR(10)
   || '                Union All   '|| CHR(10)
   || '                SELECT A.YEARMONTH, A.TOKENNO , DA SAL_'||LV_CURRENTMONTH_YEAR||'  '|| CHR(10) 
   || '                FROM PISCOMPONENTASSIGNMENT A,   '|| CHR(10)
   || '                     (   '|| CHR(10)
   || '                         SELECT TOKENNO , MAX(YEARMONTH)YEARMONTH  '|| CHR(10) 
   || '                         From PISCOMPONENTASSIGNMENT  WHERE 1 = 1'|| CHR(10);
    IF P_TOKENNO IS NOT NULL THEN
          LV_STRSQL := LV_STRSQL ||'                         AND   TOKENNO IN  ('||P_TOKENNO||')   '|| CHR(10);
    END IF;
    LV_STRSQL := LV_STRSQL ||'                         GROUP BY TOKENNO   '|| CHR(10)
   || '                     ) B   '|| CHR(10)
   || '               WHERE  A.YEARMONTH = B.YEARMONTH  '|| CHR(10) 
   || '                 AND A.TOKENNO = B.TOKENNO   '|| CHR(10);
    IF P_TOKENNO IS NOT NULL THEN
        LV_STRSQL := LV_STRSQL ||'                AND   B.TOKENNO IN  ('||P_TOKENNO||')  '|| CHR(10);
    END IF;
    LV_STRSQL := LV_STRSQL ||'           )    '|| CHR(10)
   || '       GROUP BY TOKENNO   '|| CHR(10)
   || '      )H,   '|| CHR(10)
   || '      (    '|| CHR(10)
   || '         SELECT TOKENNO, ENTITLEMENTS , CARRYFORWARD ACCUMULATION  '|| CHR(10) 
   || '         FROM PISLEAVEENTITLEMENT   '|| CHR(10)
   || '         WHERE TOKENNO||EFFECTIVEDATE IN (   '|| CHR(10)
   || '                                   SELECT TOKENNO||MAX(EFFECTIVEDATE)  '|| CHR(10)  
   || '                                   FROM PISLEAVEENTITLEMENT   '|| CHR(10)
   || '                                   WHERE COMPANYCODE = '''||P_COMPANY||''' AND DIVISIONCODE = '''||P_DIVISION||''' AND LEAVECODE =''PL''  '|| CHR(10) 
   || '                                   AND EFFECTIVEDATE <= TO_DATE('''||P_CURRENTDATE||''' ,''DD/MM/YYYY'')  '|| CHR(10);
    IF P_TOKENNO IS NOT NULL THEN
          LV_STRSQL := LV_STRSQL ||'       AND   TOKENNO IN  ('||P_TOKENNO||')   '|| CHR(10);
    END IF;
   LV_STRSQL := LV_STRSQL ||'          GROUP BY TOKENNO   '|| CHR(10)
   || '                                 )     '|| CHR(10)
   || '         AND LEAVECODE = ''PL''           '|| CHR(10);
    IF P_TOKENNO IS NOT NULL THEN
          LV_STRSQL := LV_STRSQL ||'       AND   TOKENNO IN  ('||P_TOKENNO||')   '|| CHR(10);
    END IF;
   LV_STRSQL := LV_STRSQL ||'     )E,   '|| CHR(10)
   || ' ( SELECT TOKENNO,WORKERSERIAL, EMPLOYEENAME,0 ENTITLEMENT,0 ACCUMULATION, PLBAL OPENING, LEAVECALENDARORFINYRWISE,  '|| CHR(10)  
   || ' CASE WHEN LEAVECALENDARORFINYRWISE = ''F'' THEN APR_PLAVAILED ELSE JAN_PLAVAILED END AVAILED, 0 PROPDAY, LV_EN_DAYS,LV_ENCASH   '|| CHR(10)
   || ' FROM    '|| CHR(10)
   || '  (   '|| CHR(10)
   || '     SELECT A.TOKENNO, A.WORKERSERIAL, EMPLOYEENAME, A.CATEGORYCODE, LEAVECALENDARORFINYRWISE, YEARMONTH,  '|| CHR(10)   
   || '     PLBAL,APR_PLAVAILED, JAN_PLAVAILED,LV_EN_DAYS,LV_ENCASH,   '|| CHR(10)
   || '     CASE WHEN LEAVECALENDARORFINYRWISE=''F'' THEN '''||LV_CURRENTAPRMONTH||'''   '|| CHR(10)
   || '         ELSE   '|| CHR(10)
   || '             '''||LV_CURRENTJANMONTH||'''   '|| CHR(10)
   || '     END CALC_YEARMONTH   '|| CHR(10)
   || '     FROM PISEMPLOYEEMASTER A, PISCATEGORYMASTER B,  '|| CHR(10) 
   || '     (   '|| CHR(10)
   || '         SELECT TOKENNO, YEARMONTH, SUM(PLBAL)+SUM(PLDAY)PLBAL, SUM(APR_PLAVAILED) APR_PLAVAILED, SUM(JAN_PLAVAILED) JAN_PLAVAILED,  '|| CHR(10) 
   || '         SUM(LV_EN_DAYS) LV_EN_DAYS,SUM(LV_ENCASH) LV_ENCASH   '|| CHR(10)
   || '         FROM (   '|| CHR(10)
   || '          SELECT A.TOKENNO, A.YEARMONTH, NVL(LVBL_PL,0) PLBAL, NVL(LDAY_PL,0)+NVL(LVENCSH_DAYS,0) PLDAY,  '|| CHR(10) 
   || '             0 APR_PLAVAILED, 0 JAN_PLAVAILED,0 LV_EN_DAYS,0 LV_ENCASH    '|| CHR(10)
   || '             FROM PISPAYTRANSACTION A     '|| CHR(10)
   || '             WHERE COMPANYCODE = '''||P_COMPANY||''' AND COMPANYCODE = '''||P_DIVISION||'''  '|| CHR(10)
   || '             AND YEARMONTH = '''||LV_CURRENTAPRMONTH||'''   '|| CHR(10);
   IF P_TOKENNO IS NOT NULL THEN
          LV_STRSQL := LV_STRSQL ||'       AND   TOKENNO IN  ('||P_TOKENNO||')   '|| CHR(10);
   END IF;
   LV_STRSQL := LV_STRSQL ||'             UNION ALL   '|| CHR(10)
   || '         SELECT A.TOKENNO, A.YEARMONTH, NVL(LVBL_PL,0) PLBAL, NVL(LDAY_PL,0) PLDAY,  '|| CHR(10)        
   || '             0 APR_PLAVAILED, 0 JAN_PLAVAILED,0 LV_EN_DAYS,0 LV_ENCASH    '|| CHR(10)
   || '             FROM PISPAYTRANSACTION A    '|| CHR(10)
   || '             WHERE COMPANYCODE = '''||P_COMPANY||''' AND COMPANYCODE = '''||P_DIVISION||'''  '|| CHR(10)
   || '             AND YEARMONTH = '''||LV_CURRENTJANMONTH||'''   '|| CHR(10);
   IF P_TOKENNO IS NOT NULL THEN
          LV_STRSQL := LV_STRSQL ||'       AND   A.TOKENNO IN  ('||P_TOKENNO||')   '|| CHR(10);
   END IF;
   LV_STRSQL := LV_STRSQL ||'             UNION ALL   '|| CHR(10)
   || '         SELECT A.TOKENNO, '''||LV_CURRENTAPRMONTH||'''  YEARMONTH, 0 PLBAL, 0 PLDAY,  '|| CHR(10)  
   || '             SUM(NVL(A.LDAY_PL,0)) APR_PLAVAILED, 0 JAN_PLAVAILED,0 LV_EN_DAYS,0 LV_ENCASH  '|| CHR(10)  
   || '             FROM PISPAYTRANSACTION A    '|| CHR(10)
   || '             WHERE COMPANYCODE = '''||P_COMPANY||''' AND COMPANYCODE = '''||P_DIVISION||'''  '|| CHR(10)
   || '             AND TO_NUMBER(YEARMONTH) >= '''||LV_CURRENTAPRMONTH||''' AND TO_NUMBER(YEARMONTH) <= '''||LV_CURRENTYEARMONTH||'''  '|| CHR(10); 
   IF P_TOKENNO IS NOT NULL THEN
          LV_STRSQL := LV_STRSQL ||'       AND   A.TOKENNO IN  ('||P_TOKENNO||')   '|| CHR(10);
   END IF;
   LV_STRSQL := LV_STRSQL ||'             GROUP BY TOKENNO   '|| CHR(10)
   || '             UNION ALL       '|| CHR(10)
   || '         SELECT A.TOKENNO, '''||LV_CURRENTJANMONTH||''' YEARMONTH, 0 PLBAL, 0 PLDAY,  '|| CHR(10)  
   || '             0 APR_PLAVAILED, SUM(NVL(LDAY_PL,0)) JAN_PLAVAILED,0 LV_EN_DAYS,0 LV_ENCASH  '|| CHR(10)  
   || '             FROM PISPAYTRANSACTION A    '|| CHR(10)
   || '             WHERE COMPANYCODE = '''||P_COMPANY||''' AND COMPANYCODE = '''||P_DIVISION||'''  '|| CHR(10)
   || '             AND TO_NUMBER(YEARMONTH) >= '''||LV_CURRENTJANMONTH||''' AND TO_NUMBER(YEARMONTH) <= '''||LV_CURRENTYEARMONTH||'''  '|| CHR(10); 
   IF P_TOKENNO IS NOT NULL THEN
          LV_STRSQL := LV_STRSQL ||'       AND   A.TOKENNO IN  ('||P_TOKENNO||')   '|| CHR(10);
   END IF;
   LV_STRSQL := LV_STRSQL ||'             GROUP BY TOKENNO   '|| CHR(10)
   || '             UNION ALL   '|| CHR(10)
   || '         SELECT A.TOKENNO, '''||LV_CURRENTAPRMONTH||''' YEARMONTH, 0 PLBAL, 0 PLDAY,  '|| CHR(10)  
   || '             0 APR_PLAVAILED, 0 JAN_PLAVAILED, SUM(NVL(LVENCSH_DAYS,0)) LV_EN_DAYS,0 LV_ENCASH  '|| CHR(10)  
   || '             FROM PISPAYTRANSACTION A    '|| CHR(10)
   || '             WHERE COMPANYCODE = '''||P_COMPANY||''' AND DIVISIONCODE ='''||P_DIVISION||'''  '|| CHR(10)  
   || '             AND TO_NUMBER(YEARMONTH) >= '''||LV_CURRENTAPRMONTH||'''  '|| CHR(10)
   || '             AND TO_NUMBER(YEARMONTH) <= '''||LV_CURRENTYEARMONTH||'''   '|| CHR(10);
   IF P_TOKENNO IS NOT NULL THEN
          LV_STRSQL := LV_STRSQL ||'       AND   A.TOKENNO IN  ('||P_TOKENNO||')   '|| CHR(10);
   END IF;
   LV_STRSQL := LV_STRSQL ||'             GROUP BY TOKENNO   '|| CHR(10)
   || '             UNION ALL  '|| CHR(10)
   || '         SELECT A.TOKENNO, '''||LV_CURRENTJANMONTH||''' YEARMONTH, 0 PLBAL, 0 PLDAY,  '|| CHR(10)  
   || '             0 APR_PLAVAILED, 0 JAN_PLAVAILED, SUM(NVL(A.LVENCSH_DAYS,0)) LV_EN_DAYS,0 LV_ENCASH  '|| CHR(10)  
   || '             FROM PISPAYTRANSACTION A    '|| CHR(10)
   || '             WHERE COMPANYCODE = '''||P_COMPANY||''' AND COMPANYCODE = '''||P_DIVISION||'''  '|| CHR(10)
   || '             AND TO_NUMBER(YEARMONTH) >= '''||LV_CURRENTJANMONTH||'''  '|| CHR(10)
   || '             AND TO_NUMBER(YEARMONTH) <= '''||LV_CURRENTYEARMONTH||'''   '|| CHR(10);
   IF P_TOKENNO IS NOT NULL THEN
          LV_STRSQL := LV_STRSQL ||'       AND   A.TOKENNO IN  ('||P_TOKENNO||')   '|| CHR(10);
   END IF;
   LV_STRSQL := LV_STRSQL ||'            GROUP BY TOKENNO   '|| CHR(10)
   || '             UNION ALL   '|| CHR(10)
   || '         SELECT A.TOKENNO, '''||LV_CURRENTAPRMONTH||''' YEARMONTH, 0 PLBAL, 0 PLDAY,  '|| CHR(10)  
   || '             0 APR_PLAVAILED, 0 JAN_PLAVAILED,0 LV_EN_DAYS,SUM(NVL(LEAVE_ENC,0)) LV_ENCASH  '|| CHR(10)  
   || '             FROM PISPAYTRANSACTION A    '|| CHR(10)
   || '             WHERE COMPANYCODE = '''||P_COMPANY||''' AND COMPANYCODE = '''||P_DIVISION||'''  '|| CHR(10)
   || '             AND TO_NUMBER(YEARMONTH) >= '''||LV_CURRENTAPRMONTH||'''  '|| CHR(10)
   || '             AND TO_NUMBER(YEARMONTH) <= '''||LV_CURRENTYEARMONTH||'''    '|| CHR(10);
    IF P_TOKENNO IS NOT NULL THEN
          LV_STRSQL := LV_STRSQL ||'       AND   A.TOKENNO IN  ('||P_TOKENNO||')   '|| CHR(10);
   END IF;
   LV_STRSQL := LV_STRSQL ||'             GROUP BY TOKENNO     '|| CHR(10)
   || '             UNION ALL   '|| CHR(10)
   || '         SELECT A.TOKENNO,  '''||LV_CURRENTJANMONTH||''' YEARMONTH, 0 PLBAL, 0 PLDAY,  '|| CHR(10)  
   || '             0 APR_PLAVAILED, 0 JAN_PLAVAILED,0 LV_EN_DAYS,SUM(NVL(LEAVE_ENC,0)) LV_ENCASH  '|| CHR(10)    
   || '             FROM PISPAYTRANSACTION A    '|| CHR(10)
   || '             WHERE COMPANYCODE = '''||P_COMPANY||''' AND COMPANYCODE = '''||P_DIVISION||'''  '|| CHR(10)
   || '             AND TO_NUMBER(YEARMONTH) >= '''||LV_CURRENTJANMONTH||'''  '|| CHR(10)
   || '             AND TO_NUMBER(YEARMONTH) <= '''||LV_CURRENTYEARMONTH||'''   '|| CHR(10);
   IF P_TOKENNO IS NOT NULL THEN
          LV_STRSQL := LV_STRSQL ||'       AND   A.TOKENNO IN  ('||P_TOKENNO||')   '|| CHR(10);
   END IF;
   LV_STRSQL := LV_STRSQL ||'             GROUP BY TOKENNO     '|| CHR(10)
   || '             )   '|| CHR(10)
   || '         GROUP BY TOKENNO, YEARMONTH  '|| CHR(10)  
   || '     ) X    '|| CHR(10)
   || '     WHERE A.COMPANYCODE = '''||P_COMPANY||''' AND A.COMPANYCODE = '''||P_DIVISION||'''  '|| CHR(10)
   || '     AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE  '|| CHR(10) 
   || '     AND A.CATEGORYCODE = B.CATEGORYCODE   '|| CHR(10)
   || '     AND A.TOKENNO = X.TOKENNO   '|| CHR(10);
   IF P_TOKENNO IS NOT NULL THEN
          LV_STRSQL := LV_STRSQL ||'       AND   X.TOKENNO IN  ('||P_TOKENNO||')   '|| CHR(10);
   END IF;
   LV_STRSQL := LV_STRSQL ||'     ORDER BY TOKENNO  '|| CHR(10)
   || '  ) WHERE CALC_YEARMONTH = YEARMONTH  '|| CHR(10) 
   || ' )S,PISEMPLOYEEMASTER L, DIVISIONMASTER M   '|| CHR(10)
   || '  WHERE L.TOKENNO = H.TOKENNO (+)  '|| CHR(10)
   || '    AND L.TOKENNO = S.TOKENNO (+)  '|| CHR(10)
   || '    AND L.TOKENNO = E.TOKENNO (+)   '|| CHR(10)
   || '  AND L.GRADECODE IN(''SREG'',''OSREG'',''01'',''02'',''03'',''04'',''MOREG'',''MREG'')  '|| CHR(10)
   || '  AND (L.STATUSDATE IS NULL OR L.STATUSDATE >= TO_DATE('''||P_CURRENTDATE||''' ,''DD/MM/YYYY''))  '|| CHR(10)
   || '  AND L.DATEOFJOIN<=TO_DATE('''||P_CURRENTDATE||''' ,''DD/MM/YYYY'')  '|| CHR(10)
   || ' AND L.GRATUITYAPPLICABLE=''Y''  '|| CHR(10)
   || ' AND L.COMPANYCODE = M.COMPANYCODE AND L.DIVISIONCODE = M.DIVISIONCODE  '|| CHR(10) 
   || ' )   '|| CHR(10);

    --   DBMS_OUTPUT.PUT_LINE(LV_STRSQL);
      EXECUTE IMMEDIATE LV_STRSQL;    
      
        
--    
     LV_STRSQL := 'SELECT ROWNUM AS SRL, A.* FROM (SELECT * FROM GTT_ACTUARIAL_PLSTL_PIS ORDER BY TOKENNO) A'; 
--     
--    
--    -- DBMS_OUTPUT.PUT_LINE(LV_STRSQL);
     proc_GenerateExcel(P_TEMPTABLENAME,LV_STRSQL) ;
--    
--     
     EXECUTE IMMEDIATE 'DROP TABLE GTT_ACTUARIAL_PLSTL_PIS';    
     
     
end;
/


DROP PROCEDURE PROC_RPT_PISSALABSTRACT;

CREATE OR REPLACE PROCEDURE             PROC_RPT_PISSALABSTRACT
(
    P_COMPANYCODE   VARCHAR2,
    P_DIVISIONCODE  VARCHAR2,
    P_YEARMONTH     VARCHAR2,
    P_CATEGORYCODE  VARCHAR2 DEFAULT NULL,
    P_GRADE         VARCHAR2 DEFAULT NULL,
    P_DEPARTMENT    VARCHAR2 DEFAULT NULL,
    P_OPTION        VARCHAR2  
)
AS 
/******************************************************************************
   NAME:      Chiranjit Ghosh
   PURPOSE:  PIS/Salary Abstract
   Date :    30.07.2019
     
   Modified by : Ujjwal
   Modified by : Ujjwal xx Ghosh on 20.01.2020   
  
   NOTES:
   Implementing for Gloster Jute Mills 
******************************************************************************/

    P_FROMDATE     VARCHAR2(20);
    LV_SQLSTR      VARCHAR2(32000);       
    REPMONTH       VARCHAR2(20);
   
    LV_SLNO INT;
    LV_CNT INT;
    LV_COMP   VARCHAR2(100):='';
    LV_CATEGORYCODEMERGE  VARCHAR2(1000):='';
    LV_GRADECODEMERGE  VARCHAR2(1000):='';
   
BEGIN

--IF P_CATEGORYCODE IS NULL AND P_GRADE IS NULL THEN
--    PROC_RPT_PISSALABSTRACT(P_COMPANYCODE,P_DIVISIONCODE,P_YEARMONTH,P_CATEGORYCODE);
--    RETURN;
--END IF;
        SELECT TO_CHAR(TO_DATE(''||P_YEARMONTH||'','YYYYMM'),'DD/MM/YYYY') INTO  P_FROMDATE FROM DUAL;
        
        SELECT TRIM(TO_CHAR(TO_DATE(''|| P_FROMDATE ||'','DD/MM/YYYY'),'MONTH')) ||'-'||TO_CHAR(TO_DATE(''|| P_FROMDATE ||'','DD/MM/YYYY'),'YYYY')  INTO REPMONTH FROM DUAL;
        
        DELETE FROM GTT_PISSALARYABSTRACT;
       
        DELETE FROM GTT_PISSALARYABSTRACT_NEW; 
        
       LV_SQLSTR :=     '  INSERT INTO GTT_PISSALARYABSTRACT'|| CHR(10)    
                    ||   '  SELECT C.COMPANYNAME, D.DIVISIONNAME,'''||REPMONTH||''' REPORTMONTH,SLNO, A.DEPARTMENTCODE, B.DEPARTMENTDESC, A.CATEGORYCODE, /* E.CATEGORYDESC,NULL,*/ NULL, COMPONENTSHORTNAME,COMPONENTTYPE, COMPVALUE' || CHR(10)
                    ||   '  , GROSSEARN TOTAL_EARNING, GROSSDEDN TOTAL_DEDUCTION, MISC_CF COIN_CF, (GROSSEARN - GROSSDEDN) NET_RS' || CHR(10)
                    ||   '  ,CALCULATIONINDEX EX1,0 EX2,0 EX3,0 EX4,0 EX5,0 EX6,0 EX7,0 EX8,0 EX9,GRADECODE' || CHR(10)
                    ||   '  ,NULL EX11,NULL EX12,NULL EX13,NULL EX14,NULL EX15,NULL EX16,NULL EX17,NULL EX18,NULL EX19,NULL EX20 FROM ' || CHR(10)
                    ||   '  (' || CHR(10)
                    ||   '          SELECT SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE, COMPONENTSHORTNAME,COMPONENTTYPE,SUM(NVL(COMPVALUE,0)) COMPVALUE, SUM(GROSSEARN) GROSSEARN, SUM(GROSSDEDN) GROSSDEDN,SUM(MISC_CF) MISC_CF,CALCULATIONINDEX FROM' || CHR(10)
                    ||   '          (' || CHR(10)
                    ||   '              SELECT ''1'' SLNO, COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''SAL DAYS'' COMPONENTSHORTNAME,''GENERAL'' COMPONENTTYPE,1 CALCULATIONINDEX,SUM(ATTN_SALD) COMPVALUE,0 GROSSEARN, 0 GROSSDEDN,0 MISC_CF ' || CHR(10)
                    ||   '              FROM PISPAYTRANSACTION  ' || CHR(10)
                    ||   '              WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''' AND YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, CATEGORYCODE,GRADECODE' || CHR(10)
                    ||   '              UNION ALL' || CHR(10)
                    ||   '              SELECT ''1'' SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''ATN DAYS'' COMPONENTSHORTNAME,''GENERAL'' COMPONENTTYPE,2 CALCULATIONINDEX,SUM(ATTN_WRKD) COMPVALUE,0 GROSSEARN, 0 GROSSDEDN,0 MISC_CF ' || CHR(10)
                    ||   '              FROM PISPAYTRANSACTION  ' || CHR(10)
                    ||   '              WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''' AND YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, CATEGORYCODE,GRADECODE' || CHR(10)
                    ||   '              UNION ALL' || CHR(10)
                    ||   '              SELECT ''1'' SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''LV DAYS'' COMPONENTSHORTNAME,''GENERAL'' COMPONENTTYPE,3 CALCULATIONINDEX,SUM(ATTN_LDAY) COMPVALUE,0 GROSSEARN, 0 GROSSDEDN,0 MISC_CF ' || CHR(10)
                    ||   '              FROM PISPAYTRANSACTION  ' || CHR(10)
                    ||   '              WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''' AND YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, CATEGORYCODE,GRADECODE' || CHR(10)
                    ||   '              UNION ALL' || CHR(10)
                    ||   '              SELECT ''1'' SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''HOLIDAYS'' COMPONENTSHORTNAME,''GENERAL'' COMPONENTTYPE,4 CALCULATIONINDEX,SUM(ATTN_HOLD) COMPVALUE,0 GROSSEARN, 0 GROSSDEDN,0 MISC_CF ' || CHR(10)
                    ||   '              FROM PISPAYTRANSACTION  ' || CHR(10)
                    ||   '              WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''' AND YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, CATEGORYCODE,GRADECODE' || CHR(10)
                    ||   '              UNION ALL' || CHR(10)
                    ||   '              SELECT ''1'' SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''LV ENCHD'' COMPONENTSHORTNAME,''GENERAL'' COMPONENTTYPE,5 CALCULATIONINDEX,SUM(LV_ENCASH_DAYS) COMPVALUE,0 GROSSEARN, 0 GROSSDEDN,0 MISC_CF ' || CHR(10)
                    ||   '              FROM PISPAYTRANSACTION  ' || CHR(10)
                    ||   '              WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''' AND YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, CATEGORYCODE,GRADECODE' || CHR(10)
                    ||   '              UNION ALL' || CHR(10)
                    ||   '              SELECT ''1'' SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''N_ALL_HR'' COMPONENTSHORTNAME,''GENERAL'' COMPONENTTYPE,6 CALCULATIONINDEX,SUM(NS_HRS) COMPVALUE,0 GROSSEARN, 0 GROSSDEDN,0 MISC_CF ' || CHR(10)
                    ||   '              FROM PISPAYTRANSACTION  ' || CHR(10)
                    ||   '              WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''' AND YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, CATEGORYCODE,GRADECODE' || CHR(10)
                    ||   '              UNION ALL' || CHR(10)
                    ||   '              SELECT ''1'' SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''OT D/HR'' COMPONENTSHORTNAME,''GENERAL'' COMPONENTTYPE,7 CALCULATIONINDEX,SUM(DECODE(OT_HRS,0,OT_DAYS,OT_HRS)) COMPVALUE,0 GROSSEARN, 0 GROSSDEDN,0 MISC_CF ' || CHR(10)
                    ||   '              FROM PISPAYTRANSACTION  ' || CHR(10)
                    ||   '              WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''' AND YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, CATEGORYCODE,GRADECODE' || CHR(10)
                    ||   '              UNION ALL' || CHR(10)
                    ||   '              SELECT ''1'' SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''PAY SLIP'' COMPONENTSHORTNAME,''GENERAL'' COMPONENTTYPE,8 CALCULATIONINDEX,COUNT(*) COMPVALUE,0 GROSSEARN, 0 GROSSDEDN,0 MISC_CF' || CHR(10)
                    ||   '              FROM PISPAYTRANSACTION  ' || CHR(10)
                    ||   '              WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''' AND YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, CATEGORYCODE,GRADECODE' || CHR(10)
                    ||   '          UNION ALL' || CHR(10)    
                    ||   '          SELECT * FROM (  '  ||CHR(10)                
                    ||   '          SELECT ''2'' SLNO,PAYS.COMPANYCODE, PAYS.DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,CM.COMPONENTSHORTNAME,COMPONENTTYPE,CALCULATIONINDEX,' || CHR(10)
                    ||   '              FN_GET_COMPVALUE_PAYSLIP(PAYS.COMPANYCODE,PAYS.DIVISIONCODE,PAYS.YEARMONTH,PAYS.WORKERSERIAL,COMPONENTCODE,''PIS PAY SLIP'') COMPVALUE,GROSSEARN,GROSSDEDN, MISC_CF ' || CHR(10)
                    ||   '               FROM PISPAYTRANSACTION PAYS,' || CHR(10)
                    ||   '               (' || CHR(10)
                    ||   '                  SELECT DISTINCT COMPANYCODE, DIVISIONCODE,COMPONENTCODE,COMPONENTSHORTNAME,COMPONENTDESC,COMPONENTTYPE, CALCULATIONINDEX  ' || CHR(10)
                    ||   '                  FROM PISCOMPONENTMASTER' || CHR(10)
                    ||   '                  WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||'''' || CHR(10)
                    ||   '                  AND YEARMONTH=(SELECT MAX(YEARMONTH)  FROM PISCOMPONENTMASTER                      ' || CHR(10) 
                    ||   '                                 WHERE  COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''')        ' || CHR(10)
                    ||   '                      AND COMPONENTTYPE=''EARNING''' || CHR(10)
                    ||   '               ) CM,COLS B' || CHR(10)
                    ||   '              WHERE' || CHR(10)
                    ||   '              B.TABLE_NAME = ''PISPAYTRANSACTION''' || CHR(10)
                    --||   '              AND CM.COMPONENTTYPE IN(''EARNING'')' || CHR(10)
                    ||   '              and CM.COMPONENTCODE = B.COLUMN_NAME' || CHR(10)
                    ||   '              AND PAYS.COMPANYCODE=CM.COMPANYCODE' || CHR(10)
                    ||   '              AND PAYS.DIVISIONCODE=CM.DIVISIONCODE' || CHR(10)
                    ||   '              AND PAYS.COMPANYCODE='''|| P_COMPANYCODE ||''' ' || CHR(10)
                    ||   '              AND PAYS.DIVISIONCODE='''|| P_DIVISIONCODE ||'''' || CHR(10)
                    ||   '              AND PAYS.YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              AND COMPONENTCODE<>''PF_GROSS''             ' || CHR(10)
                    ||   '             ) WHERE COMPVALUE>0 ' || CHR(10)
                    ||   '          UNION ALL' || CHR(10)
                    ||   '          SELECT * FROM (  '  ||CHR(10)
                    ||   '          SELECT ''3'' SLNO,PAYS.COMPANYCODE, PAYS.DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,COMPONENTSHORTNAME,COMPONENTTYPE,CALCULATIONINDEX,' || CHR(10)
                    ||   '              FN_GET_COMPVALUE_PAYSLIP(PAYS.COMPANYCODE,PAYS.DIVISIONCODE,PAYS.YEARMONTH,PAYS.WORKERSERIAL,COMPONENTCODE,''PIS PAY SLIP'') COMPVALUE,GROSSEARN,GROSSDEDN, MISC_BF ' || CHR(10)
                    ||   '               FROM PISPAYTRANSACTION PAYS,' || CHR(10)
                    ||   '               (' || CHR(10)
                    ||   '                  SELECT DISTINCT COMPANYCODE, DIVISIONCODE,COMPONENTCODE,COMPONENTSHORTNAME,COMPONENTDESC,COMPONENTTYPE, CALCULATIONINDEX  ' || CHR(10)
                    ||   '                  FROM PISCOMPONENTMASTER' || CHR(10)
                    ||   '                  WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||'''' || CHR(10)
                    ||   '                  AND YEARMONTH=(SELECT MAX(YEARMONTH)  FROM PISCOMPONENTMASTER                      ' || CHR(10) 
                    ||   '                                 WHERE  COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''')        ' || CHR(10)
                    ||   '               AND COMPONENTTYPE=''DEDUCTION''' || CHR(10)
                    ||   '               )  CM,COLS B' || CHR(10)
                    ||   '              WHERE' || CHR(10)
                    ||   '              B.TABLE_NAME = ''PISPAYTRANSACTION''' || CHR(10)
--                    ||   '              AND CM.COMPONENTTYPE IN(''DEDUCTION'')' || CHR(10)
                    ||   '              and CM.COMPONENTCODE = B.COLUMN_NAME' || CHR(10)
                    ||   '              AND PAYS.COMPANYCODE=CM.COMPANYCODE' || CHR(10)
                    ||   '              AND PAYS.DIVISIONCODE=CM.DIVISIONCODE' || CHR(10)
                    ||   '              AND PAYS.COMPANYCODE='''|| P_COMPANYCODE ||''' ' || CHR(10)
                    ||   '              AND PAYS.DIVISIONCODE='''|| P_DIVISIONCODE ||'''' || CHR(10)
                    ||   '              AND PAYS.YEARMONTH = '''|| P_YEARMONTH ||''' ' || CHR(10)
                                     ------------ CHANGE 29022020--------         ' || CHR(10)
                    ||   '                   UNION ALL          ' || CHR(10)
                    ||   '                   SELECT ''3'' SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''MISC_BF'' COMPONENTSHORTNAME,   ' || CHR(10)
                    ||   '                   ''DEDUCTION''COMPONENTTYPE,1000 CALCULATIONINDEX,MISC_BF COMPVALUE, GROSSEARN, GROSSDEDN,MISC_BF        ' || CHR(10)
                    ||   '                   FROM PISPAYTRANSACTION         ' || CHR(10)
                    ||   '                   WHERE COMPANYCODE='''|| P_COMPANYCODE ||'''      ' || CHR(10)
                    ||   '                   AND DIVISIONCODE='''|| P_DIVISIONCODE ||'''       ' || CHR(10)
                    ||   '                   AND YEARMONTH = '''|| P_YEARMONTH ||'''       ' || CHR(10)
                                  --------------------       ' || CHR(10)
                    ||   '             ) WHERE COMPVALUE>0 ' || CHR(10)
                    ||   '          ) ' || CHR(10)
                    ||   '          GROUP BY SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE, COMPONENTSHORTNAME,COMPONENTTYPE,CALCULATIONINDEX' || CHR(10)
                    ||   '          ORDER BY CALCULATIONINDEX' || CHR(10)
                    ||   '      ) A, PISDEPARTMENTMASTER B, COMPANYMAST C, DIVISIONMASTER D --, PISCATEGORYMASTER E' || CHR(10)
                    ||   '      WHERE A.COMPANYCODE = B.COMPANYCODE' || CHR(10)
                    ||   '       AND A.COMPANYCODE = C.COMPANYCODE' || CHR(10)
                    ||   '       AND A.COMPANYCODE = D.COMPANYCODE' || CHR(10)
                    ||   '       AND A.DIVISIONCODE = B.DIVISIONCODE' || CHR(10)
                    ||   '       AND A.DIVISIONCODE = D.DIVISIONCODE' || CHR(10)
                    ||   '       AND A.DEPARTMENTCODE = B.DEPARTMENTCODE' || CHR(10);                       
                    IF P_CATEGORYCODE IS NOT NULL THEN
                        LV_SQLSTR := LV_SQLSTR ||   '   AND      A.CATEGORYCODE  IN ('|| P_CATEGORYCODE ||')' || CHR(10);
                    END IF;      
                    
                    IF P_GRADE IS NOT NULL THEN
                        LV_SQLSTR := LV_SQLSTR ||   '   AND      A.GRADECODE  IN ('|| P_GRADE ||')' || CHR(10);
                    END IF;          
                    
                    IF P_DEPARTMENT IS NOT NULL THEN
                        LV_SQLSTR := LV_SQLSTR ||   '   AND      A.DEPARTMENTCODE  IN ('|| P_DEPARTMENT ||')' || CHR(10);
                    END IF;          
                                         
                    LV_SQLSTR := LV_SQLSTR ||   '  ORDER BY A.DEPARTMENTCODE,COMPONENTTYPE, EX1' || CHR(10);
                                                    
    -- DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
     EXECUTE IMMEDIATE LV_SQLSTR;
                    
     DELETE  FROM GTT_PISSALARYABSTRACT_DATA;
                    
     INSERT INTO GTT_PISSALARYABSTRACT_DATA
     (DEPARTMENTCODE, DEPARTMENTNAME,CATEGORYCODE, GRADECODE, GEN_INDEX, EARN_INDEX, DED_INDEX, COMPNAME_GEN, COMPVAL_GEN, COMPNAME_EARN, COMPVAL_EARN, COMPNAME_DED, COMPVAL_DED)
     SELECT DISTINCT DEPARTMENTCODE,DEPARTMENTNAME,CATEGORYCODE, EX10 AS GRADECODE, SUM(GEN_INDEX)GEN_INDEX, SUM(EARN_INDEX)EARN_INDEX, SUM(DED_INDEX) DED_INDEX, COMPNAME_GEN,SUM(COMPVAL_GEN) COMPVAL_GEN,
      COMPNAME_EARN,SUM(COMPVAL_EARN) COMPVAL_EARN, COMPNAME_DED,SUM(COMPVAL_DED) COMPVAL_DED
        FROM
        (       
            SELECT DEPARTMENTCODE,DEPARTMENTNAME,CATEGORYCODE, EX10, 'GEN' COMPTYPE, COMPONENTNAME COMPNAME_GEN,SUM(COMPVALUE) COMPVAL_GEN,NULL COMPNAME_EARN,0 COMPVAL_EARN,NULL COMPNAME_DED,0 COMPVAL_DED, EX1 GEN_INDEX, 0 EARN_INDEX, 0 DED_INDEX 
            FROM GTT_PISSALARYABSTRACT WHERE COMPONENTTYPE='GENERAL'
            GROUP BY DEPARTMENTCODE,DEPARTMENTNAME,COMPONENTNAME, EX1,CATEGORYCODE, EX10           
            UNION ALL            
            SELECT DEPARTMENTCODE,DEPARTMENTNAME,CATEGORYCODE, EX10, 'EARN' COMPTYPE,NULL COMPNAME_GEN ,0 COMPVAL_GEN ,COMPONENTNAME COMPNAME_EARN ,SUM(COMPVALUE) COMPVAL_EARN,NULL COMPNAME_DED ,0 COMPVAL_DED, 0 GEN_INDEX, EX1 EARN_INDEX, 0 DED_INDEX
            FROM GTT_PISSALARYABSTRACT WHERE COMPONENTTYPE='EARNING'
            GROUP BY DEPARTMENTCODE,DEPARTMENTNAME,COMPONENTNAME, EX1,CATEGORYCODE, EX10            
            UNION ALL            
            SELECT DEPARTMENTCODE,DEPARTMENTNAME,CATEGORYCODE, EX10, 'DED' COMPTYPE,NULL COMPNAME_GEN,0 COMPVAL_GEN,NULL COMPNAME_EARN,0 COMPVAL_EARN,COMPONENTNAME COMPNAME_DED,SUM(COMPVALUE) COMPVAL_DED,  0 GEN_INDEX, 0 EARN_INDEX, EX1 DED_INDEX
            FROM GTT_PISSALARYABSTRACT WHERE COMPONENTTYPE='DEDUCTION'
            GROUP BY DEPARTMENTCODE,DEPARTMENTNAME,COMPONENTNAME, EX1,CATEGORYCODE, EX10            
        )
       -- WHERE DEPARTMENTCODE='0001'
        GROUP BY DEPARTMENTCODE,DEPARTMENTNAME,COMPNAME_GEN,COMPNAME_EARN,COMPNAME_DED,CATEGORYCODE, EX10
        ORDER BY  GEN_INDEX, EARN_INDEX, DED_INDEX;

     
    DELETE GTT_PISSALARYABSTRACT_NEW;
    
     
   IF P_CATEGORYCODE IS NOT NULL AND P_GRADE IS NOT NULL THEN
     FOR CDEPT IN( SELECT DISTINCT DEPARTMENTCODE , DEPARTMENTNAME 
                FROM GTT_PISSALARYABSTRACT_DATA /* WHERE DEPARTMENTCODE N('0001','0002fff') */  ORDER BY DEPARTMENTCODE )
       
        LOOP        
              -----------------  GEN --------------------
              FOR C2 IN (SELECT COMPNAME_GEN , SUM(COMPVAL_GEN) COMPVAL_GEN,CATEGORYCODE,GRADECODE FROM GTT_PISSALARYABSTRACT_DATA
                            WHERE COMPNAME_GEN IS NOT NULL
                            AND DEPARTMENTCODE = CDEPT.DEPARTMENTCODE
                            GROUP BY  COMPNAME_GEN ,GEN_INDEX,CATEGORYCODE,GRADECODE
                             ORDER BY GEN_INDEX)
                LOOP        
                 SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
                 INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_GEN,COMPVAL_GEN,CATEGORYCODE,EX10 )
                 VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C2.COMPNAME_GEN,C2.COMPVAL_GEN,C2.CATEGORYCODE,C2.GRADECODE) ;        
              END LOOP;
              ----------------- EARN ----------
               FOR C3 IN (SELECT  COMPNAME_EARN , SUM(COMPVAL_EARN) COMPVAL_EARN,CATEGORYCODE,GRADECODE FROM GTT_PISSALARYABSTRACT_DATA
                            WHERE COMPVAL_EARN>0--COMPNAME_EARN IS NOT NULL
                            AND DEPARTMENTCODE = CDEPT.DEPARTMENTCODE
                            GROUP BY  COMPNAME_EARN,EARN_INDEX,CATEGORYCODE,GRADECODE
                             ORDER BY EARN_INDEX
                    )LOOP 
                       SELECT COUNT(*)  INTO LV_CNT FROM  GTT_PISSALARYABSTRACT_NEW WHERE   DEPARTMENTCODE = CDEPT.DEPARTMENTCODE    ;
                    IF LV_CNT > 0 THEN
                          SELECT MIN(to_number(SLNO)) INTO LV_SLNO  FROM GTT_PISSALARYABSTRACT_NEW WHERE   DEPARTMENTCODE = CDEPT.DEPARTMENTCODE 
                          AND COMPNAME_EARN IS NULL;
                          
                          IF LV_SLNO IS NOT NULL THEN
                               UPDATE GTT_PISSALARYABSTRACT_NEW SET COMPNAME_EARN = C3.COMPNAME_EARN , COMPVAL_EARN = C3.COMPVAL_EARN-- ,COLINDEX=C3.COLINDEX
                               WHERE SLNO = LV_SLNO;
                         ELSE    
                        -- DBMS_OUTPUT.PUT_LINE(C3.COMPNAME_EARN||'update inst C3.COMPNAME_EARN');                 
                          -- if LV_COMP<>C3.COMPNAME_EARN then 
                               SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
                            --   DBMS_OUTPUT.PUT_LINE(LV_SLNO||' update inst LV_SLNO');
                               INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_EARN,COMPVAL_EARN,CATEGORYCODE,EX10 )
                               VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C3.COMPNAME_EARN,C3.COMPVAL_EARN,C3.CATEGORYCODE,C3.GRADECODE) ;
                               LV_COMP:=C3.COMPNAME_EARN;
                         --  end if; 
                        END IF;           
                    ELSE
                       -- DBMS_OUTPUT.PUT_LINE(C3.COMPNAME_EARN||'inst C3.COMPNAME_EARN');
                       SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
                     --  DBMS_OUTPUT.PUT_LINE(LV_SLNO||'LV_SLNO');
                      INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_EARN,COMPVAL_EARN,CATEGORYCODE,EX10)
                      VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C3.COMPNAME_EARN,C3.COMPVAL_EARN,C3.CATEGORYCODE,C3.GRADECODE) ;
                    END IF;                
              END LOOP;
              ------------------------- END EARN ---------------------------------
              ------------------------- DEDN -----------------------------------
               FOR C4 IN (SELECT  COMPNAME_DED , SUM(COMPVAL_DED) COMPVAL_DED,CATEGORYCODE,GRADECODE FROM GTT_PISSALARYABSTRACT_DATA
                        WHERE COMPVAL_DED>0--COMPNAME_DED IS NOT NULL
                        AND DEPARTMENTCODE = CDEPT.DEPARTMENTCODE
                        GROUP BY  COMPNAME_DED,DED_INDEX,CATEGORYCODE,GRADECODE
                         ORDER BY DED_INDEX)
                LOOP 
                SELECT COUNT(*)  INTO LV_CNT FROM  GTT_PISSALARYABSTRACT_NEW WHERE   DEPARTMENTCODE = CDEPT.DEPARTMENTCODE    ;
                IF LV_CNT > 0 THEN
                  SELECT MIN(SLNO) INTO LV_SLNO  FROM GTT_PISSALARYABSTRACT_NEW WHERE   DEPARTMENTCODE = CDEPT.DEPARTMENTCODE 
                  AND COMPNAME_DED IS NULL;                     
                  IF LV_SLNO IS NOT NULL THEN
                  --DBMS_OUTPUT.PUT_LINE(C4.COMPNAME_DED||' update C4.COMPNAME_DED');
                   UPDATE GTT_PISSALARYABSTRACT_NEW SET COMPNAME_DED = C4.COMPNAME_DED , COMPVAL_DED = C4.COMPVAL_DED--,COLINDEX=C4.COLINDEX
                   WHERE SLNO = LV_SLNO;
                  ELSE
                  --DBMS_OUTPUT.PUT_LINE(C4.COMPNAME_DED||' update inst C4.COMPNAME_DED');
                   SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
                   INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_DED,COMPVAL_DED,CATEGORYCODE,EX10)
                   VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C4.COMPNAME_DED,C4.COMPVAL_DED,C4.CATEGORYCODE,C4.GRADECODE) ; 
                  END IF;           
                ELSE
                --DBMS_OUTPUT.PUT_LINE(C4.COMPNAME_DED||' insert C4.COMPNAME_DED');
                  SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
                   INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_DED,COMPVAL_DED,CATEGORYCODE,EX10)
                   VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C4.COMPNAME_DED,C4.COMPVAL_DED,C4.CATEGORYCODE,C4.GRADECODE) ;
                END IF;                
          END LOOP;
      --------------------------- END DEDN -----------------------------------     
       
     
        END LOOP;
        
     ELSIF P_CATEGORYCODE IS NOT NULL THEN
         --*******************  **********************
         
         FOR CDEPT IN( SELECT DISTINCT DEPARTMENTCODE , DEPARTMENTNAME 
                FROM GTT_PISSALARYABSTRACT_DATA /* WHERE DEPARTMENTCODE N('0001','0002fff') */  ORDER BY DEPARTMENTCODE )
       
        LOOP        
              -----------------  GEN --------------------
              FOR C2 IN (SELECT COMPNAME_GEN , SUM(COMPVAL_GEN) COMPVAL_GEN,CATEGORYCODE FROM GTT_PISSALARYABSTRACT_DATA
                            WHERE COMPNAME_GEN IS NOT NULL
                            AND DEPARTMENTCODE = CDEPT.DEPARTMENTCODE
                            GROUP BY  COMPNAME_GEN ,GEN_INDEX,CATEGORYCODE
                             ORDER BY GEN_INDEX)
                LOOP        
                 SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
                 INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_GEN,COMPVAL_GEN,CATEGORYCODE )
                 VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C2.COMPNAME_GEN,C2.COMPVAL_GEN,C2.CATEGORYCODE) ;        
              END LOOP;
              ----------------- EARN ----------
               FOR C3 IN (SELECT  COMPNAME_EARN , SUM(COMPVAL_EARN) COMPVAL_EARN,CATEGORYCODE FROM GTT_PISSALARYABSTRACT_DATA
                            WHERE COMPVAL_EARN>0--COMPNAME_EARN IS NOT NULL
                            AND DEPARTMENTCODE = CDEPT.DEPARTMENTCODE
                            GROUP BY  COMPNAME_EARN,EARN_INDEX,CATEGORYCODE
                             ORDER BY EARN_INDEX
                    )LOOP 
                       SELECT COUNT(*)  INTO LV_CNT FROM  GTT_PISSALARYABSTRACT_NEW WHERE   DEPARTMENTCODE = CDEPT.DEPARTMENTCODE    ;
                    IF LV_CNT > 0 THEN
                          SELECT MIN(to_number(SLNO)) INTO LV_SLNO  FROM GTT_PISSALARYABSTRACT_NEW WHERE   DEPARTMENTCODE = CDEPT.DEPARTMENTCODE 
                          AND COMPNAME_EARN IS NULL;
                          
                          IF LV_SLNO IS NOT NULL THEN
                               UPDATE GTT_PISSALARYABSTRACT_NEW SET COMPNAME_EARN = C3.COMPNAME_EARN , COMPVAL_EARN = C3.COMPVAL_EARN-- ,COLINDEX=C3.COLINDEX
                               WHERE SLNO = LV_SLNO;
                         ELSE    
                        -- DBMS_OUTPUT.PUT_LINE(C3.COMPNAME_EARN||'update inst C3.COMPNAME_EARN');                 
                          -- if LV_COMP<>C3.COMPNAME_EARN then 
                               SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
                            --   DBMS_OUTPUT.PUT_LINE(LV_SLNO||' update inst LV_SLNO');
                               INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_EARN,COMPVAL_EARN,CATEGORYCODE )
                               VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C3.COMPNAME_EARN,C3.COMPVAL_EARN,C3.CATEGORYCODE) ;
                               LV_COMP:=C3.COMPNAME_EARN;
                         --  end if; 
                        END IF;           
                    ELSE
                       -- DBMS_OUTPUT.PUT_LINE(C3.COMPNAME_EARN||'inst C3.COMPNAME_EARN');
                       SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
                     --  DBMS_OUTPUT.PUT_LINE(LV_SLNO||'LV_SLNO');
                      INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_EARN,COMPVAL_EARN,CATEGORYCODE)
                      VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C3.COMPNAME_EARN,C3.COMPVAL_EARN,C3.CATEGORYCODE) ;
                    END IF;                
              END LOOP;
              ------------------------- END EARN ---------------------------------
              ------------------------- DEDN -----------------------------------
               FOR C4 IN (SELECT  COMPNAME_DED , SUM(COMPVAL_DED) COMPVAL_DED,CATEGORYCODE FROM GTT_PISSALARYABSTRACT_DATA
                        WHERE COMPVAL_DED>0--COMPNAME_DED IS NOT NULL
                        AND DEPARTMENTCODE = CDEPT.DEPARTMENTCODE
                        GROUP BY  COMPNAME_DED,DED_INDEX,CATEGORYCODE
                         ORDER BY DED_INDEX)
                LOOP 
                SELECT COUNT(*)  INTO LV_CNT FROM  GTT_PISSALARYABSTRACT_NEW WHERE   DEPARTMENTCODE = CDEPT.DEPARTMENTCODE    ;
                IF LV_CNT > 0 THEN
                  SELECT MIN(SLNO) INTO LV_SLNO  FROM GTT_PISSALARYABSTRACT_NEW WHERE   DEPARTMENTCODE = CDEPT.DEPARTMENTCODE 
                  AND COMPNAME_DED IS NULL;                     
                  IF LV_SLNO IS NOT NULL THEN
                  --DBMS_OUTPUT.PUT_LINE(C4.COMPNAME_DED||' update C4.COMPNAME_DED');
                   UPDATE GTT_PISSALARYABSTRACT_NEW SET COMPNAME_DED = C4.COMPNAME_DED , COMPVAL_DED = C4.COMPVAL_DED--,COLINDEX=C4.COLINDEX
                   WHERE SLNO = LV_SLNO;
                  ELSE
                  --DBMS_OUTPUT.PUT_LINE(C4.COMPNAME_DED||' update inst C4.COMPNAME_DED');
                   SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
                   INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_DED,COMPVAL_DED,CATEGORYCODE)
                   VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C4.COMPNAME_DED,C4.COMPVAL_DED,C4.CATEGORYCODE) ; 
                  END IF;           
                ELSE
                --DBMS_OUTPUT.PUT_LINE(C4.COMPNAME_DED||' insert C4.COMPNAME_DED');
                  SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
                   INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_DED,COMPVAL_DED,CATEGORYCODE)
                   VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C4.COMPNAME_DED,C4.COMPVAL_DED,C4.CATEGORYCODE) ;
                END IF;                
          END LOOP;
      --------------------------- END DEDN -----------------------------------     
       
     
        END LOOP;      
        
        
        
     END IF;   
        
   IF P_CATEGORYCODE IS NULL THEN
   
      FOR CDEPT IN( SELECT DISTINCT DEPARTMENTCODE , DEPARTMENTNAME 
                FROM GTT_PISSALARYABSTRACT_DATA /* WHERE DEPARTMENTCODE N('0001','0002fff') */  ORDER BY DEPARTMENTCODE )
      LOOP        
          -----------------  GEN --------------------
          FOR C2 IN (SELECT COMPNAME_GEN , SUM(COMPVAL_GEN) COMPVAL_GEN FROM GTT_PISSALARYABSTRACT_DATA
                        WHERE COMPNAME_GEN IS NOT NULL
                        AND DEPARTMENTCODE = CDEPT.DEPARTMENTCODE
                        GROUP BY  COMPNAME_GEN ,GEN_INDEX
                         ORDER BY GEN_INDEX)
            LOOP        
             SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
             INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_GEN,COMPVAL_GEN)
             VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C2.COMPNAME_GEN,C2.COMPVAL_GEN) ;        
          END LOOP;
          ----------------- EARN ----------
           FOR C3 IN (SELECT  COMPNAME_EARN , SUM(COMPVAL_EARN) COMPVAL_EARN FROM GTT_PISSALARYABSTRACT_DATA
                        WHERE COMPVAL_EARN>0--COMPNAME_EARN IS NOT NULL
                        AND DEPARTMENTCODE = CDEPT.DEPARTMENTCODE
                        GROUP BY  COMPNAME_EARN,EARN_INDEX
                         ORDER BY EARN_INDEX
                )LOOP 
                   SELECT COUNT(*)  INTO LV_CNT FROM  GTT_PISSALARYABSTRACT_NEW WHERE   DEPARTMENTCODE = CDEPT.DEPARTMENTCODE    ;
                IF LV_CNT > 0 THEN
                      SELECT MIN(to_number(SLNO)) INTO LV_SLNO  FROM GTT_PISSALARYABSTRACT_NEW WHERE   DEPARTMENTCODE = CDEPT.DEPARTMENTCODE 
                      AND COMPNAME_EARN IS NULL;
                      
                      IF LV_SLNO IS NOT NULL THEN
                           UPDATE GTT_PISSALARYABSTRACT_NEW SET COMPNAME_EARN = C3.COMPNAME_EARN , COMPVAL_EARN = C3.COMPVAL_EARN-- ,COLINDEX=C3.COLINDEX
                           WHERE SLNO = LV_SLNO;
                     ELSE    
                    -- DBMS_OUTPUT.PUT_LINE(C3.COMPNAME_EARN||'update inst C3.COMPNAME_EARN');                 
                      -- if LV_COMP<>C3.COMPNAME_EARN then 
                           SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
                        --   DBMS_OUTPUT.PUT_LINE(LV_SLNO||' update inst LV_SLNO');
                           INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_EARN,COMPVAL_EARN)
                           VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C3.COMPNAME_EARN,C3.COMPVAL_EARN) ;
                           LV_COMP:=C3.COMPNAME_EARN;
                     --  end if; 
                   END IF;           
              ELSE
                   -- DBMS_OUTPUT.PUT_LINE(C3.COMPNAME_EARN||'inst C3.COMPNAME_EARN');
                   SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
                 --  DBMS_OUTPUT.PUT_LINE(LV_SLNO||'LV_SLNO');
                  INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_EARN,COMPVAL_EARN)
                  VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C3.COMPNAME_EARN,C3.COMPVAL_EARN) ;
                END IF;                
          END LOOP;
          ------------------------- END EARN ---------------------------------
          ------------------------- DEDN -----------------------------------
           FOR C4 IN (SELECT  COMPNAME_DED , SUM(COMPVAL_DED) COMPVAL_DED FROM GTT_PISSALARYABSTRACT_DATA
                    WHERE COMPVAL_DED>0--COMPNAME_DED IS NOT NULL
                    AND DEPARTMENTCODE = CDEPT.DEPARTMENTCODE
                    GROUP BY  COMPNAME_DED,DED_INDEX
                     ORDER BY DED_INDEX)
            LOOP 
            SELECT COUNT(*)  INTO LV_CNT FROM  GTT_PISSALARYABSTRACT_NEW WHERE   DEPARTMENTCODE = CDEPT.DEPARTMENTCODE    ;
            IF LV_CNT > 0 THEN
              SELECT MIN(SLNO) INTO LV_SLNO  FROM GTT_PISSALARYABSTRACT_NEW WHERE   DEPARTMENTCODE = CDEPT.DEPARTMENTCODE 
              AND COMPNAME_DED IS NULL;                     
              IF LV_SLNO IS NOT NULL THEN
              --DBMS_OUTPUT.PUT_LINE(C4.COMPNAME_DED||' update C4.COMPNAME_DED');
               UPDATE GTT_PISSALARYABSTRACT_NEW SET COMPNAME_DED = C4.COMPNAME_DED , COMPVAL_DED = C4.COMPVAL_DED--,COLINDEX=C4.COLINDEX
               WHERE SLNO = LV_SLNO;
              ELSE
              --DBMS_OUTPUT.PUT_LINE(C4.COMPNAME_DED||' update inst C4.COMPNAME_DED');
               SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
               INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_DED,COMPVAL_DED)
               VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C4.COMPNAME_DED,C4.COMPVAL_DED) ; 
              END IF;           
            ELSE
            --DBMS_OUTPUT.PUT_LINE(C4.COMPNAME_DED||' insert C4.COMPNAME_DED');
              SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
               INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_DED,COMPVAL_DED)
               VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C4.COMPNAME_DED,C4.COMPVAL_DED) ;
            END IF;                
      END LOOP;
      --------------------------- END DEDN -----------------------------------      
      --EXIT;
      
      
      --COMMIT;
         END LOOP;
   END IF;   
         
       
      LV_SQLSTR :=   '  UPDATE  GTT_PISSALARYABSTRACT_NEW A SET(TOTAL_EARNING, TOTAL_DEDUCTION, COIN_CF, NET_RS)=' || CHR(10)
       ||   '  (SELECT  SUM(NVL(GROSSEARN,0))TOTAL_EARN , SUM(NVL(GROSSDEDN,0)) TOTAL_DEDN, SUM(NVL(MISC_CF,0)) CNF,SUM(NVL(NETSALARY,0))NETRS ' || CHR(10)
       ||   '  FROM PISPAYTRANSACTION B' || CHR(10)
       ||   '   WHERE A.DEPARTMENTCODE=B.DEPARTMENTCODE' || CHR(10)
       ||   '   AND B.COMPANYCODE='''||P_COMPANYCODE||'''' || CHR(10)
       ||   '   AND B.DIVISIONCODE='''||P_DIVISIONCODE||'''' || CHR(10)
      
       ||   '   AND B.YEARMONTH='''||P_YEARMONTH||'''' || CHR(10);
      
         IF P_CATEGORYCODE IS NOT NULL THEN
                        LV_SQLSTR := LV_SQLSTR ||   '   AND      B.CATEGORYCODE  IN ('|| P_CATEGORYCODE ||')' || CHR(10);
        END IF;                                    
                    
        LV_SQLSTR := LV_SQLSTR ||   ')' || CHR(10);
      
    
                                              
     --DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
     EXECUTE IMMEDIATE LV_SQLSTR;
     
     
     LV_SQLSTR :=   ' 
     UPDATE  GTT_PISSALARYABSTRACT_NEW A SET(COMPANYNAME, DIVISIONNAME, REPORTMONTH';
                                              if P_CATEGORYCODE is not null then
                                                    LV_SQLSTR := LV_SQLSTR ||   '   ,CATEGORYCODE,CATEGORYDESC ';
                                              end if;
                                              
                                            
        LV_SQLSTR := LV_SQLSTR ||   '  )=(SELECT DISTINCT COMPANYNAME, DIVISIONNAME, REPORTMONTH';
        
                                              if P_CATEGORYCODE is not null then
                                                    LV_SQLSTR := LV_SQLSTR ||   '   ,CATEGORYCODE,CATEGORYDESC ';
                                              end if;
         
                                              LV_SQLSTR := LV_SQLSTR ||   '  FROM  GTT_PISSALARYABSTRACT B
                                              WHERE A.DEPARTMENTCODE=B.DEPARTMENTCODE ';
                                              if P_CATEGORYCODE is not null then
                                                LV_SQLSTR := LV_SQLSTR ||   '   AND A.CATEGORYCODE=B.CATEGORYCODE';
                                              end if;
                                              
                                              if P_GRADE is not null then 
                                                  LV_SQLSTR := LV_SQLSTR ||   '    AND A.EX10=B.EX10 ';
                                               end if;
                                              
                                             LV_SQLSTR := LV_SQLSTR ||   ' )';
        
           
     --  DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
     EXECUTE IMMEDIATE LV_SQLSTR;
      
      -- NEW SUMMERY  --  *****************************************
      
insert into GTT_PISSALARYABSTRACT_NEW
(
SLNO,DEPARTMENTCODE, DEPARTMENTNAME,  COMPNAME_GEN, COMPVAL_GEN,COMPNAME_EARN, COMPVAL_EARN, COMPNAME_DED, COMPVAL_DED, EX5
)
SELECT ROWNUM AS SLNO,'ALL' as DEPARTMENTCODE, DEPARTMENTNAME,  COMPNAME_GEN, COMPVAL_GEN,COMPNAME_EARN, COMPVAL_EARN, COMPNAME_DED, COMPVAL_DED ,  INDEXNO  
    FROM (
        SELECT DISTINCT ROWNUM, 'AllDept' as DEPARTMENTNAME,  COMPNAME_GEN, COMPVAL_GEN,COMPNAME_EARN, COMPVAL_EARN, COMPNAME_DED, COMPVAL_DED,R3,R4,NVL(A.INDEXNO, C.INDEXNO) INDEXNO
            FROM 
              (
                SELECT DISTINCT NVL(A.INDEXNO, B.INDEXNO) INDEXNO, COMPNAME_GEN, COMPVAL_GEN,COMPNAME_EARN, COMPVAL_EARN,COALESCE(A.R1,B.R2)R3
                        FROM               
                            (
                            SELECT INDEXNO,  COMPNAME_GEN, COMPVAL_GEN, ROWNUM AS R1 FROM
                            (
                                SELECT GEN_INDEX INDEXNO,  COMPNAME_GEN,sum(COMPVAL_GEN) COMPVAL_GEN
                                 from  GTT_PISSALARYABSTRACT_DATA   where  COMPVAL_GEN>0 group by COMPNAME_GEN,GEN_INDEX
                                 ORDER BY GEN_INDEX
                             )
                              ) A
                            FULL OUTER JOIN 
                            (
                             SELECT INDEXNO,  COMPNAME_EARN, COMPVAL_EARN, ROWNUM AS R2 FROM
                                (
                                select EARN_INDEX INDEXNO, COMPNAME_EARN, sum(COMPVAL_EARN) COMPVAL_EARN
                                from  GTT_PISSALARYABSTRACT_DATA  where  COMPVAL_EARN>0 group by COMPNAME_EARN,EARN_INDEX
                                 ORDER BY EARN_INDEX
                                )
                            )B
                            ON A.R1=B.R2
               )A         
               FULL OUTER JOIN      
                    (
                    SELECT INDEXNO,  COMPNAME_DED, COMPVAL_DED, ROWNUM R4 FROM
                        (
                        SELECT DED_INDEX INDEXNO, COMPNAME_DED,sum(COMPVAL_DED) COMPVAL_DED from  GTT_PISSALARYABSTRACT_DATA 
                        where  COMPVAL_DED>0 group by COMPNAME_DED,DED_INDEX
                        ORDER BY DED_INDEX
                        )    
                    )C
                    ON A.R3=C.R4
                ORDER BY R3,R4,INDEXNO     
       );
                                       
      
        UPDATE GTT_PISSALARYABSTRACT_NEW P SET COMPANYNAME=
       (
       SELECT  COMPANYNAME FROM COMPANYMAST WHERE COMPANYCODE=P_COMPANYCODE
       ),
       DIVISIONNAME=
       (
       SELECT  DIVISIONNAME FROM DIVISIONMASTER WHERE DIVISIONCODE=P_DIVISIONCODE
       )
        WHERE  DEPARTMENTCODE='ALL';

      LV_SQLSTR :=   '  UPDATE  GTT_PISSALARYABSTRACT_NEW A SET(TOTAL_EARNING, TOTAL_DEDUCTION, COIN_CF, NET_RS)=' || CHR(10)
       ||   '  (SELECT  SUM(NVL(GROSSEARN,0))TOTAL_EARN , SUM(NVL(GROSSDEDN,0)) TOTAL_DEDN, SUM(NVL(MISC_CF,0)) CNF,SUM(NVL(NETSALARY,0))NETRS ' || CHR(10)
       ||   '  FROM PISPAYTRANSACTION B' || CHR(10)
       ||   '   WHERE A.DEPARTMENTCODE=B.DEPARTMENTCODE' || CHR(10)
       ||   '   AND B.COMPANYCODE='''||P_COMPANYCODE||'''' || CHR(10)
       ||   '   AND B.DIVISIONCODE='''||P_DIVISIONCODE||'''' || CHR(10)      
       ||   '   AND B.YEARMONTH='''||P_YEARMONTH||'''' || CHR(10);
      
         IF P_CATEGORYCODE IS NOT NULL THEN
                        LV_SQLSTR := LV_SQLSTR ||   '   AND      B.CATEGORYCODE  IN ('|| P_CATEGORYCODE ||')' || CHR(10);
        END IF;                                    
                    
        LV_SQLSTR := LV_SQLSTR ||   ')' || CHR(10);
                                               
        --DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
        EXECUTE IMMEDIATE LV_SQLSTR;
                        
        UPDATE  GTT_PISSALARYABSTRACT_NEW A SET(TOTAL_EARNING, TOTAL_DEDUCTION, NET_RS)=
        (
        SELECT SUM(COMPVAL_EARN), SUM(COMPVAL_DED),(SUM(COMPVAL_EARN)-SUM(COMPVAL_DED)) FROM GTT_PISSALARYABSTRACT_NEW
        WHERE DEPARTMENTCODE='ALL'
        )
        WHERE DEPARTMENTCODE='ALL';
                 
        UPDATE  GTT_PISSALARYABSTRACT_NEW A SET(COIN_CF)= (
        SELECT SUM(COIN_CF) FROM GTT_PISSALARYABSTRACT_NEW) WHERE DEPARTMENTCODE='ALL';  
        
        --UPDATE CATEGORY AND GRADE       
       
           if P_CATEGORYCODE is not null then
                SELECT WM_CONCAT(CATEGORYCODE)CATEGORYCODE INTO LV_CATEGORYCODEMERGE FROM 
                (
                    SELECT DISTINCT CATEGORYCODE FROM GTT_PISSALARYABSTRACT_NEW WHERE CATEGORYCODE IS NOT NULL
                );
             UPDATE GTT_PISSALARYABSTRACT_NEW SET EX11=LV_CATEGORYCODEMERGE;
           end if;     
           
            IF P_GRADE IS NOT NULL then          
                SELECT WM_CONCAT(EX10)EX10 INTO LV_GRADECODEMERGE FROM 
                (
                    SELECT DISTINCT EX10 FROM GTT_PISSALARYABSTRACT_NEW WHERE EX10 IS NOT NULL
                );  
            
                UPDATE GTT_PISSALARYABSTRACT_NEW SET EX12=LV_GRADECODEMERGE;
            END IF;
           
            UPDATE  GTT_PISSALARYABSTRACT_NEW SET EX3 = TO_NUMBER(SLNO);
        
          IF UPPER(P_OPTION)='ALL' THEN
                DELETE FROM GTT_PISSALARYABSTRACT_NEW 
                    WHERE DEPARTMENTCODE<>'ALL';
                    
                UPDATE   GTT_PISSALARYABSTRACT_NEW SET REPORTMONTH =''||REPMONTH||''; 
          
          END IF;     
      
  
UPDATE GTT_PISSALARYABSTRACT_NEW A SET 
EX10 = (
SELECT WM_CONCAT(GRADE) GRADE FROM 
(
SELECT DISTINCT DEPARTMENTCODE, EX10 GRADE FROM GTT_PISSALARYABSTRACT
)
WHERE DEPARTMENTCODE=A.DEPARTMENTCODE
);

  
UPDATE GTT_PISSALARYABSTRACT_NEW A SET 
CATEGORYCODE = (
SELECT WM_CONCAT(CATEGORYCODE) CATEGORYCODE FROM 
(
SELECT DISTINCT DEPARTMENTCODE, CATEGORYCODE FROM GTT_PISSALARYABSTRACT
)
WHERE DEPARTMENTCODE=A.DEPARTMENTCODE
);

--UPDATE GTT_PISSALARYABSTRACT_NEW A SET 
--CATEGORYCODE = (
--SELECT WM_CONCAT(DISTINCT CATEGORYCODE) GRADE FROM GTT_PISSALARYABSTRACT
--WHERE DEPARTMENTCODE=A.DEPARTMENTCODE
----ORDER BY EX10
--)

                                   
END;
/


DROP PROCEDURE PROC_RPT_PISSALABSTRACT_NEW;

CREATE OR REPLACE PROCEDURE PROC_RPT_PISSALABSTRACT_new
(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_YEARMONTH     VARCHAR2,
    P_CATEGORYCODE     VARCHAR2 DEFAULT NULL,
    P_GRADE VARCHAR2 DEFAULT NULL
)
AS 
    P_FROMDATE     VARCHAR2(20);
    LV_SQLSTR      VARCHAR2(32000);       
    REPMONTH       VARCHAR2(20);
   
    LV_SLNO INT;
    LV_CNT INT;
    LV_COMP   VARCHAR2(100):='';
   
BEGIN
--        SELECT TO_CHAR(TO_DATE(''||P_YEARMONTH||'','MM/YY'),'DD/MM/YYYY') INTO  P_FROMDATE FROM DUAL;
        SELECT TO_CHAR(TO_DATE(''||P_YEARMONTH||'','YYYYMM'),'DD/MM/YYYY') INTO  P_FROMDATE FROM DUAL;
        
        SELECT TRIM(TO_CHAR(TO_DATE(''|| P_FROMDATE ||'','DD/MM/YYYY'),'MONTH')) ||'-'||TO_CHAR(TO_DATE(''|| P_FROMDATE ||'','DD/MM/YYYY'),'YYYY')  INTO REPMONTH FROM DUAL;
        

        DELETE FROM GTT_PISSALARYABSTRACT;
        ---DELETE FROM GTT_PISSALARYABSTRACT_SWTY;
        DELETE FROM GTT_PISSALARYABSTRACT_NEW; 
        
        LV_SQLSTR :=     '  INSERT INTO GTT_PISSALARYABSTRACT'|| CHR(10)    
                    ||   '  SELECT C.COMPANYNAME, D.DIVISIONNAME,'''||REPMONTH||''' REPORTMONTH,SLNO, A.DEPARTMENTCODE, B.DEPARTMENTDESC, A.CATEGORYCODE, /* E.CATEGORYDESC,NULL,*/ NULL, COMPONENTSHORTNAME,COMPONENTTYPE, COMPVALUE' || CHR(10)
                    ||   '  , GROSSEARN TOTAL_EARNING, GROSSDEDN TOTAL_DEDUCTION, MISC_CF COIN_CF, (GROSSEARN - GROSSDEDN) NET_RS' || CHR(10)
                    ||   '  ,CALCULATIONINDEX EX1,0 EX2,0 EX3,0 EX4,0 EX5,0 EX6,0 EX7,0 EX8,0 EX9,GRADECODE AS GRADECODE' || CHR(10)
                    ||   '  ,NULL EX11,NULL EX12,NULL EX13,NULL EX14,NULL EX15,NULL EX16,NULL EX17,NULL EX18,NULL EX19,NULL EX20 FROM ' || CHR(10)
                    ||   '  (' || CHR(10)
                    ||   '          SELECT SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE, COMPONENTSHORTNAME,COMPONENTTYPE,SUM(NVL(COMPVALUE,0)) COMPVALUE, SUM(GROSSEARN) GROSSEARN, SUM(GROSSDEDN) GROSSDEDN,SUM(MISC_CF) MISC_CF,CALCULATIONINDEX FROM' || CHR(10)
                    ||   '          (' || CHR(10)
                    ||   '              SELECT ''1'' SLNO, COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''SAL DAYS'' COMPONENTSHORTNAME,''GENERAL'' COMPONENTTYPE,1 CALCULATIONINDEX,SUM(ATTN_SALD) COMPVALUE,0 GROSSEARN, 0 GROSSDEDN,0 MISC_CF ' || CHR(10)
                    ||   '              FROM PISPAYTRANSACTION  ' || CHR(10)
                    ||   '              WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''' AND YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, CATEGORYCODE,GRADECODE' || CHR(10)
                    ||   '              UNION ALL' || CHR(10)
                    ||   '              SELECT ''1'' SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''ATN DAYS'' COMPONENTSHORTNAME,''GENERAL'' COMPONENTTYPE,2 CALCULATIONINDEX,SUM(ATTN_TOTD) COMPVALUE,0 GROSSEARN, 0 GROSSDEDN,0 MISC_CF ' || CHR(10)
                    ||   '              FROM PISPAYTRANSACTION  ' || CHR(10)
                    ||   '              WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''' AND YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, CATEGORYCODE,GRADECODE' || CHR(10)
                    ||   '              UNION ALL' || CHR(10)
                    ||   '              SELECT ''1'' SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''LV DAYS'' COMPONENTSHORTNAME,''GENERAL'' COMPONENTTYPE,3 CALCULATIONINDEX,SUM(ATTN_LDAY) COMPVALUE,0 GROSSEARN, 0 GROSSDEDN,0 MISC_CF ' || CHR(10)
                    ||   '              FROM PISPAYTRANSACTION  ' || CHR(10)
                    ||   '              WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''' AND YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, CATEGORYCODE,GRADECODE' || CHR(10)
                    ||   '              UNION ALL' || CHR(10)
                    ||   '              SELECT ''1'' SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''HOLIDAYS'' COMPONENTSHORTNAME,''GENERAL'' COMPONENTTYPE,4 CALCULATIONINDEX,SUM(ATTN_HOLD) COMPVALUE,0 GROSSEARN, 0 GROSSDEDN,0 MISC_CF ' || CHR(10)
                    ||   '              FROM PISPAYTRANSACTION  ' || CHR(10)
                    ||   '              WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''' AND YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, CATEGORYCODE,GRADECODE' || CHR(10)
                    ||   '              UNION ALL' || CHR(10)
                    ||   '              SELECT ''1'' SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''LV ENCHD'' COMPONENTSHORTNAME,''GENERAL'' COMPONENTTYPE,5 CALCULATIONINDEX,SUM(LV_ENCASH_DAYS) COMPVALUE,0 GROSSEARN, 0 GROSSDEDN,0 MISC_CF ' || CHR(10)
                    ||   '              FROM PISPAYTRANSACTION  ' || CHR(10)
                    ||   '              WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''' AND YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, CATEGORYCODE,GRADECODE' || CHR(10)
                    ||   '              UNION ALL' || CHR(10)
                    ||   '              SELECT ''1'' SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''N_ALL_HR'' COMPONENTSHORTNAME,''GENERAL'' COMPONENTTYPE,6 CALCULATIONINDEX,SUM(NS_HRS) COMPVALUE,0 GROSSEARN, 0 GROSSDEDN,0 MISC_CF ' || CHR(10)
                    ||   '              FROM PISPAYTRANSACTION  ' || CHR(10)
                    ||   '              WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''' AND YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, CATEGORYCODE,GRADECODE' || CHR(10)
                    ||   '              UNION ALL' || CHR(10)
                    ||   '              SELECT ''1'' SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''OT D/HR'' COMPONENTSHORTNAME,''GENERAL'' COMPONENTTYPE,7 CALCULATIONINDEX,SUM(DECODE(OT_HRS,0,OT_DAYS,OT_HRS)) COMPVALUE,0 GROSSEARN, 0 GROSSDEDN,0 MISC_CF ' || CHR(10)
                    ||   '              FROM PISPAYTRANSACTION  ' || CHR(10)
                    ||   '              WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''' AND YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, CATEGORYCODE,GRADECODE' || CHR(10)
                    ||   '              UNION ALL' || CHR(10)
                    ||   '              SELECT ''1'' SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,''PAY SLIP'' COMPONENTSHORTNAME,''GENERAL'' COMPONENTTYPE,8 CALCULATIONINDEX,COUNT(*) COMPVALUE,0 GROSSEARN, 0 GROSSDEDN,0 MISC_CF' || CHR(10)
                    ||   '              FROM PISPAYTRANSACTION  ' || CHR(10)
                    ||   '              WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||''' AND YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '              GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, CATEGORYCODE,GRADECODE' || CHR(10)
                    ||   '          UNION ALL' || CHR(10)    
                    ||   '          SELECT * FROM (  '  ||CHR(10)                
                    ||   '          SELECT ''2'' SLNO,PAYS.COMPANYCODE, PAYS.DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,CM.COMPONENTSHORTNAME,COMPONENTTYPE,CALCULATIONINDEX,' || CHR(10)
                    ||   '              FN_GET_COMPVALUE_PAYSLIP(PAYS.COMPANYCODE,PAYS.DIVISIONCODE,PAYS.YEARMONTH,PAYS.WORKERSERIAL,COMPONENTCODE,''PIS PAY SLIP'') COMPVALUE,GROSSEARN,GROSSDEDN, MISC_CF ' || CHR(10)
                    ||   '               FROM PISPAYTRANSACTION PAYS,' || CHR(10)
                    ||   '               (' || CHR(10)
                    ||   '                  SELECT DISTINCT COMPANYCODE, DIVISIONCODE,COMPONENTCODE,COMPONENTSHORTNAME,COMPONENTDESC,COMPONENTTYPE, CALCULATIONINDEX  ' || CHR(10)
                    ||   '                  FROM PISCOMPONENTMASTER' || CHR(10)
                    ||   '                  WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||'''' || CHR(10)
                    ||   '                  AND YEARMONTH='''|| P_YEARMONTH ||''' AND COMPONENTTYPE=''EARNING''' || CHR(10)
                    ||   '               ) CM,COLS B' || CHR(10)
                    ||   '              WHERE' || CHR(10)
                    ||   '              B.TABLE_NAME = ''PISPAYTRANSACTION''' || CHR(10)
                    --||   '              AND CM.COMPONENTTYPE IN(''EARNING'')' || CHR(10)
                    ||   '              and CM.COMPONENTCODE = B.COLUMN_NAME' || CHR(10)
                    ||   '              AND PAYS.COMPANYCODE=CM.COMPANYCODE' || CHR(10)
                    ||   '              AND PAYS.DIVISIONCODE=CM.DIVISIONCODE' || CHR(10)
                    ||   '              AND PAYS.COMPANYCODE='''|| P_COMPANYCODE ||''' ' || CHR(10)
                    ||   '              AND PAYS.DIVISIONCODE='''|| P_DIVISIONCODE ||'''' || CHR(10)
                    ||   '              AND PAYS.YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '             ) WHERE COMPVALUE>0 ' || CHR(10)
                    ||   '          UNION ALL' || CHR(10)
                    ||   '          SELECT * FROM (  '  ||CHR(10)
                    ||   '          SELECT ''3'' SLNO,PAYS.COMPANYCODE, PAYS.DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE,COMPONENTSHORTNAME,COMPONENTTYPE,CALCULATIONINDEX,' || CHR(10)
                    ||   '              FN_GET_COMPVALUE_PAYSLIP(PAYS.COMPANYCODE,PAYS.DIVISIONCODE,PAYS.YEARMONTH,PAYS.WORKERSERIAL,COMPONENTCODE,''PIS PAY SLIP'') COMPVALUE,GROSSEARN,GROSSDEDN, MISC_CF ' || CHR(10)
                    ||   '               FROM PISPAYTRANSACTION PAYS,' || CHR(10)
                    ||   '               (' || CHR(10)
                    ||   '                  SELECT DISTINCT COMPANYCODE, DIVISIONCODE,COMPONENTCODE,COMPONENTSHORTNAME,COMPONENTDESC,COMPONENTTYPE, CALCULATIONINDEX  ' || CHR(10)
                    ||   '                  FROM PISCOMPONENTMASTER' || CHR(10)
                    ||   '                  WHERE COMPANYCODE='''|| P_COMPANYCODE ||''' AND DIVISIONCODE='''|| P_DIVISIONCODE ||'''' || CHR(10)
                    ||   '                  AND YEARMONTH='''|| P_YEARMONTH ||''' AND COMPONENTTYPE=''DEDUCTION''' || CHR(10)
                    ||   '               )  CM,COLS B' || CHR(10)
                    ||   '              WHERE' || CHR(10)
                    ||   '              B.TABLE_NAME = ''PISPAYTRANSACTION''' || CHR(10)
--                    ||   '              AND CM.COMPONENTTYPE IN(''DEDUCTION'')' || CHR(10)
                    ||   '              and CM.COMPONENTCODE = B.COLUMN_NAME' || CHR(10)
                    ||   '              AND PAYS.COMPANYCODE=CM.COMPANYCODE' || CHR(10)
                    ||   '              AND PAYS.DIVISIONCODE=CM.DIVISIONCODE' || CHR(10)
                    ||   '              AND PAYS.COMPANYCODE='''|| P_COMPANYCODE ||''' ' || CHR(10)
                    ||   '              AND PAYS.DIVISIONCODE='''|| P_DIVISIONCODE ||'''' || CHR(10)
                    ||   '              AND PAYS.YEARMONTH = '''|| P_YEARMONTH ||'''' || CHR(10)
                    ||   '             ) WHERE COMPVALUE>0 ' || CHR(10)
                    ||   '          ) ' || CHR(10)
                    ||   '          GROUP BY SLNO,COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,  CATEGORYCODE,GRADECODE, COMPONENTSHORTNAME,COMPONENTTYPE,CALCULATIONINDEX' || CHR(10)
                    ||   '          ORDER BY CALCULATIONINDEX' || CHR(10)
                    ||   '      ) A, PISDEPARTMENTMASTER B, COMPANYMAST C, DIVISIONMASTER D --, PISCATEGORYMASTER E' || CHR(10)
                    ||   '      WHERE A.COMPANYCODE = B.COMPANYCODE' || CHR(10)
                    ||   '       AND A.COMPANYCODE = C.COMPANYCODE' || CHR(10)
                    ||   '       AND A.COMPANYCODE = D.COMPANYCODE' || CHR(10)
                    ||   '       AND A.DIVISIONCODE = B.DIVISIONCODE' || CHR(10)
                    ||   '       AND A.DIVISIONCODE = D.DIVISIONCODE' || CHR(10)
                    ||   '       AND A.DEPARTMENTCODE = B.DEPARTMENTCODE' || CHR(10);                       
                    IF P_CATEGORYCODE IS NOT NULL THEN
                        LV_SQLSTR := LV_SQLSTR ||   '   AND      A.CATEGORYCODE  IN ('|| P_CATEGORYCODE ||')' || CHR(10);
                    END IF;      
                    
                    IF P_GRADE IS NOT NULL THEN
                        LV_SQLSTR := LV_SQLSTR ||   '   AND      A.GRADECODE  IN ('|| P_GRADE ||')' || CHR(10);
                    END IF;                               
                    LV_SQLSTR := LV_SQLSTR ||   '  ORDER BY A.DEPARTMENTCODE,COMPONENTTYPE, EX1' || CHR(10);
                                                    
     DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
     EXECUTE IMMEDIATE LV_SQLSTR;
                    
     DELETE  FROM GTT_PISSALARYABSTRACT_DATA;
                    
     INSERT INTO GTT_PISSALARYABSTRACT_DATA
     SELECT DISTINCT DEPARTMENTCODE,DEPARTMENTNAME, SUM(GEN_INDEX)GEN_INDEX, SUM(EARN_INDEX)EARN_INDEX, SUM(DED_INDEX) DED_INDEX, COMPNAME_GEN,SUM(COMPVAL_GEN) COMPVAL_GEN,
      COMPNAME_EARN,SUM(COMPVAL_EARN) COMPVAL_EARN, COMPNAME_DED,SUM(COMPVAL_DED) COMPVAL_DED
        FROM
        (       
            SELECT DEPARTMENTCODE,DEPARTMENTNAME, 'GEN' COMPTYPE, COMPONENTNAME COMPNAME_GEN,SUM(COMPVALUE) COMPVAL_GEN,NULL COMPNAME_EARN,0 COMPVAL_EARN,NULL COMPNAME_DED,0 COMPVAL_DED, EX1 GEN_INDEX, 0 EARN_INDEX, 0 DED_INDEX 
            FROM GTT_PISSALARYABSTRACT WHERE COMPONENTTYPE='GENERAL'
            GROUP BY DEPARTMENTCODE,DEPARTMENTNAME,COMPONENTNAME, EX1            
            UNION ALL            
            SELECT DEPARTMENTCODE,DEPARTMENTNAME, 'EARN' COMPTYPE,NULL COMPNAME_GEN ,0 COMPVAL_GEN ,COMPONENTNAME COMPNAME_EARN ,SUM(COMPVALUE) COMPVAL_EARN,NULL COMPNAME_DED ,0 COMPVAL_DED, 0 GEN_INDEX, EX1 EARN_INDEX, 0 DED_INDEX
            FROM GTT_PISSALARYABSTRACT WHERE COMPONENTTYPE='EARNING'
            GROUP BY DEPARTMENTCODE,DEPARTMENTNAME,COMPONENTNAME, EX1            
            UNION ALL            
            SELECT DEPARTMENTCODE,DEPARTMENTNAME, 'DED' COMPTYPE,NULL COMPNAME_GEN,0 COMPVAL_GEN,NULL COMPNAME_EARN,0 COMPVAL_EARN,COMPONENTNAME COMPNAME_DED,SUM(COMPVALUE) COMPVAL_DED,  0 GEN_INDEX, 0 EARN_INDEX, EX1 DED_INDEX
            FROM GTT_PISSALARYABSTRACT WHERE COMPONENTTYPE='DEDUCTION'
            GROUP BY DEPARTMENTCODE,DEPARTMENTNAME,COMPONENTNAME, EX1            
        )
       -- WHERE DEPARTMENTCODE='0001'
        GROUP BY DEPARTMENTCODE,DEPARTMENTNAME,COMPNAME_GEN,COMPNAME_EARN,COMPNAME_DED
        ORDER BY  GEN_INDEX, EARN_INDEX, DED_INDEX;
        
--     SELECT DISTINCT DEPARTMENTCODE,DEPARTMENTNAME,COLINDEX, COMPNAME_GEN,SUM(COMPVAL_GEN) COMPVAL_GEN,
--     COMPNAME_EARN,SUM(COMPVAL_EARN) COMPVAL_EARN, COMPNAME_DED,SUM(COMPVAL_DED) COMPVAL_DED
--        FROM
--        (
--            SELECT DEPARTMENTCODE,DEPARTMENTNAME, 'GEN' COMPTYPE, COMPONENTNAME COMPNAME_GEN,SUM(COMPVALUE) COMPVAL_GEN,NULL COMPNAME_EARN,0 COMPVAL_EARN,NULL COMPNAME_DED,0 COMPVAL_DED, EX1 COLINDEX 
--            FROM GTT_PISSALARYABSTRACT WHERE COMPONENTTYPE='GENERAL'
--            GROUP BY DEPARTMENTCODE,DEPARTMENTNAME,COMPONENTNAME, EX1
--            UNION ALL
--            SELECT DEPARTMENTCODE,DEPARTMENTNAME, 'EARN' COMPTYPE,NULL COMPNAME_GEN ,0 COMPVAL_GEN ,COMPONENTNAME COMPNAME_EARN ,SUM(COMPVALUE) COMPVAL_EARN,NULL COMPNAME_DED ,0 COMPVAL_DED, EX1 COLINDEX
--            FROM GTT_PISSALARYABSTRACT WHERE COMPONENTTYPE='EARNING'
--            GROUP BY DEPARTMENTCODE,DEPARTMENTNAME,COMPONENTNAME, EX1
--            UNION ALL
--            SELECT DEPARTMENTCODE,DEPARTMENTNAME, 'DED' COMPTYPE,NULL COMPNAME_GEN,0 COMPVAL_GEN,NULL ,0 COMPVAL_EARN,COMPONENTNAME COMPNAME_DED,SUM(COMPVALUE) COMPVAL_DED, EX1 COLINDEX 
--            FROM GTT_PISSALARYABSTRACT WHERE COMPONENTTYPE='DEDUCTION'
--            GROUP BY DEPARTMENTCODE,DEPARTMENTNAME,COMPONENTNAME, EX1
--        )
--        ---WHERE DEPARTMENTCODE='0001'
--        GROUP BY DEPARTMENTCODE,DEPARTMENTNAME,COMPTYPE,COLINDEX,COMPNAME_GEN,COMPNAME_EARN,COMPNAME_DED
--        ORDER BY  COLINDEX ;  
     

--GEN_INDEX, EARN_INDEX, DED_INDEX
     
    DELETE GTT_PISSALARYABSTRACT_NEW;
    
     FOR CDEPT IN( SELECT DISTINCT DEPARTMENTCODE , DEPARTMENTNAME 
                FROM GTT_PISSALARYABSTRACT_DATA /* WHERE DEPARTMENTCODE N('0001','0002fff') */  ORDER BY DEPARTMENTCODE )
      LOOP        
          -----------------  GEN --------------------
          FOR C2 IN (SELECT COMPNAME_GEN , SUM(COMPVAL_GEN) COMPVAL_GEN FROM GTT_PISSALARYABSTRACT_DATA
                        WHERE COMPNAME_GEN IS NOT NULL
                        AND DEPARTMENTCODE = CDEPT.DEPARTMENTCODE
                        GROUP BY  COMPNAME_GEN ,GEN_INDEX
                         ORDER BY GEN_INDEX)
            LOOP        
             SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
             INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_GEN,COMPVAL_GEN)
             VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C2.COMPNAME_GEN,C2.COMPVAL_GEN) ;        
          END LOOP;
          ----------------- EARN ----------
           FOR C3 IN (SELECT  COMPNAME_EARN , SUM(COMPVAL_EARN) COMPVAL_EARN FROM GTT_PISSALARYABSTRACT_DATA
                        WHERE COMPVAL_EARN>0--COMPNAME_EARN IS NOT NULL
                        AND DEPARTMENTCODE = CDEPT.DEPARTMENTCODE
                        GROUP BY  COMPNAME_EARN,EARN_INDEX
                         ORDER BY EARN_INDEX
                )LOOP 
                   SELECT COUNT(*)  INTO LV_CNT FROM  GTT_PISSALARYABSTRACT_NEW WHERE   DEPARTMENTCODE = CDEPT.DEPARTMENTCODE    ;
                IF LV_CNT > 0 THEN
                      SELECT MIN(to_number(SLNO)) INTO LV_SLNO  FROM GTT_PISSALARYABSTRACT_NEW WHERE   DEPARTMENTCODE = CDEPT.DEPARTMENTCODE 
                      AND COMPNAME_EARN IS NULL;
                      
                      IF LV_SLNO IS NOT NULL THEN
                           UPDATE GTT_PISSALARYABSTRACT_NEW SET COMPNAME_EARN = C3.COMPNAME_EARN , COMPVAL_EARN = C3.COMPVAL_EARN-- ,COLINDEX=C3.COLINDEX
                           WHERE SLNO = LV_SLNO;
                     ELSE    
                    -- DBMS_OUTPUT.PUT_LINE(C3.COMPNAME_EARN||'update inst C3.COMPNAME_EARN');                 
                      -- if LV_COMP<>C3.COMPNAME_EARN then 
                           SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
                        --   DBMS_OUTPUT.PUT_LINE(LV_SLNO||' update inst LV_SLNO');
                           INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_EARN,COMPVAL_EARN)
                           VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C3.COMPNAME_EARN,C3.COMPVAL_EARN) ;
                           LV_COMP:=C3.COMPNAME_EARN;
                     --  end if; 
                   END IF;           
              ELSE
                   -- DBMS_OUTPUT.PUT_LINE(C3.COMPNAME_EARN||'inst C3.COMPNAME_EARN');
                   SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
                 --  DBMS_OUTPUT.PUT_LINE(LV_SLNO||'LV_SLNO');
                  INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_EARN,COMPVAL_EARN)
                  VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C3.COMPNAME_EARN,C3.COMPVAL_EARN) ;
                END IF;                
          END LOOP;
          ------------------------- END EARN ---------------------------------
          ------------------------- DEDN -----------------------------------
           FOR C4 IN (SELECT  COMPNAME_DED , SUM(COMPVAL_DED) COMPVAL_DED FROM GTT_PISSALARYABSTRACT_DATA
                    WHERE COMPVAL_DED>0--COMPNAME_DED IS NOT NULL
                    AND DEPARTMENTCODE = CDEPT.DEPARTMENTCODE
                    GROUP BY  COMPNAME_DED,DED_INDEX
                     ORDER BY DED_INDEX)
            LOOP 
            SELECT COUNT(*)  INTO LV_CNT FROM  GTT_PISSALARYABSTRACT_NEW WHERE   DEPARTMENTCODE = CDEPT.DEPARTMENTCODE    ;
            IF LV_CNT > 0 THEN
              SELECT MIN(SLNO) INTO LV_SLNO  FROM GTT_PISSALARYABSTRACT_NEW WHERE   DEPARTMENTCODE = CDEPT.DEPARTMENTCODE 
              AND COMPNAME_DED IS NULL;                     
              IF LV_SLNO IS NOT NULL THEN
              --DBMS_OUTPUT.PUT_LINE(C4.COMPNAME_DED||' update C4.COMPNAME_DED');
               UPDATE GTT_PISSALARYABSTRACT_NEW SET COMPNAME_DED = C4.COMPNAME_DED , COMPVAL_DED = C4.COMPVAL_DED--,COLINDEX=C4.COLINDEX
               WHERE SLNO = LV_SLNO;
              ELSE
              --DBMS_OUTPUT.PUT_LINE(C4.COMPNAME_DED||' update inst C4.COMPNAME_DED');
               SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
               INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_DED,COMPVAL_DED)
               VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C4.COMPNAME_DED,C4.COMPVAL_DED) ; 
              END IF;           
            ELSE
            --DBMS_OUTPUT.PUT_LINE(C4.COMPNAME_DED||' insert C4.COMPNAME_DED');
              SELECT NVL(MAX(to_number(SLNO)),0)+1 INTO LV_SLNO FROM GTT_PISSALARYABSTRACT_NEW ;
               INSERT INTO GTT_PISSALARYABSTRACT_NEW(SLNO,DEPARTMENTCODE , DEPARTMENTNAME,COMPNAME_DED,COMPVAL_DED)
               VALUES(LV_SLNO,CDEPT.DEPARTMENTCODE,CDEPT.DEPARTMENTNAME,C4.COMPNAME_DED,C4.COMPVAL_DED) ;
            END IF;                
      END LOOP;
      --------------------------- END DEDN -----------------------------------      
      --EXIT;
      
      
      --COMMIT;
END LOOP;
     
--      
--      UPDATE  GTT_PISSALARYABSTRACT_NEW A SET(TOTAL_EARNING, TOTAL_DEDUCTION, COIN_CF, NET_RS)=
--      (SELECT  SUM(NVL(GROSSEARN,0))TOTAL_EARN , SUM(NVL(GROSSDEDN,0)) TOTAL_DEDN, SUM(NVL(MISC_CF,0)) CNF,SUM(NVL(NETSALARY,0))NETRS 
--       FROM PISPAYTRANSACTION B
--       WHERE A.DEPARTMENTCODE=B.DEPARTMENTCODE
--       AND B.COMPANYCODE=P_COMPANYCODE
--       AND B.DIVISIONCODE=P_DIVISIONCODE
--       AND B.YEARMONTH=P_YEARMONTH);
--       
--    
--      UPDATE  GTT_PISSALARYABSTRACT_NEW A SET(COMPANYNAME, DIVISIONNAME, REPORTMONTH, CATEGORYCODE, CATEGORYDESC)=
--        (SELECT DISTINCT COMPANYNAME, DIVISIONNAME, REPORTMONTH, CATEGORYCODE, CATEGORYDESC
--                                              FROM  GTT_PISSALARYABSTRACT B
--                                              WHERE A.DEPARTMENTCODE=B.DEPARTMENTCODE);
                                              
 
--LV_SQLSTR := LV_SQLSTR ||   '  ORDER BY A.DEPARTMENTCODE,COMPONENTTYPE, EX1' || CHR(10);

      LV_SQLSTR :=   '  UPDATE  GTT_PISSALARYABSTRACT_NEW A SET(TOTAL_EARNING, TOTAL_DEDUCTION, COIN_CF, NET_RS)=' || CHR(10)
       ||   '  (SELECT  SUM(NVL(GROSSEARN,0))TOTAL_EARN , SUM(NVL(GROSSDEDN,0)) TOTAL_DEDN, SUM(NVL(MISC_CF,0)) CNF,SUM(NVL(NETSALARY,0))NETRS ' || CHR(10)
       ||   '  FROM PISPAYTRANSACTION B' || CHR(10)
       ||   '   WHERE A.DEPARTMENTCODE=B.DEPARTMENTCODE' || CHR(10)
       ||   '   AND B.COMPANYCODE='''||P_COMPANYCODE||'''' || CHR(10)
       ||   '   AND B.DIVISIONCODE='''||P_DIVISIONCODE||'''' || CHR(10)
      
       ||   '   AND B.YEARMONTH='''||P_YEARMONTH||'''' || CHR(10);
      
         IF P_CATEGORYCODE IS NOT NULL THEN
                        LV_SQLSTR := LV_SQLSTR ||   '   AND      B.CATEGORYCODE  IN ('|| P_CATEGORYCODE ||')' || CHR(10);
        END IF;                                    
                    
        LV_SQLSTR := LV_SQLSTR ||   ')' || CHR(10);
      
    
                                              
     --DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
     EXECUTE IMMEDIATE LV_SQLSTR;
     
     
      UPDATE  GTT_PISSALARYABSTRACT_NEW A SET(COMPANYNAME, DIVISIONNAME, REPORTMONTH, CATEGORYCODE, CATEGORYDESC,EX10)=
        (SELECT DISTINCT COMPANYNAME, DIVISIONNAME, REPORTMONTH, CATEGORYCODE, CATEGORYDESC,EX10
                                              FROM  GTT_PISSALARYABSTRACT B
                                              WHERE A.DEPARTMENTCODE=B.DEPARTMENTCODE --and a.CATEGORYCODE=b.CATEGORYCODE
                                              );
                                              

      UPDATE  GTT_PISSALARYABSTRACT_NEW SET EX3 = TO_NUMBER(SLNO);
                                                                                                                   
                       
--      **************************
--
--update  GTT_PISSALARYABSTRACT_NEW A set (EX11,EX4)=
--(SELECT COMPNAME_GEN,sum(COMPVAL_GEN) from  GTT_PISSALARYABSTRACT_NEW
--where  COMPVAL_GEN>0 AND COMPNAME_GEN=A.COMPNAME_GEN
--group by COMPNAME_GEN)
--
--update  GTT_PISSALARYABSTRACT_NEW A set (EX12,EX5)= 
--(select COMPNAME_EARN, sum(COMPVAL_EARN) from  GTT_PISSALARYABSTRACT_NEW
--where  COMPVAL_EARN>0 AND COMPNAME_EARN=A.COMPNAME_EARN
--group by COMPNAME_EARN)
--
--
--select COMPNAME_DED, sum(COMPVAL_DED) from  GTT_PISSALARYABSTRACT_NEW
--where  COMPVAL_DED>0
--group by COMPNAME_DED
--
--
--update  GTT_PISSALARYABSTRACT_NEW set EX11=
--(SELECT COMPNAME_GEN from  GTT_PISSALARYABSTRACT_NEW
--where  COMPVAL_GEN>0
--group by COMPNAME_GEN)

     --    ************************                                                      
     
END;
/


DROP PROCEDURE PROC_RPT_PIS_PAYSLIP_ED;

CREATE OR REPLACE PROCEDURE          PROC_RPT_PIS_PAYSLIP_ED
(
    P_COMPANYCODE         VARCHAR2,
    P_DIVISIONCODE        VARCHAR2,
    P_YEARCODE            VARCHAR2,
    P_YEARMONTH           VARCHAR2,
    P_UNIT                VARCHAR2 DEFAULT NULL,
    P_CATEGORY            VARCHAR2 DEFAULT NULL,
    P_GRADE               VARCHAR2 DEFAULT NULL,
    P_WORKERSERIAL        VARCHAR2 DEFAULT NULL,
    P_STATE               VARCHAR2 DEFAULT NULL 
)
AS
    LV_RPT_CAPTION        VARCHAR2(500);
    LV_SQLSTR             VARCHAR2(5000);
    LV_YYMM               VARCHAR2(10);
    LV_MONTH               VARCHAR2(10);
    LV_YEAR                VARCHAR2(10);
    LV_COMPANYNAME               VARCHAR2(100);
    LV_DIVISIONNAME               VARCHAR2(100);
BEGIN
  

    SELECT TRIM(TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'MONTH')), 
    TO_CHAR(TO_DATE(P_YEARMONTH,'YYYYMM'),'YYYY') 
    INTO LV_MONTH, LV_YEAR  FROM  DUAL;


    SELECT COMPANYNAME, DIVISIONNAME
    INTO LV_COMPANYNAME,LV_DIVISIONNAME
    FROM COMPANYMAST CM, DIVISIONMASTER DM                      
    WHERE CM.COMPANYCODE=DM.COMPANYCODE
    AND CM.COMPANYCODE=P_COMPANYCODE
    AND DM.DIVISIONCODE= P_DIVISIONCODE;
                         
  
 
   
    LV_RPT_CAPTION:= 'SALARY FOR THE MONTH OF '||LV_MONTH||', '|| LV_YEAR;


    DELETE FROM GTT_PISPAYSLIP_ED_BIRLA WHERE 1=1;
--    
--    SELECT COMPANYCODE,DIVISIONCODE,COMPONENTTYPE, LISTAGG(COMPONENTCODE, ',') WITHIN GROUP (ORDER BY PHASE,CALCULATIONINDEX) COMPONENTCODE
----        SELECT COMPANYCODE,DIVISIONCODE,COMPONENTTYPE,WM_CONCAT(COMPONENTCODE)  COMPONENTCODE
--        FROM PISCOMPONENTMASTER
--        WHERE COMPANYCODE=P_COMPANYCODE
--        and DIVISIONCODE=P_DIVISIONCODE
--        AND COMPONENTTYPE IS NOT NULL
--        AND COMPONENTTYPE IN ('EARNING','DEDUCTION')
--        AND COMPONENTCODE <> 'NETSALARY'
--        GROUP BY COMPANYCODE,DIVISIONCODE,COMPONENTTYPE;
        
     
    FOR C1 IN
    (
        SELECT * FROM (
            SELECT  P_COMPANYCODE COMPANYCODE,P_DIVISIONCODE DIVISIONCODE,'EARNING' COMPONENTTYPE, WM_CONCAT(COMPONENTCODE)  COMPONENTCODE
            FROM 
            (
                SELECT COMPANYCODE,DIVISIONCODE,COMPONENTTYPE, COMPONENTCODE --, PHASE,CALCULATIONINDEX
                FROM PISCOMPONENTMASTER
                WHERE COMPANYCODE=P_COMPANYCODE
                and DIVISIONCODE=P_DIVISIONCODE
                AND COMPONENTTYPE IS NOT NULL
            --    AND COMPONENTTYPE IN ('EARNING','DEDUCTION') 
                AND COMPONENTTYPE IN ('EARNING') 
                ORDER BY COMPONENTTYPE,PHASE,CALCULATIONINDEX
            )
            UNION ALL
            SELECT  P_COMPANYCODE COMPANYCODE,P_DIVISIONCODE DIVISIONCODE,'DEDUCTION' COMPONENTTYPE, WM_CONCAT(COMPONENTCODE)  COMPONENTCODE
            FROM 
            (
                SELECT COMPANYCODE,DIVISIONCODE,COMPONENTTYPE, COMPONENTCODE --, PHASE,CALCULATIONINDEX
                FROM PISCOMPONENTMASTER
                WHERE COMPANYCODE=P_COMPANYCODE
                and DIVISIONCODE=P_DIVISIONCODE
                AND COMPONENTTYPE IS NOT NULL
            --    AND COMPONENTTYPE IN ('EARNING','DEDUCTION') 
                AND COMPONENTTYPE = 'DEDUCTION'
                ORDER BY COMPONENTTYPE,PHASE,CALCULATIONINDEX
            )

        )
    )
    LOOP
    
        IF LV_SQLSTR IS NOT NULL THEN
            LV_SQLSTR := LV_SQLSTR || 'UNION ALL'||CHR(10);
        END IF;
        
        LV_SQLSTR := LV_SQLSTR || 'SELECT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL,TOKENNO, COMPONENTCODE, COMPONENTVALUE FROM PISPAYTRANSACTION'||CHR(10);
        LV_SQLSTR := LV_SQLSTR || 'UNPIVOT ('||CHR(10);
        LV_SQLSTR := LV_SQLSTR || '    COMPONENTVALUE  -- unpivot_clause'||CHR(10);
        LV_SQLSTR := LV_SQLSTR || '    FOR COMPONENTCODE --  unpivot_for_clause'||CHR(10);
        LV_SQLSTR := LV_SQLSTR || '    IN ('||C1.COMPONENTCODE||' )'||CHR(10);
        LV_SQLSTR := LV_SQLSTR || ')'||CHR(10);
        LV_SQLSTR := LV_SQLSTR || 'WHERE COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10);
        LV_SQLSTR := LV_SQLSTR || 'AND DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10);
        LV_SQLSTR := LV_SQLSTR || 'AND YEARMONTH='''||P_YEARMONTH||''''||CHR(10);
        IF P_UNIT IS NOT NULL THEN
            LV_SQLSTR := LV_SQLSTR || 'AND UNITCODE IN ('||P_UNIT||')'||CHR(10);
        END IF;
        IF P_CATEGORY IS NOT NULL THEN
            LV_SQLSTR := LV_SQLSTR || 'AND CATEGORYCODE IN ('||P_CATEGORY||')'||CHR(10);
        END IF;
        IF P_GRADE IS NOT NULL THEN
            LV_SQLSTR := LV_SQLSTR || 'AND GRADECODE IN ('||P_GRADE||')'||CHR(10);
        END IF;
        IF P_WORKERSERIAL IS NOT NULL THEN
            LV_SQLSTR := LV_SQLSTR || 'AND WORKERSERIAL IN ('||P_WORKERSERIAL||')'||CHR(10);
        END IF;
        LV_SQLSTR := LV_SQLSTR || 'AND YEARMONTH='''||P_YEARMONTH||''''||CHR(10);
    END LOOP;
        
    LV_SQLSTR := 'INSERT INTO GTT_PISPAYSLIP_ED_BIRLA ( COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO, COMPONENTCODE, COMPONENTVALUE, COMPONENTSHORTNAME, PHASE, CALCULATIONINDEX, COMPONENTTYPE )'||CHR(10)
    ||'SELECT  A.COMPANYCODE, A.DIVISIONCODE, A.YEARMONTH, A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL,A.TOKENNO,'||CHR(10) 
    ||'A.COMPONENTCODE, A.COMPONENTVALUE,B.COMPONENTSHORTNAME, B.PHASE, B.CALCULATIONINDEX, B.COMPONENTTYPE FROM'||CHR(10)
    ||'('||CHR(10)
    || LV_SQLSTR ||CHR(10)
    ||')A,PISCOMPONENTMASTER B WHERE A.COMPONENTCODE=B.COMPONENTCODE AND B.COMPANYCODE='''||P_COMPANYCODE||''' AND B.DIVISIONCODE='''||P_DIVISIONCODE||''' AND COMPONENTVALUE <> 0'||CHR(10);


    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    EXECUTE IMMEDIATE LV_SQLSTR;
    
--    LV_SQLSTR := NULL;
--    LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_PISPAYSLIP_ED_BIRLA'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, '|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    WORKERSERIAL, TOKENNO, COMPONENTCODE, COMPONENTSHORTNAME, PHASE, CALCULATIONINDEX, COMPONENTTYPE'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || ')'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || 'SELECT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE,'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || 'WORKERSERIAL, TOKENNO,''GENERAL'' COMPONENTCODE,COMPONENTSHORTNAME,1 PHASE, TO_NUMBER(CALCULATIONINDEX) CALCULATIONINDEX,COMPONENTTYPE FROM '|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    SELECT A.COMPANYCODE,A.DIVISIONCODE, A.TOKENNO,A.YEARMONTH, A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL,'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    ''GENERAL'' COMPONENTTYPE, A.TOKENNO||'' ''||B.EMPLOYEENAME CODE_ND_NAME, ''DESIG : ''||C.DESIGNATIONDESC DESIG, ''DPMT  : ''||D.DEPARTMENTDESC DPMT,'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    ''PF NO.: ''||B.PFNO PFNO,''ESI NO: ''||B.ESINO ESINO,''A/c No: ''||B.BANKACCNUMBER BANKACCNUMBER,''UAN No: ''||B.UANNO UANNO'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    FROM '|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    ('|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '        SELECT DISTINCT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, '|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '        CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO '|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '        FROM GTT_PISPAYSLIP_ED_BIRLA'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    ) A, PISEMPLOYEEMASTER B, PISDESIGNATIONMASTER C, PISDEPARTMENTMASTER D'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    WHERE A.COMPANYCODE=B.COMPANYCODE'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    AND A.DIVISIONCODE=B.DIVISIONCODE'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    AND A.TOKENNO=B.TOKENNO'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    AND B.COMPANYCODE=C.COMPANYCODE'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    AND B.DIVISIONCODE=C.DIVISIONCODE'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    AND B.DESIGNATIONCODE=C.DESIGNATIONCODE'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    AND B.COMPANYCODE=D.COMPANYCODE'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    AND B.DIVISIONCODE=D.DIVISIONCODE'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    AND B.DEPARTMENTCODE=D.DEPARTMENTCODE'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || ')'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || 'UNPIVOT'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    COMPONENTSHORTNAME'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    FOR CALCULATIONINDEX IN (CODE_ND_NAME AS ''1'',DESIG AS ''2'',DPMT AS ''3'',PFNO AS ''3'',ESINO AS ''4'',BANKACCNUMBER AS ''5'',UANNO AS ''6'')'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || ')'|| CHR(10);
--    
--    
--    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
--    EXECUTE IMMEDIATE LV_SQLSTR;
    
    

LV_SQLSTR := '-------------------------------------------------------------------------------------' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '--GENERAL' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '-------------------------------------------------------------------------------------' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_PISPAYSLIP_ED_BIRLA' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WORKERSERIAL, TOKENNO, COMPONENTCODE,COMPONENTVALUE, COMPONENTSHORTNAME, PHASE, CALCULATIONINDEX, COMPONENTTYPE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'SELECT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'WORKERSERIAL, TOKENNO,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''EMPCODE'',''EMP CODE'',''EMPLOYEENAME'',''EMP NAME'',''DESIG'',''DESIGNATION'',''DPMT'',''DEPARTMENT'',''DATEOFBIRTH'',''DATE OF BIRTH'',''DATEOFJOIN'',''DATE OF JOINING'') COMPONENTCODE ,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ' NULL COMPONENTVALUE,COMPONENTSHORTNAME, 1 PHASE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''EMPCODE'',1,''EMPLOYEENAME'',2,''DESIG'',3,''DPMT'',4,''DATEOFBIRTH'',5,''DATEOFJOIN'',6)  CALCULATIONINDEX,COMPONENTTYPE FROM ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SELECT A.COMPANYCODE,A.DIVISIONCODE, A.TOKENNO,A.YEARMONTH, A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    ''GENERAL'' COMPONENTTYPE,B.TOKENNO EMPCODE, B.EMPLOYEENAME, C.DESIGNATIONDESC DESIG, D.DEPARTMENTDESC DPMT,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    TO_CHAR(B.DATEOFBIRTH,''DD/MM/YYYY'') DATEOFBIRTH,TO_CHAR(B.DATEOFJOIN,''DD/MM/YYYY'') DATEOFJOIN ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FROM ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    (' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '        SELECT DISTINCT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '        CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '        FROM GTT_PISPAYSLIP_ED_BIRLA' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    ) A, PISEMPLOYEEMASTER B, PISDESIGNATIONMASTER C, PISDEPARTMENTMASTER D' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WHERE A.COMPANYCODE=B.COMPANYCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND A.DIVISIONCODE=B.DIVISIONCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND A.TOKENNO=B.TOKENNO' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.COMPANYCODE=C.COMPANYCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.DIVISIONCODE=C.DIVISIONCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.DESIGNATIONCODE=C.DESIGNATIONCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.COMPANYCODE=D.COMPANYCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.DIVISIONCODE=D.DIVISIONCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.DEPARTMENTCODE=D.DEPARTMENTCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'UNPIVOT' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    COMPONENTSHORTNAME' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FOR COMPONENTCODE IN (EMPCODE,EMPLOYEENAME,DESIG,DPMT,DATEOFBIRTH,DATEOFJOIN)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);


DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
EXECUTE IMMEDIATE LV_SQLSTR;
        
    SELECT DISTINCT TO_CHAR(STARTDATE,'YYYYMM') INTO LV_YYMM FROM FINANCIALYEAR
    WHERE TO_DATE(P_YEARMONTH,'YYYYMM') BETWEEN STARTDATE AND ENDDATE;
    
--    LV_SQLSTR := NULL;
--    LV_SQLSTR := LV_SQLSTR || ''|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_PISPAYSLIP_ED_BIRLA'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, '|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    WORKERSERIAL, TOKENNO, COMPONENTCODE,COMPONENTVALUE, COMPONENTSHORTNAME, PHASE, CALCULATIONINDEX, COMPONENTTYPE'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || ')'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || 'SELECT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE,'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || 'WORKERSERIAL, TOKENNO,COMPONENTCODE,COMPONENTVALUE,'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''YTD_PF'',''Y.T.D. PF'',''YTD_FPF'',''Y.T.D. FP'',''YTD_VPF'',''Y.T.D. VPF'',''YTD_EC'',''Y.T.D. EC'',''YTD_GR'',''Y.T.D. GR'',''PFLN_BAL'',''PFLN BAL'',''SADV_BAL'',''SADV BAL'',''FEST_BAL'',''FEST BAL'',''PENSION'',''PENSION'',''PF_COMP'',''PF COMP'') COMPONENTSHORTNAME,'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '1 PHASE, '|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''YTD_PF'',1,''YTD_FPF'',2,''YTD_VPF'',3,''YTD_EC'',4,''YTD_GR'',5,''PFLN_BAL'',6,''SADV_BAL'',7,''FEST_BAL'',8,''PENSION'',9,''PF_COMP'',10) CALCULATIONINDEX,COMPONENTTYPE FROM '|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    SELECT A.COMPANYCODE,A.DIVISIONCODE, A.TOKENNO,'''||P_YEARMONTH||''' YEARMONTH, A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL,''YTD'' COMPONENTTYPE,'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    SUM(NVL(PF_E,0)) YTD_PF,SUM(NVL(FPF,0)) YTD_FPF ,0 YTD_VPF ,0 YTD_EC ,0 YTD_GR ,0 PFLN_BAL ,0 SADV_BAL ,0 FEST_BAL ,0 PENSION ,0 PF_COMP '|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    FROM PISPAYTRANSACTION A'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    WHERE COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||''' AND WORKERSERIAL IN  ( SELECT DISTINCT WORKERSERIAL FROM GTT_PISPAYSLIP_ED_BIRLA )'||CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    AND TO_NUMBER(YEARMONTH) >= TO_NUMBER('''||LV_YYMM||''')'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    AND TO_NUMBER(YEARMONTH) <= TO_NUMBER('''||P_YEARMONTH||''')'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    GROUP BY A.COMPANYCODE,A.DIVISIONCODE, A.TOKENNO,A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || ')'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || 'UNPIVOT'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    COMPONENTVALUE'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || '    FOR COMPONENTCODE IN (YTD_PF,YTD_FPF,YTD_VPF,YTD_EC,YTD_GR,PFLN_BAL,SADV_BAL,FEST_BAL,PENSION,PF_COMP)'|| CHR(10);
--    LV_SQLSTR := LV_SQLSTR || ')'|| CHR(10);
--    
--    
--    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
--    EXECUTE IMMEDIATE LV_SQLSTR;
    

    LV_SQLSTR := NULL;
    LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_PISPAYSLIP_ED_BIRLA'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '('|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    WORKERSERIAL, TOKENNO, COMPONENTCODE,COMPONENTVALUE, COMPONENTSHORTNAME, PHASE, CALCULATIONINDEX, COMPONENTTYPE'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || ')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'SELECT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, '|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'WORKERSERIAL,TOKENNO, DECODE(COMPONENTCODE,''ATTN_SALD'',''TOTAL PAY DAYS'',COMPONENTCODE) COMPONENTCODE, COMPONENTVALUE,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''ATTN_SALD'',COMPONENTVALUE||'' '',''TOTEARN'',''TOT. EARN'',''GROSSDEDN'',''TOT. DED.'',''NETSALARY'',''NET RS.'') COMPONENTSHORTNAME,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '7 PHASE,DECODE(COMPONENTCODE,''ATTN_SALD'',7,''TOTEARN'',1,''GROSSDEDN'',2,''NETSALARY'',3) CALCULATIONINDEX,'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''ATTN_SALD'',''GENERAL'',''TOTAL'') COMPONENTTYPE FROM PISPAYTRANSACTION'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'UNPIVOT ('|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    COMPONENTVALUE  -- unpivot_clause'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    FOR COMPONENTCODE --  unpivot_for_clause'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || '    IN (ATTN_SALD,TOTEARN,GROSSDEDN,NETSALARY)'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || ')'|| CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'WHERE COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND YEARMONTH='''||P_YEARMONTH||''''||CHR(10);
    LV_SQLSTR := LV_SQLSTR || 'AND WORKERSERIAL IN  ( SELECT DISTINCT WORKERSERIAL FROM GTT_PISPAYSLIP_ED_BIRLA )'||CHR(10);

    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    EXECUTE IMMEDIATE LV_SQLSTR;
    
    
    
    
    --ADDED
    
--    
--LV_SQLSTR := '-------------------------------------------------------------------------------------' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '--GENERAL' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '-------------------------------------------------------------------------------------' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_PISPAYSLIP_ED_BIRLA' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, ' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    WORKERSERIAL, TOKENNO, COMPONENTCODE,COMPONENTVALUE, COMPONENTSHORTNAME, PHASE, CALCULATIONINDEX, COMPONENTTYPE' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || 'SELECT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || 'WORKERSERIAL, TOKENNO, COMPONENTCODE,COMPONENTVALUE, ' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''EMPCODE'',''EMP CODE'',''EMPLOYEENAME'',''EMP NAME'',''DESIG'',''DESIGNATION'',''DPMT'',''DEPARTMENT'',''DATEOFBIRTH'',''DATE OF BIRTH'',''DATEOFJOIN'',''DATE OF JOINING'') COMPONENTSHORTNAME,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '1 PHASE, ' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''EMPCODE'',1,''EMPLOYEENAME'',2,''DESIG'',3,''DPMT'',4,''DATEOFBIRTH'',5,''DATEOFJOIN'',6)  CALCULATIONINDEX,COMPONENTTYPE FROM ' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    SELECT A.COMPANYCODE,A.DIVISIONCODE, A.TOKENNO,A.YEARMONTH, A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    ''GENERAL'' COMPONENTTYPE,B.TOKENNO EMPCODE, B.EMPLOYEENAME, C.DESIGNATIONDESC DESIG, D.DEPARTMENTDESC DPMT,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    TO_CHAR(B.DATEOFBIRTH,''DD/MM/YYYY'') DATEOFBIRTH,TO_CHAR(B.DATEOFJOIN,''DD/MM/YYYY'') DATEOFJOIN --,' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '--    B.PFNO,B.ESINO,B.BANKACCNUMBER,B.UANNO' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    FROM ' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    (' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '        SELECT DISTINCT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, ' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '        CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO ' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '        FROM GTT_PISPAYSLIP_ED_BIRLA' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    ) A, PISEMPLOYEEMASTER B, PISDESIGNATIONMASTER C, PISDEPARTMENTMASTER D' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    WHERE A.COMPANYCODE=B.COMPANYCODE' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    AND A.DIVISIONCODE=B.DIVISIONCODE' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    AND A.TOKENNO=B.TOKENNO' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    AND B.COMPANYCODE=C.COMPANYCODE' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    AND B.DIVISIONCODE=C.DIVISIONCODE' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    AND B.DESIGNATIONCODE=C.DESIGNATIONCODE' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    AND B.COMPANYCODE=D.COMPANYCODE' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    AND B.DIVISIONCODE=D.DIVISIONCODE' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    AND B.DEPARTMENTCODE=D.DEPARTMENTCODE' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || 'UNPIVOT' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    COMPONENTVALUE' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    FOR COMPONENTCODE IN (EMPCODE,EMPLOYEENAME,DESIG,DPMT,DATEOFBIRTH,DATEOFJOIN)' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
--
--
--DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
--EXECUTE IMMEDIATE LV_SQLSTR;


LV_SQLSTR := '-------------------------------------------------------------------------------------' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '--GENERAL  1' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '-------------------------------------------------------------------------------------' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_PISPAYSLIP_ED_BIRLA' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WORKERSERIAL, TOKENNO, COMPONENTCODE,COMPONENTVALUE, COMPONENTSHORTNAME, PHASE, CALCULATIONINDEX, COMPONENTTYPE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'SELECT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'WORKERSERIAL, TOKENNO, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''QTR_NO'',''QTR NO.'',''PFNO'',''PF NO.'',''ESINO'',''ESI NO'',''PENSIONNO'',''PENSION NO.'',''PANCARDNO'',''PAN NO.'',''GRATUITYNO'',''GRATUITY NO.'',''LEAVE_ENCASH_DAYS'',''LEAVE ENCASH DAYS'') ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'COMPONENTCODE,NULL COMPONENTVALUE,COMPONENTSHORTNAME, 1 PHASE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''QTR_NO'',1,''PFNO'',2,''ESINO'',3,''PENSIONNO'',4,''PANCARDNO'',5,''GRATUITYNO'',6,''LEAVE_ENCASH_DAYS'',7)  CALCULATIONINDEX,COMPONENTTYPE FROM ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SELECT A.COMPANYCODE,A.DIVISIONCODE, A.TOKENNO,A.YEARMONTH, A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    ''GENERAL1'' COMPONENTTYPE,NVL(B.QUARTERNO,''NA'') QTR_NO, B.PFNO, B.ESINO,B.PENSIONNO PENSIONNO,B.PANCARDNO, NVL(B.GRATUITYNUMBER,''NA'') GRATUITYNO, ''0'' LEAVE_ENCASH_DAYS' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FROM ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    (' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '        SELECT DISTINCT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '        CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '        FROM GTT_PISPAYSLIP_ED_BIRLA' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    ) A, PISEMPLOYEEMASTER B, PISDESIGNATIONMASTER C, PISDEPARTMENTMASTER D' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WHERE A.COMPANYCODE=B.COMPANYCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND A.DIVISIONCODE=B.DIVISIONCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND A.TOKENNO=B.TOKENNO' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.COMPANYCODE=C.COMPANYCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.DIVISIONCODE=C.DIVISIONCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.DESIGNATIONCODE=C.DESIGNATIONCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.COMPANYCODE=D.COMPANYCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.DIVISIONCODE=D.DIVISIONCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.DEPARTMENTCODE=D.DEPARTMENTCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'UNPIVOT' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    COMPONENTSHORTNAME' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FOR COMPONENTCODE IN (QTR_NO,PFNO,ESINO,PENSIONNO,PANCARDNO,GRATUITYNO,LEAVE_ENCASH_DAYS)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);


    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    EXECUTE IMMEDIATE LV_SQLSTR;

LV_SQLSTR := '-------------------------------------------------------------------------------------' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '--GENERAL  2' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '-------------------------------------------------------------------------------------' || CHR(10);

LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_PISPAYSLIP_ED_BIRLA' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WORKERSERIAL, TOKENNO, COMPONENTCODE,COMPONENTVALUE, COMPONENTSHORTNAME, PHASE, CALCULATIONINDEX, COMPONENTTYPE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'SELECT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'WORKERSERIAL, TOKENNO, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''BANK_NAME'',''BANK NAME'',''BANKACCNUMBER'',''BANK A/C NO.'',''PERSONAL_AREA'',''PERSONAL AREA'',''SUB_AREA'',''SUB AREA'',''GROUP_NAME'',''GROUP'',''SUBGROUP_NAME'',''SUB GROUP'') COMPONENTCODE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'NULL COMPONENTVALUE,COMPONENTSHORTNAME, 1 PHASE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''BANK_NAME'',1,''BANKACCNUMBER'',2,''PERSONAL_AREA'',3,''SUB_AREA'',4,''GROUP_NAME'',5,''SUBGROUP_NAME'',6)  CALCULATIONINDEX,COMPONENTTYPE ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'FROM' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SELECT A.COMPANYCODE,A.DIVISIONCODE, A.TOKENNO,A.YEARMONTH, A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    ''GENERAL2'' COMPONENTTYPE,''NA'' BANK_NAME, B.BANKACCNUMBER , ''NA'' PERSONAL_AREA,''NA'' SUB_AREA, ''NA'' GROUP_NAME, ''NA'' SUBGROUP_NAME' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FROM ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    (' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '        SELECT DISTINCT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '        CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '        FROM GTT_PISPAYSLIP_ED_BIRLA' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    ) A, PISEMPLOYEEMASTER B, PISDESIGNATIONMASTER C, PISDEPARTMENTMASTER D' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WHERE A.COMPANYCODE=B.COMPANYCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND A.DIVISIONCODE=B.DIVISIONCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND A.TOKENNO=B.TOKENNO' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.COMPANYCODE=C.COMPANYCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.DIVISIONCODE=C.DIVISIONCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.DESIGNATIONCODE=C.DESIGNATIONCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.COMPANYCODE=D.COMPANYCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.DIVISIONCODE=D.DIVISIONCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND B.DEPARTMENTCODE=D.DEPARTMENTCODE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'UNPIVOT' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    COMPONENTSHORTNAME' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FOR COMPONENTCODE IN (BANK_NAME,BANKACCNUMBER,PERSONAL_AREA,SUB_AREA,GROUP_NAME,SUBGROUP_NAME)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);

    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    EXECUTE IMMEDIATE LV_SQLSTR;
    
    
LV_SQLSTR := '-------------------------------------------------------------------------------------' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '--ASSIGN 1' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '-------------------------------------------------------------------------------------' || CHR(10);


LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_PISPAYSLIP_ED_BIRLA' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WORKERSERIAL, TOKENNO, COMPONENTCODE,COMPONENTVALUE, COMPONENTSHORTNAME, PHASE, CALCULATIONINDEX, COMPONENTTYPE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'SELECT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'WORKERSERIAL, TOKENNO,COMPONENTCODE,COMPONENTVALUE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''BASIC_RT'',''BASIC RT'',''FIX_VDA_RT'',''FIX/V.D.A  RT'',''OT_HRS'',''OT. HRS'') COMPONENTSHORTNAME,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '1 PHASE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''BASIC_RT'',1,''FIX_VDA_RT'',2,''OT_HRS'',3) CALCULATIONINDEX,COMPONENTTYPE FROM ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SELECT A.COMPANYCODE,A.DIVISIONCODE, A.TOKENNO,'''||P_YEARMONTH||''' YEARMONTH, A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL,''ASSIGN1'' COMPONENTTYPE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SUM(NVL(RT_BASIC,0)) BASIC_RT,0 FIX_VDA_RT ,SUM(NVL(OT_HRS,0)) OT_HRS ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FROM PISPAYTRANSACTION A' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WHERE COMPANYCODE='''||P_COMPANYCODE||'''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||''' AND WORKERSERIAL IN  ( SELECT DISTINCT WORKERSERIAL FROM GTT_PISPAYSLIP_ED_BIRLA )' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    AND TO_NUMBER(YEARMONTH) >= TO_NUMBER('''||LV_YYMM||''')'|| CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND TO_NUMBER(YEARMONTH) = TO_NUMBER('''||P_YEARMONTH||''')'|| CHR(10);
LV_SQLSTR := LV_SQLSTR || '    GROUP BY A.COMPANYCODE,A.DIVISIONCODE, A.TOKENNO,A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'UNPIVOT' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    COMPONENTVALUE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FOR COMPONENTCODE IN (BASIC_RT,FIX_VDA_RT,OT_HRS)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);


    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    EXECUTE IMMEDIATE LV_SQLSTR;
    
    
LV_SQLSTR := '-------------------------------------------------------------------------------------' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '--ASSIGN 2' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '-------------------------------------------------------------------------------------' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_PISPAYSLIP_ED_BIRLA' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WORKERSERIAL, TOKENNO, COMPONENTCODE,COMPONENTVALUE, COMPONENTSHORTNAME, PHASE, CALCULATIONINDEX, COMPONENTTYPE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'SELECT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'WORKERSERIAL, TOKENNO,COMPONENTCODE,COMPONENTVALUE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''SPL_ALLW'',''SPL/TRNG ALLW'',''PERS_ALLW'',''PERS. PAY RT'',''OT_RT'',''OT. RT.'') COMPONENTSHORTNAME,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '1 PHASE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''SPL_ALLW'',1,''PERS_ALLW'',2,''OT_RT'',3) CALCULATIONINDEX,COMPONENTTYPE FROM ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SELECT A.COMPANYCODE,A.DIVISIONCODE, A.TOKENNO,'''||P_YEARMONTH||''' YEARMONTH, A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    ''ASSIGN2'' COMPONENTTYPE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SUM(NVL(SPL_ALLOW,0)) SPL_ALLW, SUM(NVL(PER_ALLOW,0)) PERS_ALLW,0 OT_RT' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FROM PISPAYTRANSACTION A' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WHERE COMPANYCODE='''||P_COMPANYCODE||'''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||''' AND WORKERSERIAL IN  ( SELECT DISTINCT WORKERSERIAL FROM GTT_PISPAYSLIP_ED_BIRLA )' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    AND TO_NUMBER(YEARMONTH) >= TO_NUMBER('''||LV_YYMM||''')'|| CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND TO_NUMBER(YEARMONTH) = TO_NUMBER('''||P_YEARMONTH||''')'|| CHR(10);
LV_SQLSTR := LV_SQLSTR || '    GROUP BY A.COMPANYCODE,A.DIVISIONCODE, A.TOKENNO,A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'UNPIVOT' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    COMPONENTVALUE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FOR COMPONENTCODE IN (SPL_ALLW,PERS_ALLW,OT_RT)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);


    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    EXECUTE IMMEDIATE LV_SQLSTR;
    
    
LV_SQLSTR := '-------------------------------------------------------------------------------------' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '--ASSIGN 3' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '-------------------------------------------------------------------------------------' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_PISPAYSLIP_ED_BIRLA' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WORKERSERIAL, TOKENNO, COMPONENTCODE,COMPONENTVALUE, COMPONENTSHORTNAME, PHASE, CALCULATIONINDEX, COMPONENTTYPE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'SELECT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'WORKERSERIAL, TOKENNO,COMPONENTCODE,COMPONENTVALUE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''ADHOC_RT'',''ADHOC RT'',''CONV_ALLOW'',''CONV ALLOW'',''OT_AMT'',''OT. AMT'') COMPONENTSHORTNAME,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '1 PHASE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''ADHOC_RT'',1,''CONV_ALLOW'',2,''OT_AMT'',3) CALCULATIONINDEX,COMPONENTTYPE FROM ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SELECT A.COMPANYCODE,A.DIVISIONCODE, A.TOKENNO,'''||P_YEARMONTH||''' YEARMONTH, A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    ''ASSIGN3'' COMPONENTTYPE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SUM(NVL(ADHOC,0)) ADHOC_RT, SUM(NVL(CONV_ALOW,0))   CONV_ALLOW,SUM(NVL(OT_AMT,0))  OT_AMT' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FROM PISPAYTRANSACTION A' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WHERE COMPANYCODE='''||P_COMPANYCODE||'''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||''' AND WORKERSERIAL IN  ( SELECT DISTINCT WORKERSERIAL FROM GTT_PISPAYSLIP_ED_BIRLA )' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    AND TO_NUMBER(YEARMONTH) >= TO_NUMBER('''||LV_YYMM||''')'|| CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND TO_NUMBER(YEARMONTH) = TO_NUMBER('''||P_YEARMONTH||''')'|| CHR(10);
LV_SQLSTR := LV_SQLSTR || '    GROUP BY A.COMPANYCODE,A.DIVISIONCODE, A.TOKENNO,A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'UNPIVOT' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    COMPONENTVALUE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FOR COMPONENTCODE IN (ADHOC_RT,CONV_ALLOW,OT_AMT)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);


    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    EXECUTE IMMEDIATE LV_SQLSTR;
    
    
LV_SQLSTR := '-------------------------------------------------------------------------------------' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '--ASSIGN 4' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '-------------------------------------------------------------------------------------' || CHR(10);
 
LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_PISPAYSLIP_ED_BIRLA' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WORKERSERIAL, TOKENNO, COMPONENTCODE,COMPONENTVALUE, COMPONENTSHORTNAME, PHASE, CALCULATIONINDEX, COMPONENTTYPE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'SELECT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'WORKERSERIAL, TOKENNO,COMPONENTCODE,COMPONENTVALUE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''CO_OP_LOAN_BAL'',''CO-OP LOAN BAL'',COMPONENTCODE) COMPONENTSHORTNAME,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '1 PHASE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''CO_OP_LOAN_BAL'',1) CALCULATIONINDEX,COMPONENTTYPE FROM ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SELECT A.COMPANYCODE,A.DIVISIONCODE, A.TOKENNO,'''||P_YEARMONTH||''' YEARMONTH, A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    ''ASSIGN4'' COMPONENTTYPE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SUM(LNBL_BL) CO_OP_LOAN_BAL, SUM(LNBL_PFL) PF_LOAN_BAL, SUM(LNBL_STADV) STADV_LOAN_BAL' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FROM PISPAYTRANSACTION A' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WHERE COMPANYCODE='''||P_COMPANYCODE||'''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND DIVISIONCODE='''||P_DIVISIONCODE||''' AND WORKERSERIAL IN  ( SELECT DISTINCT WORKERSERIAL FROM GTT_PISPAYSLIP_ED_BIRLA )' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    AND TO_NUMBER(YEARMONTH) >= TO_NUMBER('''||LV_YYMM||''')'|| CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND TO_NUMBER(YEARMONTH) = TO_NUMBER('''||P_YEARMONTH||''')'|| CHR(10);
LV_SQLSTR := LV_SQLSTR || '    GROUP BY A.COMPANYCODE,A.DIVISIONCODE, A.TOKENNO,A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'UNPIVOT' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    COMPONENTVALUE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FOR COMPONENTCODE IN (CO_OP_LOAN_BAL, PF_LOAN_BAL, STADV_LOAN_BAL)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);


--    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    EXECUTE IMMEDIATE LV_SQLSTR;
    
    
 PRC_PIS_LEAVEBALANCE (P_COMPANYCODE,P_DIVISIONCODE,P_YEARCODE,P_YEARMONTH,'');

LV_SQLSTR := '-------------------------------------------------------------------------------------' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '--LEAVE ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '-------------------------------------------------------------------------------------' || CHR(10);
   
LV_SQLSTR := LV_SQLSTR || 'INSERT INTO GTT_PISPAYSLIP_ED_BIRLA' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WORKERSERIAL, TOKENNO, COMPONENTCODE,COMPONENTVALUE, COMPONENTSHORTNAME, PHASE, CALCULATIONINDEX, COMPONENTTYPE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'SELECT COMPANYCODE, DIVISIONCODE, YEARMONTH, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'WORKERSERIAL, TOKENNO,LEAVECODE COMPONENTCODE,COMPONENTVALUE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''AVL'',''AVL'',''BAL'',''BAL'',''ERN'',''ERN'') COMPONENTSHORTNAME,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '1 PHASE, ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'DECODE(COMPONENTCODE,''ERN'',1,''AVL'',2,''BAL'',3) CALCULATIONINDEX,''LEAVE'' COMPONENTTYPE FROM ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    SELECT A.COMPANYCODE, A.DIVISIONCODE,A.YEARMONTH,B.YEARCODE,B.UNITCODE,null DEPARTMENTCODE,B.CATEGORYCODE, B.GRADECODE,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    A.WORKERSERIAL,A.TOKENNO,A.LEAVECODE,A.LV_TAKEN AVL,A.LV_BAL BAL,NVL(ENTITLEMENTS,0) ERN FROM' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    (' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '         SELECT * FROM GBL_PISLEAVEBALANCE WHERE WORKERSERIAL IN  ( SELECT DISTINCT WORKERSERIAL FROM GTT_PISPAYSLIP_ED_BIRLA )' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    ) A,' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    (   ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '         SELECT * FROM  PISLEAVEENTITLEMENT' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '         WHERE YEARCODE='''||P_YEARCODE||'''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    ) B' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    WHERE A.COMPANYCODE=B.COMPANYCODE(+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND A.DIVISIONCODE=B.DIVISIONCODE(+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND A.LEAVECODE    = B.LEAVECODE(+)    ' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND A.TOKENNO=B.TOKENNO(+)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    AND A.WORKERSERIAL=B.WORKERSERIAL(+)' || CHR(10);
--LV_SQLSTR := LV_SQLSTR || '    AND A.TOKENNO=''0049''' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
LV_SQLSTR := LV_SQLSTR || 'UNPIVOT' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '(' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    COMPONENTVALUE' || CHR(10);
LV_SQLSTR := LV_SQLSTR || '    FOR COMPONENTCODE IN (AVL,BAL,ERN)' || CHR(10);
LV_SQLSTR := LV_SQLSTR || ')' || CHR(10);
    
   
    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    EXECUTE IMMEDIATE LV_SQLSTR;
    --ENDED 
    
--    delete from GTT_PISPAYSLIP_ED_BIRLA where COMPONENTVALUE =0;
    
    
    UPDATE GTT_PISPAYSLIP_ED_BIRLA AA
    SET DIVISIONNAME = LV_DIVISIONNAME,
    COMPANYNAME=LV_COMPANYNAME,
    REPORTHEADER = LV_RPT_CAPTION
    WHERE 1=1;
    
END;
/


DROP PROCEDURE PRS_PIS_LOANDATE_MIGRATE;

CREATE OR REPLACE PROCEDURE             PRS_PIS_LOANDATE_MIGRATE (P_SCHEMA VARCHAR2, P_DIVCODE VARCHAR2,P_LOANCODE VARCHAR2, P_YEARMONTH VARCHAR2)
AS 
lv_Sql          varchar2(10000) := '';
lv_ComponentCode varchar2 (500) := '';
lv_LoanEMIComp      varchar2(30) := 'LOAN.'||P_LOANCODE;
lv_LoanINTComp      varchar2(30) := 'LINT.'||P_LOANCODE;
lv_LoanCapBalComp   varchar2(30) := 'LNBL.'||P_LOANCODE;
lv_LoanINTBalComp      varchar2(30) := 'LINTBL.'||P_LOANCODE;

lv_NewLoanCapEMI       varchar2(30) := 'LOAN_'||P_LOANCODE;
lv_NewLoanINTEMI      varchar2(30) := 'LINT_'||P_LOANCODE;
lv_NewLoanCapBalComp   varchar2(30) := 'LNBL_'||P_LOANCODE;
lv_NewLoanINTBalComp      varchar2(30) := 'LIBL_'||P_LOANCODE;

lv_NewLoanCode      varchar2(10) := P_LOANCODE;
lv_FN_STDT      varchar2(10);
lv_FN_ENDT      varchar2(10);
lv_CNT          number(5):=0;
begin

    lv_FN_STDT := to_char(to_date('01/'||substr(P_YEARMONTH,5,2)||'/'||substr(P_YEARMONTH,1,4),'DD/MM/YYYY'),'DD/MM/YYYY');
    lv_FN_ENDT := TO_CHAR(last_day(TO_DATE(lv_FN_STDT,'DD/MM/YYYY')),'DD/MM/YYYY');
    if P_LOANCODE='SPL_1' THEN
        lv_NewLoanCode := 'SPL1';    
    END IF;
    lv_NewLoanCapEMI      := 'LOAN_'||lv_NewLoanCode;
    lv_NewLoanINTEMI      := 'LINT_'||lv_NewLoanCode;
    lv_NewLoanCapBalComp  := 'LNBL_'||lv_NewLoanCode;
    lv_NewLoanINTBalComp  := 'LIBL_'||lv_NewLoanCode;        
    
    DELETE FROM LOANTRANSACTION WHERE MODULE='PIS' AND DIVISIONCODE = P_DIVCODE AND LOANCODE = lv_NewLoanCode;
    
    DELETE FROM LOANINTEREST WHERE MODULE='PIS' AND DIVISIONCODE = P_DIVCODE AND LOANCODE = lv_NewLoanCode;
    
    lv_Sql := ' INSERT INTO LOANTRANSACTION ( '||chr(10) 
        ||' COMPANYCODE, DIVISIONCODE, MODULE, YEARCODE, YEARMONTH, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO, '||chr(10) 
        ||' LOANCODE, LOANDATE, LOANTYPE, LOANCF, AMOUNT, INTERESTPERCENTAGE, NOOFINSTALLMENTS, INTERESTAMOUNT, ACTUALLOANAMOUNT, ACTUALLOANDATE, LOANCLAIMAMOUNT, '||chr(10) 
        ||' SANCTIONEDAMOUNT, INTERESTDEDNMONTHLY, PAYABLEAMOUNT, APPLICATIONNO, AMOUNTINHAND,   '||chr(10)
        ||' CAPITALINSTALLMENTAMT, INTERESTINSTALLMENTAMT, TOTALEMIAMOUNT, REMARKS, DEPARTMENTCODE, FORTNIGHTSTARTDATE, DEDUCTIONSTARTDATE, '||chr(10) 
        ||' SYSROWID, USERNAME, LASTMODIFIED, OLD_WORKERSERIAL) '||chr(10)

        ||' SELECT NM.COMPANYCODE, NM.DIVISIONCODE, ''PIS'' MODULE, ''2019-2020'' YEARCODE, '''||P_YEARMONTH||''' YEARMONTH, NM.CATEGORYCODE, NM.GRADECODE, NM.WORKERSERIAL, NM.TOKENNO, '||chr(10)
        ||' '''||lv_NewLoanCode||''', TO_DATE('''||lv_FN_STDT||''',''DD/MM/YYYY'') LOANDATE,''REFUNDABLE'' LOANTYPE, ''C'' LOANCF, B.'||lv_NewLoanCapBalComp||' AMOUNT, A.INTERESTPERCENTAGE, A.NOOFINSTALLMENTS, '||chr(10)
        ||' B.'||lv_NewLoanINTBalComp||' INTERESTAMOUNT,  '||chr(10)
        ||' A.AMOUNT ACTUALLOANAMOUNT, A.LOANDATE ACTUALLOANDATE, B.'||lv_NewLoanCapBalComp||' LOANCLAIMAMOUNT, B.'||lv_NewLoanCapBalComp||' SANCTIONEDAMOUNT, ''N'' INTERESTDEDNMONTHLY, B.'||lv_NewLoanCapBalComp||' PAYABLEAMOUNT, '||chr(10)
        ||' ''XXXX'' APPLICATIONNO, B.'||lv_NewLoanCapBalComp||' AMOUNTINHAND, DECODE(B.'||lv_NewLoanCapEMI||',0,'||lv_NewLoanINTEMI||','||lv_NewLoanCapEMI||') CAPITALINSTALLMENTAMT, '||chr(10)
        ||' DECODE(B.'||lv_NewLoanCapEMI||',0,'||lv_NewLoanINTEMI||','||lv_NewLoanCapEMI||') INTERESTINSTALLMENTAMT, DECODE(B.'||lv_NewLoanCapEMI||',0,'||lv_NewLoanINTEMI||','||lv_NewLoanCapEMI||') TOTALEMIAMOUNT,''MIGRATED DATA ON 24/02/2020'' REMARKS, '||chr(10)
        ||' NM.DEPARTMENTCODE, TO_DATE('''||lv_FN_STDT||''',''DD/MM/YYYY'') FORTNIGHTSTARTDATE, TO_DATE('''||lv_FN_STDT||''',''DD/MM/YYYY'') DEDUCTIONSTARTDATE, '||chr(10)
        ||' SYS_GUID() SYSROWID, ''SWT'' USERNAME, SYSDATE LASTMODIFIED, A.EMPLOYEECODE OLD_WORKERSERIAL '||chr(10)
        --SELECT OM.EMPLOYEEID,A.*  '||chr(10)
        ||' FROM PISEMPLOYEEMASTER NM, '||P_SCHEMA||'.PISEMPLOYEEMASTER OM, '||chr(10)
        ||' ( '||chr(10)
        ||'     SELECT A.* FROM '||P_SCHEMA||'.PISEMPLOYEELOANTRANSACTION A, '||chr(10)
        ||'     ( '||chr(10)
        ||'         SELECT EMPLOYEECODE, LOANCODE, MAX(LOANDATE) LOANDATE '||chr(10) 
        ||'         FROM '||P_SCHEMA||'.PISEMPLOYEELOANTRANSACTION '||chr(10)
        ||'         WHERE LOANCODE ='''||P_LOANCODE||''' '||chr(10)
        ||'         GROUP BY EMPLOYEECODE,LOANCODE '||chr(10)
        ||'     ) B '||chr(10)
        ||'     WHERE A.EMPLOYEECODE = B.EMPLOYEECODE '||chr(10)
        ||'       AND A.LOANCODE = B.LOANCODE AND A.LOANDATE = B.LOANDATE '||chr(10)
        ||'       AND A.LOANCODE ='''||P_LOANCODE||''' '||chr(10)
        ||' ) A, '||chr(10)
        ||' (  '||chr(10)
        ||'     SELECT EMPLOYEECODE, CATEGORYCODE, GRADECODE, SUM('||lv_NewLoanCapEMI||')'||lv_NewLoanCapEMI||', SUM('||lv_NewLoanINTEMI||') '||lv_NewLoanINTEMI||', '||chr(10)
        ||'     SUM('||lv_NewLoanCapBalComp||') '||lv_NewLoanCapBalComp||', SUM('||lv_NewLoanINTBalComp||')'||lv_NewLoanINTBalComp||'  '||chr(10)
        ||'     FROM  '||chr(10)
        ||'     (  '||chr(10)
        ||'         SELECT A.EMPLOYEECODE, A.CATEGORYCODE, A.GRADECODE, '||chr(10)
        ||'         DECODE(A.COMPONENTCODE,'''||lv_LoanEMIComp||''',COMPONENTAMOUNT,0) '||lv_NewLoanCapEMI||', '||chr(10)
        ||'         DECODE(A.COMPONENTCODE,'''||lv_LoanINTComp||''',COMPONENTAMOUNT,0) '||lv_NewLoanINTEMI||',  '||chr(10)
        ||'         DECODE(A.COMPONENTCODE,'''||lv_LoanCapBalComp||''',COMPONENTAMOUNT,0) '||lv_NewLoanCapBalComp||', '||chr(10)
        ||'         DECODE(A.COMPONENTCODE,'''||lv_LoanINTBalComp||''',COMPONENTAMOUNT,0) '||lv_NewLoanINTBalComp||'  '||chr(10)
        ||'         FROM '||P_SCHEMA||'.PISEMPLOYEEPAYTRANSACTION A, '||P_SCHEMA||'.PISEMPLOYEEMASTER B, '||chr(10)
        ||'         ( '||chr(10)
        ||'             SELECT EMPLOYEECODE, MAX(YEARMONTH) YEARMONTH '||chr(10)
        ||'             FROM '||P_SCHEMA||'.PISEMPLOYEEPAYTRANSACTION  '||chr(10)
        ||'             WHERE TRANSACTIONTYPE LIKE ''%SALARY%'' '||chr(10)
        ||'             GROUP BY EMPLOYEECODE '||chr(10)
        ||'         ) C '||chr(10)
        ||'         WHERE A.EMPLOYEECODE =B.EMPLOYEECODE '||chr(10)
        ||'           AND B.EMPLOYEESTATUS =''ACTIVE'' '||chr(10)
        ||'           AND A.EMPLOYEECODE = C.EMPLOYEECODE '||chr(10)
        ||'           AND A.YEARMONTH = C.YEARMONTH '||chr(10)
--        ||' --          AND A.COMPONENTCODE IN ('LOAN.SPL','LINT.SPL','LNBL.SPL','LINTBL.SPL')--,'LNBL.SPL_1','LINTBL.SPL_1') '||chr(10)
        ||'           AND A.COMPONENTCODE IN ('''||lv_LoanEMIComp||''','''||lv_LoanINTComp||''','''||lv_LoanCapBalComp||''','''||lv_LoanINTBalComp||''')'||chr(10)
        ||'     ) '||chr(10)
        ||'     GROUP BY EMPLOYEECODE, CATEGORYCODE, GRADECODE '||chr(10)
        ||' ) B '||chr(10)
        ||' WHERE 1=1 '||chr(10)
        ||'   AND A.EMPLOYEECODE = OM.EMPLOYEECODE '||chr(10)
        ||'   AND B.EMPLOYEECODE = OM.EMPLOYEECODE '||chr(10)
        ||'   AND NM.TOKENNO = OM.EMPLOYEEID '||chr(10);
    dbms_output.put_line (lv_Sql);
    EXECUTE IMMEDIATE lv_Sql;
    
    
--    SELECT COUNT(*) INTO lv_CNT from TAB WHERE TNAME = 'LNBAL_UPDT_TEMP';
--    if lv_CNT >0 then
--        EXECUTE IMMEDIATE 'DROP TABLE LNBAL_UPDT_TEMP';    
--    end if;
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE LNBAL_UPDT_TEMP';
    EXCEPTION 
        WHEN OTHERS THEN NULL;    
    END;
    
    --delete from LNBAL_UPDT_TEMP;
    
--    lv_Sql := ' insert into LNBAL_UPDT_TEMP (EMPLOYEECODE, EMPLOYEEID, WORKERSERIAL, LOANCODE, LOAN_BAL) '||chr(10)
    IF P_LOANCODE='FEADV' THEN
        lv_Sql := ' CREATE TABLE LNBAL_UPDT_TEMP AS '||CHR(10) 
            ||' SELECT A.EMPLOYEECODE, OM.EMPLOYEEID, NM.WORKERSERIAL, '''||P_LOANCODE||''' LOANCODE, SUM(AMOUNT) LOAN_BAL '||chr(10) 
            ||' FROM '||P_SCHEMA||'.PISEMPLOYEELOANBREAKUP A, '||P_SCHEMA||'.PISEMPLOYEEMASTER OM, PISEMPLOYEEMASTER NM  '||chr(10) 
            ||' WHERE A.LOCATIONCODE ='''||P_DIVCODE||''' '||CHR(10)
            ||' AND A.LOANCODE ='''||P_LOANCODE||''' '||CHR(10)  
            ||' AND A.EFFECTYEARMONTH>= '||P_YEARMONTH||'  '||chr(10)
            ||' AND A.EMPLOYEECODE = OM.EMPLOYEECODE  '||chr(10)
            ||' AND OM.EMPLOYEEID = NM.TOKENNO  '||chr(10)
            ||' GROUP BY A.EMPLOYEECODE, OM.EMPLOYEEID, NM.WORKERSERIAL  '||chr(10);

        dbms_output.put_line (lv_Sql);
        EXECUTE IMMEDIATE lv_Sql;

        lv_Sql := ' UPDATE LOANTRANSACTION A SET (A.AMOUNT, A.LOANCLAIMAMOUNT, A.SANCTIONEDAMOUNT) = (SELECT B.LOAN_BAL, B.LOAN_BAL, B.LOAN_BAL '||chr(10) 
            ||' FROM LNBAL_UPDT_TEMP B WHERE A.WORKERSERIAL = B.WORKERSERIAL AND A.LOANCODE = B.LOANCODE) '||chr(10)
            ||' WHERE A.MODULE = ''PIS'' AND A.DIVISIONCODE = '''||P_DIVCODE||''' AND A.LOANCODE ='''||P_LOANCODE||'''  '||chr(10)
            ||'   AND A.WORKERSERIAL IN (SELECT WORKERSERIAL FROM LNBAL_UPDT_TEMP WHERE LOANCODE ='''||P_LOANCODE||''')  '||chr(10);
        dbms_output.put_line (lv_Sql);    
        EXECUTE IMMEDIATE lv_Sql;
    END IF;

    lv_Sql := ' INSERT INTO LOANINTEREST ( '||chr(10)
        ||' COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, TOKENNO, WORKERSERIAL, '||chr(10) 
        ||' LOANCODE, LOANDATE, LOANAMOUNT, INTERESTAPPLICABLEON, INTERESTPERCENTAGE, INTERESTAMOUNT,  '||chr(10)
        ||' MODULE, TRANSACTIONTYPE, REMARKS, USERNAME, SYSROWID, LASTMODIFIED) '||chr(10)
        ||' SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, LOANDATE FORTNIGHTSTARTDATE, LAST_DAY(LOANDATE) FORTNIGHTENDATE, TOKENNO, WORKERSERIAL, '||chr(10)
        ||' LOANCODE, LOANDATE, AMOUNT LOANAMOUNT, AMOUNT INTERESTAPPLICABLEON, INTERESTPERCENTAGE, INTERESTAMOUNT, '||chr(10)
        ||' MODULE, ''ADD'' TRANSACTIONTYPE, REMARKS, ''SWT'' USERNAME, SYS_GUID() SYSROWID, SYSDATE LASTMODIFIED '||chr(10)
        ||' FROM LOANTRANSACTION '||CHR(10)
        ||' WHERE MODULE=''PIS'' '||chr(10)
        ||'  AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
        ||'  AND LOANCODE = '''||lv_NewLoanCode||''' '||CHR(10)  
        ||'  AND INTERESTAMOUNT > 0 '||CHR(10);
    dbms_output.put_line (lv_Sql);
    EXECUTE IMMEDIATE lv_Sql;
    --EXECUTE IMMEDIATE 'DROP table LNBAL_UPDT_TEMP';
    COMMIT;
    return;
--exception 
--    when others then
--        rollback;        
end;
/


DROP PROCEDURE PRC_PISCOMPNENTMAST_AFTERSAVE;

CREATE OR REPLACE PROCEDURE          prc_PISCOMPNENTMAST_AFTERSAVE
as
lv_StrSql varchar2(2000):= '';
lv_Remarks varchar2(1000) := '';
lv_cnt      number(3) := 0;
begin

    select COUNT(*) CNT into lv_cnt
    FROM ( 
            SELECT DISTINCT COMPONENTCODE FROM PISCOMPONENTMASTER
            MINUS
            SELECT column_name FROM COLS where table_name = 'PISPAYTRANSACTION'
         );
    if lv_cnt > 0 then
        for c1 in (             
                    select * from piscomponentmaster
                     where componentcode in (
                                             select distinct componentcode from piscomponentmaster
                                             minus
                                             select column_name from cols where table_name = 'PISPAYTRANSACTION'
                                            )
                  )
        loop                  
            lv_StrSql := 'ALTER TABLE PISPAYTRANSACTION ADD '||c1.COMPONENTCODE||' number (15,5) default 0';
            --dbms_output.put_line ('1 - '||lv_StrSql);
            BEGIN
                execute immediate lv_StrSql;
            EXCEPTION WHEN OTHERS THEN NULL;
            END;
            
            lv_StrSql := 'ALTER TABLE PISPAYTRANSACTION_SWT ADD '||c1.COMPONENTCODE||' number (15,5) default 0';
            --dbms_output.put_line ('1 - '||lv_StrSql);
            BEGIN
                execute immediate lv_StrSql;
            EXCEPTION WHEN OTHERS THEN NULL;
            END;
            
            
            lv_StrSql := 'ALTER TABLE PISARREARTRANSACTION ADD '||c1.COMPONENTCODE||' number (15,5) default 0';
            --dbms_output.put_line ('1 - '||lv_StrSql);
            BEGIN
                execute immediate lv_StrSql;
            EXCEPTION WHEN OTHERS THEN NULL;
            END;

            lv_StrSql := 'ALTER TABLE PISCOMPONENTASSIGNMENT ADD '||c1.COMPONENTCODE||' number (15,5) default 0';
            --dbms_output.put_line ('1 - '||lv_StrSql);
            BEGIN
                execute immediate lv_StrSql;
            EXCEPTION WHEN OTHERS THEN NULL;
            END;

            
            
            lv_StrSql := 'ALTER TABLE PISOTHERTRANSACTION ADD '||c1.COMPONENTCODE||' number (15,5) default 0';
            --dbms_output.put_line ('1 - '||lv_StrSql);
            BEGIN
                execute immediate lv_StrSql;
            EXCEPTION WHEN OTHERS THEN NULL;
            END;

                
             BEGIN
               
                Insert into sys_tfmap
                   (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, 
                    SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, 
                    SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
                 Values
                   (10013, 'PISCOMPONENTASSIGNMENT', 'GBL_PISCOMPONENTASSIGNMENT', c1.COMPONENTCODE, 99, 
                    'NUMBER', 15, 5, 'N', c1.COMPONENTCODE, 
                    sysdate, 'Y', NULL, NULL);
                commit;
                 proc_create_gbl_tmp_tables(10013,0);
                
                EXCEPTION WHEN OTHERS THEN NULL;
                END;


            prc_pisviewcreation( c1.companycode  ,c1.divisioncode,'ALL',0,c1.yearmonth,'SALARY','PISPAYTRANSACTION'); 
            
--            Insert into sys_tfmap
--               (SYS_TABLE_SEQUENCIER, SYS_TABLENAME_ACTUAL, SYS_TABLENAME_TEMP, SYS_COLUMNNAME, SYS_COLUMN_SEQUENCE, 
--                SYS_DATATYPE, SYS_COLUMN_LENGTH, SYS_COLUMN_PRECISION, SYS_KEYCOLUMN, SYS_MAPFIELD, 
--                SYS_TIMESTAMP, SYS_USEMAP, SYS_DEFAULT, TDSCODE)
--             Values
--               (10013, 'PISCOMPONENTASSIGNMENT', 'GBL_PISCOMPONENTASSIGNMENT', c1.COMPONENTCODE, 99, 
--                'NUMBER', 15, 5, 'N', c1.COMPONENTCODE, 
--                sysdate, 'Y', NULL, NULL);
----            commit;
--            prc_pisviewcreation( c1.companycode  ,c1.divisioncode,'ALL',0,c1.yearmonth,'SALARY','PISPAYTRANSACTION'); 
--            proc_create_gbl_tmp_tables(10013,0);
        end loop; 
                                 
    end if;
                                                               
end ;
/


DROP PROCEDURE PRC_PISSALARYPROCESS_DEDN;

CREATE OR REPLACE PROCEDURE          PRC_PISSALARYPROCESS_DEDN 
(
    P_COMPCODE Varchar2, 
    P_DIVCODE Varchar2,
    P_TRANTYPE Varchar2, 
    P_PHASE  number, 
    P_YEARMONTH Varchar2,
    P_EFFECTYEARMONTH Varchar2, 
    P_TABLENAME Varchar2,
    P_PHASE_TABLENAME Varchar2,
    P_UNIT  Varchar2,
    P_CATEGORY    Varchar2  DEFAULT NULL,
    P_GRADE       Varchar2  DEFAULT NULL,
    P_DEPARTMENT  Varchar2  DEFAULT NULL,
    P_WORKERSERIAL VARCHAR2 DEFAULT NULL
)
as 
lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,1,4),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,1,4),'DD/MM/YYYY'));
lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(10000) := '';
lv_Sql              varchar2(10000) := '';
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName         varchar2(30)   := 'PRC_PISSALARYPROCESS_DEDN';
lv_Sql_TblCreate    varchar2(4000) := '';
lv_Component        varchar2(4000) := ''; 
lv_SqlComponent     varchar2(2000) := ''; 
lv_MinimumPayableAmt    number := 0;
lv_RoundOffRs           number := 0;
lv_RoundOffType     varchar2(10):='L';
lv_WagesAsOn    number(11,2) := 0;
lv_TempVal      number(11,2) :=0;
lv_TempDednAmt  number(11,2) := 0;
lv_ComponentAmt number(11,2) := 0;
lv_intCnt       number(5) :=0;
lv_GrossWages   number(11,2) := 0;
lv_TotalEarn    number(11,2) := 0;
lv_TotalDedn    number(11,2) := 0;
lv_CoinBf       number(11,2) := 0;
lv_CoinCf       number(11,2) := 0;
lv_CapEMI       number(11,2) := 0;
lv_IntEMI       number(11,2) := 0;
lv_strWorkerSerial  varchar2(10) :='';
lv_CNT          number(11,2) := 0;
lv_PFNO         varchar2(100):='';
lv_YearCode     varchar2(10):='';
lv_MinPay     varchar2(10):='';
lv_ChkAttnHrs number(15,2) :=0;
begin
    lv_parvalues := 'COMP='||P_COMPCODE||',DIV = '||P_DIVCODE||', YEARMONTH = '||P_YEARMONTH||', EFF.YEARMONTH'||P_EFFECTYEARMONTH||',PAHSE='||P_PHASE;
    --lv_SqlStr := 'drop table '||P_PHASE_TABLENAME;
    
    SELECT YEARCODE INTO lv_YearCode FROM FINANCIALYEAR WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE =P_DIVCODE
    AND STARTDATE <= lv_fn_stdt AND ENDDATE >= lv_fn_stdt;
    
    
    IF P_TRANTYPE = 'SALARY' THEN
        prc_PISCOMPONENTMERGE( P_COMPCODE, P_DIVCODE, P_YEARMONTH, P_PHASE, 'ADJUSTMENT', 'PISOTHERTRANSACTION', P_TABLENAME);
    END IF;
   
    
    PRC_PISVIEWCREATION ( P_COMPCODE,P_DIVCODE,'PISCOMP',P_PHASE,P_YEARMONTH,P_EFFECTYEARMONTH, P_TRANTYPE,P_TABLENAME);
    --- PREPARE THE LOAN OUTSTANDNG FOR DEDUCTION -----------
    DBMS_OUTPUT.PUT_LINE ('LOAN BALANCE QUERY RUN 1');
    IF P_TRANTYPE = 'SALARY' OR  P_TRANTYPE = 'FINAL SETTLEMENT' THEN --- FOR ARREAR TIME IT'S NOT REQUIRED     
    
        --ADDED LOAN INT CALCULATION OM 06/07/2020
        PRC_GEN_LOAN_INT_CALC(P_COMPCODE,P_DIVCODE,'SWT',NULL,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'PIS','YES','PISPAYTRANSACTION_SWT');


        PROC_LOANBLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','','PIS','YES');
        ----DBMS_OUTPUT.PUT_LINE ('LOAN BALANCE QUERY RUN 2');
        PROC_PFLOANBLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','','PIS','YES');
        ----DBMS_OUTPUT.PUT_LINE ('LOAN BALANCE QUERY CLOSE 3');
        PRC_PFLN_EMI_UPDT (P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),P_TABLENAME,'GBL_PFLOANBLNC','','','PIS');
        ----DBMS_OUTPUT.PUT_LINE ('PF LOAN EMI UPDT');
        --PROC_LICDEDUCTION(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'','','LICDETAILS','PIS','YES');
        
        ------ COINBF DATA PREPARATION -------------
        PRC_PIS_PREVMONTHCOINBF (P_COMPCODE, P_DIVCODE, P_YEARMONTH, P_CATEGORY,P_GRADE,P_WORKERSERIAL);
            
            
        ------ ELECTRIC METER READING -----------------------------------
    --    PROC_ELECBLNC (P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),NULL,'WPS');
        PROC_ELECBLNC_WITH_BILL_EMI(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),NULL,'PIS','YES');  
        
        --ADDED ON 26/11/2020
        --  UNREALIZED COMPONENT DATA PREPARATION PROCEDURE CALL
        PROC_UNREALIZED_COMP_BLNC(P_COMPCODE,P_DIVCODE,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'ALL', LV_YEARCODE ,'PIS','YES',NULL);    
                              

    END IF;    
--    BEGIN 
--        execute immediate lv_SqlStr;
--    EXCEPTION WHEN OTHERS THEN NULL;
--    END;
--    DBMS_OUTPUT.PUT_LINE('1_0');    

    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE '||P_PHASE_TABLENAME||' CASCADE CONSTRAINTS';
      EXCEPTION WHEN OTHERS THEN NULL;
    END;
    for c1 in ( 
                SELECT COMPONENTCODE, COMPONENTTYPE, PAYFORMULA, CALCULATIONINDEX, PHASE,
                NVL(DEPENDENCYTYPE,'A') DEPENDENCYTYPE, NVL(ROUNDOFFTYPE,'N') ROUNDOFFTYPE, NVL(ROUNDOFFRS,0) ROUNDOFFRS,
                INCLUDEPAYROLL, nvl(ROLLOVERAPPLICABLE,'N') ROLLOVERAPPLICABLE, NVL(USERENTRYAPPLICABLE,'N') USERENTRYAPPLICABLE, 
                NVL(ATTENDANCEENTRYAPPLICABLE,'N') ATTENDANCEENTRYAPPLICABLE, 
                NVL(LIMITAPPLICABLE,'N') LIMITAPPLICABLE, NVL(SLABAPPLICABLE,'N') SLABAPPLICABLE,
                NVL(MISCPAYMENT,'N') MISCPAYMENT, NVL(FINALSETTLEMENT,'N') FINALSETTLEMENT, NVL(COMPONENTGROUP,'N/A') COMPONENTGROUP 
                FROM PISCOMPONENTMASTER
                WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                AND PHASE = P_PHASE
                AND NVL(INCLUDEPAYROLL,'N') = 'Y'
                AND YEARMONTH = ( 
                                  SELECT MAX(YEARMONTH) YEARMONTH FROM PISCOMPONENTMASTER
                                  WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                                    and YEARMONTH <= P_YEARMONTH
                                )  
              )   
    loop
        if c1.USERENTRYAPPLICABLE = 'Y' then
            if c1.ROLLOVERAPPLICABLE = 'Y' then
                lv_SqlComponent := 'NVL(PISASSIGN.'||C1.COMPONENTCODE||',0)';
            else
                lv_SqlComponent := 'NVL(PISATTN.'||C1.COMPONENTCODE||',0)';
            end if;

            if length(rtrim(ltrim(c1.PAYFORMULA))) > 0 then
                lv_SqlComponent := lv_SqlComponent||'+'||c1.PAYFORMULA;
            end if;
                        
        else
            lv_SqlComponent := NVL(c1.PAYFORMULA,0);
        end if;
        if c1.DEPENDENCYTYPE = 'A' then
            lv_SqlComponent := 'round(('||lv_SqlComponent||')*PISCOMP.ATTN_SALD/PISCOMP.ATTN_CALCF,2)';
        end if;
        ---- consider round off type criteria --------
        --IF c1.COMPONENTGROUP <> 'LOAN' AND c1.COMPONENTGROUP <> 'PF LOAN' THEN
        IF c1.COMPONENTGROUP NOT IN ('LOAN' , 'PF LOAN') THEN
            if c1.ROUNDOFFTYPE = 'H' or  c1.ROUNDOFFTYPE = 'L' THEN
                if nvl(c1.ROUNDOFFRS,0) = 0 then
                    lv_SqlComponent := 'FN_ROUNDOFFRS('||lv_SqlComponent||',1,'''||c1.ROUNDOFFTYPE||''')';
                else
                    lv_SqlComponent := 'FN_ROUNDOFFRS('||lv_SqlComponent||','||c1.ROUNDOFFRS||','''||c1.ROUNDOFFTYPE||''')';
                end if;
            --elsif c1.ROUNDOFFTYPE = 'S'
            --    lv_SqlComponent := 'FN_ROUNDOFFRS('||lv_SqlComponent||',1,'''||c1.ROUNDOFFTYPE||''')';
            else
            --    lv_SqlComponent := 0
                lv_SqlComponent := 'FN_ROUNDOFFRS('||lv_SqlComponent||',1,'''||c1.ROUNDOFFTYPE||''')'; 
            end if;
        else
            lv_SqlComponent := ' 0 ';
        END IF;
        lv_Component := lv_Component ||', '||lv_SqlComponent||' AS '|| c1.COMPONENTCODE;
     end loop;     
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE PISTEMPCOMP CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE PISTEMPCOMP AS SELECT * FROM PISCOMP';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE PISTEMPCOMP AS SELECT * FROM PISCOMP';
    END;
    
--    BEGIN 
--        EXECUTE IMMEDIATE 'DROP TABLE '||P_PHASE_TABLENAME||' CASCADE CONSTRAINTS';
--      EXCEPTION WHEN OTHERS THEN NULL;
--    END;    
        
    lv_Component := Replace(lv_Component, 'PISATTN', 'PISTEMPATTN');
    lv_Component := Replace(lv_Component, 'PISMAST', 'PISTEMPMAST');
    lv_Component := Replace(lv_Component, 'PISCOMP', 'PISTEMPCOMP');
    lv_Component := Replace(lv_Component, 'PISASSIGN', 'PISTEMPASSIGN');
    lv_Component := Replace(lv_Component, 'PISPREV', 'PISTEMPPREV');
    
--    --DBMS_output.put_line ('component '||lv_Component);
    
    lv_Remarks := 'PHASE TABLE CREATION';
    lv_SqlStr := ' CREATE TABLE '||P_PHASE_TABLENAME||' AS '||CHR(10)
             ||' SELECT PISTEMPATTN.COMPANYCODE, PISTEMPATTN.DIVISIONCODE,PISTEMPATTN.YEARMONTH, PISTEMPATTN.UNITCODE, PISTEMPATTN.CATEGORYCODE, PISTEMPATTN.GRADECODE, PISTEMPATTN.WORKERSERIAL, PISTEMPATTN.TOKENNO, PISTEMPCOMP.ATTN_SALD, PISTEMPCOMP.ATTN_CALCF, '||chr(10)
             ||' PISTEMPCOMP.GROSSEARN, PISTEMPCOMP.TOTEARN '||CHR(10)
             ||' '||lv_Component||' '||chr(10) 
             ||' FROM PISTEMPMAST, PISTEMPATTN, PISTEMPASSIGN, PISTEMPCOMP, PISTEMPPREV '||CHR(10)
             ||' WHERE PISTEMPMAST.WORKERSERIAL = PISTEMPATTN.WORKERSERIAL '||CHR(10)
             ||'   AND PISTEMPMAST.WORKERSERIAL = PISTEMPASSIGN.WORKERSERIAL '||CHR(10)
             ||'   AND PISTEMPMAST.WORKERSERIAL = PISTEMPCOMP.WORKERSERIAL '||CHR(10)
             ||'   AND PISTEMPMAST.WORKERSERIAL = PISTEMPPREV.WORKERSERIAL (+) '||CHR(10);   
     if P_CATEGORY is not null then
        lv_SqlStr := lv_SqlStr||' AND PISTEMPATTN.CATEGORYCODE = '''||P_CATEGORY||''' '||CHR(10); 
     END IF;
     if P_GRADE is not null then
        lv_SqlStr := lv_SqlStr||' AND PISTEMPATTN.GRADECODE = '''||P_GRADE||''' '||CHR(10);
     END IF;        
     if P_DEPARTMENT is not null then
        lv_SqlStr := lv_SqlStr||' AND PISTEMPATTN.DEPARTMENTCODE = '''||P_DEPARTMENT||''' '||CHR(10); 
     END IF;     
     if P_WORKERSERIAL is not null then
        lv_SqlStr := lv_SqlStr||' AND PISTEMPATTN.WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10); 
     END IF;    
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE, ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE, lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
    EXECUTE IMMEDIATE lv_SqlStr;
    lv_SqlStr := '';
    COMMIT;
    
    ---RETURN; -- TEMPORARILY NOT EXCUTE THE BELOW PART
    lv_Remarks := 'DATA BREAK TO ROW WISE';
    --PRC_PIS_PHASE_DEDN_ROWISE (P_COMPCODE, P_DIVCODE, P_YEARMONTH,'PIS_SWT_PHASE_DEDN',P_PHASE);
    lv_SqlStr := 'begin  PRC_PIS_PHASE_DEDN_ROWISE('''||P_COMPCODE||''','''||P_DIVCODE||''', '''||P_YEARMONTH||''','''||P_PHASE_TABLENAME||''','||P_PHASE||' ); end;';
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE,lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
    EXECUTE IMMEDIATE lv_SqlStr;    
    
    SELECT nvl(MINIMUMSALARYPAYABLE,0) MINIMUMSALARYPAYABLE, NVL(PAYMENTROUNDTYPE,'L') PAYMENTROUNDTYPE, nvl(ROUNDOFFRS,0) ROUNDOFFRS 
    INTO lv_MinimumPayableAmt, lv_RoundOffType, lv_RoundOffRs  
    FROM PISALLPARAMETER WHERE COMPANYCODE= P_COMPCODE AND DIVISIONCODE = P_DIVCODE;        
    
    ----DBMS_output.put_line ( 'minimum salary ='|| lv_MinimumPayableAmt||', Payment Type ='||lv_RoundOffType||', Round off Rs = '||lv_RoundOffRs);
    
--    START Previous MONTH coin c/f fetching worker wise --
/*    DELETE FROM PIS_PREV_FN_COIN;
    
    lv_Sql := ' INSERT INTO PIS_PREV_FN_COIN(WORKERSERIAL, TOKENNO, YEARMONTH, COINCF) '||CHR(10) 
            ||' SELECT A.WORKERSERIAL, A.TOKENNO, A.YEARMONTH, A.COINCF '||CHR(10)
            ||' FROM PISPAYTRANSACTION A, '||CHR(10)
            ||'  ( '||CHR(10)
            ||'    SELECT WORKERSERIAL, MAX(YEARMONTH) YEARMONTH  '||CHR(10)
            ||'    FROM PISPAYTRANSCTION  '||CHR(10)
            ||'    WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||'      AND YEARMONTH < '''||P_YEARMONTH||'''  '||CHR(10)
            ||'    GROUP BY WORKERSERIAL  '||CHR(10)
            ||'  ) B  '||CHR(10)
            ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||'   AND A.WORKERSERIAL = B.WORKERSERIAL  '||CHR(10)
            ||'   AND A.YEARMONTH = B.YEARMONTH  '||CHR(10);
     
    BEGIN
        DELETE FROM PIS_PREV_FN_COIN;
        EXECUTE IMMEDIATE lv_Sql;
    exception
        WHEN OTHERS THEN
            EXECUTE IMMEDIATE lv_Sql;        
    END;
*/         
--    END Previous MONTH coin c/f fetching worker wise --

           DBMS_OUTPUT.PUT_LINE ('RUN QRY 2 '||lv_ComponentAmt);   
    lv_strWorkerSerial := 'X';
    FOR cWages in (
                SELECT A.WORKERSERIAL, A.TOKENNO, A.UNITCODE, A.CATEGORYCODE, A.GRADECODE, A.GROSSEARN,A.TOTEARN,A.COMPONENTCODE, A.COMPONENTAMOUNT,
                NVL(B.COMPONENTGROUP,'OTHERS') COMPONENTGROUP, NVL(DEPENDENCYTYPE,'A') DEPENDENCYTYPE, NVL(ROUNDOFFTYPE,'N') ROUNDOFFTYPE, NVL(ROUNDOFFRS,1) ROUNDOFFRS,
                INCLUDEPAYROLL, nvl(ROLLOVERAPPLICABLE,'N') ROLLOVERAPPLICABLE, NVL(USERENTRYAPPLICABLE,'N') USERENTRYAPPLICABLE, 
                NVL(ATTENDANCEENTRYAPPLICABLE,'N') ATTENDANCEENTRYAPPLICABLE, 
                NVL(LIMITAPPLICABLE,'N') LIMITAPPLICABLE, NVL(SLABAPPLICABLE,'N') SLABAPPLICABLE,
                NVL(MISCPAYMENT,'N') MISCPAYMENT, NVL(FINALSETTLEMENT,'N') FINALSETTLEMENT, NVL(INCLUDEARREAR,'N') INCLUDEARREAR, PARTIALLYDEDUCT    
                FROM PIS_GTT_SWT_PHASE_DEDN A,
                ( 
                  SELECT * FROM PISCOMPONENTMASTER B
                  WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                    AND PHASE = P_PHASE
                    AND NVL(INCLUDEPAYROLL,'N') = 'Y'
                    AND YEARMONTH = ( 
                                      SELECT MAX(YEARMONTH) YEARMONTH FROM PISCOMPONENTMASTER
                                      WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                                        AND YEARMONTH <= P_YEARMONTH
                                    )
                ) B,
                ( 
                  SELECT X.UNITCODE, X.CATEGORYCODE, X.GRADECODE, X.COMPONENTCODE, NVL(X.APPLICABLE,'NO') APPLICABLE
                  FROM PISGRADECOMPONENTMAPPING X, 
                  (
                    SELECT UNITCODE, CATEGORYCODE, GRADECODE, MAX(YEARMONTH) YEARMONTH 
                    FROM PISGRADECOMPONENTMAPPING 
                    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                      AND UNITCODE = P_UNIT 
                      AND YEARMONTH <= P_YEARMONTH
                    GROUP BY UNITCODE, CATEGORYCODE, GRADECODE  
                  ) Y
                  WHERE X.COMPANYCODE = P_COMPCODE AND X.DIVISIONCODE = P_DIVCODE   
                    AND X.UNITCODE = X.UNITCODE AND X.CATEGORYCODE = Y.CATEGORYCODE AND X.GRADECODE = Y.GRADECODE
                    AND X.YEARMONTH = Y.YEARMONTH
                    AND X.APPLICABLE = 'Y'                     
                ) C                                     
                WHERE A.COMPONENTCODE = B.COMPONENTCODE
                  AND A.UNITCODE = C.UNITCODE AND A.CATEGORYCODE = C.CATEGORYCODE AND A.GRADECODE = C.GRADECODE  
                  AND A.COMPONENTCODE = C.COMPONENTCODE
                ORDER BY A.WORKERSERIAL,B.CALCULATIONINDEX
          )
    LOOP          
        lv_intCnt := lv_intCnt+1;
        
           DBMS_OUTPUT.PUT_LINE ('RUN QRY 3 cWages.WORKERSERIAL '||cWages.WORKERSERIAL);   
        if lv_strWorkerSerial <> cWages.WORKERSERIAL then
                begin
                    lv_CoinBf:=0;
                    select NVL(COINCF,0) into lv_CoinBf FROM PIS_PREV_FN_COIN where workerserial = lv_strWorkerSerial;
                exception
                    --when others then null;
                    when others then lv_CoinBf :=0;
                end;
                
             
        
            if lv_strWorkerSerial <> 'X' then
                ---- GENERATION COIN CF, TOTAL DEDUCTION, NET SALARY -------
                lv_ComponentAmt := FN_ROUNDOFFRS (lv_TotalEarn - lv_TotalDedn,lv_RoundOffRs,lv_RoundOffType);
                --lv_TempDednAmt := lv_GrossWages + nvl(lv_CoinBf,0) - lv_TotalDedn - lv_ComponentAmt;
                if lv_RoundOffType <> 'H' then
                    lv_CoinCf := lv_TotalEarn - lv_TotalDedn - lv_ComponentAmt;
                else
                    lv_CoinCf := lv_ComponentAmt - (lv_TotalEarn - lv_TotalDedn);
                end if;
--                lv_Sql := 'UPDATE '||P_TABLENAME||' set NETSALARY = '||lv_ComponentAmt||' ,MISC_BF = '||lv_CoinBf||',  MISC_CF = '||lv_CoinCf||' where workerserial = '''||lv_strWorkerSerial||''' ';
                insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
                values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',sysdate,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks );
                commit;
                lv_Sql := 'UPDATE '||P_TABLENAME||' set NETSALARY = '||lv_ComponentAmt||' ,MISC_BF = '||nvl(lv_CoinBf,0)||',  MISC_CF = '||lv_CoinCf||' where workerserial = '''||lv_strWorkerSerial||''' ';
                execute immediate lv_Sql;
                commit;
                
                insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
                values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',sysdate,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks );
                commit;
                
                
                
             
            end if;
            
            
           --added on 12/09/2020
                
            begin
--                    lv_Sql := 'SELECT NVL(MIN_PAY,0) FROM PISPAYTRANSACTION_SWT WHERE TOKENNO='''||00934||''' AND YEARMONTH = '''||202007||'''';
                lv_Sql := 'SELECT NVL(MIN_PAY,0) FROM '||P_TABLENAME||' WHERE workerserial='''||cWages.WORKERSERIAL||'''';
                    
                    
                insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
                values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',sysdate,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,'MINIMUM PAYABLE AMOUNT' );
                commit;
            

                execute immediate lv_Sql into lv_MinPay;
                lv_MinimumPayableAmt := lv_MinPay;
                    
            exception when others then
                lv_MinPay := 0;
            end;
             --ended on 12/09/2020
                 
            lv_strWorkerSerial := cWages.WORKERSERIAL;
            lv_WagesAsOn := cWages.GROSSEARN - lv_MinimumPayableAmt; -- -lv_CoinBf;
            lv_GrossWages := cWages.GROSSEARN;
            lv_TotalEarn := cWages.GROSSEARN; -- -lv_CoinBf;           --cWages.TOTEARN; CHANGES ON 25.01.2017 NEED TO BE CHANGE LATER FOR CONSIDER COINBF AMOUNT --
            lv_TotalDedn :=0;
            ----DBMS_OUTPUT.PUT_LINE ('WORKERSERIAL '||cWages.WORKERSERIAL||', Component '||cWages.COMPONENTCODE||', Gross Wages '||cWages.GROSSEARN||' , AS On '||lv_WagesAsOn);        
        end if;
        lv_TempDednAmt := 0;
        lv_ComponentAmt := cWages.COMPONENTAMOUNT;    
           DBMS_OUTPUT.PUT_LINE ('lv_ComponentAmt '||lv_ComponentAmt);        

        IF P_TRANTYPE='ARREAR' OR P_TRANTYPE='NEW SALARY' THEN --- NEW ADD ON 11/12/2019
            IF CWages.INCLUDEARREAR<>'Y' THEN
                GOTO LOOPSKIP;
            END IF;
        END IF;    
        
        CASE cWages.COMPONENTGROUP
        
            WHEN 'PTAX' THEN
                --- PTAX CALCULATE BASED ON SLAB EMPLOYEE'S PTAX STATE WHICH DEFINED IN THE EMPLOYEE MASTER, ----
                --- IF NOT DEFINED IN THE EMPLOYEEMASTER THEN IT TAKEN DEFAULT STATE AS WEST BENGAL IN THE MASTER VIEW CREATION ---  
                lv_ComponentAmt := cWages.COMPONENTAMOUNT;
                begin
                    SELECT A.PTAXAMOUNT into lv_TempVal FROM PTAXSLAB A, PISMAST B
                    WHERE 1=1
                      AND B.WORKERSERIAL = cWages.WORKERSERIAL  
                      AND B.PTAXSTATE = A.STATENAME 
                      AND WITHEFFECTFROM = ( SELECT MAX(WITHEFFECTFROM) FROM PTAXSLAB WHERE WITHEFFECTFROM <= lv_fn_stdt)
                      AND SLABAMOUNTFROM <= lv_ComponentAmt  
                      AND SLABAMOUNTTO >= lv_ComponentAmt;
                exception
                    when others then 
                      lv_TempVal := 0;
                end;
                lv_ComponentAmt := nvl(lv_TempVal,0);
                --- LIC DUCTION BASE ON gtt_DEDUCTION
--            WHEN 'LIC' THEN
--                lv_TempVal := 0;
--                lv_ComponentAmt := 0;
--                
--                IF P_TRANTYPE <> 'ARREAR' THEN --- FOR ARREAR TIME IT'S NOT REQUIRED
--                    SELECT COUNT(*) CNT INTO lv_CNT FROM  GBL_LICBALANCE WHERE WORKERSERIAL = cWages.WorkerSerial;
--                    IF lv_CNT > 0 THEN
--                        for cLIC in (SELECT * FROM GBL_LICBALANCE WHERE WORKERSERIAL = cWages.WorkerSerial)
--                        LOOP
--                            ----DBMS_OUTPUT.PUT_LINE('WAGES ON  '||lv_WagesAsOn || 'and RUNNING WAGES' ||(lv_ComponentAmt+ cLIC.DUEAMOUNT));
--                            IF lv_WagesAsOn > lv_ComponentAmt+ cLIC.DUEAMOUNT then
--                              --  --DBMS_OUTPUT.PUT_LINE('lic count  '||lv_CNT||', WORKERSERIAL '||cWages.WorkerSerial);
--                                lv_ComponentAmt := lv_ComponentAmt+cLIC.DUEAMOUNT;
--                                lv_Remarks := 'Updating wages - WORKERSERIAL -'||cWages.WorkerSerial||', Token - '||cWages.TOKENNO||', Component -'||cWages.componentcode||', Amount -'||lv_TempDednAmt||', As On Bal '||lv_WagesAsOn;
--                                lv_SqlStr := 'UPDATE GBL_LICBALANCE   SET DEDUCTIONSTATUS=''Y'',DEDUCTFORTNIGHTSTARTDATE= TO_DATE('''||lv_fn_stdt||''',''DD/MM/RRRR''),'||CHR(10)
--                                            ||'DEDUCTYEARMONTH = TO_CHAR(TO_DATE('''||TO_CHAR(lv_fn_stdt,'DD/MM/YYYY')||''',''DD/MM/YYYY''),''YYYYMM'')'||CHR(10)
--                                            ||'WHERE COMPANYCODE='''||cLIC.COMPANYCODE||''' '||CHR(10)
--                                            ||'     AND DIVISIONCODE='''||cLIC.DIVISIONCODE||''' '||CHR(10)
--                                            ||'     AND POLICYNO='''||cLIC.POLICYNO||''' '||CHR(10)
--                                            ||'     AND DUEDATE=TO_DATE('''||TO_CHAR(cLIC.DUEDATE,'DD/MM/YYYY')||''',''DD/MM/YYYY'')';
--                                insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE, ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
--                                values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE, lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
--                                execute immediate lv_SqlStr;
--                            END IF;
--                        END LOOP;
--                        
--                    END IF;
--                END IF;    
                --RETURN;
            WHEN 'PF LOAN' THEN
                lv_ComponentAmt := 0;
                
                lv_CapEMI       := 0;
                lv_IntEMI       := 0;
                
                lv_PFNO         :='';
                --- ONLY SALARY AND FINAL SETTLEMENT TIME LOAN VALUE CALCULATE IN THE SYSTEM ---
                if P_TRANTYPE = 'SALARY' OR P_TRANTYPE = 'FINAL SETTLEMENT' then
                    lv_ComponentAmt := cWages.COMPONENTAMOUNT;
                    lv_ComponentAmt:=0;
                    BEGIN
                        -- ADD 14/09/2019
                            SELECT PFNO INTO lv_PFNO FROM PISEMPLOYEEMASTER WHERE TOKENNO=cWages.TOKENNO;
                        -- ADD 14/09/2019
                        if substr(cWages.componentcode,1,5) = 'LOAN_' THEN
                            --- CHANGES ON 10.05.2017 FOR SECURITY (lUDLOW) GUARD(04) AS ON BALANCE SHOULD BE CHECK ON CAPITAL EMI + INTERNERST EMI 
                            SELECT CASE WHEN PFLOAN_BAL > CAP_EMI THEN CAP_EMI ELSE PFLOAN_BAL END,
                            CASE WHEN PFLOAN_BAL > CAP_EMI THEN CAP_EMI ELSE PFLOAN_BAL END,
                            CASE WHEN PFLOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE PFLOAN_INT_BAL END 
                            INTO lv_ComponentAmt, lv_CapEMI, lv_IntEMI
                            --SELECT CASE WHEN PFLOAN_BAL > CAP_EMI THEN CAP_EMI ELSE PFLOAN_BAL END INTO lv_ComponentAmt  
                            FROM GBL_PFLOANBLNC 
                            -- ADD 14/09/2019
                            --WHERE WORKERSERIAL = cWages.WorkerSerial
                            WHERE PFNO = lv_PFNO
                            -- ADD 14/09/2019
                              AND LOANCODE = substr(cWages.componentcode,6)
                              AND NVL(CAP_STOP,'N') = 'N'
                              AND PFLOAN_BAL > 0;
                        elsif substr(cWages.componentcode,1,5) = 'LINT_' THEN 
                        
                            SELECT CASE WHEN PFLOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE PFLOAN_INT_BAL END,
                            CASE WHEN PFLOAN_BAL > CAP_EMI THEN CAP_EMI ELSE PFLOAN_BAL END,
                            CASE WHEN PFLOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE PFLOAN_INT_BAL END 
                            INTO lv_ComponentAmt, lv_CapEMI, lv_IntEMI
                            --SELECT CASE WHEN PFLOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE PFLOAN_INT_BAL END INTO lv_ComponentAmt  
                            FROM GBL_PFLOANBLNC
                            -- ADD 14/09/2019 
                            --WHERE WORKERSERIAL = cWages.WorkerSerial
                            WHERE PFNO = lv_PFNO
                            -- ADD 14/09/2019
                              AND LOANCODE = substr(cWages.componentcode,6)
                              AND NVL(INT_STOP,'N') = 'N'
                              AND PFLOAN_INT_BAL > 0;
                             -- DBMS_OUTPUT.PUT_LINE(cWages.componentcode|| ' '||lv_ComponentAmt);
                        else
                            lv_ComponentAmt := 0;
                        end if;
                        -- LUDLOW MAINTAIN AS ON BALANCE SHOULD BE 125% MORE THAN EMI AMOUNT OTHER WISE EMI AMOUNT SHOULD BE ZERO
                        --- CHANGES ON 10.05.2017 FOR SECURITY (lUDLOW) GUARD(04) AS ON BALANCE SHOULD BE CHECK ON CAPITAL EMI + INTERNERST EMI
--                        if cWages.CATEGORYCODE = '04' then
--                            -- FOR SECURITY GUARD  AS BALANCE CAN'T LESS THAN SUM OF CAPITAL AND INTEREST EMI.
--                            IF lv_WagesAsOn < (lv_CapEMI+lv_IntEMI) THEN  
--                                lv_ComponentAmt :=0;
--                            end if;                        
--                        else
--                            IF lv_WagesAsOn < lv_ComponentAmt*1.25 THEN
--                                lv_ComponentAmt :=0;
--                            end if;
--                        end if;    

                    EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                              WHEN OTHERS THEN lv_ComponentAmt := 0;      
                    END;        
                else
                    lv_ComponentAmt := 0;
                end if;             
                
                

                              DBMS_OUTPUT.PUT_LINE('PF LOAN AMOUNT '||cWages.componentcode|| ' '||lv_ComponentAmt);   
            WHEN 'LOAN' THEN
               -- --DBMS_OUTPUT.PUT_LINE('WORKERSERIAL '||cWages.WORKERSERIAL||', COMPONENT '||cWages.componentcode);
                lv_ComponentAmt:=0;
                --- ONLY SALARY AND FINAL SETTLEMENT TIME LOAN VALUE CALCULATE IN THE SYSTEM ---
                if P_TRANTYPE = 'SALARY' OR P_TRANTYPE ='FINAL SETTLEMENT' then
                    BEGIN
                        if substr(cWages.componentcode,1,5) = 'LOAN_' THEN 
                            SELECT CASE WHEN LOAN_BAL > CAP_EMI THEN CAP_EMI ELSE LOAN_BAL END INTO lv_ComponentAmt  
                            FROM GBL_LOANBLNC 
                            WHERE WORKERSERIAL = cWages.WorkerSerial and MODULE = 'PIS'
                              AND LOANCODE = substr(cWages.componentcode,6)
                              AND NVL(CAP_STOP,'N') = 'N'
                              AND LOAN_BAL > 0;
                        elsif substr(cWages.componentcode,1,5) = 'LINT_' THEN 
                            SELECT CASE WHEN LOAN_INT_BAL > INT_EMI THEN INT_EMI ELSE LOAN_INT_BAL END INTO lv_ComponentAmt  
                            FROM GBL_LOANBLNC 
                            WHERE WORKERSERIAL = cWages.WorkerSerial and MODULE = 'PIS'
                              AND LOANCODE = substr(cWages.componentcode,6)
                              AND NVL(INT_STOP,'N') = 'N'
                              AND LOAN_INT_BAL > 0;
                        else
                            lv_ComponentAmt := 0;
                        end if;
                --DBMS_OUTPUT.PUT_LINE('lv_ComponentAmt '||lv_ComponentAmt);
                    EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                              WHEN OTHERS THEN lv_ComponentAmt := 0;      
                    END;
                end if;   
             WHEN 'ELECTRICITY' then
                BEGIN
--                    BEGIN
--                         SELECT ATTENDANCEHOURS INTO lv_ChkAttnHrs FROM WPSTEMPATTN WHERE WORKERSERIAL = cWages.WorkerSerial;
--                    EXCEPTION
--                        WHEN OTHERS THEN lv_ChkAttnHrs:=0;
--                    END;
                        lv_ChkAttnHrs := 1;
                    IF lv_ChkAttnHrs > 0 THEN
                        SELECT CASE WHEN NVL(ELEC_BAL_AMT,0) > NVL(ELEC_EMI_AMT,0) THEN ELEC_EMI_AMT ELSE ELEC_BAL_AMT END INTO lv_ComponentAmt  
--                        SELECT NVL(ELEC_BAL_AMT,0) INTO lv_ComponentAmt 
                        FROM GBL_ELECBLNC
                        WHERE WORKERSERIAL = cWages.WorkerSerial; 
                    ELSE
                        lv_ComponentAmt := 0;
                    END IF; 
                    IF lv_ComponentAmt > 0 THEN
                        IF NVL(cWages.PARTIALLYDEDUCT,'NA') = 'Y' THEN
                             if lv_WagesAsOn < lv_ComponentAmt then
                                lv_ComponentAmt := floor(lv_WagesAsOn);
                             end if;
                        END IF;            
                    END IF;
                EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                          WHEN OTHERS THEN lv_ComponentAmt := 0;      
                END; 
             WHEN 'UNREALIZED' THEN
                BEGIN
                    SELECT TOTAL_COMPONENT_EMI INTO lv_ComponentAmt  
                    FROM GBL_UNREALIZEDCOMPAMT
                    WHERE WORKERSERIAL = cWages.WorkerSerial; 
                EXCEPTION WHEN NO_DATA_FOUND THEN lv_ComponentAmt := 0;
                          WHEN OTHERS THEN lv_ComponentAmt := 0;      
                END;      
                                 
            WHEN 'OTHERS' THEN
                lv_ComponentAmt := cWages.COMPONENTAMOUNT;
            ELSE
                lv_ComponentAmt := cWages.COMPONENTAMOUNT;
        END CASE;
       -- lv_TempDednAmt := FN_ROUNDOFFRS(lv_TempDednAmt,cWages.ROUNDOFFRS,cWages.ROUNDOFFTYPE);

        if lv_WagesAsOn >=  lv_ComponentAmt then             -- cWages.COMPONENTAMOUNT
            lv_TempDednAmt := lv_ComponentAmt;              -- cWages.COMPONENTAMOUNT;
        else     
            IF NVL(cWages.PARTIALLYDEDUCT,'NA') = 'N' THEN
                lv_TempDednAmt := 0;
            ELSE
                lv_TempDednAmt := lv_WagesAsOn;  
            END IF;
               
           -- lv_TempDednAmt := lv_WagesAsOn;  
        end if;
        lv_Remarks := 'Updating wages - WORKERSERIAL -'||cWages.WorkerSerial||', Token - '||cWages.TOKENNO||', Component -'||cWages.componentcode||', Amount -'||lv_TempDednAmt||', As On Bal '||lv_WagesAsOn||', As Component Amt '||lv_ComponentAmt || '  MinimumPayableAmt :'||lv_MinimumPayableAmt;
        ----DBMS_OUTPUT.PUT_LINE (lv_Remarks);
        
        --ADDED ON 17/12/2020
--        IF (lv_ComponentAmt- lv_TempDednAmt) <> 0 THEN
            PRC_INSERT_UNREALIZEDDATA
            (
                P_COMPCODE, 
                P_DIVCODE, 
                lv_YearCode, 
                P_YEARMONTH,
                TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'), 
                TO_CHAR(lv_fn_endt,'DD/MM/YYYY'), 
                '000001', 
                '00499', 
                cWages.componentcode, 
                (lv_ComponentAmt- lv_TempDednAmt), 
                (lv_ComponentAmt- lv_TempDednAmt), 
                TO_CHAR(lv_fn_endt,'DD/MM/YYYY'), 
                NULL, 
                'UNRELIZED', 
                'PIS', 
                'UNREALIZED AMOUNT INSERT', 
                'SWT'
            );
--        END IF;
        --ENDED ON 17/12/2020
        
        if lv_TempDednAmt <> 0 then
            lv_TotalDedn := lv_TotalDedn + lv_TempDednAmt;
--            lv_SqlStr := 'UPDATE PISPAYTRANSACTION_SWT set '||cWages.componentcode||' = '||lv_TempDednAmt||', TOTDEDN = '||lv_TotalDedn||' where workerserial = '''||cWages.WorkerSerial||''' ';
            lv_SqlStr := 'UPDATE '||P_TABLENAME||'  set '||cWages.componentcode||' = '||lv_TempDednAmt||', GROSSDEDN = '||lv_TotalDedn||' where workerserial = '''||cWages.WorkerSerial||''' ';
            insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
            values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE, lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
            execute immediate lv_SqlStr;
        end if;
        lv_WagesAsOn := lv_WagesAsOn - lv_TempDednAmt;
        insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
        values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE, lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);        
        <<LOOPSKIP>>
                 lv_ComponentAmt:=0;   

    end loop; 
    ---- FRO LAST EMPLOYEE GENERATION COIN CF, TOTAL DEDUCTION, NET SALARY -------
    lv_ComponentAmt := FN_ROUNDOFFRS(lv_TotalEarn - lv_TotalDedn,lv_RoundOffRs,lv_RoundOffType);
    --lv_TempDednAmt := lv_GrossWages + nvl(lv_CoinBf,0) - lv_TotalDedn - lv_ComponentAmt;
    if lv_RoundOffType <> 'H' then
        lv_CoinCf := lv_TotalEarn - lv_TotalDedn - lv_ComponentAmt;
    else
        lv_CoinCf := lv_ComponentAmt - (lv_TotalEarn - lv_TotalDedn);
    end if;
    ---- CHANGES ON 29.02.2020 --
    lv_Remarks := 'NET SALARY UPDATE';
--    lv_Sql := 'UPDATE '||P_TABLENAME||' set NETSALARY = '||lv_ComponentAmt||', MISC_CF = '||lv_CoinCf||' where workerserial = '''||lv_strWorkerSerial||''' ';

    lv_Sql := ' UPDATE '||P_TABLENAME||' SET MISC_BF = 0 WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10);
    
--    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
--    values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,'COIN BF' );
--    commit;
    execute immediate lv_Sql;
    
    lv_Sql := 'UPDATE '||P_TABLENAME||' A SET A.MISC_BF = (SELECT B.COINCF FROM PIS_PREV_FN_COIN B WHERE A.WORKERSERIAL = B.WORKERSERIAL) '||CHR(10)
        ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' AND A.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10)
        ||' AND WORKERSERIAL IN (SELECT WORKERSERIAL FROM PIS_PREV_FN_COIN) '||CHR(10); 
    
--    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
--    values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,'COIN BF' );
--    commit;
          
    execute immediate lv_Sql;
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,'COIN BF' );
    commit;
    
    -- disable on 01/03/2020 ---
    lv_Sql := 'UPDATE '||P_TABLENAME||' set NETSALARY = '||lv_ComponentAmt||',  MISC_CF = '||lv_CoinCf||' where workerserial = '''||lv_strWorkerSerial||''' ';
    execute immediate lv_Sql;
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks );
    commit;
    --- NET SALARY UPDATE WRITE ON 29/02/2020 ---
    lv_Sql := ' UPDATE '||P_TABLENAME||' set NETSALARY = NVL(NETSALARY,0) - NVL(MISC_BF,0) WHERE COMPANYCODE='''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' AND YEARMONTH = '''||P_YEARMONTH||''' ';  
    execute immediate lv_Sql;
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',SYSDATE,lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt,lv_remarks );
    commit;
    if P_TRANTYPE = 'SALARY' OR P_TRANTYPE = 'FINAL SETTLEMENT' then -- FOR ARREAR PROCESS IT'S NOT REQUIRED 
     


        ------------ INSERT LOAN DATA IN BREAKUP TABLE ----------
        --- for pf loan contribtion insert --
        PRC_LOANBREAKUP_INSERT_WAGES ( P_COMPCODE,P_DIVCODE, lv_YearCode,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'), TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'PIS','PISPAYTRANSACTION_SWT','PF',NULL,NULL,NULL);        
        --- for GENERAL loan contribtion insert --
        PRC_LOANBREAKUP_INSERT_WAGES ( P_COMPCODE,P_DIVCODE, lv_YearCode,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'), TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'PIS','PISPAYTRANSACTION_SWT','SALARY',NULL,NULL,NULL);        
        --- for pf loan balance update in salary table ------
        ---- WAGES UPDATE PROCEDURE CALL PF LOAN UPDATE ON 01/03/3020'
--        PRC_LOANBALANCEUPDATE_SALARY (P_COMPCODE,P_DIVCODE, TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'), TO_CHAR(lv_fn_endt,'DD/MM/YYYY'), 'PIS', 'PISPAYTRANSACTION_SWT','PF', NULL,NULL);
       PRC_LOANBALANCE_UPDT_WAGES(P_COMPCODE,P_DIVCODE,lv_YearCode,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'), TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'PIS',P_TABLENAME,'PF',NULL,NULL,NULL);             
       PRC_LOANBALANCE_UPDT_WAGES(P_COMPCODE,P_DIVCODE,lv_YearCode,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'), TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'PIS',P_TABLENAME,NULL,NULL,NULL,NULL);             
        --- for GENERAL loan balance update in salary table ------
        PRC_LOANBALANCEUPDATE_SALARY (P_COMPCODE,P_DIVCODE, TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'), TO_CHAR(lv_fn_endt,'DD/MM/YYYY'), 'PIS', 'PISPAYTRANSACTION_SWT','SALARY', NULL,NULL);
        -----FOR LIC BALANCE UPDATE IN LICDETAILS TABLE -------
        --PROC_LICUPDATE();
        
            
        --  ELECTRIC DEDUCTION BREAKUP
        lv_remarks := 'ELECTRIC BREAKUP DATA INSERT';
--        PRC_ELECTRICBREAKUP_INSERT(P_COMPCODE,P_DIVCODE,lv_YearCode,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'PIS', P_TABLENAME, NULL);
        PRC_ELECTRICBREAKUP_INSERT(P_COMPCODE,P_DIVCODE,lv_YearCode,TO_CHAR(lv_fn_stdt,'DD/MM/YYYY'),TO_CHAR(lv_fn_endt,'DD/MM/YYYY'),'PIS', 'PISPAYTRANSACTION', NULL);



    end if;            
exception
when others then
 lv_sqlerrm := sqlerrm ;
 --DBMS_output.put_line(lv_sqlerrm||','||lv_sql);
 insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE, ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
 values( P_COMPCODE, P_DIVCODE,lv_ProcName,lv_sqlerrm,SYSDATE, lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);    
end;
/


DROP PROCEDURE PRC_PISSALARYPROCESS_INSERT;

CREATE OR REPLACE PROCEDURE             PRC_PISSALARYPROCESS_INSERT ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_TRANTYPE Varchar2, 
                                                  P_PHASE  number, 
                                                  P_YEARMONTH Varchar2,
                                                  P_EFFECTYEARMONTH Varchar2, 
                                                  P_TABLENAME Varchar2,
                                                  P_PHASE_TABLENAME Varchar2,
                                                  P_UNIT  Varchar2,
                                                  P_CATEGORY    Varchar2  DEFAULT NULL,
                                                  P_GRADE       Varchar2  DEFAULT NULL,
                                                  P_DEPARTMENT  Varchar2  DEFAULT NULL,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
as 
lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY'));

lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_AttnComponent    varchar2(4000) := ''; 
lv_CompWithZero     varchar2(1000) := '';
lv_CompWithValue    varchar2(4000) := '';
lv_CompCol          varchar2(1000) := '';
lv_SQLCompView      varchar2(4000) := '';
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName         varchar2(30)   := 'PRC_PISSALARYPROCESS_INSERT';
lv_TranType         varchar2(20) := 'ATTENDANCE';
begin
    
    IF P_TRANTYPE = 'SALARY' OR P_TRANTYPE = 'ARREAR' OR P_TRANTYPE = 'NEW SALARY' THEN
        lv_TranType := 'ATTENDANCE';
    ELSE
        lv_TranType := P_TRANTYPE;            
    END IF;
    dbms_output.put_line ('TRAN TYPE '||P_TRANTYPE||', YEARMONTH '||P_YEARMONTH||', TABLE NAME '||P_TABLENAME);
    PRC_PISVIEWCREATION ( P_COMPCODE,P_DIVCODE,'ALL',0,P_YEARMONTH,P_EFFECTYEARMONTH, P_TRANTYPE,P_TABLENAME);
    --PRC_PISVIEWCREATION ( 'AJ0050','0001','ALL',0, '201604','','');
    ----- CREATE TABLE WMPTEMPMAST FROM THE VIEW MAST
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE PISTEMPMAST CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE PISTEMPMAST AS SELECT * FROM PISMAST';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE PISTEMPMAST AS SELECT * FROM PISMAST';
    END;
    
    ----- CREATE TABLE PISTEMPATTN FROM THE VIEW ATTN
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE PISTEMPATTN CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE PISTEMPATTN AS SELECT * FROM PISATTN';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE PISTEMPATTN AS SELECT * FROM PISATTN';
    END;    
    ----- CREATE TABLE PISTEMPASSIGN FROM THE VIEW PISASSIGN
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE PISTEMPASSIGN CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE PISTEMPASSIGN AS SELECT * FROM PISASSIGN';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE PISTEMPASSIGN AS SELECT * FROM PISASSIGN';
    END;
    
    ----- CREATE TABLE PISTEMPPRVRT FROM THE VIEW PISPRVRT
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE PISTEMPPRVRT CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE PISTEMPPRVRT AS SELECT * FROM PISPRVRT';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE PISTEMPPRVRT AS SELECT * FROM PISPRVRT';
    END;

    ----- CREATE TABLE PISTEMPPREV FROM THE VIEW PISPREV FOR MISCELLENEOUS DATA 
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE PISTEMPPREV CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE PISTEMPPREV AS SELECT * FROM PISPREV';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE PISTEMPPREV AS SELECT * FROM PISPREV';
    END;    
    
    lv_SqlStr := ' DELETE FROM '||P_TABLENAME;
    BEGIN
        execute immediate lv_SqlStr;
      EXCEPTION WHEN OTHERS THEN NULL;
    END;
    --INSERT INTO PISPAYTRANSACTION_SWT (
    lv_SqlStr := ' INSERT INTO '||P_TABLENAME||' ( '||CHR(10)
               ||' COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, EFFECT_YEARMONTH,UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO, '||CHR(10)  
               ||' TRANSACTIONTYPE, PAYMODE, ATTN_SALD, ATTN_WPAY, ATTN_ADJD, ATTN_TOTD, ATTN_LDAY, ATTN_HOLD, ATTN_CALCF, ATTN_OFFD, LDAY_PL, LDAY_CL, LDAY_SL '||CHR(10)
               ||' ,LV_ENCASH_DAYS '||CHR(10)
               ||'     ) '||CHR(10)
               ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE, A.YEARMONTH, '''||P_EFFECTYEARMONTH||''' EFFECT_YEARMONTH, A.UNITCODE, A.DEPARTMENTCODE, A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL, B.TOKENNO, '||CHR(10) 
               ||' '''||P_TRANTYPE||''' TRANSACTIONTYPE, B.PAYMODE,  A.SALARYDAYS ATTN_SALD, NVL(A.WITHOUTPAYDAYS,0) ATTN_WPAY, NVL(A.ADJUSTMENTDAYS,0) ATTN_ADJD, '||CHR(10) 
               ||' NVL(A.TOTALDAYS,0) ATTN_TOTD, 0 ATTN_LDAY, NVL(A.HOLIDAYS,0) ATTN_HOLD, NVL(A.CALCULATIONFACTORDAYS,0) ATTN_CALCF, NVL(NOOFOFFDAYS,0) ATTN_OFFD, 0 LDAY_PL, 0 LDAY_CL, 0 LDAY_SL '||CHR(10)
               ||' ,NVL(LV_ENCASH_DAYS,0) LV_ENCASH_DAYS '||CHR(10)    
               ||'  FROM PISMONTHATTENDANCE A, PISEMPLOYEEMASTER B '||CHR(10)
               ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
               ||'   AND A.TRANSACTIONTYPE = '''||lv_TranType||''' '||chr(10)
               ||'   AND A.YEARMONTH = '''||P_YEARMONTH||'''    '||CHR(10)
               ||'   AND A.UNITCODE = '''||P_UNIT||'''        '||CHR(10);
    if NVL(P_CATEGORY,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.CATEGORYCODE = '''||P_CATEGORY||''' '||CHR(10);
    end if;
    if NVL(P_GRADE,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.GRADECODE = '''||P_GRADE||''' '||CHR(10);
    end if;
    if NVL(P_DEPARTMENT,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.DEPARTMENTCODE = '''||P_DEPARTMENT||''' '||CHR(10);
    end if;
    if NVL(P_WORKERSERIAL,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10);
    end if;
    if P_TRANTYPE = 'SALARY' OR P_TRANTYPE = 'ARREAR' THEN
        lv_SqlStr := lv_SqlStr ||'   AND (NVL(A.SALARYDAYS,0) + NVL(A.ADJUSTMENTDAYS,0)) > 0 '||CHR(10);
    end if;
    lv_SqlStr := lv_SqlStr||'   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
               ||' AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)  
               ||' ORDER BY A.TOKENNO  '||CHR(10); 
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    execute immediate lv_SqlStr;
    ---- UPDATE NOT APPLCICABLE COLUMN TO ZERO AS PER CATEGORY VS COMPONENT MAPPING FOR THE PHSE 0 OR INSERT 
    ---PROC_WPS_UPDATE_NA_COMP(P_FNSTDT, P_FNENDT, P_TABLENAME,P_TABLENAME,'NO');
    --insert into PIS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,'','',lv_parvalues,lv_fn_stdt,lv_fn_endt, 'PROCESS INSERT SUCCESSFULLY COMPLETE');
    COMMIT;                      
exception
when others then
 lv_sqlerrm := sqlerrm ;
 insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
 values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
end;
/


DROP PROCEDURE PRC_PISSALARYPROCESS_UPDATE;

CREATE OR REPLACE PROCEDURE          PRC_PISSALARYPROCESS_UPDATE ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_TRANTYPE Varchar2, 
                                                  P_PHASE  number, 
                                                  P_YEARMONTH Varchar2,
                                                  P_EFFECTYEARMONTH Varchar2, 
                                                  P_TABLENAME Varchar2,
                                                  P_PHASE_TABLENAME Varchar2,
                                                  P_UNIT  Varchar2,
                                                  P_CATEGORY    Varchar2  DEFAULT NULL,
                                                  P_GRADE       Varchar2  DEFAULT NULL,
                                                  P_DEPARTMENT  Varchar2  DEFAULT NULL,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
as 
lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY'));
lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName         varchar2(30)   := 'PRC_PISSALARYPROCESS_UPDATE';
lv_Sql_TblCreate    varchar2(4000) := '';
lv_Component        varchar2(4000) := ''; 
lv_SqlComponent     varchar2(2000) := ''; 
begin
    lv_parvalues := 'COMP='||P_COMPCODE||',DIV = '||P_DIVCODE||', YEARMONTH = '||P_YEARMONTH||', EFF.YEARMONTH'||P_EFFECTYEARMONTH||',PAHSE='||P_PHASE;
    lv_SqlStr := 'drop table '||P_PHASE_TABLENAME;
    
    BEGIN 
        execute immediate lv_SqlStr;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    
    PRC_PISVIEWCREATION ( P_COMPCODE,P_DIVCODE,'PISCOMP',P_PHASE,P_YEARMONTH,P_EFFECTYEARMONTH,P_TRANTYPE,P_TABLENAME);
    
    lv_Sql_TblCreate := 'CREATE TABLE '||P_PHASE_TABLENAME||'(WORKERSERIAL VARCHAR2(10), YEARMONTH VARCHAR2(10), TRANSACTOINTYPE VARCHAR2(20)';
    
    for c1 in ( 
                SELECT COMPONENTCODE, COMPONENTTYPE, PAYFORMULA, CALCULATIONINDEX, PHASE,
                NVL(DEPENDENCYTYPE,'A') DEPENDENCYTYPE, NVL(ROUNDOFFTYPE,'N') ROUNDOFFTYPE, NVL(ROUNDOFFRS,1) ROUNDOFFRS,
                INCLUDEPAYROLL, nvl(ROLLOVERAPPLICABLE,'N') ROLLOVERAPPLICABLE, NVL(USERENTRYAPPLICABLE,'N') USERENTRYAPPLICABLE, 
                NVL(ATTENDANCEENTRYAPPLICABLE,'N') ATTENDANCEENTRYAPPLICABLE, 
                NVL(LIMITAPPLICABLE,'N') LIMITAPPLICABLE, NVL(SLABAPPLICABLE,'N') SLABAPPLICABLE,
                NVL(MISCPAYMENT,'N') MISCPAYMENT, NVL(FINALSETTLEMENT,'N') FINALSETTLEMENT 
                FROM PISCOMPONENTMASTER
                WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                AND PHASE = P_PHASE
                AND NVL(INCLUDEPAYROLL,'N') = 'Y'
                AND YEARMONTH = ( 
                                  SELECT MAX(YEARMONTH) YEARMONTH FROM PISCOMPONENTMASTER
                                  WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                                    AND YEARMONTH <= P_YEARMONTH
                                )  
               ORDER BY NVL(CALCULATIONINDEX,0)                 
              )   
     LOOP
        if c1.USERENTRYAPPLICABLE = 'Y' then
            if c1.ROLLOVERAPPLICABLE = 'Y' then
                lv_SqlComponent := 'NVL(PISASSIGN.'||C1.COMPONENTCODE||',0)';
            else
                lv_SqlComponent := 'NVL(PISATTN.'||C1.COMPONENTCODE||',0)';
                --lv_Component := lv_Component ||', NVL(ATTN.'||C1.COMPONENTCODE||',0) AS '|| C1.COMPONENTSHORTNAME;          -- monthly entry component comes from attn view
            end if;
        else
            lv_SqlComponent := c1.PAYFORMULA;
            --lv_Component := lv_Component ||', '||c1.PAYFORMULA||' AS '|| C1.COMPONENTSHORTNAME;                                -- formula component as per view defined
        end if;
        
        if c1.DEPENDENCYTYPE = 'A' then
            lv_SqlComponent := 'round(('||lv_SqlComponent||')*PISCOMP.ATTN_SALD/PISCOMP.ATTN_CALCF,2)';
--            IF C1.ROUNDOFFTYPE <> 'N' THEN
--                lv_SqlComponent := 'FN_ROUNDOFFRS(TO_NUMBER('||lv_SqlComponent||'), '||C1.ROUNDOFFRS||','''||C1.ROUNDOFFTYPE||''')';
--            END IF;
        end if;
        IF C1.ROUNDOFFTYPE <> 'N' THEN
            lv_SqlComponent := 'FN_ROUNDOFFRS(TO_NUMBER('||lv_SqlComponent||'), '||C1.ROUNDOFFRS||','''||C1.ROUNDOFFTYPE||''')';
        END IF;
        lv_Component := lv_Component ||', '||lv_SqlComponent||' AS '|| c1.COMPONENTCODE;
     END LOOP;       
     
--------------------     
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE PISTEMPCOMP CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'CREATE TABLE PISTEMPCOMP AS SELECT * FROM PISCOMP';
      EXCEPTION WHEN OTHERS THEN 
        EXECUTE IMMEDIATE 'CREATE TABLE PISTEMPCOMP AS SELECT * FROM PISCOMP';
    END;
    
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE '||P_PHASE_TABLENAME||' CASCADE CONSTRAINTS';
      EXCEPTION WHEN OTHERS THEN NULL;
    END;  
      
        
    lv_Component :=  Replace(lv_Component, 'PISATTN', 'PISTEMPATTN');
    lv_Component := Replace(lv_Component, 'PISMAST', 'PISTEMPMAST');
    lv_Component := Replace(lv_Component, 'PISCOMP', 'PISTEMPCOMP');
    lv_Component := Replace(lv_Component, 'PISASSIGN', 'PISTEMPASSIGN');
    lv_Component := Replace(lv_Component, 'PISPREV', 'PISTEMPPREV');
    lv_Component := Replace(lv_Component, 'PISPRVRT', 'PISTEMPPRVRT');
    
    lv_SqlStr := ' CREATE TABLE '||P_PHASE_TABLENAME||' AS '||CHR(10)
             ||' SELECT PISTEMPATTN.YEARMONTH, PISTEMPATTN.UNITCODE, PISTEMPATTN.CATEGORYCODE, PISTEMPATTN.GRADECODE, PISTEMPATTN.WORKERSERIAL, PISTEMPATTN.TOKENNO, PISTEMPCOMP.ATTN_SALD, PISTEMPCOMP.ATTN_CALCF '||chr(10)
             ||' '||lv_Component||' '||chr(10) 
             ||' FROM PISTEMPMAST, PISTEMPATTN, PISTEMPASSIGN, PISTEMPCOMP, PISTEMPPREV, PISTEMPPRVRT '||CHR(10)
             ||' WHERE PISTEMPMAST.WORKERSERIAL = PISTEMPATTN.WORKERSERIAL '||CHR(10)
             ||'   AND PISTEMPMAST.WORKERSERIAL = PISTEMPASSIGN.WORKERSERIAL '||CHR(10)
             ||'   AND PISTEMPMAST.WORKERSERIAL = PISTEMPCOMP.WORKERSERIAL '||CHR(10)
             ||'   AND PISTEMPMAST.WORKERSERIAL = PISTEMPPRVRT.WORKERSERIAL (+)'||CHR(10)
             ||'   AND PISTEMPMAST.WORKERSERIAL = PISTEMPPREV.WORKERSERIAL (+)'||CHR(10);    
     if P_CATEGORY is not null then
        lv_SqlStr := lv_SqlStr||' AND PISTEMPATTN.CATEGORYCODE = '''||P_CATEGORY||''' '||CHR(10); 
     END IF;
     if P_GRADE is not null then
        lv_SqlStr := lv_SqlStr||' AND PISTEMPATTN.GRADECODE = '''||P_GRADE||''' '||CHR(10);
     END IF;        
     if P_DEPARTMENT is not null then
        lv_SqlStr := lv_SqlStr||' AND PISTEMPATTN.DEPARTMENTCODE = '''||P_DEPARTMENT||''' '||CHR(10); 
     END IF;     
     if P_WORKERSERIAL is not null then
        lv_SqlStr := lv_SqlStr||' AND PISTEMPATTN.WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10); 
     END IF;   

    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,'',lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
    EXECUTE IMMEDIATE lv_SqlStr;  
    COMMIT;

--    lv_SqlStr := 'begin  PRC_PISUPDATE_NA_COMP('''||P_YEARMONTH||''','''||P_TABLENAME||''', '''||P_PHASE_TABLENAME||''',''YES''); end;'; 
    PRC_PISUPDATE_NA_COMP(P_COMPCODE, P_DIVCODE, P_YEARMONTH, P_TABLENAME,P_PHASE_TABLENAME, 'Y');
      
    lv_remarks := 'PHASE - '||P_PHASE||' SUCESSFULLY COMPLETE';
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE,lv_ProcName,'','',lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
    
    ----------- AT THE TIME OF ARREAR NO DATA WITH OUT ARREAR COMPONENTS DATA SHOULD INITIALIZE TO OLD VALUE (ACTUAL PAYMENT PREVIOUSLY)
    IF P_YEARMONTH <> P_EFFECTYEARMONTH THEN    
        PRC_PISSALARY_NONARREAR_UPDT(P_COMPCODE, P_DIVCODE,P_TRANTYPE,P_PHASE,P_YEARMONTH,P_EFFECTYEARMONTH, P_TABLENAME, P_PHASE_TABLENAME, P_UNIT,P_CATEGORY,P_GRADE, P_DEPARTMENT,P_WORKERSERIAL);
    END IF;     
    --------------------       

         
--------------------       
exception
when others then
 lv_sqlerrm := sqlerrm ;
 insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
 values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
end;
/


