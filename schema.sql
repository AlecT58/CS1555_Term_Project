/*
    Alec Trievel and John Ha
    CS 1555 Spring 2017
    Term Project: Stage 1
*/

--Drop Tables for consistency--
DROP TABLE MUTUALFUND CASCADE CONSTRAINTS;
DROP TABLE CLOSINGPRICE CASCADE CONSTRAINTS;
DROP TABLE CUSTOMER CASCADE CONSTRAINTS;
DROP TABLE ADMINISTRATOR CASCADE CONSTRAINTS;
DROP TABLE ALLOCATION CASCADE CONSTRAINTS;
DROP TABLE PREFERS CASCADE CONSTRAINTS;
DROP TABLE TRXLOG CASCADE CONSTRAINTS;
DROP TABLE OWNS CASCADE CONSTRAINTS;
DROP TABLE MUTUALDATE CASCADE CONSTRAINTS;

-------------------------------------------------------------------------------
                        --START CREATE TABLES--
-------------------------------------------------------------------------------
CREATE TABLE MUTUALFUND
(
    symbol VARCHAR2(20),
    name VARCHAR2(30) NOT NULL,
    description VARCHAR2(100),
    category VARCHAR2(10),
    c_date DATE,
    CONSTRAINT mutual_pk 
        PRIMARY KEY (symbol) INITIALLY IMMEDIATE DEFERRABLE,
    CONSTRAINT category_type 
        CHECK (category IN ('fixed', 'bonds', 'stocks', 'mixed'))
);

CREATE TABLE CLOSINGPRICE
(
    symbol VARCHAR2(20),
    price FLOAT NOT NULL,
    p_date DATE NOT NULL,
    CONSTRAINT closing_pk 
        PRIMARY KEY (symbol, p_date) INITIALLY IMMEDIATE DEFERRABLE,
    CONSTRAINT closing_fk
        FOREIGN KEY (symbol) 
        REFERENCES MUTUALFUND (symbol) INITIALLY IMMEDIATE DEFERRABLE
);

CREATE TABLE CUSTOMER
(
    login VARCHAR2(10),
    name VARCHAR2(20) NOT NULL,
    email VARCHAR2(30),
    address VARCHAR2(30),
    password VARCHAR2(10) NOT NULL,
    balance FLOAT NOT NULL,
    CONSTRAINT customer_pk
        PRIMARY KEY (login) INITIALLY IMMEDIATE DEFERRABLE
    --CONSTRAINT balance_not_negative     --might be better to use a trigger instead, updates will cause issues too
        --CHECK (balance >= 0)
);

CREATE TABLE ADMINISTRATOR
(
    login VARCHAR2(10),
    name VARCHAR2(20) NOT NULL,
    email VARCHAR2(30),
    address VARCHAR2(30),
    password VARCHAR2(10) NOT NULL, --everyone needs a password, make not null -Alec
    CONSTRAINT admin_pk
        PRIMARY KEY (login) INITIALLY IMMEDIATE DEFERRABLE
);

CREATE TABLE ALLOCATION
(
    allocation_no INT,
    login VARCHAR2(20) NOT NULL,
    p_date DATE,
    CONSTRAINT allocation_pk
        PRIMARY KEY (allocation_no) INITIALLY IMMEDIATE DEFERRABLE,
    CONSTRAINT allocation_fk
        FOREIGN KEY (login)
        REFERENCES CUSTOMER (login) INITIALLY IMMEDIATE DEFERRABLE
);

create table PREFERS 
(
allocation_no integer,
symbol varchar2(20) NOT NULL,
percentage float,
constraint pk_prefers primary key(allocation_no, symbol) INITIALLY IMMEDIATE DEFERRABLE,
constraint fk_prefers_alloc_no foreign key (allocation_no)
    references ALLOCATION (allocation_no) INITIALLY IMMEDIATE DEFERRABLE,
CONSTRAINT fk_prefers_symbol
    FOREIGN KEY (symbol)
    REFERENCES MUTUALFUND(symbol) INITIALLY IMMEDIATE DEFERRABLE
);

create table TRXLOG (
trans_id integer,
login varchar2(10) NOT NULL, --needs to be a user doing the transaction
symbol varchar2(20),
t_date date,
action varchar2(10) NOT NULL, --maybe set a constraint instead of not null? They can still enter an invalid value -Alec
num_shares integer,
price float,
amount float NOT NULL,
constraint pk_trxlog primary key (trans_id) INITIALLY IMMEDIATE DEFERRABLE,
constraint fk_trxlog_login foreign key (login)
	references CUSTOMER (login) INITIALLY IMMEDIATE DEFERRABLE,
constraint fk_trxlog_symbol foreign key (symbol)
	references MUTUALFUND(symbol) INITIALLY IMMEDIATE DEFERRABLE
);

