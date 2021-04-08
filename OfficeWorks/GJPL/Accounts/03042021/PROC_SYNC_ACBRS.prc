CREATE OR REPLACE PROCEDURE GJPL_WEB."PROC_SYNC_ACBRS" 
(  
    p_CompanyCode           varchar2,  
    p_divisioncode          varchar2,  
    p_YearCode              varchar2,  
    p_SystemvoucherNo       varchar2, 
    p_Operation             varchar2 
)  
--------------- Required for synchorising ACBRS in order to simplyfy BRS 
as  
    lv_cnt                  number;  
    lv_strsql               varchar2(4000); 
    lv_vouchertype          varchar2(20); 
    lv_chequeno             varchar2(20); 
    lv_chequedate           date; 
    lv_chequedrawnon        varchar2(100); 
    lv_AcCode_Opposite      varchar2(50);
begin  
    if upper(p_Operation) = 'ADD' or upper(p_Operation) = 'MODIFY' then  
        --dbms_output.put_line(p_systemvoucherno); 
        select count(*) 
        into lv_cnt 
        from acvoucher a, ACVOUCHERDETAILS b 
        where a.companycode = b.companycode 
          and a.divisioncode = b.divisioncode 
          and a.yearcode = b.yearcode 
          and a.systemvoucherno = b.systemvoucherno 
          and a.companycode = p_companycode 
          and a.divisioncode = p_divisioncode 
          and a.yearcode = p_yearcode 
          and a.systemvoucherno = p_systemvoucherno; 
         
         if lv_cnt > 0 then 
