SELECT * FROM 
(
    SELECT SUM(FBASIC_PEICERT) FBASIC_PEICERT, SUM(FBASIC) FBASIC
    , SUM(VBASIC) VBASIC, SUM(DA) DA, SUM(TSA) TSA, SUM(ADHOC) ADHOC, SUM(NS_ALLOW) NS_ALLOW
    FROM 
    (
        SELECT COMPONENT.TOKENNO, FORTNIGHTSTARTDATE,FORTNIGHTENDDATE,
        COMPONENT.FBASIC_PEICERT, COMPONENT.FBASIC,COMPONENT.VBASIC ,COMPONENT.DA,
        COMPONENT.TSA,COMPONENT.ADHOC , (CASE WHEN SECMST.PFLINKHOURS >0 THEN COMPONENT.NS_ALLOW ELSE 0 END) NS_ALLOW ,
        --
        COMPONENT.FBASIC_PEICERT+ COMPONENT.FBASIC +COMPONENT.VBASIC +COMPONENT.DA+
        COMPONENT.TSA+COMPONENT.ADHOC + (CASE WHEN SECMST.PFLINKHOURS >0 THEN COMPONENT.NS_ALLOW ELSE 0 END) TOTAL_SUM
        FROM WPSWAGESDETAILS COMPONENT, VW_WPSSECTIONMAST  SECMST
        WHERE TOKENNO='04053' --'04053'
        AND COMPONENT.COMPANYCODE='NJ0001'
        AND COMPONENT.DIVISIONCODE='0002'
        AND COMPONENT.SECTIONCODE=SECMST.SECTIONCODE
        AND COMPONENT.COMPANYCODE=SECMST.COMPANYCODE
        AND COMPONENT.DIVISIONCODE=SECMST.DIVISIONCODE
        AND COMPONENT.DEPARTMENTCODE=SECMST.DEPARTMENTCODE
        AND FORTNIGHTENDDATE IN 
        (
            SELECT FORTNIGHTENDDATE FROM 
            (
                SELECT ROW_NUMBER() OVER (ORDER BY FORTNIGHTENDDATE DESC) RNO, 
                FORTNIGHTENDDATE  FROM WPSWAGESDETAILS 
                WHERE TOKENNO='04053' --'04053'
                AND COMPANYCODE='NJ0001'
                AND DIVISIONCODE='0002'
                GROUP BY FORTNIGHTENDDATE
            )
            WHERE RNO <= 6
        )
    )
    GROUP BY TOKENNO
)sale_stats
UNPIVOT(
    COMPONENTVALUE  -- unpivot_clause
    FOR COMPONENTCODE --  unpivot_for_clause
    IN ( -- unpivot_in_clause
        FBASIC_PEICERT AS 'FBASIC_PEICERT', 
        FBASIC AS 'FBASIC', 
        VBASIC AS 'VBASIC', 
        DA AS 'DA', 
        TSA AS 'TSA', 
        ADHOC AS 'ADHOC', 
        NS_ALLOW AS 'NS_ALLOW'
    )
);