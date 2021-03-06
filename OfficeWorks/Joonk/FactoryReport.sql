INSERT INTO GTT_FACTORYREPORT(MAINDES,DES,PERIOD,TODATE,LPERIOD,LTODATE) 
SELECT MAINDES,  DES,SUM (PERIOD) PERIOD, SUM (TODATE) TODATE, SUM (LPERIOD), SUM (LTODATE)
FROM   
(
    SELECT   '001. GREEN LEAF RECEIVED' MAINDES,'a.OWN' DES,NVL (SUM (TOTALWT), 0) PERIOD,0 TODATE,0 LPERIOD,0 LTODATE
    FROM PRODDAILYGRNLEAFPLKINGDETAILS
    WHERE DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND LEAFTYPE = 'OWN'
    AND PLUCKDATE >= TO_DATE('31/07/2020','dd/MM/yyyy')
    AND PLUCKDATE <= TO_DATE ('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT '001. GREEN LEAF RECEIVED' MAINDES,'a.OWN' DES,0 PERIOD,NVL (SUM (TOTALWT), 0) TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODDAILYGRNLEAFPLKINGDETAILS
    WHERE   DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND LEAFTYPE = 'OWN'
    AND PLUCKDATE >= TO_DATE('01/04/2020','dd/MM/yyyy')
    AND PLUCKDATE <= TO_DATE('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '001. GREEN LEAF RECEIVED' MAINDES,'a.OWN' DES,0 PERIOD,0 TODATE,NVL (SUM (TOTALWT), 0) LPERIOD,0 LTODATE
    FROM   PRODDAILYGRNLEAFPLKINGDETAILS
    WHERE  DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND LEAFTYPE = 'OWN'
    AND PLUCKDATE >= TO_DATE('31/07/2019','dd/MM/yyyy')
    AND PLUCKDATE <= TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '001. GREEN LEAF RECEIVED' MAINDES,'a.OWN' DES,0 PERIOD,0 TODATE,0 LPERIOD,NVL (SUM (TOTALWT), 0) LTODATE
    FROM   PRODDAILYGRNLEAFPLKINGDETAILS
    WHERE  DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND LEAFTYPE = 'OWN'
    AND PLUCKDATE >= TO_DATE('01/04/2019','dd/MM/yyyy')
    AND PLUCKDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '001. GREEN LEAF RECEIVED' MAINDES,'b.BOUGHT' DES,NVL (SUM (ACCEPTEDQUANTITY), 0) PERIOD,0 TODATE,0 LPERIOD,0 LTODATE
    FROM   GREENLEAFRECEIPTNOTE
    WHERE   DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTDATE >=TO_DATE('31/07/2020','dd/MM/yyyy')
    AND RECEIPTDATE <= TO_DATE ('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '001. GREEN LEAF RECEIVED' MAINDES,'b.BOUGHT' DES,0 PERIOD,NVL (SUM (ACCEPTEDQUANTITY), 0) TODATE,0 LPERIOD,0 LTODATE
    FROM   GREENLEAFRECEIPTNOTE
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTDATE >= TO_DATE('01/04/2020','dd/MM/yyyy')
    AND RECEIPTDATE <= TO_DATE('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '001. GREEN LEAF RECEIVED' MAINDES,'b.BOUGHT' DES,0 PERIOD,0 TODATE,NVL (SUM (ACCEPTEDQUANTITY), 0) LPERIOD,0 LTODATE
    FROM   GREENLEAFRECEIPTNOTE
    WHERE  DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTDATE >= TO_DATE('31/07/2019','dd/MM/yyyy')
    AND RECEIPTDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '001. GREEN LEAF RECEIVED' MAINDES,'b.BOUGHT' DES,0 PERIOD,0 TODATE,0 LPERIOD,NVL (SUM (ACCEPTEDQUANTITY), 0) LTODATE
    FROM   GREENLEAFRECEIPTNOTE
    WHERE DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTDATE >= TO_DATE('01/04/2019','dd/MM/yyyy')
    AND RECEIPTDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '001. GREEN LEAF RECEIVED' MAINDES,'c.TRANSFER IN' DES,NVL (SUM (TOTALWT), 0) PERIOD,0 TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODDAILYGRNLEAFPLKINGDETAILS
    WHERE  DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND LEAFTYPE = 'TRANSFER IN'
    AND PLUCKDATE >= TO_DATE('31/07/2020','dd/MM/yyyy')
    AND PLUCKDATE <= TO_DATE ('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '001. GREEN LEAF RECEIVED' MAINDES,'c.TRANSFER IN' DES,0 PERIOD,NVL (SUM (TOTALWT), 0) TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODDAILYGRNLEAFPLKINGDETAILS
    WHERE  DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND LEAFTYPE = 'TRANSFER IN'
    AND PLUCKDATE >= TO_DATE('01/04/2020','dd/MM/yyyy')
    AND PLUCKDATE <= TO_DATE('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '001. GREEN LEAF RECEIVED' MAINDES,'c.TRANSFER IN' DES,0 PERIOD,0 TODATE,NVL (SUM (TOTALWT), 0) LPERIOD,0 LTODATE
    FROM   PRODDAILYGRNLEAFPLKINGDETAILS
    WHERE  DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND LEAFTYPE = 'TRANSFER IN'
    AND PLUCKDATE >=TO_DATE('31/07/2019','dd/MM/yyyy')
    AND PLUCKDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '001. GREEN LEAF RECEIVED' MAINDES,'c.TRANSFER IN' DES,0 PERIOD,0 TODATE,0 LPERIOD,NVL (SUM (TOTALWT), 0) LTODATE
    FROM   PRODDAILYGRNLEAFPLKINGDETAILS
    WHERE   DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND LEAFTYPE = 'TRANSFER IN'
    AND PLUCKDATE >= TO_DATE('01/04/2019','dd/MM/yyyy')
    AND PLUCKDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '001. GREEN LEAF RECEIVED' MAINDES,'d.TRANSFER OUT' DES,NVL (SUM (TOTALWT), 0) PERIOD,0 TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODDAILYGRNLEAFPLKINGDETAILS
    WHERE  DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND LEAFTYPE = 'TRANSFER OUT'
    AND PLUCKDATE >= TO_DATE('31/07/2020','dd/MM/yyyy')
    AND PLUCKDATE <= TO_DATE ('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '001. GREEN LEAF RECEIVED' MAINDES,'d.TRANSFER OUT' DES,0 PERIOD,NVL (SUM (TOTALWT), 0) TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODDAILYGRNLEAFPLKINGDETAILS
    WHERE  DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND LEAFTYPE = 'TRANSFER IN'
    AND PLUCKDATE >= TO_DATE('01/04/2020','dd/MM/yyyy')
    AND PLUCKDATE <= TO_DATE('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '001. GREEN LEAF RECEIVED' MAINDES,'d.TRANSFER OUT' DES,0 PERIOD,0 TODATE,NVL (SUM (TOTALWT), 0) LPERIOD,0 LTODATE
    FROM   PRODDAILYGRNLEAFPLKINGDETAILS
    WHERE  DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND LEAFTYPE = 'TRANSFER OUT'
    AND PLUCKDATE >=TO_DATE('31/07/2019','dd/MM/yyyy')
    AND PLUCKDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '001. GREEN LEAF RECEIVED' MAINDES,'d.TRANSFER OUT' DES,0 PERIOD,0 TODATE,0 LPERIOD,NVL (SUM (TOTALWT), 0) LTODATE
    FROM   PRODDAILYGRNLEAFPLKINGDETAILS
    WHERE   DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND LEAFTYPE = 'TRANSFER OUT'
    AND PLUCKDATE >= TO_DATE('01/04/2019','dd/MM/yyyy')
    AND PLUCKDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '002. GREEN LEAF CONSUMED' MAINDES,'a.OWN' DES,NVL (SUM (QUANTITYFORWITHER), 0) PERIOD,0 TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE  DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'OWN'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE ('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '002. GREEN LEAF CONSUMED' MAINDES,'a.OWN' DES,0 PERIOD,NVL (SUM (QUANTITYFORWITHER), 0) TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE  DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'OWN'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '002. GREEN LEAF CONSUMED' MAINDES,'a.OWN' DES,0 PERIOD,0 TODATE,NVL (SUM (QUANTITYFORWITHER), 0) LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE  DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'OWN'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '002. GREEN LEAF CONSUMED' MAINDES,'a.OWN' DES,0 PERIOD,0 TODATE,0 LPERIOD, NVL (SUM (QUANTITYFORWITHER), 0) LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE  DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'OWN'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '002. GREEN LEAF CONSUMED' MAINDES,'b.BOUGHT' DES,NVL (SUM (QUANTITYFORWITHER), 0) PERIOD,0 TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE  DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'BOUGHT'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE ('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '002. GREEN LEAF CONSUMED' MAINDES,'b.BOUGHT' DES,0 PERIOD,NVL (SUM (QUANTITYFORWITHER), 0) TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE  DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'BOUGHT'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '002. GREEN LEAF CONSUMED' MAINDES,'b.BOUGHT' DES,0 PERIOD,0 TODATE,NVL (SUM (QUANTITYFORWITHER), 0) LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'BOUGHT'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '002. GREEN LEAF CONSUMED' MAINDES,'b.BOUGHT' DES,0 PERIOD,0 TODATE,0 LPERIOD,NVL (SUM (QUANTITYFORWITHER), 0) LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE  DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'BOUGHT'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '002. GREEN LEAF CONSUMED' MAINDES,'c.TRANSFER IN' DES,NVL (SUM (QUANTITYFORWITHER), 0) PERIOD,0 TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE  DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'TRANSFER IN'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE ('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '002. GREEN LEAF CONSUMED' MAINDES,'c.TRANSFER IN' DES,0 PERIOD,NVL (SUM (QUANTITYFORWITHER), 0) TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE  DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'TRANSFER IN'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '002. GREEN LEAF CONSUMED' MAINDES,'c.TRANSFER IN' DES,0 PERIOD,0 TODATE,NVL (SUM (QUANTITYFORWITHER), 0) LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'TRANSFER IN'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '002. GREEN LEAF CONSUMED' MAINDES,'c.TRANSFER IN' DES,0 PERIOD,0 TODATE,0 LPERIOD,NVL (SUM (QUANTITYFORWITHER), 0) LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE  DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'TRANSFER IN'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '003. WIRHERED LEAF' MAINDES,'a.OWN' DES,NVL (SUM (WITHEREDQUANTITY), 0) PERIOD,0 TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'OWN'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE ('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '003. WIRHERED LEAF' MAINDES,'a.OWN' DES,0 PERIOD,NVL (SUM (WITHEREDQUANTITY), 0) TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE   DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'OWN'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '003. WIRHERED LEAF' MAINDES,'a.OWN' DES,0 PERIOD,0 TODATE,NVL (SUM (WITHEREDQUANTITY), 0) LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE   DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'OWN'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '003. WIRHERED LEAF' MAINDES,'a.OWN' DES,0 PERIOD,0 TODATE,0 LPERIOD,NVL (SUM (WITHEREDQUANTITY), 0) LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'OWN'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '003. WIRHERED LEAF' MAINDES,'b.BOUGHT' DES,NVL (SUM (WITHEREDQUANTITY), 0) PERIOD,0 TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE  DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'BOUGHT'
    AND PRODUCTIONDATE >=TO_DATE('31/07/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE ('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '003. WIRHERED LEAF' MAINDES,'b.BOUGHT' DES,0 PERIOD,NVL (SUM (WITHEREDQUANTITY), 0) TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'BOUGHT'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <=TO_DATE('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '003. WIRHERED LEAF' MAINDES,'b.BOUGHT' DES,0 PERIOD,0 TODATE,NVL (SUM (WITHEREDQUANTITY), 0) LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'BOUGHT'
    AND PRODUCTIONDATE >=TO_DATE('31/07/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '003. WIRHERED LEAF' MAINDES,'b.BOUGHT' DES,0 PERIOD,0 TODATE,0 LPERIOD,NVL (SUM (WITHEREDQUANTITY), 0) LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'BOUGHT'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '003. WIRHERED LEAF' MAINDES,'c.TRANSFER IN' DES,NVL (SUM (WITHEREDQUANTITY), 0) PERIOD,0 TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE  DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'TRANSFER IN'
    AND PRODUCTIONDATE >=TO_DATE('31/07/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE ('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '003. WIRHERED LEAF' MAINDES,'c.TRANSFER IN' DES,0 PERIOD,NVL (SUM (WITHEREDQUANTITY), 0) TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'TRANSFER IN'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <=TO_DATE('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '003. WIRHERED LEAF' MAINDES,'c.TRANSFER IN' DES,0 PERIOD,0 TODATE,NVL (SUM (WITHEREDQUANTITY), 0) LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'TRANSFER IN'
    AND PRODUCTIONDATE >=TO_DATE('31/07/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '003. WIRHERED LEAF' MAINDES,'c.TRANSFER IN' DES,0 PERIOD,0 TODATE,0 LPERIOD,NVL (SUM (WITHEREDQUANTITY), 0) LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'TRANSFER IN'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '004. WIRHERED LEAF %' MAINDES,'a.OWN' DES,
    ROUND(NVL (SUM (WITHEREDQUANTITY), 0) / nullif(NVL (SUM (QUANTITYFORWITHER), 0), 0) * 100,2) PERIOD,0 TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'OWN'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE ('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '004. WIRHERED LEAF %' MAINDES,'a.OWN' DES,0 PERIOD,
    ROUND(NVL (SUM (WITHEREDQUANTITY), 0) / nullif(NVL (SUM (QUANTITYFORWITHER), 0), 0) * 100,2) TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'OWN'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '004. WIRHERED LEAF %' MAINDES,'a.OWN' DES,0 PERIOD,0 TODATE,
    ROUND(NVL (SUM (WITHEREDQUANTITY), 0) / nullif(NVL (SUM (QUANTITYFORWITHER), 0), 0) * 100,2) LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'OWN'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '004. WIRHERED LEAF %' MAINDES,'a.OWN' DES,0 PERIOD,0 TODATE,0 LPERIOD,
    ROUND(NVL (SUM (WITHEREDQUANTITY), 0) / nullif(NVL (SUM (QUANTITYFORWITHER), 0), 0) * 100,2) LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'OWN'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '004. WIRHERED LEAF %' MAINDES,'b.BOUGHT' DES,
    ROUND(NVL (SUM (WITHEREDQUANTITY), 0) / nullif(NVL (SUM (QUANTITYFORWITHER), 0), 0) * 100,2) PERIOD,0 TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'BOUGHT'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE ('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '004. WIRHERED LEAF %' MAINDES,'b.BOUGHT' DES,0 PERIOD,
    ROUND(NVL (SUM (WITHEREDQUANTITY), 0) / nullif(NVL (SUM (QUANTITYFORWITHER), 0), 0) * 100,2) TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'BOUGHT'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '004. WIRHERED LEAF %' MAINDES,'b.BOUGHT' DES,0 PERIOD,0 TODATE,
    ROUND(NVL (SUM (WITHEREDQUANTITY), 0) / nullif(NVL (SUM (QUANTITYFORWITHER), 0), 0) * 100,2) LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'BOUGHT'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '004. WIRHERED LEAF %' MAINDES,'b.BOUGHT' DES,0 PERIOD,0 TODATE,0 LPERIOD,
    ROUND(NVL (SUM (WITHEREDQUANTITY), 0) / nullif(NVL (SUM (QUANTITYFORWITHER), 0), 0) * 100,2) LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'BOUGHT'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '004. WIRHERED LEAF %' MAINDES,'c.TRANSFER IN' DES,
    ROUND(NVL (SUM (WITHEREDQUANTITY), 0) / nullif(NVL (SUM (QUANTITYFORWITHER), 0), 0) * 100,2) PERIOD,0 TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'TRANSFER IN'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE ('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '004. WIRHERED LEAF %' MAINDES,'c.TRANSFER IN' DES,0 PERIOD,
    ROUND(NVL (SUM (WITHEREDQUANTITY), 0) / nullif(NVL (SUM (QUANTITYFORWITHER), 0), 0) * 100,2) TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'TRANSFER IN'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '004. WIRHERED LEAF %' MAINDES,'c.TRANSFER IN' DES,0 PERIOD,0 TODATE,
    ROUND(NVL (SUM (WITHEREDQUANTITY), 0) / nullif(NVL (SUM (QUANTITYFORWITHER), 0), 0) * 100,2) LPERIOD,0 LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'TRANSFER IN'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '004. WIRHERED LEAF %' MAINDES,'c.TRANSFER IN' DES,0 PERIOD,0 TODATE,0 LPERIOD,
    ROUND(NVL (SUM (WITHEREDQUANTITY), 0) / nullif(NVL (SUM (QUANTITYFORWITHER), 0), 0) * 100,2) LTODATE
    FROM   PRODGREENLEAFWITHERDETAIL
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND RECEIPTTYPE = 'TRANSFER IN'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '005. TEA MADE' MAINDES,'a.OWN' DES,NVL (SUM (TEAMADEQTY), 0) PERIOD,0 TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODDAILYDRYERDETAILS
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND OWNBOUGHT IN ('OWN')
    AND PRODUCTIONDATE >= TO_DATE('31/07/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE ('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '005. TEA MADE' MAINDES,'a.OWN' DES,0 PERIOD,NVL (SUM (TEAMADEQTY), 0) TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODDAILYDRYERDETAILS
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND OWNBOUGHT IN ('OWN')
    AND PRODUCTIONDATE >= TO_DATE('01/04/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '005. TEA MADE' MAINDES,'a.OWN' DES,0 PERIOD,0 TODATE,NVL (SUM (TEAMADEQTY), 0) LPERIOD,0 LTODATE
    FROM   PRODDAILYDRYERDETAILS
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND OWNBOUGHT IN ('OWN')
    AND PRODUCTIONDATE >= TO_DATE('31/07/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '005. TEA MADE' MAINDES,'a.OWN' DES,0 PERIOD,0 TODATE,0 LPERIOD,NVL (SUM (TEAMADEQTY), 0) LTODATE
    FROM   PRODDAILYDRYERDETAILS
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND OWNBOUGHT IN ('OWN')
    AND PRODUCTIONDATE >= TO_DATE('01/04/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '005. TEA MADE' MAINDES,'b.BOUGHT' DES,NVL (SUM (TEAMADEQTY), 0) PERIOD,0 TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODDAILYDRYERDETAILS
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND OWNBOUGHT='BOUGHT'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE ('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '005. TEA MADE' MAINDES,'b.BOUGHT' DES,0 PERIOD,NVL (SUM (TEAMADEQTY), 0) TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODDAILYDRYERDETAILS
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND OWNBOUGHT='BOUGHT'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '005. TEA MADE' MAINDES,'b.BOUGHT' DES,0 PERIOD,0 TODATE,NVL (SUM (TEAMADEQTY), 0) LPERIOD,0 LTODATE
    FROM   PRODDAILYDRYERDETAILS
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND OWNBOUGHT='BOUGHT'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '005. TEA MADE' MAINDES,'b.BOUGHT' DES,0 PERIOD,0 TODATE,0 LPERIOD,NVL (SUM (TEAMADEQTY), 0) LTODATE
    FROM   PRODDAILYDRYERDETAILS
    WHERE       DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND OWNBOUGHT='BOUGHT'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy') 
    UNION ALL
    SELECT   '005. TEA MADE' MAINDES,'c.TRANSFER IN' DES,NVL (SUM (TEAMADEQTY), 0) PERIOD,0 TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODDAILYDRYERDETAILS
    WHERE DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND BATCHNO LIKE  '%TRANSFER IN%'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE ('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '005. TEA MADE' MAINDES,'c.TRANSFER IN' DES,0 PERIOD,NVL (SUM (TEAMADEQTY), 0) TODATE,0 LPERIOD,0 LTODATE
    FROM   PRODDAILYDRYERDETAILS
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND BATCHNO LIKE  '%TRANSFER IN%'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2020','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE('31/07/2020','dd/MM/yyyy')
    UNION ALL
    SELECT   '005. TEA MADE' MAINDES,'c.TRANSFER IN' DES,0 PERIOD,0 TODATE,NVL (SUM (TEAMADEQTY), 0) LPERIOD,0 LTODATE
    FROM   PRODDAILYDRYERDETAILS
    WHERE       DIVISIONCODE = '0010'
    AND COMPANYCODE ='JT0070' 
    AND BATCHNO LIKE  '%TRANSFER IN%'
    AND PRODUCTIONDATE >= TO_DATE('31/07/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <= TO_DATE ('31/07/2019','dd/MM/yyyy')
    UNION ALL
    SELECT   '005. TEA MADE' MAINDES,'c.TRANSFER IN' DES,0 PERIOD,0 TODATE,0 LPERIOD,NVL (SUM (TEAMADEQTY), 0) LTODATE
    FROM   PRODDAILYDRYERDETAILS
    WHERE       DIVISIONCODE ='0010'
    AND COMPANYCODE ='JT0070' 
    AND BATCHNO LIKE  '%TRANSFER IN%'
    AND PRODUCTIONDATE >= TO_DATE('01/04/2019','dd/MM/yyyy')
    AND PRODUCTIONDATE <=  TO_DATE ('31/07/2019','dd/MM/yyyy') 
)GROUP BY MAINDES,DES
ORDER BY MAINDES,DES

