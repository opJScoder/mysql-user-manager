-- ============================================================
-- 0. CONFIGURATION CONFIG (SET YOUR VARIABLE HERE)
-- ============================================================
SET @prefix = '250180107';

-- ============================================================
-- 1. CREATE MANAGEMENT DATABASE
-- ============================================================
CREATE DATABASE IF NOT EXISTS `user_management`;

-- ============================================================
-- 2. CREATE CREDENTIALS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `user_management`.`credentials` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(64) NOT NULL UNIQUE,
    database_name VARCHAR(64) NOT NULL,
    password VARCHAR(8) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
-- 3. CREATE ONE USER + DATABASE (UPDATED TO '%')
-- ============================================================
DROP PROCEDURE IF EXISTS `user_management`.`create_user_db`;
DELIMITER $$
CREATE PROCEDURE `user_management`.`create_user_db`(
    IN user_number INT
)
BEGIN
    DECLARE name_value VARCHAR(64);
    DECLARE generated_password VARCHAR(8);

    IF user_number < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User number must be 1 or greater';
    END IF;

    -- Uses the global session prefix
    SET name_value = CONCAT(@prefix, LPAD(user_number, 3, '0'));
    SET generated_password = HEX(RANDOM_BYTES(4));

    SET @sql = CONCAT('CREATE DATABASE IF NOT EXISTS `', name_value, '` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci');
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    SET @sql = CONCAT('DROP USER IF EXISTS ''', name_value, '''@''localhost''');
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    SET @sql = CONCAT('DROP USER IF EXISTS ''', name_value, '''@''%''');
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    SET @sql = CONCAT('CREATE USER ''', name_value, '''@''%'' IDENTIFIED BY ''', generated_password, '''');
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    SET @sql = CONCAT('GRANT ALL PRIVILEGES ON `', name_value, '`.* TO ''', name_value, '''@''%''');
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    INSERT INTO `user_management`.`credentials` (username, database_name, password)
    VALUES (name_value, name_value, generated_password)
    ON DUPLICATE KEY UPDATE database_name = name_value, password = generated_password, updated_at = CURRENT_TIMESTAMP;

    SELECT name_value AS database_name, name_value AS username, generated_password AS password;
END$$
DELIMITER ;

-- ============================================================
-- 4. CREATE RANGE OF USERS + DATABASES (UPDATED TO '%')
-- ============================================================
DROP PROCEDURE IF EXISTS `user_management`.`create_users_dbs`;
DELIMITER $$
CREATE PROCEDURE `user_management`.`create_users_dbs`(
    IN start_number INT,
    IN end_number INT
)
BEGIN
    DECLARE i INT;
    DECLARE name_value VARCHAR(64);
    DECLARE generated_password VARCHAR(8);

    IF start_number < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Start number must be 1 or greater';
    END IF;
    IF end_number < start_number THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'End number must be greater than or equal to start number';
    END IF;

    SET i = start_number;
    WHILE i <= end_number DO
        -- Uses the global session prefix
        SET name_value = CONCAT(@prefix, LPAD(i, 3, '0'));
        SET generated_password = HEX(RANDOM_BYTES(4));

        SET @sql = CONCAT('CREATE DATABASE IF NOT EXISTS `', name_value, '` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci');
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

        SET @sql = CONCAT('DROP USER IF EXISTS ''', name_value, '''@''localhost''');
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
        SET @sql = CONCAT('DROP USER IF EXISTS ''', name_value, '''@''%''');
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

        SET @sql = CONCAT('CREATE USER ''', name_value, '''@''%'' IDENTIFIED BY ''', generated_password, '''');
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

        SET @sql = CONCAT('GRANT ALL PRIVILEGES ON `', name_value, '`.* TO ''', name_value, '''@''%''');
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

        INSERT INTO `user_management`.`credentials` (username, database_name, password)
        VALUES (name_value, name_value, generated_password)
        ON DUPLICATE KEY UPDATE database_name = name_value, password = generated_password, updated_at = CURRENT_TIMESTAMP;

        SET i = i + 1;
    END WHILE;

    -- Dynamically filter by the configured prefix value
    SELECT username, database_name, password FROM `user_management`.`credentials`
    WHERE username REGEXP CONCAT('^', @prefix, '(', start_number, '|', start_number + 1, '|', start_number + 2, '|', end_number, ')$')
    ORDER BY username;
END$$
DELIMITER ;

-- ============================================================
-- 5. DELETE ONE USER + DATABASE (UPDATED TO '%')
-- ============================================================
DROP PROCEDURE IF EXISTS `user_management`.`delete_user_db`;
DELIMITER $$
CREATE PROCEDURE `user_management`.`delete_user_db`(
    IN user_number INT
)
BEGIN
    DECLARE name_value VARCHAR(64);

    IF user_number < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User number must be 1 or greater';
    END IF;

    -- Uses the global session prefix
    SET name_value = CONCAT(@prefix, LPAD(user_number, 3, '0'));

    SET @sql = CONCAT('DROP DATABASE IF EXISTS `', name_value, '`');
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    SET @sql = CONCAT('DROP USER IF EXISTS ''', name_value, '''@''%''');
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    SET @sql = CONCAT('DROP USER IF EXISTS ''', name_value, '''@''localhost''');
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    DELETE FROM `user_management`.`credentials` WHERE username = name_value;

    SELECT name_value AS database_deleted, name_value AS user_deleted;
