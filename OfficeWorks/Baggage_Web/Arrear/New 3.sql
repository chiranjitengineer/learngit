select DISTINCT ''''||ATTN_ADJD||''','''||ATTN_CALCF||''','''||ATTN_LDAY||''','''||ATTN_OFFD||''','''||ATTN_SALD||''','''||ATTN_TOTD||''','''||ATTN_WPAY||''','''||ATTN_WRKD||''','''||CATEGORYCODE||''','''||COMPANYCODE||''','''||DEPARTMENTCODE||''','''||DIVISIONCODE||''','''||EFFECT_YEARMONTH||''','''||GRADECODE||''','''||LASTMODIFIED||''','''||LDAY_CL||''','''||LDAY_PL||''','''||LDAY_SL||''','''||LVDAYS_RET||''','''||LV_ENCASH_DAYS||''','''||PAYMODE||''','''||SYSROWID||''','''||TOKENNO||''','''||TOTLOAN||''','''||'MONTHLYARR'||''','''||UNITCODE||''','''||USERNAME||''','''||WORKERSERIAL||''','''||YEARCODE||''','''||YEARMONTH||''','  from PISARREARTRANSACTION  where  companycode = '0001'  and DIVISIONCODE = '002' and  UNITCODE = '002' and  DEPARTMENTCODE = '10' and  CATEGORYCODE = '01' and  GRADECODE  = '01' and YEARMONTH = '202004' and WORKERSERIAL = '000110'
insert data   select ''''||SUM(ATN_ALW)||''','''||SUM(ATN_INCTV)||''','''||SUM(ATTN_CUMD)||''','''||SUM(ATTN_FDAY)||''','''||SUM(ATTN_HOLD)||''','''||SUM(ATTN_WOFD)||''','''||SUM(ATTN_WOHD)||''','''||SUM(BASIC)||''','''||SUM(BASIC_RT)||''','''||SUM(CANTEEN)||''','''||SUM(CHILD_ALLW)||''','''||SUM(CHRG_HAND)||''','''||SUM(CLEAN_ALW)||''','''||SUM(CONV_ALLW)||''','''||SUM(CONV_ALW)||''','''||SUM(EDU_ALW)||''','''||SUM(ESI_C)||''','''||SUM(ESI_E)||''','''||SUM(ESI_GROSS)||''','''||SUM(FIX_ALW)||''','''||SUM(FPF)||''','''||SUM(FSTL_DED)||''','''||SUM(FSTL_EARN)||''','''||SUM(GELESI)||''','''||SUM(GROSSDEDN)||''','''||SUM(GROSSEARN)||''','''||SUM(GR_ESI_OTH)||''','''||SUM(HRA)||''','''||SUM(HRA_GROSS)||''','''||SUM(HRA_PER)||''','''||SUM(HRA_RT)||''','''||SUM(INCENTIVE)||''','''||SUM(INSP_ALW)||''','''||SUM(ITAX)||''','''||SUM(LCUM_CL)||''','''||SUM(LCUM_PL)||''','''||SUM(LGBK_ALW)||''','''||SUM(LIBL_EDLN)||''','''||SUM(LIBL_EDU)||''','''||SUM(LIBL_HBLDG)||''','''||SUM(LIBL_HBLN)||''','''||SUM(LIBL_MDLN)||''','''||SUM(LIBL_MGLN)||''','''||SUM(LIBL_MRG)||''','''||SUM(LIBL_OTLN)||''','''||SUM(LIBL_PF)||''','''||SUM(LIBL_PRLN)||''','''||SUM(LIBL_SADV)||''','''||SUM(LIBL_VCLN)||''','''||SUM(LINT_EDLN)||''','''||SUM(LINT_EDU)||''','''||SUM(LINT_HBLDG)||''','''||SUM(LINT_HBLN)||''','''||SUM(LINT_MDLN)||''','''||SUM(LINT_MGLN)||''','''||SUM(LINT_MRG)||''','''||SUM(LINT_OTLN)||''','''||SUM(LINT_PF)||''','''||SUM(LINT_PRLN)||''','''||SUM(LINT_SADV)||''','''||SUM(LINT_VCLN)||''','''||SUM(LNBL_EDLN)||''','''||SUM(LNBL_EDU)||''','''||SUM(LNBL_HBLDG)||''','''||SUM(LNBL_HBLN)||''','''||SUM(LNBL_MDLN)||''','''||SUM(LNBL_MGLN)||''','''||SUM(LNBL_MRG)||''','''||SUM(LNBL_OTLN)||''','''||SUM(LNBL_PF)||''','''||SUM(LNBL_PRLN)||''','''||SUM(LNBL_SADV)||''','''||SUM(LNBL_VCLN)||''','''||SUM(LOAN_EDLN)||''','''||SUM(LOAN_EDU)||''','''||SUM(LOAN_HBLDG)||''','''||SUM(LOAN_HBLN)||''','''||SUM(LOAN_MDLN)||''','''||SUM(LOAN_MGLN)||''','''||SUM(LOAN_MRG)||''','''||SUM(LOAN_OTLN)||''','''||SUM(LOAN_PF)||''','''||SUM(LOAN_PRLN)||''','''||SUM(LOAN_SADV)||''','''||SUM(LOAN_VCLN)||''','''||SUM(LOP)||''','''||SUM(LTA)||''','''||SUM(LVBL_CL)||''','''||SUM(LVBL_PL)||''','''||SUM(LVBL_SL)||''','''||SUM(MEDICAL)||''','''||SUM(MISC_BF)||''','''||SUM(MISC_CF)||''','''||SUM(MISC_DEDN)||''','''||SUM(NETSALARY)||''','''||SUM(OTH_ALLW)||''','''||SUM(OTH_ALLW2)||''','''||SUM(PEN_GROSS)||''','''||SUM(PERF_ALW)||''','''||SUM(PERS_ALLW)||''','''||SUM(PF_C)||''','''||SUM(PF_E)||''','''||SUM(PF_GROSS)||''','''||SUM(PTAX)||''','''||SUM(PTAX_GROSS)||''','''||SUM(PUNC_ALW)||''','''||SUM(SALRATE)||''','''||SUM(SAL_SAVING)||''','''||SUM(SARR_ARRD)||''','''||SUM(SARR_ARRE)||''','''||SUM(SERV_ALLW)||''','''||SUM(SHIFTA_HRS)||''','''||SUM(SHIFTB_HRS)||''','''||SUM(SHIFTC_HRS)||''','''||SUM(SHIFT_A)||''','''||SUM(SHIFT_ALW)||''','''||SUM(SHIFT_B)||''','''||SUM(SHIFT_C)||''','''||SUM(SOFT_ALLW)||''','''||SUM(TOTALDED)||''','''||SUM(TOTEARN)||''','''||SUM(TOTINT)||''','''||SUM(TOTLOANAMT)||''','''||SUM(TOTLOANINT)||''','''||SUM(WASH_ALW)||'''' from (
                            (      
                            select ATN_ALW,ATN_INCTV,ATTN_CUMD,ATTN_FDAY,ATTN_HOLD,ATTN_WOFD,ATTN_WOHD,BASIC,BASIC_RT,CANTEEN,CHILD_ALLW,CHRG_HAND,CLEAN_ALW,CONV_ALLW,CONV_ALW,EDU_ALW,ESI_C,ESI_E,ESI_GROSS,FIX_ALW,FPF,FSTL_DED,FSTL_EARN,GELESI,GROSSDEDN,GROSSEARN,GR_ESI_OTH,HRA,HRA_GROSS,HRA_PER,HRA_RT,INCENTIVE,INSP_ALW,ITAX,LCUM_CL,LCUM_PL,LGBK_ALW,LIBL_EDLN,LIBL_EDU,LIBL_HBLDG,LIBL_HBLN,LIBL_MDLN,LIBL_MGLN,LIBL_MRG,LIBL_OTLN,LIBL_PF,LIBL_PRLN,LIBL_SADV,LIBL_VCLN,LINT_EDLN,LINT_EDU,LINT_HBLDG,LINT_HBLN,LINT_MDLN,LINT_MGLN,LINT_MRG,LINT_OTLN,LINT_PF,LINT_PRLN,LINT_SADV,LINT_VCLN,LNBL_EDLN,LNBL_EDU,LNBL_HBLDG,LNBL_HBLN,LNBL_MDLN,LNBL_MGLN,LNBL_MRG,LNBL_OTLN,LNBL_PF,LNBL_PRLN,LNBL_SADV,LNBL_VCLN,LOAN_EDLN,LOAN_EDU,LOAN_HBLDG,LOAN_HBLN,LOAN_MDLN,LOAN_MGLN,LOAN_MRG,LOAN_OTLN,LOAN_PF,LOAN_PRLN,LOAN_SADV,LOAN_VCLN,LOP,LTA,LVBL_CL,LVBL_PL,LVBL_SL,MEDICAL,MISC_BF,MISC_CF,MISC_DEDN,NETSALARY,OTH_ALLW,OTH_ALLW2,PEN_GROSS,PERF_ALW,PERS_ALLW,PF_C,PF_E,PF_GROSS,PTAX,PTAX_GROSS,PUNC_ALW,SALRATE,SAL_SAVING,SARR_ARRD,SARR_ARRE,SERV_ALLW,SHIFTA_HRS,SHIFTB_HRS,SHIFTC_HRS,SHIFT_A,SHIFT_ALW,SHIFT_B,SHIFT_C,SOFT_ALLW,TOTALDED,TOTEARN,TOTINT,TOTLOANAMT,TOTLOANINT,WASH_ALW from PISARREARTRANSACTION where companycode = '0001'  and DIVISIONCODE = '002' /*and  UNITCODE = '002' and  DEPARTMENTCODE = '10' and  CATEGORYCODE = '01' and  GRADECODE  = '01' and YEARMONTH = '202004'*/ and TRANSACTIONTYPE = 'NEW SALARY' and WORKERSERIAL = '000110' 
                            union all
                            select ATN_ALW*-1,ATN_INCTV*-1,ATTN_CUMD*-1,ATTN_FDAY*-1,ATTN_HOLD*-1,ATTN_WOFD*-1,ATTN_WOHD*-1,BASIC*-1,BASIC_RT*-1,CANTEEN*-1,CHILD_ALLW*-1,CHRG_HAND*-1,CLEAN_ALW*-1,CONV_ALLW*-1,CONV_ALW*-1,EDU_ALW*-1,ESI_C*-1,ESI_E*-1,ESI_GROSS*-1,FIX_ALW*-1,FPF*-1,FSTL_DED*-1,FSTL_EARN*-1,GELESI*-1,GROSSDEDN*-1,GROSSEARN*-1,GR_ESI_OTH*-1,HRA*-1,HRA_GROSS*-1,HRA_PER*-1,HRA_RT*-1,INCENTIVE*-1,INSP_ALW*-1,ITAX*-1,LCUM_CL*-1,LCUM_PL*-1,LGBK_ALW*-1,LIBL_EDLN*-1,LIBL_EDU*-1,LIBL_HBLDG*-1,LIBL_HBLN*-1,LIBL_MDLN*-1,LIBL_MGLN*-1,LIBL_MRG*-1,LIBL_OTLN*-1,LIBL_PF*-1,LIBL_PRLN*-1,LIBL_SADV*-1,LIBL_VCLN*-1,LINT_EDLN*-1,LINT_EDU*-1,LINT_HBLDG*-1,LINT_HBLN*-1,LINT_MDLN*-1,LINT_MGLN*-1,LINT_MRG*-1,LINT_OTLN*-1,LINT_PF*-1,LINT_PRLN*-1,LINT_SADV*-1,LINT_VCLN*-1,LNBL_EDLN*-1,LNBL_EDU*-1,LNBL_HBLDG*-1,LNBL_HBLN*-1,LNBL_MDLN*-1,LNBL_MGLN*-1,LNBL_MRG*-1,LNBL_OTLN*-1,LNBL_PF*-1,LNBL_PRLN*-1,LNBL_SADV*-1,LNBL_VCLN*-1,LOAN_EDLN*-1,LOAN_EDU*-1,LOAN_HBLDG*-1,LOAN_HBLN*-1,LOAN_MDLN*-1,LOAN_MGLN*-1,LOAN_MRG*-1,LOAN_OTLN*-1,LOAN_PF*-1,LOAN_PRLN*-1,LOAN_SADV*-1,LOAN_VCLN*-1,LOP*-1,LTA*-1,LVBL_CL*-1,LVBL_PL*-1,LVBL_SL*-1,MEDICAL*-1,MISC_BF*-1,MISC_CF*-1,MISC_DEDN*-1,NETSALARY*-1,OTH_ALLW*-1,OTH_ALLW2*-1,PEN_GROSS*-1,PERF_ALW*-1,PERS_ALLW*-1,PF_C*-1,PF_E*-1,PF_GROSS*-1,PTAX*-1,PTAX_GROSS*-1,PUNC_ALW*-1,SALRATE*-1,SAL_SAVING*-1,SARR_ARRD*-1,SARR_ARRE*-1,SERV_ALLW*-1,SHIFTA_HRS*-1,SHIFTB_HRS*-1,SHIFTC_HRS*-1,SHIFT_A*-1,SHIFT_ALW*-1,SHIFT_B*-1,SHIFT_C*-1,SOFT_ALLW*-1,TOTALDED*-1,TOTEARN*-1,TOTINT*-1,TOTLOANAMT*-1,TOTLOANINT*-1,WASH_ALW*-1 from PISPAYTRANSACTION  where companycode = '0001'  and DIVISIONCODE = '002' /*and  UNITCODE = '002' and  DEPARTMENTCODE = '10' and  CATEGORYCODE = '01' and  GRADECODE  = '01' and YEARMONTH = '202004'*/ and TRANSACTIONTYPE = 'SALARY' and WORKERSERIAL = '000110'  
                            ) )
