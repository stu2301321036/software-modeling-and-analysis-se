/* ===== FactWorkerDailyPerformance ===== */
/* приемаме фиксирана почасова ставка 20.00 за пример */
DECLARE @HourlyRate DECIMAL(18,2) = 20.00;

INSERT INTO FactWorkerDailyPerformance (
    WorkerKey,
    DateKey,
    MachineKey,
    TotalLaborHours,
    OrdersWorkedOn,
    PlatesHandled,
    TotalLaborCost,
    TotalMachineHours,
    TotalMachineCost,
    LastUpdatedAt
)
SELECT
    dw.WorkerKey,
    dd.DateKey,
    NULL AS MachineKey,
    SUM(ow.AssignedHours) AS TotalLaborHours,
    COUNT(DISTINCT ow.OrderID) AS OrdersWorkedOn,
    COUNT(p.PlateID) AS PlatesHandled,
    SUM(ow.AssignedHours) * @HourlyRate AS TotalLaborCost,
    NULL AS TotalMachineHours,
    NULL AS TotalMachineCost,
    GETDATE() AS LastUpdatedAt
FROM WoodCutterDB.dbo.OrderWorker ow
JOIN WoodCutterDB.dbo.Worker w ON ow.WorkerID = w.WorkerID
JOIN DimWorker dw ON dw.WorkerID = w.WorkerID
JOIN WoodCutterDB.dbo.[Order] o ON ow.OrderID = o.OrderID
JOIN DimDate dd ON dd.CalendarDate = CAST(o.CreatedAt AS DATE)
LEFT JOIN WoodCutterDB.dbo.Plate p ON p.OrderID = o.OrderID
GROUP BY
    dw.WorkerKey,
    dd.DateKey;
GO
