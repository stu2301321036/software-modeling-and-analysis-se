-- 1. Създаване на база данни (ако искаш друго име, смени тук)
CREATE DATABASE WoodCutterDB;
GO

/* ===========================
   TABLE: Role
   =========================== */
CREATE TABLE Role (
    RoleID      INT IDENTITY(1,1) PRIMARY KEY,
    RoleName    NVARCHAR(100) NOT NULL
);
GO

/* ===========================
   TABLE: [User]
   =========================== */
CREATE TABLE [User] (
    UserID           INT IDENTITY(1,1) PRIMARY KEY,
    FullName         NVARCHAR(200) NOT NULL,
    Email            NVARCHAR(200) NOT NULL,
    Username         NVARCHAR(100) NOT NULL,
    PhoneNumber      NVARCHAR(50) NULL,
    RegistrationDate DATETIME      NOT NULL DEFAULT(GETDATE()),
    IsActive         BIT           NOT NULL DEFAULT(1),
    RoleID           INT           NOT NULL
);
GO

-- Уникално потребителско име
CREATE UNIQUE INDEX UX_User_Username ON [User](Username);
GO

-- FK към Role
ALTER TABLE [User]
ADD CONSTRAINT FK_User_Role
    FOREIGN KEY (RoleID) REFERENCES Role(RoleID);
GO

/* ===========================
   TABLE: OrderStatus
   =========================== */
CREATE TABLE OrderStatus (
    OrderStatusID INT IDENTITY(1,1) PRIMARY KEY,
    StatusName    NVARCHAR(100) NOT NULL
);
GO

/* ===========================
   TABLE: Shipping
   =========================== */
CREATE TABLE Shipping (
    ShippingID       INT IDENTITY(1,1) PRIMARY KEY,
    ShippingMethod   NVARCHAR(100) NOT NULL,
    ShippingPrice    DECIMAL(18,2) NOT NULL,
    ShippingTime     INT           NOT NULL, -- напр. дни или часове
    ShippingDate     DATETIME      NOT NULL,
    Country          NVARCHAR(100) NOT NULL,
    City             NVARCHAR(100) NOT NULL,
    StreetName       NVARCHAR(200) NOT NULL,
    BuildingNumber   INT           NOT NULL,
    ApartmentNumber  INT           NULL
);
GO

/* ===========================
   TABLE: Material
   =========================== */
CREATE TABLE Material (
    MaterialID         INT IDENTITY(1,1) PRIMARY KEY,
    Name               NVARCHAR(200) NOT NULL,
    Type               NVARCHAR(100) NOT NULL,
    Color              NVARCHAR(50)  NOT NULL,
    MaterialPrice      DECIMAL(18,2) NOT NULL,
    InStockQuantity    DECIMAL(18,2) NOT NULL,
    StandardWidth      DECIMAL(18,2) NOT NULL,
    StandardHeight     DECIMAL(18,2) NOT NULL,
    StandardThickness  DECIMAL(18,2) NOT NULL
);
GO

/* ===========================
   TABLE: Machine
   =========================== */
CREATE TABLE Machine (
    MachineID        INT IDENTITY(1,1) PRIMARY KEY,
    Name             NVARCHAR(200) NOT NULL,
    Type             NVARCHAR(100) NOT NULL,
    HourlyCost       DECIMAL(18,2) NOT NULL,
    MaxWorkloadPerDay INT         NOT NULL
);
GO

/* ===========================
   TABLE: Worker
   =========================== */
CREATE TABLE Worker (
    WorkerID           INT IDENTITY(1,1) PRIMARY KEY,
    UserID             INT           NOT NULL,
    Specialty          NVARCHAR(200) NOT NULL,
    WorkingHoursPerDay INT           NOT NULL,
    IsActive           BIT           NOT NULL DEFAULT(1)
);
GO

-- Връзка 1:1 Worker - User (UserID да е уникален в Worker)
CREATE UNIQUE INDEX UX_Worker_UserID ON Worker(UserID);
GO

ALTER TABLE Worker
ADD CONSTRAINT FK_Worker_User
    FOREIGN KEY (UserID) REFERENCES [User](UserID);
GO

/* ===========================
   TABLE: WorkerMachine (M:N)
   =========================== */
CREATE TABLE WorkerMachine (
    WorkerID  INT NOT NULL,
    MachineID INT NOT NULL,
    PRIMARY KEY (WorkerID, MachineID)
);
GO

ALTER TABLE WorkerMachine
ADD CONSTRAINT FK_WorkerMachine_Worker
    FOREIGN KEY (WorkerID) REFERENCES Worker(WorkerID);

ALTER TABLE WorkerMachine
ADD CONSTRAINT FK_WorkerMachine_Machine
    FOREIGN KEY (MachineID) REFERENCES Machine(MachineID);
GO

/* ===========================
   TABLE: [Order]
   =========================== */
CREATE TABLE [Order] (
    OrderID       INT IDENTITY(1,1) PRIMARY KEY,
    UserID        INT           NOT NULL,
    ShippingID    INT           NULL,  -- може да е NULL ако още няма доставка
    StatusID      INT           NOT NULL,
    CreatedAt     DATETIME      NOT NULL DEFAULT(GETDATE()),
    EstimatedTime INT           NOT NULL,      -- дни/часове до завършване
    TotalPrice    DECIMAL(18,2) NOT NULL,
    Details       NVARCHAR(MAX) NULL
);
GO

ALTER TABLE [Order]
ADD CONSTRAINT FK_Order_User
    FOREIGN KEY (UserID) REFERENCES [User](UserID);

ALTER TABLE [Order]
ADD CONSTRAINT FK_Order_Shipping
    FOREIGN KEY (ShippingID) REFERENCES Shipping(ShippingID);

ALTER TABLE [Order]
ADD CONSTRAINT FK_Order_Status
    FOREIGN KEY (StatusID) REFERENCES OrderStatus(OrderStatusID);
GO

/* ===========================
   TABLE: Plate
   =========================== */
CREATE TABLE Plate (
    PlateID            INT IDENTITY(1,1) PRIMARY KEY,
    OrderID            INT           NOT NULL,
    MaterialID         INT           NOT NULL,
    Width              DECIMAL(18,2) NOT NULL,
    Height             DECIMAL(18,2) NOT NULL,
    Thickness          DECIMAL(18,2) NOT NULL,
    Quantity           INT           NOT NULL,
    EdgeBanding        NVARCHAR(200) NULL, -- или BIT ако е да/не
    DrillingDescription NVARCHAR(MAX) NULL
);
GO

ALTER TABLE Plate
ADD CONSTRAINT FK_Plate_Order
    FOREIGN KEY (OrderID) REFERENCES [Order](OrderID);

ALTER TABLE Plate
ADD CONSTRAINT FK_Plate_Material
    FOREIGN KEY (MaterialID) REFERENCES Material(MaterialID);
GO

/* ===========================
   TABLE: OrderWorker (M:N Order–Worker)
   =========================== */
CREATE TABLE OrderWorker (
    OrderID       INT NOT NULL,
    WorkerID      INT NOT NULL,
    AssignedRole  NVARCHAR(200) NULL,
    AssignedHours INT           NOT NULL,
    PRIMARY KEY (OrderID, WorkerID)
);
GO

ALTER TABLE OrderWorker
ADD CONSTRAINT FK_OrderWorker_Order
    FOREIGN KEY (OrderID) REFERENCES [Order](OrderID);

ALTER TABLE OrderWorker
ADD CONSTRAINT FK_OrderWorker_Worker
    FOREIGN KEY (WorkerID) REFERENCES Worker(WorkerID);
GO
