CREATE TRIGGER trg_Plate_UpdateOrderTotalPrice
ON Plate
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Събираме всички засегнати OrderID от inserted и deleted
    DECLARE @OrderIDs TABLE (OrderID INT PRIMARY KEY);

    INSERT INTO @OrderIDs (OrderID)
    SELECT DISTINCT OrderID FROM inserted WHERE OrderID IS NOT NULL
    UNION
    SELECT DISTINCT OrderID FROM deleted  WHERE OrderID IS NOT NULL;

    -- Ако няма засегнати поръчки, излизаме
    IF NOT EXISTS (SELECT 1 FROM @OrderIDs)
        RETURN;

    -- Обновяваме TotalPrice за всички засегнати поръчки наведнъж
    UPDATE o
    SET o.TotalPrice = dbo.fn_CalculateOrderMaterialCost(o.OrderID)
                      + ISNULL(s.ShippingPrice, 0)
    FROM [Order] o
    JOIN @OrderIDs ids ON ids.OrderID = o.OrderID
    LEFT JOIN Shipping s ON o.ShippingID = s.ShippingID;
END;
GO
