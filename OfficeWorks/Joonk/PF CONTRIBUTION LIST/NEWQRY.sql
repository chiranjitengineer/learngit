PROC_PFCONTRIBUTION_PERIODWISE('DY0080','0002','01/04/2020','30/04/2020','','','')


SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%party%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE='010306030203'

SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG='PARTY BILL SUMMARY'


SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE=''

SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''



SET DEFINE OFF;
Insert into REPORTPARAMETERMASTER
   (MODULENAME, REPORTTAG, REPORTTAG1, REPORTTAG2, REPORTTAG3, MAINTABLE, SUBREPORTTABLE, SUBREPORTTABLE1, SUBREPORTTABLE2, SUBREPORTTABLE3, SUBREPORTTABLE4, REPORTNAME, REFNO)
 Values
   ('GPS', 'PF CONTRIBUTION LIST PERIODICALLY', 'PROC_PFCONTRIBUTION_PERIODWISE', NULL, NULL, 
    'GTT_PFCONTRIBUTION_NEW', NULL, NULL, NULL, NULL, 
    NULL, 'GPS/PAGES/Report/Transaction/rpt_PFCONTRIBUTION_new.rdlc', NULL);
COMMIT;
