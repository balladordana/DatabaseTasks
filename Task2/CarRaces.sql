--Определить, какие автомобили из каждого класса имеют наименьшую среднюю позицию в гонках, и вывести информацию о каждом таком автомобиле для данного класса, включая его класс, среднюю позицию и количество гонок, в которых он участвовал. Также отсортировать результаты по средней позиции.
select * from (
SELECT DISTINCT ON (cars."class") 
    cars."name" car_name,
    cars."class" car_class, 
    q.average_position, 
    q.race_count
from cars join
(select car, avg("position") average_position, count(*) race_count from results
group by car) q on q.car = cars."name"
ORDER BY cars."class", q.average_position)
order by  average_position;

--Определить автомобиль, который имеет наименьшую среднюю позицию в гонках среди всех автомобилей, и вывести информацию об этом автомобиле, включая его класс, среднюю позицию, количество гонок, в которых он участвовал, и страну производства класса автомобиля. Если несколько автомобилей имеют одинаковую наименьшую среднюю позицию, выбрать один из них по алфавиту (по имени автомобиля).
SELECT cars."name" car_name, 
    cars."class" car_class, 
    q.average_position, 
    q.race_count,
	classes.country car_country
from cars 
join (select car, avg("position") average_position, count(*) race_count from results
group by car) q on q.car = cars."name"
join classes on classes."class" = cars."class" 
ORDER BY q.average_position, cars."name"
LIMIT 1;

--Определить классы автомобилей, которые имеют наименьшую среднюю позицию в гонках, и вывести информацию о каждом автомобиле из этих классов, включая его имя, среднюю позицию, количество гонок, в которых он участвовал, страну производства класса автомобиля, а также общее количество гонок, в которых участвовали автомобили этих классов. Если несколько классов имеют одинаковую среднюю позицию, выбрать все из них.
with carPos as (
	select car, avg("position") average_position, count(*) race_count from results
	group by car
),
carClass as (
	SELECT cars."class"
	from cars
	join carPos on carPos.car = cars."name"
	where carPos.average_position = (select min(average_position) from carPos) 
)
SELECT cars."name" car_name, cars."class" car_class, average_position, race_count, classes.country car_country, 
SUM(carPos.race_count) OVER (PARTITION BY cars.class) total_races
from cars
join carPos on carPos.car = cars."name"
join classes ON classes."class" = cars."class"
join carClass on carClass."class" = cars."class"
where cars.class = carClass.class;

--Определить, какие автомобили имеют среднюю позицию лучше (меньше) средней позиции всех автомобилей в своем классе (то есть автомобилей в классе должно быть минимум два, чтобы выбрать один из них). Вывести информацию об этих автомобилях, включая их имя, класс, среднюю позицию, количество гонок, в которых они участвовали, и страну производства класса автомобиля. Также отсортировать результаты по классу и затем по средней позиции в порядке возрастания.
with carPos as (
	select car, avg("position") average_position, count(*) race_count from results
	group by car
), carCount as (
	select "class", avg(average_position) average_position, count(*) c  from cars join carPos on "name" = carPos.car  group by "class" HAVING count(*) > 1
)
SELECT cars."name" car_name, 
    cars."class" car_class, 
    carPos.average_position, 
    carPos.race_count,
	classes.country car_country
from cars 
join carPos on carPos.car = cars."name"
join classes on classes."class" = cars."class" 
join carCount on cars."class" = carCount."class"
where carPos.average_position < carCount.average_position
ORDER BY cars."class", carPos.average_position;

--Определить, какие классы автомобилей имеют наибольшее количество автомобилей с низкой средней позицией (больше 3.0) и вывести информацию о каждом автомобиле из этих классов, включая его имя, класс, среднюю позицию, количество гонок, в которых он участвовал, страну производства класса автомобиля, а также общее количество гонок для каждого класса. Отсортировать результаты по количеству автомобилей с низкой средней позицией.
with carPos as (
	select car, avg("position") average_position, count(*) race_count from results
	group by car
),
carClass as (
	SELECT cars."class", count(cars."name") OVER (PARTITION BY cars."name") c
	from cars
	join carPos on carPos.car = cars."name"
	where carPos.average_position > 3
)
SELECT cars."name" car_name, cars."class" car_class, average_position, race_count, classes.country car_country, 
SUM(carPos.race_count) OVER (PARTITION BY cars.class) total_races, carClass.c low_position_count
from cars
join carPos on carPos.car = cars."name"
join classes ON classes."class" = cars."class"
join carClass on carClass."class" = cars."class"
where cars.class = carClass.class and carClass.c = (select max(c) from carClass)
order by carClass.c;