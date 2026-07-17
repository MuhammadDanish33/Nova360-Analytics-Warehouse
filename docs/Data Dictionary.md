# Data Dictionary

# Nova360 Analytics Warehouse

## Purpose

This Data Dictionary provides a high-level inventory of all schemas, tables, and business entities within the Nova360 Analytics Warehouse database.

The document serves as a quick-reference guide for:

- Data Analysts
- Business Intelligence Analysts
- Database Developers
- Technical Reviewers

---

# Database Summary

| Component | Count |
|------------|---------:|
| Schemas | 4 |
| Common Tables | 3 |
| Banking Tables | 20 |
| Retail Tables | 18 |
| Energy Tables | 19 |
| Total Tables | 60 |

---

# Schema Overview

```text
NovaGroup
│
├── Common
├── Banking
├── Retail
└── Energy
```

---

# Common Schema

## Purpose

Provides enterprise-wide master and reference data shared across business domains.

---

## Common.Customer

### Description

Enterprise customer master table.

### Business Purpose

Stores core customer information used throughout Banking and Retail domains.

### Key Attributes

- CustomerID
- CustomerExternalRef
- FirstName
- LastName
- DateOfBirth
- Email
- RiskRating
- VulnerabilityFlag

---

## Common.DateDim

### Description

Enterprise calendar dimension.

### Business Purpose

Supports time-based analytics and reporting.

### Key Attributes

- DateKey
- FullDate
- Day
- Month
- Year
- Quarter
- WeekNumber

---

## Common.TimeDim

### Description

Enterprise time dimension.

### Business Purpose

Supports intraday reporting and time analysis.

### Key Attributes

- TimeKey
- Hour
- Minute
- Second
- TimeBand

---

# Banking Schema

## Purpose

Supports banking operations, fraud monitoring, investigations, customer risk analysis, reimbursements, and recovery activities.

---

# Banking Dimensions

## Banking.DimAccount

### Description

Customer bank account dimension.

### Business Purpose

Stores account information used in transaction processing.

### Key Attributes

- AccountID
- CustomerID
- AccountNumber
- AccountType
- AccountStatus
- KYCLevel

---

## Banking.DimBeneficiary

### Description

Registered payment beneficiary.

### Business Purpose

Stores beneficiary details used in fund transfers.

### Key Attributes

- BeneficiaryID
- CustomerID
- BeneficiaryName
- BeneficiaryAccountNumber
- BankName

---

## Banking.DimDevice

### Description

Customer device registry.

### Business Purpose

Tracks devices used for banking access.

### Key Attributes

- DeviceID
- CustomerID
- DeviceFingerprint
- DeviceType
- OS
- Browser

---

## Banking.DimLocation

### Description

Location reference dimension.

### Business Purpose

Supports fraud and risk analysis.

### Key Attributes

- LocationID
- IPAddress
- Country
- City
- IsHighRiskCountry

---

## Banking.DimTransactionStatus

### Description

Transaction status lookup.

### Key Attributes

- TransactionStatusID
- StatusName

---

## Banking.DimAlertRule

### Description

Fraud detection rules.

### Key Attributes

- AlertRuleID
- RuleName
- RiskWeight
- ThresholdValue

---

## Banking.DimInvestigator

### Description

Fraud investigation personnel.

### Key Attributes

- InvestigatorID
- Name
- Team
- SeniorityLevel

---

## Banking.DimCasePriority

### Description

Case prioritization dimension.

### Key Attributes

- CasePriorityID
- PriorityName
- SLAHours

---

## Banking.DimFraudType

### Description

Fraud classification reference.

### Key Attributes

- FraudTypeID
- FraudTypeName

---

## Banking.DimInterventionType

### Description

Customer intervention categories.

### Key Attributes

- InterventionTypeID
- Name

---

# Banking Facts

## Banking.FactTransaction

### Description

Central banking transaction fact table.

### Business Purpose

Stores financial transactions.

### Measures

- Amount

---

## Banking.FactTransactionEvent

