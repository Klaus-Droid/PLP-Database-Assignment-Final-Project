-- clinic_booking_system.sql
-- Clinic Booking System (MySQL)
-- Creates a database and all tables with constraints and relationships.
-- Author: Emmanuel Chege
-- Date: 2025-09-16

CREATE DATABASE clinic_db;
USE clinic_db;

-- ------------------------------
-- Owners (pet owners / clients)
-- ------------------------------
CREATE TABLE owners (
  owner_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  phone VARCHAR(30) NOT NULL,
  email VARCHAR(150),
  address VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (owner_id),
  UNIQUE KEY uq_owner_phone (phone),
  UNIQUE KEY uq_owner_email (email)
) ENGINE=InnoDB;

-- ------------------------------
-- Pets (patients)
-- ------------------------------
CREATE TABLE pets (
  pet_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  owner_id INT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  species VARCHAR(50) NOT NULL,          -- e.g., Dog, Cat, Rabbit
  breed VARCHAR(100),
  date_of_birth DATE,
  gender ENUM('Male','Female','Unknown') DEFAULT 'Unknown',
  microchip VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (pet_id),
  UNIQUE KEY uq_pet_microchip (microchip),
  INDEX idx_pets_owner (owner_id),
  CONSTRAINT fk_pets_owner FOREIGN KEY (owner_id)
    REFERENCES owners(owner_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------
-- Veterinarians
-- ------------------------------
CREATE TABLE vets (
  vet_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  license_number VARCHAR(100) NOT NULL,
  phone VARCHAR(30),
  email VARCHAR(150),
  specialization VARCHAR(150),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (vet_id),
  UNIQUE KEY uq_vet_license (license_number),
  UNIQUE KEY uq_vet_email (email)
) ENGINE=InnoDB;

-- ------------------------------
-- Services (catalog)
-- ------------------------------
CREATE TABLE services (
  service_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  duration_minutes INT UNSIGNED DEFAULT 30,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (service_id),
  UNIQUE KEY uq_service_name (name)
) ENGINE=InnoDB;

-- ------------------------------
-- Appointments
-- ------------------------------
CREATE TABLE appointments (
  appointment_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pet_id INT UNSIGNED NOT NULL,
  vet_id INT UNSIGNED NOT NULL,
  appointment_datetime DATETIME NOT NULL,
  status ENUM('scheduled','completed','cancelled','no-show') NOT NULL DEFAULT 'scheduled',
  reason VARCHAR(255),
  notes TEXT,
  created_by VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (appointment_id),
  INDEX idx_appointments_pet (pet_id),
  INDEX idx_appointments_vet (vet_id),
  INDEX idx_appointments_dt (appointment_datetime),
  CONSTRAINT fk_appointments_pet FOREIGN KEY (pet_id)
    REFERENCES pets(pet_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_appointments_vet FOREIGN KEY (vet_id)
    REFERENCES vets(vet_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Optional: prevent duplicate appointment at exact same datetime for same vet (simple safeguard)
CREATE UNIQUE INDEX uq_vet_datetime ON appointments(vet_id, appointment_datetime);

-- ------------------------------
-- Appointment_Services (many-to-many between appointments and services)
-- ------------------------------
CREATE TABLE appointment_services (
  appointment_id INT UNSIGNED NOT NULL,
  service_id INT UNSIGNED NOT NULL,
  quantity INT UNSIGNED NOT NULL DEFAULT 1,
  price_at_time DECIMAL(10,2) NOT NULL, -- snapshot of price when service was provided
  PRIMARY KEY (appointment_id, service_id),
  INDEX idx_as_appointment (appointment_id),
  INDEX idx_as_service (service_id),
  CONSTRAINT fk_as_appointment FOREIGN KEY (appointment_id)
    REFERENCES appointments(appointment_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_as_service FOREIGN KEY (service_id)
    REFERENCES services(service_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------
-- Invoices
-- ------------------------------
CREATE TABLE invoices (
  invoice_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  appointment_id INT UNSIGNED NOT NULL,
  invoice_number VARCHAR(100) NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  paid BOOLEAN NOT NULL DEFAULT FALSE,
  paid_at TIMESTAMP NULL DEFAULT NULL,
  notes TEXT,
  PRIMARY KEY (invoice_id),
  UNIQUE KEY uq_invoice_number (invoice_number),
  UNIQUE KEY uq_invoice_appointment (appointment_id),
  INDEX idx_invoice_issued_at (issued_at),
  CONSTRAINT fk_invoice_appointment FOREIGN KEY (appointment_id)
    REFERENCES appointments(appointment_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------
-- Simple users table for system users (optional)
-- ------------------------------
CREATE TABLE users (
  user_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(80) NOT NULL,
  display_name VARCHAR(150),
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','reception','vet','accountant') DEFAULT 'reception',
  email VARCHAR(150),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  UNIQUE KEY uq_users_username (username),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB;

-- ------------------------------
-- Useful views (example)
-- ------------------------------
-- View: appointment details with pet, owner and vet
DROP VIEW IF EXISTS vw_appointment_details;
CREATE VIEW vw_appointment_details AS
SELECT
  a.appointment_id,
  a.appointment_datetime,
  a.status,
  p.pet_id,
  p.name AS pet_name,
  p.species,
  o.owner_id,
  CONCAT(o.first_name, ' ', o.last_name) AS owner_name,
  v.vet_id,
  CONCAT(v.first_name, ' ', v.last_name) AS vet_name,
  a.reason
FROM appointments a
JOIN pets p ON a.pet_id = p.pet_id
JOIN owners o ON p.owner_id = o.owner_id
JOIN vets v ON a.vet_id = v.vet_id;

-- ------------------------------
-- Example seed data (OPTIONAL)
-- ------------------------------
-- Uncomment to insert sample rows for initial testing.

-- INSERT INTO owners (first_name, last_name, phone, email, address) VALUES
-- ('Alice','Ngugi','+254700000001','alice@example.com','Nairobi, Kenya'),
-- ('Brian','Ouma','+254700000002','brian@example.com','Nairobi, Kenya');

-- INSERT INTO pets (owner_id, name, species, breed, date_of_birth, gender, microchip) VALUES
-- (1, 'Bella', 'Dog', 'Labrador', '2019-05-12', 'Female', 'MC-1001'),
-- (2, 'Mittens', 'Cat', 'Domestic Shorthair', '2021-03-03', 'Female', NULL);

-- INSERT INTO vets (first_name, last_name, license_number, phone, email, specialization) VALUES
-- ('Dr. John','Wambua','LIC-2020-001','+254700000010','john.w@example.com','Surgery'),
-- ('Dr. Mary','Kariuki','LIC-2019-045','+254700000011','mary.k@example.com','Internal Medicine');

-- INSERT INTO services (name, description, price, duration_minutes) VALUES
-- ('General Checkup','Routine physical examination', 15.00, 20),
-- ('Vaccination','Core vaccinations', 25.00, 15),
-- ('Spay/Neuter','Neutering surgery', 120.00, 90);

-- Example appointment and invoice flow (uncomment to test)
-- INSERT INTO appointments (pet_id, vet_id, appointment_datetime, status, reason, created_by) VALUES
-- (1, 1, '2025-09-20 10:00:00', 'scheduled', 'Annual checkup', 'reception1');

-- INSERT INTO appointment_services (appointment_id, service_id, quantity, price_at_time)
-- VALUES (1, 1, 1, 15.00), (1, 2, 1, 25.00);

-- INSERT INTO invoices (appointment_id, invoice_number, total_amount, tax_amount, paid)
-- VALUES (1, 'INV-20250916-0001', 40.00, 0.00, FALSE);

-- ------------------------------
-- END OF SCRIPT
-- ------------------------------
