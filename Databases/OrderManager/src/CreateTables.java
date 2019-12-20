import java.sql.*;
import java.util.Properties;

/**
 * CreateTables.java
 *
 * @author Vishal Annamaneni
 * @author Ryan Douglas
 * @since 2019-06-14
 */

public class CreateTables {

    public static void main(String[] args) {
        String protocol = "jdbc:derby:";
        String dbName = "OrderManager";
        String connStr = protocol + dbName+ ";create=true";
        String user = "user1";
        String password = "user1";

        // tables created by this program
        String dbTables[] = {
                "Order_Record", "Inventory_Record", "Product",
                "Orders", "Customer"
        };

        // stored functions created by this program
        String storedFunctions[] = {
                "isSKU", "parsePrice", "isState"
        };

        // procedures created by this program
        String storedProcedures[] = {
                "quantityCheck", "checkPending", "cancelOrder"
        };

        // triggers created by this program
        String dbTriggers[] = {
                "InsertOrderRecord", "updateInventory", "cancelOrder"
        };

        Properties props = new Properties(); // connection properties
        // providing a user name and password is optional in the embedded
        // and derbyclient frameworks
        props.put("user", user);
        props.put("password", password);

        try (
                // connect to the database using URL
                Connection conn = DriverManager.getConnection(connStr, props);

                // statement is channel for sending commands thru connection
                Statement stmt = conn.createStatement();
        ){
            System.out.printf("\n\n********************************* Dropping and Creating Tables *********************************\n\n");

            System.out.println("Connected to and created database " + dbName);
            System.out.println();

            // drop the database triggers and recreate them below
            for (String tgr : dbTriggers) {
                try {
                    stmt.executeUpdate("drop trigger " + tgr);
                    System.out.println("Dropped trigger " + tgr);
                } catch (SQLException ex) {
                    System.out.println("Did not drop trigger " + tgr);
                }
            }
            System.out.println();

            // drop the database tables and recreate them below
            for (String tbl : dbTables) {
                try {
                    stmt.executeUpdate("drop table " + tbl);
                    System.out.println("Dropped table " + tbl);
                } catch (SQLException ex) {
                    System.out.println("Did not drop table " + tbl);
                }
            }
            System.out.println();

            // drop the storedFunctions and recreate them below
            for (String func : storedFunctions) {
                try {
                    stmt.executeUpdate("drop function " + func);
                    System.out.println("Dropped function " + func);
                } catch (SQLException ex) {
                    System.out.println("Did not drop function " + func);
                }
            }
            System.out.println();

            // drop the storedProcedures and recreate them below
            for (String proc : storedProcedures) {
                try {
                    stmt.executeUpdate("drop procedure " + proc);
                    System.out.println("Dropped procedure " + proc);
                } catch (SQLException ex) {
                    System.out.println("Did not drop procedure " + proc);
                }
            }
            System.out.println();

            // create the isSKU stored function
            String createFunction_isSKU =
                    "CREATE FUNCTION isSKU("
                            + " 	SKU VARCHAR(16)"
                            + "	)  RETURNS boolean"
                            + " PARAMETER STYLE JAVA"
                            + " LANGUAGE JAVA"
                            + " DETERMINISTIC"
                            + " NO SQL"
                            + " EXTERNAL NAME"
                            + "		'StoredFunctions.isSKU'";
            stmt.executeUpdate(createFunction_isSKU);
            System.out.println("Created stored function isSKU");

            // create the parsePrice stored function
            String createFunction_parsePrice =
                    "CREATE FUNCTION parsePrice("
                            + " 	price VARCHAR(16)"
                            + "	)  RETURNS float"
                            + " PARAMETER STYLE JAVA"
                            + " LANGUAGE JAVA"
                            + " DETERMINISTIC"
                            + " NO SQL"
                            + " EXTERNAL NAME"
                            + "		'StoredFunctions.parsePrice'";
            stmt.executeUpdate(createFunction_parsePrice);
            System.out.println("Created stored function parsePrice");

            // create the isState stored function
            String createFunction_isState =
                    "CREATE FUNCTION isState("
                            + " 	SKU VARCHAR(2)"
                            + "	)  RETURNS boolean"
                            + " PARAMETER STYLE JAVA"
                            + " LANGUAGE JAVA"
                            + " DETERMINISTIC"
                            + " NO SQL"
                            + " EXTERNAL NAME"
                            + "		'StoredFunctions.isState'";
            stmt.executeUpdate(createFunction_isState);
            System.out.println("Created stored function isState");
            System.out.println();

            // create the quantityCheck stored procedure
            String createProcedure_quantityCheck =
                    "CREATE PROCEDURE quantityCheck("
                            + "     IN orderID int,"
                            + "     IN SKU varchar(12),"
                            + "     IN quantity int"
                            + "	) "
                            + " PARAMETER STYLE JAVA"
                            + " LANGUAGE JAVA"
                            + " DETERMINISTIC"
                            + " MODIFIES SQL DATA"
                            + " EXTERNAL NAME"
                            + "		'StoredFunctions.quantityCheck'";
            stmt.executeUpdate(createProcedure_quantityCheck);
            System.out.println("Created stored procedure quantityCheck");

            // create the checkPending stored procedure
            String createProcedure_checkPending =
                    "CREATE PROCEDURE checkPending("
                            + "     IN SKU varchar(12),"
                            + "     IN quantity int,"
                            + "     IN price float"
                            + "	) "
                            + " PARAMETER STYLE JAVA"
                            + " LANGUAGE JAVA"
                            + " DETERMINISTIC"
                            + " MODIFIES SQL DATA"
                            + " EXTERNAL NAME"
                            + "		'StoredFunctions.checkPending'";
            stmt.executeUpdate(createProcedure_checkPending);
            System.out.println("Created stored procedure checkPending");

            // create the cancelOrder stored procedure
            String createProcedure_cancelOrder =
                    "CREATE PROCEDURE cancelOrder("
                            + "     IN orderID int,"
                            + "     IN status varchar(16)"
                            + "	) "
                            + " PARAMETER STYLE JAVA"
                            + " LANGUAGE JAVA"
                            + " DETERMINISTIC"
                            + " MODIFIES SQL DATA"
                            + " EXTERNAL NAME"
                            + "		'StoredFunctions.cancelOrder'";
            stmt.executeUpdate(createProcedure_cancelOrder);
            System.out.println("Created stored procedure cancelOrder");
            System.out.println();

            // create the Product table
            String createTable_Product =
                    "create table Product ("
                            + "  SKU varchar(12) not null,"
                            + "  Name varchar(32) not null,"
                            + "  Description varchar(64) not null,"
                            + "  primary key (SKU),"
                            + "  check (isSKU(SKU))"
                            + ")";
            stmt.executeUpdate(createTable_Product);
            System.out.println("Created entity table Product");

            // create the Inventory_Record table
            String createTable_Inventory_Record =
                    "create table Inventory_Record ("
                            + "  SKU varchar(12) not null,"
                            + "  Quantity int not null check (Quantity >= 0),"
                            + "  Price float not null check (Price > 0),"
                            + "  primary key (SKU),"
                            + "  foreign key (SKU) references Product(SKU),"
                            + "  check (isSKU(SKU))"
                            + ")";
            stmt.executeUpdate(createTable_Inventory_Record);
            System.out.println("Created entity table Inventory_Record");

            // create the Customer table
            String createTable_Customer =
                    "create table Customer ("
                            + "  ID int not null GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),"
                            + "  First_Name varchar(16) not null,"
                            + "  Last_Name varchar(16) not null,"
                            + "  Address varchar(32) not null,"
                            + "  City varchar(16) not null,"
                            + "  State varchar(2) not null check (isState(State)),"
                            + "  Country varchar(16) not null,"
                            + "  Postal_Code varchar(16) not null,"
                            + "  primary key (ID)"
                            + ")";
            stmt.executeUpdate(createTable_Customer);
            System.out.println("Created entity table Customer");

            // create the Orders table
            String createTable_Orders =
                    "create table Orders ("
                            + "  ID int not null GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),"
                            + "  Customer_ID int not null,"
                            + "  Order_Date date not null,"
                            + "  Shipment_Date date,"
                            + "  Order_Status varchar(16) check (Order_Status in ('Placed', 'Shipped', 'Pending', 'Cancelled')),"
                            + "  primary key (ID),"
                            + "  foreign key (Customer_ID) references Customer(ID)"
                            + ")";
            stmt.executeUpdate(createTable_Orders);
            System.out.println("Created entity table Orders");

            // create the Orders table
            String createTable_Order_Record =
                    "create table Order_Record ("
                            + "  ID int check (ID > 0),"
                            + "  SKU varchar(12),"
                            + "  Quantity int check (Quantity > 0),"
                            + "  Price float check (Price > 0),"
                            + "  Status varchar(16) check (Status in ('Available', 'Pending', 'Cancelled')),"
                            + "  Pending_Inventory int check (Pending_Inventory >= 0),"
                            + "  primary key (ID, SKU),"
                            + "  foreign key (ID) references Orders(ID) on delete cascade,"
                            + "  foreign key (SKU) references Product(SKU)"
                            + ")";
            stmt.executeUpdate(createTable_Order_Record);
            System.out.println("Created entity table Order_Record");
            System.out.println();

            // create trigger for reducing inventory count of a product
            // when a new order record for that product is inserted
            String createTrigger_InsertOrderRecord =
                    "create trigger InsertOrderRecord"
                            + "  after insert on Order_Record"
                            + "  referencing new as newRecord"
                            + "  for each row MODE DB2SQL"
                            + "     call quantityCheck(newRecord.ID, newRecord.SKU, newRecord.Quantity)";

            stmt.executeUpdate(createTrigger_InsertOrderRecord);
            System.out.println("Created trigger for InsertOrderRecord");

            // create trigger for increasing inventory count of a product
            // when an existing order is cancelled
            String createTrigger_cancelOrder =
                    "create trigger cancelOrder"
                            + "  after update on Orders"
                            + "  referencing new as newRecord"
                            + "  for each row MODE DB2SQL"
                            + "     call cancelOrder(newRecord.ID, newRecord.Order_Status)";

            stmt.executeUpdate(createTrigger_cancelOrder);
            System.out.println("Created trigger for cancelOrder");

            // create trigger for updating inventory count of a product
            // whenever there is an inventory update
            String createTrigger_updateInventory =
                    "create trigger updateInventory"
                            + "  after update on Inventory_Record "
                            + "  referencing new as newRecord"
                            + "  for each row MODE DB2SQL"
                            + "     call checkPending(newRecord.SKU, newRecord.Quantity, newRecord.Price)   ";

            stmt.executeUpdate(createTrigger_updateInventory);
            System.out.println("Created trigger for updateInventory");


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
