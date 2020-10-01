USE yelp_project;

###check those stores with special attributes to compare their star rate and review counts
SELECT 
    r.state,r.city,r.stars,
    CASE
        WHEN b.Alcohol = "True" THEN 1
        ELSE 0
    END Alcohol,
    CASE
        WHEN b.Caters = "True" THEN 1
        ELSE 0
    END Caters,
    CASE
        WHEN b.HappyHour = "True" THEN 1
        ELSE 0
    END HappyHour,
	CASE
        WHEN b.WheelchairAccessible = "True" THEN 1
        ELSE 0
    END Wheelchairaccessibles,
	CASE
        WHEN b.DogsAllowed = "True" THEN 1
        ELSE 0
    END Dogsallowed,
    COUNT(*) restaurant_count
    FROM
    attributes b
        LEFT JOIN
   business r ON b.business_id = r.business_id
   group by state, city, stars;

###check different checkin by star rating
select * from check_in;

SELECT 
    b.business_id,b.name,b.city, c.hour,
    CASE
        WHEN c.weekday = 'Sun' THEN SUM(c.checkin)
    END 'Sun',
    CASE
        WHEN c.weekday = 'Mon' THEN SUM(c.checkin)
    END 'Mon',
    CASE
        WHEN c.weekday = 'Tue' THEN SUM(c.checkin)
    END 'Tue',
    CASE
        WHEN c.weekday = 'Wed' THEN SUM(c.checkin)
    END 'Wed',
    CASE
        WHEN c.weekday = 'Thu' THEN SUM(c.checkin)
    END 'Thu',
    CASE
        WHEN c.weekday = 'Fri' THEN SUM(c.checkin)
    END 'Fri',
    CASE
        WHEN c.weekday = 'Sat' THEN SUM(c.checkin)
    END 'Sat'
FROM
    check_in c
        LEFT JOIN
    business b ON b.business_id = c.business_id
GROUP BY b.business_id,b.name,b.city,c.hour,weekday;

###check by state restaurants rating, review count, average income level, check in times
SELECT 
    i.STATE,
    AVG(cast(stars as signed)),
    SUM(review_count),
    AVG(i.AverageIncome),
    SUM(checkin)
FROM
    business br
        LEFT JOIN
    income i ON br.postal_code = i.zipcode
        LEFT JOIN
    check_in c ON br.business_id = c.business_id
GROUP BY i.state;

###compare yelp reviews with tweets
SELECT 
    b.business_id,
    t.twitter_account,
    b.name,
    b.stars,
    COUNT(DISTINCT re.review_id) AS yelp_reviews,
    t.followers_count AS twitter_followers
FROM
    business AS b
INNER JOIN
    yelp_review AS re
INNER JOIN
    business_twitter_account AS t 
ON 
 b.business_id = re.business_id AND
 b.business_id = t.business_id
GROUP BY
 b.business_id, t.twitter_account;

##others
CREATE VIEW top_3 AS
    SELECT 
        *
    FROM
        business
    WHERE
        business_id IN ('faPVqws-x-5k2CQKDNtHxw' , '4JNXUYY8wbaaDmk3BPzlWw',
            'f4x1YBxkLrZg652xt2KR5g');

SELECT 
    *
FROM
    business
LIMIT 5;

SELECT 
    *
FROM
   yelp_review
LIMIT 50;
SELECT 
    *
FROM
    review
LIMIT 50;
SELECT 
    *
FROM
    yelp_review;

SELECT 
    business_id
FROM
    business;

SELECT 
    *
FROM
    yelp_users
LIMIT 5000;
SELECT 
    COUNT(user_id)
FROM
    yelp_users;

SELECT 
    *
FROM
    check_in
LIMIT 5000;

SELECT 
    *
FROM
    check_in
WHERE
    business_id = 'business_id';
    
DELETE FROM check_in 
WHERE
    business_id = 'business_id';
    
SELECT 
    COUNT(*)
FROM
    check_in;

SELECT 
    *
FROM
    business
WHERE
    business_id IN ('faPVqws-x-5k2CQKDNtHxw' , '4JNXUYY8wbaaDmk3BPzlWw',
        'f4x1YBxkLrZg652xt2KR5g');

#select attributes for top_3 places;
CREATE VIEW top_3_attributes AS
    SELECT 
        a.*
    FROM
        attributes a
            RIGHT JOIN
        top_3 b ON a.business_id = b.business_id;

#select check-in info for top_3 places;
CREATE VIEW top_3_check_in AS
    SELECT 
        a.*, b.name
    FROM
        check_in a
            RIGHT JOIN
        top_3 b ON a.business_id = b.business_id;

#select income info for top_3 zips;
CREATE VIEW top_3_income AS
    SELECT 
        a.zipcode, a.AverageIncome, b.neighborhood, b.name
    FROM
        income a
            RIGHT JOIN
        top_3 b ON a.zipcode = b.postal_code; 

#select tweeter_tweets info for top_3 places;
CREATE VIEW top_3_tweets AS
    SELECT 
        a.*, b.name
    FROM
        twitter_tweets a
            RIGHT JOIN
        top_3 b ON a.Business_id = b.business_id; 

#select tweeter_users info for top_3 places;
CREATE VIEW top_3_tweets_users AS
    SELECT 
        a.*
    FROM
        twitter_users a
            RIGHT JOIN
        top_3 b ON a.Business_id = b.business_id; 

#selectyelp_review info for top_3 places;
CREATE VIEW top_3_yelp_review_restaurant AS
    SELECT 
        a.*
    FROM
       yelp_review a
            RIGHT JOIN
        top_3 b ON a.Business_id = b.business_id; 

#select yelp_users_restaurant info for top_3 places;
CREATE VIEW top_3_yelp_users_restaurant AS
    SELECT 
        a.*
    FROM
        yelp_users_restaurant a
            RIGHT JOIN
       yelp_review b ON a.user_id = b.user_id
    WHERE
        a.user_id IS NOT NULL;

SELECT 
    SUM(useful)
FROM
    top_3_yelp_review_restaurant
GROUP BY business_id;

SELECT 
    COUNT((review_id))
FROM
    top_3_yelp_review_restaurant
GROUP BY business_id;

SELECT 
    COUNT(*)
FROM
    top_3_yelp_users_restaurant;