### Description

Transaction lifecycle events.

### Business Purpose

Tracks transaction progression.

### Measures

- EventTimestamp

---

## Banking.FactDigitalSession

### Description

Digital banking login sessions.

### Business Purpose

Tracks customer access behaviour.

### Measures

- FailedAttemptsCount
- SessionRiskScore

---

## Banking.FactFraudAlert

### Description

Fraud alert records.

### Business Purpose

Captures suspicious activity.

### Measures

- RiskScore

---

## Banking.FactCase

### Description

Fraud investigation cases.

### Business Purpose

Case management and investigation tracking.

### Measures

- LossAmount

---

## Banking.FactIntervention

### Description

Customer intervention activities.

### Business Purpose

Tracks fraud prevention actions.

---

## Banking.FactReimbursement

### Description

Customer reimbursement decisions.

### Measures

- AmountRequested
- AmountReimbursed

---

## Banking.FactFundRecovery

### Description

Fund recovery activities.

### Measures

- AmountRequested
- AmountRecovered

---

## Banking.FactRiskFeature

### Description

Derived customer risk indicators.

### Measures

- PaymentVelocity_1H
- PaymentVelocity_24H
- NewBeneficiaryCount_24H
- RiskScoreDerived

---

## Banking.FactAccountNetwork

### Description

Account relationship network.

### Business Purpose

Supports fraud network analytics.

### Measures

- ConnectionStrengthScore

---

# Retail Schema

## Purpose

Supports retail sales, inventory, supply chain, purchasing, forecasting, and promotions.

---

# Retail Dimensions

## Retail.DimProduct

### Description

Retail product catalog.

### Key Attributes

- ProductKey
- ProductName
- SKU
- Category
- Brand
- UnitCost
- UnitPrice

---

## Retail.DimLocation

### Description

Retail locations.

### Key Attributes

- LocationKey
- LocationName
- LocationType
- Region
- City

---

## Retail.DimSupplier

### Description

Product supplier catalog.

### Key Attributes

- SupplierKey
- SupplierName
- LeadTimeDays
- ReliabilityScore

---

## Retail.Bridge_ProductSupplier

### Description

Many-to-many relationship between products and suppliers.

### Purpose

Supports multiple sourcing relationships.

---

## Retail.DimChannel

### Description

Sales channels.

### Key Attributes

- ChannelKey
- ChannelName

---

## Retail.DimPromotion

### Description

Marketing promotion catalog.

### Key Attributes

- PromotionKey
- PromotionName
- DiscountType
- DiscountValue

---

## Retail.DimReturnReason

### Description

Product return reasons.

### Key Attributes

- ReturnReasonKey
- ReasonName

---

## Retail.DimInventoryMovementType

### Description

Inventory movement classifications.

### Key Attributes

- MovementTypeKey
- MovementTypeName

---

# Retail Facts

## Retail.FactSalesLine

### Description

Sales transaction fact table.

### Measures

- Quantity
- DiscountAmount
- NetSalesAmount
- CostAmount
- GrossProfit

---

## Retail.FactInventorySnapshot

### Description

Inventory position snapshots.

### Measures

- OnHandQty
- AvailableQty
- ReservedQty
- DamagedQty
- InventoryValue

---

## Retail.FactInventoryMovement

### Description

Inventory movement transactions.

### Measures

- Quantity
- UnitCost

---

## Retail.FactOnlineOrderLine

### Description

Online order activity.

### Measures

- OrderedQty
- FulfilledQty
- CancelledQty
- SubstitutedQty

---

## Retail.FactPurchaseOrderLine

### Description

Purchase order activity.

### Measures

- OrderedQty
- UnitCost

---

## Retail.FactGoodsReceipt

### Description

Received inventory records.

### Measures

- ReceivedQty

---

## Retail.FactStockTransfer

### Description

Stock movement between locations.

### Measures

- Quantity

---

## Retail.FactReturnLine

### Description

Returned products.

### Measures

