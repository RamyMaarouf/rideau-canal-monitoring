# Rideau Canal Ice Monitoring System (CST8916 Final Project)

This repository serves as the **main documentation and submission artifact** for the Rideau Canal Ice Monitoring System. This end-to-end cloud solution monitors simulated sensor data, calculates ice safety status, and displays real-time and historical trends via a web dashboard.

---

## System Architecture

The solution uses a **microservices architecture** built entirely on **Azure Cloud services** and Node.js.

The data follows a "hot path" from generation to consumption:
**Python Simulator** $\rightarrow$ **IoT Hub** $\rightarrow$ **Stream Analytics** $\rightarrow$ **Cosmos DB** $\leftarrow$ **Node.js API** $\rightarrow$ **Web Dashboard**

The full architecture diagram is available in the `architecture/` folder.

---

## Safety Status Logic

The core business logic is implemented in the Azure Stream Analytics query to determine the safety of the ice at three simulated locations.

| Ice Thickness ($\text{cm}$) | Status | Description |
| :---: | :---: | :--- |
| **$> 30$** | **Safe** | Ice is thick enough for activity. |
| **$25$ to $30$** | **Caution** | Conditions are monitored; thickness is nearing the minimum threshold. |
| **$< 25$** | **Unsafe** | Ice is too thin; activity should be avoided. |

---

## Submission Links

This project is separated into three required GitHub repositories.

| Repository | Content | Link |
| :--- | :--- | :--- |
| **1. Documentation (Current)** | Documentation, Screenshots, ASA Query | [Link to this repository] |
| **2. Sensor Simulation** | Python code for data generation. | [Link to rideau-canal-sensor-simulation repo] |
| **3. Web Dashboard** | Node.js API and Frontend code. | [Link to rideau-canal-dashboard repo] |

**Live Deployment URL:**
The fully functional dashboard is hosted on Azure App Service: `https://rcs-webapp1-czg2exatfngaaxhc.canadacentral-01.azurewebsites.net`