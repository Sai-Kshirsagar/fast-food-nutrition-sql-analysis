CREATE OR REPLACE TABLE `project-d129c4ea-acf9-44f7-91d.Project.FastFoodNutritionMenu` AS
SELECT
  REPLACE(Item, 'Â', '') AS Item,
  REPLACE(Calories, 'Â', '') AS Calories,
  REPLACE(Calories_from_fat, 'Â', '') AS Calories_from_fat,
  REPLACE(Total_Fat_gm, 'Â', '') AS Total_Fat_gm,
  REPLACE(Saturated_Fat_gm, 'Â', '') AS Saturated_Fat_gm,
  REPLACE(Trans_Fat_gm, 'Â', '') AS Trans_Fat_gm,
  REPLACE(Cholesterol_gm, 'Â', '') AS Cholesterol_gm,
  REPLACE(Sodium_mg, 'Â', '') AS Sodium_mg,
  REPLACE(Carbs_gm, 'Â', '') AS Carbs_gm,
  REPLACE(Fiber_gm, 'Â', '') AS Fiber_gm,
  REPLACE(Sugars_gm, 'Â', '') AS Sugars_gm,
  REPLACE(Protein_gm, 'Â', '') AS Protein_gm,
  REPLACE(Serving_Weight, 'Â', '') AS Serving_Weight
FROM
  `project-d129c4ea-acf9-44f7-91d`.Project.FastFoodNutritionMenu