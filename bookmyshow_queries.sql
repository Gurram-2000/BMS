-- ============================================================================
-- BookMyShow - Query Solutions
-- P1: Database Design with Normalization
-- P2: Query to List Shows on a Given Date at a Theatre
-- ============================================================================

-- ============================================================================
-- P1: DATABASE SCHEMA AND NORMALIZATION EXPLANATION
-- ============================================================================
/*
ENTITY-RELATIONSHIP MODEL:

1. USERS
   - Stores customer information
   - Primary Key: user_id
   - Attributes: user_id, first_name, last_name, email, phone, registration_date
   - Normalization: Follows BCNF - No partial or transitive dependencies

2. CITIES
   - Lookup table for cities to maintain referential integrity
   - Primary Key: city_id
   - Attributes: city_id, city_name, state
   - Normalization: Follows BCNF - No partial or transitive dependencies

3. THEATRES
   - Stores theatre information
   - Primary Key: theatre_id
   - Foreign Key: city_id (references cities)
   - Attributes: theatre_id, theatre_name, city_id, location, phone, email
   - Normalization: Follows BCNF - city_id is separated to avoid transitive dependency

4. SCREENS
   - Stores screen information for each theatre
   - Primary Key: screen_id
   - Foreign Key: theatre_id (references theatres)
   - Attributes: screen_id, theatre_id, screen_name, total_seats, screen_type
   - Normalization: Follows 3NF - All attributes depend on screen_id

5. SEAT_TYPES
   - Lookup table for different seat types (Standard, Premium, Recliner)
   - Primary Key: seat_type_id
   - Attributes: seat_type_id, seat_type_name
   - Normalization: Follows BCNF

6. SEATS
   - Stores individual seat information
   - Primary Key: seat_id
   - Foreign Keys: screen_id, seat_type_id
   - Attributes: seat_id, screen_id, row_number, seat_number, seat_type_id
   - Normalization: Follows BCNF - No partial or transitive dependencies

7. MOVIES
   - Stores movie information
   - Primary Key: movie_id
   - Attributes: movie_id, title, genre, language, duration_minutes, release_date, rating
   - Normalization: Follows BCNF - All atomic values

8. SHOWS
   - Stores show information (specific showing of a movie)
   - Primary Key: show_id
   - Foreign Keys: movie_id, screen_id
   - Attributes: show_id, movie_id, screen_id, show_date, show_time, ticket_price, available_seats
   - Normalization: Follows 3NF - Ticket price is atomic value, available_seats is calculated

9. BOOKING_STATUSES
   - Lookup table for booking status
   - Primary Key: status_id
   - Attributes: status_id, status_name
   - Normalization: Follows BCNF

10. BOOKINGS
    - Stores ticket booking information
    - Primary Key: booking_id
    - Foreign Keys: user_id, show_id, seat_id, status_id
    - Attributes: booking_id, user_id, show_id, seat_id, booking_date, amount, status_id
    - Normalization: Follows BCNF - Each attribute fully depends on booking_id

NORMALIZATION RULES COMPLIANCE:
✓ 1NF: All attributes are atomic (no repeating groups)
✓ 2NF: No partial dependencies on composite keys
✓ 3NF: No transitive dependencies (theatre city info separated)
✓ BCNF: Every determinant is a candidate key
*/

-- ============================================================================
-- P2: Query to List All Shows on a Given Date at a Given Theatre
-- ============================================================================

/*
REQUIREMENT: List all shows on a given date at a given theatre with show timings

PARAMETERS:
- Theatre Name: 'PVR Cinemas - Worli'
- Date: '2024-04-22'

This query will return:
- Theatre Name
- Screen Name
- Screen Type
- Movie Title
- Language
- Show Time
- Movie Duration
- Ticket Price
- Available Seats
*/

SELECT 
    t.theatre_name,
    t.location AS theatre_location,
    s.screen_name,
    s.screen_type,
    m.title AS movie_title,
    m.genre,
    m.language,
    sh.show_time,
    m.duration_minutes,
    sh.ticket_price,
    sh.available_seats,
    sh.show_id
FROM shows sh
INNER JOIN screens s ON sh.screen_id = s.screen_id
INNER JOIN theatres t ON s.theatre_id = t.theatre_id
INNER JOIN movies m ON sh.movie_id = m.movie_id
WHERE t.theatre_name = 'PVR Cinemas - Worli'
    AND sh.show_date = '2024-04-22'
ORDER BY s.screen_name, sh.show_time;

-- ============================================================================
-- ALTERNATIVE QUERY: List Shows by Theatre ID and Date (More Efficient)
-- ============================================================================

SELECT 
    t.theatre_name,
    t.location AS theatre_location,
    s.screen_name,
    s.screen_type,
    m.title AS movie_title,
    m.genre,
    m.language,
    sh.show_time,
    m.duration_minutes,
    sh.ticket_price,
    sh.available_seats,
    sh.show_id
