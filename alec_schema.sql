--First 5 tables from part 1
--John Dropped tables in his version

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
    --set primary and foreign keys
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

COMMIT;