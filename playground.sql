/* Question 9*/
DO $$ BEGIN RAISE NOTICE 'Question 9'; END $$;

SELECT s.id, s.proper_name, s.x_pc, s.y_pc, s.z_pc
FROM star AS s
JOIN constellation AS c ON s.con = c.abbr
WHERE c.name = 'Pisces'
  AND s.spectral_type LIKE 'M%'; -- this makes that it checks the first letter


/* Question 10*/

/* We try to find the sun first */
SELECT s.id, s.proper_name, s.x_pc,  s.y_pc, s.z_pc
FROM star AS s 
WHERE s.proper_name ILIKE 'SOL'; 

SELECT n.id,
       n.proper_name,
       ABS(n.x_pc - s.x_pc) AS x_diff,
       ABS(n.y_pc - s.y_pc) AS y_diff,
       ABS(n.z_pc - s.z_pc) AS z_diff,
       (ABS(n.x_pc - s.x_pc) * ABS(n.x_pc - s.x_pc) + 
        ABS(n.y_pc - s.y_pc) * ABS(n.y_pc - s.y_pc) +
        ABS(n.z_pc - s.z_pc) * ABS(n.z_pc - s.z_pc)) AS distance_pow_2
    FROM star as n CROSS JOIN star as s 
    WHERE 
        s.proper_name ILIKE 'Sol' AND 
        n.id <> s.id
    ORDER BY distance_pow_2 ASC LIMIT 100; 

/* Question 11 */
SELECT n.id,
       n.proper_name,
       ABS(n.x_pc - s.x_pc) AS x_diff,
       ABS(n.y_pc - s.y_pc) AS y_diff,
       ABS(n.z_pc - s.z_pc) AS z_diff,
       (ABS(n.x_pc - s.x_pc) * ABS(n.x_pc - s.x_pc) + 
        ABS(n.y_pc - s.y_pc) * ABS(n.y_pc - s.y_pc) +
        ABS(n.z_pc - s.z_pc) * ABS(n.z_pc - s.z_pc)) AS distance_pow_2
    FROM star as n CROSS JOIN star as s 
    WHERE 
        s.proper_name ILIKE 'Antares' AND 
        n.id <> s.id
    ORDER BY distance_pow_2 ASC LIMIT 100; 


/* Question 12 */


