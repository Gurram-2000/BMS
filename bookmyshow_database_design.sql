-- ============================================================================
-- BookMyShow Database Design
-- Database follows 1NF, 2NF, 3NF, and BCNF normalization rules
-- ============================================================================

-- Create Database
CREATE DATABASE IF NOT EXISTS bookmyshow;
USE bookmyshow;

-- ============================================================================
-- TABLE: users
-- Stores user/customer information
-- Primary Key: user_id
-- ============================================================================
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) NOT NULL,
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABLE: cities
-- Stores city information to avoid data redundancy
-- Primary Key: city_id
-- ============================================================================
CREATE TABLE cities (
    city_id INT PRIMARY KEY AUTO_INCREMENT,
    city_name VARCHAR(50) UNIQUE NOT NULL,
    state VARCHAR(50) NOT NULL
);

-- ============================================================================
-- TABLE: theatres
-- Stores theatre/cinema information
-- Primary Key: theatre_id
-- Foreign Key: city_id references cities
-- ============================================================================
CREATE TABLE theatres (
    theatre_id INT PRIMARY KEY AUTO_INCREMENT,
    theatre_name VARCHAR(100) NOT NULL,
    city_id INT NOT NULL,
    location VARCHAR(150) NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100),
    FOREIGN KEY (city_id) REFERENCES cities(city_id),
    UNIQUE KEY unique_theatre (theatre_name, city_id)
);

-- ============================================================================
-- TABLE: screens
-- Stores screen/auditorium information for each theatre
-- Primary Key: screen_id
-- Foreign Key: theatre_id references theatres
-- ============================================================================
CREATE TABLE screens (
    screen_id INT PRIMARY KEY AUTO_INCREMENT,
    theatre_id INT NOT NULL,
    screen_name VARCHAR(50) NOT NULL,
    total_seats INT NOT NULL CHECK (total_seats > 0),
    screen_type VARCHAR(30),
    FOREIGN KEY (theatre_id) REFERENCES theatres(theatre_id),
    UNIQUE KEY unique_screen (theatre_id, screen_name)
);

-- ============================================================================
-- TABLE: seat_types
-- Lookup table for different seat types (standard, premium, recliner, etc.)
-- Primary Key: seat_type_id
-- ============================================================================
CREATE TABLE seat_types (
    seat_type_id INT PRIMARY KEY AUTO_INCREMENT,
    seat_type_name VARCHAR(50) UNIQUE NOT NULL
);

-- ============================================================================
-- TABLE: seats
-- Stores individual seat information for each screen
-- Primary Key: seat_id
-- Foreign Keys: screen_id, seat_type_id
-- ============================================================================
CREATE TABLE seats (
    seat_id INT PRIMARY KEY AUTO_INCREMENT,
    screen_id INT NOT NULL,
    row_number CHAR(1) NOT NULL,
    seat_number INT NOT NULL,
    seat_type_id INT NOT NULL,
    FOREIGN KEY (screen_id) REFERENCES screens(screen_id),
    FOREIGN KEY (seat_type_id) REFERENCES seat_types(seat_type_id),
    UNIQUE KEY unique_seat (screen_id, row_number, seat_number)
);

-- ============================================================================
-- TABLE: movies
-- Stores movie information
-- Primary Key: movie_id
-- ============================================================================
CREATE TABLE movies (
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(150) NOT NULL,
    genre VARCHAR(50) NOT NULL,
    language VARCHAR(30) NOT NULL,
    duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
    release_date DATE NOT NULL,
    rating VARCHAR(10),
    UNIQUE KEY unique_movie (title, language, release_date)
);

-- ============================================================================
-- TABLE: shows
-- Stores show information (specific showing of a movie at a specific time)
-- Primary Key: show_id
-- Foreign Keys: movie_id, screen_id
-- ============================================================================
CREATE TABLE shows (
    show_id INT PRIMARY KEY AUTO_INCREMENT,
    movie_id INT NOT NULL,
    screen_id INT NOT NULL,
    show_date DATE NOT NULL,
    show_time TIME NOT NULL,
    ticket_price DECIMAL(10, 2) NOT NULL CHECK (ticket_price > 0),
    available_seats INT NOT NULL CHECK (available_seats >= 0),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
    FOREIGN KEY (screen_id) REFERENCES screens(screen_id),
    UNIQUE KEY unique_show (screen_id, show_date, show_time),
    INDEX idx_show_date_time (show_date, show_time),
    INDEX idx_screen_date (screen_id, show_date)
);

