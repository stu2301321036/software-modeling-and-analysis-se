USE WoodCutterDW;
GO

/* ===== DimCustomer (от WoodCutterDB.dbo.[User] с роля Customer) ===== */
INSERT INTO DimCustomer (UserID, FullName, Email, PhoneNumber, RegistrationDate, IsActive)
SELECT 
    u.UserID,
    u.FullName,
    u.Email,
    u.PhoneNumber,
    u.RegistrationDate,
    u.IsActive
FROM WoodCutterDB.dbo.[User] u
JOIN WoodCutterDB.dbo.Role r ON u.RoleID = r.RoleID
WHERE r.RoleName = N'Customer';
GO

/* ===== DimShippingMethod (distinct от Shipping) ===== */
INSERT INTO DimShippingMethod (ShippingMethod)
SELECT DISTINCT s.ShippingMethod
FROM WoodCutterDB.dbo.Shipping s;
GO

/* ===== DimAddress (distinct от Shipping адресите) ===== */
INSERT INTO DimAddress (Country, City, StreetName, BuildingNumber, ApartmentNumber)
SELECT DISTINCT 
    s.Country,
    s.City,
    s.StreetName,
    s.BuildingNumber,
    s.ApartmentNumber
FROM WoodCutterDB.dbo.Shipping s;
GO

/* ===== DimOrderStatus (от OrderStatus) ===== */
INSERT INTO DimOrderStatus (StatusName)
SELECT StatusName
FROM WoodCutterDB.dbo.OrderStatus;
GO

/* ===== DimMaterial (от Material) ===== */
INSERT INTO DimMaterial (MaterialID, [Name], Color, [Type], MaterialPrice, InStockQuantity)
SELECT 
    m.MaterialID,
    m.Name,
    m.Color,
    m.[Type],
    m.MaterialPrice,
    m.InStockQuantity
FROM WoodCutterDB.dbo.Material m;
GO

/* ===== DimWorker (от Worker + User) ===== */
INSERT INTO DimWorker (WorkerID, FullName, Specialty, WorkingHoursPerDay, IsActive)
SELECT 
    w.WorkerID,
    u.FullName,
    w.Specialty,
    w.WorkingHoursPerDay,
    w.IsActive
FROM WoodCutterDB.dbo.Worker w
JOIN WoodCutterDB.dbo.[User] u ON w.UserID = u.UserID;
GO

/* ===== DimMachine (от Machine) ===== */
INSERT INTO DimMachine (MachineID, [Name], [Type], HourlyCost, MaxWorkloadPerDay)
SELECT 
    m.MachineID,
    m.Name,
    m.[Type],
    m.HourlyCost,
    m.MaxWorkloadPerDay
FROM WoodCutterDB.dbo.Machine m;
GO
