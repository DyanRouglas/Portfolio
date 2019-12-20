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

public class InsertCustomerData {
    public static void main(String[] args) {
        // the default framework is embedded
        String protocol = "jdbc:derby:";
        String dbName = "OrderManager";
        String connStr = protocol + dbName+ ";create=true";

        // tables created by this program
        String dbTables[] = {
                "Customer"
        };

        // get the data file
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

                // insert prepared statements for customer
                PreparedStatement insertRow_Customer = conn.prepareStatement(
                        "insert into Customer (First_Name, Last_Name, Address, City, State, Country, Postal_Code) "
                                + "values(?, ?, ?, ?, ?, ?, ?)");
        ) {
            System.out.printf("\n\n********************************* Inserting Customer Data *********************************\n\n");

            // connected to the database using URL
            System.out.println("Connected to database " + dbName);

            String line;
            while ((line = br.readLine()) != null) {
                // split input line into fields at tab delimiter
                String[] data = line.split("\t");
                if (data.length != 7) continue;

                // get the customer data fields
                String Customer_First_Name = data[0];
                String Customer_Last_Name = data[1];
                String Address = data[2];
                String City = data[3];
                String State = data[4];
                String Country = data[5];
                String Code = data[6];

                // add Customer if does not exist and state code is valid
                try {
                    insertRow_Customer.setString(1, Customer_First_Name);
                    insertRow_Customer.setString(2, Customer_Last_Name);
                    insertRow_Customer.setString(3, Address);
                    insertRow_Customer.setString(4, City);
                    insertRow_Customer.setString(5, State);
                    insertRow_Customer.setString(6, Country);
                    insertRow_Customer.setString(7, Code);
                    insertRow_Customer.execute();

                } catch (SQLException ex) {
                    System.err.printf("\n%s is not a recognized postal code for any U.S. state or territory. Customer Entry not created.\n", State);
                }
            }

            System.out.println();

            PrintUtilities.printCustomers(conn);

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