-- ============================================================================
-- TABLE: booking_statuses
-- Lookup table for booking status (Confirmed, Cancelled, Pending)
-- Primary Key: status_id
-- ============================================================================
CREATE TABLE booking_statuses (
    status_id INT PRIMARY KEY AUTO_INCREMENT,
    status_name VARCHAR(30) UNIQUE NOT NULL
);

-- ============================================================================
-- TABLE: bookings
-- Stores ticket booking information
-- Primary Key: booking_id
-- Foreign Keys: user_id, show_id, seat_id, status_id
-- ============================================================================
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    show_id INT NOT NULL,
    seat_id INT NOT NULL,
    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    status_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (show_id) REFERENCES shows(show_id),
    FOREIGN KEY (seat_id) REFERENCES seats(seat_id),
    FOREIGN KEY (status_id) REFERENCES booking_statuses(status_id),
    UNIQUE KEY unique_booking (show_id, seat_id),
    INDEX idx_user_booking (user_id, booking_date),
    INDEX idx_show_booking (show_id, booking_date)
);

-- ============================================================================
-- INSERT SAMPLE DATA
-- ============================================================================

-- Insert cities
INSERT INTO cities (city_name, state) VALUES
('Mumbai', 'Maharashtra'),
('Delhi', 'Delhi'),
('Bangalore', 'Karnataka'),
('Hyderabad', 'Telangana'),
('Chennai', 'Tamil Nadu');

-- Insert theatres
INSERT INTO theatres (theatre_name, city_id, location, phone, email) VALUES
('PVR Cinemas - Worli', 1, 'Worli, Mumbai', '022-12345678', 'pvr.worli@pvr.co.in'),
('INOX - BKC', 1, 'Bandra Kurla Complex, Mumbai', '022-87654321', 'inox.bkc@inoxmovies.com'),
('Cinepolis - Connaught Place', 2, 'Connaught Place, Delhi', '011-40123456', 'cinepolis.cp@cinepolis.com'),
('Carnival Cinemas - Bangalore', 3, 'Whitefield, Bangalore', '080-25678901', 'carnival.bf@carnival.co.in'),
('Imax - Hyderabad', 4, 'Begumpet, Hyderabad', '040-12345678', 'imax.bg@imax.com');

-- Insert screens for PVR Cinemas - Worli
INSERT INTO screens (theatre_id, screen_name, total_seats, screen_type) VALUES
(1, 'Screen 1', 150, 'Standard'),
(1, 'Screen 2', 180, '4DX'),
(1, 'Screen 3', 200, 'IMAX'),
(2, 'Screen A', 160, 'Standard'),
(2, 'Screen B', 190, 'Dolby Atmos'),
(3, 'Hall 1', 170, 'Standard'),
(3, 'Hall 2', 210, '3D'),
(4, 'Theater 1', 150, 'Standard'),
(5, 'Premium Hall', 220, 'IMAX');

-- Insert seat types
INSERT INTO seat_types (seat_type_name) VALUES
('Standard'),
('Premium'),
('Recliner'),
('Wheelchair Accessible');

-- Insert seats for Screen 1 (PVR Worli - Screen 1) - 150 seats
INSERT INTO seats (screen_id, row_number, seat_number, seat_type_id) 
SELECT 1, CHAR(64 + numbers.n), seats.n, 
    CASE 
        WHEN seats.n IN (7, 8, 9, 10) THEN 2  -- Premium
        WHEN seats.n IN (1, 2, 3, 4, 5, 6) AND CHAR(64 + numbers.n) IN ('A', 'B') THEN 1  -- Standard front
        ELSE 1  -- Standard
    END
FROM (
    SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
    UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
    UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
) seats
CROSS JOIN (
    SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
    UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
) numbers;

