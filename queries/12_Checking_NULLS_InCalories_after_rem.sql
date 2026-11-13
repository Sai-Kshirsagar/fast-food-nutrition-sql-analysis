SELECT
  COUNTIF(Calories IS NULL) AS null_calories,
  COUNT(*) AS total_rows
FROM `project-d129c4ea-acf9-44f7-91d.Project.fast_food_nutritionV6Cast`