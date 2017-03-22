# CS1555_Term_Project
Term project for CS1555 Spring 2017. Created by John Ha and Alec Trievel

### Project Goal
The goal of this project is to design and implement an electronic investing system of 401(k) retirement accounts.
The core of such a system is a database system and a set ACID transactions. Our system, which we
call “BetterFuture”, allows personal investors to buy shares of mutual funds (of stocks, bonds, or mixed of
both), exchange-traded shares, and keep track of their BetterFuture investments.

### Milestone 1: The BetterFuture Database Schema
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

### Milestone 2: the BetterFuture interface and Functions
For this project, you need to design two easy-to-use interfaces for two different user groups: administrators
and customers (note that an administrator could not be a customer under our BetterFuture company rules).
You are expected to implement your project in Java. You may design nice graphic interfaces, but it is
not required and it carries NO bonus points. A simple text-oriented menu with different options is sufficient
enough for this project: a two level menu such that the higher level menu provides options for administrators
login and normal user login. The lower level menu provides different options for different users, depending
on whether she is an administrator or he is a customer.
  
  You can develop your project on either unixs, class3 or Windows environments, but we will only test
your code in unixs or class3 machine. So even though your code works in a windows environment, you
should make sure it works on unixs or class3 before you submit your project.
  
  You need to design the **SQL transactions** appropriately and when necessary, use the concurrency control
mechanisms supported by Oracle (e.g., isolation level, locking modes) to make sure that inconsistent state
will not occur. There are two situations that you should handle:
* If the same user logs in and runs functions on two different terminals concurrently, the application
semantics should remain still intact. For example, if the customer attempts to buy shares from two
different terminals for a sum higher that his/her balance, one of the transactions should fail.
* If the administrator updates the share price of a mutual fund and/or updates today’s date while a
customer is buying/selling shares of the same mutual fund, the state of the database should stay consistent.
For example, the administrator updates the per share price of stock XYZ from $10 to $15
while a customer is trying to buy 1 share for XYZ. If the customer’s balance is $10, then the system
cannot record the purchase of 1 shares at $15.

  The objective of this project is to familiarize yourself with all the powerful features of SQL which include
functions, procedures and triggers. Recall that triggers and stored procedures can be used to make
your code more efficient besides enforcing integrity constraints.

Each interface is described as a set of functions. Many of which should be processed in an ”all or nothing”
fashion. The functions are described as following:
* Customer interface

    -Browsing mutual funds
Customers are allowed to look at the list of all mutual funds or those in a category of their choice;
they can also ask for funds to be sorted on the highest price for a given date, or alphabetically
by fund name.

    – Searching mutual fund by text
Customers can specify up to two keywords; our system has to return the products that contain
ALL these keywords in their mutual fund description.

    – Investing
Customers may submit (deposit) an amount for investment, which is used to buy shares based on
their allocation preference. Note that a ’deposit’ transaction triggers a set of ’buy’ transactions
and this should be automated by a trigger defined in your database. Other implementations
will result in 0 points for this task. Also, Investing should either result in buying shares of all
mutual funds as specified in the allocation or none. Buying some is not an option. Thus, when
an amount is deposited and the new balance in the account is not sufficient to buy all the shares
as specified in the allocation, that amount is just deposited in the account. In addition, any
remaining amount after an investment becomes the new balance in the account.

    – Selling shares
A customer may sell a number of shares of a mutual fund by providing its symbol and the
number of shares. The resulting amount from the sell remains in the customers account as a
balance which can be used for buying shares of another mutual fund. Note that the balance
should be automatically updated by a trigger defined in your database.

    – Buying shares
A customer may buy a number of shares of a mutual fund by providing its symbol and the
number of shares or by providing its symbol and the amount to be used in the trade. In both
cases, the required amount should not exceed the balance in the customer’s account.
Note, when a customer buys shares by specifying an amount which is equal or less the balance
in his/her account. The customer buys the maximum number of (whole) shares based on the
specified amount and the remaining amount remains in the balance. That this is not the same
when you specify the number of shares to be bought. If the balance is not sufficient to buy all
the shares, no share is bought. Also, the price of a share on a given day is the closing price of
the most recent trading day, e.g., on a Monday will be the closing price of the previous Friday.

    – Conditional investment
There are two kinds of condition. First, a customer may set up a date, so that on that date,
certain investment action (invest/buy/sell) will be executed. Second, a customer may set up
price condition for buy and sell. For example, buy certain amount of mutual fund if its price
drops under certain point or sell some if the price rises above certain point. The conditional
investment should be realized through triggers.

    – Changing the allocation preference
A customer may change his/her allocation preference.

    – Customer portfolio
This function generates a performance report of a customer portfolio. For a specific date, the
report will list the mutual funds the customer owns shares of: their symbols, their prices, the
number of shares, their current values on the specific date, the cost value and the yield as well
as the total value of the portfolio. We define price to be the amount of money needed to buy one
share of a stock. This price changes every day as discussed above. The current value of a given
stock owned by a customer is defined as the product of the number of shares and the price on
the specific date. The cost value of a stock is the total amount paid to purchase the shares. The
adjusted cost is the cost value minus the sum of all the sales of the given stock. Thus, the yield
is the current value minus the adjusted cost. We define the total value of the portfolio to be the
sum of the current value of the stocks owned by the customer.

* Administrator interface
    – New customer registration
Each new customer has to provide his/her name, address, email address, preferred login name
and password. You should also specify whether the new user is an administrator or not. Your
database should prevent two customers from selecting the same login name.

    – Updating share quotes for a day
Update the price of each share of a mutual fund.

    – Adding new mutual fund.
Add a new mutual fund.

    – Updating the time and date.
    
    – Statistics
For the past x months, we want to know
    1. the top k highest volume categories (highest count of shares sold)
    2. the top k most investors (highest invested amount)
k should be an input parameter that can be specified by the users of your system.

You must verify the login name and password of all users at the beginning. By default, we assume a preexisting
administrator with a login name “admin” and a password “root”. This information can be inserted
into your table after you create the database. You can add yourselves as the first customers.

### Milestone 3: Bringing it all together
The primary task for this phase is to create a Java driver program to demonstrate the correctness of your
BetterFuture backend by calling all of the above functions. It may prove quite handy to write this driver as
you develop the functions as a way to test them. Your driver should also include a benchmark feature that
stress the stability of your system buy calling each function automatically for multiple time with reasonably
large amount of data and display corresponding results each time a function is being called.

Now this may not seem like a lot for a third milestone (especially since it is stated that you may want
to do this work alongside Milestone 2). The reasoning for this is to allow you to focus on incorporating
feedback from the TA regarding Milestones 1 and 2 into your project as part of Milestone 3. This will be
the primary focus of Milestone 3.
