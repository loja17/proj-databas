--
-- Create scheme for database internetbanken.
-- By loja17 for course Databas.
-- 2018-03-19
--

-- Skapa databas
DROP DATABASE IF EXISTS internetbanken;
CREATE DATABASE internetbanken;

-- Välj vilken databas du vill använda
USE internetbanken;

-- Radera en databas med allt innehåll
-- DROP DATABASE internetbanken;

-- Visa vilka databaser som finns
-- SHOW DATABASES;

-- Visa vilka databaser som finns
-- som heter något i stil med *internetbanken*
SHOW DATABASES LIKE "%internetbanken%";

-- Skapa användaren "user" med
-- lösenordet "pass" och ge
-- fulla rättigheter till databasen "internetbanken"
-- när användaren loggar in från maskinen "localhost"
GRANT ALL ON internetbanken.* TO user@localhost IDENTIFIED BY 'pass';

-- Visa vad en användare kan göra mot vilken databas.
SHOW GRANTS FOR user@localhost;

-- Visa för nuvarande användare
-- SHOW GRANTS FOR CURRENT_USER;