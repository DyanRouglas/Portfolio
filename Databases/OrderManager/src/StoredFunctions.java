import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;

/**
 * StoredFunctions.java
 *
 * @author Vishal Annamaneni
 * @author Ryan Douglas
 * @since 2019-06-15
 */

public class StoredFunctions {

    static String[] states = {"AL","AK","AS","AZ","AR","CA","CO","CT","DE","DC","FM","FL","GA","GU","HI","ID","IL","IN","IA",
            "KS","KY","LA","ME","MH","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","MP",
            "OH","OK","OR","PW","PA","PR","RI","SC","SD","TN","TX","UT","VT","VI","VA","WA","WV","WI","WY", "AS", "GU",
            "MH", "FM", "MP", "PW", "PR", "VI"};


    /**
     * Checks if state code matches any of 50 states or DC
     * @param state the state code
     * @return true if is state code
     */
    public static boolean isState(String state) {
        return Arrays.asList(states).contains(state);
    }

    /**
     * This function checks if a given string is in the SKU format
     *
     * @param SKU String representation of the SKU to check
     * @return true if valid, false otherwise
     * @throws NumberFormatException if the string is not a valid SKU
     */
    public static boolean isSKU (String SKU) {
        if (!SKU.matches("([A-Z]{2})-(\\d{6})-([\\dA-Z]{2})$")) {
            throw new NumberFormatException("Malformed SKU");
        }

        return true;
    }

    /**
     * This function returns a new double which is formatted to be a
     * positive number with 2 digits after the decimal place
     *
     * @param price String representation of the price to check
     * @return positive float with 2 digits after the decimal place
     */
    public static double parsePrice(String price) {
        StringBuilder s = new StringBuilder(price);
        if (s.toString().matches("(\\d*)(\\.)(\\d)$")) {
            s.append("0");
        } else if (s.toString().matches("(\\d+)")){
            s.append(".00");

        } else if (s.toString().matches("(\\.)(\\d{2})$")) {
            s.insert(0, "0");

        } else if (s.toString().matches("(\\.)(\\d)$")) {
            s.insert(0, "0");
            s.append("0");

        } else if (s.toString().matches("(\\d*)(\\.)(\\d){3,}$")) {
            int dotIndex = s.toString().indexOf('.');
            s.delete(dotIndex + 3, s.length());
        }
        return Double.parseDouble(s.toString());
    }

