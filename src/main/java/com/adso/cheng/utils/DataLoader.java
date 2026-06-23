package com.adso.cheng.utils;

import java.sql.Connection;
import java.sql.Statement;

public class DataLoader {
    public static void main(String[] args) {
        String sql = "INSERT INTO products (name, description, brand, price, stock, barcode, motorcycle_brand, motorcycle_model, part_category, image_url) VALUES " +
            "('Pastillas de Freno Sinterizadas', 'Alta duración y agarre. Específicas para motos deportivas.', 'Brembo', 85000.00, 20, 'ASAMA-2001', 'Suzuki', 'GSX-R600', 'Frenos', 'https://m.media-amazon.com/images/I/71e-M0-RjAL._AC_SL1500_.jpg')," +
            "('Filtro de Aire Deportivo', 'Filtro de aire de alto flujo lavable.', 'K&N', 120000.00, 15, 'ASAMA-2002', 'Suzuki', 'V-Strom 650', 'Motor', 'https://m.media-amazon.com/images/I/81x-M7G+i1L._AC_SL1500_.jpg')," +
            "('Kit de Arrastre Reforzado', 'Cadena dorada reforzada con piñones en acero.', 'Renthal', 195000.00, 10, 'ASAMA-2003', 'Yamaha', 'MT-09', 'Transmisión', 'https://m.media-amazon.com/images/I/61M-Fw-PzTL._AC_SL1000_.jpg')," +
            "('Amortiguador Trasero Gas', 'Amortiguador de gas ajustable para pista.', 'Ohlins', 1500000.00, 5, 'ASAMA-2004', 'Yamaha', 'R6', 'Suspensión', 'https://m.media-amazon.com/images/I/61d-M1+D8+L._AC_SL1500_.jpg')," +
            "('Kit de Embrague Kevlar', 'Discos de fricción y separadores.', 'EBC', 130000.00, 12, 'ASAMA-2005', 'Honda', 'CBR600RR', 'Motor', 'https://m.media-amazon.com/images/I/71X-D5-k7WL._AC_SL1500_.jpg')," +
            "('Bomba de Freno Radial', 'Bomba de freno delantera de 19mm.', 'Brembo', 850000.00, 8, 'ASAMA-2006', 'Kawasaki', 'Ninja ZX-10R', 'Frenos', 'https://m.media-amazon.com/images/I/61K-K0-B8eL._AC_SL1500_.jpg')," +
            "('Espejos Retrovisores', 'Espejos tipo gota, estilo deportivo y elegante.', 'Rizoma', 125000.00, 25, 'ASAMA-2007', '', '', 'Accesorios', 'https://m.media-amazon.com/images/I/61b-N4-x3PL._AC_SL1000_.jpg')," +
            "('Líquido de Frenos DOT 4', 'Líquido de frenos de alto rendimiento. 500ml.', 'Motul', 28000.00, 40, 'ASAMA-2008', '', '', 'Frenos', 'https://m.media-amazon.com/images/I/61f-Q4-b0SL._AC_SL1500_.jpg')," +
            "('Bujía Iridium CR9EIX', 'Bujía de Iridium para mayor rendimiento.', 'NGK', 45000.00, 50, 'ASAMA-2009', 'Yamaha', 'MT-07', 'Eléctrico', 'https://m.media-amazon.com/images/I/61a-T8-U9tL._AC_SL1500_.jpg')," +
            "('Batería Litio YTZ10S', 'Batería super ligera de litio-ion.', 'Skyrich', 250000.00, 15, 'ASAMA-2010', 'Honda', 'CB1000R', 'Eléctrico', 'https://m.media-amazon.com/images/I/71Y-F0-R0kL._AC_SL1500_.jpg')," +
            "('Cúpula Deportiva', 'Cúpula ahumada doble burbuja, protección contra el viento.', 'Puig', 180000.00, 10, 'ASAMA-2011', 'Suzuki', 'GSX-R1000', 'Accesorios', 'https://m.media-amazon.com/images/I/61u-P8-a0zL._AC_SL1000_.jpg')," +
            "('Llanta Pilot Road 5', 'Llanta touring excelente agarre en mojado.', 'Michelin', 450000.00, 20, 'ASAMA-2012', '', '', 'Llantas', 'https://m.media-amazon.com/images/I/61d-M1+D8+L._AC_SL1500_.jpg')," +
            "('Aceite Telescópicos 10W', 'Aceite sintético para suspensión delantera.', 'Motorex', 42000.00, 30, 'ASAMA-2013', '', '', 'Suspensión', 'https://m.media-amazon.com/images/I/61s-L8-T0pL._AC_SL1500_.jpg')," +
            "('Defensas de Motor', 'Barras protectoras tubulares anticaída.', 'Givi', 320000.00, 8, 'ASAMA-2014', 'Suzuki', 'V-Strom 250', 'Accesorios', 'https://m.media-amazon.com/images/I/71o-Q5-V2pL._AC_SL1500_.jpg')," +
            "('Kit de Direccionales LED', 'Par de luces direccionales homologadas, alta visibilidad.', 'Barracuda', 85000.00, 25, 'ASAMA-2015', '', '', 'Eléctrico', 'https://m.media-amazon.com/images/I/61n-V8-K9kL._AC_SL1500_.jpg');";

        System.out.println("Connecting to Database and injecting products...");
        try (Connection conn = DbConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // Delete previously loaded sample 20xx products if this is re-run
            stmt.executeUpdate("DELETE FROM products WHERE barcode LIKE 'ASAMA-20%'");

            int rows = stmt.executeUpdate(sql);
            System.out.println("SUCCESS! Inserted " + rows + " new products into the database.");
            
            // Also update the original sample data to have some categories
            stmt.executeUpdate("UPDATE products SET part_category = 'Motor', motorcycle_brand = '', motorcycle_model = '' WHERE barcode = 'ASAMA-1001'");
            stmt.executeUpdate("UPDATE products SET part_category = 'Motor', motorcycle_brand = '', motorcycle_model = '' WHERE barcode = 'ASAMA-1002'");
            stmt.executeUpdate("UPDATE products SET part_category = 'Eléctrico', motorcycle_brand = '', motorcycle_model = '' WHERE barcode = 'ASAMA-1003'");
            stmt.executeUpdate("UPDATE products SET part_category = 'Transmisión', motorcycle_brand = 'Yamaha', motorcycle_model = 'FZ16' WHERE barcode = 'ASAMA-1004'");
            stmt.executeUpdate("UPDATE products SET part_category = 'Frenos', motorcycle_brand = 'Honda', motorcycle_model = 'CB190R' WHERE barcode = 'ASAMA-1005'");
            stmt.executeUpdate("UPDATE products SET part_category = 'Frenos', motorcycle_brand = 'Honda', motorcycle_model = 'CB190R' WHERE barcode = 'ASAMA-1006'");
            stmt.executeUpdate("UPDATE products SET part_category = 'Llantas', motorcycle_brand = '', motorcycle_model = '' WHERE barcode = 'ASAMA-1007'");
            stmt.executeUpdate("UPDATE products SET part_category = 'Llantas', motorcycle_brand = '', motorcycle_model = '' WHERE barcode = 'ASAMA-1008'");
            stmt.executeUpdate("UPDATE products SET part_category = 'Eléctrico', motorcycle_brand = '', motorcycle_model = '' WHERE barcode = 'ASAMA-1009'");
            stmt.executeUpdate("UPDATE products SET part_category = 'Accesorios', motorcycle_brand = '', motorcycle_model = '' WHERE barcode = 'ASAMA-1010'");
            stmt.executeUpdate("UPDATE products SET part_category = 'Accesorios', motorcycle_brand = '', motorcycle_model = '' WHERE barcode = 'ASAMA-1011'");
            stmt.executeUpdate("UPDATE products SET part_category = 'Suspensión', motorcycle_brand = '', motorcycle_model = '' WHERE barcode = 'ASAMA-1012'");
            System.out.println("SUCCESS! Updated old dummy products with categories and compatibilities.");

        } catch (Exception e) {
            System.err.println("ERROR inserting products:");
            e.printStackTrace();
        }
    }
}
