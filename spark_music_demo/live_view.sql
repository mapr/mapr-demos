SELECT
CAST(`row_key` AS INTEGER) AS `custid`,
CAST(`t`.`ldata`['morn_tracks'] AS FLOAT) AS `avg_morn`,
CAST(`t`.`ldata`['aft_tracks'] AS FLOAT) AS `avg_aft`,
CAST(`t`.`ldata`['eve_tracks'] AS FLOAT) AS `avg_eve`,
CAST(`t`.`ldata`['night_tracks'] AS FLOAT) AS `avg_night`, CAST(`t`.`ldata`['unique_tracks'] AS FLOAT) AS `avg_unique`,
CAST(`t`.`ldata`['mobile_tracks'] AS FLOAT) AS `avg_mobile`
FROM `dfs`.`default`.`./user/mapr/live_table` AS `t`
