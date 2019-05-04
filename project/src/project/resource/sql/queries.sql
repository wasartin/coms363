use group13;
/*
Q1. List k most retweeted tweets in a given month and a given year; show the retweet count, the tweet
text, the posting user’s screen name, the posting user’s category, the posting user’s sub-category in
descending order of the retweet count
Input: value of k (e.g., 10), month (e.g., 1), and year (e.g., 2016)
Rationale: This query finds k most influential tweets in a given time frame and the users who posted
them.
*/
set @q1_month = 1;
set @q1_year = 2016;
set @k = 10;

PREPARE stmt_q1 FROM'
SELECT t.retweet_count, t.tweet_text, t.screen_name, u.category, u.party
FROM tweets t, users u
WHERE t.screen_name = u.screen_name
    AND @q1_month = t.posted_month
	AND @q1_year = t.posted_year
ORDER BY t.retweet_count DESC LIMIT ?';
EXECUTE stmt_q1 USING @k;

# Project Query Q2
/*
In a given month of a given year, 
find k users who used a given hashtag in a tweet with the most number of retweets; 
show the user’s screen name, user’s category, tweet text, and retweet count in 
descending order of the retweet count.
Input: value of k; hashtag, month, and year
Rationale: This query finds k most influential users who used a hashtag of interest 
that may represent a certain agenda.
*/

SET @k = 10;
SET @q2_month = 1;
SET @q2_year = 2016;
SET @hashtag = 'NewYear';

PREPARE stmt_q2 FROM'
	SELECT t.screen_name, u.category,  t.tweet_text, t.retweet_count
	FROM users u, tweets t, hashtags h
	WHERE h.word = @hashtag 
		AND t.screen_name = u.screen_name 
		AND h.tid = t.tid
		AND @q2_month = t.posted_month
		AND @q2_year = t.posted_year
	ORDER BY t.retweet_count DESC LIMIT ?';
EXECUTE stmt_q2 USING @k;

/*
Q3
Find k hashtags that appeared in the most number of states in a given year; 
list the total number of states the hashtag appeared, the list of the distinct states it appeared, 
and the hashtag itself in descending order of the number of states the hashtag appeared.
Input: value of k, year
Rationale: This query finds k hashtags that are spread across the most number ofstates, which could
indicate a certain agenda that is widely discussed.
Hint: Use concat() to create a list
*/

set @k = 10;
set @q3_year = 2016;

PREPARE stmt_q3 FROM 'SELECT DISTINCT h.word, GROUP_CONCAT(DISTINCT location_state SEPARATOR \', \') as appeared_in, COUNT(DISTINCT location_state) as num_of_states
FROM hashtags h, users u
WHERE h.tid IN
	(SELECT t.tid
		FROM tweets t
        WHERE t.screen_name = u.screen_name
		AND t.posted_year = @q3_year)
GROUP BY h.word
ORDER BY num_of_states DESC LIMIT ?';
EXECUTE stmt_q3 USING @k;

/*
Q6
Find k users who used a certain set of hashtags in their tweets. Show the user’s screen name and the
state to which the user belongs in descending order of the number of followers.
Input: value of k, hashtags (e.g., GOPDebate, DemDebate)
Rationale: This is to find k users who share similar interests.
*/
use group13;
set @k = 11;
set @q6_hashtags = "GOP, DemDebate, GOPDebate"; -- 'gop', GOPDebate, DemDebate are good ones

SELECT DISTINCT u.screen_name, u.location_state
	FROM users u, hashtags h, tweets t
	WHERE u.screen_name = t.screen_name
		AND t.tid = h.tid
		AND ( FIND_IN_SET (h.word, @q6_hashtags) )
	ORDER BY u.followers_count DESC LIMIT 10;

# Project Query Q 10
/*
Find the list of distinct hashtags that appeared in one of the states in a given list in a given month of a given year; 
show the list of the hashtags and the names of the states in which they appeared.
Input from user: list of the state, (e.g., Ohio, Alaska, Alabama), month, year
Rationale: This is to find common interest among the users in the states of interest.
*/
/* Finds the correct information for a list of states.*/

SET @k = 10;
SET @q10_month = 1;
SET @q10_year = 2016;
SET @q10_state_list = "IA,Florida,FL"; # The list must be in this string format.

SELECT DISTINCT h.word, u.location_state
FROM users u, tweets t, hashtags h
WHERE  t.screen_name = u.screen_name 
	AND h.tid = t.tid
    AND ( FIND_IN_SET( u.location_state, @q10_state_list ) )
	AND @q10_month = t.posted_month
	AND @q10_year = t.posted_year
ORDER BY u.location_state;

# Project Query Q 15
/*
Find users in a given sub-category along with the list of URLs used in the user’s tweets 
in a given month of a given year. Show the user’s screen name, the state the user belongs, and the list of URLs
Input: sub-category (e.g., GOP), month, year
Rationale: This query finds URLs shared by a party.
*/
/* Shows multiple rows with one url per row, and multiple rows with the same user. */

SET @q15_month = 1;
SET @q15_year = 2016;
SET @q15_party = "GOP";

