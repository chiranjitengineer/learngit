SELECT * FROM WPSWORKERCATEGORYMAST

SELECT * FROM WPSWORKERCATEGORYMAST@CJIL_DBLINK

SELECT * FROM WPSWORKERCATEGORYMAST@CJIL_DBLINK

SELECT * FROM TAB
WHERE TNAME LIKE 'WPS%OCCU%'

WPSOCCUPATIONMAST 

SELECT * FROM COLS@CJIL_DBLINK
WHERE TABLE_NAME LIKE '%WPSWORKERCATEGORYMAST%'


SELECT * FROM COLS@CJIL_DBLINK
WHERE TABLE_NAME LIKE 'WPSWORKERCATEGORYMAST'

--------------------------------------------------------------------------------


SELECT COMPANYCODE, DIVISIONCODE, WORKERCATEGORYCODE, WORKERCATEGORYNAME, DA, ALLOWANCERATE, ACTALLOWANCERATE, FBKRATE, ROUNDOFF, 
ATTENTYPE, PREFIX, DAILYRATEBASEDWAGES, DEPARTMENTWISEPROCESS, TOKENPRINT, LABOURPRINT, NAMEFATHERNAMEPRINT, STATUTORYAPPLY, 
VARIABLEBASIC, CATEGORYINDEX, STLRATE, NOOFMEMOGENERATE, MINIMUMSHOWCAUSEWORKDAY, MINIMUMMEMO1WORKDAY, MINIMUMMEMO2WORKDAY, 
MINIMUMMEMOFINALWORKDAY,NULL MEMOGENERAT,NULL MEMOGENERATE, 'SWT' USERNAME, SYSDATE LASTMODIFIED, SYS_GUID() SYSROWID, 'Y' PRINTSLIP, DECODE (STATUTORYAPPLY,'Y','Y','N') STLAPPLICABLE, 
'Y' CALC_CUMULATIVEWORKDAYS, 'Y' BONUSAPPLICABLE, 240 STL_ELIGIBLE_WORKDAYS, 'Y' ISWAGESPROCESS
FROM WPSWORKERCATEGORYMAST

--------------------------------------------------------------------------------
--WPSWORKERCATEGORYMAST INSERT
--------------------------------------------------------------------------------

INSERT INTO WPSWORKERCATEGORYMAST
(
    COMPANYCODE, DIVISIONCODE, WORKERCATEGORYCODE, WORKERCATEGORYNAME, DA, ALLOWANCERATE, 
    ACTALLOWANCERATE, FBKRATE, ROUNDOFF, ATTENTYPE, PREFIX, DAILYRATEBASEDWAGES, DEPARTMENTWISEPROCESS, 
    TOKENPRINT, LABOURPRINT, NAMEFATHERNAMEPRINT, STATUTORYAPPLY, VARIABLEBASIC, CATEGORYINDEX, STLRATE, 
    NOOFMEMOGENERATE, MINIMUMSHOWCAUSEWORKDAY, MINIMUMMEMO1WORKDAY, MINIMUMMEMO2WORKDAY, MINIMUMMEMOFINALWORKDAY, 
    MEMOGENERAT, MEMOGENERATE, USERNAME, LASTMODIFIED, SYSROWID, PRINTSLIP, STLAPPLICABLE, 
    CALC_CUMULATIVEWORKDAYS, BONUSAPPLICABLE, STL_ELIGIBLE_WORKDAYS, ISWAGESPROCESS, CATEGORYGROUP
)
SELECT COMPANYCODE, DIVISIONCODE, WORKERCATEGORYCODE, WORKERCATEGORYNAME, DA, ALLOWANCERATE, ACTALLOWANCERATE, FBKRATE, ROUNDOFF, 
ATTENTYPE, PREFIX, DAILYRATEBASEDWAGES, DEPARTMENTWISEPROCESS, TOKENPRINT, LABOURPRINT, NAMEFATHERNAMEPRINT, STATUTORYAPPLY, 
VARIABLEBASIC, CATEGORYINDEX,NULL  STLRATE,NULL  NOOFMEMOGENERATE,NULL  MINIMUMSHOWCAUSEWORKDAY,NULL  MINIMUMMEMO1WORKDAY,NULL  MINIMUMMEMO2WORKDAY, 
NULL MINIMUMMEMOFINALWORKDAY,NULL MEMOGENERAT,NULL MEMOGENERATE, 'SWT' USERNAME, SYSDATE LASTMODIFIED, SYS_GUID() SYSROWID, 'Y' PRINTSLIP, DECODE (STATUTORYAPPLY,'Y','Y','N') STLAPPLICABLE, 
'Y' CALC_CUMULATIVEWORKDAYS, 'Y' BONUSAPPLICABLE, 240 STL_ELIGIBLE_WORKDAYS, 'Y' ISWAGESPROCESS,NULL CATEGORYGROUP
FROM WPSWORKERCATEGORYMAST@CJIL_DBLINK