- ReturnedQty
- RefundAmount

---

## Retail.FactPromotionPerformance

### Description

Promotion effectiveness tracking.

### Measures

- BaselineSalesQty
- ActualSalesQty
- IncrementalSalesQty

---

## Retail.FactForecast

### Description

Forecasted demand.

### Measures

- ForecastQty
- ForecastValue

---

# Energy Schema

## Purpose

Supports renewable energy generation, operational monitoring, maintenance, forecasting, and commercial activities.

---

# Energy Dimensions

## Energy.DimRegion

### Description

Energy operating regions.

### Key Attributes

- RegionKey
- RegionName
- Country
- GridOperator

---

## Energy.DimAsset

### Description

Renewable energy assets.

### Key Attributes

- AssetKey
- AssetName
- AssetType
- Technology
- CapacityMW

---

## Energy.DimWeatherStation

### Description

Weather monitoring locations.

### Key Attributes

- WeatherStationKey
- StationName

---

## Energy.DimMarket

### Description

Energy trading markets.

### Key Attributes

- MarketKey
- MarketName

---

## Energy.DimMarketService

### Description

Grid service catalog.

### Key Attributes

- ServiceKey
- ServiceName

---

## Energy.DimCurtailmentReason

### Description

Curtailment classifications.

### Key Attributes

- CurtailmentReasonKey
- ReasonName

---

## Energy.DimOutageReason

### Description

Outage classifications.

### Key Attributes

- OutageReasonKey
- ReasonName

---

## Energy.DimMaintenanceType

### Description

Maintenance categories.

### Key Attributes

- MaintenanceTypeKey
- TypeName

---

## Energy.DimAssetComponent

### Description

Asset component registry.

### Key Attributes

- ComponentKey
- ComponentName
- ComponentType

---

## Energy.DimCounterparty

### Description

Commercial counterparties.

### Key Attributes

- CounterpartyKey
- Name
- Type

---

# Energy Facts

## Energy.FactEnergyInterval

### Description

Energy generation intervals.

### Measures

- ActualGenerationMWh
- ForecastGenerationMWh
- CurtailmentMWh
- DemandMWh
- MarketPrice

---

## Energy.FactCurtailmentEvent

### Description

Curtailment occurrences.

### Measures

- EnergyLostMWh
- EstimatedRevenueLoss
- ConstraintMW

---

## Energy.FactDispatchInstruction

### Description

Grid dispatch instructions.

### Measures

- RequestedMW
- DeliveredMW

---

## Energy.FactWeatherObservation

### Description

Weather observations.

### Measures

- WindSpeed
- SolarIrradiance
- Temperature

---

## Energy.FactAssetAvailability

### Description

Asset performance availability.

### Measures

- AvailableHours
- TotalHours
- AvailabilityPct

---

## Energy.FactMaintenanceWorkOrder

### Description

Maintenance activities.

### Measures

- Cost
- DowntimeHours

---

## Energy.FactAssetFault

### Description

Asset fault events.

### Measures

- DowntimeHours

---

## Energy.FactCommercialSettlement

### Description

Commercial energy settlements.

### Measures

- EnergySoldMWh
- Revenue
- Cost
- NetProfit

---

## Energy.FactGenerationAnomaly

### Description

Generation anomaly tracking.

### Measures

- ExpectedGeneration
- ActualGeneration
- DeviationPct
- RevenueImpact
- CarbonImpact

---

# Table Classification Summary

| Schema | Dimensions | Facts | Bridge | Total |
|----------|---------:|---------:|---------:|---------:|
| Common  | 3 | 0 | 0 | 3 |
| Banking | 10 | 10 | 0 | 20 |
| Retail | 7 | 10 | 1 | 18 |
| Energy | 10 | 9 | 0 | 19 |
| Total | 30 | 29 | 1 | 60 |

---

# Data Dictionary Usage Guide

This document should be used alongside:

```text
docs/database-overview.md
docs/database-architecture.md
docs/database-business-rules-and-constraints.md5
```
