WITH RECURSIVE SubordinateHierarchy AS (
    SELECT 
        ManagerID,
        EmployeeID,
        1 AS level
    FROM 
        Employees
    WHERE 
        ManagerID IS NOT NULL
    
    UNION ALL
    
    SELECT 
        sh.ManagerID,
        e.EmployeeID,
        sh.level + 1
    FROM 
        SubordinateHierarchy sh
        INNER JOIN Employees e ON sh.EmployeeID = e.ManagerID
),
SubordinateCount AS (
    SELECT 
        ManagerID,
        COUNT(DISTINCT EmployeeID) AS TotalSubordinates
    FROM 
        SubordinateHierarchy
    GROUP BY 
        ManagerID
),
ManagerEmployees AS (
    SELECT 
        EmployeeID,
        Name,
        ManagerID,
        DepartmentID,
        RoleID
    FROM 
        Employees
    WHERE 
        RoleID = (SELECT RoleID FROM Roles WHERE RoleName = 'Менеджер')
),
EmployeeProjects AS (
    SELECT 
        e.EmployeeID,
        STRING_AGG(DISTINCT p.ProjectName, ', ' ORDER BY p.ProjectName) AS ProjectNames
    FROM 
        ManagerEmployees e
        LEFT JOIN Tasks t ON e.EmployeeID = t.AssignedTo
        LEFT JOIN Projects p ON t.ProjectID = p.ProjectID
    GROUP BY 
        e.EmployeeID
),
EmployeeTasks AS (
    SELECT 
        e.EmployeeID,
        STRING_AGG(DISTINCT t.TaskName, ', ' ORDER BY t.TaskName) AS TaskNames
    FROM 
        ManagerEmployees e
        LEFT JOIN Tasks t ON e.EmployeeID = t.AssignedTo
    GROUP BY 
        e.EmployeeID
)
SELECT 
    e.EmployeeID,
    e.Name AS EmployeeName,
    e.ManagerID,
    d.DepartmentName,
    r.RoleName,
    ep.ProjectNames,
    et.TaskNames,
    sc.TotalSubordinates
FROM 
    ManagerEmployees e
    INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
    INNER JOIN Roles r ON e.RoleID = r.RoleID
    LEFT JOIN EmployeeProjects ep ON e.EmployeeID = ep.EmployeeID
    LEFT JOIN EmployeeTasks et ON e.EmployeeID = et.EmployeeID
    INNER JOIN SubordinateCount sc ON e.EmployeeID = sc.ManagerID
WHERE 
    sc.TotalSubordinates > 0
ORDER BY 
    e.Name;