create table OWNS (
login varchar2(10),
symbol varchar2(20) NOT NULL,
shares integer NOT NULL,
constraint pk_owns primary key (login, symbol) INITIALLY IMMEDIATE DEFERRABLE,
constraint fk_owns_login foreign key (login)
	references CUSTOMER (login) INITIALLY IMMEDIATE DEFERRABLE,
constraint fk_owns_symbol foreign key (symbol)
	references MUTUALFUND(symbol) INITIALLY IMMEDIATE DEFERRABLE
);

create table MUTUALDATE (
c_date date,
constraint pk_mutualdate primary key (c_date) INITIALLY IMMEDIATE DEFERRABLE
);

COMMIT;
-------------------------------------------------------------------------------
                          --END CREATE TABLES--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
                        --START INSERT STATEMENTS--
-------------------------------------------------------------------------------
--Inserts for MUTUALDATE
INSERT INTO MUTUALDATE (c_date)
VALUES ('04-APR-14');

--Inserts into CUSTOMER
INSERT INTO CUSTOMER (login, name, email, address, password, balance)
VALUES ('mike', 'Mike', 'mike@betterfuture.com', '1st street', 'pwd', 750);

INSERT INTO CUSTOMER (login, name, email, address, password, balance)
VALUES ('mary', 'Mary', 'mary@betterfuture.com', '2st street', 'pwd', 0);

--Inserts into ADMINISTRATOR
INSERT INTO ADMINISTRATOR (login, name, email, address, password)
VALUES ('admin', 'Administrator', 'admin@betterfuture.com', '5th Ave, Pitt', 'root');

--Inserts into MUTUALFUND
INSERT INTO MUTUALFUND (symbol, name, description, category, c_date)
VALUES ('MM', 'money-market', 'money market, conservative', 'fixed', '06-JAN-14');

INSERT INTO MUTUALFUND (symbol, name, description, category, c_date)
VALUES ('RE', 'real-estate', 'real estate', 'fixed', '09-JAN-14');

INSERT INTO MUTUALFUND (symbol, name, description, category, c_date)
VALUES ('STB', 'short-time-bonds', 'short term bonds', 'bonds', '10-JAN-14');

INSERT INTO MUTUALFUND (symbol, name, description, category, c_date)
VALUES ('LTB', 'long-time-bonds', 'long term bonds', 'bonds', '11-JAN-14');

INSERT INTO MUTUALFUND (symbol, name, description, category, c_date)
VALUES ('BBS', 'balance-time-bonds', 'balance bonds and stocks', 'mixed', '12-JAN-14');

INSERT INTO MUTUALFUND (symbol, name, description, category, c_date)
VALUES ('SRBS', 'social-respons-bonds-stocks', 'social responsibility bonds and stocks', 'mixed', '12-JAN-14');

INSERT INTO MUTUALFUND (symbol, name, description, category, c_date)
VALUES ('GS', 'general-stocks', 'general stocks', 'stocks', '16-JAN-14');

INSERT INTO MUTUALFUND (symbol, name, description, category, c_date)
VALUES ('AS', 'aggressive-stocks', 'aggressive stocks', 'stocks', '23-JAN-14');

INSERT INTO MUTUALFUND (symbol, name, description, category, c_date)
VALUES ('IMS', 'international-markets-stock', 'international markets stock, risky', 'stocks', '30-JAN-14');

--Inserts into OWNS
INSERT INTO OWNS (login, symbol, shares)
VALUES ('mike', 'RE', 50);

--Inserts into TRXLOG
INSERT INTO TRXLOG (trans_id, login, symbol, t_date, action, num_shares, price, amount)
VALUES (0, 'mike', NULL, '29-MAR-14', 'deposit', NULL, NULL, 1000);

INSERT INTO TRXLOG (trans_id, login, symbol, t_date, action, num_shares, price, amount)
VALUES (1, 'mike', 'MM', '29-MAR-14', 'buy', 50, 10, 500);

INSERT INTO TRXLOG (trans_id, login, symbol, t_date, action, num_shares, price, amount)
VALUES (2, 'mike', 'RE', '29-MAR-14', 'buy', 50, 10, 500);

INSERT INTO TRXLOG (trans_id, login, symbol, t_date, action, num_shares, price, amount)
VALUES (3, 'mike', 'RE', '01-APR-14', 'sell', 50, 15, 750);

