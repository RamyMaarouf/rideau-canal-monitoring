# Rideau Canal Ice Monitoring System (CST8916 Final Project)

## Project Title and Description
The **Rideau Canal Ice Monitoring System** is an end-to-end IoT solution designed to ingest real-time environmental data, process it in the cloud to determine ice safety status, and present the results on a live, publicly accessible web dashboard. It automates the critical safety assessment of the canal's ice surface.

---

## Student Information
* **Name:** Ramy Maarouf
* **Student ID:** 041-269-337

---

## Scenario Overview

### Problem Statement
The safety of skating and recreational activities on the Rideau Canal is critically dependent on consistent ice thickness and temperature. Relying on manual, intermittent measurements is prone to delay and error. The goal is to create a reliable, scalable, and real-time monitoring system to provide continuous safety assessments to the public.

### System Objectives
1.  **Ingest Data:** Securely receive simulated sensor data from multiple locations using Azure IoT Hub.
2.  **Process Data:** Aggregate sensor readings over a time window and apply business logic (ice safety rules) using Azure Stream Analytics.
3.  **Store Data:** Persist processed, aggregated, and high-value data in a scalable NoSQL database (Cosmos DB).
4.  **Visualize Data:** Deploy a Node.js web application to display the real-time status and historical trends.

---

## System Architecture

### Architecture Diagram
The full architecture diagram is available in the `architecture/` folder: `architecture-diagram.png`.

### Data Flow Explanation
The system operates on a "hot path" data flow:
1.  **Production:** Python simulators generate and send JSON telemetry to Azure IoT Hub.
2.  **Ingestion:** IoT Hub acts as the secure, single entry point for all device data.
3.  **Processing:** Stream Analytics consumes the raw data, applies a **5-minute Tumbling Window** aggregation, and computes the `SafetyStatus`.
4.  **Storage:** The processed records are stored as JSON documents in Azure Cosmos DB.
5.  **Consumption:** The Node.js App Service queries the latest and historical records from Cosmos DB to serve the dynamic dashboard to users.

### Azure Services Used
* **Azure IoT Hub:** Cloud gateway for secure device connectivity and message routing.
* **Azure Stream Analytics (ASA):** Real-time data processing, aggregation, and rule-based decision-making.
* **Azure Cosmos DB (SQL API):** High-throughput, low-latency persistence layer for aggregated data.
* **Azure App Service (Linux):** Hosting the Node.js Express application for the web dashboard.
* **Blob Storage (Implicit):** Used by ASA for potential error output, and for storing CI/CD artifacts.

---

## Implementation Overview

### IoT Sensor Simulation ([Link to Sensor Simulation Repository])
* A Python script simulates three devices (`dows-lake`, `fifth-avenue`, `nac`) sending telemetry.
* Uses the **Azure IoT SDK** for secure, device-level authentication.

### Azure IoT Hub Configuration
* Three distinct devices were registered and their connection strings secured.
* The default Event Hub endpoint was configured as the input for the Stream Analytics job.

### Stream Analytics Job (ASA)
The ASA job performs the aggregation and business logic.

#### ASA Query (`query.sql`)
```sql
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
