CREATE OR REPLACE TABLE `project-d129c4ea-acf9-44f7-91d.Project.food_scoredv3` AS
SELECT *
FROM `project-d129c4ea-acf9-44f7-91d.Project.food_scoredv2`
WHERE NOT (
     LOWER(Item) LIKE 'latte%'
  OR LOWER(Item) LIKE 'cappuccino%'
  OR LOWER(Item) LIKE 'mocha%'
  OR LOWER(Item) LIKE 'limeade%'
  OR LOWER(Item) LIKE 'dr%pepper%'
  OR LOWER(Item) LIKE '%root beer%'
)
ORDER BY health_score DESC;