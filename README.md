# CS1555_Term_Project
Term project for CS1555 Spring 2017. Created by John Ha and Alec Trievel

#### Project Goal
The goal of this project is to design and implement an electronic investing system of 401(k) retirement accounts.
The core of such a system is a database system and a set ACID transactions. Our system, which we
call “BetterFuture”, allows personal investors to buy shares of mutual funds (of stocks, bonds, or mixed of
both), exchange-traded shares, and keep track of their BetterFuture investments.

#### Milestone 1: The BetterFuture Database Schema
The BetterFuture Database includes information about the mutual funds, customers and their investments,
the transaction histories and the current time and date (we do NOT use system time, rather, we maintain the
“pseudo” current time in separate relation called MUTUALDATE). The latter will allow us to test different
scenarios.
* Mutual funds
The BetterFuture offers a variety of mutual funds such as money-market, real-estate, short-termbonds,
long-term-bonds, balance-bonds-stocks, social-responsibility-bonds-stocks, general-stocks,
aggressive-stocks and international-markets-stocks. Each mutual fund has a name (e.g., moneymarket),
is identified by its symbol and belongs to one or more categories: fixed, bonds, stocks
and mixed. For example, money-market and real-estate are fixed, while balance-bonds-stocks and
social-responsibility-bonds-stocks are mixed. The database also maintains a description for each fund
and the date when the fund was created. In addition, the database keeps track of the closing price
of each mutual fund which is used in the following day for purchases, exchanges-traded shares and
calculation of investments.
* Customer data
For every customer, we store his/her name, address, email address, a unique login-name and password.
Each customer may own some funds and also has his/her allocation preferences based on which assets
are allocated: Every time a customer deposits an amount to his/her 401(k) account, this amount
is invested in shares based on the allocation preferences expressed as percentages. Customers can
change their allocation preferences once a month. A customer can distribute his/her investment to
as many funds as he/she wants. Each fund will have a corresponding percentage and the sum of the
percentages should be 100%.
* Investment transactions
Finally, the history of trading transactions is maintained in the TRXLOG table. Each transaction
records the customer, the mutual fund involved in the transaction, the number of shares, the price of
the mutual fund and the total amount. The date when the transaction was processed and the action
taken are also stored.
