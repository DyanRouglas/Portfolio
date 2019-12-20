import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.sql.*;
import java.util.Properties;

/**
 * InsertProductData.java
 *
 * @author Vishal Annamaneni
 * @author Ryan Douglas
 * @since 2019-06-15
 */

public class InsertProductData {
    public static void main(String[] args) {
        // the default framework is embedded
        String protocol = "jdbc:derby:";
        String dbName = "OrderManager";
        String connStr = protocol + dbName+ ";create=true";

        // input FileNmae
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
                Connection  conn = DriverManager.getConnection(connStr, props);
                Statement stmt = conn.createStatement();

                // insert prepared statements
                PreparedStatement insertRow_Product = conn.prepareStatement(
                        "insert into Product values(?, ?, ?)");
                PreparedStatement insertRow_Inventory_Record = conn.prepareStatement(
                        "insert into Inventory_Record values(?, ?, parsePrice(?))");
        ) {
            System.out.printf("\n********************************* Inserting Product Data *********************************\n\n");

            // connected to the database using URL
            System.out.println("Connected to database " + dbName);
            System.out.println();

            String line;
            while ((line = br.readLine()) != null) {
                // split input line into fields at tab delimiter
                String[] data = line.split("\t");
                if (data.length != 5) continue;

                // get fields from input data
                String SKU = data[0];
                String productName = data[1];
                String productDescription = data[2];

                // add Product if does not exist
                try {
                    insertRow_Product.setString(1, SKU);
                    insertRow_Product.setString(2, productName);
                    insertRow_Product.setString(3, productDescription);
                    insertRow_Product.execute();
                } catch (SQLException | NumberFormatException ex) {
                    // already exists
                    // System.err.printf("Already inserted Publisher %s City %s\n", publisherName, publisherCity);
                    System.err.printf("Failed to insert Product: %s. Malformed SKU: %s\n\n", productName, SKU);
                    continue;
                }

                // get fields from input data
                String quantity = data[3];
                String price = data[4];

                // add Inventory Record if does not exist
                try {
                    insertRow_Inventory_Record.setString(1, SKU);
                    insertRow_Inventory_Record.setString(2, quantity);
                    insertRow_Inventory_Record.setString(3, price);
                    insertRow_Inventory_Record.execute();
                } catch (SQLException ex) {
//                    ex.printStackTrace();
                    System.err.printf("Failed to insert Product: %s. Invalid Price: %s\n", productName, price);

                    // delete the corresponding entry from the Product table
                    System.err.printf("Deleting the corresponding entry from the Product table for SKU: %s\n\n", SKU);
                    String query = String.format("delete from Product where SKU = '%s'", SKU);
                    stmt.executeUpdate(query);
                }
            }

            System.out.println();
            PrintUtilities.printProducts(conn);
            PrintUtilities.printInventory(conn);

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
