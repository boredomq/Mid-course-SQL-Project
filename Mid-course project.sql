USE mavenfuzzyfactory;

-- QUESTION 1 : Gsearch seems to be the biggest driver of our business. 
-- Could you pull monthly trends for gsrearch sessions adnd orders so that we can showcase the growth there

SELECT
	COUNT(DISTINCT order_id) AS amount_of_orders,
    COUNT(DISTINCT ws.website_session_id) AS amount_of_Sessions,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT ws.website_session_id) as conversion_rate,
    date_format((ws.created_at), '%M') as months,
    min(date(ws.created_at)) AS first_date_month
FROM website_sessions ws
	LEFT JOIN orders o 
		ON ws.website_session_id = o.website_session_id
WHERE ws.utm_source = 'gsearch'
	AND ws.created_at < '2012-11-27' -- predefined date in the assignment
GROUP BY 4
ORDER BY first_date_month;
-- We can see that from the start of the website site till the predefined date there is steady growth of orders


-- QUESTION 2 :
	-- Next, it would be great to see similar monthly trend for Gsearch, but this time splitting out nonbrand and brand campaigns separately. 

SELECT
	date_format((ws.created_at), '%M') AS mo,
	YEAR(ws.created_at) AS yr,
    COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS nonbrand_sessions,
    COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS nonbrand_orders,
    COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END)/COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS nonbrand_conv_rt,
    COUNT(CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS brand_sessions,
    COUNT(CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END) AS brand_orders,
    COUNT(CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END)/COUNT(CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS brand_conv_rt
FROM
	website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id = o.website_session_id
WHERE ws.utm_source = 'gsearch'
	AND ws.created_at < '2012-11-27'
GROUP BY 1,2
ORDER BY min(date(ws.created_at));
-- We can see that even brand conv rate is better than nonbrand, nonbrand channel brings in much more orders


-- QUESTION 3 :
	-- While we're on Gsearch, could you please dive into nonbrand, and pull monthly sessions and orders split by device type. 

-- Step 1 - check for devices used to enter the site

SELECT DISTINCT device_type
FROM website_sessions; 

-- there're only MOBILE and DESKTOP

SELECT 
	date_format((ws.created_at), '%M') AS mo,
	YEAR(ws.created_at) AS yr,
    COUNT(CASE WHEN device_type = 'mobile' THEN ws.website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(CASE WHEN device_type = 'mobile' THEN o.order_id ELSE NULL END) AS mobile_orders,
    COUNT(CASE WHEN device_type = 'desktop' THEN ws.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(CASE WHEN device_type = 'desktop' THEN o.order_id ELSE NULL END) AS desktop_orders,
    COUNT(CASE WHEN device_type = 'desktop' THEN o.order_id ELSE NULL END) / COUNT(CASE WHEN device_type = 'mobile' THEN o.order_id ELSE NULL END) as diff_in_orders
FROM
	website_sessions ws
    LEFT JOIN 
		orders o
        ON ws.website_session_id = o.website_session_id
WHERE 
	utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
    AND ws.created_at < '2012-11-27'
GROUP BY 1,2;

-- As we can see, desktop sessions and orders prevail over mobile ones

-- QUESTION 4 :
	-- Can you pull monthly trends for Gearch, alongside monthly trends for each of our other channeles 
    
-- first of all we check what are other channels

SELECT DISTINCT 
	utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE created_at < '2012-11-27';

-- There're (gsearch - nonbrand - https://www.gsearch.com) 
-- (NULL - NULL - NULL) that means direct type-in traffic
-- (gsearch - brand - https://www.gsearch.com)
-- (NULL - NULL - https://www.gsearch.com) - organic gsearch traffic 
-- (bsearch - brand - https://www.bsearch.com)
-- (NULL - NULL - https://www.bsearch.com) - organic bsearch traffic 
-- (bsearch - nonbrand - https://www.bsearch.com)



SELECT
	DATE_FORMAT((ws.created_at), '%M') AS mo,
	YEAR(ws.created_at) AS yr,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN ws.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN ws.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN ws.website_session_id ELSE NULL END) AS organic_search_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN ws.website_session_id ELSE NULL END) AS direct_type_in_sessions
FROM website_sessions ws
WHERE ws.created_at < '2012-11-27'
GROUP BY 1,2
ORDER BY MIN(DATE(ws.created_at));

-- As we can see, there's growth across all channels, especially in non-paid ones, the board can be excited about that growth as these are sessions a company don't pay for 



-- QUESTION 5 :
	-- Could you pull session to order conversion rates, by month
 

SELECT
	YEAR(ws.created_at) AS yr,
	MONTH(ws.created_at) AS mo,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conversion_rate
FROM website_sessions ws
	LEFT JOIN orders o 
		ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2012-11-27'
GROUP BY 1,2
ORDER BY 1,2
;
    
-- We can see a climb-up from 3% in the first month to 4% in the last one


-- QUESTION 6 :
	-- For the gsearch lander test, please estimate the revenue that test earned us 

-- estimating when the new landing page (/landing-1) was established

SELECT
	MIN(created_at),
    MIN(website_session_id),
    MIN(website_pageview_id)
FROM website_pageviews
WHERE pageview_url = '/lander-1';


-- first pageview_id with /lander-1 is 23504


CREATE TEMPORARY TABLE first_test_pageviews
SELECT 
	wp.website_session_id,
    MIN(wp.website_pageview_id) as first_pageview
FROM website_pageviews wp
	JOIN website_sessions ws 
		On wp.website_session_id = ws.website_session_id
		AND ws.created_at < '2012-07-28' -- prescribed by the assignment
        AND wp.website_pageview_id >= 23504
        AND ws.utm_source = 'gsearch'
        AND ws.utm_campaign = 'nonbrand'
GROUP BY wp.website_session_id;

SELECT * FROM first_test_pageviews;


CREATE TEMPORARY TABLE nonbrand_test_session_w_landings
SELECT
	ftp.website_session_id,
	wp.pageview_url AS landing_page
FROM first_test_pageviews ftp
	LEFT JOIN website_pageviews wp
		ON ftp.first_pageview = wp.website_pageview_id
WHERE wp.pageview_url IN ('/home', '/lander-1');

SELECT * FROM nonbrand_test_session_w_landings;

CREATE TEMPORARY TABLE nonbrand_test_session_w_orders
SELECT 
	ntswl.website_session_id,
    ntswl.landing_page,
    o.order_id
FROM nonbrand_test_session_w_landings ntswl
	LEFT JOIN orders o 
		ON ntswl.website_session_id = o.website_session_id;

		
SELECT * FROM nonbrand_test_session_w_orders;

SELECT 
	Landing_page,
    COUNT(website_session_id) AS sessions,
    COUNT(order_id) AS orders,
    COUNT(order_id) / COUNT(website_session_id) AS conv_rt
FROM nonbrand_test_session_w_orders
GROUP BY Landing_page;

-- for lander-1 - 0.0406; for home - 0.318 
-- additional .0087 orders per session

-- finding the most recent pageview for gsearch nonbrand where the traffic was sent to /home

SELECT
	MAX(ws.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview
FROM website_sessions ws
	LEFT JOIN website_pageviews wp
		ON ws.website_session_id = wp.website_session_id
WHERE utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
    AND pageview_url = '/home'
    AND ws.created_at < '2012-11-27';

-- max website_session_id = 17145

SELECT 
	COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE created_at < '2012-11-27'
	AND website_session_id > 17145 -- last /home session
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand';

-- 22972 website sessions since the test

-- now we can multiply 22972 sessions by additional .0087 orders per session 
-- we get 200 additional orders for 4 months

-- QUESTION 7 :
	-- For the landing page test you analyzed previously, it would be great to show FULL CONVERSION FUNNEL FROM EACH  OF THE TWO PAGES TO ORDERS
    -- Period of time jun 19 - jul 28

-- Creating table with dummies 
    
SELECT
	ws.website_session_id,
    wp.pageview_url,
    CASE WHEN wp.pageview_url = '/home' THEN 1 ELSE 0 END AS home_page,
    CASE WHEN wp.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_page,
    CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
    CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thanks_page
FROM website_sessions ws
	LEFT JOIN website_pageviews wp 
		ON ws.website_session_id = wp.website_session_id
WHERE ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand'
    AND ws.created_at < '2012-07-28'
    AND ws.created_at > '2012-06-19'
ORDER BY 
	ws.website_session_id,
    wp.created_at;
    
-- using subquery to make a complete table and then wrap it up in temporary table
CREATE TEMPORARY TABLE sessions_level_made_it
SELECT
	website_session_id,
    MAX(home_page) as saw_homepage,
	MAX(lander_page) as saw_landerpage,
    MAX(product_page) as product_made_it,
    MAX(mrfuzzy_page) as mrfuzzy_made_it,
    MAX(cart_page) as cart_made_it,
	MAX(shipping_page) as shipping_made_it,
    MAX(billing_page) as billing_made_it,
    MAX(thanks_page) as thanks_made_it
FROM ( 
	SELECT
		ws.website_session_id,
		wp.pageview_url,
		CASE WHEN wp.pageview_url = '/home' THEN 1 ELSE 0 END AS home_page,
		CASE WHEN wp.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_page,
		CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
		CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
		CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
		CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
		CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
		CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thanks_page
	FROM website_sessions ws
		LEFT JOIN website_pageviews wp 
			ON ws.website_session_id = wp.website_session_id
	WHERE ws.utm_source = 'gsearch'
		AND ws.utm_campaign = 'nonbrand'
		AND ws.created_at < '2012-07-28'
		AND ws.created_at > '2012-06-19'
	ORDER BY 
		ws.website_session_id,
		wp.created_at
	) as pageview_level
GROUP BY website_session_id;

SELECT * FROM sessions_level_made_it;


-- final output part 1 
SELECT 
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_landerpage = 1 THEN  'saw_landerpage'
        ELSE 'check logic'
	END as segment,
    COUNT(DISTINCT website_session_id) AS overall_sessions,
    COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(CASE WHEN thanks_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thanks
FROM sessions_level_made_it
GROUP BY 1;


-- final output part 2
SELECT 
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_landerpage = 1 THEN  'saw_landerpage'
        ELSE 'check logic'
	END as segment,
    COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id)  AS lander_click_rate,
    
    COUNT(CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) /  COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS product_click_rate,
    
    COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rate,
    
    COUNT(CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rate,
    
    COUNT(CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rate,
    
    COUNT(CASE WHEN thanks_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rate
    FROM sessions_level_made_it
GROUP BY 1;

-- as we can see, larder-1 page has better results in almost every aspect

-- QUESTION 8 :
	-- Quantify the impact of billing test. Analyze the lift in terms of revenue per billing page session and pull the numer of billing page sessions for the past month
    -- Period of time Sep - 10 Nov 10
 
 
SELECT 
	billing_ver,
    COUNT(DISTINCT website_session_id) AS sessions,
    SUM(price_usd) / COUNT(DISTINCT website_session_id) AS revenue_per_billing_page
FROM
	(SELECT 
	wp.website_session_id,
    wp.pageview_url AS billing_ver,
    o.order_id,
    o.price_usd
FROM 
	website_pageviews wp
    LEFT JOIN orders o 
		ON wp.website_session_id = o.website_session_id
WHERE pageview_url IN ('/billing', '/billing-2')
	AND wp.created_at < '2012-11-10'
    AND wp.created_at > '2012-9-10') AS billing_pageviews_and_order_data
GROUP BY 1;

-- $22.8 revenue per billing page seen for the old version
-- $31.34 for the new version
-- LIFT: $8.51 per billing page view
   
SELECT 
	COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews
WHERE pageview_url IN ('/billing', '/billing-2')
	AND created_at BETWEEN '2012-10-27' AND '2012-11-27' -- ~past montn~

-- 1,194 billing sessions past month
-- LIFT: 8.51 per billing session
-- VALUE OF BILLING TEST: 10,160 over the past month