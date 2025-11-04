-- ============================================================================
-- Assignment 9: Docker Compose, PostgreSQL, and SQL Operations
-- Database: fastapi_db
-- PostgreSQL Version: 16
-- Student: Rajat Pednekar
-- Date: October 30, 2025
-- ============================================================================

-- ============================================================================
-- SECTION 1: DATABASE SETUP
-- ============================================================================

-- Connect to the database (via pgAdmin)
-- Host: db (Docker service name)
-- Port: 5432
-- Database: fastapi_db
-- User: postgres
-- Password: postgres

-- ============================================================================
-- SECTION 2: CREATE TABLES
-- ============================================================================

-- Create Users Table
-- Purpose: Store user information with unique constraints
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Verify table creation
\d users

-- Create Calculations Table with Foreign Key Relationship
-- Purpose: Store calculation records linked to users (one-to-many relationship)
CREATE TABLE calculations (
    id SERIAL PRIMARY KEY,
    operation VARCHAR(20) NOT NULL,
    operand_a FLOAT NOT NULL,
    operand_b FLOAT NOT NULL,
    result FLOAT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Verify table creation
\d calculations

-- ============================================================================
-- SECTION 3: INSERT DATA (CREATE)
-- ============================================================================

-- Insert Users
-- Note: id and created_at are auto-generated
INSERT INTO users (username, email) 
VALUES 
    ('alice', 'alice@example.com'), 
    ('bob', 'bob@example.com');

-- Verify user insertion
SELECT * FROM users;

-- Expected Result:
-- id | username |       email        |       created_at        
-- ----+----------+--------------------+-------------------------
--  1 | alice    | alice@example.com  | 2025-10-30 02:00:00
--  2 | bob      | bob@example.com    | 2025-10-30 02:00:00

-- Insert Calculations
-- Note: Alice (user_id=1) has 2 calculations, Bob (user_id=2) has 1
INSERT INTO calculations (operation, operand_a, operand_b, result, user_id)
VALUES
    ('add', 2, 3, 5, 1),
    ('divide', 10, 2, 5, 1),
    ('multiply', 4, 5, 20, 2);

-- Verify calculation insertion
SELECT * FROM calculations;

-- Expected Result:
-- id | operation | operand_a | operand_b | result |       timestamp        | user_id
-- ----+-----------+-----------+-----------+--------+------------------------+---------
--  1 | add       |         2 |         3 |      5 | 2025-10-30 02:00:01    |       1
--  2 | divide    |        10 |         2 |      5 | 2025-10-30 02:00:01    |       1
--  3 | multiply  |         4 |         5 |     20 | 2025-10-30 02:00:01    |       2

-- ============================================================================
-- SECTION 4: QUERY DATA (READ)
-- ============================================================================

-- Query 1: Retrieve All Users
SELECT * FROM users;

-- Query 2: Retrieve All Calculations
SELECT * FROM calculations;

-- Query 3: Retrieve Specific User by ID
SELECT * FROM users WHERE id = 1;

-- Query 4: Retrieve Calculations for a Specific User
SELECT * FROM calculations WHERE user_id = 1;

-- Query 5: Count Total Users
SELECT COUNT(*) as total_users FROM users;

-- Query 6: Count Calculations per User
SELECT user_id, COUNT(*) as calculation_count 
FROM calculations 
GROUP BY user_id;

-- Expected Result:
-- user_id | calculation_count
-- ---------+-------------------
--       1 |                 2
--       2 |                 1

-- ============================================================================
-- SECTION 5: JOIN OPERATIONS (COMBINING RELATED DATA)
-- ============================================================================

-- Query 7: JOIN Users and Calculations (Show usernames with calculations)
-- Purpose: Demonstrate one-to-many relationship and data normalization
SELECT 
    u.username, 
    c.operation, 
    c.operand_a, 
    c.operand_b, 
    c.result
FROM calculations c
JOIN users u ON c.user_id = u.id;

-- Expected Result:
-- username | operation | operand_a | operand_b | result
-- ----------+-----------+-----------+-----------+--------
-- alice    | add       |         2 |         3 |      5
-- alice    | divide    |        10 |         2 |      5
-- bob      | multiply  |         4 |         5 |     20

-- Query 8: JOIN with Additional User Information
SELECT 
    u.id as user_id,
    u.username, 
    u.email,
    c.operation, 
    c.operand_a, 
    c.operand_b, 
    c.result,
    c.timestamp
FROM calculations c
JOIN users u ON c.user_id = u.id
ORDER BY u.username, c.timestamp;

-- Query 9: JOIN with Aggregation (Count calculations per user with username)
SELECT 
    u.username,
    u.email,
    COUNT(c.id) as total_calculations
FROM users u
LEFT JOIN calculations c ON u.id = c.user_id
GROUP BY u.id, u.username, u.email;

-- Expected Result:
-- username |       email        | total_calculations
-- ----------+--------------------+--------------------
-- alice    | alice@example.com  |                  2
-- bob      | bob@example.com    |                  1

-- ============================================================================
-- SECTION 6: UPDATE DATA (MODIFY)
-- ============================================================================

-- Update 1: Correct a calculation result
-- Scenario: The addition result for calculation id=1 was incorrect
UPDATE calculations
SET result = 6
WHERE id = 1;

-- Verify the update
SELECT * FROM calculations WHERE id = 1;

-- Expected Result:
-- id | operation | operand_a | operand_b | result | timestamp | user_id
-- ----+-----------+-----------+-----------+--------+-----------+---------
--  1 | add       |         2 |         3 |      6 | ...       |       1

-- Update 2: Modify user email
UPDATE users
SET email = 'alice.smith@example.com'
WHERE username = 'alice';

-- Verify the update
SELECT * FROM users WHERE username = 'alice';

-- Update 3: Update multiple calculations for a user
UPDATE calculations
SET operation = 'addition'
WHERE operation = 'add' AND user_id = 1;

-- Verify the update
SELECT * FROM calculations WHERE user_id = 1;

-- ============================================================================
-- SECTION 7: DELETE DATA (REMOVE)
-- ============================================================================

-- Delete 1: Remove a specific calculation
DELETE FROM calculations
WHERE id = 2;

-- Verify deletion
SELECT * FROM calculations;

-- Expected Result: Only calculations with id=1 and id=3 remain
-- id | operation | operand_a | operand_b | result | timestamp | user_id
-- ----+-----------+-----------+-----------+--------+-----------+---------
--  1 | addition  |         2 |         3 |      6 | ...       |       1
--  3 | multiply  |         4 |         5 |     20 | ...       |       2

-- Delete 2: CASCADE DELETE Demonstration
-- Deleting a user will automatically delete their calculations
-- Uncomment to test (WARNING: This will delete data)

-- DELETE FROM users WHERE id = 1;
-- 
-- Verify CASCADE effect:
-- SELECT * FROM calculations;
-- 
-- Expected: Only calculation id=3 (Bob's) remains
-- Alice's calculation (id=1) is automatically deleted

-- ============================================================================
-- SECTION 8: ADVANCED QUERIES (OPTIONAL DEMONSTRATIONS)
-- ============================================================================

-- Query 10: Filter calculations by operation type
SELECT 
    u.username,
    c.operation,
    c.result
FROM calculations c
JOIN users u ON c.user_id = u.id
WHERE c.operation = 'multiply';

-- Query 11: Find users with no calculations (using LEFT JOIN)
SELECT 
    u.username,
    u.email
FROM users u
LEFT JOIN calculations c ON u.id = c.user_id
WHERE c.id IS NULL;

-- Query 12: Calculate average result per user
SELECT 
    u.username,
    AVG(c.result) as average_result
FROM users u
JOIN calculations c ON u.id = c.user_id
GROUP BY u.id, u.username;

-- Query 13: Find calculations with results greater than 10
SELECT 
    u.username,
    c.operation,
    c.operand_a,
    c.operand_b,
    c.result
FROM calculations c
JOIN users u ON c.user_id = u.id
WHERE c.result > 10;

-- ============================================================================
-- SECTION 9: DATA VALIDATION AND CONSTRAINTS
-- ============================================================================

-- Test 1: Attempt to insert duplicate username (should fail)
-- INSERT INTO users (username, email) 
-- VALUES ('alice', 'another.alice@example.com');
-- Expected Error: duplicate key value violates unique constraint "users_username_key"

-- Test 2: Attempt to insert calculation with non-existent user (should fail)
-- INSERT INTO calculations (operation, operand_a, operand_b, result, user_id)
-- VALUES ('subtract', 10, 5, 5, 999);
-- Expected Error: insert or update on table "calculations" violates foreign key constraint

-- Test 3: Attempt to insert NULL username (should fail)
-- INSERT INTO users (username, email) 
-- VALUES (NULL, 'test@example.com');
-- Expected Error: null value in column "username" violates not-null constraint

-- ============================================================================
-- SECTION 10: CLEANUP (OPTIONAL - USE WITH CAUTION)
-- ============================================================================

-- WARNING: These commands will delete all data and tables
-- Uncomment only if you need to reset the database

-- Drop tables (calculations first due to foreign key dependency)
-- DROP TABLE IF EXISTS calculations;
-- DROP TABLE IF EXISTS users;

-- Verify tables are dropped
-- \dt

-- ============================================================================
-- SECTION 11: USEFUL POSTGRESQL COMMANDS
-- ============================================================================

-- List all tables in the current database
-- \dt

-- Describe table structure
-- \d users
-- \d calculations

-- View table indexes
-- \di

-- View foreign key constraints
-- SELECT
--     tc.constraint_name, 
--     tc.table_name, 
--     kcu.column_name,
--     ccu.table_name AS foreign_table_name,
--     ccu.column_name AS foreign_column_name 
-- FROM information_schema.table_constraints AS tc 
-- JOIN information_schema.key_column_usage AS kcu
--     ON tc.constraint_name = kcu.constraint_name
-- JOIN information_schema.constraint_column_usage AS ccu
--     ON ccu.constraint_name = tc.constraint_name
-- WHERE tc.constraint_type = 'FOREIGN KEY';

-- ============================================================================
-- END OF SQL SCRIPTS
-- ============================================================================

-- Notes for Execution:
-- 1. Execute sections sequentially
-- 2. Review results after each operation
-- 3. Uncomment test scenarios carefully (they may fail intentionally)
-- 4. Use pgAdmin Query Tool for execution
-- 5. Take screenshots of key operations for documentation

-- Learning Objectives Demonstrated:
-- ✓ CREATE: Table creation with constraints
-- ✓ INSERT: Data insertion with auto-generated fields
-- ✓ SELECT: Simple and complex queries
-- ✓ JOIN: Combining related data from multiple tables
-- ✓ UPDATE: Modifying existing records
-- ✓ DELETE: Removing records with CASCADE effects
-- ✓ Foreign Keys: Enforcing referential integrity
-- ✓ One-to-Many Relationships: Users and Calculations
