DELETE FROM `project-d129c4ea-acf9-44f7-91d.Project.fast_food_nutritionV5`
WHERE 
  Item IS NULL 
  OR TRIM(LOWER(Item)) = 'null' 
  OR TRIM(Item) = ''     -- As ITEM is a string
  OR TRIM(Item) = '0';