-- Insert movies
INSERT INTO movies (title, genre, language, duration_minutes, release_date, rating) VALUES
('Bade Miyan Chote Miyan', 'Action', 'Hindi', 120, '2024-04-10', 'PG-13'),
('Article 370', 'Thriller', 'Hindi', 138, '2024-02-16', 'UA'),
('Godzilla X Kong', 'Action/Adventure', 'English', 145, '2024-03-29', 'PG-13'),
('Salaar: Part 2', 'Action', 'Telugu', 155, '2024-05-01', 'A'),
('Crew', 'Comedy', 'Hindi', 112, '2024-03-28', 'UA');

-- Insert shows for Screen 1 (PVR Worli, Screen 1) on different dates
INSERT INTO shows (movie_id, screen_id, show_date, show_time, ticket_price, available_seats) VALUES
(1, 1, '2024-04-22', '10:00:00', 200.00, 120),
(1, 1, '2024-04-22', '13:30:00', 250.00, 85),
(1, 1, '2024-04-22', '16:45:00', 300.00, 45),
(1, 1, '2024-04-22', '19:15:00', 350.00, 20),
(2, 1, '2024-04-22', '11:00:00', 220.00, 95),
(2, 1, '2024-04-22', '14:00:00', 270.00, 60),
(3, 1, '2024-04-23', '10:15:00', 250.00, 110),
(3, 1, '2024-04-23', '13:15:00', 300.00, 75),
(4, 1, '2024-04-23', '16:00:00', 320.00, 50),
(5, 1, '2024-04-24', '09:30:00', 180.00, 140);

-- Insert shows for Screen 2 (PVR Worli, Screen 2 - 4DX)
INSERT INTO shows (movie_id, screen_id, show_date, show_time, ticket_price, available_seats) VALUES
(1, 2, '2024-04-22', '10:30:00', 350.00, 160),
(1, 2, '2024-04-22', '14:00:00', 400.00, 95),
(3, 2, '2024-04-22', '17:30:00', 420.00, 55),
(2, 2, '2024-04-23', '11:00:00', 380.00, 120),
(4, 2, '2024-04-23', '15:00:00', 450.00, 70);

-- Insert shows for Screen 3 (PVR Worli, Screen 3 - IMAX)
INSERT INTO shows (movie_id, screen_id, show_date, show_time, ticket_price, available_seats) VALUES
(3, 3, '2024-04-22', '12:00:00', 500.00, 180),
(3, 3, '2024-04-22', '15:30:00', 550.00, 110),
(5, 3, '2024-04-22', '18:45:00', 480.00, 75),
(1, 3, '2024-04-23', '10:00:00', 520.00, 160),
(2, 3, '2024-04-23', '14:30:00', 550.00, 90);

-- Insert users
INSERT INTO users (first_name, last_name, email, phone) VALUES
('Rajesh', 'Kumar', 'rajesh.kumar@email.com', '9876543210'),
('Priya', 'Singh', 'priya.singh@email.com', '9876543211'),
('Amit', 'Patel', 'amit.patel@email.com', '9876543212'),
('Anjali', 'Sharma', 'anjali.sharma@email.com', '9876543213'),
('Vikram', 'Reddy', 'vikram.reddy@email.com', '9876543214');

-- Insert booking statuses
INSERT INTO booking_statuses (status_name) VALUES
('Confirmed'),
('Cancelled'),
('Pending'),
('Expired');

-- Insert sample bookings
INSERT INTO bookings (user_id, show_id, seat_id, amount, status_id) VALUES
(1, 1, 1, 200.00, 1),
(1, 1, 2, 200.00, 1),
(2, 1, 5, 200.00, 1),
(3, 1, 10, 200.00, 1),
(2, 2, 25, 250.00, 1),
(4, 2, 26, 250.00, 1),
(5, 3, 15, 300.00, 1),
(1, 6, 30, 270.00, 1),
(3, 6, 31, 270.00, 1),
(2, 7, 50, 250.00, 1);

-- Create indexes for better query performance
CREATE INDEX idx_theatre_city ON theatres(city_id);
CREATE INDEX idx_screen_theatre ON screens(theatre_id);
CREATE INDEX idx_seat_screen ON seats(screen_id);
CREATE INDEX idx_seat_type ON seats(seat_type_id);
CREATE INDEX idx_movie_language ON movies(language);
CREATE INDEX idx_show_movie ON shows(movie_id);
CREATE INDEX idx_show_screen ON shows(screen_id);
CREATE INDEX idx_booking_user ON bookings(user_id);