select DISTINCT ''''||ATTN_ADJD||''','''||ATTN_CALCF||''','''||ATTN_LDAY||''','''||ATTN_OFFD||''','''||ATTN_SALD||''','''||ATTN_TOTD||''','''||ATTN_WPAY||''','''||ATTN_WRKD||''','''||CATEGORYCODE||''','''||COMPANYCODE||''','''||DEPARTMENTCODE||''','''||DIVISIONCODE||''','''||EFFECT_YEARMONTH||''','''||GRADECODE||''','''||LASTMODIFIED||''','''||LDAY_CL||''','''||LDAY_PL||''','''||LDAY_SL||''','''||LVDAYS_RET||''','''||LV_ENCASH_DAYS||''','''||PAYMODE||''','''||SYSROWID||''','''||TOKENNO||''','''||TOTLOAN||''','''||'MONTHLYARR'||''','''||UNITCODE||''','''||USERNAME||''','''||WORKERSERIAL||''','''||YEARCODE||''','''||YEARMONTH||''','  from PISARREARTRANSACTION  where  companycode = '0001'  and DIVISIONCODE = '002' and  UNITCODE = '002' and  DEPARTMENTCODE = '10' and  CATEGORYCODE = '01' and  GRADECODE  = '01' and YEARMONTH = '202005' and WORKERSERIAL = '000110'
insert data   select ''''||SUM(ATN_ALW)||''','''||SUM(ATN_INCTV)||''','''||SUM(ATTN_CUMD)||''','''||SUM(ATTN_FDAY)||''','''||SUM(ATTN_HOLD)||''','''||SUM(ATTN_WOFD)||''','''||SUM(ATTN_WOHD)||''','''||SUM(BASIC)||''','''||SUM(BASIC_RT)||''','''||SUM(CANTEEN)||''','''||SUM(CHILD_ALLW)||''','''||SUM(CHRG_HAND)||''','''||SUM(CLEAN_ALW)||''','''||SUM(CONV_ALLW)||''','''||SUM(CONV_ALW)||''','''||SUM(EDU_ALW)||''','''||SUM(ESI_C)||''','''||SUM(ESI_E)||''','''||SUM(ESI_GROSS)||''','''||SUM(FIX_ALW)||''','''||SUM(FPF)||''','''||SUM(FSTL_DED)||''','''||SUM(FSTL_EARN)||''','''||SUM(GELESI)||''','''||SUM(GROSSDEDN)||''','''||SUM(GROSSEARN)||''','''||SUM(GR_ESI_OTH)||''','''||SUM(HRA)||''','''||SUM(HRA_GROSS)||''','''||SUM(HRA_PER)||''','''||SUM(HRA_RT)||''','''||SUM(INCENTIVE)||''','''||SUM(INSP_ALW)||''','''||SUM(ITAX)||''','''||SUM(LCUM_CL)||''','''||SUM(LCUM_PL)||''','''||SUM(LGBK_ALW)||''','''||SUM(LIBL_EDLN)||''','''||SUM(LIBL_EDU)||''','''||SUM(LIBL_HBLDG)||''','''||SUM(LIBL_HBLN)||''','''||SUM(LIBL_MDLN)||''','''||SUM(LIBL_MGLN)||''','''||SUM(LIBL_MRG)||''','''||SUM(LIBL_OTLN)||''','''||SUM(LIBL_PF)||''','''||SUM(LIBL_PRLN)||''','''||SUM(LIBL_SADV)||''','''||SUM(LIBL_VCLN)||''','''||SUM(LINT_EDLN)||''','''||SUM(LINT_EDU)||''','''||SUM(LINT_HBLDG)||''','''||SUM(LINT_HBLN)||''','''||SUM(LINT_MDLN)||''','''||SUM(LINT_MGLN)||''','''||SUM(LINT_MRG)||''','''||SUM(LINT_OTLN)||''','''||SUM(LINT_PF)||''','''||SUM(LINT_PRLN)||''','''||SUM(LINT_SADV)||''','''||SUM(LINT_VCLN)||''','''||SUM(LNBL_EDLN)||''','''||SUM(LNBL_EDU)||''','''||SUM(LNBL_HBLDG)||''','''||SUM(LNBL_HBLN)||''','''||SUM(LNBL_MDLN)||''','''||SUM(LNBL_MGLN)||''','''||SUM(LNBL_MRG)||''','''||SUM(LNBL_OTLN)||''','''||SUM(LNBL_PF)||''','''||SUM(LNBL_PRLN)||''','''||SUM(LNBL_SADV)||''','''||SUM(LNBL_VCLN)||''','''||SUM(LOAN_EDLN)||''','''||SUM(LOAN_EDU)||''','''||SUM(LOAN_HBLDG)||''','''||SUM(LOAN_HBLN)||''','''||SUM(LOAN_MDLN)||''','''||SUM(LOAN_MGLN)||''','''||SUM(LOAN_MRG)||''','''||SUM(LOAN_OTLN)||''','''||SUM(LOAN_PF)||''','''||SUM(LOAN_PRLN)||''','''||SUM(LOAN_SADV)||''','''||SUM(LOAN_VCLN)||''','''||SUM(LOP)||''','''||SUM(LTA)||''','''||SUM(LVBL_CL)||''','''||SUM(LVBL_PL)||''','''||SUM(LVBL_SL)||''','''||SUM(MEDICAL)||''','''||SUM(MISC_BF)||''','''||SUM(MISC_CF)||''','''||SUM(MISC_DEDN)||''','''||SUM(NETSALARY)||''','''||SUM(OTH_ALLW)||''','''||SUM(OTH_ALLW2)||''','''||SUM(PEN_GROSS)||''','''||SUM(PERF_ALW)||''','''||SUM(PERS_ALLW)||''','''||SUM(PF_C)||''','''||SUM(PF_E)||''','''||SUM(PF_GROSS)||''','''||SUM(PTAX)||''','''||SUM(PTAX_GROSS)||''','''||SUM(PUNC_ALW)||''','''||SUM(SALRATE)||''','''||SUM(SAL_SAVING)||''','''||SUM(SARR_ARRD)||''','''||SUM(SARR_ARRE)||''','''||SUM(SERV_ALLW)||''','''||SUM(SHIFTA_HRS)||''','''||SUM(SHIFTB_HRS)||''','''||SUM(SHIFTC_HRS)||''','''||SUM(SHIFT_A)||''','''||SUM(SHIFT_ALW)||''','''||SUM(SHIFT_B)||''','''||SUM(SHIFT_C)||''','''||SUM(SOFT_ALLW)||''','''||SUM(TOTALDED)||''','''||SUM(TOTEARN)||''','''||SUM(TOTINT)||''','''||SUM(TOTLOANAMT)||''','''||SUM(TOTLOANINT)||''','''||SUM(WASH_ALW)||'''' from (
                            (      
                            select ATN_ALW,ATN_INCTV,ATTN_CUMD,ATTN_FDAY,ATTN_HOLD,ATTN_WOFD,ATTN_WOHD,BASIC,BASIC_RT,CANTEEN,CHILD_ALLW,CHRG_HAND,CLEAN_ALW,CONV_ALLW,CONV_ALW,EDU_ALW,ESI_C,ESI_E,ESI_GROSS,FIX_ALW,FPF,FSTL_DED,FSTL_EARN,GELESI,GROSSDEDN,GROSSEARN,GR_ESI_OTH,HRA,HRA_GROSS,HRA_PER,HRA_RT,INCENTIVE,INSP_ALW,ITAX,LCUM_CL,LCUM_PL,LGBK_ALW,LIBL_EDLN,LIBL_EDU,LIBL_HBLDG,LIBL_HBLN,LIBL_MDLN,LIBL_MGLN,LIBL_MRG,LIBL_OTLN,LIBL_PF,LIBL_PRLN,LIBL_SADV,LIBL_VCLN,LINT_EDLN,LINT_EDU,LINT_HBLDG,LINT_HBLN,LINT_MDLN,LINT_MGLN,LINT_MRG,LINT_OTLN,LINT_PF,LINT_PRLN,LINT_SADV,LINT_VCLN,LNBL_EDLN,LNBL_EDU,LNBL_HBLDG,LNBL_HBLN,LNBL_MDLN,LNBL_MGLN,LNBL_MRG,LNBL_OTLN,LNBL_PF,LNBL_PRLN,LNBL_SADV,LNBL_VCLN,LOAN_EDLN,LOAN_EDU,LOAN_HBLDG,LOAN_HBLN,LOAN_MDLN,LOAN_MGLN,LOAN_MRG,LOAN_OTLN,LOAN_PF,LOAN_PRLN,LOAN_SADV,LOAN_VCLN,LOP,LTA,LVBL_CL,LVBL_PL,LVBL_SL,MEDICAL,MISC_BF,MISC_CF,MISC_DEDN,NETSALARY,OTH_ALLW,OTH_ALLW2,PEN_GROSS,PERF_ALW,PERS_ALLW,PF_C,PF_E,PF_GROSS,PTAX,PTAX_GROSS,PUNC_ALW,SALRATE,SAL_SAVING,SARR_ARRD,SARR_ARRE,SERV_ALLW,SHIFTA_HRS,SHIFTB_HRS,SHIFTC_HRS,SHIFT_A,SHIFT_ALW,SHIFT_B,SHIFT_C,SOFT_ALLW,TOTALDED,TOTEARN,TOTINT,TOTLOANAMT,TOTLOANINT,WASH_ALW from PISARREARTRANSACTION where companycode = '0001'  and DIVISIONCODE = '002' /*and  UNITCODE = '002' and  DEPARTMENTCODE = '10' and  CATEGORYCODE = '01' and  GRADECODE  = '01' and YEARMONTH = '202005'*/ and TRANSACTIONTYPE = 'NEW SALARY' and WORKERSERIAL = '000110' 
                            union all
                            select ATN_ALW*-1,ATN_INCTV*-1,ATTN_CUMD*-1,ATTN_FDAY*-1,ATTN_HOLD*-1,ATTN_WOFD*-1,ATTN_WOHD*-1,BASIC*-1,BASIC_RT*-1,CANTEEN*-1,CHILD_ALLW*-1,CHRG_HAND*-1,CLEAN_ALW*-1,CONV_ALLW*-1,CONV_ALW*-1,EDU_ALW*-1,ESI_C*-1,ESI_E*-1,ESI_GROSS*-1,FIX_ALW*-1,FPF*-1,FSTL_DED*-1,FSTL_EARN*-1,GELESI*-1,GROSSDEDN*-1,GROSSEARN*-1,GR_ESI_OTH*-1,HRA*-1,HRA_GROSS*-1,HRA_PER*-1,HRA_RT*-1,INCENTIVE*-1,INSP_ALW*-1,ITAX*-1,LCUM_CL*-1,LCUM_PL*-1,LGBK_ALW*-1,LIBL_EDLN*-1,LIBL_EDU*-1,LIBL_HBLDG*-1,LIBL_HBLN*-1,LIBL_MDLN*-1,LIBL_MGLN*-1,LIBL_MRG*-1,LIBL_OTLN*-1,LIBL_PF*-1,LIBL_PRLN*-1,LIBL_SADV*-1,LIBL_VCLN*-1,LINT_EDLN*-1,LINT_EDU*-1,LINT_HBLDG*-1,LINT_HBLN*-1,LINT_MDLN*-1,LINT_MGLN*-1,LINT_MRG*-1,LINT_OTLN*-1,LINT_PF*-1,LINT_PRLN*-1,LINT_SADV*-1,LINT_VCLN*-1,LNBL_EDLN*-1,LNBL_EDU*-1,LNBL_HBLDG*-1,LNBL_HBLN*-1,LNBL_MDLN*-1,LNBL_MGLN*-1,LNBL_MRG*-1,LNBL_OTLN*-1,LNBL_PF*-1,LNBL_PRLN*-1,LNBL_SADV*-1,LNBL_VCLN*-1,LOAN_EDLN*-1,LOAN_EDU*-1,LOAN_HBLDG*-1,LOAN_HBLN*-1,LOAN_MDLN*-1,LOAN_MGLN*-1,LOAN_MRG*-1,LOAN_OTLN*-1,LOAN_PF*-1,LOAN_PRLN*-1,LOAN_SADV*-1,LOAN_VCLN*-1,LOP*-1,LTA*-1,LVBL_CL*-1,LVBL_PL*-1,LVBL_SL*-1,MEDICAL*-1,MISC_BF*-1,MISC_CF*-1,MISC_DEDN*-1,NETSALARY*-1,OTH_ALLW*-1,OTH_ALLW2*-1,PEN_GROSS*-1,PERF_ALW*-1,PERS_ALLW*-1,PF_C*-1,PF_E*-1,PF_GROSS*-1,PTAX*-1,PTAX_GROSS*-1,PUNC_ALW*-1,SALRATE*-1,SAL_SAVING*-1,SARR_ARRD*-1,SARR_ARRE*-1,SERV_ALLW*-1,SHIFTA_HRS*-1,SHIFTB_HRS*-1,SHIFTC_HRS*-1,SHIFT_A*-1,SHIFT_ALW*-1,SHIFT_B*-1,SHIFT_C*-1,SOFT_ALLW*-1,TOTALDED*-1,TOTEARN*-1,TOTINT*-1,TOTLOANAMT*-1,TOTLOANINT*-1,WASH_ALW*-1 from PISPAYTRANSACTION  where companycode = '0001'  and DIVISIONCODE = '002' /*and  UNITCODE = '002' and  DEPARTMENTCODE = '10' and  CATEGORYCODE = '01' and  GRADECODE  = '01' and YEARMONTH = '202005'*/ and TRANSACTIONTYPE = 'SALARY' and WORKERSERIAL = '000110'  
                            ) )
