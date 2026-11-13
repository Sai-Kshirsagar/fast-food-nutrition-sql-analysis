UPDATE `project-d129c4ea-acf9-44f7-91d.Project.fast_food_nutritionV5`
SET Item = REGEXP_REPLACE(Item, r'["“”‘’`]', '')
WHERE REGEXP_CONTAINS(Item, r'["“”‘’`]');