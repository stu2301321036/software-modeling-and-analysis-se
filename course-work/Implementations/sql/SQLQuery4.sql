USE WoodCutterDB;
GO

/* ========= 1. Role ========= */
INSERT INTO Role (RoleName) VALUES
(N'Admin'),
(N'Worker'),
(N'Customer');
GO

/* ======== 2. OrderStatus ======== */
INSERT INTO OrderStatus (StatusName) VALUES
(N'New'),
(N'In Progress'),
(N'Completed'),
(N'Shipped'),
(N'Cancelled');
GO

/* ======== 3. Material ======== */
INSERT INTO Material
    (Name, Type, Color, MaterialPrice, InStockQuantity,
     StandardWidth, StandardHeight, StandardThickness)
VALUES
(N'White Chipboard 18mm', N'Chipboard', N'White', 45.00, 200, 2800, 2070, 18),
(N'Oak MDF 18mm',         N'MDF',       N'Oak',   65.00, 150, 2800, 2070, 18),
(N'Black MDF 8mm',        N'MDF',       N'Black', 35.00, 100, 2800, 2070, 8);
GO

/* ======== 4. Machine ======== */
INSERT INTO Machine
    (Name, Type, HourlyCost, MaxWorkloadPerDay)
VALUES
(N'Cutting Saw 1',        N'Cutting',  30.00, 8),
(N'Edge Banding Machine', N'EdgeBand', 40.00, 8),
(N'CNC Drill 1',          N'Drilling', 50.00, 8);
GO

/* ======== 5. User ======== */
/* RoleID: 1=Admin, 2=Worker, 3=Customer */
INSERT INTO [User]
    (FullName, Email, Username, PhoneNumber,
     RegistrationDate, IsActive, RoleID)
VALUES
(N'Admin User',    N'admin@woodcutter.bg', N'admin',  N'+359111111111', GETDATE(), 1, 1),
(N'Ivan Ivanov',   N'ivan@woodcutter.bg',  N'ivan',   N'+359888111111', GETDATE(), 1, 2),
(N'Petar Petrov',  N'petar@woodcutter.bg', N'petar',  N'+359888222222', GETDATE(), 1, 2),
(N'Maria Customer',N'maria@customer.bg',   N'maria',  N'+359888333333', GETDATE(), 1, 3);
GO

/* ======== 6. Worker ======== */
/* приемаме, че Ivan = UserID 2, Petar = UserID 3 */
INSERT INTO Worker (UserID, Specialty, WorkingHoursPerDay, IsActive) VALUES
(2, N'Cutting / CNC', 8, 1),
(3, N'Edge banding',  8, 1);
GO

/* ======== 7. WorkerMachine (M:N) ======== */
/* WorkerID 1 и 2; MachineID 1,2,3 */
INSERT INTO WorkerMachine (WorkerID, MachineID) VALUES
(1, 1),
(1, 3),
(2, 2);
GO

/* ======== 8. Shipping ======== */
INSERT INTO Shipping
    (ShippingMethod, ShippingPrice, ShippingTime, ShippingDate,
     Country, City, StreetName, BuildingNumber, ApartmentNumber)
VALUES
(N'Courier - Economy', 25.00, 3, '2025-12-01',
 N'Bulgaria', N'Sofia',   N'Vitosha Blvd',    10, 5),
(N'Courier - Express', 40.00, 1, '2025-12-02',
 N'Bulgaria', N'Plovdiv', N'Central Square',  1,  NULL);
GO

/* ======== 9. Order ======== */
/* Maria Customer = UserID 4; ShippingID 1 и 2, статуси:
   1=New, 2=In Progress, 3=Completed, 4=Shipped */
INSERT INTO [Order]
    (UserID, ShippingID, StatusID, CreatedAt,
     EstimatedTime, TotalPrice, Details)
VALUES
(4, 1, 2, '2025-11-28', 5, 1200.00, N'Kitchen cabinets order'),
(4, 2, 1, '2025-12-03', 7,  800.00, N'Wardrobe and shelves');
GO

/* ======== 10. Plate ======== */
/* Материали 1..3, поръчки 1 и 2 */
INSERT INTO Plate
    (OrderID, MaterialID, Width, Height, Thickness,
     Quantity, EdgeBanding, DrillingDescription)
VALUES
(1, 1, 600,  720, 18, 10, N'Front edges', N'Hinge drilling 35mm'),
(1, 2, 450,  720, 18,  6, N'All edges',   N'Shelf pins 5mm'),
(2, 1, 500, 2000, 18,  2, N'Front edges', N'Handle holes'),
(2, 3, 300,  800,  8,  4, NULL,          N'Back panels');
GO

/* ======== 11. OrderWorker (M:N Order–Worker) ======== */
/* WorkerID 1 и 2, OrderID 1 и 2 */
INSERT INTO OrderWorker
    (OrderID, WorkerID, AssignedRole, AssignedHours)
VALUES
(1, 1, N'Cutting and CNC', 6),
(1, 2, N'Edge banding',    4),
(2, 1, N'Cutting',         3);
GO