    /**
     * This is a stored procedure which checks and updates the inventory count
     * of a product every time a new order is created
     *
     * @param orderID ID for this order
     * @param SKU SKU id for the product in the order record
     * @param quantity quantity of the product in the order
     */
    public static void quantityCheck(int orderID, String SKU, int quantity) {

        try (
                // connect to the database by getting the default connection
                Connection conn = DriverManager.getConnection("jdbc:default:connection");

                // statement is channel for sending commands thru connection
                Statement stmt = conn.createStatement();
                PreparedStatement pstmt = null;
                Statement stmt2 = conn.createStatement();
        ) {

            // Get the Inventory quantity of product in the Order Record
            String query = String.format("select quantity from Inventory_record where SKU = '%s'", SKU);
            ResultSet rs = stmt.executeQuery(query);

            // if the product SKU record is available
            if (rs.next()) {
                int count = rs.getInt(1);

                // If inventory count greater than or equal to order count
                if (count >= quantity) {

                    count -= quantity;

                    // Decrement the inventory count with the order count
                    query = String.format("update Inventory_record set quantity = %d where SKU = '%s'", count, SKU);
                    stmt.executeUpdate(query);

                // If inventory count less than order count
                } else {

                    // update the status in the Order_Record to pending and update pending count to quantity required
                    query = String.format("update Order_Record set Status = 'Pending', Pending_Inventory = %d "
                                        + "where SKU = '%s' and ID = %d", quantity - count, SKU, orderID);
                    stmt.executeUpdate(query);

                    // Update the status of the Order for this Order Record to pending and null the shipment date
                    query = String.format("update Orders set Order_Status = 'Pending', Shipment_Date = null where ID = %d", orderID);
                    stmt.executeUpdate(query);

                    // Decrement the inventory count to 0
                    query = String.format("update Inventory_Record set Quantity = %d where SKU = '%s'", 0, SKU);
                    stmt.executeUpdate(query);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

    }

    /**
     * This is a stored procedure which checks and updates any pending orders by
     * updating the order records and orders every time the inventory is updated.
     *
     * @param SKU SKU id for the product in the order record
     * @param quantity quantity of the product int the order
     * @param price price of the product
     */
    public static void checkPending(String SKU, int quantity, double price) {
        try (
                // connect to the database by getting the default connection
                Connection conn = DriverManager.getConnection("jdbc:default:connection");

                // statement is channel for sending commands thru connection
                Statement stmt = conn.createStatement();
                Statement stmt2 = conn.createStatement();
                Statement stmt3 = conn.createStatement();
        ) {

            // Get all the Order Records containing this particular SKU
            String query = String.format("select * from Order_Record where SKU = '%s' and Status = 'Pending'", SKU);
            ResultSet rs = stmt.executeQuery(query);

            int count = quantity;
            int counter = 0;

            // while the inventory count is positive and there are further records to process
            while (rs.next() && count > 0) {

                counter++;

                // get the orderID and pending count
                int orderID = rs.getInt(1);
                int pending = rs.getInt(6);

                // If pending inventory less than or equal to inventory count
                if (pending <= count) {

                    // update status of the order record to available and pending inventory count to zero
                    query = String.format("update Order_Record set Status = 'Available', Pending_Inventory = %d "
                                        + "where ID = %d and SKU = '%s'", 0, orderID, SKU);
                    stmt2.executeUpdate(query);
                    count -= pending;

                    // select all the order record pertaining to the same order as the above record with pending status
                    query = String.format("select * from Order_Record where ID = %d and Status = 'Pending'", orderID);
                    ResultSet newSet =  stmt2.executeQuery(query);

                    // if no other pending records for this order
                    if (!newSet.next()) {

                        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("MM/dd/yyyy");
                        LocalDate lDNow = LocalDate.now();
                        String currentdate = dtf.format(lDNow);

                        // update the status of the order to placed and update the shipment date to current date
                        query = String.format("update Orders set Order_Status = 'Placed', Shipment_Date = '%s' where ID = %d", currentdate, orderID);
                        stmt2.executeUpdate(query);
                    }

                // If pending inventory greater than inventory count
                } else if (pending > count) {

                    // decrement the pending count by the inventory count
                    query = String.format("update Order_Record set Pending = %d "
                                        + "where ID = %d and SKU = '%s'", pending - count, orderID, SKU);
                    stmt2.executeQuery(query);
                    count = 0;
                }
            }

            // check to avoid infinite trigger calls when this procedure updates the inventory table
            if (counter > 0) {
                // update the inventory count with the remaining available count
                query = String.format("update Inventory_record set quantity = %d where SKU = '%s'", count, SKU);
                stmt.executeUpdate(query);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

    }

    /**
     * This is a stored procedure that is called after any update on the Orders table. If
     * a pending order status is changed to cancelled, this procedure cancels the individual
     * order records and adds back the items in the order back to the inventory
     *
     * @param orderID Order ID of the updated row
     * @param status Status of the update row
     */
    public static void cancelOrder(int orderID, String status) {
        try (
                // connect to the database by getting the default connection
                Connection conn = DriverManager.getConnection("jdbc:default:connection");

                // statement is channel for sending commands thru connection
                Statement stmt = conn.createStatement();
                Statement stmt2 = conn.createStatement();
                Statement stmt3 = conn.createStatement();
        ) {

            // Check if the status is changed to cancelled
            if (status.equalsIgnoreCase("cancelled")) {

                // get all the order records for the cancelled order
                String query = String.format("select * from Order_Record where ID = %d", orderID);
                ResultSet rs = stmt.executeQuery(query);

                // while there are order records to process
                while (rs.next()) {

                    String SKU = rs.getString(2);
                    int quantity = rs.getInt(3);
                    int pending = rs.getInt(6);

                    // get the inventory count for the product in the order record
                    query = String.format("select quantity from Inventory_record where SKU = '%s'", SKU);
                    ResultSet rs2 = stmt2.executeQuery(query);

                    if (rs2.next()) {

                        int count = rs2.getInt(1);

                        // update the order record status to cancelled
                        query = String.format("update Order_Record set Status = 'Cancelled' "
                                            + "where ID = %d and SKU = '%s'", orderID, SKU);
                        stmt2.executeUpdate(query);

                        count = count + (quantity - pending);

                        // update the inventory count by incrementing the quantity
                        query = String.format("update Inventory_record set quantity = %d where SKU = '%s'", count, SKU);
                        stmt2.executeUpdate(query);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
