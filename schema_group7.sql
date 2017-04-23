/*
    Alec Trievel and John Ha
    CS 1555 Spring 2017
    Term Project
*/

--Drop Tables to create new schema --
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
        PRIMARY KEY (login) INITIALLY IMMEDIATE DEFERRABLE,
    CONSTRAINT balance_not_negative     
        CHECK (balance >= 0)
);

CREATE TABLE ADMINISTRATOR
(
    login VARCHAR2(10),
    name VARCHAR2(20) NOT NULL,
    email VARCHAR2(30),
    address VARCHAR2(30),
    password VARCHAR2(10) NOT NULL, 
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
    allocation_no INT,
    symbol VARCHAR2(20) NOT NULL,
    percentage FLOAT,
    CONSTRAINT pk_prefers 
        PRIMARY KEY(allocation_no, symbol) INITIALLY IMMEDIATE DEFERRABLE,
    CONSTRAINT fk_prefers_alloc_no 
        FOREIGN KEY (allocation_no)
        REFERENCES ALLOCATION (allocation_no) INITIALLY IMMEDIATE DEFERRABLE,
    CONSTRAINT fk_prefers_symbol
        FOREIGN KEY (symbol)
        REFERENCES MUTUALFUND(symbol) INITIALLY IMMEDIATE DEFERRABLE
);

create table TRXLOG 
(
    trans_id INT,
    login VARCHAR2(10) NOT NULL, 
    symbol VARCHAR2(20),
    t_date DATE,
    action VARCHAR2(10) NOT NULL, 
    num_shares INT,
    price FLOAT,
    amount FLOAT NOT NULL,
    CONSTRAINT pk_trxlog 
        PRIMARY KEY (trans_id) INITIALLY IMMEDIATE DEFERRABLE,
    CONSTRAINT fk_trxlog_login 
        FOREIGN KEY (login)
	    REFERENCES CUSTOMER (login) INITIALLY IMMEDIATE DEFERRABLE,
    CONSTRAINT fk_trxlog_symbol 
        FOREIGN KEY (symbol)
	    REFERENCES MUTUALFUND(symbol) INITIALLY IMMEDIATE DEFERRABLE
);

create table OWNS 
(
    login VARCHAR2(10),
    symbol VARCHAR2(20) NOT NULL,
    shares INT NOT NULL,
    CONSTRAINT pk_owns 
        PRIMARY KEY (login, symbol) INITIALLY IMMEDIATE DEFERRABLE,
    CONSTRAINT fk_owns_login 
        FOREIGN KEY (login)
        REFERENCES CUSTOMER (login) INITIALLY IMMEDIATE DEFERRABLE,
    CONSTRAINT fk_owns_symbol foreign key (symbol)
        REFERENCES MUTUALFUND(symbol) INITIALLY IMMEDIATE DEFERRABLE
);

