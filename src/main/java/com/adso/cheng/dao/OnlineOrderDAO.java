package com.adso.cheng.dao;

import com.adso.cheng.models.OnlineOrder;
import com.adso.cheng.utils.DbConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class OnlineOrderDAO {

    public List<OnlineOrder> getAllOrders() {
        List<OnlineOrder> orders = new ArrayList<>();
        String sql = "SELECT o.*, COALESCE(u.full_name, 'Cliente Desconocido') as customer_name " +
                     "FROM online_orders o " +
                     "LEFT JOIN users u ON o.customer_id = u.id " +
                     "ORDER BY o.id DESC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                orders.add(mapResultSetToOrder(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }

    public List<OnlineOrder> getUnreadOrdersByRole(int roleId) {
        List<OnlineOrder> orders = new ArrayList<>();
        String column;
        if (roleId == 1) {
            column = "is_read_admin";
        } else if (roleId == 3) {
            column = "is_read_storekeeper";
        } else {
            column = "is_read_cashier";
        }
        String sql = "SELECT o.*, COALESCE(u.full_name, 'Cliente Desconocido') as customer_name " +
                     "FROM online_orders o " +
                     "LEFT JOIN users u ON o.customer_id = u.id " +
                     "WHERE o." + column + " = FALSE AND o.status = 'COMPLETADO' " +
                     "ORDER BY o.created_at DESC";
                     
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                orders.add(mapResultSetToOrder(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }

    public void markAsRead(int orderId, int roleId) {
        String column;
        if (roleId == 1) {
            column = "is_read_admin";
        } else if (roleId == 3) {
            column = "is_read_storekeeper";
        } else {
            column = "is_read_cashier";
        }
        String sql = "UPDATE online_orders SET " + column + " = TRUE WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, orderId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    public void markAllAsRead(int roleId) {
        String column;
        if (roleId == 1) {
            column = "is_read_admin";
        } else if (roleId == 3) {
            column = "is_read_storekeeper";
        } else {
            column = "is_read_cashier";
        }
        String sql = "UPDATE online_orders SET " + column + " = TRUE WHERE " + column + " = FALSE";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void updateStatus(int orderId, String status) {
        String sql = "UPDATE online_orders SET status = ? WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, orderId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void markAsCompletedAndNotify(int orderId) {
        String sql = "UPDATE online_orders SET status = 'COMPLETADO', is_read_admin = FALSE, is_read_cashier = FALSE WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, orderId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private OnlineOrder mapResultSetToOrder(ResultSet rs) throws SQLException {
        OnlineOrder order = new OnlineOrder();
        order.setId(rs.getInt("id"));
        order.setCustomerId(rs.getInt("customer_id"));
        order.setCustomerName(rs.getString("customer_name"));
        order.setTotalAmount(rs.getDouble("total_amount"));
        order.setShippingCost(rs.getDouble("shipping_cost"));
        order.setItemsJson(rs.getString("items_json"));
        order.setStatus(rs.getString("status"));
        order.setReadAdmin(rs.getBoolean("is_read_admin"));
        order.setReadCashier(rs.getBoolean("is_read_cashier"));
        order.setReadStorekeeper(rs.getBoolean("is_read_storekeeper"));
        order.setCreatedAt(rs.getTimestamp("created_at"));
        return order;
    }
}