SELECT * FROM WPSWORKERCATEGORYMAST



--------------------------------------------------------------------------------
--WPS DEPARTMENT MASTER
--------------------------------------------------------------------------------

INSERT INTO WPSDEPARTMENTMASTER (
COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, DEPARTMENTNAME, DEPARTMENTTYPE, NSAAPPLICABLE, ISMACHINEDEPENDENT, PRINTABLEDEPARTMENTCODE, 
DEPTGROUPCODE, FIXEDHANDS, USERNAME, LASTMODIFIED, SYSROWID)
SELECT COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, DEPARTMENTNAME, DEPARTMENTTYPE,NULL NSAAPPLICABLE, ISMACHINEDEPENDENT,NULL PRINTABLEDEPARTMENTCODE, 
DEPARTMENTCODE DEPTGROUPCODE,NULL FIXEDHANDS, 'SWT' USERNAME, SYSDATE LASTMODIFIED, SYS_GUID() SYSROWID
FROM WPSDEPARTMENTMAST@CJIL_DBLINK

SELECT * FROM WPSDEPARTMENTMASTER

 
--------------------------------------------------------------------------------
---- SECTION MASTER ------- NOT FOUND
INSERT INTO WPSSECTIONMAST (
COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, SECTIONCODE, SECTIONNAME, USERNAME, LASTMODIFIED, SYSROWID, GRADERATE, 
INCREMENTRATE, LISTINDEX, ATTN_GRID_TAG, VB_PROCNAME, IB_PROCNAME, WORKTYPECODE, VB_PERCENTAGE, IB_PERCENTAGE, 
DEPENDANTSECTIONCODE, DEFAULTSECTION,DEPTSECTIONCODE)
SELECT COMPANYCODE, DIVISIONCODE,SUBSTR(DEPARTMENTCODE,1,2) DEPARTMENTCODE,SUBSTR(DEPARTMENTCODE,4) SECTIONCODE,DEPARTMENTNAME ||'_SEC_'||SUBSTR(DEPARTMENTCODE,4) SECTIONNAME, 
'SWT' USERNAME, SYSDATE LASTMODIFIED, SYS_GUID() SYSROWID,NULL GRADERATE, 
0 INCREMENTRATE, ROWNUM LISTINDEX, 'GENERAL' ATTN_GRID_TAG, NULL VB_PROCNAME, NULL IB_PROCNAME, 'T' WORKTYPECODE, 0 VB_PERCENTAGE, 0 IB_PERCENTAGE, 
NULL DEPENDANTSECTIONCODE, NULL DEFAULTSECTION,DEPARTMENTCODE DEPTSECTIONCODE
FROM WPSDEPARTMENTMASTER
WHERE DEPARTMENTCODE IS NOT  NULL

SELECT * FROM 
WPSSECTIONMAST WERDsDdFDSASDSA




--------------------------------------------------------------------------------
--WPS OCCUPATION MASTER
--------------------------------------------------------------------------------


SELECT OCCUPATIONCODE, DEPARTMENTCODE, WORKERTYPECODE, OCCUPATIONNAME,NULL IBCALCONMCWISEPROD, 
LASTMODIFIED, COMPANYCODE, DIVISIONCODE, OCCUPATIONTYPE, RATE, MACHINEMANDETORY, 
MAINSARDER,NULL LISTINDEX, MAINSARDERVBRATE,NULL ALLOWVARIABLEBASICHOURLYRATE,NULL VBIBCALCONTKNWISEPROD, 
NULL TIMERATEDIBRATE,NULL OCCUPATIONCODEFORPLW, PLWCALCULATIONBASEDON,NULL DEPARTMENTCODEFORPLW, 
NULL DEFAULT_OCCU,NULL RATIOTYPE,NULL RATIO,NULL FIXEDVALUE 
FROM WPSOCCUPATIONMAST


