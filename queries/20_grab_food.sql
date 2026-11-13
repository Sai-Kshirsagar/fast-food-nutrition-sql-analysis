-- "In a hurry, what should I grab?"
-- Top 10 meal-sized items (250 kcal or more) by checks passed, score breaks ties.
CREATE OR REPLACE TABLE `project-d129c4ea-acf9-44f7-91d.Project.food_grab_list`
AS
SELECT Company, Item, kcal, checks_passed, health_score
FROM `project-d129c4ea-acf9-44f7-91d.Project.food_checked`
WHERE kcal >= 250
ORDER BY checks_passed DESC, health_score DESC
LIMIT 10;