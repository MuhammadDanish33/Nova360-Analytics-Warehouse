# Database Overview

# Nova360 Analytics Warehouse

## Project Overview

Nova360 Analytics Warehouse is a multi-domain enterprise database developed in Microsoft SQL Server.

The solution models business processes across three major operational domains:

1. Banking
2. Retail
3. Renewable Energy

The database is supported by a shared Common schema that provides enterprise-wide customer and time dimensions used across multiple business areas.

The project demonstrates professional relational database design practices including:

- Primary Key implementation
- Foreign Key relationships
- Referential integrity
- Data validation
- Business rule enforcement
- Enterprise schema separation
- Constraint management

---

# Business Objective

The objective of this database is to simulate how a large enterprise organization could manage operational and analytical data from multiple business divisions within a unified platform.

The database enables:

- Customer-centric analytics
- Fraud monitoring and investigation
- Retail sales reporting
- Inventory management
- Supply chain analytics
- Renewable energy production monitoring
- Asset performance management
- Cross-domain reporting

---

# Enterprise Architecture

The database is organized into four schemas.

```text
NovaGroup Database
│
├── Common
├── Banking
├── Retail
└── Energy
```

Each schema represents a distinct business capability while sharing common enterprise dimensions.

---

# Common Schema

## Purpose

Provides shared reference data used across multiple business domains.

## Key Tables

| Table | Purpose |
|---------|---------|
| Customer | Master customer information |
| DateDim | Calendar dimension |
| TimeDim | Time dimension |

## Business Value

Provides a single source of truth for:

- Customer records
- Date analysis
- Time-based reporting

This design eliminates duplication and promotes consistency across domains.

---

# Banking Schema

## Purpose

Models banking operations, fraud detection, investigations, customer risk monitoring, reimbursements, and recovery processes.

## Key Dimensions

| Table |
|---------|
| DimAccount |
| DimBeneficiary |
| DimDevice |
| DimLocation |
| DimTransactionStatus |
| DimAlertRule |
| DimInvestigator |
| DimCasePriority |
| DimFraudType |
| DimInterventionType |

## Key Facts

| Table |
|---------|
| FactTransaction |
| FactTransactionEvent |
| FactDigitalSession |
| FactFraudAlert |
| FactCase |
| FactIntervention |
| FactReimbursement |
| FactFundRecovery |
| FactRiskFeature |
| FactAccountNetwork |

## Supported Analytics

- Fraud Detection
- Transaction Monitoring
- Account Behaviour Analysis
- Customer Risk Profiling
- Case Management Reporting
- SLA Monitoring
- Reimbursement Analysis
- Recovery Performance Analysis

---

# Retail Schema

## Purpose

Models retail operations including sales, inventory, purchasing, returns, promotions, forecasting, and supply chain processes.

## Key Dimensions

| Table |
|---------|
| DimProduct |
| DimLocation |
| DimSupplier |
| DimChannel |
| DimPromotion |
| DimReturnReason |
| DimInventoryMovementType |

## Bridge Tables

| Table |
|---------|
| Bridge_ProductSupplier |

## Key Facts

| Table |
|---------|
| FactSalesLine |
| FactInventorySnapshot |
| FactInventoryMovement |
| FactOnlineOrderLine |
| FactPurchaseOrderLine |
| FactGoodsReceipt |
| FactStockTransfer |
| FactReturnLine |
| FactPromotionPerformance |
| FactForecast |

## Supported Analytics

- Sales Performance
- Inventory Optimization
- Product Performance
- Promotion Effectiveness
- Supply Chain Monitoring
- Forecast Accuracy
- Return Analysis

---

# Energy Schema

## Purpose

Models renewable energy generation and operational performance.

## Key Dimensions

| Table |
|---------|
| DimRegion |
| DimAsset |
| DimWeatherStation |
| DimMarket |
| DimMarketService |
| DimCurtailmentReason |
| DimOutageReason |
| DimMaintenanceType |
| DimAssetComponent |
| DimCounterparty |

## Key Facts

| Table |
|---------|
| FactEnergyInterval |
| FactCurtailmentEvent |
| FactDispatchInstruction |
| FactWeatherObservation |
| FactAssetAvailability |
| FactMaintenanceWorkOrder |
| FactAssetFault |
| FactCommercialSettlement |
| FactGenerationAnomaly |

## Supported Analytics

- Generation Performance Analysis
- Asset Availability Monitoring
- Maintenance Analytics
- Commercial Settlement Reporting
- Curtailment Monitoring
- Weather Impact Analysis
- Renewable Energy Forecasting

---

# Customer-Centric Design

The database follows a customer-centric architecture.

```text
Customer
   │
   ├── Banking Accounts
   │
   ├── Banking Transactions
   │
   ├── Fraud Cases
   │
   ├── Retail Purchases
   │
   └── Retail Orders
```

This enables enterprise-wide customer visibility and cross-functional reporting.

---

# Data Integrity Framework

The database enforces data quality through:

## Primary Keys

Every major entity contains a unique primary key.

Examples:

- CustomerID
- AccountID
- TransactionID
- ProductKey
- AssetKey

---

## Foreign Keys

Referential integrity ensures relationships remain valid.

Examples:

- Accounts require valid Customers
- Transactions require valid Accounts
- Sales require valid Products
- Energy records require valid Assets

---

## Constraints

The solution includes:

- Check Constraints
- Unique Constraints
- Default Values
- Relationship Constraints

Examples include:

- Positive transaction amounts
- Valid customer risk ratings
- Valid account statuses
- Inventory quantity validations
- Energy performance validations

---

# Analytical Use Cases

The database can support:

### Banking

- Fraud Dashboards
- Customer Risk Monitoring
- Investigation Reporting

### Retail

- Sales Analytics
- Product Analytics
- Inventory Dashboards

### Energy

- Generation Reporting
- Asset Monitoring
- Maintenance Analytics

### Executive Reporting

- Enterprise KPI Dashboards
- Customer 360 Analysis
- Cross-Domain Performance Reporting

---

# Intended Audience

This database can be used by:

- Data Analysts
- Business Intelligence Analysts
- Data Engineers
- Database Developers
- Data Architects
- Reporting Teams
- Analytics Teams

---

# Project Status

Current Status: Database Design Complete

Completed:

✅ Schema Design

✅ Table Design

✅ Primary Keys

✅ Foreign Keys

✅ Constraints

✅ Referential Integrity

✅ Business Rules

✅ Validation

✅ Technical Documentation

Future Enhancements:

- Sample Data Generation
- Analytical SQL Queries
- Power BI Dashboards
- Stored Procedures
- Views
- ETL Pipelines