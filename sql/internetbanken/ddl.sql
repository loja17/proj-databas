-- Create scheme for database internetbanken.
-- By loja17 for course Databas.
-- 2018-03-19
--


-- Drop tables in order to avoid FK constraint
DROP TABLE IF EXISTS accountHolder;
DROP TABLE IF EXISTS account;
DROP TABLE IF EXISTS accountOwner;
DROP TABLE IF EXISTS log;
DROP TABLE IF EXISTS calculationInterest;


--
-- Create table: accountHolder
-- accountHolder (id, name, born, address, city, pin)
--
-- DROP TABLE IF EXISTS accountHolder;
CREATE TABLE accountHolder
(
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50),
    born DATE,
    address VARCHAR(50),
    city VARCHAR(30),
    pin INT,

    PRIMARY KEY (id) 
);

--
-- Create table: account
-- account (id, accountNumber, balance)
--
-- DROP TABLE IF EXISTS account;
CREATE TABLE account
(
    id INT NOT NULL AUTO_INCREMENT,
    accountNumber CHAR(8),
    balance DECIMAL,
 
    PRIMARY KEY (id)
);

--
-- Table for accountOwner
--accountOwner (id, #accountHolder_id, #account_id)
--
-- DROP TABLE IF EXISTS accountOwner;
CREATE TABLE accountOwner
(
    id INT NOT NULL AUTO_INCREMENT,
    accountHolder_id INT,
    FOREIGN KEY (accountHolder_id) REFERENCES accountHolder(id),
    account_id INT,
    FOREIGN KEY (account_id) REFERENCES account(id),

    PRIMARY KEY (id)
);

--
-- Table for log
--log (id, #accountNumber, #balance, amountChange, logTime)
--
-- DROP TABLE IF EXISTS log;
CREATE TABLE log
(
    id INT NOT NULL AUTO_INCREMENT,
    accountNumber CHAR(8),
    balance DECIMAL,
    amountChange DECIMAL,
    logTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id)
);

--
-- Create table: calculationOfInterest
--calculationOfInterest (id, #accountNumber, calcInterest, calcDate)
--
-- DROP TABLE IF EXISTS calculationOfInterest;
CREATE TABLE calculationOfInterest
(
    id INT NOT NULL AUTO_INCREMENT,
    accountNumber CHAR(8),
    calcInterest DECIMAL,
    calcDate DATE,
    
    PRIMARY KEY (id)
);


-- STORED PROCEDURES AND FUNCTIONS

--
-- SP for new AccountHolder
--
DROP PROCEDURE IF EXISTS newAccountHolder;
DELIMITER ;;
CREATE PROCEDURE newAccountHolder
(
    aName VARCHAR(50),
    aBorn DATE,
    aAddress VARCHAR(50),
    aCity VARCHAR(30),
    aPin INT
)
BEGIN
    INSERT INTO accountHolder (name, born, address, city, pin) 
    VALUES (aName, aBorn, aAddress, aCity, aPin);
END
;;
DELIMITER ;


--
-- SP for new Account
--
DROP PROCEDURE IF EXISTS newAccount;
DELIMITER ;;
CREATE PROCEDURE newAccount
(
    aAccountNumber CHAR(8),
    aBalance DECIMAL
)
BEGIN
    INSERT INTO account (accountNumber, balance) 
    VALUES (aAccountNumber, aBalance);
END
;;
DELIMITER ;


--
-- SP for connect accountHolder to account
--
DROP PROCEDURE IF EXISTS connectToAccount;
DELIMITER ;;
CREATE PROCEDURE connectToAccount
(
    aAccountHolder_id INT,
    aAccountNumber CHAR(8)
)
BEGIN
    DECLARE a_id INT;
    SELECT id FROM account WHERE accountNumber = aAccountNumber INTO a_id;
    INSERT INTO accountOwner (accountHolder_id, account_id) 
    VALUES (aAccountHolder_id, a_id);
END
;;
DELIMITER ;


--
-- SP for getting accountHolder name by id
--
DROP PROCEDURE IF EXISTS getNameById;
DELIMITER ;;
CREATE PROCEDURE getNameById(
    aId INT
)
BEGIN
    SELECT name as n
    from accountHolder WHERE id = aId;
END
;;
DELIMITER ;


--
-- SP for getting accountnumber by id
--
DROP PROCEDURE IF EXISTS getAccountNumberById;
DELIMITER ;;
CREATE PROCEDURE getAccountNumberById(
    aId INT
)
BEGIN
    SELECT accountNumber as n
    from account WHERE id = aId;
END
;;
DELIMITER ;


--
-- SP for getting id by accountnumber
--
DROP PROCEDURE IF EXISTS getIdByAccountNumber;
DELIMITER ;;
CREATE PROCEDURE getIdByAccountNumber(
    aAccountNumber CHAR(8)
)
BEGIN
    SELECT id as n
    from account WHERE accountNumber = aAccountNumber;
END
;;
DELIMITER ;


--
-- Create procedure for select * from log
--
DROP PROCEDURE IF EXISTS showLog;
DELIMITER //
CREATE PROCEDURE showLog()
BEGIN
    SELECT * FROM log;
END
//
DELIMITER ;


--
-- UDF for formatting 
--
DROP FUNCTION IF EXISTS getAccountsByAH;
DELIMITER ;;
CREATE FUNCTION getAccountsByAH(
    aId INT
)
RETURNS VARCHAR(300) 
BEGIN
    DECLARE str VARCHAR(300);
    select 
      GROUP_CONCAT(accountNumber)
      from account 
      where id in(select account_id from accountowner 
        where accountholder_id = aId) into str;
    RETURN str;
END
;;
DELIMITER ;


--
-- SP for showing accountholder with accounts
--
DROP PROCEDURE IF EXISTS showAccountHolder;
DELIMITER //
CREATE PROCEDURE showAccountHolder()
BEGIN
    SELECT
        id,
        name,
        born,        
        CONCAT(address,', ',city) AS address,
        internetbanken.getAccountsByAH(id) as accountNumbers
    FROM accountHolder;
END
//
DELIMITER ;


--
-- SP for showing one accountholder with accounts
--
DROP PROCEDURE IF EXISTS showOneAccountHolder;
DELIMITER //
CREATE PROCEDURE showOneAccountHolder(
    aId INT
)
BEGIN
    SELECT
        ah.id AS id,
        ah.name as name,
        ah.born as born,        
        CONCAT(ah.address,', ',ah.city) AS address,
        ao.id as accountOwner_id,
        a.id AS account_id,
        a.accountNumber as accountNumber,
        a.balance as balance
    FROM accountHolder as ah
    INNER JOIN
        accountOwner as ao
        on ah.id = ao.accountHolder_id
    INNER JOIN 
        account as a
            on a.id = ao.account_id
    WHERE ah.id = aId;
END
//
DELIMITER ;


--
-- SP for showing one accountholder with accounts
--
DROP PROCEDURE IF EXISTS showAccountsOfAccountHolder;
DELIMITER //
CREATE PROCEDURE showAccountsOfAccountHolder(
    aId INT
)
BEGIN

    SELECT 
        ah.id AS id,
        ah.name as owner,
        ao.id as accountOwner_id,
        a.id AS account_id,
        a.accountNumber as accountNumber,
        a.balance as balance,
        internetbanken.sharedAccount(account_id) as shared
    FROM accountHolder as ah
    INNER JOIN
        accountOwner as ao
        on ah.id = ao.accountHolder_id
    INNER JOIN 
        account as a
            on a.id = ao.account_id
    WHERE ah.id = aId;
END
//
DELIMITER ;
    

--
-- SP for showing one accountholder with accounts
--
DROP PROCEDURE IF EXISTS showAccountsByIdPin;
DELIMITER //
CREATE PROCEDURE showAccountsByIdPin(
    aId INT,
    pincode INT
)
BEGIN

    SELECT 
        ah.id AS id,
        ah.name as owner,
        ao.id as accountOwner_id,
        a.id AS account_id,
        a.accountNumber as accountNumber,
        a.balance as balance,
        internetbanken.sharedAccount(account_id) as shared
    FROM accountHolder as ah
    INNER JOIN
        accountOwner as ao
        on ah.id = ao.accountHolder_id
    INNER JOIN 
        account as a
            on a.id = ao.account_id
    WHERE ah.id = aId and ah.pin = pincode;
END
//
DELIMITER ;


--
-- UDF for formatting 
--
DROP FUNCTION IF EXISTS sharedAccount;
DELIMITER ;;
CREATE FUNCTION sharedAccount(
    aId INT
)
RETURNS VARCHAR(300) 
BEGIN
    DECLARE str VARCHAR(300);
    select 
      GROUP_CONCAT(name)
      from accountholder 
      where id in(select accountholder_id from accountowner 
        where account_id = aId) into str;
    RETURN str;
END
;;
DELIMITER ;


--
-- SP for showing one account
--
DROP PROCEDURE IF EXISTS showSingleAccount;
DELIMITER //
CREATE PROCEDURE showSingleAccount(
    aId INT
)
BEGIN
    SELECT DISTINCT
        id,
        accountNumber,
        balance,
        internetbanken.sharedAccount(id) as shared
    FROM account
    WHERE id = aId;
END
//
DELIMITER ;


--
-- SP for showing one account
--
DROP PROCEDURE IF EXISTS showAvailableOwners;
DELIMITER //
CREATE PROCEDURE showAvailableOwners(
    aId INT
)
BEGIN
    SELECT DISTINCT
    ah.id as id,
    ah.name as availableOwner
    from accountHolder as ah
    WHERE ah.id NOT IN(SELECT
        accountHolder_id
    FROM accountOwner
    WHERE account_id =aID);
END
//
DELIMITER ;


--
-- SP for showing sum of all accounts
--
DROP PROCEDURE IF EXISTS showsumAccount;
DELIMITER //
CREATE PROCEDURE showSumAccount()
BEGIN
    SELECT SUM(balance) as n
    FROM account;
END
//
DELIMITER ;


--
-- SP for make CalculationOfInterest;
--
DROP PROCEDURE IF EXISTS makeCalculationOfInterest;
DELIMITER ;;
CREATE PROCEDURE makeCalculationOfInterest
(
    interestRate CHAR(8),
    dateOfCalculation DATE
)
BEGIN
    DECLARE a_id INT;
    DECLARE sum INT;
    DECLARE aAccountNumber CHAR(8);
    DECLARE accountBalance DECIMAL;
    DECLARE interest DECIMAL;
    SELECT COUNT(id) FROM account INTO sum;


    SET a_id=1;
        loop1: WHILE a_id<=sum DO
            SELECT balance FROM account WHERE id = a_id INTO accountBalance;
            SELECT accountNumber FROM account WHERE id = a_id INTO aAccountNumber;
            SET interest = interestRate * accountBalance / 365;
            INSERT INTO calculationOfInterest (accountNumber, calcInterest, calcDate) 
            VALUES (aAccountNumber, interest, dateOfCalculation);
        SET a_id=a_id+1;
    END WHILE loop1;
END
;;
DELIMITER ;


--
-- SP for showing calcInterest by date
--
DROP PROCEDURE IF EXISTS showCalculationOfInterestDate;
DELIMITER ;;
CREATE PROCEDURE showCalculationOfInterestDate
(
    dateOfCalculation DATE
)
BEGIN
    SELECT 
        SUM(calcInterest)
    FROM calculationOfInterest
    WHERE calcDate = dateOfCalculation;
END
;;
DELIMITER ;


--
-- SP for showing calcInterest by year
--
DROP PROCEDURE IF EXISTS showCalculationOfInterestYear;
DELIMITER ;;
CREATE PROCEDURE showCalculationOfInterestYear
(
    yearOfCalculation INT
)
BEGIN
    SELECT 
        SUM(calcInterest)
    FROM calculationOfInterest 
    WHERE YEAR(calcDate) = yearOfCalculation;
END
;;
DELIMITER ;


--
-- UDF for getting interest by account 
--
DROP FUNCTION IF EXISTS getInterestByAccount;
DELIMITER ;;
CREATE FUNCTION getInterestByAccount(
    aAccountNumber CHAR(8)
)
RETURNS DECIMAL 
BEGIN
    DECLARE interestSum DECIMAL;
    
    SELECT
        SUM(calcInterest)
    FROM calculationOfInterest
    WHERE accountNumber = aAccountNumber
    INTO interestSum;

    RETURN interestSum;
END
;;
DELIMITER ;


--
-- SP for showing accounts
--
DROP PROCEDURE IF EXISTS showAccounts;
DELIMITER //
CREATE PROCEDURE showAccounts()
BEGIN
   SELECT 
        id, 
        accountNumber, 
        balance,
        internetbanken.sharedAccount(id) as shared
    FROM account;
END
//
DELIMITER ;


--
-- SP for showing accounts with interest
--
DROP PROCEDURE IF EXISTS showAccountsWithInterest;
DELIMITER //
CREATE PROCEDURE showAccountsWithInterest()
BEGIN
   SELECT 
        id, 
        accountNumber, 
        balance,
        internetbanken.getInterestByAccount(accountNumber) as interestSum
    FROM account;
END
//
DELIMITER ;


--
-- SP for showing one accountholders account with interest
--
DROP PROCEDURE IF EXISTS showOneAccountInterest;
DELIMITER //
CREATE PROCEDURE showOneAccountInterest(
    aId INT
)
BEGIN
    SELECT 
        ah.id AS id,
        ah.name as owner,
        ao.id as accountOwner_id,
        a.id AS account_id,
        a.accountNumber as accountNumber,
        a.balance as balance,
        internetbanken.getInterestByAccount(accountNumber) as interestSum
    FROM accountHolder as ah
    INNER JOIN
        accountOwner as ao
            on ah.id = ao.accountHolder_id
    INNER JOIN 
        account as a
            on a.id = ao.account_id
    WHERE ah.id = aId;

END
//
DELIMITER ;


--
-- SP for showing account with interest by date
--
DROP PROCEDURE IF EXISTS showAccountInterestByDate;
DELIMITER //
CREATE PROCEDURE showAccountInterestByDate(
    aCalcDate DATE
)
BEGIN
    SELECT 
        ah.id AS id,
        ah.name as owner,
        ao.id as accountOwner_id,
        a.id AS account_id,
        a.accountNumber as accountNumber,
        a.balance as balance,
        internetbanken.getInterestByAccount(a.accountNumber) as accumulatedInterest,
        internetbanken.get
    FROM accountHolder as ah
    INNER JOIN
        accountOwner as ao
            on ah.id = ao.accountHolder_id
    INNER JOIN 
        account as a
            on a.id = ao.account_id
    WHERE ah.id = aId;
END
//
DELIMITER ;


--
-- SP for moving money from one account to another
--
DROP PROCEDURE IF EXISTS moveMoney;
DELIMITER //
CREATE PROCEDURE moveMoney(
    fromId INT,
    toId INT,
    amount DECIMAL
)
BEGIN
    
    START TRANSACTION;

    UPDATE account SET balance = balance + amount WHERE id = toId;

    UPDATE account SET balance = balance - amount WHERE id = fromId;
    
    COMMIT;

END
//
DELIMITER ;


--
-- SP for swishing money from one account to another
--
DROP PROCEDURE IF EXISTS swishMoney;
DELIMITER //
CREATE PROCEDURE swishMoney(
    userId INT,
    pincode INT,
    fromAccount CHAR(8),
    amount DECIMAL,
    toAccount CHAR(8)
)
BEGIN

    DECLARE validPin INT;
    DECLARE validAccount VARCHAR(100);

    SELECT GROUP_CONCAT(accountNumber SEPARATOR ' ') FROM account 
    WHERE id IN(SELECT account_id FROM accountOwner 
    WHERE accountHolder_id = userId) INTO validAccount;

    SELECT pin FROM accountHolder WHERE id = userId INTO validPin;  


    START TRANSACTION;
    
    IF (pincode = validPin AND validAccount LIKE CONCAT ('%', fromAccount, '%')) THEN
        UPDATE account SET balance = balance - amount WHERE accountNumber = fromAccount;
        UPDATE account SET balance = balance + amount WHERE accountNumber = toAccount;
    END IF;

    COMMIT;

END
//
DELIMITER ;


--
-- Create trigger for logging when account balance is changed
--
DROP TRIGGER IF EXISTS logUpdateBalance;
DELIMITER ;;
CREATE TRIGGER logUpdateBalance
AFTER UPDATE
ON account FOR EACH ROW
BEGIN
    IF (NEW.balance != OLD.balance) THEN
    INSERT INTO log (accountNumber, balance, amountChange, logTime)
        VALUES (OLD.accountNumber, NEW.balance, NEW.balance-OLD.balance, CURRENT_TIMESTAMP);
    END IF;
END;
;;
DELIMITER ;