select DISTINCT ''''||ATTN_ADJD||''','''||ATTN_CALCF||''','''||ATTN_LDAY||''','''||ATTN_OFFD||''','''||ATTN_SALD||''','''||ATTN_TOTD||''','''||ATTN_WPAY||''','''||ATTN_WRKD||''','''||CATEGORYCODE||''','''||COMPANYCODE||''','''||DEPARTMENTCODE||''','''||DIVISIONCODE||''','''||EFFECT_YEARMONTH||''','''||GRADECODE||''','''||LASTMODIFIED||''','''||LDAY_CL||''','''||LDAY_PL||''','''||LDAY_SL||''','''||LVDAYS_RET||''','''||LV_ENCASH_DAYS||''','''||PAYMODE||''','''||SYSROWID||''','''||TOKENNO||''','''||TOTLOAN||''','''||'MONTHLYARR'||''','''||UNITCODE||''','''||USERNAME||''','''||WORKERSERIAL||''','''||YEARCODE||''','''||YEARMONTH||''','  from PISARREARTRANSACTION  where  companycode = '0001'  and DIVISIONCODE = '002' and  UNITCODE = '002' and  DEPARTMENTCODE = '10' and  CATEGORYCODE = '01' and  GRADECODE  = '01' and YEARMONTH = '202006' and WORKERSERIAL = '000110'
insert data   