create table MUTUALDATE 
(
    c_date DATE,
    CONSTRAINT pk_mutualdate 
        PRIMARY KEY (c_date) INITIALLY IMMEDIATE DEFERRABLE
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
CREATE OR REPLACE VIEW SHARES_SOLD --done
    AS SELECT symbol, category, num_shares, t_date
    FROM TRXLOG NATURAL JOIN MUTUALFUND   
    WHERE action = 'buy';

CREATE OR REPLACE VIEW BROWSE_FUNDS --done
    AS SELECT symbol, name, description, category, price, p_date
    FROM MUTUALFUND NATURAL JOIN CLOSINGPRICE;

CREATE OR REPLACE VIEW COST_BY_SHARE    --done
    AS SELECT login, symbol, SUM(amount) AS Total_Cost
    FROM TRXLOG WHERE action = 'buy' GROUP BY login, symbol;

CREATE OR REPLACE VIEW SOLD_TRANSACTIONS    --done
    AS SELECT login, symbol, SUM(amount) AS Total_Sales
    FROM TRXLOG WHERE action = 'sell' GROUP BY login, symbol;

CREATE OR REPLACE VIEW RECENT_PRICES --done
AS SELECT *
    FROM (SELECT first_close.symbol, first_close.price, second_close.newest_date FROM CLOSINGPRICE first_close
    JOIN
        (SELECT symbol, max(p_date) as newest_date FROM CLOSINGPRICE
            GROUP BY symbol) second_close
    ON first_close.symbol = second_close.symbol AND second_close.newest_date = first_close.p_date);

CREATE OR REPLACE VIEW PORTFOLIO --done
    AS 
    SELECT ownsSelect.login, ownsSelect.symbol, ownsSelect.price, ownsSelect.shares, coalesce(costSelect.Total_Cost, 0) as Cost_Values, coalesce(costSelect.Total_Sales, 0) as Sales_Values
    FROM 
        (SELECT * FROM OWNS NATURAL JOIN RECENT_PRICES) ownsSelect
    LEFT JOIN
        (SELECT COST_BY_SHARE.login, COST_BY_SHARE.symbol, COST_BY_SHARE.Total_Cost, SOLD_TRANSACTIONS.Total_Sales
	    FROM COST_BY_SHARE
	        LEFT JOIN SOLD_TRANSACTIONS 
            ON COST_BY_SHARE.login = SOLD_TRANSACTIONS.login AND COST_BY_SHARE.symbol = SOLD_TRANSACTIONS.symbol) costSelect
    ON ownsSelect.login = costSelect.login AND ownsSelect.symbol = costSelect.symbol;

CREATE OR REPLACE VIEW MAX_TRANSACTIONS --done
    AS SELECT MAX(trans_id) AS Trans_ID_Order
    FROM TRXLOG;

CREATE OR REPLACE VIEW MAX_ALLOCATIONS  --done
    AS SELECT MAX(allocation_no) AS Allocation_No_Order
    FROM ALLOCATION;

CREATE OR REPLACE VIEW RECENT_ALLOCATIONS   --done
    AS SELECT login, MAX(allocation_no) AS Allocation_No_Order
    FROM ALLOCATION GROUP BY login;

COMMIT;
-------------------------------------------------------------------------------
                            --END VIEW CREATION--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
                            --START PROCEDURE CREATION--
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE subtractFromBalance(customerID IN VARCHAR2, amountToSubtract IN FLOAT)  --done
    AS Old_Balance FLOAT;
    BEGIN
        SELECT balance into Old_Balance 
        FROM CUSTOMER WHERE customerId = login;
        UPDATE CUSTOMER 
            SET balance = Old_Balance - amountToSubtract
            WHERE login = customerID;
    END;
/

CREATE OR REPLACE PROCEDURE addToBalance(customerID IN VARCHAR2, amountToAdd IN FLOAT) --done
    AS Old_Balance FLOAT;
    BEGIN
        SELECT balance into Old_Balance 
        FROM CUSTOMER WHERE customerId = login;
        UPDATE CUSTOMER 
            SET balance = Old_Balance + amountToAdd
            WHERE login = customerID;
    END;
/

CREATE OR REPLACE PROCEDURE insertNewPurchase(customerID IN VARCHAR2, symbol IN VARCHAR2, numShares IN NUMBER, price IN FLOAT) --done
    AS
        purchaseAmount float;
        maxTransID number;
    BEGIN
        purchaseAmount := (numShares * prices);
        SELECT MAX(trans_id) INTO maxTransID
        FROM TRXLOG;
        INSERT INTO TRXLOG VALUES(maxTransID + 1, customerID, symbol, current_date, 'buy', numShares, price, purchaseAmount);
    END;
/

CREATE OR REPLACE PROCEDURE insertNewDeposit(customerID IN VARCHAR2, depositAmount IN FLOAT) --done
    AS
        maxTransID number;
    BEGIN
        SELECT MAX(trans_id) INTO maxTransID
        FROM TRXLOG;
        INSERT INTO TRXLOG VALUES(maxTransID + 1, customerID, NULL, current_date, 'deposit', NULL, NULL, depositAmount);
    END;
/

CREATE OR REPLACE PROCEDURE UPDATE_TRANSACTIONS(maxTransID IN NUMBER, customerID IN VARCHAR2, updateAmount IN FLOAT, depositDate IN DATE) --TO DO
    AS
        current_balance NUMBER;
        num_shares NUMBER;
        share_price NUMBER;
        alloc_no NUMBER;
        buy_these NUMBER;
        current_percent FLOAT;
        sym VARCHAR2(10);

    BEGIN
        addToBalance(customerID, updateAmount);
        SELECT alloc_no INTO alloc_no 
            FROM RECENT_ALLOCATIONS 
            WHERE login = customerID;
        SELECT COUNT(symbol) INTO buy_these 
            FROM PREFERS 
            WHERE allocation_no = alloc_no;
        SELECT balance INTO current_balance 
            FROM CUSTOMER 
            WHERE login = customerID;
        FOR counter IN 1..buy_these
        LOOP
            SELECT percentage, symbol INTO current_percent, sym
            FROM(
	                SELECT percentage, symbol, rownum AS current_row
	                FROM PREFERS
	                WHERE allocation_no = alloc_no
	            )
            WHERE current_row = counter;
            SELECT price into share_price 
                FROM CLOSINGPRICE 
                WHERE symbol = sym AND p_date = depositDate;
            shares := floor(bal * percent / sharePrice);
            INSERT INTO TRXLOG 
                VALUES(maxTransID + counter, customerID, sym, depositDate, 'buy', num_shares, share_price, num_shares * share_price);
        END LOOP;
    END;
/
-------------------------------------------------------------------------------
                            --END PROCEDURE CREATION--
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
                            --START TRIGGER CREATION--
-------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER CHECK_DEPOSIT --done
    BEFORE INSERT    --should fire before because we don't want to add bad data -Alec
    ON TRXLOG
    FOR EACH ROW
    BEGIN
        IF :new.action LIKE 'deposit' 
            THEN UPDATE_TRANSACTIONS(:new.trans_id, :new.login, :new.amount, :new:t_date);
        END IF;
    End;
/

CREATE OR REPLACE TRIGGER BALANCE_UPDATE    --done
    BEFORE INSERT
    ON TRXLOG
    FOR EACH ROW   
    BEGIN
        IF :new.action LIKE 'sell' 
            THEN subtractFromBalance(:new.login, :new.amount);
        END IF;
        IF :new.action LIKE 'buy' 
            THEN addToBalance(:new.login, :new.amount);
        END IF;
    END;
/

COMMIT;
-------------------------------------------------------------------------------
                            --END TRIGGER CREATION--
-------------------------------------------------------------------------------

--Last commit for good measure, purge recyclebin as well
COMMIT;
PURGE RECYCLEBIN;