--Inserts into ALLOCATION 
INSERT INTO ALLOCATION (allocation_no, login, p_date)
VALUES (0, 'mike', '28-MAR-14');

INSERT INTO ALLOCATION (allocation_no, login, p_date)
VALUES (1, 'mary', '29-MAR-14');

INSERT INTO ALLOCATION (allocation_no, login, p_date)
VALUES (2, 'mike', '03-MAR-14');

--Inserts into PREFERS
INSERT INTO PREFERS (allocation_no, symbol, percentage)
VALUES (0, 'MM', .5);

INSERT INTO PREFERS (allocation_no, symbol, percentage)
VALUES (0, 'RE', .5);

INSERT INTO PREFERS (allocation_no, symbol, percentage)
VALUES (1, 'STB', .2);

INSERT INTO PREFERS (allocation_no, symbol, percentage)
VALUES (1, 'LTB', .4);

INSERT INTO PREFERS (allocation_no, symbol, percentage)
VALUES (1, 'BBS', .4);

INSERT INTO PREFERS (allocation_no, symbol, percentage)
VALUES (2, 'GS', .3);

INSERT INTO PREFERS (allocation_no, symbol, percentage)
VALUES (2, 'AS', .3);

INSERT INTO PREFERS (allocation_no, symbol, percentage)
VALUES (2, 'TMS', .4);

--Inserts into CLOSINGPRICE
INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('MM', 10, '28-MAR-14');
	
