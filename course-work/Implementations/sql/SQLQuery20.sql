USE WoodCutterDW;
GO

-- за всеки случай чистим FactOrder (ако има нещо)
DELETE FROM FactOrder;
GO

/* ===== Попълване на FactOrder с правилно извикване на функцията ===== */
INSERT INTO FactOrder (
    OrderID,
    CustomerKey,
    OrderDateKey,
    ShippingDateKey,
    ShippingMethodKey,
    AddressKey,
    OrderStatusKey,
    TotalPrice,
    MaterialCostTotal,
    LaborCostTotal,
    MachineCostTotal,
    ShippingPrice,
    NumberOfPlates
)
SELECT
    o.OrderID,
    dc.CustomerKey,
    ddOrder.DateKey,
    ddShip.DateKey,
    dsm.ShippingMethodKey,
    da.AddressKey,
    dos.OrderStatusKey,
    o.TotalPrice,
    WoodCutterDB.dbo.fn_CalculateOrderMaterialCost(o.OrderID) AS MaterialCostTotal,
    NULL AS LaborCostTotal,   -- може да попълниш по-късно
    NULL AS MachineCostTotal, -- може да попълниш по-късно
    ISNULL(s.ShippingPrice, 0) AS ShippingPrice,
    COUNT(p.PlateID) AS NumberOfPlates
FROM WoodCutterDB.dbo.[Order] o
JOIN WoodCutterDB.dbo.[User] u ON o.UserID = u.UserID
JOIN DimCustomer dc ON dc.UserID = u.UserID
JOIN DimDate ddOrder ON ddOrder.CalendarDate = CAST(o.CreatedAt AS DATE)
LEFT JOIN WoodCutterDB.dbo.Shipping s ON o.ShippingID = s.ShippingID
LEFT JOIN DimDate ddShip ON ddShip.CalendarDate = CAST(s.ShippingDate AS DATE)
LEFT JOIN DimShippingMethod dsm ON dsm.ShippingMethod = s.ShippingMethod
LEFT JOIN DimAddress da ON
    da.Country        = s.Country
    AND da.City       = s.City
    AND da.StreetName = s.StreetName
    AND da.BuildingNumber  = s.BuildingNumber
    AND (
        (da.ApartmentNumber IS NULL AND s.ApartmentNumber IS NULL)
        OR da.ApartmentNumber = s.ApartmentNumber
    )
JOIN WoodCutterDB.dbo.OrderStatus os ON os.OrderStatusID = o.StatusID
JOIN DimOrderStatus dos ON dos.StatusName = os.StatusName
LEFT JOIN WoodCutterDB.dbo.Plate p ON p.OrderID = o.OrderID
GROUP BY
    o.OrderID,
    dc.CustomerKey,
    ddOrder.DateKey,
    ddShip.DateKey,
    dsm.ShippingMethodKey,
    da.AddressKey,
    dos.OrderStatusKey,
    o.TotalPrice,
    s.ShippingPrice;
GO