END$$
DELIMITER ;

-- ============================================================
-- 6. DELETE RANGE OF USERS + DATABASES (UPDATED TO '%')
-- ============================================================
DROP PROCEDURE IF EXISTS `user_management`.`delete_users_dbs`;
DELIMITER $$
CREATE PROCEDURE `user_management`.`delete_users_dbs`(
    IN start_number INT,
    IN end_number INT
)
BEGIN
    DECLARE i INT;
    DECLARE name_value VARCHAR(64);

    IF start_number < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Start number must be 1 or greater';
    END IF;
    IF end_number < start_number THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'End number must be greater than or equal to start number';
    END IF;

    SET i = start_number;
    WHILE i <= end_number DO
        -- Uses the global session prefix
        SET name_value = CONCAT(@prefix, LPAD(i, 3, '0'));

        SET @sql = CONCAT('DROP DATABASE IF EXISTS `', name_value, '`');
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

        SET @sql = CONCAT('DROP USER IF EXISTS ''', name_value, '''@''%''');
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
        SET @sql = CONCAT('DROP USER IF EXISTS ''', name_value, '''@''localhost''');
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

        DELETE FROM `user_management`.`credentials` WHERE username = name_value;

        SET i = i + 1;
    END WHILE;

    SELECT username, database_name, password FROM `user_management`.`credentials` ORDER BY username;
END$$
DELIMITER ;

-- ============================================================
-- 7. PASSWORD MANAGEMENT FUNCTIONS (AUTO-GENERATED)
-- ============================================================

-- Change Password for a single user (Randomly Generated)
DROP PROCEDURE IF EXISTS `user_management`.`change_password_user`;
DELIMITER $$
CREATE PROCEDURE `user_management`.`change_password_user`(
    IN user_number INT
)
BEGIN
    DECLARE name_value VARCHAR(64);
    DECLARE generated_password VARCHAR(8);

    IF user_number < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User number must be 1 or greater';
    END IF;

    SET name_value = CONCAT(@prefix, LPAD(user_number, 3, '0'));
    SET generated_password = HEX(RANDOM_BYTES(4));

    SET @sql = CONCAT('ALTER USER ''', name_value, '''@''%'' IDENTIFIED BY ''', generated_password, '''');
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    UPDATE `user_management`.`credentials` 
    SET password = generated_password, updated_at = CURRENT_TIMESTAMP 
    WHERE username = name_value;

    SELECT name_value AS username, generated_password AS new_password;
END$$
DELIMITER ;

-- Change Password for a range of users (Randomly Generated)
DROP PROCEDURE IF EXISTS `user_management`.`change_password_users_range`;
DELIMITER $$
CREATE PROCEDURE `user_management`.`change_password_users_range`(
    IN start_number INT,
    IN end_number INT
)
BEGIN
    DECLARE i INT;
    DECLARE name_value VARCHAR(64);
    DECLARE generated_password VARCHAR(8);

    IF start_number < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Start number must be 1 or greater';
    END IF;
    IF end_number < start_number THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'End number must be greater than or equal to start number';
    END IF;

    SET i = start_number;
    WHILE i <= end_number DO
        SET name_value = CONCAT(@prefix, LPAD(i, 3, '0'));
        SET generated_password = HEX(RANDOM_BYTES(4));

        SET @sql = CONCAT('ALTER USER ''', name_value, '''@''%'' IDENTIFIED BY ''', generated_password, '''');
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

        UPDATE `user_management`.`credentials` 
        SET password = generated_password, updated_at = CURRENT_TIMESTAMP 
        WHERE username = name_value;

        SET i = i + 1;
    END WHILE;

    SELECT username, database_name, password FROM `user_management`.`credentials`
    WHERE username REGEXP CONCAT('^', @prefix, '(', start_number, '|', start_number + 1, '|', start_number + 2, '|', end_number, ')$')
    ORDER BY username;
END$$
DELIMITER ;

-- ============================================================
-- 8. CHANGE PASSWORD TO SPECIFIC CUSTOM VALUE
-- ============================================================

-- Change Password for a single user to a custom specified string
DROP PROCEDURE IF EXISTS `user_management`.`change_password_user_custom`;
DELIMITER $$
CREATE PROCEDURE `user_management`.`change_password_user_custom`(
    IN user_number INT,
    IN custom_password VARCHAR(64)
)
BEGIN
    DECLARE name_value VARCHAR(64);

    IF user_number < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User number must be 1 or greater';
    END IF;
    IF custom_password IS NULL OR CHAR_LENGTH(custom_password) < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password string cannot be empty';
    END IF;

    SET name_value = CONCAT(@prefix, LPAD(user_number, 3, '0'));

    SET @sql = CONCAT('ALTER USER ''', name_value, '''@''%'' IDENTIFIED BY ''', custom_password, '''');
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

    UPDATE `user_management`.`credentials` 
    SET password = custom_password, updated_at = CURRENT_TIMESTAMP 
    WHERE username = name_value;

    SELECT name_value AS username, custom_password AS new_password;
END$$
DELIMITER ;
