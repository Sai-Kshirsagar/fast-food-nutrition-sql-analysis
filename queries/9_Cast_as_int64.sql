CREATE OR REPLACE TABLE `project-d129c4ea-acf9-44f7-91d`.Project.fast_food_nutritionV6Cast
AS
SELECT
  Company,
  Item,
  SAFE_CAST(Calories AS INT64) AS Calories,
  SAFE_CAST(Calories_from_fat AS INT64) AS Calories_from_fat,
  SAFE_CAST(Total_Fat_gm AS INT64) AS Total_Fat_gm,
  SAFE_CAST(Saturated_Fat_gm AS INT64) AS Saturated_Fat_gm,
  SAFE_CAST(Trans_Fat_gm AS INT64) AS Trans_Fat_gm,
  SAFE_CAST(Cholesterol_gm AS INT64) AS Cholesterol_gm,
  SAFE_CAST(Sodium_mg AS INT64) AS Sodium_mg,
  SAFE_CAST(Carbs_gm AS INT64) AS Carbs_gm,
  SAFE_CAST(Fiber_gm AS INT64) AS Fiber_gm,
  SAFE_CAST(Sugars_gm AS INT64) AS Sugars_gm,
  SAFE_CAST(Protein_gm AS INT64) AS Protein_gm,
  SAFE_CAST(Serving_Weight AS INT64) AS Serving_Weight
FROM `project-d129c4ea-acf9-44f7-91d`.Project.fast_food_nutritionV5
