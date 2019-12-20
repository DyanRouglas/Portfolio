import java.util.Scanner;
import java.sql.*;
import java.util.Properties;

/**
 * QueryOrderManager.java
 *
 * @author Vishal Annamaneni
 * @author Ryan Douglas
 * @since 2019-06-24
 */

public class QueryOrderManager {

    /** Connection variable accessible by all static functions */
    private static Connection conn;

    static String lines = "\n--------------------------------------------------------"
            + "------------------------------------------------------------------"
            + "------------------------------------------------------------------"
            + "--------------------------------------------------------------\n\n";

    /**
     * This function selects and prints a product from the product
     * table based on the input SKU
     *
     * @param SKU the product SKU
     */
    public static void getProduct(String SKU) {
        try (Statement stmt = conn.createStatement();) {
            String query = String.format("select * from Product where SKU = '%s'", SKU);
            ResultSet rs = stmt.executeQuery(query);

            System.out.println("Product:");
            while (rs.next()) {
                String sk = rs.getString(1);
                String name = rs.getString(2);
                String desc = rs.getString(3);

                System.out.printf("SKU: %s\t\tName: %s\t\tDescription: %s\n", sk, name, desc);
            }
            System.out.println();
        } catch (SQLException e) {
            System.err.println("Error/Invalid Input");
        }
    }

    /**
     * This function selects and prints a product from the inventory
     * table based on the input SKU
     *
     * @param SKU the product SKU
     */
    public static void getInventory(String SKU) {
        try (Statement stmt = conn.createStatement();) {
            String query = String.format("select * from Inventory_Record where SKU = '%s'", SKU);
            ResultSet rs = stmt.executeQuery(query);

            System.out.println("Inventory");
            while (rs.next()) {
                String sk = rs.getString(1);
                int quantity = rs.getInt(2);
                double price = rs.getDouble(3);

                System.out.printf("SKU: %s\t\tQuantity: %d\t\tPrice: %f\n", SKU, quantity, price);
            }
            System.out.println();
        } catch (SQLException e) {
            System.err.println("Error/Invalid Input");
        }
    }

    /**
     * This function selects and prints a customer from the customer
     * table based on the input Customer ID
     *
     * @param custID the customer ID
     */
    public static void getCustomer(int custID) {
        try (Statement stmt = conn.createStatement();) {

            String query = String.format("select * from Customer where ID = %d", custID);
            ResultSet rs = stmt.executeQuery(query);

            System.out.println("Customer");
            while (rs.next()) {
                int id = rs.getInt(1);
                String customer_First_Name = rs.getString(2);
                String customer_Last_Name = rs.getString(3);
                String address =rs.getString(4);
                String city = rs.getString(5);
                String state =rs.getString(6);
                String country = rs.getString(7);
                String code = rs.getString(8);

                System.out.printf("ID: %d\t\tName: %s %s\t\tAddress: %s, %s, %s, %s - %s\n", id, customer_First_Name, customer_Last_Name,
                        address, city, state, country, code);
            }
            System.out.println();

        } catch (SQLException e) {
            System.err.println("Error/Invalid Input");
        }
    }

    /**
     * This function selects and prints an Order from the Order
     * table based on the input Order ID
     *
     * @param oID the order ID
     */
    public static void getOrder(int oID) {
        try (Statement stmt = conn.createStatement();) {

            String query = String.format("select * from Orders where ID = %d", oID);
            ResultSet rs = stmt.executeQuery(query);

            System.out.println("Orders");
            while (rs.next()) {
                int id = rs.getInt(1);
                int cid = rs.getInt(2);
                String oDate = rs.getString(3);
                String sDate = rs.getString(4);
                String status = rs.getString(5);
                System.out.printf("Order ID: %d\t\tCustomer ID: %d\t\tOrder Date: %s\t\tShipment Date: %s\t\tOrder Status: %s\n",
                        id, cid, oDate, sDate, status);
            }
            System.out.println();

        } catch (SQLException e) {
            System.err.println("Error/Invalid Input");
        }
    }