INSERT INTO WPSOCCUPATIONMAST

SELECT XX, COUNT(XX) FROM(
SELECT COMPANYCODE||'-'||DIVISIONCODE||'-'||DEPARTMENTCODE||'-'||SECTIONCODE||'-'||OCCUPATIONCODE XX FROM (


SELECT COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE,DEPARTMENTCODE SECTIONCODE, OCCUPATIONCODE, OCCUPATIONNAME, 
OCCUPATIONTYPE, WORKERTYPECODE, MACHINEMANDETORY, RATE, MAINSARDER, MAINSARDERVBRATE, 
PLWCALCULATIONBASEDON,NULL  ACTIVE,'SWT'  USERNAME, LASTMODIFIED,SYS_GUID()  SYSROWID,NULL  DEPTOCCPCODE, 
NULL VB_PROCNAME,NULL  IB_PROCNAME,NULL  VB_PERCENTAGE,NULL  IB_PERCENTAGE,NULL  VB_DEPENDENT_DEPTOCCPCODE, 
NULL IB_DEPENDENT_DEPTOCCPCODE,NULL  VBRATE,NULL  IBCALCULATIONINDEX,NULL  STANDARDHANDSHIFT1, 
NULL STANDARDHANDSHIFT2,NULL  STANDARDHANDSHIFT3,NULL  DEFAULTOCCUPATION,NULL FITMENTRATE,NULL LINENOAPPLICABLE
FROM WPSOCCUPATIONMAST@CJIL_DBLINK
WHERE COMPANYCODE IS NOT NULL


)
)
GROUP BY XX
HAVING COUNT(XX) > 1

WPSOCCUPATIONMAST_U01


--------------------------------------------------------------------------------

SELECT 

