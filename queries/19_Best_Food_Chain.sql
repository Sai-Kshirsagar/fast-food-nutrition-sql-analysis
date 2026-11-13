-- Final chain table, one row per chain.
-- Chain numbers are averages or shares, so menu size gives no advantage.
-- Best meal = highest-scoring item with at least 250 kcal (my cutoff, change if needed).
CREATE OR REPLACE TABLE `project-d129c4ea-acf9-44f7-91d.Project.food_chain_final`
AS
WITH
  base_stats AS (
    SELECT
      Company,
      Item,
      health_score,
      checks_passed,
      kcal,
      COUNT(*) OVER (PARTITION BY Company) AS items,
      ROUND(AVG(health_score) OVER (PARTITION BY Company), 3) AS mean_score,
      ROUND(AVG(checks_passed) OVER (PARTITION BY Company), 3) AS avg_checks,
      ROUND(
        COUNTIF(checks_passed >= 5)
          OVER (PARTITION BY Company)
          / COUNT(*) OVER (PARTITION BY Company)
          * 100,
        1)
        AS pass_5plus_pct
    FROM `project-d129c4ea-acf9-44f7-91d.Project.food_checked`
  )
SELECT
  Company,
  items,
  mean_score,
  avg_checks,
  pass_5plus_pct,
  Item AS best_meal,
  health_score AS best_meal_score,
  checks_passed AS best_meal_checks,
  RANK() OVER (ORDER BY mean_score DESC) AS rank_by_score,
  RANK() OVER (ORDER BY avg_checks DESC) AS rank_by_standard
FROM base_stats
WHERE kcal >= 250
QUALIFY health_score = MAX(health_score) OVER (PARTITION BY Company)
ORDER BY rank_by_standard;