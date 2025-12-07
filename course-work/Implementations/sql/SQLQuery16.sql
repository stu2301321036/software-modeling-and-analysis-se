/* ===== FactPlateProduction ===== */
INSERT INTO FactPlateProduction (
    OrderID,
    PlateID,
    MaterialKey,
    WorkerKey,
    MachineKey,
    ProductionDateKey,
    CustomerKey,
    Quantity,
    Width,
    Height,
    Thickness,
    PlateArea,
    MaterialCost,
    LaborHours,
    MachineHours,
    LaborCost,
    MachineCost
)
SELECT
    p.OrderID,
    p.PlateID,
    dm.MaterialKey,
    NULL AS WorkerKey,   -- може да ги вържеш с OrderWorker при желание
    NULL AS MachineKey,  -- по-просто за момента
    dd.DateKey AS ProductionDateKey,   -- приемаме, че дата на производство = CreatedAt на Order
    dc.CustomerKey,
    p.Quantity,
    p.Width,
    p.Height,
    p.Thickness,
    (p.Width * p.Height) AS PlateArea,
    p.Quantity * m.MaterialPrice AS MaterialCost,
    NULL AS LaborHours,
    NULL AS MachineHours,
    NULL AS LaborCost,
    NULL AS MachineCost
FROM WoodCutterDB.dbo.Plate p
JOIN WoodCutterDB.dbo.Material m ON p.MaterialID = m.MaterialID
JOIN DimMaterial dm ON dm.MaterialID = m.MaterialID
JOIN WoodCutterDB.dbo.[Order] o ON p.OrderID = o.OrderID
JOIN WoodCutterDB.dbo.[User] u ON o.UserID = u.UserID
JOIN DimCustomer dc ON dc.UserID = u.UserID
JOIN DimDate dd ON dd.CalendarDate = CAST(o.CreatedAt AS DATE);
GO
