# Database Architecture

# Nova360 Analytics Warehouse

## Architecture Overview

Nova360 Analytics Warehouse is an enterprise-scale relational database implemented in Microsoft SQL Server.

The database has been designed around a multi-domain architecture that supports:

- Banking Operations & Fraud Analytics
- Retail Operations & Supply Chain Analytics
- Renewable Energy Operations
- Customer-Centric Analytics

The solution uses a shared Common schema to standardize customer, date, and time information across multiple business domains.

---

# Architectural Principles

The database was designed using the following principles:

## Separation of Business Domains
Each major business area is isolated into its own schema.

```text
NovaGroup
│
├── Common
├── Banking
├── Retail
└── Energy
```

Benefits:

- Improved maintainability
- Reduced complexity
- Easier security management
- Clear business ownership
- Scalable architecture

---

## Shared Enterprise Dimensions

The Common schema provides reusable dimensions shared across domains.

### Shared Tables

| Table | Purpose |
|---------|---------|
| Customer | Enterprise customer master |
| DateDim | Enterprise calendar dimension |
| TimeDim | Enterprise time dimension |

Benefits:

- Eliminates duplication
- Improves consistency
- Supports enterprise-wide reporting

---

## Referential Integrity

Relationships are enforced using Foreign Keys.

Benefits:

- Prevents orphan records
- Maintains data consistency
- Enforces business rules
- Improves reporting reliability

---

# Architectural Layers

The database can be viewed as four logical layers.

```text
┌───────────────────────────┐
│    Presentation Layer     │
│ Dashboards / Reports      │
└──────────────┬────────────┘
               │
┌──────────────▼────────────┐
│      Analytics Layer      │
│ Fact Tables               │
└──────────────┬────────────┘
               │
┌──────────────▼────────────┐
│      Business Layer       │
│ Dimensions & Entities     │
└──────────────┬────────────┘
               │
┌──────────────▼────────────┐
│      Data Foundation      │
│ Customer / Date / Time    │
└───────────────────────────┘
```

---

# Schema Architecture

## Common Schema

### Role

Acts as the enterprise foundation layer.

### Core Entities

```text
Customer
DateDim
TimeDim
```

### Responsibilities

- Customer Master Data
- Enterprise Calendar
- Time Standardization

### Referenced By

```text
Banking Schema
Retail Schema
Energy Schema
```

---

## Banking Schema

### Purpose

Models banking operations and fraud management processes.

### Architecture Pattern

```text
Dimensions
    │
    ▼
Transactions
    │
    ▼
Fraud Alerts
    │
    ▼
Cases
    │
    ▼
Interventions
    │
    ▼
Recoveries
```

### Dimension Tables

```text
DimAccount
DimBeneficiary
DimDevice
DimLocation
DimTransactionStatus
DimAlertRule
DimInvestigator
DimCasePriority
DimFraudType
DimInterventionType
```

### Fact Tables

```text
FactTransaction
FactTransactionEvent
FactDigitalSession
FactFraudAlert
FactCase
FactIntervention
FactReimbursement
FactFundRecovery
FactRiskFeature
FactAccountNetwork
```

### Business Focus

- Banking Operations
- Fraud Detection
- Customer Risk Monitoring
- Investigations
- Recoveries

---

## Retail Schema

### Purpose

Models retail commerce and supply chain operations.

### Architecture Pattern

```text
Supplier
    │
    ▼
Products
    │
    ▼
Inventory
    │
    ▼
Sales
    │
    ▼
Returns
```

### Dimension Tables

```text
DimProduct
DimLocation
DimSupplier
DimChannel
DimPromotion
DimReturnReason
DimInventoryMovementType
```

### Bridge Table

```text
Bridge_ProductSupplier
```

### Fact Tables

```text
FactSalesLine
FactInventorySnapshot
FactInventoryMovement
FactOnlineOrderLine
FactPurchaseOrderLine
FactGoodsReceipt
FactStockTransfer
FactReturnLine
FactPromotionPerformance
FactForecast
```

### Business Focus

- Sales Analysis
- Inventory Management
- Supply Chain Operations
- Demand Forecasting

---

## Energy Schema

### Purpose

Models renewable energy production and operational performance.

### Architecture Pattern

```text
Region
   │
   ▼
Asset
   │
   ├── Generation
   ├── Dispatch
   ├── Maintenance
   ├── Faults
   ├── Settlements
   └── Availability
```

### Dimension Tables

```text
DimRegion
DimAsset
DimWeatherStation
DimMarket
DimMarketService
DimCurtailmentReason
DimOutageReason
DimMaintenanceType
DimAssetComponent
DimCounterparty
```

### Fact Tables

```text
FactEnergyInterval
FactCurtailmentEvent
FactDispatchInstruction
FactWeatherObservation
FactAssetAvailability
FactMaintenanceWorkOrder
FactAssetFault
FactCommercialSettlement
FactGenerationAnomaly
```

### Business Focus

- Renewable Energy Operations
- Asset Monitoring
- Grid Services
- Energy Trading
- Performance Analytics

---

# Parent-Child Relationships

## Common.Customer

### One Customer → Many Accounts

