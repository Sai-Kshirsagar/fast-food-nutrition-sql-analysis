# Fast Food Health Score: Comparing 6 Major US Chains with SQL

A SQL (BigQuery) project that builds a nutrient-based health score for fast food menu items and uses it to compare six major US fast food chains.

**Tools:** Google BigQuery (SQL) · Kaggle dataset · Google Sheets · Tableau

---

## Problem

Nutrition labels list many nutrients separately, which makes it hard to judge how healthy a menu item or a whole chain is. This project builds one health score per menu item and uses it to compare six major US fast food chains. The project compares meals, so beverages are excluded from the analysis.

**Key questions**
1. Which fast food chain offers the healthiest menu, and does my scoring system agree with standard nutrition criteria?
2. Which fast food meal or food item is the healthiest among all?

---

## Data

- **Source:** Fast Food Nutrition by Joakim Arvidsson, from [Kaggle](https://www.kaggle.com/datasets/joebeachcapital/fast-food) (Kaggle usability score: 10/10)
- **Chains covered:** McDonald's, KFC, Burger King, Taco Bell, Wendy's, Pizza Hut
- **Size:** 1,148 items (rows) and 12 nutrient columns in the raw file; 364 items were scored
- **Scope:** Beverages were excluded, because the project compares meals and food items

---

## Methodology

### 1. Cleaning

1. Loaded the Kaggle dataset into BigQuery. The nutrient columns were imported as **strings**.
2. On loading, all column names were replaced with generic names (`String_type_0`, `String_type_1`, and so on). Renamed them back to the correct names.
3. The file picked up many encoding errors while being downloaded from the web.
4. Strange characters that were not in the original dataset had been added, especially in the `Items` column: `â€`, `Ã`, `¡`, `”`. Removed them.
5. Some characters had also been swapped for others (for example, `'` was replaced by `™`). Corrected these.
6. Removed all rows where the `Item` value was NULL but the nutrient columns still had values. This was done before the conversion in the next step.
7. Converted all nutrient columns from `STRING` to `INT64`.
8. Removed all beverage entries, because the project compares meals and not drinks.
9. Kept only the rows where every nutrient value is `NOT NULL`, with the conditions joined by `AND`, so a row with any missing nutrient value was left out.

### 2. Scoring system

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

### 3. Analysis

- **Standard criteria check:** Checked every item against six standard nutrition criteria and counted how many it passed (checks passed, out of 6).
- **Chain comparison:** For each chain, took the average health score, the average checks passed, and the share of items passing at least 5 of the 6 checks. Ranked the six chains both ways.
- **Best meal:** For each chain, picked the item with the highest health score among meal-sized items (at least [250] kcal) that pass at least 5 of the 6 checks.
- **Best item overall:** The item with the highest health score across all 364 scored items.

---

## Results

### Chain comparison

| Chain | Items | Avg health score (rank) | Avg checks passed, out of 6 (rank) | Items passing 5+ checks |
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
| KFC | Breast (260 kcal) | 0.698 | 5 of 6 |
| McDonald's | Premium Bacon Ranch Salad with Grilled Chicken | 0.659 | 5 of 6 |
| Wendy's | Grilled Chicken Sandwich | 0.663 | 5 of 6 |
| Taco Bell | Power Menu Bowl Specialties | 0.614 | 5 of 6 |
| Burger King | French Fries medium | 0.607 | 5 of 6 |
| Pizza Hut | Hand Tossed Slices Hawaiian Chicken Large | 0.598 | 5 of 6 |

**Healthiest item overall:** House Side Salad from KFC, with a score of 0.774 (15 kcal, 5 of 6 checks passed).

### Key findings

- **KFC has the highest average health score (0.584), but Pizza Hut passes the most checks.** Pizza Hut ranks 3rd by my score yet 1st by the standard criteria, with 77.8% of its items passing at least 5 of 6 checks. Burger King comes last on both.
- **The scores are close.** All six chains sit between 0.531 and 0.584, so the standard criteria separate the chains more clearly than my score does.
- **A high score is not a clean bill of health.** Some items score very high on my health score, yet they still fail the standard criteria. It is easy to shrug off one failed criterion, but failing even one is a real problem. None of the 10 highest-scoring items passes all six checks, and only 4 of the 364 items do. Of the 91 highest-scoring items (the top quarter), 88 fail at least one check and 14 fail two or more. My score adds everything together, so strong results on some nutrients can hide a bad result on another. The score shows which items look healthy overall, and the criteria check shows which ones hold up.

---

## Repository structure

```
├── queries/     SQL for the scoring
├── results/     food_scoredv3.csv, food_checked.csv, food_grab_list.csv, food_chain_final.xlsx
├── visuals/     Chart screenshots
├── checklist    Project checklist
└── README.md
```

---

## How to reproduce

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/joebeachcapital/fast-food).
2. Load it into BigQuery.
3. Fix the column names that were replaced on loading.
4. Remove the encoding errors and unwanted characters, and correct the swapped characters.
5. Remove the rows where `Item` is NULL but the nutrient columns have values.
6. Convert the nutrient columns from `STRING` to `INT64`.
7. Remove the beverage entries.
8. Keep only the rows where every nutrient value is `NOT NULL` (conditions joined with `AND`).
9. Normalise each nutrient per 100 kcal.
10. Min-max scale each nutrient to 0-1.
11. Calculate the health score with the formula above.
12. Check every item against the six standard criteria and count the checks passed.
13. Average the health score and checks passed per chain, and rank the chains both ways.
14. Pick the best meal for each chain and the best item overall.
15. Build the charts in Tableau or Google Sheets.

---

## Assumptions & Limitations

- The score is **relative**: min-max scaling means a chain's result depends on the other items in this dataset.
- All nutrients are weighted equally.
- Scoring per 100 kcal does not account for portion size.
- Items with zero or very few calories can distort the per-100-kcal values.
- Beverages are excluded, so the results cover meals and food items only, not drinks.
- Rows with any missing nutrient value were left out, so only items with complete data are scored.
- The `+3` and `÷5` in the formula were chosen by trial and error.
- The data is a snapshot, and menus change over time.
- Standard criteria are general guidelines, not personalised advice.
- This is a learning project and not medical or dietary advice.

---

## About

Built by Sai Chanchal Kshirsagar as part of my data analytics learning journey.
