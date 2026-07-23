# Smart Mini-ERP & Factory Management System (Learning Project)

![SAP S/4HANA](https://img.shields.io/badge/SAP-S%2F4HANA-blue?style=for-the-badge&logo=sap)
![ABAP RAP](https://img.shields.io/badge/Architecture-ABAP_RAP-orange?style=for-the-badge)
![CDS Views](https://img.shields.io/badge/Data_Modeling-CDS_Views-success?style=for-the-badge)
![OData V4](https://img.shields.io/badge/API-OData_V4-yellow?style=for-the-badge)
![TDD](https://img.shields.io/badge/Testing-ABAP_Unit-lightgrey?style=for-the-badge)
![SAPUI5](https://img.shields.io/badge/Frontend-SAPUI5-blueviolet?style=for-the-badge)

## 1. Project Overview

Welcome to my Smart Mini-ERP project! I am building this comprehensive SAP application as a hands-on learning journey to deepen my expertise in the **SAP RESTful Application Programming Model (RAP)** and modern cloud-ready development. 

My goal is to simulate a real-world factory management system that handles Business Partners, Material Master data, Purchase Orders, and Sales Orders. Throughout this development process, I am strictly challenging myself to apply **industry best practices**, adhere to **SAP's Clean Core principles**, and write scalable, modular code just as it would be expected in a professional enterprise environment. 

## 2. Tech Stack & Learning Progress

I am utilizing this project to bridge the gap between theoretical SAP courses and real-world implementation. Here is a breakdown of the technologies I am currently learning and applying:

* **Database Tables & Include Structures** `[Successfully Implemented]`
* **Core Data Services (CDS) Views (Root, Interface, Consumption)** `[Successfully Implemented]`
* **Behavior Definitions (BDEF)** `[Successfully Implemented]`
* **Behavior Implementations (BIL - Validations, Determinations)** `[Currently Developing]`
* **Entity Manipulation Language (EML) & Unit Testing (TDD)** `[Successfully Implemented]`
* **OData V4 API Generation (Service Definition & Binding)** `[Successfully Implemented]`
* **SAPUI5 Freestyle Application (Frontend)** `[Planned / Next Step]`

## 3. Architecture & Data Model

I structured the system architecture within the `ZFACTORY_MANAGEMENT` package, focusing on understanding and applying the **Virtual Data Model (VDM)** layers.

### Database Design & Clean Code
I am paying special attention to clean code practices at the database level. Instead of using legacy abbreviations, I am practicing domain-driven naming conventions (e.g., using `unit_price` and `quantity`).
* **Master Data:** `ZFAB_T_BP` (Business Partners) and `ZFAB_T_MAT` (Materials).
* **Transactional Data:** Designed with strict parent-child (Header-Item) relationships for Procurement (`ZFAB_T_PO_HDR/ITM`) and Sales (`ZFAB_T_SO_HDR/ITM`).
* **Reusability:** I implemented standard include structures like `ZFAB_S_ADDRESS` to keep the database normalized and avoid code duplication.
* **Draft Capabilities:** Enabled draft tables to understand stateful processing in modern SAP Fiori applications.

### Core Data Services (CDS)
* I built the `ZR_` (Root), `ZI_` (Interface), and `ZC_` (Consumption) layers to separate physical data from business logic and UI requirements.
* I am actively practicing **HANA Code Pushdown** by shifting calculations (like line-item totals) directly to the database level within the CDS views.

## 4. Key Features I Am Building

* **End-to-End CRUD Operations:** Learning to manage the complete lifecycle of business objects using the RAP framework.
* **Test-Driven Development (TDD):** Instead of just writing code, I am building a mock data factory (`ZCL_FAB_MOCK_FACTORY`) and writing ABAP Unit tests *before* implementing the actual business logic to ensure behavioral stability.
* **Complex Validations:** Coding backend rules to prevent logical errors (e.g., restricting negative prices, validating standard currency codes, and preventing the deletion of a Material if it is actively used in an Order).
* **Dynamic Feature Control:** Exploring how to lock specific fields (like Base Unit of Measure) to read-only mode after a record is created to maintain data integrity.

## 5. Current Status & Roadmap

**Where I am right now:** 
I have successfully laid down the entire database and CDS architecture, and fully built the Unit Testing (TDD) infrastructure for both Master and Transactional Data (BP, MAT, SO, PO). I am currently focusing entirely on the core backend business logic—writing the actual **Validations and Determinations** inside the Behavior Implementation (BIL) classes to make my unit tests pass and secure the system.

**What is next:**
Once all the backend validations are implemented and my test coverage is green, I will jump into the UI development phase. I plan to consume my exposed OData V4 services by developing a responsive, freestyle SAPUI5 application to bring the ERP processes to life.

### 💡 Retrospective: What I Could Do Better
As I reflect on my backend development journey, I have identified a few key areas for future refactoring to elevate my code to senior-level architectural standards:

* **Unit Testing =** I plan to transition from a static Mock Factory to a **Builder Design Pattern** (`->with_role('S')->build()`) for more flexible and readable test data creation. I also want to implement a **Base Test Class** (Inheritance) to reduce boilerplate setup/teardown code, and replace hardcoded expected values with dynamic calculations to make my tests bulletproof.
* **Code Reusability =** I will refactor my test helper methods to handle both *Happy Paths* and *Negative Tests* seamlessly using boolean flags (e.g., `iv_expect_fail`), which will significantly reduce redundant EML modify statements.

## 6. Associated Learning Paths

This project acts as my practical playground and preparation for the following official SAP Learning Journeys and Certifications:
* **Acquiring Core ABAP Skills** *(Targeting Certification)*
* **Developing SAPUI5 Applications** *(Targeting Certification)*
