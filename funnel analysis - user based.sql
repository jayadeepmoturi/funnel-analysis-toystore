use fuzzy_factory;

select * from website_pageviews;
select * from website_sessions;
select * from orders;

-- how many visitors are we getting in the website / how busy is the website ?
select count(user_id) from website_sessions;
select date_format(created_at,'%Y-%m') as cohort,count(user_id) from website_sessions group by date_format(created_at,'%Y-%m') order by date_format(created_at,'%Y-%m');
-- where are visitors comming from?
select utm_source,  count(distinct user_id) as user_count from website_sessions group by utm_source   order by user_count desc;
select utm_campaign,count(distinct user_id) as user_count from website_sessions group by utm_campaign order by user_count desc;
select utm_content ,count(distinct user_id) as user_count from website_sessions group by utm_content  order by user_count desc ;
select device_type ,count(distinct user_id) as user_count from website_sessions group by device_type  order by user_count desc ;
select http_referer,count(distinct user_id) as user_count from website_sessions group by http_referer  order by user_count desc ;
-- ====================================================================================================================================================
drop view if exists user_events;
create view  user_events as (
select ws.website_session_id,
       ws.created_at,
       ws.user_id,
       wp.pageview_url,
       device_type,
       utm_source,
       utm_campaign,
       utm_content
from website_pageviews wp
left join website_sessions ws
on wp.website_session_id = ws.website_session_id
);
select * from user_events;

with pivoted as(
select 
     user_id,
     min(case when pageview_url in ('/home','/lander-1','/lander-2','/lander-3','/lander-4','/lander-5') then created_at end) as t1,
     min(case when pageview_url = '/products'then created_at end) as t2,
     min(case when pageview_url = '/cart'then created_at end) as t3,
     min(case when pageview_url = '/shipping'then created_at end) as t4,
     min(case when pageview_url in ('/billing', '/billing-2')then created_at end) as t5,
     min(case when pageview_url = '/thank-you-for-your-order'then created_at end) as t6
from user_events
group by user_id
)
  select 
     count(case when t1 is not null then user_id end) as step_1,
     count(case when t1 is not null and t2>=t1 then user_id end) as step_2,
     count(case when t2>=t1 and t3>=t2 then user_id end) as step_3,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 then user_id end) as step_4,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 and t5>=t4 then user_id end) as step_5,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 and t5>=t4 and t6>=t5 then user_id end) as step_6
from pivoted;

-- ====================================================================================================================================================
with pivoted as(
select 
     user_id,
     min(case when pageview_url in ('/home','/lander-1','/lander-2','/lander-3','/lander-4','/lander-5') then created_at end) as t1,
     min(case when pageview_url = '/products'then created_at end) as t2,
     min(case when pageview_url = '/cart'then created_at end) as t3,
     min(case when pageview_url = '/shipping'then created_at end) as t4,
     min(case when pageview_url in ('/billing', '/billing-2')then created_at end) as t5,
     min(case when pageview_url = '/thank-you-for-your-order'then created_at end) as t6
from user_events
group by user_id
),
step_counts as(
select '1' as step_number,'landing_page' as step_name,count(case when t1 is not null then user_id end) as users_count from pivoted 
union all
select '2','product_view',count(case when t1 is not null and t2>=t1 then user_id end) from pivoted
union all
select '3','cart_view',count(case when t2>=t1 and t3>=t2 then user_id end) from pivoted
union all
select '4','shipping',count(case when t2>=t1 and t3>=t2 and t4>=t3 then user_id end) from pivoted
union all
select '5','billing',count(case when t2>=t1 and t3>=t2 and t4>=t3 and t5>=t4 then user_id end) from pivoted
union all
select '6','purchase',count(case when t2>=t1 and t3>=t2 and t4>=t3 and t5>=t4 and t6>=t5 then user_id end) from pivoted 
)
select *,
       round(100.0*users_count/first_value(users_count)over(order by step_number asc),2) as step_conv_pct,
       round(100.0*users_count/lag(users_count)over(order by step_number asc),2) as overall_conv_pct,
       (lag(users_count)over(order by step_number asc) - users_count)as dropped_users,
	   round(100.0*(lag(users_count)over(order by step_number asc) - users_count)/lag(users_count)over(order by step_number asc),2) as dropoff_pct
from  step_counts;

-- ====================================================================================================================================================

with pivoted as(
select 
     user_id,
     min(case when pageview_url in ('/home','/lander-1','/lander-2','/lander-3','/lander-4','/lander-5') then created_at end) as t1,
     min(case when pageview_url = '/products'then created_at end) as t2,
     min(case when pageview_url = '/cart'then created_at end) as t3,
     min(case when pageview_url = '/shipping'then created_at end) as t4,
     min(case when pageview_url in ('/billing', '/billing-2')then created_at end) as t5,
     min(case when pageview_url = '/thank-you-for-your-order'then created_at end) as t6
from user_events
group by user_id
)
  select 
     count(case when t1 is not null then user_id end) as step_1,
     count(case when t1 is not null and t2>=t1 then user_id end) as step_2,
     count(case when t2>=t1 and t3>=t2 then user_id end) as step_3,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 then user_id end) as step_4,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 and t5>=t4 then user_id end) as step_5,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 and t5>=t4 and t6>=t5 then user_id end) as step_6
