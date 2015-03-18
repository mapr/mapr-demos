create or replace view dfs.views.tweet_base as
select CAST(t.`id` as BIGINT) as `id`, 
t.dir0 as dir_year,
t.dir1 as dir_month,
t.dir2 as dir_day,
t.dir3 as dir_hour, 
CAST(t.`timestamp_ms` as BIGINT) as EPOC,
to_date ((concat (substring(t.`created_at`, 5,6),substring(t.`created_at`, 26,5))), 'MMM dd yyyy') as `date`,
to_timestamp ((concat (substring(t.`created_at`, 5,6),substring(t.`created_at`, 26,5),substring(t.`created_at`, 11,9))), 'MMM dd yyyy HH:mm:ss') as `timestamp`,
to_timestamp ((concat (substring(t.`created_at`, 5,6),substring(t.`created_at`, 26,5),substring(t.`created_at`, 11,6),':00')), 'MMM dd yyyy HH:mm:ss') as `timestamp_min`,
to_timestamp ((concat (substring(t.`created_at`, 5,6),substring(t.`created_at`, 26,5),substring(t.`created_at`, 11,3),':00:00')), 'MMM dd yyyy HH:mm:ss') as `timestamp_hour`,
CAST(regexp_replace(t.`text`, '[^ -~¡-ÿ]', '°') as VARCHAR(300)) as `tweet`,
CAST(t.`favorite_count` as INT) as `favorite_count_tweet`,
CAST(t.`retweet_count` as INT) as `retweet_count`,
CAST(t.`source` as VARCHAR(140)) as `source`,
CAST(t.`lang` as VARCHAR(10)) as `language_tweet`,
CAST(t.`user`.`id` as BIGINT) as `user_id`,
CAST(t.`user`.`name` as VARCHAR(40)) as `username`,
CAST(t.`user`.`screen_name` as VARCHAR(40)) as `screen_name`,
CAST(t.`user`.`location` as VARCHAR(80)) as `user_location`,
CAST(t.`user`.`followers_count` as INT) as `followers_count`,
CAST(t.`user`.`favorites_count` as INT) as `favorites_count_user`,
CAST(t.`user`.`friends_count` as INT) as `friends_count`,
CAST(t.`user`.`statuses_count` as INT) as `statuses_count`
from dfs.twitter.`/feed` t;


create or replace view dfs.views.`tweet_hashtags` as
select CAST(tmp.`id` as BIGINT) as `id_hash`,
tmp.dir0 as dir_year_hash,
tmp.dir1 as dir_month_hash,
tmp.dir2 as dir_day_hash,
tmp.dir3 as dir_hour_hash,
`date`,  
CAST(tmp.hash.text as VARCHAR(40)) as hashtag
from 
(select t.id,
t.dir0,
t.dir1,
t.dir2,
t.dir3, 
to_date ((concat (substring(t.`created_at`, 5,6),substring(t.`created_at`, 26,5))), 'MMM dd yyyy') as `date`,
flatten(t.hashtags) as hash
from 
(select tag.id,
tag.dir0,
tag.dir1,
tag.dir2,
tag.dir3, 
tag.`created_at`,
tag.entities.hashtags as hashtags
from dfs.twitter.`/feed` tag where tag.entities.hashtags[0].text is not null) as t) as tmp;

create or replace view dfs.views.retweeted as
select CAST(t.`id` as BIGINT) as `id_rt`, 
CAST(t.retweeted_status.`id` as BIGINT) as `retweet_id`,
t.dir0 as dir_year_rt,
t.dir1 as dir_month_rt,
t.dir2 as dir_day_rt,
t.dir3 as dir_hour_rt,
to_date ((concat (substring(t.`created_at`, 5,6),substring(t.`created_at`, 26,5))), 'MMM dd yyyy') as `date`,
to_date ((concat (substring(t.retweeted_status.`created_at`, 5,6),substring(t.retweeted_status.`created_at`, 26,5))), 'MMM dd yyyy') as `date_rt`,
to_timestamp ((concat (substring(t.retweeted_status.`created_at`, 5,6),substring(t.retweeted_status.`created_at`, 26,5),substring(t.retweeted_status.`created_at`, 11,9))), 'MMM dd yyyy HH:mm:ss') as `timestamp_rt`,
CAST(regexp_replace(t.retweeted_status.`text`, '[^ -~¡-ÿ]', '°') as VARCHAR(300)) as `retweet`,
CAST(t.retweeted_status.`favorite_count` as INT) as `favorite_count_retweet`,
CAST(t.retweeted_status.`retweet_count` as INT) as `retweet_count_rt`,
CAST(t.retweeted_status.`source` as VARCHAR(140)) as `source_rt`,
CAST(t.retweeted_status.`lang` as VARCHAR(10)) as `language_rt`,
CAST(t.retweeted_status.`user`.`id` as BIGINT) as `user_id_rt`,
CAST(t.retweeted_status.`user`.`name` as VARCHAR(40)) as `username_rt`,
CAST(t.retweeted_status.`user`.`screen_name` as VARCHAR(40)) as `screen_name_rt`,
CAST(t.retweeted_status.`user`.`location` as VARCHAR(80)) as `user_location_rt`,
CAST(t.retweeted_status.`user`.`followers_count` as INT) as `followers_count_rt`,
CAST(t.retweeted_status.`user`.`favorites_count` as INT) as `favorites_count_user_rt`
from dfs.twitter.`/feed` t where t.retweeted_status.id is not null;
