SELECT
CAST(`row_key` AS INTEGER) AS `custid`,
CAST(`t`.`cdata`['name'] AS VARCHAR(20)) AS `name`,
CAST(`t`.`cdata`['campaign'] AS INTEGER) AS `campaign`,
CAST(`t`.`cdata`['gender'] AS INTEGER) AS `gender`,
CAST(`t`.`cdata`['level'] AS INTEGER) AS `level`,
CAST(`t`.`cdata`['address'] AS VARCHAR(40)) AS `address`,
CAST(`t`.`cdata`['zip'] AS VARCHAR(5)) AS `zip`
FROM `dfs`.`default`.`./user/mapr/cust_table` AS `t`
