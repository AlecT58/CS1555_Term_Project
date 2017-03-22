--Drop Tables for consistency--
drop table MUTUALFUND cascade constraints;
drop table CLOSINGPRICE cascade constraints;
drop table CUSTOMER cascade constraints;
drop table ADMINISTRATOR cascade constraints;
drop table ALLOCATION cascade constraints;
drop table PREFERS cascade constraints;
drop table TRXLOG cascade constraints;
drop table OWNS cascade constraints;
drop table MUTUALDATE cascade constraints;

--START CREATE TABLES
--First 5 tables from part 1
CREATE TABLE MUTUALFUND
(
    symbol VARCHAR2(20),
    name VARCHAR2(30) NOT NULL,
    description VARCHAR2(100),
    category VARCHAR2(10),
    c_date DATE

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
        REFERENCES MUTUALFUND (symbol)
);

CREATE TABLE CUSTOMER
(
    login VARCHAR2(10),
    name VARCHAR2(20) NOT NULL,
    email VARCHAR2(30),
    address VARCHAR2(30),
    password VARCHAR2(10) NOT NULL,
    balance FLOAT,

    CONSTRAINT customer_pk
        PRIMARY KEY (login) INITIALLY IMMEDIATE DEFERRABLE
    --does balance have to be  >=0? If so, make check statement
);

CREATE TABLE ADMINISTRATOR
(
    login VARCHAR2(10),
    name VARCHAR2(20) NOT NULL,
    email VARCHAR2(30),
    address VARCHAR2(30),
    password VARCHAR2(10),

    CONSTRAINT admin_pk
        PRIMARY KEY (login) INITIALLY IMMEDIATE DEFERRABLE
);

CREATE TABLE ALLOCATION
(
    allocation_no INT PRIMARY KEY,
    symbol VARCHAR2(20),
    percentage FLOAT,
    CONSTRAINT allocation_fk
        FOREIGN KEY (login)
        REFERENCES CUSTOMER (login)
);

--Last 4 tables (NEEDS CONSTRAINTS)
create table PREFERS (
allocation_no integer;
symbol varchar2(20),
percentage float,
constraint pk_prefers primary key(allocation_no, symbol),
constraint fk_prefers_alloc_no foreign key (allocation_no)
    references ALLOCATION (allocation_no)
);

create table TRXLOG (
trans_id integer,
login varchar2(10),
symbol varchar2(20),
t_date date,
action varchar2(10),
num_shares integer,
price float,
amount float,
constraint pk_trxlog primary key (trans_id),
constraint fk_trxlog_login foreign key (login)
	references CUSTOMER (login),
constraint fk_trxlog_symbol foreign key (symbol)
	references MUTUALFUND(symbol)
);

create table OWNS (
login varchar2(10),
symbol varchar2(20),
shares integer,
constraint pk_owns primary key (login, symbol),
constraint fk_owns_login foreign key (login)
	references CUSTOMER (login),
constraint fk_owns_symbol foreign key (symbol)
	references MUTUALFUND(symbol)
);

create table MUTUALDATE (
c_date date,
constraint pk_mutualdate primary key (c_date)
);
--END CREATE TABLES
COMMIT;

--START INSERT STAEMEMENTS
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
INSERT INTO TRXLOG (trans_id, login, t_date, action, num_shares, price, amount)
VALUES (0, 'mike', NULL, '29-MAR-14', 'deposit', NULL, NULL, 1000);

INSERT INTO TRXLOG (trans_id, login, t_date, action, num_shares, price, amount)
VALUES (1, 'mike', 'MM', '29-MAR-14', 'buy', 50, 10, 500);

INSERT INTO TRXLOG (trans_id, login, t_date, action, num_shares, price, amount)
VALUES (2, 'mike', 'RE', '29-MAR-14', 'buy', 50, 10, 500);

INSERT INTO TRXLOG (trans_id, login, t_date, action, num_shares, price, amount)
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
--END INSERT STATEMENTS

--ADD TRIGGERS/VIEWS HERE

COMMIT;
PURGE RECYCLEBIN;
