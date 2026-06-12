package com.adso.cheng.utils;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class AuditLogger {

    /**
     * Registra una acción en el historial de operaciones del personal.
     * 
     * @param userId  ID del usuario que realiza la acción
     * @param module  Módulo donde ocurre (ej. VENTAS, INVENTARIO, PERSONAL, MANTENIMIENTO)
     * @param action  Acción corta (ej. "Venta Procesada")
     * @param details Descripción detallada de lo que hizo
     */
    public static void logAction(int userId, String module, String action, String details) {
        String sql = "INSERT INTO audit_logs (user_id, module, action, details) VALUES (?, ?, ?, ?)";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setString(2, module);
            stmt.setString(3, action);
            stmt.setString(4, details);
            stmt.executeUpdate();
        } catch (Exception e) {
            System.err.println("Error al registrar auditoría: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