select ''''||SUM(ATN_ALW)||''','''||SUM(ATN_INCTV)||''','''||SUM(ATTN_CUMD)||''','''||SUM(ATTN_FDAY)||''','''||SUM(ATTN_HOLD)||''','''||SUM(ATTN_WOFD)||''','''||SUM(ATTN_WOHD)||''','''||SUM(BASIC)||''','''||SUM(BASIC_RT)||''','''||SUM(CANTEEN)||''','''||SUM(CHILD_ALLW)||''','''||SUM(CHRG_HAND)||''','''||SUM(CLEAN_ALW)||''','''||SUM(CONV_ALLW)||''','''||SUM(CONV_ALW)||''','''||SUM(EDU_ALW)||''','''||SUM(ESI_C)||''','''||SUM(ESI_E)||''','''||SUM(ESI_GROSS)||''','''||SUM(FIX_ALW)||''','''||SUM(FPF)||''','''||SUM(FSTL_DED)||''','''||SUM(FSTL_EARN)||''','''||SUM(GELESI)||''','''||SUM(GROSSDEDN)||''','''||SUM(GROSSEARN)||''','''||SUM(GR_ESI_OTH)||''','''||SUM(HRA)||''','''||SUM(HRA_GROSS)||''','''||SUM(HRA_PER)||''','''||SUM(HRA_RT)||''','''||SUM(INCENTIVE)||''','''||SUM(INSP_ALW)||''','''||SUM(ITAX)||''','''||SUM(LCUM_CL)||''','''||SUM(LCUM_PL)||''','''||SUM(LGBK_ALW)||''','''||SUM(LIBL_EDLN)||''','''||SUM(LIBL_EDU)||''','''||SUM(LIBL_HBLDG)||''','''||SUM(LIBL_HBLN)||''','''||SUM(LIBL_MDLN)||''','''||SUM(LIBL_MGLN)||''','''||SUM(LIBL_MRG)||''','''||SUM(LIBL_OTLN)||''','''||SUM(LIBL_PF)||''','''||SUM(LIBL_PRLN)||''','''||SUM(LIBL_SADV)||''','''||SUM(LIBL_VCLN)||''','''||SUM(LINT_EDLN)||''','''||SUM(LINT_EDU)||''','''||SUM(LINT_HBLDG)||''','''||SUM(LINT_HBLN)||''','''||SUM(LINT_MDLN)||''','''||SUM(LINT_MGLN)||''','''||SUM(LINT_MRG)||''','''||SUM(LINT_OTLN)||''','''||SUM(LINT_PF)||''','''||SUM(LINT_PRLN)||''','''||SUM(LINT_SADV)||''','''||SUM(LINT_VCLN)||''','''||SUM(LNBL_EDLN)||''','''||SUM(LNBL_EDU)||''','''||SUM(LNBL_HBLDG)||''','''||SUM(LNBL_HBLN)||''','''||SUM(LNBL_MDLN)||''','''||SUM(LNBL_MGLN)||''','''||SUM(LNBL_MRG)||''','''||SUM(LNBL_OTLN)||''','''||SUM(LNBL_PF)||''','''||SUM(LNBL_PRLN)||''','''||SUM(LNBL_SADV)||''','''||SUM(LNBL_VCLN)||''','''||SUM(LOAN_EDLN)||''','''||SUM(LOAN_EDU)||''','''||SUM(LOAN_HBLDG)||''','''||SUM(LOAN_HBLN)||''','''||SUM(LOAN_MDLN)||''','''||SUM(LOAN_MGLN)||''','''||SUM(LOAN_MRG)||''','''||SUM(LOAN_OTLN)||''','''||SUM(LOAN_PF)||''','''||SUM(LOAN_PRLN)||''','''||SUM(LOAN_SADV)||''','''||SUM(LOAN_VCLN)||''','''||SUM(LOP)||''','''||SUM(LTA)||''','''||SUM(LVBL_CL)||''','''||SUM(LVBL_PL)||''','''||SUM(LVBL_SL)||''','''||SUM(MEDICAL)||''','''||SUM(MISC_BF)||''','''||SUM(MISC_CF)||''','''||SUM(MISC_DEDN)||''','''||SUM(NETSALARY)||''','''||SUM(OTH_ALLW)||''','''||SUM(OTH_ALLW2)||''','''||SUM(PEN_GROSS)||''','''||SUM(PERF_ALW)||''','''||SUM(PERS_ALLW)||''','''||SUM(PF_C)||''','''||SUM(PF_E)||''','''||SUM(PF_GROSS)||''','''||SUM(PTAX)||''','''||SUM(PTAX_GROSS)||''','''||SUM(PUNC_ALW)||''','''||SUM(SALRATE)||''','''||SUM(SAL_SAVING)||''','''||SUM(SARR_ARRD)||''','''||SUM(SARR_ARRE)||''','''||SUM(SERV_ALLW)||''','''||SUM(SHIFTA_HRS)||''','''||SUM(SHIFTB_HRS)||''','''||SUM(SHIFTC_HRS)||''','''||SUM(SHIFT_A)||''','''||SUM(SHIFT_ALW)||''','''||SUM(SHIFT_B)||''','''||SUM(SHIFT_C)||''','''||SUM(SOFT_ALLW)||''','''||SUM(TOTALDED)||''','''||SUM(TOTEARN)||''','''||SUM(TOTINT)||''','''||SUM(TOTLOANAMT)||''','''||SUM(TOTLOANINT)||''','''||SUM(WASH_ALW)||'''' from (
                            (      
                            select ATN_ALW,ATN_INCTV,ATTN_CUMD,ATTN_FDAY,ATTN_HOLD,ATTN_WOFD,ATTN_WOHD,BASIC,BASIC_RT,CANTEEN,CHILD_ALLW,CHRG_HAND,CLEAN_ALW,CONV_ALLW,CONV_ALW,EDU_ALW,ESI_C,ESI_E,ESI_GROSS,FIX_ALW,FPF,FSTL_DED,FSTL_EARN,GELESI,GROSSDEDN,GROSSEARN,GR_ESI_OTH,HRA,HRA_GROSS,HRA_PER,HRA_RT,INCENTIVE,INSP_ALW,ITAX,LCUM_CL,LCUM_PL,LGBK_ALW,LIBL_EDLN,LIBL_EDU,LIBL_HBLDG,LIBL_HBLN,LIBL_MDLN,LIBL_MGLN,LIBL_MRG,LIBL_OTLN,LIBL_PF,LIBL_PRLN,LIBL_SADV,LIBL_VCLN,LINT_EDLN,LINT_EDU,LINT_HBLDG,LINT_HBLN,LINT_MDLN,LINT_MGLN,LINT_MRG,LINT_OTLN,LINT_PF,LINT_PRLN,LINT_SADV,LINT_VCLN,LNBL_EDLN,LNBL_EDU,LNBL_HBLDG,LNBL_HBLN,LNBL_MDLN,LNBL_MGLN,LNBL_MRG,LNBL_OTLN,LNBL_PF,LNBL_PRLN,LNBL_SADV,LNBL_VCLN,LOAN_EDLN,LOAN_EDU,LOAN_HBLDG,LOAN_HBLN,LOAN_MDLN,LOAN_MGLN,LOAN_MRG,LOAN_OTLN,LOAN_PF,LOAN_PRLN,LOAN_SADV,LOAN_VCLN,LOP,LTA,LVBL_CL,LVBL_PL,LVBL_SL,MEDICAL,MISC_BF,MISC_CF,MISC_DEDN,NETSALARY,OTH_ALLW,OTH_ALLW2,PEN_GROSS,PERF_ALW,PERS_ALLW,PF_C,PF_E,PF_GROSS,PTAX,PTAX_GROSS,PUNC_ALW,SALRATE,SAL_SAVING,SARR_ARRD,SARR_ARRE,SERV_ALLW,SHIFTA_HRS,SHIFTB_HRS,SHIFTC_HRS,SHIFT_A,SHIFT_ALW,SHIFT_B,SHIFT_C,SOFT_ALLW,TOTALDED,TOTEARN,TOTINT,TOTLOANAMT,TOTLOANINT,WASH_ALW from PISARREARTRANSACTION where companycode = '0001'  and DIVISIONCODE = '002' /*and  UNITCODE = '002' and  DEPARTMENTCODE = '10' and  CATEGORYCODE = '01' and  GRADECODE  = '01' and YEARMONTH = '202006'*/ and TRANSACTIONTYPE = 'NEW SALARY' and WORKERSERIAL = '000110' 
                            union all
                            select ATN_ALW*-1,ATN_INCTV*-1,ATTN_CUMD*-1,ATTN_FDAY*-1,ATTN_HOLD*-1,ATTN_WOFD*-1,ATTN_WOHD*-1,BASIC*-1,BASIC_RT*-1,CANTEEN*-1,CHILD_ALLW*-1,CHRG_HAND*-1,CLEAN_ALW*-1,CONV_ALLW*-1,CONV_ALW*-1,EDU_ALW*-1,ESI_C*-1,ESI_E*-1,ESI_GROSS*-1,FIX_ALW*-1,FPF*-1,FSTL_DED*-1,FSTL_EARN*-1,GELESI*-1,GROSSDEDN*-1,GROSSEARN*-1,GR_ESI_OTH*-1,HRA*-1,HRA_GROSS*-1,HRA_PER*-1,HRA_RT*-1,INCENTIVE*-1,INSP_ALW*-1,ITAX*-1,LCUM_CL*-1,LCUM_PL*-1,LGBK_ALW*-1,LIBL_EDLN*-1,LIBL_EDU*-1,LIBL_HBLDG*-1,LIBL_HBLN*-1,LIBL_MDLN*-1,LIBL_MGLN*-1,LIBL_MRG*-1,LIBL_OTLN*-1,LIBL_PF*-1,LIBL_PRLN*-1,LIBL_SADV*-1,LIBL_VCLN*-1,LINT_EDLN*-1,LINT_EDU*-1,LINT_HBLDG*-1,LINT_HBLN*-1,LINT_MDLN*-1,LINT_MGLN*-1,LINT_MRG*-1,LINT_OTLN*-1,LINT_PF*-1,LINT_PRLN*-1,LINT_SADV*-1,LINT_VCLN*-1,LNBL_EDLN*-1,LNBL_EDU*-1,LNBL_HBLDG*-1,LNBL_HBLN*-1,LNBL_MDLN*-1,LNBL_MGLN*-1,LNBL_MRG*-1,LNBL_OTLN*-1,LNBL_PF*-1,LNBL_PRLN*-1,LNBL_SADV*-1,LNBL_VCLN*-1,LOAN_EDLN*-1,LOAN_EDU*-1,LOAN_HBLDG*-1,LOAN_HBLN*-1,LOAN_MDLN*-1,LOAN_MGLN*-1,LOAN_MRG*-1,LOAN_OTLN*-1,LOAN_PF*-1,LOAN_PRLN*-1,LOAN_SADV*-1,LOAN_VCLN*-1,LOP*-1,LTA*-1,LVBL_CL*-1,LVBL_PL*-1,LVBL_SL*-1,MEDICAL*-1,MISC_BF*-1,MISC_CF*-1,MISC_DEDN*-1,NETSALARY*-1,OTH_ALLW*-1,OTH_ALLW2*-1,PEN_GROSS*-1,PERF_ALW*-1,PERS_ALLW*-1,PF_C*-1,PF_E*-1,PF_GROSS*-1,PTAX*-1,PTAX_GROSS*-1,PUNC_ALW*-1,SALRATE*-1,SAL_SAVING*-1,SARR_ARRD*-1,SARR_ARRE*-1,SERV_ALLW*-1,SHIFTA_HRS*-1,SHIFTB_HRS*-1,SHIFTC_HRS*-1,SHIFT_A*-1,SHIFT_ALW*-1,SHIFT_B*-1,SHIFT_C*-1,SOFT_ALLW*-1,TOTALDED*-1,TOTEARN*-1,TOTINT*-1,TOTLOANAMT*-1,TOTLOANINT*-1,WASH_ALW*-1 from PISPAYTRANSACTION  where companycode = '0001'  and DIVISIONCODE = '002' /*and  UNITCODE = '002' and  DEPARTMENTCODE = '10' and  CATEGORYCODE = '01' and  GRADECODE  = '01' and YEARMONTH = '202006'*/ and TRANSACTIONTYPE = 'SALARY' and WORKERSERIAL = '000110'  
                            ) )
                            

