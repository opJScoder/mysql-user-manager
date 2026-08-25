-- ===================================================================================================================
-- TO CHANGE PASSWORD FOR ONE USER (RANDOM) : CALL `user_management`.`change_password_user`(user_number);
-- ===================================================================================================================
CALL `user_management`.`change_password_user`(1);

-- ===================================================================================================================
-- TO CHANGE PASSWORD FOR RANGE OF USERS (RANDOM) : CALL `user_management`.`change_password_users_range`(start_number, end_number);
-- ===================================================================================================================
CALL `user_management`.`change_password_users_range`(2, 11);

-- ===================================================================================================================
-- TO CHANGE PASSWORD FOR ONE USER (CUSTOM) : CALL `user_management`.`change_password_user_custom`(user_number, custom_password);
-- ===================================================================================================================
CALL `user_management`.`change_password_user_custom`(11, '0AD562C1');
