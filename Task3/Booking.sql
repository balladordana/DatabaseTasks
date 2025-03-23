--Определить, какие клиенты сделали более двух бронирований в разных отелях, и вывести информацию о каждом таком клиенте, включая его имя, электронную почту, телефон, общее количество бронирований, а также список отелей, в которых они бронировали номера (объединенные в одно поле через запятую с помощью CONCAT). Также подсчитать среднюю длительность их пребывания (в днях) по всем бронированиям. Отсортировать результаты по количеству бронирований в порядке убывания.
SELECT c.name, c.email, c.phone,
COUNT(b.ID_booking) AS total_bookings,
STRING_AGG(DISTINCT h.name, ', ') AS hotel_list,
AVG(b.check_out_date - b.check_in_date) AS avg_stay_duration
FROM Booking b
JOIN Room r ON b.ID_room = r.ID_room
JOIN Hotel h ON r.ID_hotel = h.ID_hotel
join Customer c ON b.ID_customer = c.ID_customer
GROUP BY b.ID_customer, c.name, c.email, c.phone
HAVING COUNT(b.ID_booking) > 2 AND COUNT(DISTINCT r.ID_hotel) > 1;

--Необходимо провести анализ клиентов, которые сделали более двух бронирований в разных отелях и потратили более 500 долларов на свои бронирования.
with countBooking as (
SELECT b.ID_customer, c.name, 
COUNT(b.ID_booking) AS total_bookings,
sum(r.price * (b.check_out_date - b.check_in_date)) AS total_spent,
COUNT(DISTINCT r.ID_hotel) as unique_hotels
FROM Booking b
JOIN Room r ON b.ID_room = r.ID_room
join Customer c ON b.ID_customer = c.ID_customer
GROUP BY b.ID_customer, c.name 
HAVING COUNT(b.ID_booking) > 2 AND COUNT(DISTINCT r.ID_hotel) > 1),
countSpent as (
SELECT b.ID_customer, c.name, 
COUNT(b.ID_booking) AS total_bookings,
sum(r.price * (b.check_out_date - b.check_in_date)) AS total_spent
FROM Booking b
JOIN Room r ON b.ID_room = r.ID_room
join Customer c ON b.ID_customer = c.ID_customer
GROUP BY b.ID_customer, c.name 
HAVING sum(r.price * (b.check_out_date - b.check_in_date)) > 500)
select countBooking.*
from countBooking
join countSpent on countBooking.ID_customer = countSpent.ID_customer
order by countBooking.total_spent;

--Вам необходимо провести анализ данных о бронированиях в отелях и определить предпочтения клиентов по типу отелей
WITH HotelCategory AS (
    -- Определяем категорию каждого отеля по средней цене номера
    SELECT 
        h.ID_hotel,
        h.name AS hotel_name,
        CASE 
            WHEN AVG(r.price) < 175 THEN 'Дешевый'
            WHEN AVG(r.price) BETWEEN 175 AND 300 THEN 'Средний'
            ELSE 'Дорогой'
        END AS hotel_category
    FROM Hotel h
    JOIN Room r ON h.ID_hotel = r.ID_hotel
    GROUP BY h.ID_hotel, h.name
), 
CustomerPreferences AS (
    -- Определяем предпочитаемый тип отеля для каждого клиента
    SELECT 
        b.ID_customer,
        CASE 
            WHEN COUNT(DISTINCT CASE WHEN hc.hotel_category = 'Дорогой' THEN hc.ID_hotel END) > 0 THEN 'Дорогой'
            WHEN COUNT(DISTINCT CASE WHEN hc.hotel_category = 'Средний' THEN hc.ID_hotel END) > 0 THEN 'Средний'
            ELSE 'Дешевый'
        END AS preferred_hotel_type,
        STRING_AGG(DISTINCT hc.hotel_name, ', ') AS visited_hotels
    FROM Booking b
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN HotelCategory hc ON r.ID_hotel = hc.ID_hotel
    GROUP BY b.ID_customer
)
SELECT 
    c.ID_customer,
    c.name,
    cp.preferred_hotel_type,
    cp.visited_hotels
FROM CustomerPreferences cp
JOIN Customer c ON cp.ID_customer = c.ID_customer
ORDER BY 
    CASE cp.preferred_hotel_type 
        WHEN 'Дешевый' THEN 1 
        WHEN 'Средний' THEN 2 
        WHEN 'Дорогой' THEN 3 
    END;

