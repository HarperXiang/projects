-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema yelp_project
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `yelp_project` DEFAULT CHARACTER SET utf8 ;
USE `yelp_project` ;

-- -----------------------------------------------------
-- Table_1 `yelp_project`.`income`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `yelp_project`.`income` (
  `postal_code` INT NOT NULL,
  `ave_income` VARCHAR(45) NOT NULL,
  `state` VARCHAR(45) NOT NULL,
  `country` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`postal_code`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table_2 `yelp_project`.`business`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `yelp_project`.`business` (
  `business_id` VARCHAR(30) NOT NULL,
  `name` VARCHAR(25) NULL DEFAULT NULL,
  `neighborhood` VARCHAR(25) NULL DEFAULT NULL,
  `address` VARCHAR(25) NULL DEFAULT NULL,
  `city` VARCHAR(25) NULL DEFAULT NULL,
  `state` VARCHAR(25) NULL DEFAULT NULL,
  `latitude` FLOAT NULL DEFAULT NULL,
  `longitude` FLOAT NULL DEFAULT NULL,
  `stars` VARCHAR(25) NULL DEFAULT NULL,
  `review_count` INT(10) NULL DEFAULT NULL,
  `is_open` VARCHAR(25) NULL DEFAULT NULL,
  `categories` VARCHAR(25) NULL DEFAULT NULL,
  `postal_code` INT(10) NOT NULL,
  PRIMARY KEY (`business_id`),
  INDEX `postal_code_idx` (`postal_code` ASC) VISIBLE,
  CONSTRAINT `postal_code`
    FOREIGN KEY (`postal_code`)
    REFERENCES `yelp_project`.`income` (`postal_code`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Transition Table_1 `yelp_project`.`attributes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `yelp_project`.`attributes` (
  `business_id` VARCHAR(30) NOT NULL,
  `AcceptsInsurance` VARCHAR(10) NULL DEFAULT NULL,
  `ByAppointmentOnly` VARCHAR(10) NULL DEFAULT NULL,
  `BusinessAcceptsCreditCards` VARCHAR(10) NULL DEFAULT NULL,
  `BusinessParking_garage` VARCHAR(10) NULL DEFAULT NULL,
  `BusinessParking_street` VARCHAR(10) NULL DEFAULT NULL,
  `BusinessParking_validated` VARCHAR(10) NULL DEFAULT NULL,
  `BusinessParking_lot` VARCHAR(10) NULL DEFAULT NULL,
  `GoodForKids` VARCHAR(10) NULL DEFAULT NULL,
  `WheelchairAccessible` VARCHAR(10) NULL DEFAULT NULL,
  `Alcohol` VARCHAR(10) NULL DEFAULT NULL,
  `Caters` VARCHAR(10) NULL DEFAULT NULL,
  `HappyHour` VARCHAR(10) NULL DEFAULT NULL,
  `OutdoorSeating` VARCHAR(10) NULL DEFAULT NULL,
  `RestaurantsDelivery` VARCHAR(10) NULL DEFAULT NULL,
  `Smoking` VARCHAR(10) NULL DEFAULT NULL,
  `DogsAllowed` VARCHAR(10) NULL DEFAULT NULL,
  `BYOB` VARCHAR(10) NULL DEFAULT NULL,
  PRIMARY KEY (`business_id`),
  CONSTRAINT `business_id`
    FOREIGN KEY (`business_id`)
    REFERENCES `yelp_project`.`business` (`business_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table_3 `yelp_project`.`check_in`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `yelp_project`.`check_in` (
  `business_id` VARCHAR(30) NOT NULL,
  `weekday` VARCHAR(50) NOT NULL,
  `hour` TIME NOT NULL,
  `checkin` INT(10) NOT NULL,
  PRIMARY KEY (`business_id`),
  CONSTRAINT `business_id`
    FOREIGN KEY (`business_id`)
    REFERENCES `yelp_project`.`business` (`business_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table_4 `yelp_project`.`yelp_users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `yelp_project`.`yelp_users` (
  `user_id` VARCHAR(30) NOT NULL,
  `name` VARCHAR(20) NULL DEFAULT NULL,
  `review_count` INT(10) NULL DEFAULT NULL,
  `yelping_since` INT(10) NULL DEFAULT NULL,
  `friends` VARCHAR(30) NULL DEFAULT NULL,
  `useful` INT(10) NULL DEFAULT NULL,
  `funny` INT(10) NULL DEFAULT NULL,
  `cool` INT(10) NULL DEFAULT NULL,
  `fans` INT(10) NULL DEFAULT NULL,
  `elite` VARCHAR(30) NULL DEFAULT NULL,
  `average_stars` INT(10) NULL DEFAULT NULL,
  `compliment_hot` INT(10) NULL DEFAULT NULL,
  `compliment_more` INT(10) NULL DEFAULT NULL,
  `compliment_profile` INT(10) NULL DEFAULT NULL,
  `compliment_cute` INT(10) NULL DEFAULT NULL,
  `compliment_list` INT(10) NULL DEFAULT NULL,
  `compliment_note` INT(10) NULL DEFAULT NULL,
  `compliment_plain` INT(10) NULL DEFAULT NULL,
  `compliment_cool` INT(10) NULL DEFAULT NULL,
  `compliment_funny` INT(10) NULL DEFAULT NULL,
  `compliment_writer` INT(10) NULL DEFAULT NULL,
  `compliment_photos` INT(10) NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table_5 `yelp_project`.`yelp_review`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `yelp_project`.`yelp_review` (
  `review_id` VARCHAR(30) NOT NULL,
  `user_id` VARCHAR(30) NOT NULL,
  `business_id` VARCHAR(30) NOT NULL,
  `stars` INT(10) NULL DEFAULT NULL,
  `date` DATE NULL DEFAULT NULL,
  `text` VARCHAR(300) NULL DEFAULT NULL,
  `useful` INT(10) NULL DEFAULT NULL,
  `funny` INT(10) NULL DEFAULT NULL,
  `cool` INT(10) NULL DEFAULT NULL,
  PRIMARY KEY (`review_id`),
  INDEX `business_id_idx` (`business_id` ASC) VISIBLE,
  INDEX `user_id_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `business_id`
    FOREIGN KEY (`business_id`)
    REFERENCES `yelp_project`.`business` (`business_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `yelp_project`.`yelp_users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table_6 `yelp_project`.`business_twitter_account`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `yelp_project`.`business_twitter_account` (
  `business_twitter_id` INT(64) NOT NULL,
  `name` VARCHAR(30) NULL DEFAULT NULL,
  `screen_name` VARCHAR(30) NULL DEFAULT NULL,
  `location` VARCHAR(30) NULL DEFAULT NULL,
  `derived_city` VARCHAR(30) NULL DEFAULT NULL,
  `derived_state` VARCHAR(10) NULL DEFAULT NULL,
  `derived_country` VARCHAR(10) NULL DEFAULT NULL,
  `verified` TINYINT(1) NULL DEFAULT NULL,
  `followers_count` INT(11) NULL DEFAULT NULL,
  `friends_count` INT(11) NULL DEFAULT NULL,
  `listed_count` INT(11) NULL DEFAULT NULL,
  `favourites_count` INT(11) NULL DEFAULT NULL,
  `statuses_count` INT(11) NULL DEFAULT NULL,
  `created_at` VARCHAR(30) NULL DEFAULT NULL,
  `business_business_id` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`business_twitter_id`),
  INDEX `fk_twitter_users_business1_idx` (`business_business_id` ASC) VISIBLE,
  CONSTRAINT `fk_twitter_users_business1`
    FOREIGN KEY (`business_business_id`)
    REFERENCES `yelp_project`.`business` (`business_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table_7 `yelp_project`.`tweets`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `yelp_project`.`tweets` (
  `Tweets_ID` INT(64) NOT NULL,
  `text` VARCHAR(150) NULL DEFAULT NULL,
  `in_reply_to_status_id` INT(64) NULL DEFAULT NULL,
  `in_reply_to_user_id` INT(64) NULL DEFAULT NULL,
  `in_reply_to_screen_name` VARCHAR(30) NULL DEFAULT NULL,
  `latitude` INT(30) NULL DEFAULT NULL,
  `longtitude` INT(30) NULL DEFAULT NULL,
  `place_name_city` VARCHAR(30) NULL DEFAULT NULL,
  `place_name_state` VARCHAR(10) NULL DEFAULT NULL,
  `place_name_country` VARCHAR(10) NULL DEFAULT NULL,
  `quoted_status_id` INT(64) NULL DEFAULT NULL,
  `is_quote_status` TINYINT(1) NULL DEFAULT NULL,
  `quote_count` INT(11) NULL DEFAULT NULL,
  `reply_count` INT(11) NULL DEFAULT NULL,
  `retweet_count` INT(11) NULL DEFAULT NULL,
  `favorite_count` INT(11) NULL DEFAULT NULL,
  `entities` VARCHAR(30) NULL DEFAULT NULL,
  `lang` VARCHAR(5) NULL DEFAULT NULL,
  `twitter_users_id` INT(64) NOT NULL,
  PRIMARY KEY (`Tweets_ID`),
  INDEX `fk_business_tweets_twitter_users1_idx` (`twitter_users_id` ASC) VISIBLE,
  CONSTRAINT `fk_business_tweets_twitter_users1`
    FOREIGN KEY (`twitter_users_id`)
    REFERENCES `yelp_project`.`business_twitter_account` (`business_twitter_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Transition Table_2 `yelp_project`.`yelp_users_has_business`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `yelp_project`.`yelp_users_has_business` (
  `yelp_users_user_id` VARCHAR(30) NOT NULL,
  `business_business_id` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`yelp_users_user_id`, `business_business_id`),
  INDEX `fk_yelp_users_has_business_business1_idx` (`business_business_id` ASC) VISIBLE,
  INDEX `fk_yelp_users_has_business_yelp_users1_idx` (`yelp_users_user_id` ASC) VISIBLE,
  CONSTRAINT `fk_yelp_users_has_business_yelp_users1`
    FOREIGN KEY (`yelp_users_user_id`)
    REFERENCES `yelp_project`.`yelp_users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_yelp_users_has_business_business1`
    FOREIGN KEY (`business_business_id`)
    REFERENCES `yelp_project`.`business` (`business_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

##create index for all the tables
CREATE INDEX index_business_id
ON business_restaurant (business_id);


CREATE INDEX index_review_id
ON yelp_review_restaurant (review_id);

CREATE INDEX index_business_id
ON yelp_review_restaurant (business_id);

CREATE INDEX index_user_id
ON yelp_review_restaurant (user_id);

CREATE INDEX index_user_id
ON yelp_users_restaurant (user_id);

CREATE INDEX index_business_id
ON check_in (business_id);

CREATE INDEX index_business_id
ON twitter_tweets (business_id);