select ATN_ALW,ATN_INCTV,ATTN_CUMD,ATTN_FDAY,ATTN_HOLD,ATTN_WOFD,ATTN_WOHD,BASIC,
BASIC_RT,CANTEEN,CHILD_ALLW,CHRG_HAND,CLEAN_ALW,CONV_ALLW,CONV_ALW,EDU_ALW,ESI_C,
ESI_E,ESI_GROSS,FIX_ALW,FPF,FSTL_DED,FSTL_EARN,GELESI,GROSSDEDN,GROSSEARN,GR_ESI_OTH,
HRA,HRA_GROSS,HRA_PER,HRA_RT,INCENTIVE,INSP_ALW,ITAX,LCUM_CL,LCUM_PL,LGBK_ALW,LIBL_EDLN,
LIBL_EDU,LIBL_HBLDG,LIBL_HBLN,LIBL_MDLN,LIBL_MGLN,LIBL_MRG,LIBL_OTLN,LIBL_PF,LIBL_PRLN,
LIBL_SADV,LIBL_VCLN,LINT_EDLN,LINT_EDU,LINT_HBLDG,LINT_HBLN,LINT_MDLN,LINT_MGLN,LINT_MRG,
LINT_OTLN,LINT_PF,LINT_PRLN,LINT_SADV,LINT_VCLN,LNBL_EDLN,LNBL_EDU,LNBL_HBLDG,LNBL_HBLN,
LNBL_MDLN,LNBL_MGLN,LNBL_MRG,LNBL_OTLN,LNBL_PF,LNBL_PRLN,LNBL_SADV,LNBL_VCLN,LOAN_EDLN,
LOAN_EDU,LOAN_HBLDG,LOAN_HBLN,LOAN_MDLN,LOAN_MGLN,LOAN_MRG,LOAN_OTLN,LOAN_PF,LOAN_PRLN,
LOAN_SADV,LOAN_VCLN,LOP,LTA,LVBL_CL,LVBL_PL,LVBL_SL,MEDICAL,MISC_BF,MISC_CF,MISC_DEDN,
NETSALARY,OTH_ALLW,OTH_ALLW2,PEN_GROSS,PERF_ALW,PERS_ALLW,PF_C,PF_E,PF_GROSS,PTAX,
PTAX_GROSS,PUNC_ALW,SALRATE,SAL_SAVING,SARR_ARRD,SARR_ARRE,SERV_ALLW,SHIFTA_HRS,
SHIFTB_HRS,SHIFTC_HRS,SHIFT_A,SHIFT_ALW,SHIFT_B,SHIFT_C,SOFT_ALLW,TOTALDED,
TOTEARN,TOTINT,TOTLOANAMT,TOTLOANINT,WASH_ALW 
from PISARREARTRANSACTION where companycode = '0001'  
and YEARMONTH = '202006'
and DIVISIONCODE = '002' /*and  UNITCODE = '002' and  DEPARTMENTCODE = '10' and  CATEGORYCODE = '01' and  GRADECODE  = '01' and YEARMONTH = '202006'*/ 
and TRANSACTIONTYPE = 'NEW SALARY' and WORKERSERIAL = '000110' 

