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

/* testing */
SELECT name, star_id, num_stars
FROM exoplanet 
WHERE num_stars > 1
ORDER BY name; 


WITH distances AS (SELECT n.id,
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
    ORDER BY distance_pow_2 ASC 
)
SELECT e.name, d.distance_pow_2
FROM exoplanet AS e JOIN distances AS d 
ON e.star_id = d.id
ORDER BY distance_pow_2
LIMIT 100;  


/*cleaner one rght? */
SELECT e.name, 
        n.id,
        (ABS(n.x_pc - s.x_pc) * ABS(n.x_pc - s.x_pc) + 
        ABS(n.y_pc - s.y_pc) * ABS(n.y_pc - s.y_pc) +
        ABS(n.z_pc - s.z_pc) * ABS(n.z_pc - s.z_pc)) AS distance_pow_2
    FROM star as n CROSS JOIN star as s 
    JOIN exoplanet e
    ON e.star_id = n.id
    WHERE 
        s.proper_name ILIKE 'Sol' AND 
        n.id <> s.id
    ORDER BY distance_pow_2 ASC LIMIT 100; 


/* Question 13 */
SELECT c.name, COUNT(e.name) AS num_planets
FROM constellation AS c JOIN 
star AS s ON s.con = c.abbr
LEFT JOIN exoplanet AS e ON 
s.id = e.star_id
GROUP BY c.name
ORDER BY num_planets ASC;


/* Qusetion 14 */

/*  
    cooardinates for the suns 
    ra_deg double precision,
    dec_deg double precision,
*/

/*
    There is function named constellation_at 


*/

WITH calculated_stars AS (
        SELECT  id, 
                proper_name,
                con,
                constellation_at(ra_deg,dec_deg) as calculated_con
    FROM star
)
SELECT  id, 
        proper_name,
        con,
        calculated_con
FROM calculated_stars
WHERE con <> calculated_con; 


/* creating view */
CREATE VIEW IF NOT EXISTS calculated_stars AS (
        SELECT  id, 
                proper_name,
                con,
                constellation_at(ra_deg,dec_deg) as calculated_con
    FROM star
);


SELECT  id, 
        proper_name,
        con,
        calculated_con
FROM calculated_stars
WHERE con <> calculated_con; 




/* Question 15 */

/*
WITH distances AS  (SELECT n.id,
       n.proper_name,
       ABS(n.x_pc - s.x_pc) AS x_diff,
       ABS(n.y_pc - s.y_pc) AS y_diff,
       ABS(n.z_pc - s.z_pc) AS z_diff,
       (ABS(n.x_pc - s.x_pc) * ABS(n.x_pc - s.x_pc) + 
        ABS(n.y_pc - s.y_pc) * ABS(n.y_pc - s.y_pc) +
        ABS(n.z_pc - s.z_pc) * ABS(n.z_pc - s.z_pc)) AS distance_pow_2
    FROM star as n CROSS JOIN star as s 
    WHERE 
        s.spectral_type LIKE 'M%' AND 
        n.id <> s.id
),
with_douplicates AS (
    SELECT DISTINCT n.id,
                    n.proper_name,
                    n.distance_pow_2
    FROM distances AS n  
    WHERE n.distance_pow_2 < 1
),
only_duplicates AS (
    SELECT DISTINCT s1.id,
                    s1.proper_name,
                    MIN(s1.distance_pow_2) AS distance_pow_2
    FROM with_douplicates AS s1 JOIN 
    with_douplicates AS s2 
    ON s1.id = s2.id AND s1.distance_pow_2 <> s2.distance_pow_2
    GROUP BY s1.id, s1.proper_name
),
no_duplicates AS(
    SELECT DISTINCT n.id, 
                    n.proper_name,
                    n.distance_pow_2
    FROM with_douplicates AS n WHERE n.id NOT IN (SELECT id from only_duplicates)
)

SELECT id, proper_name, distance_pow_2
FROM only_duplicates

UNION ALL

SELECT id, proper_name, distance_pow_2
FROM no_duplicates

ORDER BY distance_pow_2 ASC;
*/

/* optimized version */

WITH distances AS  (SELECT n.id,
       n.proper_name,
       ABS(n.x_pc - s.x_pc) AS x_diff,
       ABS(n.y_pc - s.y_pc) AS y_diff,
       ABS(n.z_pc - s.z_pc) AS z_diff,
       (ABS(n.x_pc - s.x_pc) * ABS(n.x_pc - s.x_pc) + 
        ABS(n.y_pc - s.y_pc) * ABS(n.y_pc - s.y_pc) +
        ABS(n.z_pc - s.z_pc) * ABS(n.z_pc - s.z_pc)) AS distance_pow_2
    FROM star as n CROSS JOIN star as s 
    WHERE 
        s.spectral_type LIKE 'M%' AND 
        n.id <> s.id
)
SELECT id,
       proper_name,
       MIN(distance_pow_2) AS distance_pow_2
FROM distances
WHERE distance_pow_2 < 1
GROUP BY id, proper_name
ORDER BY distance_pow_2 ASC;



/* Question 16 */
WITH distances AS  (SELECT n.id,
       n.proper_name,
       ABS(n.x_pc - s.x_pc) AS x_diff,
       ABS(n.y_pc - s.y_pc) AS y_diff,
       ABS(n.z_pc - s.z_pc) AS z_diff,
       (ABS(n.x_pc - s.x_pc) * ABS(n.x_pc - s.x_pc) + 
        ABS(n.y_pc - s.y_pc) * ABS(n.y_pc - s.y_pc) +
        ABS(n.z_pc - s.z_pc) * ABS(n.z_pc - s.z_pc)) AS distance_pow_2
    FROM star as n CROSS JOIN star as s 
    WHERE 
        s.spectral_type LIKE 'M%' AND 
        n.id <> s.id
),
SELECT id,
       proper_name,
       MIN(distance_pow_2) AS distance_pow_2
FROM distances
GROUP BY id, proper_name
HAVING MIN(distance_pow_2) >= 2500
ORDER BY distance_pow_2 ASC;

/* Question 18 */
SELECT d.name 
FROM dso AS d JOIN constellation AS c 
ON d.con = c.abbr
WHERE c.name ILIKE 'virgo' AND d.redshift > 0.5; 

/* Question 19*/
SELECT name,
       radius_earth,
       mass_earth,
       insolation_earth, -- how much energy it recievs from form its start 
       eq_temp_k, -- estimated equilibrium temp 
       eccentricity, -- how stretched its orbit is
       (
           POWER(radius_earth - 1, 2) +
           POWER(mass_earth - 1, 2) +
           POWER(insolation_earth - 1, 2) +
           POWER(eq_temp_k - 255, 2) +
           POWER(eccentricity - 0.0167, 2)
       ) AS earth_distance_pow_2
FROM exoplanet
WHERE radius_earth IS NOT NULL
  AND mass_earth IS NOT NULL
  AND insolation_earth IS NOT NULL
  AND eq_temp_k IS NOT NULL
  AND eccentricity IS NOT NULL
ORDER BY earth_distance_pow_2 ASC;