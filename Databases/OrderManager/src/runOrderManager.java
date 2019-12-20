/**
 * runOrderManager.java
 *
 * @author Vishal Annamaneni
 * @author Ryan Douglas
 * @since 2019-06-23
 */

public class runOrderManager {

    public static void main(String[] args) {

        // drop and create tables, functions, procedures and triggers using by calling create tables
        CreateTables.main(null);

        // insert Customer Data from a tab separated text file
        String[] customerData = {"TestData_OrderManager/customerData.txt"};
        InsertCustomerData.main(customerData);

        // insert Product Data from a tab separated text file
        String[] productData = {"TestData_OrderManager/productData.txt"};
        InsertProductData.main(productData);

        // insert Order Data from a tab separated text file
        String[] orderData = {"TestData_OrderManager/orderData.txt"};
        InsertOrderData.main(orderData);

        /* For Demo and Testing purposes */
        // testing the cancel trigger by cancelling Order 4
        TestCancelAndDelete.CancelOrder();

        // updating Inventory Data from a tab separated text file
        String[] updateInventoryData = {"TestData_OrderManager/updateInventory.txt"};
        UpdateInventory.main(updateInventoryData);

        /* For Demo and Testing purposes */
        // testing the delete after cascade constraint on Order_Record Table by deleting Order 4
        TestCancelAndDelete.DeleteOrder();
    }
}
