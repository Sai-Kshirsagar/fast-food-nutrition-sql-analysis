# Fast Food Health Score: Comparing 6 Major US Chains with SQL

A SQL (BigQuery) project that builds a nutrient-based health score for fast food menu items and uses it to compare six major US fast food chains.

**Tools:** Google BigQuery (SQL) · Kaggle dataset · Google Sheets · Tableau

---

## Problem

Nutrition labels list many nutrients separately, which makes it hard to judge how healthy a menu item or a whole chain is. This project builds one health score per menu item and uses it to compare six major US fast food chains. The project compares meals, so beverages are excluded from the analysis.

**Key questions**
1. Which fast food chain offers the healthiest menu, and does my scoring system agree with standard nutrition criteria?
2. Which meal is the healthiest at each chain?

---

## Data

- **Source:** Fast Food Nutrition by Joakim Arvidsson, from [Kaggle](https://www.kaggle.com/datasets/joebeachcapital/fast-food) (Kaggle usability score: 10/10)
- **Chains covered:** McDonald's, KFC, Burger King, Taco Bell, Wendy's, Pizza Hut
- **Size:** 1,148 items (rows) and 12 nutrient columns in the raw file; 364 items were scored
- **Scope:** Beverages were excluded, because the project compares meals and food items

---

## Disclaimer

This project is strictly an educational and learning activity undertaken to develop practical skills in data cleaning, SQL, data analysis, and visualization.

The analysis includes publicly available nutritional information from six major food chains and is intended solely for academic and personal skill-development purposes. Any comparisons, scores, rankings, or observations presented are based on the selected dataset, criteria, and methodology used in this project.

This project is not intended to criticize, target, defame, or express any personal or negative opinions about the food chains or their brands. No commercial conclusions or judgments about the overall quality of their products or services should be drawn from this analysis.

All brand names and related information are used solely for identification and educational analysis.

---

## Methodology

The whole project is 20 SQL files, numbered in the order they were run. The numbers in brackets below point to those files.

### 1. Cleaning (files 1-13)

**Loading and column names**

1. Loaded the Kaggle dataset into BigQuery. The nutrient columns were imported as **strings**.
2. On loading, all column names were replaced with generic names (`String_type_0`, `String_type_1`, and so on). Renamed them back to the correct names. `[1]`

**Fixing encoding errors**

3. The file picked up many encoding errors while being downloaded from the web. Strange characters that were not in the original dataset had been added, especially in the `Item` column. Each pattern was fixed with its own query:

| File | Problem | Fix |
|------|---------|-----|
| 2 | `Â` | Removed |
| 3 | `â€` | Removed |
| 4 | `”` (double inverted comma, a special case) | Removed |
| 5 | `¡` | Removed |
| 6 | `CafÃ©` (this is where `Ã` appears) | Replaced with `Café` |
| 7 | `™` standing in for an apostrophe | Replaced with `'` |

   File 3 has to run before file 7: a garbled apostrophe comes through as `â€™`, so stripping `â€` leaves the `™`, which is then swapped for `'`.

**Removing empty rows and converting types**

4. Removed all rows where the `Item` value was NULL but the nutrient columns still had values. This was done before the conversion in the next step. `[8]`
5. Converted all nutrient columns from `STRING` to `INT64`. `[9]`

**Handling missing calories**

6. Checked how many rows had NULL values in `Calories`. `[10]`
7. Removed the rows where `Calories` was NULL or 0. Every nutrient is later divided by calories, so these rows cannot be scored. `[11]`
8. Re-ran the check to confirm no NULL or zero calories were left. `[12]`
9. Built the final cleaned table. Kept only the rows where every nutrient value is `NOT NULL`, with the conditions joined by `AND`, so a row with any missing nutrient value was left out. `[13]`

### 2. Separating food from beverages (files 14-15, 17)

The project compares meals, so beverages are not scored.

1. Extracted the beverage entries into their own table, so they could be identified and checked. `[14]`
2. Built a food-only table with the beverages left out. `[15]`
3. After the health score was calculated, some beverages were still in the scored table. A second query removed them. `[17]`

### 3. Scoring system (file 16)

I built a score for every nutrient, then combined them into one health score per item.

**Step 1: Normalise per 100 kcal.** Each nutrient is measured per 100 kilocalories, so large and small items can be compared fairly.

**Step 2: Min-max scale each nutrient to 0-1.**

```
nutrient_score = (value_per_100kcal - min) / (max - min)
```

**Step 3: Combine into a health score.** Positive nutrients add to the score and negative nutrients subtract from it. The result is shifted and rescaled to stay between 0 and 1.

```
health_score = (sum of positive nutrient scores
                - sum of negative nutrient scores
                + 3) / 5
```

- **Positive nutrients** (higher is better): e.g. protein, fibre
- **Negative nutrients** (lower is better): e.g. sodium, sugar, saturated fat

The `+3` and `÷5` were found by trial and error, to keep the final score between 0 and 1.

A score closer to **1** means healthier, and closer to **0** means less healthy.

> **Note:** This score is relative to the items in this dataset. It is not an absolute measure of health and does not correspond to official nutrition standards.

### 4. Standard criteria check (file 18)

Checked every item against seven standard nutrition criteria and counted how many it passed (checks passed, out of 7).

The criteria are daily reference values divided by 3, on the assumption of three meals a day. Each check is worth 1 point if the item passes and 0 if it fails. Unlike the health score, the checks use the item's **absolute amounts**, not per-100-kcal values.

| # | Criterion | Daily reference | Pass if (per meal, daily / 3) |
|---|-----------|-----------------|-------------------------------|
| 1 | Calories | 2,000 kcal | ≤ 666.7 kcal |
| 2 | Sodium | 2,000 mg | ≤ 666.7 mg |
| 3 | Saturated fat | 22 g | ≤ 7.33 g |
| 4 | Trans fat | 2.2 g | ≤ 0.73 g |
| 5 | Sugars | 50 g | ≤ 16.7 g |
| 6 | Protein | 50 g | ≥ 16.7 g |
| 7 | Fibre | 25 g | ≥ 8.3 g |

```sql
  CAST(kcal             <= 2000/3 AS INT64)  -- divided by 3 for three meals a day
+ CAST(Sodium_mg        <= 2000/3 AS INT64)
+ CAST(Saturated_Fat_gm <= 22/3   AS INT64)
+ CAST(Trans_fat_gm     <= 2.2/3  AS INT64)
+ CAST(Sugars_gm        <= 50/3   AS INT64)
+ CAST(Protein_gm       >= 50/3   AS INT64)
+ CAST(Fiber_gm         >= 25/3   AS INT64)
```

Calories, sodium, saturated fat, trans fat and sugars are limits (lower is better). Protein and fibre are minimums (higher is better).

### 5. Analysis (files 19-20)

- **Chain comparison** `[19]`: For each chain, took the average health score, the average checks passed, and the share of items passing at least 5 of the 7 checks. Ranked the six chains both ways.
- **Best meal per chain** `[20]`: For each chain, picked the item with the highest health score among meal-sized items (at least 250 kcal) that pass at least 5 of the 7 checks.

---

## Results

### Chain comparison

| Chain | Items | Avg health score (rank) | Avg checks passed, out of 7 (rank) | Items passing 5+ checks |
|-------|-------|-------------------------|------------------------------------|-------------------------|
| KFC | 57 | 0.584 (1) | 4.63 (2) | 71.9% |
| Taco Bell | 57 | 0.581 (2) | 4.35 (3) | 54.4% |
| Pizza Hut | 45 | 0.572 (3) | 4.78 (1) | 77.8% |
| Wendy's | 62 | 0.543 (4) | 4.10 (5) | 35.5% |
| McDonald's | 83 | 0.532 (5) | 4.11 (4) | 43.4% |
| Burger King | 60 | 0.531 (6) | 3.82 (6) | 33.3% |

### Best meal per chain

| Chain | Best meal | Health score | Checks passed |
|-------|-----------|--------------|---------------|
| KFC | Breast (260 kcal) | 0.698 | 5 of 7 |
| Wendy's | Grilled Chicken Sandwich | 0.663 | 5 of 7 |
| McDonald's | Premium Bacon Ranch Salad with Grilled Chicken | 0.659 | 5 of 7 |
| Taco Bell | Power Menu Bowl Specialties | 0.614 | 5 of 7 |
| Burger King | French Fries medium | 0.607 | 5 of 7 |
| Pizza Hut | Hand Tossed Slices Hawaiian Chicken Large | 0.598 | 5 of 7 |

### Key findings

- **KFC has the highest average health score (0.584), but Pizza Hut passes the most checks.** Pizza Hut ranks 3rd by my score yet 1st by the standard criteria, with 77.8% of its items passing at least 5 of 7 checks. Burger King comes last on both.
- **The scores are close.** All six chains sit between 0.531 and 0.584, so the standard criteria separate the chains more clearly than my score does.
- **A high score is not a clean bill of health.** Some items score very high on my health score, yet they still fail the standard criteria. It is easy to shrug off one failed criterion, but failing even one is a real problem. None of the 10 highest-scoring items passes all seven checks, and only 4 of the 364 items do. Of the 91 highest-scoring items (the top quarter), 88 fail at least one check and 14 fail two or more. My score adds everything together, so strong results on some nutrients can hide a bad result on another. The score shows which items look healthy overall, and the criteria check shows which ones hold up.

---

## Tableau dashboards

- [All Items Health Scores](https://public.tableau.com/app/profile/sai.kshirsagar1799/viz/AllHealthScores/Sheet1?publish=yes)
- [Food Chains Overview](https://public.tableau.com/app/profile/sai.kshirsagar1799/viz/Food_chains_ovr/Sheet1?publish=yes)

## SQL files

All queries are in `queries/`, numbered in the order they were run.

| # | File | What it does |
|---|------|--------------|
| 1 | `1_Column_Name_Change` | Renames the generic column names back to the correct names |
| 2 | `2_To_REM_Â` | Removes `Â` |
| 3 | `3_Remove_â€` | Removes `â€` |
| 4 | `4_Special_Case_DoubleInverted_Removal` | Removes `”` (special case) |
| 5 | `5_rem_special_¡` | Removes `¡` |
| 6 | `6_Replace_CafÃ©_with_Café` | Replaces `CafÃ©` with `Café` |
| 7 | `7_Replaced™to'` | Replaces `™` with `'` |
| 8 | `8_REM_Item_NULL_0` | Removes rows with a NULL `Item` |
| 9 | `9_Cast_as_int64` | Converts nutrient columns from `STRING` to `INT64` |
| 10 | `10_Checking_NULLS_InCalories` | Checks for NULL calories |
| 11 | `11_REM_calories_NULL_0` | Removes rows where calories are NULL or 0 |
| 12 | `12_Checking_NULLS_InCalories_after_rem` | Re-checks calories after the removal |
| 13 | `13_Cleaned_data_final_cmd` | Builds the final cleaned table (every nutrient `NOT NULL`) |
| 14 | `14_Extract_Beverages_Only` | Extracts the beverage entries |
| 15 | `15_Food_Only` | Builds the food-only table |
| 16 | `16_health_score` | Normalises per 100 kcal, min-max scales, and calculates the health score |
| 17 | `17_To_REM_Beverages_in_health_score` | Removes beverages that were still in the scored table |
| 18 | `18_Standards_Check` | Checks each item against the seven standard criteria |
| 19 | `19_Best_Food_Chain` | Compares and ranks the six chains |
| 20 | `20_grab_food` | Picks the best meal per chain |

---

## Repository structure

```
├── queries/     20 SQL files, numbered in run order (see table above)
├── results/     food_scoredv3.csv, food_checked.csv, food_grab_list.csv, food_chain_final.xlsx
├── visuals/     Chart screenshots
└── README.md
```

---

## How to reproduce

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/joebeachcapital/fast-food).
2. Load it into BigQuery.
3. Fix the column names that were replaced on loading (file 1).
4. Remove the encoding errors and correct the swapped characters (files 2-7).
5. Remove the rows where `Item` is NULL (file 8).
6. Convert the nutrient columns from `STRING` to `INT64` (file 9).
7. Check for NULL calories, remove the rows where calories are NULL or 0, and check again (files 10-12).
8. Keep only the rows where every nutrient value is `NOT NULL`, with conditions joined by `AND` (file 13).
9. Extract the beverages and build the food-only table (files 14-15).
10. Normalise each nutrient per 100 kcal, min-max scale each nutrient to 0-1, and calculate the health score with the formula above (file 16).
11. Remove the beverages that are still in the scored table (file 17).
12. Check every item against the seven standard criteria and count the checks passed (file 18).
13. Average the health score and checks passed per chain, and rank the chains both ways (file 19).
14. Pick the best meal for each chain (file 20).
15. Build the charts in Tableau or Google Sheets.

---

## Assumptions & Limitations

- The score is **relative**: min-max scaling means a chain's result depends on the other items in this dataset.
- All nutrients are weighted equally.
- Scoring per 100 kcal does not account for portion size.
- Items with zero or very few calories can distort the per-100-kcal values. Items with NULL or 0 calories were removed before scoring.
- Beverages are excluded, so the results cover meals and food items only, not drinks.
- Rows with any missing nutrient value were left out, so only items with complete data are scored.
- Encoding errors were fixed one pattern at a time, so a garbled character I did not spot could still be in an `Item` name.
- The `+3` and `÷5` in the formula were chosen by trial and error.
- The best meal per chain uses a 250 kcal cut-off, so a side item (like Burger King's fries) can still qualify as a "meal".
- The data is a snapshot, and menus change over time.
- The standard criteria use a 2,000 kcal day split into three equal meals. Snacks, bigger or smaller eaters, and different calorie needs are not covered.
- The criteria check uses absolute amounts per item, while the health score uses per-100-kcal values. This is one reason the two can disagree.
- All seven checks are worth the same, and a pass or fail does not show how close the item was to the limit.
- The sugar limit (50 g) is a daily reference value, but the dataset reports total sugars, so naturally occurring sugars are counted too.
- Standard criteria are general guidelines, not personalised advice.
- This is a learning project and not medical or dietary advice.

---

## About

Built by Sai Chanchal Kshirsagar as part of my data analytics learning journey.
