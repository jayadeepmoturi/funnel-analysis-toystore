use fuzzy_factory;

select * from website_pageviews;
select * from website_sessions;
select * from orders;

-- 1.step wise session count
with made_session_level as(
  select 
      s.website_session_id,
      max(case when p.pageview_url in('/home','/lander-1','/lander-2','/lander-3','/lander-4','/lander-5') then 1 else 0 end) as saw_homepage,
      max(case when p.pageview_url = '/products' then 1 else 0 end) as saw_products,
      max(case when p.pageview_url in('/the-original-mr-fuzzy','/the-forever-love-bear','/the-birthday-sugar-panda','/the-hudson-river-mini-bear') then 1 else 0 end) as saw_product_details,
      max(case when p.pageview_url = '/cart' then 1 else 0 end) as saw_cart,
      max(case when p.pageview_url = '/shipping' then 1 else 0 end) as saw_shipping,
      max(case when p.pageview_url in('/billing','/billing-2') then 1 else 0 end) as saw_billing,
      max(case when p.pageview_url = '/thank-you-for-your-order' then 1 else 0 end) as saw_thank_you,
      max(case when o.order_id is not null then 1 else 0 end) as made_order
from website_sessions s
left join website_pageviews p on s.website_session_id = p.website_session_id
left join orders o on s.website_session_id = o.website_session_id
group by s.website_session_id
)
select
      count(website_session_id) as total_sessions,
      sum(saw_products) as products,
	  sum(saw_product_details) as product_details,
      sum(saw_cart) as cart,
      sum(saw_shipping) as shipping,
      sum(saw_billing) as billing,
      sum(saw_thank_you) as thank_you,
      sum(made_order) as orders
from made_session_level;
-- ====================================================================================================================================================
-- 2.Click through rates of sessions for each step
with made_session_level as(
    select  
      s.website_session_id,
      max(case when p.pageview_url in('/home','/lander-1','/lander-2','/lander-3','/lander-4','/lander-5') then 1 else 0 end) as saw_homepage,
      max(case when p.pageview_url = '/products' then 1 else 0 end) as saw_products,
      max(case when p.pageview_url in('/the-original-mr-fuzzy','/the-forever-love-bear','/the-birthday-sugar-panda','/the-hudson-river-mini-bear') then 1 else 0 end) as saw_product_details,
      max(case when p.pageview_url = '/cart' then 1 else 0 end) as saw_cart,
      max(case when p.pageview_url = '/shipping' then 1 else 0 end) as saw_shipping,
      max(case when p.pageview_url in('/billing','/billing-2') then 1 else 0 end) as saw_billing,
      max(case when p.pageview_url = '/thank-you-for-your-order' then 1 else 0 end) as saw_thank_you,
      max(case when o.order_id is not null then 1 else 0 end) as made_order
from website_sessions s
left join website_pageviews p on s.website_session_id = p.website_session_id
left join orders o on s.website_session_id = o.website_session_id
group by s.website_session_id
),
funnel_counts as(
select
      count(website_session_id) as total_sessions,
      sum(saw_products) as products,
	  sum(saw_product_details) as product_details,
      sum(saw_cart) as cart,
      sum(saw_shipping) as shipping,
      sum(saw_billing) as billing,
      sum(saw_thank_you) as thank_you,
      sum(made_order) as orders
from made_session_level
)
select 
     round(100.0*products/total_sessions,2) as lander_to_products_ctr,
     round(100.0*product_details/products,2) as products_to_detail_ctr,
     round(100.0*cart/product_details,2) as detail_to_cart_ctr,
     round(100.0*shipping/cart,2) as cart_to_shipping_ctr,
     round(100.0*billing/shipping,2) as shipping_to_billing_ctr,
     round(100.0*thank_you/billing,2) as billing_to_thankyou_ctr,
     round(100.0*orders/billing,2) as billing_to_order_ctr,
     round(100.0*orders/total_sessions,2) as overall_conversion
from funnel_counts;

-- ====================================================================================================================================================
-- 3.dropoff rates of sessions for each step
with made_session_level as(
    select  
      s.website_session_id,
      max(case when p.pageview_url in('/home','/lander-1','/lander-2','/lander-3','/lander-4','/lander-5') then 1 else 0 end) as saw_homepage,
      max(case when p.pageview_url = '/products' then 1 else 0 end) as saw_products,
      max(case when p.pageview_url in('/the-original-mr-fuzzy','/the-forever-love-bear','/the-birthday-sugar-panda','/the-hudson-river-mini-bear') then 1 else 0 end) as saw_product_details,
      max(case when p.pageview_url = '/cart' then 1 else 0 end) as saw_cart,
      max(case when p.pageview_url = '/shipping' then 1 else 0 end) as saw_shipping,
      max(case when p.pageview_url in('/billing','/billing-2') then 1 else 0 end) as saw_billing,
      max(case when p.pageview_url = '/thank-you-for-your-order' then 1 else 0 end) as saw_thank_you,
      max(case when o.order_id is not null then 1 else 0 end) as made_order
from website_sessions s
left join website_pageviews p on s.website_session_id = p.website_session_id
left join orders o on s.website_session_id = o.website_session_id
group by s.website_session_id
),
funnel_counts as(
select
      count(website_session_id) as total_sessions,
      sum(saw_products) as products,
	  sum(saw_product_details) as product_details,
      sum(saw_cart) as cart,
      sum(saw_shipping) as shipping,
      sum(saw_billing) as billing,
      sum(saw_thank_you) as thank_you,
      sum(made_order) as orders
from made_session_level
),
 ctr as(
select 
     round(100.0*products/total_sessions,2) as lander_to_products_ctr,
     round(100.0*product_details/products,2) as products_to_detail_ctr,
     round(100.0*cart/product_details,2) as detail_to_cart_ctr,
     round(100.0*shipping/cart,2) as cart_to_shipping_ctr,
     round(100.0*billing/shipping,2) as shipping_to_billing_ctr,
     round(100.0*thank_you/billing,2) as billing_to_thankyou_ctr,
     round(100.0*orders/billing,2) as billing_to_order_ctr,
     round(100.0*orders/total_sessions,2) as overall_conversion
from funnel_counts
)
select 
     round((100-lander_to_products_ctr),2) as lander_dropoff_rate,
     round((100-products_to_detail_ctr),2) as products_dropoff_rate,
     round((100-detail_to_cart_ctr),2) as product_detail_dropoff_rate,
     round((100-cart_to_shipping_ctr),2) as cart_dropoff_rate,
     round((100-shipping_to_billing_ctr),2) as shipping_dropoff_rate,
     round((100-billing_to_thankyou_ctr),2) as billing_dropoff_rate,
     round((100-billing_to_order_ctr),2) as billing_dropoff_rate,
     round((100-overall_conversion),2) as overall_dropoff_rate
