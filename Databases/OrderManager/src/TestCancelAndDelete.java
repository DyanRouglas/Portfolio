import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.sql.*;
import java.util.Properties;

/**
 * TestCancelAndDelete.java
 *
 * @author Vishal Annamaneni
 * @since 2019-06-26
 */

public class TestCancelAndDelete {

    /**
     * Test function to test CancelOrder trigger
     */
    public static void CancelOrder() {
        String protocol = "jdbc:derby:";
        String dbName = "OrderManager";
        String connStr = protocol + dbName + ";create=true";

        Properties props = new Properties(); // connection properties
        // providing a user name and password is optional in the embedded
        // and derbyclient frameworks
        props.put("user", "user1");
        props.put("password", "user1");

        try (
                // connect to database
                Connection conn = DriverManager.getConnection(connStr, props);
                Statement stmt = conn.createStatement();
        ) {
            System.out.printf("\n********************************* Cancelling Order 4 *********************************\n\n");

            // connect to the database using URL
            System.out.println("Connected to database " + dbName);

            String query = String.format("update Orders set Order_Status = 'Cancelled' where ID = 4");
            stmt.executeUpdate(query);


            PrintUtilities.printOrders(conn);
            PrintUtilities.printRecords(conn);
            PrintUtilities.printInventory(conn);

        } catch (SQLException e) {
//            e.printStackTrace();
        }
    }

    /**
     * Test function to test delete after cascade constraint
     * on the Order_Record table
     */
    public static void DeleteOrder() {
        String protocol = "jdbc:derby:";
        String dbName = "OrderManager";
        String connStr = protocol + dbName+ ";create=true";

        Properties props = new Properties(); // connection properties
        // providing a user name and password is optional in the embedded
        // and derbyclient frameworks
        props.put("user", "user1");
        props.put("password", "user1");

        try (
                // connect to database
                Connection conn = DriverManager.getConnection(connStr, props);
                Statement stmt = conn.createStatement();
        ) {
            System.out.printf("\n********************************* Deleting Order 4 *********************************\n\n");

            // connect to the database using URL
            System.out.println("Connected to database " + dbName);

            String query = String.format("delete from Orders where ID = 4");
            stmt.executeUpdate(query);
            PrintUtilities.printOrders(conn);
            PrintUtilities.printRecords(conn);
            PrintUtilities.printInventory(conn);

        } catch (SQLException e) {
//            e.printStackTrace();
        }
    }

}
