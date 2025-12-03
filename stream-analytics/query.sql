
SELECT
    System.Timestamp() AS WindowEndTime,
    'SensorAggregations' AS documentId, -- Required for Cosmos DB
    Location,
    AVG(IceThickness) AS AvgIceThickness_cm,
    AVG(SurfaceTemperature) AS AvgSurfaceTemp_C,
    CASE
        WHEN AVG(IceThickness) >= 30.0 THEN 'Safe'
        WHEN AVG(IceThickness) >= 20.0 AND AVG(IceThickness) < 30.0 THEN 'Caution'
        ELSE 'Unsafe'
    END AS SafetyStatus
INTO
    [CosmosDB-Output]
FROM
    [IoTHub-Input]
GROUP BY
    Location,
    TUMBLINGWINDOW(mi, 5) -- Aggregates data every 5 minutes