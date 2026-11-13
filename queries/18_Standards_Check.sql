/* Every item gets the 7 real-standard checks.
  lower better: calories, sodium, sat fat, trans fat, sugars.
  higher better: protein, fiber.
  This table is also the data for your scatter plot. */
CREATE OR REPLACE TABLE `project-d129c4ea-acf9-44f7-91d.Project.food_checked` AS
SELECT
  Company, Item, kcal, health_score,
  (CAST(kcal             <= 2000/3 AS INT64)        -- by 3 as cosidering three meals a day
 + CAST(Sodium_mg        <= 2000/3 AS INT64)
 + CAST(Saturated_Fat_gm <= 22/3   AS INT64)
 + CAST(Trans_fat_gm     <= 2.2/3  AS INT64)
 + CAST(Sugars_gm        <= 50/3   AS INT64)
 + CAST(Protein_gm       >= 50/3   AS INT64)
 + CAST(Fiber_gm         >= 25/3   AS INT64)) AS checks_passed   -- out of 7
FROM `project-d129c4ea-acf9-44f7-91d.Project.food_scoredv3`
WHERE health_score IS NOT NULL
ORDER BY health_score DESC;