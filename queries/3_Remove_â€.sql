CREATE OR REPLACE TABLE `project-d129c4ea-acf9-44f7-91d.Project`.fast_food_nutritionV5 AS
SELECT
  REPLACE(Item, 'â€', '') AS Item,
  REPLACE(Company, 'â€', '') AS Company,
  REPLACE(Calories, 'â€', '') AS Calories,
  REPLACE(Calories_from_fat, 'â€', '') AS Calories_from_fat,
  REPLACE(Total_Fat_gm, 'â€', '') AS Total_Fat_gm,
  REPLACE(Saturated_Fat_gm, 'â€', '') AS Saturated_Fat_gm,
  REPLACE(Trans_Fat_gm, 'â€', '') AS Trans_Fat_gm,
  REPLACE(Cholesterol_gm, 'â€', '') AS Cholesterol_gm,
  REPLACE(Sodium_mg, 'â€', '') AS Sodium_mg,
  REPLACE(Carbs_gm, 'â€', '') AS Carbs_gm,
  REPLACE(Fiber_gm, 'â€', '') AS Fiber_gm,
  REPLACE(Sugars_gm, 'â€', '') AS Sugars_gm,
  REPLACE(Protein_gm, 'â€', '') AS Protein_gm,
  REPLACE(Serving_Weight, 'â€', '') AS Serving_Weight
FROM
  `project-d129c4ea-acf9-44f7-91d.Project`.fast_food_nutritionV4