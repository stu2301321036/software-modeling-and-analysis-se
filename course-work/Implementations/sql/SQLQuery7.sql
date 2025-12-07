CREATE PROCEDURE dbo.sp_UpdateOrderTotalPrice
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaterialCost  DECIMAL(18,2);
    DECLARE @ShippingPrice DECIMAL(18,2);

    -- 1) Материален разход
    SELECT @MaterialCost = dbo.fn_CalculateOrderMaterialCost(@OrderID);

    -- 2) Цена на доставка (може да е NULL)
    SELECT @ShippingPrice = ISNULL(s.ShippingPrice, 0)
    FROM [Order] o
    LEFT JOIN Shipping s ON o.ShippingID = s.ShippingID
    WHERE o.OrderID = @OrderID;

    -- 3) Обновяваме TotalPrice
    UPDATE [Order]
    SET TotalPrice = @MaterialCost + @ShippingPrice
    WHERE OrderID = @OrderID;
END;
GO
