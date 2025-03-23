# README

## Описание проекта
Этот проект представляет собой учебное задание по работе с базами данных, в котором необходимо создать, наполнить и манипулировать данными с использованием SQL. В рамках проекта задействованы четыре различные базы данных: транспортные средства, автомобильные гонки, бронирование отелей и структура организации. Задания включают в себя этапы создания таблиц, наполнения их тестовыми данными и выполнения различных SQL-запросов.

## Цели и задачи
- Создание и наполнение таблиц тестовыми данными.
- Осуществление манипуляций с данными с использованием SQL-запросов.
- Работа с различными аспектами управления базами данных, включая установление связей между таблицами.

## Структура базы данных

- **Departments**: Хранит информацию об отделах.
- **Roles**: Хранит данные о ролях сотрудников.
- **Employees**: Основная таблица сотрудников, связывающая их с отделами, ролями и менеджерами.
- **Projects**: Описывает проекты, которые выполняются внутри компании.
- **Tasks**: Задачи, назначенные сотрудникам в рамках проектов.
- **Car**: Хранит данные о транспортных средствах.
- **Vehicle**: Представляет дополнительную информацию о транспортных средствах.
- **Booking**: Управляет процессом бронирования отелей.
- **Races**: Хранит информацию об автомобильных гонках.

## Основные функции
- Создание и управление таблицами в реляционной базе данных.
- Добавление, удаление и обновление данных.
- Выполнение аналитических SQL-запросов.
- Определение связей между таблицами с использованием `REFERENCES`.
- Проведение анализа данных в рамках заданий.

## Инструкции по запуску

1. Установите PostgreSQL (если он еще не установлен).
2. Создайте новую базу данных:
   ```sql
   CREATE DATABASE project_db;
   ```
3. Подключитесь к базе данных:
   ```bash
   psql -U your_user -d project_db
   ```
4. Создайте таблицы, используя предоставленный SQL-код в файле `DDL.sql`.
5. Заполните таблицы тестовыми данными из файла `DML.sql`.
6. Выполните запросы для анализа данных.
