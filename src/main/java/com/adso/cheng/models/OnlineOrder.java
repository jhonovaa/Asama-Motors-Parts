package com.adso.cheng.models;

import java.sql.Timestamp;

public class OnlineOrder {
    private int id;
    private int customerId;
    private String customerName;
    private double totalAmount;
    private double shippingCost;
    private String itemsJson;
    private String status;
    private boolean isReadAdmin;
    private boolean isReadCashier;
    private Timestamp createdAt;

    public OnlineOrder() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public double getShippingCost() { return shippingCost; }
    public void setShippingCost(double shippingCost) { this.shippingCost = shippingCost; }

    public String getItemsJson() { return itemsJson; }
    public void setItemsJson(String itemsJson) { this.itemsJson = itemsJson; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public boolean isReadAdmin() { return isReadAdmin; }
    public void setReadAdmin(boolean readAdmin) { isReadAdmin = readAdmin; }

    public boolean isReadCashier() { return isReadCashier; }
    public void setReadCashier(boolean readCashier) { isReadCashier = readCashier; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