SELECT COMPANYCODE, DIVISIONCODE, OLDTYPECODE, OLD_TOKENNO, WORKERSERIAL, WORKERCODE, LBNO, 
WORKERCATEGORYCODE, WORKERNAME, DESIGNATION, ADDRESS1, ADDRESS2, ADDRESS3, ADDRESS4, ADDRESS5, 
FATHERNAME, GUARDIANNAME, SEX, MARITALSTATUS, QUARTERALLOTED, DATEOFBIRTH, DATEOFJOINING, 
DATEOFRETIREMENT, ESINO, PFNO, PFLOANAMOUNT, PFLOANDATE, PFLOANNOOFEMI, PFLOANAMOUNTOFEMI, 
PFLOANREFUNDAMOUNT, PFLOANAMOUNTBALANCE, FIXEDBASIC, DAPERCENTAGE, TOTALPFCONTRIBUTION, 
TOTALGRFORBONUS, LASTMODIFIED, ACTIVE, DARATE, CARATE, PCSRATE, TOKENNO, MCODE, OTBASEDONSTANDHRS, 
ADVANCE_DEDN_EMI, AGREE_ADV_EMI, COP_DEDN, PF_LOAN_INT_EMI, QUARTER_REPAIR_REMB, SHOP_RENT_EMI, 
LICDEDN_EMI, ELEC_DUE, QTRALLOTED, DOCTORCODE, TERMINATIONDATE, TERMINATIONREASON, DEPARTMENTCODE, 
DATEOFTERMINATION, REASONOFTERMINATION, IDENTIFICATIONMARKS, GENERALREMARKS, DATEOFCARDISSUE, 
MOTHERNAME, LOCALADDRESS1, LOCALADDRESS2, LOCALADDRESS3, LOCALADDRESS4, LOCALADDRESS5, 
LOCALPOSTOFFICE, LOCALPOLICESTATION, LOCALDISTRICT, LOCALPROVINCE, EDUCATIONALQUALIFICATION, 
PROFESSIONALQUALIFICATION, HOMEPOSTOFFICE, HOMEPOLICESTATION, HOMEDISTRICT, HOMEPROVINCE, 
CANREAD, CANWRITE, RELIGION, REMARKS, REFERENCEONE, REFERENCEONE_ADDRESS, REFERENCETWO, 
REFERENCETWO_ADDRESS, HEARING, VW_GLASSES, VW_NOGLASSES, CHEST_NORMAL, CHEST_EXPAND, 
HEARTSOUNDS, PULSE, SPLEEN, LIVER, PILES, ABDOMENGIRTH, WTONE, WTTWO, NOSE, TEETH, THROAT, 
HARNIA, SKINDISEASE, GENERALDISEASE, OTHERDISEASE, HEARTSOUND, WORKERSOUSENAME, ADHOCRATE, 
BANKACNO, LASTMEDICALTEST, PENSIONNO, PFMEMBERSHIPDATE, DATEOFRETIREMENTEXTENSION, 
DATEOFLASTINCREMENT, DATEOFTERMINATIONADVICE, ESISUBMISSIONPLACECODE, TOTALBASIC, 
PFLOANTYPECODE, TOTALPFCOMPANYCONTRIBUTION, TOTALFPFCONTRIBUTION, COOPERATIVEMEMBERNO, 
COOPERATIVELOANAMOUNTBALANCE, COOPERATIVELOANINSTALLMENTLEFT, COOPERATIVENEXTLOANELIGIBLITY, 
NOOFSHARES, SPECIALADVNOOFEMI, SPECIALADVBALANCE, SPECIALADVINSTALLMENTLEFT, 
COOPERATIVELOANNOOFEMI, ADVANCEWFDEDUCTION, YTDRFGROSS, TEMPORARYLOANCONTTODATE, 
RFTODATE, DELTODATE, COOPERATIVELOANTYPECODE, WORKERSDEFAULTFOLDER, SRLNO, 
WORKERPICTUREPATH, TOTALOPENINGPFCONTRIBUTION, RETAINER, WORKERHISTRY, UPDATETAG, 
GRADECODE, ATM, QUARTERNO, FIXEDBASIC_PIECERT, ANG_FBASIC, ANG_DARATE, ANG_CARATE, 
ISPLWCONSIDER, GCODE, NEWWORKERSERIAL, DEPARTMENTWISEDEDUCTION, EPFAPPLICABLE, 
PFAPPLICABLE, PTAXAPPLICABLE, ESIAPPLICABLE, ESIADDINGROSS, GROUPCODE, EMP_NO, 
OCCUPATIONCODE, PFSETTLEMENTDATE, STOPDEDUCTIONONSTL, STL_DAY, CJIFULLPAID, WORKERNAMEESI, 
ESIAPPLICABLE_TEMP,NULL CONSIDER_ESIRC,NULL PARENTSHIFT,NULL INPUTSHEETSERIAL, TAB_IMAGENAME, 
DAYOFFDAY,NULL ADHARNO,NULL BANKIFSCCODE, EMAIL,NULL PANNO, UANNO,NULL WORKERBANKNAME,NULL ATN_INCENTIVE,NULL PRINTPAYSLIP 
FROM WPSWORKERMAST


