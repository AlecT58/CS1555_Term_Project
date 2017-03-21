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

--First 5 tables from part 1

CREATE TABLE MUTUALFUND
(
    symbol VARCHAR2(20) PRIMARY KEY,
    name VARCHAR2(30),
    description VARCHAR2(100),
    category VARCHAR2(10),
    c_date DATE
);

CREATE TABLE CLOSINGPRICE
(
    symbol VARCHAR2(20),
    price FLOAT,
    p_date DATE,
    CONSTRAINT closing_pk 
        PRIMARY KEY (symbol, p_date),
    CONSTRAINT closing_fk
        FOREIGN KEY (symbol) 
        REFERENCES MUTUALFUND (symbol)
);

CREATE TABLE CUSTOMER
(
    login VARCHAR2(10) PRIMARY KEY,
    name VARCHAR2(20),
    email VARCHAR2(30),
    address VARCHAR2(30),
    password VARCHAR2(10),
    balance FLOAT
);

CREATE TABLE ADMINISTRATOR
(
    login VARCHAR2(10) PRIMARY KEY,
    name VARCHAR2(20),
    email VARCHAR2(30),
    address VARCHAR2(30),
    password VARCHAR2(10),
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

--Last 4 tables
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

COMMIT;