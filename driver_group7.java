/*
    Alec Trievel and John Ha
    CS 1555 Spring 2017
    Term Project
*/

import java.sql.*;
import java.util.*;
import java.text.*;
import java.sql.Date;

public class driver_group7
{
    static Connection connection; 
	static Statement statement;
	static ResultSet resultSet;
	static ResultSet resultSet2;
	static PreparedStatement prepStatement;
	static String query;
	static SimpleDateFormat dateformat = new SimpleDateFormat("dd-MMM-yyyy");
    static boolean debugMode = false;

    public static void main(String[] args) throws SQLException 
    {
        String dbUsername = "abt22";
        String dbPassword = "3943128";

        try
        {
            DriverManager.registerDriver (new oracle.jdbc.driver.OracleDriver());
            String url = "jdbc:oracle:thin:@class3.cs.pitt.edu:1521:dbclass";
            connection = DriverManager.getConnection(url, dbUsername, dbPassword); 
            statement = connection.createStatement();
            connection.setAutoCommit(false); 
            connection.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);

            Scanner in = new Scanner(System.in);
            int userChoice = -1;

            System.out.println("\n\t\tBETTER FUTURE ACCESS DATABASE SYSTEM");

            while (userChoice == -1)
            {
                System.out.println("Please select an option:\n1)USER LOGIN\n2)ADMIN LOGIN\n3)RUN STRESS TEST");
                System.out.print("Your choice: ");
                userChoice = in.nextInt();
                in.nextLine();


                if(userChoice < 1 || userChoice > 3)
                {
                    System.out.println("\nError. Invalid entry. Please try again.\n");
                    userChoice = -1;
                }
            }

            if(userChoice == 3)
            {
                debugMode = true;
                runStressTest();
                
                while(true)
                {
                    System.out.print("CONTINUE TESTING (Y to continue)? ");
                    if(!in.nextLine().equalsIgnoreCase("Y"))
                    {
                        System.out.print("ARE YOU SURE YOU WANT TO QUIT (Y to quit)? ");
                        if(in.nextLine().equalsIgnoreCase("Y"))
                        {
                            statement.close();
                            connection.close();
                            System.exit(0);
                        }
                    }
                    runStressTest();
                }
            }

            boolean admin = false;
            String userName = null, password = null;

            if(userChoice == 2)
            {
                admin = true;
            }

            while(true)
            {
                System.out.print("\nEnter your username: ");
                userName = in.nextLine();
                System.out.print("Enter your password: ");
                password = in.nextLine();

                if(!checkLogin(admin, userName, password))
                {
                    System.out.println("\nIncorrect login. Please try again");
                }
                else if(userChoice == 1)
                {
                    System.out.println("\nWelcome user " + userName + "!");
                    break;
                }
                else if(userChoice == 2)
                {
                    System.out.println("\nWelcome administrator!");
                    break;
                }
            }

            boolean start = true;
            boolean adminPriceUpdateDone = false;

            while(start)
            {
                connection.commit();
                try
                {
                    if(admin)
                    {
                        System.out.println("\nSelect an option:");
                        System.out.println("0 - Exit");
                        System.out.println("1 - Add user to the database");
                        System.out.println("2 - Update daily share prices (once per day)");
                        System.out.println("3 - Add new mutual fund");
                        System.out.println("4 - Update today's date/time information");
                        System.out.println("5 - View statistics");
                        System.out.print("Your choice: ");
                        userChoice = in.nextInt();

                        boolean updatedToday = false;
                        switch(userChoice)
                        {
                            case 0:
                                System.out.println("\nGood bye, " + userName + "!");
                                start = false;
                                break;
                            case 1:
                                if(addUser())
                                    System.out.println("\nNEW USER ADDED"); 
                                break;
                            case 2:
                                if(!updatedToday && updatePrices())
                                {
                                    System.out.println("\nPRICES UPDATED");
                                    updatedToday = true;
                                }
                                else
                                {
                                    System.out.println("\nERROR. PRICES CAN ONLY BE UPDATED ONCE A DAY");  
                                }
                                break;
                            case 3:
                                if(addFunds())
                                    System.out.println("\nNEW FUNDS ADDED"); 
                                break;
                            case 4:
                                if(updateTime())
                                    System.out.println("\nTIME UPDATED");      
                                break;
                            case 5:
                                viewStats();        
                                break;
                            default:
                                System.out.println("Error. Invalid option. Please try again.");
                        }
                    }
                    else
                    {
                        System.out.println("\nSelect an option:");
                        System.out.println("0 - Exit");
                        System.out.println("1 - Browse Mutual Funds");
                        System.out.println("2 - Search for Specific Funds");
                        System.out.println("3 - Sell Shares");
                        System.out.println("4 - New Investment or Deposit");
                        System.out.println("5 - Buy New Shares");
                        System.out.println("6 - Conditional Investment");
                        System.out.println("7 - Change Allocation Preferences");
                        System.out.println("8 - View Your Portfolio");
                        System.out.print("Your choice: ");
                        userChoice = in.nextInt();

                        switch(userChoice)
                        {
                            case 0:
                                System.out.println("\nGood bye, " + userName + "!");
                                start = false;
                                break;
                            case 1:
                                browseFunds();  //done
                                break;
                            case 2:
                                searchFunds();  //done
                                break;
                            case 3:
                                sellShares(userName);   //done
                                break;
                            case 4:
                                invest(userName);   //done
                                break;
                            case 5:
                                buyShares(userName);    //done
                                break;
                            case 6:
                                conditionalInvestment(userName);   //NOT DONE
                                break;
                            case 7:
                                changePref(userName);   //NOT DONE
                                break;
                            case 8:
                                viewPortfolio(userName);    //done
                                break;
                            default:
                                System.out.println("Error. Invalid option. Please try again.");
                        }
                    }
        
                }
                catch(Exception e)
                {
                    //most likely a bad user input, but we can just use this hack for now
                    if(in.hasNextLine())
                    {
                        in.nextLine();
                    }
                    System.out.println("\n\nThere was an error processing your request. Changes were rolled-back to maintain structure and accuracy. Please try again.");
                    
                    if(debugMode)
                    {
                        e.printStackTrace();
                    }

                    connection.rollback();
                }
            }
        }
        catch(Exception sql)
        {
            System.out.println("Error establishing connection to the database.");
        }
        finally
        {
            statement.close();
			connection.close();
        }
    }

    /*
     * START ADMIN ONLY FUNCTIONS
     */
     //done
    public static boolean addUser() throws SQLException
    {
        Scanner in = new Scanner(System.in);

        String username = "";
        String password = "";
        String name = "";
        String address = "";
        String email = "";
        boolean admin = false;

        System.out.println("\nYou will be prompted for the information for the new user. \nNote: If an entered value is longer in length than requested, it will be truncated.");
        
        System.out.print("Enter the username for the new user (20 characters): ");
        username = in.nextLine();

        if(!nameAvailable(username))
        {
            System.out.println("\nError. Username already in use. Please try another name.");
            return false;
        }

        System.out.print("Enter the password for the new user (10 characters): ");
        password = in.nextLine();

        System.out.print("Is the new user an admin? (Y for yes, other for no): ");
        if(in.nextLine().equalsIgnoreCase("Y"))
            admin = true;

        System.out.print("Enter the name for the new user (20 characters): ");
        name = in.nextLine();

        System.out.print("Enter the address for the new user (30 characters): ");
        address = in.nextLine();

        System.out.print("Enter the email for the new user (30 characters): ");
        email = in.nextLine();

        if(admin)
        {
            query = "insert into ADMINISTRATOR values (?,?,?,?,?)";
            prepStatement = connection.prepareStatement(query);
            prepStatement.setString(1, username); 
            prepStatement.setString(2, name); 
            prepStatement.setString(3, email); 
            prepStatement.setString(4, address); 
            prepStatement.setString(5, password); 
            prepStatement.executeUpdate();
        }
        else
        {
            query = "insert into CUSTOMER values (?,?,?,?,?,?)";
            prepStatement = connection.prepareStatement(query);
            prepStatement.setString(1, username); 
            prepStatement.setString(2, name); 
            prepStatement.setString(3, email); 
            prepStatement.setString(4, address); 
            prepStatement.setString(5, password); 
            prepStatement.setDouble(6, 0.0);
            prepStatement.executeUpdate();
        }

        connection.commit();
        return true; 
    }

    //done
    public static boolean updatePrices() throws SQLException
    {
        Scanner in = new Scanner(System.in);
        String currentDate = dateAsString(getMutualDate());
        
        query = "SELECT symbol, price FROM CLOSINGPRICE WHERE p_date = ?";
        prepStatement = connection.prepareStatement(query);
        prepStatement.setString(1,  currentDate);
        resultSet = prepStatement.executeQuery();

        while (resultSet.next())
        {
            String symbol = resultSet.getString(1);
            float oldPrice = resultSet.getFloat(2);
            
            System.out.println("\nHere is the current price of today's mutual fund with its symbol " + symbol + ": " + oldPrice);
            System.out.print("Enter the new price: ");
            float newPrice = in.nextFloat();

            query = "UPDATE CLOSINGPRICE set price = ? WHERE symbol = ? AND p_date = ?";
            prepStatement = connection.prepareStatement(query);
            prepStatement.setFloat(1, newPrice);
            prepStatement.setString(2, symbol);
            prepStatement.setString(3, currentDate);
            prepStatement.executeUpdate();
        }

        connection.commit();

        return true;
    }

    //done
    public static boolean addFunds() throws SQLException
    {
        Scanner in = new Scanner(System.in);

        String symbol = "";
        String name = "";
        String description = "";
        String category = "";
        float price = 0;
        String c_date = dateAsString(getMutualDate());

        System.out.println("\nYou will be prompted for the information for the new MUTUALFUND. \nNote: If an entered value is longer in length than requested, it will be truncated.");
        
        System.out.print("Enter the symbol (max 20 characters): ");
        symbol = in.nextLine();

        if(!symbolAvailable(symbol))
        {
            System.out.println("Error. Symbol name already exits.");
            return false;
        }

        System.out.print("Enter the name (max 30 characters): ");
        name = in.nextLine();

        System.out.print("Enter the description (max 100 characters): ");
        description = in.nextLine();

        System.out.print("Enter the category (fixed, bonds, stocks, or mixed): ");
        category = in.nextLine();

        System.out.print("Enter the price: ");
        price = in.nextFloat();

        query = "INSERT into MUTUALFUND values (?,?,?,?,?)";
		prepStatement = connection.prepareStatement(query);
		prepStatement.setString(1, symbol); 
		prepStatement.setString(2, name); 
		prepStatement.setString(3, description); 
		prepStatement.setString(4, category);
        prepStatement.setString(5, c_date);
		prepStatement.executeUpdate();

        query = "INSERT into CLOSINGPRICE values (?,?,?)";
		prepStatement = connection.prepareStatement(query);
		prepStatement.setString(1, symbol);
		prepStatement.setFloat(2,  price);
		prepStatement.setString(3, c_date);
		prepStatement.executeUpdate();

		connection.commit();
		return true;
    }

    //done
    public static boolean updateTime() throws SQLException
    {
        Scanner in = new Scanner(System.in);
        System.out.println("\nThe current date is " + getMutualDate());
        
        Date current = getMutualDate();
        System.out.print("Enter the new year (4 digits): ");
        int year = in.nextInt();
        in.nextLine();

        System.out.print("Enter the new month (1-2 digits, 1 to 12 only): ");
        int month = in.nextInt();
        in.nextLine();

        System.out.print("Enter the new day (1-2 digits, 1 to 31 only): ");
        int day = in.nextInt();
        in.nextLine();

        String dateAsString = day + "-" + getMonth(month) + "-" + year;
        query = "UPDATE MUTUALDATE SET c_date = ?";
		prepStatement = connection.prepareStatement(query);
        prepStatement.setString(1, dateAsString);
		prepStatement.executeUpdate();

        boolean dateExists = false;
		query = "SELECT symbol, price FROM CLOSINGPRICE WHERE p_date = ?";
		prepStatement = connection.prepareStatement(query);
		prepStatement.setString(1, dateAsString);
		resultSet = prepStatement.executeQuery();
		while(resultSet.next())
			dateExists = true;
		
		if(!dateExists)
		{
			query = "SELECT symbol, price FROM CLOSINGPRICE WHERE p_date = ?";
			prepStatement = connection.prepareStatement(query);
			prepStatement.setString(1, dateAsString(current));
			resultSet = prepStatement.executeQuery();
			double price;
			String symbol;
			while(resultSet.next())
			{
				symbol = resultSet.getString(1);
				price = resultSet.getDouble(2);
				query = "INSERT INTO CLOSINGPRICE VALUES(?,?,?)";
				prepStatement = connection.prepareStatement(query);
				prepStatement.setString(1, symbol);
				prepStatement.setDouble(2,  price);
				prepStatement.setString(3, dateAsString);
				prepStatement.execute();
			}
		}

        connection.commit();
		return true;

    }

    //done
    public static boolean viewStats() throws SQLException
    {
        Scanner in = new Scanner(System.in);

        System.out.print("\nHow many months of statsitics would you like to view? ");
        int numMonths = in.nextInt();
        in.nextLine();

        System.out.print("How many rows or data would you like to view for the past " + numMonths + " months? ");
        int numRows = in.nextInt();
        in.nextLine();

        Date now = getMutualDate();
        Calendar cal = new GregorianCalendar();
        cal.setTime(now);
        cal.add(Calendar.MONTH, -numMonths);    //subtract here

        query = "SELECT * FROM (SELECT category, sum(num_shares) FROM SHARES_SOLD WHERE t_date >= ?  GROUP BY category ORDER BY sum(num_shares) DESC) WHERE rownum <= ?";
        prepStatement = connection.prepareStatement(query);
		prepStatement.setString(1, dateformat.format(cal.getTime()));
		prepStatement.setInt(2, numRows);
		resultSet = prepStatement.executeQuery();

        System.out.println("\n\t\tDISPLAYING STATISTICS FOR THE LAST " + numMonths + " MONTHS");
        System.out.println("Top " + numRows + " Highest Volume Categories");
		
        System.out.printf("%-15S %-15S%n", "CATEGORY", "SHARES");
		while(resultSet.next()) 
        {
			System.out.printf("%-15s %-15S%n", resultSet.getString(1), resultSet.getInt(2));
		}
		
		query = "SELECT * FROM (SELECT login, sum(amount) FROM TRXLOG WHERE action = 'buy' AND t_date >= ? GROUP BY login ORDER BY sum(amount) DESC) WHERE rownum <= ?";		
		prepStatement = connection.prepareStatement(query);
		prepStatement.setString(1, dateformat.format(now.getTime()));
		prepStatement.setInt(2, numRows);
		resultSet = prepStatement.executeQuery();

        System.out.println("\nTop " + numRows + " Investors");

		System.out.printf("%-15S %-15S%n", "USER", "AMOUNT");
		while(resultSet.next()) 
        {
			System.out.printf("%-15s %-15S%n", resultSet.getString(1), resultSet.getDouble(2));
		}

		connection.commit();
		return true;
    }
    /*
     * END ADMIN ONLY FUNCTIONS
     */

    /*
     * START USER ONLY FUNCTIONS
     */
     //done
    public static boolean browseFunds() throws SQLException
    {
        Scanner in = new Scanner(System.in);
        String userCategory = "";
        
        System.out.println("\nSelect an option: \n1 - View All Funds \n2 - View by Categories");
        System.out.print("Your choice: ");
        int option = in.nextInt();
        in.nextLine();

        if(option == 2)
        {
            query = "SELECT category FROM MUTUALFUND GROUP BY CATEGORY";
            prepStatement = connection.prepareStatement(query);
            resultSet = prepStatement.executeQuery();

            System.out.println("List of available categories:");
            while(resultSet.next())
            {
                System.out.println(resultSet.getString(1));
            }
            
            System.out.print("Chose a category: ");
            userCategory = in.nextLine();
        }

        System.out.print("Enter the date you wish to view in the following format (DAY-MONTH-YEAR): ");
        String userDate[] = in.nextLine().split("-");
        String dateAsString = Integer.parseInt(userDate[0]) + "-" + getMonth(Integer.parseInt(userDate[1])) + "-" + Integer.parseInt(userDate[2]);
        
        System.out.println("\nSelect an option: \n1 - Order by Price \n2 - Order Alphabetically");
        System.out.print("Your choice: ");
        int orderBy = in.nextInt();
        in.nextLine();

        System.out.printf("%25S %5S %35S %15S %5S%n", "Name", "Symbol", "Description", "Category", "Price");

        if(orderBy == 1)
        {
            if(option == 2)
            {
                query = "SELECT * FROM BROWSE_FUNDS WHERE P_DATE = ? AND CATEGORY = ? ORDER BY price DESC";
                prepStatement = connection.prepareStatement(query);
                prepStatement.setString(1,  dateAsString);
                prepStatement.setString(2,  userCategory);
                resultSet = prepStatement.executeQuery();
            }
            else
            {
                query = "SELECT * FROM BROWSE_FUNDS WHERE P_DATE = ? ORDER BY price DESC";
                prepStatement = connection.prepareStatement(query);
                prepStatement.setString(1,  dateAsString);
            }
        }
        else if(orderBy == 2)
        {
            if(option == 2)
            {
                query = "SELECT * FROM BROWSE_FUNDS WHERE P_DATE = ? AND CATEGORY = ? ORDER BY name DESC";
                prepStatement = connection.prepareStatement(query);
                prepStatement.setString(1,  dateAsString);
                prepStatement.setString(2, userCategory);
                resultSet = prepStatement.executeQuery();
            }
            else
            {
                query = "SELECT * FROM BROWSE_FUNDS WHERE P_DATE = ? ORDER BY name DESC";
                prepStatement = connection.prepareStatement(query);
                prepStatement.setString(1,  dateAsString);
                resultSet = prepStatement.executeQuery();
            }
        }

        while(resultSet.next())
        {
            System.out.printf("%25S %5S %35S %15S %5S%n",resultSet.getString(2),resultSet.getString(1),resultSet.getString(3),resultSet.getString(4),resultSet.getFloat(5));
        }

        return true;
    }

    //done
    public static boolean searchFunds() throws SQLException 
    {
        Scanner in = new Scanner(System.in);

        System.out.print("\nSearch by one (type 1) or two (type 2) keywords? ");
		int numKeywords = in.nextInt();
		in.nextLine();  //flush

		System.out.print("\nEnter the first keyword: ");
		String first = in.nextLine();

		if(numKeywords > 1)
		{
			System.out.print("\nEnter the second keyword: ");
			String second = in.nextLine();

			query = "SELECT * FROM MUTUALFUND WHERE description LIKE ? AND description LIKE ?"; 
			prepStatement = connection.prepareStatement(query);
			prepStatement.setString(1,  "%"+ first +"%");
			prepStatement.setString(2, "%"+ second +"%");
		}
		else
		{
			query = "SELECT * FROM MUTUALFUND WHERE description LIKE ?";
			prepStatement = connection.prepareStatement(query);
			prepStatement.setString(1,  "%"+ first +"%");
		}
		
		resultSet = prepStatement.executeQuery();
		System.out.printf("%30S %10S %40S %20S%n", "Name", "Symbol", "Description", "Category");
		
        while	(resultSet.next()) 
        {
			System.out.printf("%30S %10S %40S %20S%n", resultSet.getString(2), resultSet.getString(1), resultSet.getString(3), resultSet.getString(4));
		}
		
		return true;
     }

    
    //done
    public static boolean sellShares(String userName) throws SQLException
    {
        Scanner in = new Scanner(System.in);

        query = "SELECT symbol, shares FROM OWNS WHERE login = ?";
        prepStatement = connection.prepareStatement(query);
        prepStatement.setString(1,  userName);
        resultSet = prepStatement.executeQuery();

        System.out.println("\nHere is a list of the share you can sell:");
        System.out.printf("%5S %5S%n", "Symbol", "Shares");

        while(resultSet.next())
        {
            System.out.printf("%5S %5S%n", resultSet.getString(1), resultSet.getInt(2));
        }

        System.out.print("Enter a symbol of the share you would like to sell: ");
        String symbol = in.nextLine();
        
        boolean ownsShare = false;
        int ownedAmount = 0;

        query = "SELECT shares FROM OWNS WHERE login = ? AND symbol = ?";
        prepStatement = connection.prepareStatement(query);
        prepStatement.setString(1, userName);
        prepStatement.setString(2,  symbol);
        resultSet = prepStatement.executeQuery();

        while(resultSet.next())
        {
            ownsShare = true;
            ownedAmount = resultSet.getInt(1);
        }
        if(!ownsShare)
        {
            System.out.println("Error. You do not own any shares with that name. Please see the generated list of symbols above.");
            return false;
        }

        System.out.print("How many shares would you like to sell? ");
        int toSell = in.nextInt();

        if(ownedAmount < toSell)
        {
            System.out.println("Error. You cannot sell because you own less than " + toSell + " shares of " + symbol);
            return false;
        }

        int max = getMaxTransaction();
        String date = dateAsString(getMutualDate());
        float price = getFundPrice(symbol, getMutualDate());

        query = "INSERT INTO TRXLOG VALUES (?,?,?,?,?,?,?,?)";
        prepStatement = connection.prepareStatement(query);
        prepStatement.setInt(1, max+1);
        prepStatement.setString(2, userName);
        prepStatement.setString(3, symbol);
        prepStatement.setString(4, date);
        prepStatement.setString(5, "sell");
        prepStatement.setInt(6, toSell);
        prepStatement.setFloat(7, price);
        prepStatement.setFloat(8, toSell * price);
        prepStatement.executeUpdate();
        updateOwnedShares(userName, symbol, toSell, false);

        connection.commit();
        return true;
     }

    //done
    public static boolean invest(String userName) throws SQLException
    {
        Scanner in = new Scanner(System.in);
        int maxTrans = getMaxTransaction() + 1;
		Date now = getMutualDate();
        int alloc_id = 0;
        String sym = "";
		float percent = 0;
		int total = 0;
		int numshares = 0;
		
        System.out.print("How much ($) would you like to deposit? ");
		float amount = in.nextFloat();

		if(amount <= 0)
		{
			System.out.println("Cannot deposit less than or equal to 0. Please try again.");
			return false;
		}

		query = "INSERT INTO TRXLOG (trans_id, login, symbol, t_date, action, num_shares, price, amount) VALUES (?,?,?,?,?,?,?,?)";
		prepStatement = connection.prepareStatement(query);
		prepStatement.setInt(1, maxTrans);
		prepStatement.setString(2, userName);
        prepStatement.setString(3, null);
		prepStatement.setString(4,  dateAsString(now));
		prepStatement.setString(5, "deposit");
		prepStatement.setInt(6, 0);
        prepStatement.setFloat(7, 0);
        prepStatement.setFloat(7, amount);
        prepStatement.executeUpdate();

        /*
		query = "SELECT alloc_no FROM RecentAllocations WHERE login = ?";
		prepStatement = connection.prepareStatement(query);
		prepStatement.setString(1, userName);
		resultSet = prepStatement.executeQuery();
		
        boolean hasMore = true;
		while(resultSet.next())
		{
			hasMore = false;
			alloc_id = resultSet.getInt(1);
		}
		if(hasMore)
			return true;
		
		query = "SELECT symbol, percentage FROM PREFERS WHERE allocation_no = ?";
		prepStatement = connection.prepareStatement(query);
		prepStatement.setInt(1, alloc_id);
		resultSet2 = prepStatement.executeQuery();
		while(resultSet2.next())
		{
			sym = resultSet2.getString(1);
			percent = resultSet2.getFloat(2);
			total = Math.round(percent * amount);
			numshares = (int)Math.floor(total / getFundPrice(sym, now));
			updateOwnedShares(userName, sym, numshares, true);
        }
        */
		
		connection.commit();
		return true;
        
    }

    //done
    public static boolean buyShares(String userName) throws SQLException
    {
        Scanner in = new Scanner(System.in);

        float balance = getUserBalance(userName);
        int trans = getMaxTransaction();
        String currentDate = dateAsString(getMutualDate());

        query = "SELECT symbol, price FROM BROWSE_FUNDS WHERE p_date = ?";
        prepStatement = connection.prepareStatement(query);
        prepStatement.setString(1, currentDate);
        resultSet = prepStatement.executeQuery();
        System.out.println("---Symbol---\t---Price---");

        while(resultSet.next())
        {
            System.out.println(resultSet.getString(1) + "\t\t" + resultSet.getFloat(2));
        }

        System.out.println("\n" + userName + ", your current balance is $" + balance);

        System.out.print("Enter the symbol from the above list of the fund you would like to purchase: ");
        String symbol = in.nextLine();

        query = "SELECT symbol from MUTUALFUND where symbol = ?";
        prepStatement = connection.prepareStatement(query);
        prepStatement.setString(1, symbol);
        resultSet = prepStatement.executeQuery();

        boolean isSymbol = false;

        while(resultSet.next())
        {
            isSymbol = true;
        }
        if(!isSymbol)
        {
            System.out.println("Error. That symbol does not exist.");
            return false;
        }

        float price = getFundPrice(symbol, getMutualDate());

        System.out.print("Enter the number of shrares you would like to purchase: ");
        int amount = in.nextInt();
            
        if(amount * price > balance)
        {
            System.out.println("Error. Insufficent funds.");
            return false;
        }
        else
        {
            query = "INSERT INTO TRXLOG VALUES (?,?,?,?,?,?,?,?)";
            prepStatement = connection.prepareStatement(query);
            prepStatement.setInt(1, trans + 1);
            prepStatement.setString(2, userName);
            prepStatement.setString(3, symbol);
            prepStatement.setString(4, currentDate);
            prepStatement.setString(5, "buy");
            prepStatement.setInt(6, amount);
            prepStatement.setFloat(7, price);
            prepStatement.setFloat(8, amount * price);
            prepStatement.executeUpdate();
        }

        updateOwnedShares(userName, symbol, amount, true);

        connection.commit();
        return true;
    }

    public static boolean changePref(String userName) throws SQLException
    {
        System.out.println("\nNot implemented\n");
        return false;
    }

    public static boolean conditionalInvestment(String userName) throws SQLException
    {
        System.out.println("\nNot implemented\n");
        return false;
    }

    //done
    public static boolean viewPortfolio(String userName) throws SQLException
    {
        query = "SELECT * FROM PORTFOLIO WHERE login = ?";
		prepStatement = connection.prepareStatement(query);
		prepStatement.setString(1,userName);
		resultSet = prepStatement.executeQuery();

		System.out.printf("\n%-20S %-7S %-6S %-7S %-7S %-7S%n", "SYMBOL", "PRICE", "SHARES", "VALUE", "COST", "YIELD");
		
		double total = 0.0;
		
		while(resultSet.next()) 
        {
			String symbol = resultSet.getString(2);
			double price = resultSet.getDouble(3); 
			int shares = resultSet.getInt(4);
			double current_value = price * shares;
			double cost_value = resultSet.getDouble(5);	
			double adjusted_cost = cost_value - resultSet.getDouble(6);	
			double yield = current_value - adjusted_cost;
			
			System.out.printf("%-20s %-7.2f %-6d %-7.2f %-7.2f %-7.2f%n", symbol, price, shares, current_value, cost_value, yield);
			total += current_value;
		}
		
		System.out.println("\nTotal value of your portfolio is: " + total);
		connection.commit();
		return true;
    }
    /*
     * END USER ONLY FUNCTIONS
     */


    /*
     * START HELPER  FUNCTIONS
     */
    public static boolean checkLogin(boolean admin, String userName, String password) throws SQLException
    {
        if(admin)
            query = "SELECT * FROM ADMINISTRATOR WHERE login = ? AND password = ?";
		else
			query = "SELECT * FROM CUSTOMER WHERE login = ? AND password = ?";
		
        prepStatement = connection.prepareStatement(query);
        prepStatement.setString(1, userName);
        prepStatement.setString(2, password);
        resultSet = prepStatement.executeQuery();
        while (resultSet.next())
        {
            if(resultSet.getString(1).equals(userName))
                return true;
        }
        return false;
    }

    private static float getUserBalance(String userName) throws SQLException
	{
		query = "SELECT balance FROM CUSTOMER WHERE login = ?";
		prepStatement = connection.prepareStatement(query);
		prepStatement.setString(1, userName);
		resultSet = prepStatement.executeQuery();
		resultSet.next();

		return resultSet.getFloat(1);
    }

    private static int getMaxAllocNo() throws SQLException
	{
		query = "SELECT * FROM MAX_ALLOCATIONS";
		prepStatement = connection.prepareStatement(query);
		resultSet = prepStatement.executeQuery();
		resultSet.next();

		return resultSet.getInt(1);
	}

    private static Date getMutualDate() throws SQLException 
	{
		Date currentDate;
		query = "SELECT * FROM MUTUALDATE";
		prepStatement = connection.prepareStatement(query);
		resultSet = prepStatement.executeQuery();
		resultSet.next();
		currentDate = (resultSet.getDate(1));

		return currentDate; 
	}

    private static float getFundPrice(String symbol, Date date) throws SQLException
	{
		query = "SELECT price FROM CLOSINGPRICE where symbol = ? AND p_date = ?";
		prepStatement = connection.prepareStatement(query);
		prepStatement.setString(1, symbol);
		prepStatement.setString(2, dateAsString(date));
		resultSet = prepStatement.executeQuery();
		resultSet.next();

		return resultSet.getFloat(1);
	}

    public static int getMaxTransaction() throws SQLException
	{
		query = "SELECT * FROM MAX_TRANSACTIONS"; //update this in the schema file
		prepStatement = connection.prepareStatement(query);
		resultSet = prepStatement.executeQuery();
		resultSet.next();

		return resultSet.getInt(1);
	}

    public static void updateOwnedShares(String userName, String symbol, int amount, boolean buy) throws SQLException	
	{
		query = "SELECT shares FROM OWNS WHERE symbol = ? AND login = ?";
		prepStatement = connection.prepareStatement(query);
		prepStatement.setString(1, symbol);
		prepStatement.setString(2,  userName);
		resultSet = prepStatement.executeQuery();

		boolean ownsShares = false;
		int shares = 0;
		while(resultSet.next())
		{
			shares = resultSet.getInt(1);
			ownsShares = true;
		}
		
		if(buy)
		{	
            if(ownsShares)
			{
				query = "UPDATE OWNS SET shares = ? WHERE login = ? AND symbol = ?";
				prepStatement = connection.prepareStatement(query);
				prepStatement.setInt(1,  amount + shares);
				prepStatement.setString(2, userName);
				prepStatement.setString(3,  symbol);
				prepStatement.executeUpdate();
			}
			else 
			{
				query = "INSERT into OWNS values (?,?,?)";
				prepStatement = connection.prepareStatement(query);
				prepStatement.setString(1, userName);
				prepStatement.setString(2, symbol);
				prepStatement.setInt(3, amount);
				prepStatement.executeUpdate();
			}
		}
		else
		{
			if(amount == shares) 
			{
				query = "DELETE FROM OWNS WHERE login = ? AND symbol = ?";
				prepStatement = connection.prepareStatement(query);
				prepStatement.setString(1, userName);
				prepStatement.setString(2, symbol);
				prepStatement.executeUpdate();
			}
			else 
			{
				query = "UPDATE OWNS set shares = ? WHERE login = ? AND symbol = ?";
				prepStatement = connection.prepareStatement(query);
				prepStatement.setInt(1,  shares - amount);
				prepStatement.setString(2, userName);
				prepStatement.setString(3,  symbol);
				prepStatement.executeUpdate();
			}
		}
	}

	public static String dateAsString(Date date)
	{
		String dateString = date.getDate() + "-" + getMonth(date.getMonth()+1) + 
                            "-" + (date.getYear()+1900);
		return dateString;
	}

    public static String getMonth(int month)
	{
		switch(month)
        {
			case 1:
				return "JAN";
			case 2:
				return "FEB";
			case 3:
				return "MAR";
			case 4:
				return "APR";
			case 5:
				return "MAY";
			case 6:
				return "JUN";
			case 7:
				return "JUL";
			case 8:
				return "AUG";
			case 9:
				return "SEP";
			case 10:
				return "OCT";
			case 11:
				return "NOV";
			default:
				return "DEC";
		}		
	}

    public static boolean symbolAvailable(String symbol) throws SQLException
    {
        query = "SELECT * FROM MUTUALFUND WHERE symbol = ?";
        prepStatement = connection.prepareStatement(query);
        prepStatement.setString(1, symbol);
        resultSet = prepStatement.executeQuery();

        while (resultSet.next())
        {
            if((resultSet.getString(1)).equals(symbol))
                return false;
        }

        connection.commit();
        return true;
    }

    public static boolean nameAvailable(String username) throws SQLException
    {
        query = "SELECT * FROM CUSTOMER WHERE login = ?";
		prepStatement = connection.prepareStatement(query);
		prepStatement.setString(1, username);
		resultSet = prepStatement.executeQuery();

		while (resultSet.next())
		{
			if(resultSet.getString(1).equals(username))
                return false;
		}
		
		query = "SELECT * FROM ADMINISTRATOR WHERE login = ?";
		prepStatement = connection.prepareStatement(query);
		prepStatement.setString(1, username);
		resultSet = prepStatement.executeQuery();
	
        while (resultSet.next())
		{
			if(resultSet.getString(1).equals(username))
                return false;
		}

		connection.commit();
        return true;	
    }
    /*
     * END HELPER FUNCTIONS
     */

    private static void runStressTest()
    {
        Scanner in = new Scanner(System.in);
        boolean admin = false;
        int userChoice = 0;
        String userName = "";
        String password = "";

            try
            {
                while(true)
                    {
                        System.out.print("\nAre you an admin? (Y for yes) ");
                        admin = in.nextLine().equalsIgnoreCase("Y");
                        System.out.print("Enter your username: ");
                        userName = in.nextLine();
                        System.out.print("Enter your password: ");
                        password = in.nextLine();

                        if(!checkLogin(admin, userName, password))
                        {
                            System.out.println("\nIncorrect login. Please try again");
                        }
                        else if(!admin)
                        {
                            System.out.println("\nWelcome user " + userName + "!");
                            break;
                        }
                        else if(admin)
                        {
                            System.out.println("\nWelcome administrator!");
                            break;
                        }
                    }

                    boolean start = true;
                    boolean adminPriceUpdateDone = false;

                    while(start)
                    {
                        connection.commit();
                        try
                        {
                            if(admin)
                            {
                                System.out.println("\nSelect an option:");
                                System.out.println("0 - Exit");
                                System.out.println("1 - Add user to the database");
                                System.out.println("2 - Update daily share prices (once per day)");
                                System.out.println("3 - Add new mutual fund");
                                System.out.println("4 - Update today's date/time information");
                                System.out.println("5 - View statistics");
                                System.out.print("Your choice: ");
                                userChoice = in.nextInt();

                                boolean updatedToday = false;
                                switch(userChoice)
                                {
                                    case 0:
                                        System.out.println("\nGood bye, " + userName + "!");
                                        start = false;
                                        break;
                                    case 1:
                                        if(addUser())
                                            System.out.println("\nNEW USER ADDED"); 
                                        break;
                                    case 2:
                                        if(!updatedToday && updatePrices())
                                        {
                                            System.out.println("\nPRICES UPDATED");
                                            updatedToday = true;
                                        }
                                        else
                                        {
                                            System.out.println("\nERROR. PRICES CAN ONLY BE UPDATED ONCE A DAY");  
                                        }
                                        break;
                                    case 3:
                                        if(addFunds())
                                            System.out.println("\nNEW FUNDS ADDED"); 
                                        break;
                                    case 4:
                                        if(updateTime())
                                            System.out.println("\nTIME UPDATED");      
                                        break;
                                    case 5:
                                        viewStats();        
                                        break;
                                    default:
                                        System.out.println("Error. Invalid option. Please try again.");
                                }
                            }
                            else
                            {
                                System.out.println("\nSelect an option:");
                                System.out.println("0 - Exit");
                                System.out.println("1 - Browse Mutual Funds");
                                System.out.println("2 - Search for Specific Funds");
                                System.out.println("3 - Sell Shares");
                                System.out.println("4 - New Investment or Deposit");
                                System.out.println("5 - Buy New Shares");
                                System.out.println("6 - Conditional Investment");
                                System.out.println("7 - Change Allocation Preferences");
                                System.out.println("8 - View Your Portfolio");
                                System.out.print("Your choice: ");
                                userChoice = in.nextInt();

                                switch(userChoice)
                                {
                                    case 0:
                                        System.out.println("\nGood bye, " + userName + "!");
                                        start = false;
                                        break;
                                    case 1:
                                        browseFunds();  //done
                                        break;
                                    case 2:
                                        searchFunds();  //done
                                        break;
                                    case 3:
                                        sellShares(userName);   //done
                                    break;
                                case 4:
                                    invest(userName);   //done
                                    break;
                                case 5:
                                    buyShares(userName);    //done
                                    break;
                                case 6:
                                    conditionalInvestment(userName);   //NOT DONE
                                    break;
                                case 7:
                                    changePref(userName);   //NOT DONE
                                    break;
                                case 8:
                                    viewPortfolio(userName);    //done
                                    break;
                                default:
                                    System.out.println("Error. Invalid option. Please try again.");
                            }
                        }
            
                    }
                    catch(Exception e)
                    {
                        //most likely a bad user input, but we can just use this hack for now
                        if(in.hasNextLine())
                        {
                            in.nextLine();
                        }
                        System.out.println("\n\nThere was an error processing your request. Changes were rolled-back to maintain structure and accuracy. Please try again.");
                    
                        e.printStackTrace();
                    
                        
                        
                        connection.rollback();
                    }
                }
        }
        catch(SQLException sql)
        {
            sql.printStackTrace();
        }
    }
}