INSERT INTO CLOSINGPRICE (symbol, price, p_date)		
VALUES ('MM', 11, '29-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('MM', 12, '30-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('MM', 15, '31-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('MM', 14, '01-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('MM', 15, '02-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('MM', 16, '03-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('RE', 10, '28-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('RE', 12, '29-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('RE', 15, '30-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('RE', 14, '31-MAR-14');                                       

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('RE', 16, '01-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('RE', 17, '02-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('RE', 15, '03-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('STB', 10, '28-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('STB', 9, '29-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('STB', 10, '30-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('STB', 12, '31-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('STB', 14, '01-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('STB', 10, '02-APR-14');  

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('STB', 12, '03-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('LTB', 10, '28-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('LTB', 12, '29-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('LTB', 13, '30-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('LTB', 15, '31-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('LTB', 12, '01-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('LTB', 9, '02-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('LTB', 10, '03-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('BBS', 10, '28-MAR-14');
	
INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('BBS', 11, '29-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('BBS', 14, '30-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('BBS', 18, '31-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('BBS', 13, '01-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('BBS', 15, '02-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('BBS', 16, '03-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('SRBS', 10, '28-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('SRBS', 12, '29-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('SRBS', 12, '30-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('SRBS', 14, '31-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('SRBS', 17, '01-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('SRBS', 20, '02-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('SRBS', 20, '03-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('GS', 10, '28-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('GS', 12, '29-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('GS', 13, '30-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('GS', 15, '31-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('GS', 14, '01-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('GS', 15, '02-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('GS', 12, '03-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('AS', 10, '28-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('AS', 15, '29-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('AS', 14, '30-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('AS', 16, '31-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('AS', 14, '01-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('AS', 17, '02-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('AS', 18, '03-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('IMS', 10, '28-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('IMS', 12, '29-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('IMS', 12, '30-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('IMS', 14, '31-MAR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('IMS', 13, '01-APR-14');  

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('IMS', 12, '02-APR-14');

INSERT INTO CLOSINGPRICE (symbol, price, p_date)
VALUES ('IMS', 11, '03-APR-14'); 

COMMIT;
-------------------------------------------------------------------------------
                            --END INSERT STATEMENTS--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
                            --START VIEW CREATION--
-------------------------------------------------------------------------------
--NOTE: I don't think any of our views need to be materialized since the base tables
--      shouldn't recieve updates too often. -Alec

--will hold the number of shares sold (aka have been bought)
CREATE OR REPLACE VIEW SHARES_SOLD_VIEW
    AS SELECT symbol, category, num_shares, t_date
    FROM TRXLOG NATURAL JOIN MUTUALFUND     --no repeats
    WHERE action = 'buy';

--will hold the info about specific mutual funds, see "Browsing Mutual Funds"
CREATE OR REPLACE VIEW BROWSE_FUNDS_VIEW
    AS SELECT symbol, name, description, category, price, p_date
    FROM MUTUALFUND NATURAL JOIN CLOSINGPRICE;

/*
--will hold the user's portfolio inforamtion, see "Customer Portfolio"
CREATE OR REPLACE VIEW CUSTOMER_PORTFOLIO_VIEW
    AS SELECT a.login, a.symbol, a.price, a.shares, --need way to get non null values for cost and sales
    FROM 
        (SELECT * FROM OWNS NATURAL JOIN RecentPrice) a
        LEFT JOIN 
            --will do this later
*/

--get the total amount of sales for a user and the respective symbol 
CREATE OR REPLACE VIEW SOLD_TRANSACTIONS
    AS SELECT login, symbol, SUM(amount) AS Total_Sales_Made
    FROM TRXLOG WHERE action = 'sell' GROUP BY login, symbol;

--get the costs of the total amount of shares per login and symbol
CREATE OR REPLACE VIEW COST_BY_SHARE
    AS SELECT login, symbol, SUM(amount) AS Amount_Per_Group
    FROM TRXLOG WHERE action = 'buy' GROUP BY login, symbol;

CREATE OR REPLACE VIEW MAX_TRANSACTIONS
    AS SELECT MAX(trans_id) AS Trans_ID_Order
    FROM TRXLOG;

CREATE OR REPLACE VIEW MAX_ALLOCATIONS
    AS SELECT MAX(allocation_no) AS Allocation_No_Order
    FROM ALLOCATION;

--get the most recent set of allocations for a specific user
CREATE OR REPLACE VIEW RECENT_ALLOCATIONS
    AS SELECT login, MAX(allocation_no) AS Allocation_No_Order
    FROM ALLOCATION GROUP BY login;

--Still need a view for getting the most recent prices and need to finish our portfolio view -Alec

-------------------------------------------------------------------------------
                            --END VIEW CREATION--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
                            --START TRIGGER CREATION--
-------------------------------------------------------------------------------
Create or replace trigger OnDepositTrx
BEFORE INSERT    --should fire before because we don't want to add bad data -Alec
On TRXLOG
For Each Row
Begin
	Insert Into MUTUALFUND()--Insert into mutual fund, right? Not sure--
	where symbol = symbol -- idea is here. will do later
	
	
End;
/

--Trigger that will make sure the balance will be updated properly after buying or selling
CREATE OR REPLACE TRIGGER BALANCE_UPDATE_TRIG
    BEFORE INSERT
    ON TRXLOG
    FOR EACH ROW   
    BEGIN
        --selling shares, need to subtract from balance; buying shares, add to balace
        IF :new.action LIKE 'sell' THEN --PROCEDURE to update balance needs to go here
        END IF;
        IF :new.action LIKE 'buy' THEN --PROCEDURE to update balance needs to go here
    END;
/

COMMIT;
-------------------------------------------------------------------------------
                            --END TRIGGER CREATION--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
                        --START PROCEDURE/FUNCTION CREATION--
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE subtractFromBalance(customerID IN VARCHAR2, amountToSubtract IN FLOAT)
    AS Old_Balance FLOAT;
    BEGIN
        SELECT balance into Old_Balance 
        FROM CUSTOMER WHERE customerId = login;
        UPDATE CUSTOMER 
            SET balance = Old_Balance - amountToSubtract
            WHERE login = customerID;
    END;
/

CREATE OR REPLACE PROCEDURE addToBalance(customerID IN VARCHAR2, amountToAdd IN FLOAT)
    AS Old_Balance FLOAT;
    BEGIN
        SELECT balance into Old_Balance 
        FROM CUSTOMER WHERE customerId = login;
        UPDATE CUSTOMER 
            SET balance = Old_Balance + amountToAdd
            WHERE login = customerID;
    END;
/

CREATE OR REPLACE PROCEDURE getReturns(numShares IN NUMBER, sharePrice IN FLOAT) RETURN NUMBER
    AS
    BEGIN
        RETURN(numShares * sharePrice);
    END;
/

CREATE OR REPLACE PROCEDURE insertNewDeposit(customerID IN VARCHAR2, amountDeposit IN FLOAT)
    AS ID number;
    BEGIN
        SELECT MAX(trans_id) INTO ID --highest ID == 1 less than our new ID
        FROM TRXLOG;
        INSERT INTO TRXLOG VALUES(ID + 1, customerID, NULL, current_date, 'deposit', NULL, NULL, amountDeposit);
    END;
/
-------------------------------------------------------------------------------
                        --END PROCEDURE/FUNCTION CREATION--
-------------------------------------------------------------------------------

--Last commit for good measure, purge recyclebin as well
COMMIT;
PURGE RECYCLEBIN;