/* ===== DimDate (по реални дати от Order и Shipping) ===== */
INSERT INTO DimDate (DateKey, CalendarDate, [Day], [Month], [Year], [Quarter], IsWeekend)
SELECT DISTINCT
    CONVERT(INT, FORMAT(d.CalendarDate, 'yyyyMMdd')) AS DateKey,
    d.CalendarDate,
    DATEPART(DAY,   d.CalendarDate) AS [Day],
    DATEPART(MONTH, d.CalendarDate) AS [Month],
    DATEPART(YEAR,  d.CalendarDate) AS [Year],
    DATEPART(QUARTER, d.CalendarDate) AS [Quarter],
    CASE 
        WHEN DATEPART(WEEKDAY, d.CalendarDate) IN (1, 7) THEN 1  -- събота/неделя (зависи от @@DATEFIRST, но за проекта е ОК)
        ELSE 0 
    END AS IsWeekend
FROM (
    SELECT DISTINCT CAST(o.CreatedAt    AS DATE) AS CalendarDate 
    FROM WoodCutterDB.dbo.[Order] o
    UNION
    SELECT DISTINCT CAST(s.ShippingDate AS DATE) 
    FROM WoodCutterDB.dbo.Shipping s
) d;
GO
