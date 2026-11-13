CREATE OR REPLACE TABLE `project-d129c4ea-acf9-44f7-91d.Project.food_scoredv2` AS


/* per_100kcal */

WITH per_100kcal AS (
  SELECT
    Company, Item, kcal,
    Sodium_mg, Protein_gm, Fiber_gm, Saturated_Fat_gm,
    Trans_fat_gm, Sugars_gm, Cholesterol_gm,
    SAFE_DIVIDE(Sodium_mg, kcal) * 100 AS sodium_per_100kcal,
    SAFE_DIVIDE(Protein_gm, kcal) * 100 AS protein_per_100kcal,
    SAFE_DIVIDE(Fiber_gm, kcal) * 100 AS fiber_per_100kcal,
    SAFE_DIVIDE(Saturated_Fat_gm, kcal) * 100 AS saturated_fat_per_100kcal,
    SAFE_DIVIDE(Sugars_gm, kcal) * 100 AS sugars_per_100kcal
  FROM `project-d129c4ea-acf9-44f7-91d.Project.fast_food_nutrition_food_only`
  WHERE 
    Sodium_mg IS NOT NULL AND Protein_gm IS NOT NULL AND Fiber_gm IS NOT NULL
    AND Saturated_Fat_gm IS NOT NULL AND Trans_fat_gm IS NOT NULL
    AND Sugars_gm IS NOT NULL AND Cholesterol_gm IS NOT NULL
),

 /*min_max_values
 lowest and highest value of that nutrient.
 protein_max = the highest protein per 100 kcal in the table.
 */

min_max_values AS (
  SELECT
    MIN(protein_per_100kcal) AS protein_min,
    MAX(protein_per_100kcal) AS protein_max,
    MIN(fiber_per_100kcal) AS fiber_min,
    MAX(fiber_per_100kcal) AS fiber_max,
    MIN(sodium_per_100kcal) AS sodium_min,
    MAX(sodium_per_100kcal) AS sodium_max,
    MIN(saturated_fat_per_100kcal) AS saturated_fat_min,
    MAX(saturated_fat_per_100kcal) AS saturated_fat_max,
    MIN(sugars_per_100kcal) AS sugars_min,
    MAX(sugars_per_100kcal) AS sugars_max
  FROM per_100kcal
),

 /* normalized value: (value - min) / (max - min)
   0 = lowest, 1 = highest.*/

normalized AS (
  SELECT item_values.*,
    
    SAFE_DIVIDE(item_values.protein_per_100kcal - min_max.protein_min, min_max.protein_max - min_max.protein_min) AS normalized_protein,

    SAFE_DIVIDE(item_values.fiber_per_100kcal - min_max.fiber_min, min_max.fiber_max - min_max.fiber_min) AS normalized_fiber,

    SAFE_DIVIDE(item_values.sodium_per_100kcal - min_max.sodium_min, min_max.sodium_max - min_max.sodium_min) AS normalized_sodium,

    SAFE_DIVIDE(item_values.saturated_fat_per_100kcal - min_max.saturated_fat_min, min_max.saturated_fat_max - min_max.saturated_fat_min) AS normalized_saturated_fat,
    
    SAFE_DIVIDE(item_values.sugars_per_100kcal - min_max.sugars_min, min_max.sugars_max - min_max.sugars_min) AS normalized_sugars
  
  FROM per_100kcal AS item_values
  
  CROSS JOIN min_max_values AS min_max
)

/* health_score : good - bad
  protein and fiber add to the score; sodium, saturated fat and
  sugars subtract. 
Higher health_score= healthier. */

SELECT
  Company, Item, kcal,
  Sodium_mg, Protein_gm, Fiber_gm, Saturated_Fat_gm,
  Trans_fat_gm, Sugars_gm, Cholesterol_gm,
  ROUND(
    (normalized_protein + normalized_fiber - normalized_sodium
      - normalized_saturated_fat - normalized_sugars + 3) / 5, 
    3) AS health_score -- The result is shifted by +3 and divided by 5 to maintain 0 to 1
FROM normalized
ORDER BY health_score DESC;

-- This Result is realtive(table) basis only.