INSERT INTO WPSWORKERMAST
--
SELECT
COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO,NULL  ATTNIDENTIFICATION, WORKERNAME, NVL(DEPARTMENTCODE,'NA'), 
NULL SECTIONCODE, NVL(WORKERCATEGORYCODE,'NA'), GROUPCODE, NVL(OCCUPATIONCODE,'NA'), DESIGNATION, NVL(ACTIVE,'N'), NULL TAKEPARTINWAGES, 
WORKERCODE, MCODE, SRLNO, GRADECODE, DAYOFFDAY,NULL  PFCATEGORY, ADDRESS1, ADDRESS2, ADDRESS3, ADDRESS4, 
ADDRESS5, FATHERNAME, MOTHERNAME, GUARDIANNAME, WORKERSOUSENAME, TRIM(SEX), TRIM(MARITALSTATUS),TRIM(QUARTERALLOTED), 
NULL HRAAPPLICABLE, PFAPPLICABLE, EPFAPPLICABLE, DATEOFBIRTH, DATEOFJOINING, DATEOFRETIREMENT, ESINO, 
PFNO, PENSIONNO, PFMEMBERSHIPDATE, FIXEDBASIC,NULL  FIXEDBASIC_PEICERT, DARATE,NULL  INCREMENTAMOUNT, CARATE, 
ADHOCRATE,NULL  SPL_ALLOW_RATE,NULL  PPRATE, COP_DEDN, ELEC_DUE, DOCTORCODE, TERMINATIONDATE, TERMINATIONREASON, 
DATEOFTERMINATION, REASONOFTERMINATION, IDENTIFICATIONMARKS, GENERALREMARKS, DATEOFCARDISSUE, 
LOCALADDRESS1, LOCALADDRESS2, LOCALADDRESS3, LOCALADDRESS4, LOCALADDRESS5, LOCALPOSTOFFICE, 
LOCALPOLICESTATION, LOCALDISTRICT, LOCALPROVINCE, EDUCATIONALQUALIFICATION, PROFESSIONALQUALIFICATION, 
HOMEPOSTOFFICE, HOMEPOLICESTATION, HOMEDISTRICT, HOMEPROVINCE, CANREAD, CANWRITE, RELIGION, REMARKS, 
REFERENCEONE, REFERENCEONE_ADDRESS, REFERENCETWO, REFERENCETWO_ADDRESS, HEARING, VW_GLASSES, 
VW_NOGLASSES, CHEST_NORMAL, CHEST_EXPAND, HEARTSOUNDS, PULSE, SPLEEN, LIVER, PILES, ABDOMENGIRTH, 
WTONE, WTTWO, NOSE, TEETH, THROAT, HARNIA, SKINDISEASE, GENERALDISEASE, OTHERDISEASE, HEARTSOUND, 
BANKACNO, LASTMEDICALTEST, DATEOFRETIREMENTEXTENSION, DATEOFLASTINCREMENT, DATEOFTERMINATIONADVICE, 
ESISUBMISSIONPLACECODE, COOPERATIVEMEMBERNO, NOOFSHARES, WORKERSDEFAULTFOLDER, WORKERPICTUREPATH, 
RETAINER, WORKERHISTRY, UPDATETAG, QUARTERNO, PTAXAPPLICABLE, ESIAPPLICABLE,NULL  WELFAREAPPLICABLE, 
NULL BLOCK_DATE,NULL  UNBLOCK_DATE,NULL  BLOCKREMARKS,NULL  DLIAPPLICABLE,NULL  SHIFT,NULL  PRINTABLESERIAL,NULL  PROMOTIONDATE, 
NULL MOBILENO,NULL  LOCALPHONE,NULL  HOMEPHONE,NULL  ESIJOININGDATE,NULL  NOOFINCREMENT,NULL  SHIFTBASEDON,NULL  NOMINEENAME, 
NULL NOMINEERELATION,NULL  PFSETTELMENTDATE,NULL  GRATUITYOPENINGYEARS,NULL  VPFPERCENT,NULL PRINTINATTNSHEET, 
NULL IDENTIFIEDCODE,NULL WORKERSTATUS,NULL STATUSDATE,NULL GRATUITYAPPLICABLE,NULL GRATUITYSETTELMENTDATE, 
TAB_IMAGENAME,NULL DEPTWORKERCODE,NULL BONUSAPPLICABLE,'SWT' USERNAME, LASTMODIFIED,SYS_GUID() SYSROWID,'WPS' MODULE, 
NULL UNITCODE,NULL  OCCUPATIONCODE_OLD,NULL  ADDLBASIC_RATE,NULL  BANKCODE,NULL  PAYMODE, UANNO, PANNO,NULL  ADHARNO, 
NULL CONTRACTORCODE,NULL  CONTRACTORNAME,NULL  LASTCOMPANYNAME,NULL INCREMENTOPENING,NULL  DAILYBASICRATE,WORKERBANKNAME  WORKERNAME_BANK, 
NULL INSURANCEAPPLICABLE,NULL  SHOP_RENT,NULL  INSURANCE_POLICYNO,NULL  INSURANCEAMOUNT,NULL  ADHARLINKDATE,NULL  HOMESTATE, 
NULL LOCALSTATE,NULL  BANKBRANCH,NULL  IMAGEURL,NULL  WORKTYPECODE,NULL  NATIONALITY,NULL  HEIGHT,NULL WEIGHTINKG,NULL SUPERANNUATIONDATE, 
NULL GRATUITYSETTLEMENTDATE, EMAIL,NULL GRATUITYPAYMENTDATE,NULL STATUSCHANGEDATE,NULL GRATUITYJOINDATE
FROM WPSWORKERMAST@CJIL_DBLINK
WHERE COMPANYCODE IS NOT NULL

SELECT * FROM WPSWORKERMAST

--------------------------------------------------------------------------------



SELECT * FROM MACHINEMASTER


SELECT * FROM WPSMACHINEGROUPMAST