    /**
     * This function selects and prints an Order Record from the
     * Order_Record table based on the input Order ID and Product SKU
     *
     * @param oID the order ID
     * @param SKU the product SKU
     */
    public static void getOrderRecord(int oID, String SKU) {
        try (Statement stmt = conn.createStatement();) {

            String query = String.format("select * from Order_Record where ID = %d and SKU = '%s'", oID, SKU);
            ResultSet rs = stmt.executeQuery(query);

            System.out.println("Order Record:");
            while (rs.next()) {
                int id = rs.getInt(1);
                String sk = rs.getString(2);
                int quantity = rs.getInt(3);
                double price = rs.getDouble(4);
                String status = rs.getString(5);
                int pending = rs.getInt(6);

                System.out.printf("Order ID: %d\t\tSKU: %s\t\tQuantity: %s\t\tPrice: %f\t\tStatus: %s\t\tPending Inventory: %d\n",
                        id, sk, quantity, price, status, pending);
            }
            System.out.println();
        } catch (SQLException e) {
            System.err.println("Error/Invalid Input");
        }
    }

    /**
     * This function selects and prints all Order Record from the
     * Order_Record table based on the input Order ID
     *
     * @param oID the Order ID
     */
    public static void getOrderRecord(int oID) {
        try (Statement stmt = conn.createStatement();) {

            String query = String.format("select * from Order_Record where ID = %d", oID);
            ResultSet rs = stmt.executeQuery(query);

            System.out.println("Order Record:");
            while (rs.next()) {
                int id = rs.getInt(1);
                String sk = rs.getString(2);
                int quantity = rs.getInt(3);
                double price = rs.getDouble(4);
                String status = rs.getString(5);
                int pending = rs.getInt(6);

                System.out.printf("Order ID: %d\t\tSKU: %s\t\tQuantity: %s\t\tPrice: %f\t\tStatus: %s\t\tPending Inventory: %d\n",
                        id, sk, quantity, price, status, pending);
            }
            System.out.println();

        } catch (SQLException e) {
            System.err.println("Error/Invalid Input");
        }
    }

    /**
     * This function selects and prints all Order Records from the
     * Order_Record table based on the Product SKU
     *
     * @param SKU the product SKU
     */
    public static void getOrderRecord(String SKU) {
        try (Statement stmt = conn.createStatement();) {

            String query = String.format("select * from Order_Record where SKU = '%s'", SKU);
            ResultSet rs = stmt.executeQuery(query);

            System.out.println("Order Record:");
            while (rs.next()) {
                int id = rs.getInt(1);
                String sk = rs.getString(2);
                int quantity = rs.getInt(3);
                double price = rs.getDouble(4);
                String status = rs.getString(5);
                int pending = rs.getInt(6);

                System.out.printf("Order ID: %d\t\tSKU: %s\t\tQuantity: %s\t\tPrice: %f\t\tStatus: %s\t\tPending Inventory: %d\n",
                        id, sk, quantity, price, status, pending);
            }
            System.out.println();

        } catch (SQLException e) {
            System.err.println("Error/Invalid Input");
        }
    }

    /**
     * Helper function to display choices in the console
     */
    public static void printOptions() {

        String[] options = {"Run a query on the Product Table", "Run a query on Inventory_Record Table",
                "Run a query on Customer table", "Run a query on Orders Table", "Run a query on Order_Record Table"};

//        System.out.printf("Select the realtion to query on:\n");

        System.out.printf("Select from the following available operations:\n");
        for (int i = 0; i < 5; i++) {
            System.out.printf("%d: %s\n", i+1, options[i]);
        }

        System.out.printf("0: Run a custom Query\n");
        System.out.printf("9: Exit\n\n>> ");
    }

    /**
     * This helper function takes the input stream and returns
     * the next occurring valid integer
     *
     * @param in the input scanner
     * @return the first valid input integer
     */
    public static int getIntegerInput(Scanner in) {
        while (!in.hasNextInt()) in.next();
        int num1 = in.nextInt();
        return num1;
    }

    /**
     * Helper function to run the Order Record querys
     *
     * @param in the input scanner
     */
    public static void runOrderRecords( Scanner in) {
        System.out.printf("\nSelect the type of query:\n");
        System.out.printf("0: Select all Order Records\n");
        System.out.printf("1: Order Record based on Order ID and SKU\n");
        System.out.printf("2: Order Record based on Order ID\n");
        System.out.printf("3: Order Record based on SKU\n");
        System.out.printf("9: Go back to the main menu\n");

        int choice = getIntegerInput(in);
        int inInput;
        String strInput;
        if (choice == 1) {
            System.out.printf("Enter a SKU\n>> ");
            in.nextLine();
            strInput = in.nextLine();
            System.out.printf("Enter an Order ID\n>> ");
            inInput = getIntegerInput(in);
            System.out.println(lines);
            getOrderRecord(inInput, strInput);
            System.out.println(lines);
        } else if (choice == 2) {
            System.out.printf("Enter an Order ID\n>> ");
            inInput = getIntegerInput(in);
            System.out.println(lines);
            getOrderRecord(inInput);
            System.out.println(lines);
        } else if (choice == 3) {
            System.out.printf("Enter a SKU\n>> ");
            in.nextLine();
            strInput = in.nextLine();
            System.out.println(lines);
            getOrderRecord(strInput);
            System.out.println(lines);
        } else if (choice == 9) {
            System.out.printf("\nGoing back to the main menu\n\n");
        } else if (choice == 0) {
            try {
                System.out.println(lines);
                PrintUtilities.printRecords(conn);
                System.out.println(lines);
            } catch (Exception e) {

            }

        } else {
            System.out.printf("Invalid number. Back to the main menu\n\n");
        }
    }

