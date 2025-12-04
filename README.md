# Rideau Canal Ice Monitoring System (CST8916 Final Project)

## Project Title and Description
The **Rideau Canal Ice Monitoring System** is an end-to-end IoT solution designed to ingest real-time environmental data, process it in the cloud to determine ice safety status, and present the results on a live, publicly accessible web dashboard. It automates the critical safety assessment of the canal's ice surface.

---

## Student Information
* **Name:** Ramy Maarouf
* **Student ID:** 041269337

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

### ASA Query (query.sql)
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
```
### Cosmos DB Setup
* A database (RideauCanalDB) and container (SensorAggregations) were created.
* The Partition Key was set to /documentId (value 'SensorAggregations') for efficient query routing.

### Web Dashboard
* A Node.js/Express server provides a simple API for the frontend.
* The frontend uses vanilla JavaScript to fetch data from the API and render charts.
* For details, see the [https://github.com/RamyMaarouf/rideau-canal-dashboard.git].

### Azure App Service Deployment
* Deployed to RCS-WebApp1 using GitHub Actions for continuous integration/deployment.
* Environment variables (COSMOS_ENDPOINT, COSMOS_KEY, COSMOS_DATABASE, COSMOS_CONTAINER, PORT) were configured in App Service Settings.

---

## Repository Links
* https://github.com/RamyMaarouf/rideau-canal-sensor-simulation.git
* https://github.com/RamyMaarouf/rideau-canal-dashboard.git
* https://github.com/RamyMaarouf/rideau-canal-monitoring.git

---

## Video Demonstration
* [https://youtu.be/d8LitDA-Hw8]

---

## Setup Instructions

### Prerequisites
* Azure Subscription
* Python 3.x
* Node.js (v20+)
* Git

### High-Level Setup Steps
* Azure Resource Creation: Deploy IoT Hub, Stream Analytics, Cosmos DB, and App Service.
* Simulation Setup: Configure the Python simulator with the IoT Device Connection String.
* ASA Configuration: Deploy the Stream Analytics query provided above, linking IoT Hub (Input) and Cosmos DB (Output).
* Dashboard Deployment: Deploy the Node.js application to Azure App Service via GitHub Actions.
* App Settings: Securely configure Cosmos DB credentials as App Service settings.

---

## Results and Analysis

### Sample Outputs and Screenshots
All validation screenshots are located in the screenshots/ folder:
* 08-dashboard-azure.png: Final working web dashboard on Azure.
* 05-cosmos-db-data.png: Shows the structured, aggregated data in Cosmos DB.

The final deployed dashboard successfully displays:
* Real-time Safety Status (Safe, Caution, Unsafe) for each location.
* Historical Trends (Ice Thickness and Surface Temperature) over the last hour.

### Data Analysis
The ASA query successfully transformed high-volume, granular IoT data into a low-volume, high-value dataset ready for quick querying by the dashboard. The safety status reflects the defined business rules accurately.

### System Performance Observations
* Latency: End-to-end latency (sensor → dashboard) is consistently low (under 30 seconds), enabling near real-time decision-making.
* Scalability: The architecture utilizing IoT Hub and Cosmos DB provides robust scalability to handle hundreds of thousands of devices and high request throughput if the system were expanded.

---

## Challenges and Solutions

### Technical challenges faced / Solution Implemented
* 504 Gateway Timeout / Corrected the App Service Configuration setting for PORT from PORT1 to the standard PORT.
* Application Crash (App Error) / Updated the App Service Startup Command from its default to the correct node server.js command.
* Cosmos DB Authentication / Ensured the Primary Read-Write Key was used and correctly passed as an Application Setting in the App Service.

---

## AI Tools Disclosure 
* Tools Used: Gemini (Google's AI model) was used for generating Python code and Node.js code, suggesting the correct ASA query syntax, and guiding the troubleshooting process for the Azure App Service deployment issues (e.g., identifying the need to change PORT and the Startup Command).
* What was AI-Generated vs Your Work:
    * AI-Generated: All final Python code, all Node.js code, troubleshooting steps, and the comprehensive validation of the end-to-end system.
    * Student's Work: The structural layout, format, key technical points, the configuration of all Azure resources, generating structured Markdown templates, and structuring the architecture.

---

## References
* Libraries: Node.js, Express.js, azure-iot-device, python-dotenv.
* Resources: Microsoft Azure documentation for IoT Hub, Stream Analytics, and App Service.
