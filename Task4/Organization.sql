--Найти всех сотрудников, подчиняющихся Ивану Иванову (с EmployeeID = 1), включая их подчиненных и подчиненных подчиненных
WITH RECURSIVE Subordinates AS (
    -- Базовый уровень: выбираем непосредственных подчиненных Ивана Иванова (EmployeeID = 1)
    SELECT 
        e.EmployeeID, 
        e.Name, 
        e.ManagerID, 
        e.DepartmentID, 
        e.RoleID
    FROM Employees e
    WHERE e.ManagerID = 1
    UNION ALL
    -- Рекурсивный запрос: выбираем подчиненных подчиненных и так далее
    SELECT 
        e.EmployeeID, 
        e.Name, 
        e.ManagerID, 
        e.DepartmentID, 
        e.RoleID
    FROM Employees e
    JOIN Subordinates s ON e.ManagerID = s.EmployeeID
)
SELECT 
    s.EmployeeID, 
    s.Name, 
    s.ManagerID, 
    d.DepartmentName, 
    r.RoleName,
    -- Получаем список проектов через STRING_AGG
    COALESCE(
        STRING_AGG(DISTINCT p.ProjectName, ', '), NULL
    ) AS ProjectNames,
    -- Получаем список задач через STRING_AGG
    COALESCE(
        STRING_AGG(DISTINCT t.TaskName, ', '), NULL
    ) AS TaskNames
FROM Subordinates s
LEFT JOIN Departments d ON s.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON s.RoleID = r.RoleID
LEFT JOIN Projects p ON p.DepartmentID = s.DepartmentID
LEFT JOIN Tasks t ON t.AssignedTo = s.EmployeeID
GROUP BY 
    s.EmployeeID, s.Name, s.ManagerID, 
    d.DepartmentName, r.RoleName
ORDER BY s.Name;

--Найти всех сотрудников, подчиняющихся Ивану Иванову с EmployeeID = 1, включая их подчиненных и подчиненных подчиненных c выводом количества задач и подчиненных
WITH RECURSIVE Subordinates AS (
    -- Базовый уровень: выбираем непосредственных подчиненных Ивана Иванова (EmployeeID = 1)
    SELECT 
        e.EmployeeID, 
        e.Name, 
        e.ManagerID, 
        e.DepartmentID, 
        e.RoleID
    FROM Employees e
    WHERE e.ManagerID = 1
    UNION ALL
    -- Рекурсивный запрос: выбираем подчиненных подчиненных и так далее
    SELECT 
        e.EmployeeID, 
        e.Name, 
        e.ManagerID, 
        e.DepartmentID, 
        e.RoleID
    FROM Employees e
    JOIN Subordinates s ON e.ManagerID = s.EmployeeID
),
DirectReports AS (
    -- Подсчитываем количество непосредственных подчиненных у каждого сотрудника
    SELECT 
        ManagerID, 
        COUNT(*) AS DirectSubordinates
    FROM Employees
    WHERE ManagerID IS NOT NULL
    GROUP BY ManagerID
)
SELECT 
    s.EmployeeID, 
    s.Name, 
    s.ManagerID, 
    d.DepartmentName, 
    r.RoleName,
    -- Список уникальных проектов, в которых участвует сотрудник
    COALESCE(STRING_AGG(DISTINCT p.ProjectName, ', '), NULL) AS ProjectNames,
    -- Список уникальных задач, назначенных сотруднику
    COALESCE(STRING_AGG(DISTINCT t.TaskName, ', '), NULL) AS TaskNames,
    -- Количество назначенных задач
    COUNT(DISTINCT t.TaskID) AS TotalTasks,
    -- Количество подчиненных (прямых)
    COALESCE(dr.DirectSubordinates, 0) AS TotalSubordinates
FROM Subordinates s
LEFT JOIN Departments d ON s.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON s.RoleID = r.RoleID
LEFT JOIN Projects p ON p.DepartmentID = s.DepartmentID
LEFT JOIN Tasks t ON t.AssignedTo = s.EmployeeID
LEFT JOIN DirectReports dr ON s.EmployeeID = dr.ManagerID
GROUP BY 
    s.EmployeeID, s.Name, s.ManagerID, 
    d.DepartmentName, r.RoleName, dr.DirectSubordinates
ORDER BY s.Name;

--Найти всех сотрудников, которые занимают роль менеджера и имеют подчиненных (то есть число подчиненных больше 0)
WITH RECURSIVE Subordinates AS (
    -- Базовый уровень: выбираем непосредственных подчиненных Ивана Иванова (EmployeeID = 1)
    SELECT 
        e.EmployeeID, 
        e.Name, 
        e.ManagerID, 
        e.DepartmentID, 
        e.RoleID
    FROM Employees e
    WHERE e.ManagerID = 1
    UNION ALL
    -- Рекурсивный запрос: выбираем подчиненных подчиненных и так далее
    SELECT 
        e.EmployeeID, 
        e.Name, 
        e.ManagerID, 
        e.DepartmentID, 
        e.RoleID
    FROM Employees e
    JOIN Subordinates s ON e.ManagerID = s.EmployeeID
),
ManagerSubordinates AS (
    -- Подсчет общего количества подчиненных для каждого менеджера
    SELECT 
        ManagerID, 
        COUNT(*) AS TotalSubordinates
    FROM Employees
    WHERE ManagerID IS NOT NULL
    GROUP BY ManagerID
)
SELECT 
    e.EmployeeID, 
    e.Name, 
    e.ManagerID, 
    d.DepartmentName, 
    r.RoleName,
    -- Список уникальных проектов, в которых участвует сотрудник
    COALESCE(STRING_AGG(DISTINCT p.ProjectName, ', '), NULL) AS ProjectNames	,
    -- Список уникальных задач, назначенных сотруднику
    COALESCE(STRING_AGG(DISTINCT t.TaskName, ', '), NULL) AS TaskNames,
    -- Количество подчиненных (включая всех уровней)
    ms.TotalSubordinates
FROM Employees e
JOIN ManagerSubordinates ms ON e.EmployeeID = ms.ManagerID
LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON e.RoleID = r.RoleID
LEFT JOIN Projects p ON p.DepartmentID = e.DepartmentID
LEFT JOIN Tasks t ON t.AssignedTo = e.EmployeeID
where r.RoleName = 'Менеджер'
GROUP BY 
    e.EmployeeID, e.Name, e.ManagerID, 
    d.DepartmentName, r.RoleName, ms.TotalSubordinates
ORDER BY ms.TotalSubordinates DESC;
