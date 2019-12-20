import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.sql.*;
import java.util.Properties;

/**
 * UpdateInventory.java
 *
 * @author Vishal Annamaneni
 * @author Ryan Douglas
 * @since 2019-06-22
 */

public class UpdateInventory {

    public static void main(String[] args) {
        // the default framework is embedded
        String protocol = "jdbc:derby:";
        String dbName = "OrderManager";
        String connStr = protocol + dbName+ ";create=true";

        // tables created by this program
        String dbTables[] = {
                "Inventory_Record"
        };

        // input FileNmae
        String fileName = args[0];

        Properties props = new Properties(); // connection properties
        // providing a user name and password is optional in the embedded
        // and derbyclient frameworks
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

                // insert prepared statements
                PreparedStatement updateRow_Inventory_Record_Quantity = conn.prepareStatement(
                        "update Inventory_Record set Quantity = ? where SKU = ?");
                PreparedStatement updateRow_Inventory_Record_Price = conn.prepareStatement(
                        "update Inventory_Record set Quantity = ?, Price = ? where SKU = ?");

        ) {
            System.out.printf("\n********************************* Updating Inventory *********************************\n\n");

            // connected to the database using URL
            System.out.println("Connected to database " + dbName);

            String line;

            while ((line = br.readLine()) != null) {
                // split input line into fields at tab delimiter
                String[] data = line.split("\t");
//                if (data.length != 3) continue;

                // get fields from input data
                String SKU = data[0];
                int quantity = Integer.parseInt(data[1]);

                String query = String.format("select quantity, price from Inventory_record where SKU = '%s'", SKU);
                rs = stmt.executeQuery(query);

                if (rs.next()) {
                    int oldCount = rs.getInt(1);
                    quantity += oldCount;

                    double oldPrice = rs.getDouble(2);
                    try {
                        if (data.length == 3) {
                            double price = Double.parseDouble(data[2]);
                            double finalPrice = (price > oldPrice ? price : oldPrice);

                            updateRow_Inventory_Record_Price.setInt(1, quantity);
                            updateRow_Inventory_Record_Price.setDouble(2, finalPrice);
                            updateRow_Inventory_Record_Price.setString(3, SKU);
                            updateRow_Inventory_Record_Price.executeUpdate();

                        } else if (data.length == 2) {
                            updateRow_Inventory_Record_Quantity.setInt(1, quantity);
                            updateRow_Inventory_Record_Quantity.setString(2, SKU);
                            updateRow_Inventory_Record_Quantity.executeUpdate();
                        }
                    } catch (SQLException ex) {
                        // already exists
                        ex.printStackTrace();
                    }
                }
            }

            // Printing the relevant tables at the end
            PrintUtilities.printInventory(conn);
            PrintUtilities.printOrders(conn);
            PrintUtilities.printRecords(conn);

            rs.close();

        } catch (IOException e) {
            e.printStackTrace();
        } catch (SQLException e) {
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
