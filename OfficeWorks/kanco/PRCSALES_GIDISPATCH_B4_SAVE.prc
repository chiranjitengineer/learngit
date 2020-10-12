CREATE OR REPLACE procedure KANCO_WEB.prcsales_gidispatch_b4_save
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_master               gbl_salesgardeninvoicemaster%rowtype;
lv_maxgpdate            date;
lv_gpno                 varchar2(50);
lv_INVOICESRLNO         number;
begin
    lv_result:='#SUCCESS#';
    
        --added on 06/10/2020 delete data if companycode is null -- chiranjit ghosh
        delete from gbl_saleschargedetails where COMPANYCODE is null;
                
                
        select *
        into lv_master
        from gbl_salesgardeninvoicemaster;
        
        select count(*)
        into lv_cnt
        from gbl_salesgardeninvoicemaster;

     

        if nvl(lv_master.operationmode,'NA') = 'A' then
            -----------------------  generate transaction (dispatch) no --start-----------------------
            /*
            select fn_autogen_params(lv_master.companycode,lv_master.enterdivisioncode,lv_master.seasoncode,'garden_invoice_dispatch',to_char(lv_master.gatepassdate,'dd/mm/yyyy')) 
            into lv_gpno
            from dual;
            */
            select fn_autogen_params(lv_master.companycode,lv_master.enterdivisioncode,lv_master.yearcode,'GARDEN_INVOICE_DISPATCH',to_char(lv_master.gatepassdate,'dd/mm/yyyy')) 
            into lv_gpno
            from dual;

            -----------------------  generate transaction (dispatch) no --end-----------------------
            if nvl(lv_gpno,'NA') <>'NA' then
                update gbl_salesgardeninvoicemaster
                set gatepassno = lv_gpno;
                
                update gbl_saleschargedetails
                set documentno= lv_gpno;
                
                update gbl_salesgardeninvoicedetail
                set gatepassno = lv_gpno;
            else
                lv_error_remark := 'Dispatch No. not generated. Check Parameters for Auto Gen.';
                raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',6,lv_error_remark));
            end if;
            
        end if;
        
        lv_cnt := 0;
        select count(*)
        into lv_cnt
        from gbl_salesgardeninvoicedetail;
        
        if  nvl(lv_cnt,0) =0 then
            lv_error_remark := 'No details available to save.';
            raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',6,lv_error_remark));
        end if;
        
        
        if nvl(lv_master.operationmode,'NA') = 'A' then
             FOR C1 IN(SELECT DISTINCT COMPANYCODE,DIVISIONCODE,GARDENINVOICENO,MARK
                              FROM GBL_SALESGARDENINVOICEDETAIL 
                              ORDER BY GARDENINVOICENO)
                    LOOP
                    
                        SELECT NVL(MAX(INVOICESRLNO),0)
                        INTO lv_INVOICESRLNO 
                        FROM SALESGARDENINVOICEDETAIL
                        WHERE COMPANYCODE=C1.COMPANYCODE
                        AND DIVISIONCODE=C1.DIVISIONCODE
                        AND MARK=C1.MARK
                        AND GARDENINVOICENO=C1.GARDENINVOICENO;
                        
                        FOR C2 IN(SELECT DISTINCT COMPANYCODE,DIVISIONCODE,MARK,GARDENINVOICENO,GARDENINVOICEDATE,GARDENINVOICESRLNO
                              FROM GBL_SALESGARDENINVOICEDETAIL
                              WHERE  COMPANYCODE=C1.COMPANYCODE
                                     AND DIVISIONCODE=C1.DIVISIONCODE
                                     AND GARDENINVOICENO=C1.GARDENINVOICENO
                              ORDER BY GARDENINVOICENO,GARDENINVOICESRLNO)
                        LOOP
                                lv_INVOICESRLNO := NVL(lv_INVOICESRLNO,0) + 1;
                                
                                UPDATE GBL_SALESGARDENINVOICEDETAIL SET INVOICESRLNO = lv_INVOICESRLNO
                                WHERE COMPANYCODE=C2.COMPANYCODE
                                     AND DIVISIONCODE=C2.DIVISIONCODE
                                     AND GARDENINVOICENO=C2.GARDENINVOICENO
                                     AND GARDENINVOICESRLNO = C2.GARDENINVOICESRLNO;
                        END LOOP;
                            
                    END LOOP;
        end if;
        
    select count(*)
    into lv_cnt
    from sys_gbl_procoutput_info;
          
    if nvl(lv_master.operationmode,'NA') = 'A' then  
        if lv_cnt = 0 then
            insert into sys_gbl_procoutput_info
            values ('[DISPATCH NUMBER GENERATED: ' || lv_gpno || ' Dated : ' || lv_master.gatepassdate || ']' || '~' || lv_master.TRANSFERTYPE || '~' || lv_gpno);
        else
            update sys_gbl_procoutput_info
            set sys_save_info = nvl(sys_save_info,'') || ('[DISPATCH NUMBER GENERATED: ' || lv_gpno || ' Dated : ' || lv_master.gatepassdate || ']' || '~' || lv_master.TRANSFERTYPE || '~' || lv_gpno);
        end if;
    else
         if nvl(lv_master.operationmode,'NA') = 'M' then
             if lv_cnt = 0 then
                insert into sys_gbl_procoutput_info
                values ('[DISPATCH NUMBER : ' || lv_master.gatepassno || ' Dated : ' || lv_master.gatepassdate || ' edited]' || '~' || lv_master.TRANSFERTYPE || '~' || lv_master.gatepassno);
             else
                update sys_gbl_procoutput_info
                set sys_save_info = nvl(sys_save_info,'') || ('[DISPATCH NUMBER : ' || lv_master.gatepassno || ' Dated : ' || lv_master.gatepassdate || ' edited]' || '~' || lv_master.TRANSFERTYPE || '~' || lv_master.gatepassno);
             end if;
         end if;  
    end if;      

--exception when others then
--    lv_error_remark:= lv_error_remark || '#unsucc#essfull#';
--    raise_application_error(to_number(fn_display_error( 'common')),fn_display_error( 'common',6,lv_error_remark));
end;
/