from ctr;

-- ====================================================================================================================================================
-- 4.funnel analysis by device type
with made_session_level as(
    select  
      s.website_session_id,
      s.device_type,
      max(case when p.pageview_url in('/home','/lander-1','/lander-2','/lander-3','/lander-4','/lander-5') then 1 else 0 end) as saw_homepage,
      max(case when p.pageview_url = '/products' then 1 else 0 end) as saw_products,
      max(case when p.pageview_url in('/the-original-mr-fuzzy','/the-forever-love-bear','/the-birthday-sugar-panda','/the-hudson-river-mini-bear') then 1 else 0 end) as saw_product_details,
      max(case when p.pageview_url = '/cart' then 1 else 0 end) as saw_cart,
      max(case when p.pageview_url = '/shipping' then 1 else 0 end) as saw_shipping,
      max(case when p.pageview_url in('/billing','/billing-2') then 1 else 0 end) as saw_billing,
      max(case when p.pageview_url = '/thank-you-for-your-order' then 1 else 0 end) as saw_thank_you,
      max(case when o.order_id is not null then 1 else 0 end) as made_order,
	  sum(o.price_usd) as revenue,
      sum(o.price_usd - o.cogs_usd) as margin
from website_sessions s
left join website_pageviews p on s.website_session_id = p.website_session_id
left join orders o on s.website_session_id = o.website_session_id
group by s.website_session_id,s.device_type
),
funnel_counts as(
select
      device_type,
      count(website_session_id) as total_sessions,
      sum(saw_products) as products,
	  sum(saw_product_details) as product_details,
      sum(saw_cart) as cart,
      sum(saw_shipping) as shipping,
      sum(saw_billing) as billing,
      sum(saw_thank_you) as thank_you,
      sum(made_order) as orders,
      sum(revenue) as total_revenue,
      sum(margin) as total_margin
from made_session_level
group by device_type
)
select 
     device_type,
     round(100.0*products/total_sessions,2) as lander_to_products_ctr,
     round(100.0*product_details/products,2) as products_to_detail_ctr,
     round(100.0*cart/product_details,2) as detail_to_cart_ctr,
     round(100.0*shipping/cart,2) as cart_to_shipping_ctr,
     round(100.0*billing/shipping,2) as shipping_to_billing_ctr,
     round(100.0*thank_you/billing,2) as billing_to_thankyou_ctr,
     round(100.0*orders/billing,2) as billing_to_order_ctr,
     round(100.0*orders/total_sessions,2) as overall_conversion,
	 total_revenue,
     total_margin,
     round(total_revenue/total_sessions,2) AS revenue_per_session,
     round(total_revenue/orders,2) AS average_order_value
from funnel_counts
group by device_type;
-- ====================================================================================================================================================
-- 5.Marketing Channel & Campaign Level Funnel Analysis
with session_funnel as(
  select
        s.website_session_id,
        coalesce(s.utm_source,'direct/organic') as source,
        coalesce(s.utm_campaign,'none') as campaign,
        max(case when  p.pageview_url ='/products' then 1 else 0 end)as saw_products,
        max(case when p.pageview_url ='/cart' then 1 else 0 end)as saw_cart,
        max(case when p.pageview_url ='/thank-you-for-your-order' then 1 else 0 end)as saw_thank_you,
	    max(case when o.order_id is not null then 1 else 0 end) as made_order,
	   sum(o.price_usd) as revenue,
       sum(o.price_usd - o.cogs_usd) as margin
 from website_sessions s
 left join website_pageviews p on s.website_session_id = p.website_session_id
 left join orders o on s.website_session_id = o.website_session_id
 group by s.website_session_id,source, campaign
)
select
    source,
    campaign,
    count(website_session_id) as total_sessions,
    
    -- funnel progress
    sum(saw_products) as to_products,
    sum(saw_cart) as to_cart,
    sum(saw_thank_you) as orders,
    
    -- conversion rates
    round(sum(saw_products)*100.0/count(website_session_id), 2) as to_products_ctr,
    round(sum(saw_cart)*100.0/count(website_session_id), 2) as to_cart_rate,
    round(sum(saw_thank_you)*100.0/count(website_session_id), 2) as overall_conv_rate,
    
    -- economics
      sum(revenue) as total_revenue,
      sum(margin) as total_margin,
     round(sum(revenue)/count(website_session_id),2) AS revenue_per_session,
     round(sum(revenue)/sum(made_order),2) AS average_order_value
from session_funnel
group by source, campaign
order by total_sessions desc;
-- ====================================================================================================================================================
