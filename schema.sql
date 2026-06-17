-- Database Schema for Asama Moto Parts

-- Drop existing tables if they exist
DROP TABLE IF EXISTS maintenance_jobs CASCADE;
DROP TABLE IF EXISTS motorcycles CASCADE;
DROP TABLE IF EXISTS inventory_logs CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS time_tracking CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS roles CASCADE;

-- 1. Roles Table
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO roles (name) VALUES 
('Administrador'),
('Contador'),
('Bodeguero'),
('Cajero'),
('Cliente'),
('Mecánico');

-- 2. Users Table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    document_id VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role_id INT NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
    barcode VARCHAR(100) UNIQUE,
    photo_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Products Table (Repuestos de Motos)
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    brand VARCHAR(100),
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    barcode VARCHAR(100) UNIQUE NOT NULL,
    image_url VARCHAR(255),
    estante VARCHAR(50),
    fila VARCHAR(50),
    minimo_programado INT DEFAULT 5,
    motorcycle_brand VARCHAR(100),
    motorcycle_model VARCHAR(100),
    part_category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Time Tracking Table
CREATE TABLE time_tracking (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entry_time TIMESTAMP NOT NULL,
    exit_time TIMESTAMP,
    date DATE NOT NULL DEFAULT CURRENT_DATE
);

-- 5. Sales Table
CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES users(id),
    cashier_id INT REFERENCES users(id),
    product_id INT NOT NULL REFERENCES products(id),
    quantity INT NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sale_type VARCHAR(50) DEFAULT 'IN_STORE'
);

-- 6. Inventory Logs Table
CREATE TABLE inventory_logs (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES users(id),
    quantity_added INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. Motorcycles Table
CREATE TABLE motorcycles (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES users(id),
    plate VARCHAR(20) NOT NULL UNIQUE,
    brand VARCHAR(100),
    model VARCHAR(100),
    year INT
);

-- 8. Maintenance Jobs Table
CREATE TABLE maintenance_jobs (
    id SERIAL PRIMARY KEY,
    motorcycle_id INT NOT NULL REFERENCES motorcycles(id),
    mechanic_id INT REFERENCES users(id),
    description TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDIENTE',
    cost DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Default Admin (password: admin123 hashed with SHA-256)
INSERT INTO users (full_name, document_id, email, password, role_id, barcode)
VALUES ('Admin Principal', '123456789', 'admin@asama.com', 
        'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 1, 'ASAMA-ADM-1');

-- Sample Motorcycle Parts
INSERT INTO products (name, description, brand, price, stock, barcode) VALUES
('Aceite Motor 10W-40', 'Aceite sintético para motores de moto 4 tiempos. 1 litro.', 'Motul', 35000.00, 50, 'ASAMA-1001'),
('Filtro de Aceite', 'Filtro de aceite universal para motos 150cc-250cc.', 'Hiflofiltro', 18000.00, 30, 'ASAMA-1002'),
('Bujía NGK CR8E', 'Bujía de encendido estándar para motos.', 'NGK', 12000.00, 100, 'ASAMA-1003'),
('Kit Cadena 428H', 'Kit completo de cadena, piñón y corona. 428H x 118 eslabones.', 'DID', 85000.00, 15, 'ASAMA-1004'),
('Pastillas de Freno Delanteras', 'Pastillas semimetálicas para freno de disco delantero.', 'EBC', 28000.00, 40, 'ASAMA-1005'),
('Pastillas de Freno Traseras', 'Pastillas orgánicas para freno de disco trasero.', 'EBC', 22000.00, 35, 'ASAMA-1006'),
('Llanta Delantera 110/70-17', 'Llanta deportiva para moto, compuesto suave.', 'Pirelli', 180000.00, 10, 'ASAMA-1007'),
('Llanta Trasera 140/70-17', 'Llanta trasera deportiva, excelente agarre.', 'Pirelli', 210000.00, 8, 'ASAMA-1008'),
('Batería YTX7A-BS', 'Batería de gel libre de mantenimiento 12V 7Ah.', 'Yuasa', 95000.00, 20, 'ASAMA-1009'),
('Cable de Acelerador', 'Cable de acelerador universal ajustable.', 'Genérico', 15000.00, 25, 'ASAMA-1010'),
('Manigueta Freno Derecha', 'Manigueta de freno en aluminio con pivot.', 'Genérico', 25000.00, 18, 'ASAMA-1011'),
('Kit Rodamientos Dirección', 'Juego completo de rodamientos de dirección.', 'All Balls', 45000.00, 12, 'ASAMA-1012');

-- 9. Post Sale Requests Table (Garantías y Devoluciones)
CREATE TABLE post_sale_requests (
    id SERIAL PRIMARY KEY,
    sale_id INT NOT NULL REFERENCES sales(id),
    request_type VARCHAR(50) NOT NULL, -- GARANTIA, DEVOLUCION
    damage VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    image_path VARCHAR(255),
    status VARCHAR(50) DEFAULT 'PENDIENTE', -- PENDIENTE, APROBADA, RECHAZADA
    admin_reply TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. Accountant Reports Table (Reportes en PDF generados para el contador)
CREATE TABLE accountant_reports (
    id SERIAL PRIMARY KEY,
    request_id INT NOT NULL REFERENCES post_sale_requests(id),
    pdf_path VARCHAR(255) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. Audit Logs Table (Auditoría de Operaciones del Personal)
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    module VARCHAR(50) NOT NULL,
    action VARCHAR(100) NOT NULL,
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 12. Online Orders Table (Historial y Notificaciones de Pedidos Web)
CREATE TABLE online_orders (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES users(id),
    total_amount DECIMAL(10, 2) NOT NULL,
    shipping_cost DECIMAL(10, 2) DEFAULT 0.00,
    items_json TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDIENTE',
    is_read_admin BOOLEAN DEFAULT FALSE,
    is_read_cashier BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

