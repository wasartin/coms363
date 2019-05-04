use group13;
DROP TABLE IF EXISTS application_users;
DROP TABLE IF EXISTS hashtags;
DROP TABLE IF EXISTS urls;
DROP TABLE IF EXISTS tweets;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS application_users;

CREATE TABLE application_users(
	un VARCHAR(80),
	pw VARCHAR(100),
    is_admin BOOLEAN,
	PRIMARY KEY(un)
);

CREATE TABLE users (
	screen_name VARCHAR(15), /* limit set by twitter */
	user_name VARCHAR(80),   /*this I randomly chose */
	party VARCHAR(30),
	category VARCHAR(30),
	location_state VARCHAR(49), /* I thought we wered told state was 2 wide, but the data has full names listed*/
	followers_count INT,
	following_count INT,
	PRIMARY KEY(screen_name)
);

CREATE TABLE tweets (
	tid BIGINT, 
    tweet_text VARCHAR(280), -- tweet_text limit is 280 on twitter
	retweet_count INT,
	retweeted INT,
	posted TIMESTAMP,
    posted_month INT,
    posted_year INT,
	screen_name VARCHAR(15), -- this is how we are implementing post relation
	PRIMARY KEY(tid),
	FOREIGN KEY(screen_name) REFERENCES users(screen_name) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE hashtags (
	tid BIGINT,
	word VARCHAR(280),
   	PRIMARY KEY(tid, word),
	FOREIGN KEY(tid) REFERENCES tweets(tid) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE urls (
	tid BIGINT,
	link_path VARCHAR(100),
	PRIMARY KEY (tid, link_path),
	FOREIGN KEY(tid) REFERENCES tweets(tid) ON DELETE CASCADE ON UPDATE CASCADE
); 

# Trigger for ensuring presidential candidates have no state association.
drop trigger if exists check_candidate_state;
delimiter //
CREATE TRIGGER check_candidate_state BEFORE INSERT ON users
FOR EACH ROW
BEGIN
	IF NEW.category LIKE 'presidential_candidate' AND NEW.location_state NOT LIKE 'na' THEN
		-- SET NEW.category = 'na';
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Presidential candidates cannot have a state association, data was changed to na';
	END IF;
END;//
delimiter ;

-- LOAD DATA	

INSERT INTO application_users VALUES
	('shawn', SHA('sean'), false),
    ('general', SHA('general'), false),
    ('admin', SHA('password'), true),
    ('mcmuffin', SHA('biscuts1'), true); 
	
 -- 2016
LOAD DATA INFILE 'C:\\temp\\user.csv'
INTO TABLE users
FIELDS TERMINATED BY ';' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:\\temp\\tweets.csv'
INTO TABLE tweets
FIELDS TERMINATED BY ';' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(tid, tweet_text, retweet_count, retweeted, posted, screen_name)
SET posted_month = MONTH(posted), posted_year = YEAR(posted);

LOAD DATA INFILE 'C:\\temp\\tagged.csv'
INTO TABLE hashtags
FIELDS TERMINATED BY ';' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:\\temp\\urlused.csv'
INTO TABLE urls
FIELDS TERMINATED BY ';' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;



