WITH factorial (fact_num, fact_prod1, fact_prod2)
AS (SELECT 0, 1, 1
      FROM DUAL
     UNION ALL
    SELECT fact_num + 1,
           fact_prod1 * (fact_num + 1),
           fact_prod1 * (fact_num + 1)
      FROM factorial
     WHERE fact_num < :num)

SELECT fact_num,
       fact_prod2 AS factorial
  FROM factorial;