--            raise_application_error(-20012, '~Invalid System Voucher No. for preparing the ACBRSDETAILS.. Called from proc_Sync_ACBRS~');  
--         end if; 
             select count(*) 
             into lv_cnt 
             from ACVOUCHERDETAILS a, acacledger b 
             where a.companycode = b.companycode 
               and a.companycode = p_companycode 
               and a.divisioncode = p_divisioncode 
               and a.yearcode = p_yearcode 
               and a.systemvoucherno = p_systemvoucherno 
               and a.accode = b.accode 
               and b.grouptype = 'BANK'; 
             
             
             if lv_cnt > 0 then 
                  
                 lv_chequeno := null; 
                 lv_chequedate := null; 
                 lv_chequedrawnon := null; 
     
                 select count(*) 
                 into lv_cnt 
                 from ( 
                     select nvl(nvl(chequeno,instructionno),'~NA~') chequeno,nvl(chequedate,to_date('01/01/1900','dd/mm/yyyy')) chequedate,nvl(chequedrawnon,'~NA~') chequedrawnon  
                     from acvoucher 
                     where companycode = p_companycode 
                      and divisioncode = p_divisioncode 
                      and yearcode = p_yearcode 
                      and systemvoucherno = p_systemvoucherno 
                      and nvl(nvl(chequeno,instructionno),'~NA~') <> '~NA~' 
                     union all 
                     select nvl(nvl(partychequeno,instructionno),'~NA~') chequeno,nvl(partychequedate,to_date('01/01/1900','dd/mm/yyyy')) chequedate,nvl(partychequedrawnon,'~NA~') chequedrawnon  
                     from ACVOUCHERDETAILS 
                     where companycode = p_companycode 
                      and divisioncode = p_divisioncode 
                      and yearcode = p_yearcode 
                      and systemvoucherno = p_systemvoucherno 
                      and  nvl(nvl(partychequeno,instructionno),'~NA~') <> '~NA~' 
                       ); 
     
                 if lv_cnt > 0 then 
                     select distinct chequeno,chequedate,chequedrawnon 
                     into lv_chequeno,lv_chequedate,lv_chequedrawnon 
                     from ( 
                         select nvl(nvl(chequeno,instructionno),'~NA~') chequeno,nvl(chequedate,to_date('01/01/1900','dd/mm/yyyy')) chequedate,nvl(chequedrawnon,'~NA~') chequedrawnon  
                         from acvoucher 
                         where companycode = p_companycode 
                          and divisioncode = p_divisioncode 
                          and yearcode = p_yearcode 
                          and systemvoucherno = p_systemvoucherno 
                          and nvl(nvl(chequeno,instructionno),'~NA~') <> '~NA~' 
                         union all 
                         select nvl(nvl(partychequeno,instructionno),'~NA~') chequeno,nvl(partychequedate,to_date('01/01/1900','dd/mm/yyyy')) chequedate,nvl(partychequedrawnon,'~NA~') chequedrawnon  
                         from ACVOUCHERDETAILS 
                         where companycode = p_companycode 
                          and divisioncode = p_divisioncode 
                          and yearcode = p_yearcode 
                          and systemvoucherno = p_systemvoucherno 
                          and  nvl(nvl(partychequeno,instructionno),'~NA~') <> '~NA~' 
                           ); 
                 end if; 
                   
                 delete from acbrsdetails 
                 where companycode = p_companycode 
                   and divisioncode = p_divisioncode 
                   and yearcode = p_yearcode 
                   and systemvoucherno = p_systemvoucherno; 
              
                if lv_chequeno = '~NA~' then  
                    lv_chequeno := null; 
                end if; 
                if lv_chequedate = to_date('01/01/1900','dd/mm/yyyy') then  
                    lv_chequedate := null; 
                end if; 
                if lv_chequedrawnon = '~NA~' then  
                    lv_chequedrawnon := null; 
                end if; 
                   
                 for c1 in (select a.companycode,a.divisioncode,a.yearcode,a.systemvoucherno,a.systemvoucherdate,
                                   a.serialno,a.accode,a.amount,a.drcr,a.realizationdate,c.sysrowid,c.username,c.lastmodified
                            from ACVOUCHERDETAILS a, acacledger b, acvoucher c 
                            where a.companycode = b.companycode 
                              and a.companycode = p_companycode 
                              and a.divisioncode = p_divisioncode 
                              and a.yearcode = p_yearcode 
                              and a.systemvoucherno = p_systemvoucherno 
                              and a.companycode = c.companycode
                              and a.divisioncode = C.DIVISIONCODE
                              and a.yearcode = c.yearcode
                              and a.systemvoucherno = c.systemvoucherno
                              and a.accode = b.accode 
                              and b.grouptype = 'BANK' 
                           ) loop 
     
                         select accode 
                         into lv_AcCode_Opposite 
                         from acvoucherdetails  
                         where companycode = p_companycode 
                           and divisioncode = p_divisioncode 
                           and yearcode = p_yearcode 
                           and systemvoucherno = p_systemvoucherno 
                           and accode <> c1.accode 
                           and drcr <> c1.drcr 
                           and serialno = (select min(serialno) as serialno 
                                           from ACVOUCHERDETAILS  
                                           where companycode = p_companycode 
                                             and divisioncode = p_divisioncode 
                                             and yearcode = p_yearcode 
                                             and systemvoucherno = p_systemvoucherno 
                                             and accode <> c1.accode 
                                             and drcr <> c1.drcr 
                                           ); 
                          
                        insert into acbrsdetails 
                        (companycode,divisioncode,yearcode,systemvoucherno,systemvoucherdate,serialno,accode,amount,drcr, 
                         chequeno,chequedate,chequedrawnon,realizationdate,accode_opposite,sysrowid,username,lastmodified) 
                        values 
                        (c1.companycode,c1.divisioncode,c1.yearcode,c1.systemvoucherno,c1.systemvoucherdate,c1.serialno,c1.accode,c1.amount,c1.drcr, 
                         lv_chequeno,lv_chequedate,lv_chequedrawnon,c1.realizationdate,lv_AcCode_Opposite,c1.sysrowid,c1.username,c1.lastmodified); 
                 end loop; 
             end if;           
        end if;
    else 
         delete from acbrsdetails 
         where companycode = p_companycode 
           and divisioncode = p_divisioncode 
           and yearcode = p_yearcode 
           and systemvoucherno = p_systemvoucherno; 
    end if;     
/*exception  
    when others then  
    --dbms_output.put_line(sqlerrm);*/   
end;
/
