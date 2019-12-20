
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Properties;

/**
 * InsertOrderData.java
 *
 * @author Vishal Annamaneni
 * @author Ryan Douglas
 * @since 2019-06-15
 */

public class InsertOrderData {

    public static void main(String[] args) {
        // the default framework is embedded
        String protocol = "jdbc:derby:";
        String dbName = "OrderManager";
        String connStr = protocol + dbName+ ";create=true";

        // Input File Name
        String fileName = args[0];

        Properties props = new Properties(); // connection properties
        props.put("user", "user1");
        props.put("password", "user1");

        // result set for queries
        ResultSet rs = null;
        try (
                // open data file
                BufferedReader br = new BufferedReader(new FileReader(new File(fileName)));

                // connect to database
                Connection conn = DriverManager.getConnection(connStr, props);
                Statement stmt = conn.createStatement();

                // insert prepared statements for Order and Order Record
                PreparedStatement insertRow_Orders = conn.prepareStatement(
                        "insert into Orders (Customer_ID, Order_Date, Shipment_Date, Order_Status) " +
                                "values(?, ?, ?, ?)", Statement.RETURN_GENERATED_KEYS);
                PreparedStatement insertRow_Order_Record = conn.prepareStatement(
                        "insert into Order_Record (ID, SKU, Quantity, Price, Status, Pending_Inventory) values(?, ?, ?, ?, ?, ?)")
        ) {

            System.out.printf("\n********************************* Inserting Order Data *********************************\n\n");

            // connected to the database using URL
            System.out.println("Connected to database " + dbName);

            String line;
            while ((line = br.readLine()) != null) {
                // split input line into fields at tab delimiter
                String[] data = line.split("\t");

                // get fields from input data
                String customerid = data[0];
                // set initial order status to placed
                String order_status = "Placed";

                // get the current date to set the order date
                DateTimeFormatter dtf = DateTimeFormatter.ofPattern("MM/dd/yyyy");
                LocalDate lDNow = LocalDate.now();
                String currentdate = dtf.format(lDNow);

                // add Orders if does not exist
                try {
                    insertRow_Orders.setString(1, customerid);
                    insertRow_Orders.setString(2, currentdate);
                    insertRow_Orders.setString(3, currentdate);
                    insertRow_Orders.setString(4, order_status);

                    insertRow_Orders.executeUpdate();

                } catch (SQLException ex) {
                    // already exists
                    System.out.printf("\nUnable to process order for customer ID: %s. Error Message: %s\n\n",
                            customerid, ex.getMessage());
                    continue;
                }

                int count = 1;

                // get the orderID (auto-generated) for the above order
                rs = insertRow_Orders.getGeneratedKeys();
                if (rs.next()){

                    // add Order Records for this Order
                    int orderID = rs.getInt(1);
                    String SKU = null;
                    int quantity = 0;

                    while (count < data.length - 1) {

                        // get the order record data fields
                        SKU = data[count++];
                        quantity = Integer.parseInt(data[count++]);

                        try {

                            insertRow_Order_Record.setInt(1, orderID);
                            insertRow_Order_Record.setString(2, SKU);
                            insertRow_Order_Record.setInt(3, quantity);

                            // get the price of the product in the order record
                            String query = String.format("select Price from Inventory_record where SKU = '%s'", SKU);
                            ResultSet priceSet = stmt.executeQuery(query);
                            double price = 0;
                            if (priceSet.next()) {
                                price = priceSet.getDouble(1);
                                insertRow_Order_Record.setDouble(4, price*quantity);
                            }

                            // set the initial status to available
                            insertRow_Order_Record.setString(5, "Available");
                            insertRow_Order_Record.setInt(6, 0);

                            insertRow_Order_Record.executeUpdate();
                        } catch (SQLException ex) {
                            System.err.printf("\nUnable to process order record for Order ID: %s  SKU: %s\n",
                                    orderID, SKU);
                            // delete the corresponding entry from the Order table
                            System.err.printf("Deleting the corresponding entry from the Orders table for Order ID: %s\n\n", orderID);
                            String query = String.format("delete from Orders where ID = %d", orderID);
                            stmt.executeUpdate(query);
                            continue;
                        }
                    }
                }
            }

            // Printing the relevant tables at the end
            PrintUtilities.printOrders(conn);
            PrintUtilities.printRecords(conn);
            PrintUtilities.printInventory(conn);

            rs.close();

        } catch (IOException | SQLException e) {
            e.printStackTrace();
        }

        // shutdown the database before closing
        try {
            DriverManager.getConnection(protocol + dbName + ";shutdown=true");
        } catch (SQLException e) {
            // shutting down
        }
    }
}