FROM shows sh
INNER JOIN screens s ON sh.screen_id = s.screen_id
INNER JOIN theatres t ON s.theatre_id = t.theatre_id
INNER JOIN movies m ON sh.movie_id = m.movie_id
WHERE t.theatre_id = 1  -- PVR Cinemas - Worli
    AND sh.show_date = '2024-04-22'
ORDER BY s.screen_name, sh.show_time;

-- ============================================================================
-- QUERY 3: List Shows with Screen Details for a Given Theatre on a Date
-- ============================================================================

SELECT 
    sh.show_id,
    s.screen_id,
    s.screen_name,
    s.screen_type,
    s.total_seats,
    m.movie_id,
    m.title AS movie_title,
    m.genre,
    m.language,
    m.duration_minutes,
    m.rating,
    sh.show_date,
    sh.show_time,
    sh.ticket_price,
    sh.available_seats,
    (s.total_seats - sh.available_seats) AS booked_seats,
    CONCAT(sh.show_time, ' - ', 
        DATE_FORMAT(
            DATE_ADD(CONCAT(sh.show_date, ' ', sh.show_time), 
            INTERVAL m.duration_minutes MINUTE), 
            '%H:%i'
        )) AS show_duration_display
FROM shows sh
INNER JOIN screens s ON sh.screen_id = s.screen_id
INNER JOIN theatres t ON s.theatre_id = t.theatre_id
INNER JOIN movies m ON sh.movie_id = m.movie_id
WHERE t.theatre_name = 'PVR Cinemas - Worli'
    AND sh.show_date = '2024-04-22'
ORDER BY s.screen_name, sh.show_time;

-- ============================================================================
-- QUERY 4: List Next 7 Days of Shows for a Theatre
-- ============================================================================

SELECT 
    sh.show_date,
    DAYNAME(sh.show_date) AS day_name,
    s.screen_name,
    m.title AS movie_title,
    sh.show_time,
    sh.ticket_price,
    sh.available_seats
FROM shows sh
INNER JOIN screens s ON sh.screen_id = s.screen_id
INNER JOIN theatres t ON s.theatre_id = t.theatre_id
INNER JOIN movies m ON sh.movie_id = m.movie_id
WHERE t.theatre_name = 'PVR Cinemas - Worli'
    AND sh.show_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 6 DAY)
ORDER BY sh.show_date, s.screen_name, sh.show_time;

-- ============================================================================
-- QUERY 5: Count of Shows by Movie for a Theatre on a Given Date
-- ============================================================================

SELECT 
    m.title AS movie_title,
    m.language,
    COUNT(sh.show_id) AS total_shows,
    SUM(sh.available_seats) AS total_available_seats,
    AVG(sh.ticket_price) AS avg_ticket_price
FROM shows sh
INNER JOIN screens s ON sh.screen_id = s.screen_id
INNER JOIN theatres t ON s.theatre_id = t.theatre_id
INNER JOIN movies m ON sh.movie_id = m.movie_id
WHERE t.theatre_name = 'PVR Cinemas - Worli'
    AND sh.show_date = '2024-04-22'
GROUP BY m.movie_id, m.title, m.language
ORDER BY total_shows DESC;

-- ============================================================================
-- QUERY 6: Show Details with Booking Information
-- ============================================================================

SELECT 
    t.theatre_name,
    s.screen_name,
    m.title AS movie_title,
    sh.show_date,
    sh.show_time,
    sh.ticket_price,
    s.total_seats,
    sh.available_seats,
    (s.total_seats - sh.available_seats) AS booked_seats,
    COUNT(b.booking_id) AS confirmed_bookings
FROM shows sh
INNER JOIN screens s ON sh.screen_id = s.screen_id
INNER JOIN theatres t ON s.theatre_id = t.theatre_id
INNER JOIN movies m ON sh.movie_id = m.movie_id
LEFT JOIN bookings b ON sh.show_id = b.show_id AND b.status_id = 1
WHERE t.theatre_name = 'PVR Cinemas - Worli'
    AND sh.show_date = '2024-04-22'
GROUP BY sh.show_id, t.theatre_name, s.screen_name, m.title, 
         sh.show_date, sh.show_time, sh.ticket_price, s.total_seats
ORDER BY s.screen_name, sh.show_time;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- View all available theatres
SELECT * FROM theatres;

-- View all screens in PVR Cinemas - Worli
SELECT s.* FROM screens s
INNER JOIN theatres t ON s.theatre_id = t.theatre_id
WHERE t.theatre_name = 'PVR Cinemas - Worli';

-- View all shows in the database
SELECT 
    t.theatre_name,
    s.screen_name,
    m.title,
    sh.show_date,
    sh.show_time
FROM shows sh
INNER JOIN screens s ON sh.screen_id = s.screen_id
INNER JOIN theatres t ON s.theatre_id = t.theatre_id
INNER JOIN movies m ON sh.movie_id = m.movie_id
ORDER BY sh.show_date, t.theatre_name, s.screen_name, sh.show_time;