SELECT DISTINCT usr.screen_name, usr.location_state, GROUP_CONCAT(DISTINCT url.link_path SEPARATOR ', ') as paths as paths
FROM users usr, tweets t, urls url
WHERE  t.screen_name = usr.screen_name 
	AND url.tid = t.tid
    AND @q15_party = usr.party
	AND @q15_month = t.posted_month
	AND @q15_year = t.posted_year
GROUP BY usr.screen_name, usr.location_state
ORDER BY usr.screen_name;


/*
Q23
Find k most used hashtags with the count of tweets it appeared posted by a given sub-category
of users in a list of months. Show the hashtag name and the count in descending order of the count.
Input: sub-category (e.g., GOP), a list of months (e.g., 1, 2, 3), year=2016, value of k
*/

set @k = 10;
set @q23_year = 2016;
set @q23_party = 'GOP'; -- this is the give sub-category
set @q23_listOfMonths = '1, 2, 3';

PREPARE stmt_q23 FROM '
	SELECT h.word, COUNT(h.word) AS Occurences
	FROM hashtags h
	WHERE h.tid IN
		(SELECT t.tid
			FROM tweets t, users u 
			WHERE t.screen_name = u.screen_name
				AND u.party = @q23_party
				AND t.posted_year = @q23_year
				AND  FIND_IN_SET(t.posted_month, @q23_listOfMonths) != 0)
	GROUP BY h.word
	ORDER BY occurences DESC LIMIT ?';
EXECUTE stmt_q23 USING @k;

# Project Query Q 27
/*
Given a year and two selected months, report the screen names of influential users 
(based on top k retweet counts in that month in the two selected years).
Input: value of k (e.g., 10), year (e.g., 2016), month1 (e.g., 1), month2 (e.g., 2)
*/
/* This works */

set @q27_month1 = 1;
set @q27_month2 = 2;
set @q27_year = 2016;
set @k = 10;

PREPARE stmt_q27 FROM'
	SELECT t.screen_name
	FROM tweets t, users u
	WHERE t.screen_name = u.screen_name
		AND (
			@q27_month1 = t.posted_month
			OR @q27_month2 = t.posted_month
			)
		AND @q27_year = t.posted_year
	ORDER BY t.retweet_count DESC LIMIT ?';
EXECUTE stmt_q27 USING @k;

use group13;
SELECT EXISTS(
         SELECT *
         FROM users
         WHERE screen_name = 'mcmuffinBurger') as present;
         
SELECT EXISTS(
         SELECT *
         FROM users
         WHERE screen_name = 'TOMMYDUMBLUCK') as present;
         
         
SELECT * FROM users WHERE screen_name = 'mcmuffinBurger';


# Project Query I
/*
Insert information of a new user into the database.
Input: All relevant attribute values of a user
*/

SET @QI_screen_name = "test_screen1";
SET @QI_user_name = "test_user1";
SET @QI_party = "GOP";
SET @QI_category = "test_category";
SET @QI_location_state = "IA";
SET @QI_followers_count = 0;
SET @QI_following_count = 0;


INSERT INTO users (screen_name, user_name, party, category, location_state, followers_count, following_count)
VALUES (@QI_screen_name, @QI_user_name, @QI_party, @QI_category, @QI_location_state, @QI_followers_count, @QI_following_count);

# Use the delete to delete what was just inserted for testing purposes.
/*
DELETE FROM users
WHERE screen_name = @QI_screen_name;
*/

# Select used for testing insert.
/*
select *
from users u
where u.screen_name = @QI_screen_name
order by u.screen_name;
*/

# Project Query D
/*
Delete a given user and all the tweets the user has tweeted, relevant hashtags, and users mentioned
Input: screen name of the user to delete
Must check that a user is valid before doing so. If the user’s screen name is not valid, abort the transaction.
*/

# User attributes used to test query in mysql.
SET @QD_screen_name = "test_screen1";
SET @QD_user_name = "test_user1";
SET @QD_party = "GOP";
SET @QD_category = "test_category";
SET @QD_location_state = "IA";
SET @QD_followers_count = 0;
SET @QD_following_count = 0;

# Tweet attributes used to test query in mysql.
SET @QD_tid = 1;
SET @QD_tweet_text = "This is a test tweet that will be deleted.";
SET @QD_retweet_count = 0;
SET @QD_posted_date = "2019-05-01 00:00:00";
# Hashtag attributes
SET @QD_word = "hashtagTest";
# Screen name is @QD_screen_name

# Insert data to test the deletion in mysql.
/*
# Insert test user data.
INSERT INTO users (screen_name, user_name, party, category, location_state, followers_count, following_count)
VALUES (@QD_screen_name, @QD_user_name, @QD_party, @QD_category, @QD_location_state, @QD_followers_count, @QD_following_count);


# Insert test user tweet data.
INSERT INTO tweets (tid, tweet_text, retweet_count, posted_date, screen_name)
VALUES (@QD_tid, @QD_tweet_text, @QD_retweet_count, @QD_posted_date, @QD_screen_name);


# Insert test user tweet hashtag data.
INSERT INTO hashtags (tid, word)
VALUES (@QD_tid, @QD_word);
*/
# Delete a user. Use only this query in the actual app.

DELETE FROM users
WHERE screen_name = @QD_screen_name;