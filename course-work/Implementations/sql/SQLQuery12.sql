/* ============================================
   1. Създаване на DW база (ако я няма)
   ============================================ */
IF DB_ID('WoodCutterDW') IS NULL
BEGIN
    CREATE DATABASE WoodCutterDW;
END;
GO

USE WoodCutterDW;
GO

/* ============================================
   2. DIMENSIONS
   ============================================ */

-- DimCustomer
IF OBJECT_ID('dbo.DimCustomer', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimCustomer (
        CustomerKey     INT IDENTITY(1,1) PRIMARY KEY,
        UserID          INT      NOT NULL,  -- business key от OLTP
        FullName        NVARCHAR(200) NOT NULL,
        Email           NVARCHAR(200) NOT NULL,
        PhoneNumber     NVARCHAR(50)  NULL,
        RegistrationDate DATETIME     NOT NULL,
        IsActive        BIT          NOT NULL
    );
END;
GO

-- DimShippingMethod
IF OBJECT_ID('dbo.DimShippingMethod', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimShippingMethod (
        ShippingMethodKey INT IDENTITY(1,1) PRIMARY KEY,
        ShippingMethod    NVARCHAR(100) NOT NULL
    );
END;
GO

-- DimAddress
IF OBJECT_ID('dbo.DimAddress', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimAddress (
        AddressKey      INT IDENTITY(1,1) PRIMARY KEY,
        Country         NVARCHAR(100) NOT NULL,
        City            NVARCHAR(100) NOT NULL,
        StreetName      NVARCHAR(200) NOT NULL,
        BuildingNumber  INT           NOT NULL,
        ApartmentNumber INT           NULL
    );
END;
GO

-- DimOrderStatus
IF OBJECT_ID('dbo.DimOrderStatus', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimOrderStatus (
        OrderStatusKey INT IDENTITY(1,1) PRIMARY KEY,
        StatusName     NVARCHAR(100) NOT NULL
    );
END;
GO

-- DimDate
IF OBJECT_ID('dbo.DimDate', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimDate (
        DateKey       INT        PRIMARY KEY,  -- напр. 20251207
        CalendarDate  DATE       NOT NULL,
        [Day]         TINYINT    NOT NULL,
        [Month]       TINYINT    NOT NULL,
        [Year]        SMALLINT   NOT NULL,
        [Quarter]     TINYINT    NOT NULL,
        IsWeekend     BIT        NOT NULL
    );
END;
GO

-- DimMaterial
IF OBJECT_ID('dbo.DimMaterial', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimMaterial (
        MaterialKey      INT IDENTITY(1,1) PRIMARY KEY,
        MaterialID       INT           NOT NULL,  -- от OLTP Material
        [Name]           NVARCHAR(200) NOT NULL,
        Color            NVARCHAR(50)  NOT NULL,
        [Type]           NVARCHAR(100) NOT NULL,
        MaterialPrice    DECIMAL(18,2) NOT NULL,
        InStockQuantity  DECIMAL(18,2) NOT NULL
    );
END;
GO

-- DimWorker
IF OBJECT_ID('dbo.DimWorker', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimWorker (
        WorkerKey          INT IDENTITY(1,1) PRIMARY KEY,
        WorkerID           INT           NOT NULL,  -- от OLTP Worker
        FullName           NVARCHAR(200) NOT NULL,
        Specialty          NVARCHAR(200) NOT NULL,
        WorkingHoursPerDay INT           NOT NULL,
        IsActive           BIT           NOT NULL
    );
END;
GO

-- DimMachine
IF OBJECT_ID('dbo.DimMachine', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimMachine (
        MachineKey        INT IDENTITY(1,1) PRIMARY KEY,
        MachineID         INT           NOT NULL, -- от OLTP Machine
        [Name]            NVARCHAR(200) NOT NULL,
        [Type]            NVARCHAR(100) NOT NULL,
        HourlyCost        DECIMAL(18,2) NOT NULL,
        MaxWorkloadPerDay INT           NOT NULL
    );
END;
GO

/* ============================================
   3. FACT TABLES
   ============================================ */

-- FactOrder
IF OBJECT_ID('dbo.FactOrder', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FactOrder (
        OrderKey          INT IDENTITY(1,1) PRIMARY KEY,
        OrderID           INT NOT NULL,           -- business key от OLTP
        CustomerKey       INT NOT NULL,
        OrderDateKey      INT NOT NULL,
        ShippingDateKey   INT NULL,
        ShippingMethodKey INT NULL,
        AddressKey        INT NULL,
        OrderStatusKey    INT NOT NULL,

        TotalPrice        DECIMAL(18,2) NULL,
        MaterialCostTotal DECIMAL(18,2) NULL,
        LaborCostTotal    DECIMAL(18,2) NULL,
        MachineCostTotal  DECIMAL(18,2) NULL,
        ShippingPrice     DECIMAL(18,2) NULL,
        NumberOfPlates    INT           NULL,

        CONSTRAINT FK_FactOrder_Customer
            FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey),
        CONSTRAINT FK_FactOrder_OrderDate
            FOREIGN KEY (OrderDateKey) REFERENCES DimDate(DateKey),
        CONSTRAINT FK_FactOrder_ShippingDate
            FOREIGN KEY (ShippingDateKey) REFERENCES DimDate(DateKey),
        CONSTRAINT FK_FactOrder_ShippingMethod
            FOREIGN KEY (ShippingMethodKey) REFERENCES DimShippingMethod(ShippingMethodKey),
        CONSTRAINT FK_FactOrder_Address
            FOREIGN KEY (AddressKey) REFERENCES DimAddress(AddressKey),
        CONSTRAINT FK_FactOrder_OrderStatus
            FOREIGN KEY (OrderStatusKey) REFERENCES DimOrderStatus(OrderStatusKey)
    );
END;
GO

-- FactWorkerDailyPerformance
IF OBJECT_ID('dbo.FactWorkerDailyPerformance', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FactWorkerDailyPerformance (
        WorkerPerformanceKey INT IDENTITY(1,1) PRIMARY KEY,
        WorkerKey            INT NOT NULL,
        DateKey              INT NOT NULL,
        MachineKey           INT NULL,

        TotalLaborHours      DECIMAL(18,2) NOT NULL,
        OrdersWorkedOn       INT           NOT NULL,
        PlatesHandled        INT           NOT NULL,
        TotalLaborCost       DECIMAL(18,2) NOT NULL,
        TotalMachineHours    DECIMAL(18,2) NULL,
        TotalMachineCost     DECIMAL(18,2) NULL,
        LastUpdatedAt        DATETIME      NULL,

        CONSTRAINT FK_FactWorkerDailyPerformance_Worker
            FOREIGN KEY (WorkerKey) REFERENCES DimWorker(WorkerKey),
        CONSTRAINT FK_FactWorkerDailyPerformance_Date
            FOREIGN KEY (DateKey)   REFERENCES DimDate(DateKey),
        CONSTRAINT FK_FactWorkerDailyPerformance_Machine
            FOREIGN KEY (MachineKey) REFERENCES DimMachine(MachineKey)
    );
END;
GO

-- FactPlateProduction
IF OBJECT_ID('dbo.FactPlateProduction', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FactPlateProduction (
        PlateProductionKey INT IDENTITY(1,1) PRIMARY KEY,
        OrderID            INT NOT NULL,         -- от OLTP Order
        PlateID            INT NOT NULL,         -- от OLTP Plate
        MaterialKey        INT NOT NULL,
        WorkerKey          INT NULL,
        MachineKey         INT NULL,
        ProductionDateKey  INT NOT NULL,
        CustomerKey        INT NOT NULL,

        Quantity           INT           NOT NULL,
        Width              DECIMAL(18,2) NOT NULL,
        Height             DECIMAL(18,2) NOT NULL,
        Thickness          DECIMAL(18,2) NOT NULL,
        PlateArea          DECIMAL(18,2) NULL,
        MaterialCost       DECIMAL(18,2) NULL,
        LaborHours         DECIMAL(18,2) NULL,
        MachineHours       DECIMAL(18,2) NULL,
        LaborCost          DECIMAL(18,2) NULL,
        MachineCost        DECIMAL(18,2) NULL,

        CONSTRAINT FK_FactPlateProduction_Material
            FOREIGN KEY (MaterialKey)       REFERENCES DimMaterial(MaterialKey),
        CONSTRAINT FK_FactPlateProduction_Worker
            FOREIGN KEY (WorkerKey)         REFERENCES DimWorker(WorkerKey),
        CONSTRAINT FK_FactPlateProduction_Machine
            FOREIGN KEY (MachineKey)        REFERENCES DimMachine(MachineKey),
        CONSTRAINT FK_FactPlateProduction_ProductionDate
            FOREIGN KEY (ProductionDateKey) REFERENCES DimDate(DateKey),
        CONSTRAINT FK_FactPlateProduction_Customer
            FOREIGN KEY (CustomerKey)       REFERENCES DimCustomer(CustomerKey)
    );
END;
GO
