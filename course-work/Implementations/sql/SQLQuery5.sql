CREATE FUNCTION dbo.fn_CalculateOrderMaterialCost (@OrderID INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Total DECIMAL(18,2);

    SELECT @Total = ISNULL(SUM(p.Quantity * m.MaterialPrice), 0)
    FROM Plate p
    JOIN Material m ON p.MaterialID = m.MaterialID
    WHERE p.OrderID = @OrderID;

    RETURN @Total;
END;
GO