SELECT COMPANYCODE,
   DIVISIONCODE,
   PRODUCTIONTYPE,
   DEPARTMENTCODE,
   MACHINECODE,
   MACHINENAME,
   LOOMYESNO,
   PARTNERLOOMCODE,
   PAIRLOOMCODE,
   MACHINETYPECODE,
   MACHINEGROUP,
   ACTUALRPM,
   MACHINEREEDSPACE,
   MAXWIDTH,
   DIVISIONFACTOR,
   MODULE,
   LASTMODIFIED,
   SYSROWID,
   USERNAME,
   PIC_A,
   PIC_B,
   PIC_C 
   FROM MACHINEMASTER





--------------------------------------------------------------------------------

INSERT INTO MACHINEMASTER
(
COMPANYCODE, DIVISIONCODE, PRODUCTIONTYPE, DEPARTMENTCODE, MACHINECODE, MACHINENAME, LOOMYESNO, PARTNERLOOMCODE, 
PAIRLOOMCODE, MACHINETYPECODE, MACHINEGROUP, ACTUALRPM, MACHINEREEDSPACE, MAXWIDTH, DIVISIONFACTOR, MODULE, 
LASTMODIFIED, SYSROWID, USERNAME, PIC_A, PIC_B, PIC_C, ROLLYESNO
)
SELECT * FROM MC_MAST

--

CREATE TABLE MC_MAST AS 

SELECT XX,COUNT(*) FROM(
SELECT  COMPANYCODE||'~'||DIVISIONCODE||'~'||DEPARTMENTCODE||'~'||MACHINECODE XX fROM MC_MAST
)
GROUP BY XX
HAVING COUNT(XX) > 1



SELECT * FROM MC_MAST

WHERE COMPANYCODE||'~'||DIVISIONCODE||'~'||DEPARTMENTCODE||'~'||MACHINECODE ='CJ0001~0002~22/01~336'


select DISTINCT COMPANYCODE, DIVISIONCODE, 'P0003' PRODUCTIONTYPE, DEPARTMENTCODE, MACHINECODE, MACHINENAME, LOOMYESNO, PARTNERLOOMCODE,
'NA' PAIRLOOMCODE,'NA' MACHINETYPECODE, 'H' MACHINEGROUP, 0 ACTUALRPM, MACHINEREEDSPACE,0 MAXWIDTH,0 DIVISIONFACTOR, 'WPS' MODULE, 
SYSDATE LASTMODIFIED, SYS_GUID() SYSROWID, 'SWT' USERNAME, 
0 PIC_A, 0 PIC_B, 0 PIC_C, 'N' ROLLYESNO
from WPSMACHINEMASTER@CJIL_DBLINK



CJIL_WEB.MACHINEMASTER_U01



--------------------------------------------------------------------------------


INSERT INTO WPSQUALITYMASTER
SELECT
COMPANYCODE, DIVISIONCODE, PRODUCTIONTYPE, QUALITYCODE, QUALITYNAME, QUALITYTYPECODE, QUALITYUOMCODE, 
QUALITYUOMCODE2, QUALITYUOMDESC, QUALITYUOMDESC2, CONVERSIONFACTOR,NULL FINISHTYPE, PORTER, SHOTS,NULL  ACTUALSHOTS, 
NULL SHORTNAME, OZ,NULL  BASEOZ,NULL  OZTYPE, WIDTH,NULL  FINISHEDLENGTH,NULL  LAIDLENGTH,NULL  SPEED,NULL  CHATTAK,NULL  YARDPRECUT, 
NULL SELVEDGE,NULL  WARPMARK,NULL  WARPGRIST,NULL  WEFTMARK,NULL  WEFTGRIST, WEIGHTSPECIFICATION,NULL  TARGETPRODUCTION, 
NULL TARGETEFFICIENCYPERCENT,NULL  ISTIMERATEQUALITY,NULL  GSM,NULL  MAXWIDTH,NULL  ACTPICMETER,SYSDATE LASTMODIFIED,
'SWT' USERNAME,SYS_GUID() SYSROWID,'WPS' MODULE
FROM WPSQUALITYMASTER@CJIL_DBLINK


--------------------------------------------------------------------------------
SELECT *
FROM   QUALITYMASTER
    WHERE   MODULE LIKE '%WPS%';

--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------



--------------------------------------------------------------------------------