-- ===================================================================================================================
-- TO SHOW THE PASSWORD OF CREATED USERS!
-- ===================================================================================================================

SELECT
    username,
    database_name,
    password
FROM user_management.credentials
ORDER BY username;