    public static void runCustomQuery(String query) {

        try (Statement stmt = conn.createStatement();) {

            ResultSet rs = stmt.executeQuery(query);
            ResultSetMetaData rsmd = rs.getMetaData();
            int columnsNumber = rsmd.getColumnCount();

            System.out.printf("\nUnlabelled Output:\n");

            // Iterate through the data in the result set and display it.
            while (rs.next()) {
                //Print one row
                for(int i = 1 ; i <= columnsNumber; i++){
                    System.out.printf("%20s\t", rs.getString(i));
//                    System.out.print(rs.getString(i) + "\t\t"); //Print one element of a row
                }
                System.out.println();//Move to the next line to print the next row.
            }
            System.out.println();

        } catch (SQLException e) {
            System.err.printf("Error in executing Query. Error Message: %s\n\n", e.getMessage());
        }

    }

    public static void main(String[] args) {
        // the default framework is embedded
        String protocol = "jdbc:derby:";
        String dbName = "OrderManager";
        String connStr = protocol + dbName + ";create=true";

        Properties props = new Properties(); // connection properties
        // providing a user name and password is optional in the embedded
        // and derbyclient frameworks
        props.put("user", "user1");
        props.put("password", "user1");

        // result set for queries
        ResultSet rs = null;
        try (
                // open data file
                Scanner in = new Scanner(System.in);

                // connect to database
                Connection conn = DriverManager.getConnection(connStr, props);
                Statement stmt = conn.createStatement();

        ) {
            // connect to the database using URL
            System.out.println("Connected to database " + dbName);
            System.out.println();

            QueryOrderManager.conn = conn;

            boolean cont = true;

            while(cont) {
                printOptions();

                int choice = getIntegerInput(in);

                String input;
                int inInt;
                switch (choice) {
                    case 0:
                        System.out.printf("Enter the Select query to run\n>> ");
                        in.nextLine();
                        input = in.nextLine();
                        System.out.println(lines);
                        runCustomQuery(input);
                        System.out.println(lines);
                        break;
                    case 1:
                        System.out.printf("Enter a SKU or 'All' to Select all Products\n>> ");
                        in.nextLine();
                        input = in.nextLine();
                        System.out.println(lines);
                        if (input.equalsIgnoreCase("all")) {
                            PrintUtilities.printProducts(conn);
                        } else {
                            getProduct(input);
                        }
                        System.out.println(lines);
                        break;
                    case 2:
                        System.out.printf("Enter a SKU or 'All' to Select all Inventory records\n>> ");
                        in.nextLine();
                        input = in.nextLine();
                        System.out.println(lines);
                        if (input.equalsIgnoreCase("all")) {
                            PrintUtilities.printInventory(conn);
                        } else {
                            getInventory(input);
                        }
                        System.out.println(lines);
                        break;
                    case 3:
                        System.out.printf("Enter a Customer ID or 0 to Select all Orders\n>> ");
                        inInt = getIntegerInput(in);
                        System.out.println(lines);
                        if (inInt == 0) {
                            PrintUtilities.printCustomers(conn);
                        } else {
                            getCustomer(inInt);
                        }
                        System.out.println(lines);
                        break;
                    case 4:
                        System.out.printf("Enter an Order ID or 0 to Select all Orders\n>> ");
                        inInt = getIntegerInput(in);
                        System.out.println(lines);
                        if (inInt == 0) {
                            PrintUtilities.printOrders(conn);
                        } else {
                            getOrder(inInt);
                        }
                        System.out.println(lines);
                        break;
                    case 5:
                        runOrderRecords(in);
                        break;
                    case 9:
                        cont = false;
                        System.out.printf("Exiting...\n\n");
                        break;
                    default:
                        System.out.printf("Invalid option. Back to main menu\n\n");
                        break;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
