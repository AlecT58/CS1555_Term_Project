--MASTER SCHEMA--


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



