union all
select ATN_ALW*-1,ATN_INCTV*-1,ATTN_CUMD*-1,ATTN_FDAY*-1,ATTN_HOLD*-1,ATTN_WOFD*-1,ATTN_WOHD*-1,BASIC*-1,
BASIC_RT*-1,CANTEEN*-1,CHILD_ALLW*-1,CHRG_HAND*-1,CLEAN_ALW*-1,CONV_ALLW*-1,CONV_ALW*-1,EDU_ALW*-1,ESI_C*-1,
ESI_E*-1,ESI_GROSS*-1,FIX_ALW*-1,FPF*-1,FSTL_DED*-1,FSTL_EARN*-1,GELESI*-1,GROSSDEDN*-1,GROSSEARN*-1,GR_ESI_OTH*-1,
HRA*-1,HRA_GROSS*-1,HRA_PER*-1,HRA_RT*-1,INCENTIVE*-1,INSP_ALW*-1,ITAX*-1,LCUM_CL*-1,LCUM_PL*-1,LGBK_ALW*-1,
LIBL_EDLN*-1,LIBL_EDU*-1,LIBL_HBLDG*-1,LIBL_HBLN*-1,LIBL_MDLN*-1,LIBL_MGLN*-1,LIBL_MRG*-1,LIBL_OTLN*-1,
LIBL_PF*-1,LIBL_PRLN*-1,LIBL_SADV*-1,LIBL_VCLN*-1,LINT_EDLN*-1,LINT_EDU*-1,LINT_HBLDG*-1,LINT_HBLN*-1,
LINT_MDLN*-1,LINT_MGLN*-1,LINT_MRG*-1,LINT_OTLN*-1,LINT_PF*-1,LINT_PRLN*-1,LINT_SADV*-1,LINT_VCLN*-1,
LNBL_EDLN*-1,LNBL_EDU*-1,LNBL_HBLDG*-1,LNBL_HBLN*-1,LNBL_MDLN*-1,LNBL_MGLN*-1,LNBL_MRG*-1,LNBL_OTLN*-1,
LNBL_PF*-1,LNBL_PRLN*-1,LNBL_SADV*-1,LNBL_VCLN*-1,LOAN_EDLN*-1,LOAN_EDU*-1,LOAN_HBLDG*-1,LOAN_HBLN*-1,
LOAN_MDLN*-1,LOAN_MGLN*-1,LOAN_MRG*-1,LOAN_OTLN*-1,LOAN_PF*-1,LOAN_PRLN*-1,LOAN_SADV*-1,LOAN_VCLN*-1,
LOP*-1,LTA*-1,LVBL_CL*-1,LVBL_PL*-1,LVBL_SL*-1,MEDICAL*-1,MISC_BF*-1,MISC_CF*-1,MISC_DEDN*-1,
NETSALARY*-1,OTH_ALLW*-1,OTH_ALLW2*-1,PEN_GROSS*-1,PERF_ALW*-1,PERS_ALLW*-1,PF_C*-1,PF_E*-1,
PF_GROSS*-1,PTAX*-1,PTAX_GROSS*-1,PUNC_ALW*-1,SALRATE*-1,SAL_SAVING*-1,SARR_ARRD*-1,SARR_ARRE*-1,SERV_ALLW*-1,
SHIFTA_HRS*-1,SHIFTB_HRS*-1,SHIFTC_HRS*-1,SHIFT_A*-1,SHIFT_ALW*-1,SHIFT_B*-1,SHIFT_C*-1,SOFT_ALLW*-1,
TOTALDED*-1,TOTEARN*-1,TOTINT*-1,TOTLOANAMT*-1,TOTLOANINT*-1,WASH_ALW*-1 
from PISPAYTRANSACTION  where companycode = '0001'  
and DIVISIONCODE = '002' /*and  UNITCODE = '002' and  DEPARTMENTCODE = '10' and  CATEGORYCODE = '01' and  GRADECODE  = '01'*/  
and YEARMONTH = '202006'
and TRANSACTIONTYPE = 'SALARY' and WORKERSERIAL = '000110'  

                          
                            
