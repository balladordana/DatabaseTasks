--Найдите производителей (maker) и модели всех мотоциклов, которые имеют мощность более 150 лошадиных сил, стоят менее 20 тысяч долларов и являются спортивными (тип Sport). Также отсортируйте результаты по мощности в порядке убывания.
select maker, v.model 
from Vehicle v join Motorcycle m on v.model = m.model
where v.model = m.model and horsepower > 150 and price < 20000 and m.type = 'Sport'
order by horsepower desc;

--Найти информацию о производителях и моделях различных типов транспортных средств (автомобили, мотоциклы и велосипеды), которые соответствуют заданным критериям.
select maker, v.model,
case 
	when v.type = 'Motorcycle' then motorcycle.horsepower
	when v.type = 'Car' then car.horsepower
	else NULL
end as horsepower, 
case 
	when v.type = 'Motorcycle' then motorcycle.engine_capacity
	when v.type = 'Car' then car.engine_capacity
	else NULL
end as engine_capacity, 
v.type as vehicle_type
from Vehicle v 
full join motorcycle ON motorcycle.model = v.model
full join bicycle ON bicycle.model = v.model 
full join car ON car.model = v.model
where (car.horsepower > 150 and car.engine_capacity < 3 and car.price < 35000)
or (motorcycle.horsepower > 150 and motorcycle.engine_capacity < 1.5 and motorcycle.price < 20000)
or (bicycle.gear_count > 18 and bicycle.price < 4000)
order by horsepower desc nulls last;