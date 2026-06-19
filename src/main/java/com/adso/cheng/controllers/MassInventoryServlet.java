package com.adso.cheng.controllers;

import com.adso.cheng.models.User;
import com.adso.cheng.utils.DbConnection;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@WebServlet("/MassInventoryServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
    maxFileSize = 1024 * 1024 * 10,      // 10 MB
    maxRequestSize = 1024 * 1024 * 15    // 15 MB
)
public class MassInventoryServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        Gson gson = new Gson();
        Map<String, Object> jsonResponse = new HashMap<>();

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 3)) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "No autorizado.");
            response.getWriter().write(gson.toJson(jsonResponse));
            return;
        }

        Part filePart = request.getPart("csvFile");
        if (filePart == null || filePart.getSize() == 0) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "No se encontró ningún archivo CSV.");
            response.getWriter().write(gson.toJson(jsonResponse));
            return;
        }

        int successCount = 0;
        int errorCount = 0;

        String sql = "INSERT INTO products (name, brand, description, price, stock, estante, fila, minimo_programado, barcode) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (InputStream fileContent = filePart.getInputStream();
             BufferedReader reader = new BufferedReader(new InputStreamReader(fileContent, "UTF-8"));
             Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            String line;
            boolean isFirstLine = true;
            
            while ((line = reader.readLine()) != null) {
                // Saltar línea en blanco o metadata de Excel
                if (line.trim().isEmpty() || line.toLowerCase().startsWith("sep=")) continue;
                
                // Manejar separadores (coma o punto y coma)
                String separator = line.contains(";") ? ";" : ",";
                
                // Regex para separar respetando comillas
                String regex = separator + "(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)";
                String[] columns = line.split(regex, -1);
                
                // Limpiar comillas de las columnas
                for (int i = 0; i < columns.length; i++) {
                    columns[i] = columns[i].trim();
                    if (columns[i].startsWith("\"") && columns[i].endsWith("\"") && columns[i].length() >= 2) {
                        columns[i] = columns[i].substring(1, columns[i].length() - 1);
                    }
                }

                // Saltar cabecera si parece serlo (ej. la primera línea no tiene precio numérico)
                if (isFirstLine) {
                    isFirstLine = false;
                    try {
                        if (columns.length > 3) Double.parseDouble(columns[3]);
                    } catch (Exception e) {
                        continue; // Es cabecera
                    }
                }

                if (columns.length < 5) { // Mínimo requerido: Nombre, Marca, Desc, Precio, Stock
                    errorCount++;
                    continue;
                }

                try {
                    String name = columns[0];
                    String brand = columns[1];
                    String description = columns[2];
                    double price = Double.parseDouble(columns[3].replace(",", ".")); // Manejar comas en decimales
                    int stock = Integer.parseInt(columns[4]);
                    
                    String estante = (columns.length > 5 && !columns[5].isEmpty()) ? columns[5] : null;
                    String fila = (columns.length > 6 && !columns[6].isEmpty()) ? columns[6] : null;
                    int minimo = (columns.length > 7 && !columns[7].isEmpty()) ? Integer.parseInt(columns[7]) : 5;
                    
                    String barcode = (columns.length > 8 && !columns[8].isEmpty()) ? columns[8] : generateUniqueBarcode();

                    if (name.isEmpty() || brand.isEmpty()) throw new IllegalArgumentException("Campos requeridos vacíos");

                    stmt.setString(1, name);
                    stmt.setString(2, brand);
                    stmt.setString(3, description.isEmpty() ? null : description);
                    stmt.setDouble(4, price);
                    stmt.setInt(5, stock);
                    stmt.setString(6, estante);
                    stmt.setString(7, fila);
                    stmt.setInt(8, minimo);
                    stmt.setString(9, barcode);

                    stmt.executeUpdate();
                    successCount++;
                } catch (Exception ex) {
                    System.out.println("Error procesando línea: " + line + " -> " + ex.getMessage());
                    errorCount++;
                }
            }
            
            jsonResponse.put("success", true);
            jsonResponse.put("message", "Carga finalizada. Exitosos: " + successCount + ". Errores: " + errorCount);
            
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error procesando el archivo: " + e.getMessage());
        }

        response.getWriter().write(gson.toJson(jsonResponse));
    }

    private String generateUniqueBarcode() {
        return "PRD" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}
