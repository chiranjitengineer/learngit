DROP PROCEDURE NJMCL_WEB.PRCWPS_PFLOAN_AFTERSAVE_160319;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRCWPS_PFLOAN_AFTERSAVE_160319
IS
LV_CNT                  NUMBER;
LV_RESULT               VARCHAR2(10);
LV_ERROR_REMARK         VARCHAR2(4000) := '' ;
LV_MASTER               GBL_PFLOANAPPLICATION%ROWTYPE;
LV_PF_C NUMBER;
LV_PF_E NUMBER;
LV_VPF  NUMBER; 
LV_FORTNIGHTSTARTDATE VARCHAR2(10);
LV_FORTNIGHTENDDATE VARCHAR2(10);

BEGIN
    lv_result:='#SUCCESS#';
    
    select *
    into lv_master
    from gbl_pfloanapplication
    where rownum<=1;

    select count(*)
    into lv_cnt
    from gbl_pfloanapplication;
        
    if nvl(lv_cnt,0)=0 then
        lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
        raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',5,lv_error_remark));
    end if;
       
    if lv_master.operationmode is null then
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
        raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',6,lv_error_remark));
    end if;
        
    if nvl(lv_master.loantype,'XX')='NONREFUNDABLE' then
        if nvl(lv_master.module,'XX')='WPS' then
            select to_char(fortnightstartdate,'DD/MM/RRRR'),to_char(fortnightenddate,'DD/MM/RRRR') 
              into lv_fortnightstartdate,lv_fortnightenddate
              from wpswagedperioddeclaration
             where to_date(lv_master.loandate,'DD/MM/RRRR') between fortnightstartdate and fortnightenddate;
        else
            select '01/'||substr(lv_master.loandate,4),TO_CHAR(last_day(to_date(lv_master.loandate,'DD/MM/RRRR')),'DD/MM/YYYY') 
              into lv_fortnightstartdate,lv_fortnightenddate
              from dual;
        end if;
        
        delete from pftransactiondetails 
        where companycode=lv_master.companycode
          and divisioncode=lv_master.divisioncode
          and yearmonth=lv_master.yearmonth
          and startdate=to_date(lv_fortnightstartdate,'dd/mm/yyyy') 
          and enddate=to_date(lv_fortnightenddate,'dd/mm/yyyy')
          and workerserial=lv_master.workerserial
          and pfno=lv_master.pfno
          and transactiontype='LOAN';
        
        if lv_master.pf_e>0 then
            insert into pftransactiondetails
            select companycode, divisioncode, yearcode, yearmonth, to_date(lv_fortnightstartdate,'dd/mm/yyyy') startdate, 
                   to_date(lv_fortnightenddate,'dd/mm/yyyy') enddate, pfno, workerserial, tokenno, 
                   'PF_E' componentcode, -1*pf_e componentamount, 'LOAN' transactiontype, lv_master.module postedfrom, 
                   'WORKER' employmenttype, 'LESS' addless, null pftrustcode, 
                   0 int_per, 0 int_amt, pf_e total_amt, null pensionno, 0 averagebalance, employeecompanycode, employeedivisioncode, 
                   module, 0 adj_amt, remarks, voucherno, voucherdate, systemvoucherno, systemvoucherdate, 
                   loandate applicationdate, applicationno,SYSDATE LASTMODIFIEDDATE,username,SYSROWID
             from pfloantransaction
            where companycode=lv_master.companycode
              and divisioncode=lv_master.divisioncode
              and yearmonth=lv_master.yearmonth
              and loandate between to_date(lv_fortnightstartdate,'dd/mm/yyyy') and to_date(lv_fortnightenddate,'dd/mm/yyyy')
              and workerserial=lv_master.workerserial
              and pfno=lv_master.pfno;
        end if;
        
        if lv_master.pf_c>0 then
            insert into pftransactiondetails
            select companycode, divisioncode, yearcode, yearmonth, to_date(lv_fortnightstartdate,'dd/mm/yyyy') startdate, 
                   to_date(lv_fortnightenddate,'dd/mm/yyyy') enddate, pfno, workerserial, tokenno, 
                   'PF_C' componentcode, -1*pf_c componentamount, 'LOAN' transactiontype, lv_master.module postedfrom, 
                   'WORKER' employmenttype, 'LESS' addless, null pftrustcode, 
                   0 int_per, 0 int_amt, pf_c total_amt, null pensionno, 0 averagebalance, employeecompanycode, employeedivisioncode, 
                   module, 0 adj_amt, remarks, voucherno, voucherdate, systemvoucherno, systemvoucherdate, 
                   loandate applicationdate, applicationno,SYSDATE LASTMODIFIEDDATE,username,SYSROWID
             from pfloantransaction
            where companycode=lv_master.companycode
              and divisioncode=lv_master.divisioncode
              and yearmonth=lv_master.yearmonth
              and loandate between to_date(lv_fortnightstartdate,'dd/mm/yyyy') and to_date(lv_fortnightenddate,'dd/mm/yyyy')
              and workerserial=lv_master.workerserial
              and pfno=lv_master.pfno;
        end if;
        
        if lv_master.vpf>0 then
            insert into pftransactiondetails
            select companycode, divisioncode, yearcode, yearmonth, to_date(lv_fortnightstartdate,'dd/mm/yyyy') startdate, 
                   to_date(lv_fortnightenddate,'dd/mm/yyyy') enddate, pfno, workerserial, tokenno, 
                   'VPF' componentcode, -1*vpf componentamount, 'LOAN' transactiontype, lv_master.module postedfrom, 
                   'WORKER' employmenttype, 'LESS' addless, null pftrustcode, 
                   0 int_per, 0 int_amt, vpf total_amt, null pensionno, 0 averagebalance, employeecompanycode, employeedivisioncode, 
                   module, 0 adj_amt, remarks, voucherno, voucherdate, systemvoucherno, systemvoucherdate, 
                   loandate applicationdate, applicationno,SYSDATE LASTMODIFIEDDATE,username,SYSROWID
             from pfloantransaction
            where companycode=lv_master.companycode
              and divisioncode=lv_master.divisioncode
              and yearmonth=lv_master.yearmonth
              and loandate between to_date(lv_fortnightstartdate,'dd/mm/yyyy') and to_date(lv_fortnightenddate,'dd/mm/yyyy')
              and workerserial=lv_master.workerserial
              and pfno=lv_master.pfno;
        end if;
    end if;
    
end;
/


