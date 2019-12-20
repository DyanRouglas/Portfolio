import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * PrintUtilities.java
 *
 * @author Vishal Annamaneni
 * @author Ryan Douglas
 * @since 2019-06-15
 */

public class PrintUtilities {

    /**
     * Print Product table.
     * @param conn the connection
     * @return number of authors
     * @throws SQLException if a database operation fails
     */
    static int printProducts(Connection conn) throws SQLException {
        try (
                Statement stmt = conn.createStatement();
                // list authors and their ORCIDs
                ResultSet rs = stmt.executeQuery(
                        "select * from Product order by Name")
        ) {
            System.out.println("Products:");
            int count = 0;
            while (rs.next()) {
                String SKU = rs.getString(1);
                String name = rs.getString(2);
                String description = rs.getString(3);

                System.out.printf("SKU: %s \t\t Name: %10s \t\t Description: %s\n", SKU, name, description);
                count++;
            }
            System.out.println();
            return count;
        }
    }

    /**
     * Print Inventory table.
     * @param conn the connection
     * @return number of authors
     * @throws SQLException if a database operation fails
     */
    static int printInventory(Connection conn) throws SQLException {
        try (
                Statement stmt = conn.createStatement();
                // list authors and their ORCIDs
                ResultSet rs = stmt.executeQuery(
                        "select * from Inventory_Record")
        ) {
            System.out.println("Inventory:");
            int count = 0;
            while (rs.next()) {
                String SKU = rs.getString(1);
                int quantity = rs.getInt(2);
                double price = rs.getDouble(3);

                System.out.printf("SKU: %s \t\t Quantity: %d \t\t Price: $%.2f\n", SKU, quantity, price);
                count++;
            }
            System.out.println();
            return count;
        }
    }

    /**
     * Print Customer table.
     * @param conn the connection
     * @return number of authors
     * @throws SQLException if a database operation fails
     */
    static int printCustomers(Connection conn) throws SQLException {
        try (
                Statement stmt = conn.createStatement();
                // list authors and their ORCIDs
                ResultSet rs = stmt.executeQuery(
                        "select * from Customer order by ID");
        ) {
            System.out.println("Customers:");
            int count = 0;
            while (rs.next()) {
                int ID = rs.getInt(1);
                String customer_First_Name = rs.getString(2);
                String customer_Last_Name = rs.getString(3);
                String address =rs.getString(4);
                String city = rs.getString(5);
                String state =rs.getString(6);
                String country = rs.getString(7);
                String code = rs.getString(8);

                System.out.printf("ID: %-10d Name: %10s %15s  \t Address: %s, %s, %s, %s - %s\n",
                        ID, customer_First_Name, customer_Last_Name, address, city, state, country, code);
                count++;
            }
            System.out.println();
            return count;
        }
    }

    /**
     * Print Orders table.
     * @param conn the connection
     * @return number of authors
     * @throws SQLException if a database operation fails
     */
    static int printOrders(Connection conn) throws SQLException {
        try (
                Statement stmt = conn.createStatement();
                // list authors and their ORCIDs
                ResultSet rs = stmt.executeQuery(
                        "select * from Orders order by ID");
        ) {
            System.out.println("Orders:");
            int count = 0;
            while (rs.next()) {
                int id = rs.getInt(1);
                int cid = rs.getInt(2);
                String oDate = rs.getString(3);
                String sDate = rs.getString(4);
                String status = rs.getString(5);

                if (!status.equalsIgnoreCase("placed")) {
                    System.err.printf("Order ID: %d \t Customer ID: %d \t Order Date: %s \t Shipment Date: %10s \t Order Status: %s\n",
                            id, cid, oDate, sDate, status);
                } else {
                    System.out.printf("Order ID: %d \t Customer ID: %d \t Order Date: %s \t Shipment Date: %10s \t Order Status: %s\n",
                            id, cid, oDate, sDate, status);
                }

//                System.out.printf("Order ID: %d \t Customer ID: %d \t Order Date: %s \t Shipment Date: %10s \t Order Status: %s\n",
//                        id, cid, oDate, sDate, status);
                count++;
            }
            System.out.println();
            return count;
        }
    }

    /**
     * Print Records table.
     * @param conn the connection
     * @return number of authors
     * @throws SQLException if a database operation fails
     */
    static int printRecords(Connection conn) throws SQLException {
        try (
                Statement stmt = conn.createStatement();
                // list authors and their ORCIDs
                ResultSet rs = stmt.executeQuery(
                        "select * from Order_Record order by ID");
        ) {
            System.out.println("Records:");
            int count = 0;
            while (rs.next()) {
                int id = rs.getInt(1);
                String SKU = rs.getString(2);
                int quantity = rs.getInt(3);
                double price = rs.getDouble(4);
                String status = rs.getString(5);
                int pending = rs.getInt(6);

                if (pending > 0 || status.equalsIgnoreCase("cancelled")) {
                    System.err.printf("Order ID: %d \t SKU: %s \t\t Quantity: %s \t Price: $%8.2f  \t\t Status: %s \t\t Pending Inventory: %d\n",
                            id, SKU, quantity, price, status, pending);
                } else {
                    System.out.printf("Order ID: %d \t SKU: %s \t\t Quantity: %s \t Price: $%8.2f  \t\t Status: %s \t\t Pending Inventory: %d\n",
                            id, SKU, quantity, price, status, pending);
                }

//                System.out.printf("Order ID: %d \t SKU: %s \t\t Quantity: %s \t Price: $%8.2f  \t\t Status: %s \t\t Pending Inventory: %d\n",
//                        id, SKU, quantity, price, status, pending);
                count++;
            }
            System.out.println();
            return count;
        }
    }

}