from pivoted;

-- ====================================================================================================================================================
with pivoted as(
select 
     user_id,
     device_type,
     min(case when pageview_url in ('/home','/lander-1','/lander-2','/lander-3','/lander-4','/lander-5') then created_at end) as t1,
     min(case when pageview_url = '/products'then created_at end) as t2,
     min(case when pageview_url = '/cart'then created_at end) as t3,
     min(case when pageview_url = '/shipping'then created_at end) as t4,
     min(case when pageview_url in ('/billing', '/billing-2')then created_at end) as t5,
     min(case when pageview_url = '/thank-you-for-your-order'then created_at end) as t6
from user_events
group by user_id,device_type
)
select 
     device_type,
     count(case when t1 is not null then user_id end) as step_1,
     count(case when t1 is not null and t2>=t1 then user_id end) as step_2,
     count(case when t2>=t1 and t3>=t2 then user_id end) as step_3,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 then user_id end) as step_4,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 and t5>=t4 then user_id end) as step_5,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 and t5>=t4 and t6>=t5 then user_id end) as step_6
from pivoted
group by device_type;

-- ====================================================================================================================================================

with pivoted as(
select 
     user_id,
     utm_source,
     min(case when pageview_url in ('/home','/lander-1','/lander-2','/lander-3','/lander-4','/lander-5') then created_at end) as t1,
     min(case when pageview_url = '/products'then created_at end) as t2,
     min(case when pageview_url = '/cart'then created_at end) as t3,
     min(case when pageview_url = '/shipping'then created_at end) as t4,
     min(case when pageview_url in ('/billing', '/billing-2')then created_at end) as t5,
     min(case when pageview_url = '/thank-you-for-your-order'then created_at end) as t6
from user_events
group by user_id,utm_source
)
select 
     utm_source,
     count(case when t1 is not null then user_id end) as step_1,
     count(case when t1 is not null and t2>=t1 then user_id end) as step_2,
     count(case when t2>=t1 and t3>=t2 then user_id end) as step_3,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 then user_id end) as step_4,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 and t5>=t4 then user_id end) as step_5,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 and t5>=t4 and t6>=t5 then user_id end) as step_6
from pivoted
group by utm_source;
-- ====================================================================================================================================================
with pivoted as(
select 
     user_id,
     utm_campaign,
     min(case when pageview_url in ('/home','/lander-1','/lander-2','/lander-3','/lander-4','/lander-5') then created_at end) as t1,
     min(case when pageview_url = '/products'then created_at end) as t2,
     min(case when pageview_url = '/cart'then created_at end) as t3,
     min(case when pageview_url = '/shipping'then created_at end) as t4,
     min(case when pageview_url in ('/billing', '/billing-2')then created_at end) as t5,
     min(case when pageview_url = '/thank-you-for-your-order'then created_at end) as t6
from user_events
group by user_id,utm_campaign
)
select 
     utm_campaign,
     count(case when t1 is not null then user_id end) as step_1,
     count(case when t1 is not null and t2>=t1 then user_id end) as step_2,
     count(case when t2>=t1 and t3>=t2 then user_id end) as step_3,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 then user_id end) as step_4,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 and t5>=t4 then user_id end) as step_5,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 and t5>=t4 and t6>=t5 then user_id end) as step_6
from pivoted
group by utm_campaign;
-- ====================================================================================================================================================
with pivoted as(
select 
     user_id,
     utm_content,
     min(case when pageview_url in ('/home','/lander-1','/lander-2','/lander-3','/lander-4','/lander-5') then created_at end) as t1,
     min(case when pageview_url = '/products'then created_at end) as t2,
     min(case when pageview_url = '/cart'then created_at end) as t3,
     min(case when pageview_url = '/shipping'then created_at end) as t4,
     min(case when pageview_url in ('/billing', '/billing-2')then created_at end) as t5,
     min(case when pageview_url = '/thank-you-for-your-order'then created_at end) as t6
from user_events
group by user_id,utm_content
)
select 
     utm_content,
     count(case when t1 is not null then user_id end) as step_1,
     count(case when t1 is not null and t2>=t1 then user_id end) as step_2,
     count(case when t2>=t1 and t3>=t2 then user_id end) as step_3,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 then user_id end) as step_4,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 and t5>=t4 then user_id end) as step_5,
     count(case when t2>=t1 and t3>=t2 and t4>=t3 and t5>=t4 and t6>=t5 then user_id end) as step_6
from pivoted
group by utm_content;

