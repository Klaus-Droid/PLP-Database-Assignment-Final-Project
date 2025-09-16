🏥 Clinic Booking System (MySQL Database)
📌 Project Overview

This project implements a relational database management system (RDBMS) for a veterinary/medical clinic booking system.
It demonstrates database design principles, proper constraints, and relationships between entities such as Owners, Pets, Veterinarians, Appointments, Services, and Invoices.

The database supports:

Managing clients (owners) and their pets.

Scheduling appointments with veterinarians.

Linking services to appointments (many-to-many).

Generating invoices for completed appointments.

✨ Features

Well-structured schema with normalization applied.

Primary keys, foreign keys, unique constraints, and NOT NULL constraints ensure data integrity.

One-to-Many relationships (e.g., Owner → Pets, Vet → Appointments).

Many-to-Many relationships handled via a junction table (appointment_services).

Views for simplified data reporting.

Optional seed data for testing.

🛠️ Technologies Used

MySQL (v8.0 or compatible)

SQL DDL (Data Definition Language) – CREATE DATABASE, CREATE TABLE, constraints.

SQL DML (optional seed data) – INSERT statements for testing.

📂 Database Schema

Entities & Relationships:

owners – Stores client information.

pets – Linked to owners (1:N).

vets – Veterinarians in the clinic.

services – Catalog of available services.

appointments – Bookings for pets with vets.

appointment_services – Links services to appointments (M:N).

invoices – Billing linked to appointments (1:1).

users – System users (admins, reception, vets).

🚀 How to Run Locally

Open MySQL client or terminal.

Run the SQL script:

mysql -u your_username -p < clinic_booking_system.sql


Switch to the database:

USE clinic_db;


(Optional) Insert seed data by uncommenting the provided INSERT statements.

📖 Example Queries

View all appointments with pet, owner, and vet details:

SELECT * FROM vw_appointment_details;


List all unpaid invoices:

SELECT * FROM invoices WHERE paid = FALSE;


Find all pets belonging to a specific owner:

SELECT name, species, breed FROM pets WHERE owner_id = 1;