```text
Customer
   │
   └──────< Account
```

Cardinality:

```text
1 : Many
```

Reason:

A customer may own multiple accounts.

---

## Account to Transaction

### One Account → Many Transactions

```text
Account
   │
   └──────< Transaction
```

Cardinality:

```text
1 : Many
```

Reason:

An account may participate in many transactions.

---

## Transaction to Fraud Alert

### One Transaction → Many Alerts

```text
Transaction
      │
      └──────< Fraud Alert
```

Cardinality:

```text
1 : Many
```

Reason:

Multiple fraud detection rules may trigger for a single transaction.

---

## Fraud Alert to Case

### One Alert → Many Cases

```text
Fraud Alert
      │
      └──────< Case
```

Cardinality:

```text
1 : Many
```

Reason:

Fraud investigations may evolve through multiple case lifecycles.

---

## Product to Sales

### One Product → Many Sales

```text
Product
   │
   └──────< Sales
```

Cardinality:

```text
1 : Many
```

Reason:

Products can appear in many sales transactions.

---

## Asset to Energy Events

### One Asset → Many Records

```text
Asset
   │
   ├── Energy Intervals
   ├── Dispatch Events
   ├── Faults
   ├── Maintenance
   └── Settlements
```

Cardinality:

```text
1 : Many
```

Reason:

Operational activity is recorded over time for each asset.

---

# Many-to-Many Relationships

## Product ↔ Supplier

The database includes a dedicated bridge table.

```text
Product
    │
    ▼
Bridge_ProductSupplier
    ▲
    │
Supplier
```

Cardinality:

```text
Many : Many
```

Reason:

A product may have multiple suppliers.

A supplier may provide multiple products.

Benefits:

- Reduced duplication
- Flexible sourcing model
- Improved scalability

---

# Self-Referencing Relationships

## Energy Asset Hierarchy

Energy assets support parent-child relationships.

```text
Parent Asset
      │
      ▼
Child Asset
```

Example:

```text
Wind Farm
   │
   ├── Turbine 1
   ├── Turbine 2
   └── Turbine 3
```

Benefits:

- Hierarchical reporting
- Asset aggregation
- Enterprise asset management

---

# Dimensional Modelling Characteristics

The design contains dimensional modelling concepts.

## Dimension Tables

Store descriptive business attributes.

Examples:

```text
DimAccount
DimProduct
DimSupplier
DimAsset
DimRegion
DimInvestigator
```

Characteristics:

- Relatively low rate of change
- Descriptive attributes
- Filtering and grouping

---

## Fact Tables

Store measurable business events.

Examples:

```text
FactTransaction
FactSalesLine
FactEnergyInterval
FactFraudAlert
FactCommercialSettlement
```

Characteristics:

- High transaction volume
- Quantitative data
- Analytical calculations

---

# Normalization Assessment

Based on the implemented schema structure:

## Identified Design Characteristics

### First Normal Form (1NF)

Implemented through:

- Atomic fields
- No repeating groups
- Unique row identification

---

### Second Normal Form (2NF)

Implemented through:

- Separation of entities
- Elimination of partial dependencies

---

### Third Normal Form (3NF)

Implemented through:

- Dedicated dimension tables
- Reduced redundancy
- Explicit business entities

---

## Assumption

The schema structure strongly indicates a normalized relational design combined with dimensional modelling patterns commonly used for enterprise analytics solutions.

---

# Data Integrity Design

The architecture protects data integrity through:

## Primary Keys

Every major entity has a unique identifier.

```text
CustomerID
AccountID
TransactionID
ProductKey
AssetKey
```

---

## Foreign Keys

Control relationship validity.

Examples:

```text
Customer → Account
Account → Transaction
Product → Sales
Asset → Energy Interval
```

---

## Check Constraints

Enforce business rules.

Examples:

```text
Valid Risk Ratings
Valid Account Statuses
Positive Transaction Amounts
Inventory Quantity Checks
Energy Capacity Rules
```

---

## Unique Constraints

Prevent duplicate business records.

Examples:

```text
CustomerExternalRef
AccountNumber
SKU
DeviceFingerprint
```

---

# Design Assumptions

The following assumptions are based on the implemented schema:

1. The database supports analytical reporting workloads.
2. Customer is the central business entity across domains.
3. Time-based analysis is important across all business areas.
4. Fraud analysis is a primary banking use case.
5. Inventory optimization is a primary retail use case.
6. Asset monitoring is a primary energy use case.
7. Data integrity takes precedence over data duplication.
8. Scalability and maintainability were prioritized through schema separation.

---

# Architecture Strengths

## Enterprise Separation

Clear business boundaries through schema design.

## Reusable Dimensions

Shared customer and calendar dimensions.

## Strong Data Governance

Implemented using:

- Primary Keys
- Foreign Keys
- Constraints
- Referential Integrity

## Analytics Ready

Supports:

- Operational Reporting
- KPI Reporting
- Power BI Dashboards
- Business Intelligence Solutions

## Scalable Foundation

Designed to support future additions such as:

- Stored Procedures
- Views
- ETL Pipelines
- Data Warehouses
- Power BI Models
- Advanced Analytics