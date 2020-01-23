# OrderManager: A Database for Managing Products and Orders

This is a RDBMS for managing products, product inventory, and customer information for an online store. The database is built using Apache Dery version 10.15.1.3 and Java version 10.0.2.

The database is made up of 5 tables: Product, Inventory_Record, Customer, Orders and Order_Record. A detailed data model representing the entities and relationships amongst the tables can be found in this folder under the name "OrderManagerER.pdf".

The database uses several Java classes, each providing a type of data language support to the database system.

DATA DEFINITION LANGUAGE (DDL):
------------------------------
The CreateTables java class drops all the tables, stored functions, procedures and triggers and recreates them based on the ER diagram by enforcing several check constraints and foreign key constraints. This class can be run as a seperate unit and it always performs the afore-mentioned operations.

As part of the DDL, the system contains several check constraints, stored functions, stored procedures, and triggers. They are as follows:

Check Constraints:
------------------
**Product**
- Check that SKU is valid

**Inventory_Record**
- Quantity >= 0
- Price is valid

**Customer**
- Ensure address has a recognized postal code for a U.S. state or territory

**Orders**
- Order_status can only be "Placed", "Shipped", "Pending", or "Cancelled"

**Order_Record**
- Status can only be "Available", "Pending", or "Cancelled"; Quantity > 0; Price is valid; Pending_Inventory >= 0

Stored Functions:
-----------------

**isState**
- checks if a given code matches the postal code for any of the 50 states or U.S. territories.

**isSKU**
- checks if a given string matches the SKU format AA-NNNNNN-CC.
- Ex: "AB-123456-0N"

**parsePrice**
- returns a double which is formatted to be a positive number with two digits after the decimal point.

Stored Procedures:
------------------
**quantityCheck**
- checks and updates the inventory count of a product every time a new order is created.

**checkPending**
- checks and updates any pending orders by updating the Orders and Order Records table every time new inventory is added.

**cancelOrder**
- when an order is cancelled the inventory from that order is added back to the Inventory Record table.

Triggers:
---------
**InsertOrderRecord**
- reduces inventory count for a product when a new order record for that product is inserted.
- Triggered after insert on Order Record

**updateInventory**
- updates inventory count for a product whenever there is an inventory update.
- Triggered after insert on Inventory Record

**cancelOrder**
- calls the stored procedure cancelOrder after update on Orders
- Triggered after update on Orders

DATA MANIPULATION LANGUAGE (DML):
---------------------------------
Four java classes perform DML operations on the database:

**InsertCustomerData Class**
- This program takes as input the path to a tab seperated text file containing the customer data. 
- It reads data from the file and inserts it into the Customer table in the database.
- The customer ID is generated automatically in an incrementing sequence.
- This class can be run as a seperate unit and it always performs the afore-mentioned operations.

**InsertProductData Class**
- This program takes as input the path to a tab seperated text file containing the Product and Inventory data. 
- It reads the file line by line and where it validates the SKU and inserts data into the Product table and then the Inventory_Record table
- SKU: a 12-character value of the form AA-NNNNNN-CC where A is an upper-case letter, N is a digit from 0-9, and C is either a digit or an uppper case letter. 
- This class can be run as a seperate unit and it always performs the afore-mentioned operations.

**InsertOrderData Class**
- This program takes as input the path to a tab seperated text file containing the Orders and Order_Record data. 
- It reads the file line by line and creates an Order by automatically generating an Order ID in an incrementing sequence.
- Once an order is created and inserted into the database, the corresponding Order_Record entries are inserted into the table. - An order can have different number of Order Records. To handle this constraint, the input file can contain lines of different length. Each line represents an Order and the assosciated Order Records. 
- This class can be run as a seperate unit and it always performs the afore-mentioned operations.

**UpdateInventory Class**
- This program takes as input the path to a tab seperated text file containing the Inventory resupply data. 
- It reads the file line by line and updates the Inventory_Record for each entry. 
- Price is an optional input. If no price is present, the existing price is used, else the higer of the two prices is used.
- This class can be run as a seperate unit and it always performs the afore-mentioned operations.

DATA QUERY LANGUAGE (DQL):
--------------------------
- The DQL functionality for the database is provided by the QueryOrderManager Java Class. 
- The program has in-built fucntions to  run standard queries on the tables to retrieve either all the rows of the tables or specific rows based on the primary key. 
- To retrieve results of complex queries, the programs provides an option to enter the query manullay. Once entered, the program executes the query and prints the results of the resultant table
- Once the program is run, it shows a list of operations to choose from. 
- After selecting an operation, it prompts the user to input the primary key for the table to query on. Aditionally, there an option to print the entire table is also present.

UTILITY FUNCTIONS
-----------------
- **StoredFunctions Class**
This Java Class contains the Java functions of the stored function in the check constaints mentioned above, and the stored procedures that are called by the triggers mentioned above.

- **PrintUtilities**
This Java Class contains print functions to print the tables in a uniformely formatted manner

TEST RUN:
--------
A test run of the database system with some test data (.txt files for each table included in the TestData_OrderManager sub-directory) can be conducted by running runOrderManager Java Class. This function calls all of the above mentioned programs in a particualr order. This test simulates the creation of tables, insertion of data, placing orders, updating inventory, full-filling pending ordrs, cancelling orders and deleting orders.


