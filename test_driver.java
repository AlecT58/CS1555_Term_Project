/*
    Alec Trievel and John Ha
    CS 1555 Spring 2017
    Term Project: Stage 2
*/

import java.sql.*;
import java.util.*;
import java.text.*;
import java.sql.Date;

public class test_driver
{
    static Connection connection; 
	static Statement statement;
	static ResultSet resultSet;
	static ResultSet resultSet2;
	static PreparedStatement prepStatement;
	static String query;
	static SimpleDateFormat df;

    public static void main(String[] args) throws SQLException 
    {
        String dbUsername = "abt22";
        String dbPassword = "3943128";
        SimpleDateFormat currentDate = new SimpleDateFormat("dd-MMM-yyyy");

        try
        {
            // DriverManager.registerDriver (new oracle.jdbc.driver.OracleDriver());
            // String url = "jdbc:oracle:thin:@class3.cs.pitt.edu:1521:dbclass"; 
            // connection = DriverManager.getConnection(url, dbUsername, dbPassword); 
            // statement = connection.createStatement();
            // connection.setAutoCommit(false); 
            // connection.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);


            Scanner in = new Scanner(System.in);
            int userChoice = -1;

            System.out.println("\t\tBETTER FUTURE ACCESS DATABASE SYSTEM");

            while (userChoice == -1)
            {
                System.out.println("Please select an option:\n1)USER LOGIN\n2)ADMIN LOGIN\n");
                System.out.print("Your choice: ");
                userChoice = in.nextInt();

                if(userChoice < 1 || userChoice > 2)
                {
                    System.out.println("\nError. Invalid entry. Please try again.\n");
                    userChoice = -1;
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

                        switch(userChoice)
                        {
                            case 0:
                                System.out.println("\nExiting administrative options...");
                                start = false;
                                break;
                            case 1:
                                addUser();
                                break;
                            case 2:
                                updatePrices();
                                break;
                            case 3:
                                addFunds();
                                break;
                            case 4:
                                updateTime();
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
                        System.out.println("6 - Change Allocation Preferences");
                        System.out.println("7 - View Your Portfolio");
                        System.out.print("Your choice: ");
                        userChoice = in.nextInt();

                        switch(userChoice)
                        {
                            case 0:
                                System.out.println("\nExiting administrative options...");
                                start = false;
                                break;
                            case 1:
                                browseFunds();
                                break;
                            case 2:
                                searchFunds();
                                break;
                            case 3:
                                sellShares(userName);
                                break;
                            case 4:
                                invest(userName);
                                break;
                            case 5:
                                buyShares(userName);
                                break;
                            case 6:
                                changePref(userName);
                                break;
                            case 7:
                                viewPortfolio(userName);
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
                    System.out.println("\n\nThere was an error processing your request. Changes were rolled back to maintain structure. Please try again.");
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

    /*
     * START ADMIN ONLY FUNCTIONS
     */
    public static boolean addUser() throws SQLException
    {
        return false;
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
            
            System.out.println("Here is the current price of mutual fund with symbol " + symbol + ":" + oldPrice);
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

    public static boolean addFunds() throws SQLException
    {
        return false;
    }

    public static boolean updateTime() throws SQLException
    {
        return false;
    }

    public static boolean viewStats() throws SQLException
    {
        return false;
    }
    /*
     * END ADMIN ONLY FUNCTIONS
     */

    /*
     * START USER ONLY FUNCTIONS
     */
     public static boolean browseFunds() throws SQLException
     {
         return false;
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

        System.out.println("Here is a list of the share you can sell:");
        System.out.printf("%5S %5S%n", "Symbol", "Shares");

        while(resultSet.next())
        {
            System.out.printf("%5S %5S%n", resultSet.getString(1), resultSet.getInt(2));
        }

        System.out.print("Enter a symbol of the share you would like to sell: ");
        String symbol = in.nextLine();
        
        boolean ownsShare = false;
        int ownedAmount = 0;

        query = "SELECT shares FROM OWNS where login = ? AND symbol = ?";
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

        System.out.println("How many shares would you like to sell?");
        int toSell = in.nextInt();

        if(ownedAmount < toSell)
        {
            System.out.println("Error. You cannot sell because you own less than " + toSell + " shares of " + symbol);
            return false;
        }

        int max = findLatestTransaction();
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

     public static boolean invest(String userName) throws SQLException
     {
         return false;
     }

    //done
    public static boolean buyShares(String userName) throws SQLException
    {
        Scanner in = new Scanner(System.in);

        float balance = getUserBalance(userName);
        int trans = getMaxTransaction();
        String currentDate = dateAsString(getMutualDate());

        query = "SELECT symbol, price FROM FUNDS where p_date = ?";
        prepStatement = connection.prepareStatement(query);
        prepStatement.setString(1, currentDate);
        resultSet = prepStatement.executeQuery();
        System.out.println("---Symbol---\t---Price---");

        while(resultSet.next())
        {
            System.out.println(resultSet.getString(1) + "\t" + resultSet.getFloat(2));
        }

        System.out.println("\n" + userName + ", your current balance is $" + balance);

        System.out.print("Enter the symbol of the fund you would like to purchase: ");
        String symbol = in.nextLine();

        query = "SELECT symbol from MUTUALFUND where symbol=?";
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

        System.out.print("Enter the number of shres you would like to purchase: ");
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
        return false;
    }

    public static boolean viewPortfolio(String userName) throws SQLException
    {
        return false;
    }
    /*
     * END USER ONLY FUNCTIONS
     */


    /*
     * START HELPER  FUNCTIONS
     */
    private static int findLatestTransaction() throws SQLException
	{
		query = "SELECT * FROM MAXTRX";
		prepStatement = connection.prepareStatement(query);
		resultSet = prepStatement.executeQuery();
		resultSet.next();

		return resultSet.getInt(1);
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
		query = "SELECT * FROM MAXALLOC";
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
		query = "SELECT * FROM MAXTRX"; //update this in the schema file
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
				query = "UPDATE OWNS set shares = ? WHERE login = ? AND symbol = ?";
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

    /*
     * END HELPER FUNCTIONS
     */
}