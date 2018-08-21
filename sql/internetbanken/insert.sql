-- Insert data for internetbanken.
-- By loja17 for course Databas.
-- 2018-03-20
--

--
-- Insert to accountHolder
--
CALL newAccountHolder('Louise Jakobsson', '1992-06-24', 'Hinderbanan 26', 'Göteborg', 1243);
CALL newAccountHolder('Frank Franksson', '1995-09-22', 'Frankvägen 5', 'Lerum', 1112);
CALL newAccountHolder('Kråkan Kråk', '1956-01-16', 'Kråkvägen 20', 'Alingsås', 1113);
CALL newAccountHolder('Milo Karlsson', '1998-02-12', 'Milogränden 28', 'Stockholm', 1114);
CALL newAccountHolder('Stig Stigsson', '1988-01-27', 'Stigen 6', 'Kiruna', 1115);
CALL newAccountHolder('Sten Stensson', '1982-05-06', 'Stenen 7', 'Floda', 1116);
CALL newAccountHolder('Ada Ada', '1940-06-03', 'Adaslingan 55', 'Gränna', 1117);
CALL newAccountHolder('Siv Ert', '1955-08-24', 'Siverts gata 10', 'Partille', 1118);

SELECT * FROM accountHolder;

--
-- Insert to account
--
CALL newAccount('900-5566', 20000);
CALL newAccount('901-5567', 110000);
CALL newAccount('902-5568', 10000);
CALL newAccount('903-5569', 50000);
CALL newAccount('904-6677', 60000);
CALL newAccount('905-6678', 1000);
CALL newAccount('906-6679', 40000);
CALL newAccount('907-7788', 99000);
CALL newAccount('908-7789', 56000);
CALL newAccount('909-7790', 23000);
CALL newAccount('910-8866', 2000);
CALL newAccount('911-8877', 5200);
CALL newAccount('912-8888', 8000);
CALL newAccount('913-8899', 12000);
CALL newAccount('914-9967', 16000);
CALL newAccount('915-9977', 15000);

SELECT * FROM account;

--
-- Insert to accountOwner
--
CALL connectToAccount(1, '900-5566');
CALL connectToAccount(2, '900-5566');
CALL connectToAccount(3, '900-5566');
CALL connectToAccount(1, '901-5567');
CALL connectToAccount(2, '901-5567');
CALL connectToAccount(3, '901-5567');
CALL connectToAccount(4, '902-5568');
CALL connectToAccount(5, '903-5569');
CALL connectToAccount(6, '904-6677');
CALL connectToAccount(7, '905-6678');
CALL connectToAccount(8, '900-5566');
CALL connectToAccount(1 ,'906-6679');
CALL connectToAccount(2 ,'907-7788');
CALL connectToAccount(3 ,'908-7789');
CALL connectToAccount(4 ,'909-7790');
CALL connectToAccount(5 ,'910-8866');
CALL connectToAccount(6 ,'911-8877');
CALL connectToAccount(7 ,'912-8888');
CALL connectToAccount(8 ,'913-8899');
CALL connectToAccount(4 ,'914-9967');
CALL connectToAccount(5 ,'915-9977');


SELECT * FROM accountOwner;


--
-- Make calculation of interest
--
CALL makecalculationofinterest('0.7', '2017-04-20');
CALL makecalculationofinterest('1.1', '2018-04-19');
CALL makecalculationofinterest('0.85', '2018-04-20');

SELECT * FROM calculationOfInterest;


--
-- Move money
--
CALL moveMoney(2, 1, 110);

-- 
-- Swish money
--
CALL swishMoney(1, 1243, '900-5566', 10, '901-5567');

SELECT * FROM log;