INSERT INTO PISARREARTRANSACTION (COMPANYCODE, DIVISIONCODE, YEARCODE, UNITCODE, DEPARTMENTCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO , YEARMONTH, EFFECT_YEARMONTH,TRANSACTIONTYPE ,GROSSEARN , 
INSP_ALW , 
ESI_C , 
ATN_ALW , 
ATTN_WOHD , 
HRA_GROSS , 
CLEAN_ALW , 
HRA_PER , 
SHIFTB_HRS , 
SARR_ARRD , 
LGBK_ALW , 
CHRG_HAND , 
BASIC_RT , 
ATTN_FDAY , 
PF_E , 
SHIFT_ALW , 
SARR_ARRE , 
PF_GROSS , 
LOP , 
WASH_ALW , 
SHIFTC_HRS , 
GELESI , 
ESI_GROSS , 
HRA , 
FPF , 
ATN_INCTV , 
ATTN_CUMD , 
PEN_GROSS , 
PTAX_GROSS , 
SHIFTA_HRS , 
CONV_ALW , 
ATTN_HOLD , 
ATTN_WOFD , 
GR_ESI_OTH , 
PUNC_ALW , 
PF_C , 
BASIC , 
EDU_ALW , 
ESI_E , 
PERF_ALW  
,NETSALARY,GROSSDEDN) VALUES ( '0001','002','2020-2021','002','10','01','01','000110','0004','202007','202007','ARREAR' , '-40413','-1500','0','0','','-14190','0','-75','0','','-900','-9000','-14190','','-10326','0','','-14076','-180','-900','0','','-40413','-3552','-1179','-3000','','-14076','-40413','','-3000','0','','','-900','-9147','-14076','-2250','-1440','-1335','-28647' ,'-11766' )
