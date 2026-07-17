# Business Rules and Constraints

# Nova360 Analytics Warehouse

## Overview

This document describes the business rules, constraints, and data integrity controls implemented within the Nova360 Analytics Warehouse database.

The database uses:

- Primary Keys
- Foreign Keys
- Check Constraints
- Unique Constraints
- Default Constraints
- Relationship Enforcement

These controls ensure data quality, business rule compliance, and referential integrity across all schemas.

---

# Constraint Types Implemented

| Constraint Type | Purpose |
|----------|----------|
| Primary Key (PK) | Ensures row uniqueness |
| Foreign Key (FK) | Enforces referential integrity |
| Unique Constraint | Prevents duplicate business values |
| Check Constraint | Enforces business rules |
| Default Constraint | Provides default values |
| Composite Key | Supports many-to-many relationships |

---

# Common Schema Business Rules

## Common.Customer

### Primary Key Rule

Every customer must have a unique CustomerID.

```text
CustomerID
```

---

### Unique Customer Reference

Each customer must have a unique external reference.

```text
CustomerExternalRef
```

Constraint:

```sql
UQ_Customer_ExternalRef
```

Business Rule:

> No two customers may share the same external customer reference.

---

### Risk Rating Validation

Constraint:

```sql
CK_Customer_RiskRating
```

Allowed Values:

```text
Low
Medium
High
```

Business Rule:

> Customer risk ratings must use predefined risk categories.

---

### Default Vulnerability Flag

Default:

```text
0 (False)
```

Business Rule:

> Customers are considered non-vulnerable unless explicitly flagged.

---

### Default Active Status

Default:

```text
1 (True)
```

Business Rule:

> New customers are active by default.

---

# Common.TimeDim

## Time Band Validation

Constraint:

```sql
CK_TimeDim_TimeBand
```

Allowed Values:

```text
Night
Morning
Afternoon
Evening
```

Business Rule:

> Time classifications must align with predefined reporting periods.

---

# Banking Schema Business Rules

# Banking.DimAccount

## Primary Key Rule

Every account must have a unique AccountID.

---

## Customer Ownership

Foreign Key:

```text
CustomerID → Common.Customer
```

Business Rule:

> An account cannot exist without a valid customer.

---

## Unique Account Number

Constraint:

```sql
UQ_Account
```

Business Rule:

> Account numbers must be unique across the banking platform.

---

## Account Status Validation

Constraint:

```sql
CK_Account_Status
```

Allowed Values:

```text
Active
Frozen
Closed
```

Business Rule:

> Accounts may only exist in approved lifecycle states.

---

## Account Lifecycle Validation

Constraint:

```sql
CK_Account_DateLifecycle
```

Business Rule:

> Account close dates cannot occur before account open dates.

---

# Banking.DimDevice

## Unique Device Fingerprint

Constraint:

```text
DeviceFingerprint
```

Business Rule:

> Each device fingerprint must uniquely identify a device.

---

# Banking.DimTransactionStatus

## Status Validation

Constraint:

```sql
CK_TransactionStatus
```

Allowed Values:

```text
Pending
Completed
Blocked
Failed
Reversed
```

Business Rule:

> Transactions must exist within approved banking statuses.

---

# Banking.DimCasePriority

## Priority Validation

Constraint:

```sql
CK_CasePriority
```

Allowed Values:

```text
Low
Medium
High
Critical
```

Business Rule:

> Fraud investigation cases must be categorized using approved priority levels.

---

# Banking.FactTransaction

## Transaction Integrity

### Sender Account Validation

Foreign Key:

```text
SenderAccountID → DimAccount
```

Business Rule:

> Every transaction must reference a valid sender account.

---

### Receiving Account Validation

Foreign Key:

```text
ReceivingAccountID → DimAccount
```

Business Rule:

> Receiving accounts must exist before transactions can be recorded.

---

### Beneficiary Validation

Foreign Key:

```text
BeneficiaryID → DimBeneficiary
```

Business Rule:

> Beneficiaries must be pre-registered before transactions reference them.

---

### Amount Validation

Constraint:

```sql
CK_Transaction_Amount
```

Rule:

```text
Amount > 0
```

Business Rule:

> Transaction values must be positive.

---

### Currency Validation

Constraint:

```sql
CK_Transaction_Currency
```

Allowed Values:

```text
GB
USD
EURO
PKR
```

Business Rule:

> Transactions must use an approved currency.

---

### Confirmation of Payee Validation

Constraint:

```sql
CK_CoP
```

Allowed Values:

```text
Match
No Match
Partial
```

Business Rule:

> CoP results must follow approved banking outcomes.

---

### Transaction Type Validation

Constraint:

```sql
CK_TransactionType
```

Allowed Values:

```text
Deposit
Withdrawal
Transfer
Payment
Refund
Others
```

Business Rule:

> Transaction categories must follow approved banking classifications.

---

# Banking.FactTransactionEvent

## Performed By Validation

Constraint:

```sql
CK_Event_PerformedBy
```

Allowed Values:

```text
System
User
```

Business Rule:

> Transaction events must record whether they originated from a system or user action.

---

## Event Type Validation

Constraint:

```sql
CK_Event_Type
```

Allowed Values:

```text
Created
Authorised
Blocked
Released
Completed
```

Business Rule:

> Only approved transaction lifecycle events may be recorded.

---

# Banking.FactDigitalSession

## Failed Login Validation

Constraint:

```sql
CK_FailedAttempts
```

Rule:

```text
FailedAttemptsCount >= 0
```

Business Rule:

> Failed login counts cannot be negative.

---

# Banking.FactFraudAlert

## Fraud Alert Validation

### Alert Status

Constraint:

```sql
CK_FactFraudAlert_Status
```

Allowed Values:

```text
Open
Closed
Converted
```

Business Rule:

> Fraud alerts must use approved statuses.

---

### Risk Score Validation

Constraint:

```sql
CK_FactFraudAlert_RiskScore
```

Rule:

```text
0 ≤ RiskScore ≤ 100
```

Business Rule:

> Fraud risk scores must stay within the approved scoring range.

---

# Banking.FactCase

## Case Status Validation

Constraint:

```sql
CK_FactCase_CaseStatus
```

Allowed Values:

```text
Open
Closed
Reopened
```

Business Rule:

> Fraud investigations must follow approved case states.

---

## Loss Amount Validation

Constraint:

```sql
CK_FactCase_LossAmount
```

Rule:

```text
LossAmount >= 0
```

Business Rule:

> Recorded fraud losses cannot be negative.

---

## Case Lifecycle Validation

Constraint:

```sql
CK_FactCase_CloseAfterOpen
```

Business Rule:

> Cases cannot close before they open.

---

# Banking.FactIntervention

## Outcome Validation

Constraint:

```sql
CK_FactIntervention_Outcome
```

Allowed Values:

```text
Successful
Failed
Ignored
```

---

## Customer Response Validation

Constraint:

```sql
CK_FactIntervention_CustomerResponse
```

Allowed Values:

```text
Accepted
Rejected
Ignored
```

Business Rule:

> Customer intervention outcomes must use approved response types.

---

# Banking.FactReimbursement

## Reimbursement Amount Rules

Constraint:

```sql
CK_FactReimbursement_Amounts
```

Business Rules:

- Requested amount cannot be negative
- Reimbursed amount cannot be negative
- Reimbursed amount cannot exceed requested amount

---

## Reimbursement Status Validation

Allowed Values:

```text
Approved
Rejected
Partial
```

Business Rule:

> Reimbursement outcomes must use approved decision categories.

---

# Banking.FactFundRecovery

## Recovery Validation

Rule:

```text
AmountRecovered ≤ AmountRequested
```

Business Rule:

> Recovered funds cannot exceed the amount originally requested.

---

## Recovery Status Validation

Allowed Values:

```text
Pending
Partial
Completed
Failed
```

Business Rule:

> Recovery activities must follow approved status values.

---

# Banking.FactRiskFeature

## Risk Score Validation

Rule:

```text
0 ≤ RiskScoreDerived ≤ 100
```

Business Rule:

> Derived risk scores must remain within the enterprise scoring model.

---

## Velocity Validation

Rules:

```text
PaymentVelocity_1H >= 0
PaymentVelocity_24H >= 0
```

Business Rule:

> Transaction velocity metrics cannot be negative.

---

## Beneficiary Validation

Rules:

```text
NewBeneficiaryCount_24H >= 0
UniqueBeneficiaries_7D >= 0
```

Business Rule:

> Beneficiary metrics must be positive or zero.

---

## Amount Validation

Rules:

```text
Average Amount >= 0
Maximum Amount >= 0
Maximum >= Average
```

Business Rule:

> Maximum transaction values must be greater than or equal to average values.

---

## Daily Feature Snapshot Rule

Constraint:

```sql
UQ_FactRiskFeature
```

Business Rule:

> Only one feature snapshot may exist per account per day.

---

# Banking.FactAccountNetwork

## Self-Link Prevention

Constraint:

```sql
CK_FactAccountNetwork_NoSelfLink
```

Business Rule:

> Accounts cannot create relationships with themselves.

---

## Connection Strength Validation

Rule:

```text
0 ≤ Score ≤ 100
```

Business Rule:

> Relationship strength scores must remain within valid scoring boundaries.

---

## Duplicate Relationship Prevention

Constraint:

```sql
UQ_FactAccountNetwork
```

Business Rule:

> Duplicate account relationships are prohibited.

---

# Retail Schema Business Rules

# Retail.DimProduct

## SKU Uniqueness

Constraint:

```sql
UQ_Product_SKU
```

Business Rule:

> Every product must have a unique SKU.

---

## Cost Validation

Rule:

```text
UnitCost >= 0
```

Business Rule:

> Product costs cannot be negative.

---

## Price Validation

Rule:

```text
UnitPrice >= 0
```

Business Rule:

> Product selling prices cannot be negative.

---

## Margin Validation

Constraint:

```sql
CK_Product_Margin
```

Rule:

```text
UnitPrice ≥ UnitCost
```

Business Rule:

> Selling price must not be lower than cost.

---

## Shelf Life Validation

Rule:

```text
ShelfLifeDays >= 0
```

Business Rule:

> Shelf life values cannot be negative.

---

# Retail.DimLocation

## Location Type Validation

Allowed Values:

```text
Store
Warehouse
Fulfilment Centre
```

Business Rule:

> Retail locations must be classified using approved location categories.

---

# Retail.DimSupplier

## Lead Time Validation

Rule:

```text
LeadTimeDays >= 0
```

---

## Reliability Validation

Rule:

```text
0 ≤ ReliabilityScore ≤ 100
```

Business Rule:

> Supplier reliability must follow standardized scoring.

---

# Retail.Bridge_ProductSupplier

## Contract Cost Validation

Rule:

```text
ContractCost > 0
```

Business Rule:

> Product supplier agreements require positive contract costs.

---

# Retail.DimChannel

Allowed Values:

```text
Store
Online
Mobile
Marketplace
```

Business Rule:

> Sales channels must use approved channel classifications.

---

# Retail.DimPromotion

## Promotion Validation

### Discount Type

Allowed Values:

```text
Percent
Amount
```

### Discount Value

Rule:

```text
DiscountValue >= 0
```

### Date Validation

Rule:

```text
EndDate >= StartDate
```

Business Rule:

> Promotions cannot end before they begin.

---

# Retail Fact Table Rules

## Sales Quantities

Rule:

```text
Quantity > 0
```

Business Rule:

> Sales must contain positive quantities.

---

## Inventory Snapshot

Rules:

```text
OnHandQty >= 0
AvailableQty >= 0
ReservedQty >= 0
DamagedQty >= 0
```

Business Rule:

> Inventory quantities cannot be negative.

---

### Availability Rule

```text
AvailableQty <= OnHandQty
```

Business Rule:

> Available inventory cannot exceed physical stock.

---

### Daily Snapshot Uniqueness

Constraint:

```sql
UQ_Inventory
```

Business Rule:

> Only one inventory snapshot may exist per product, location, and date.

---

## Inventory Movement

Business Rule:

> At least one source or destination location must be supplied.

---

## Online Order Rules

Business Rule:

> Quantities fulfilled, cancelled, or substituted cannot exceed quantity ordered.

---

## Purchase Orders

Rule:

```text
OrderedQty > 0
```

Business Rule:

> Purchase orders require positive quantities.

---

## Goods Receipts

Rule:

```text
ReceivedQty > 0
```

Business Rule:

> Goods receipts require positive received quantities.

---

## Stock Transfers

Rules:

```text
Quantity > 0
FromLocation <> ToLocation
```

Business Rule:

> Stock cannot be transferred to the same location.

---

## Returns

Rule:

```text
ReturnedQty > 0
```

Business Rule:

> Return quantities must be positive.

---

# Energy Schema Business Rules

# Energy.DimAsset

## Asset Type Validation

Allowed Values:

```text
Wind
Solar
Battery
```

Business Rule:

> Assets must belong to approved renewable energy categories.

---

## Capacity Validation

Rule:

```text
CapacityMW > 0
```

Business Rule:

> Assets must have positive generation capacity.

---

## Asset Lifecycle Validation

Rule:

```text
DecommissionDate >= CommissionDate
```

Business Rule:

> Assets cannot be decommissioned before commissioning.

---

# Energy Fact Rules

## Energy Interval Metrics

Rules:

```text
Generation ≥ 0
Forecast ≥ 0
Curtailment ≥ 0
Demand ≥ 0
Charge ≥ 0
Discharge ≥ 0
Degradation Cost ≥ 0
```

Business Rule:

> Operational energy metrics cannot be negative.

---

## State of Charge

Rule:

```text
0 ≤ StateOfChargePct ≤ 100
```

Business Rule:

> Battery state of charge must be expressed as a valid percentage.

---

## Availability Percentage

Rule:

```text
0 ≤ AvailabilityPct ≤ 100
```

Business Rule:

> Availability must remain within valid percentage bounds.

---

## Curtailment Events

Business Rules:

```text
EndTimestamp >= StartTimestamp
EnergyLostMWh >= 0
ConstraintMW >= 0
```

---

## Dispatch Instructions

Business Rules:

```text
RequestedMW >= 0
DeliveredMW >= 0
DeliveredMW <= RequestedMW
```

---

## Weather Observations

Business Rules:

```text
WindSpeed >= 0
SolarIrradiance >= 0
-100 < Temperature < 100
```

---

## Maintenance Work Orders

Business Rules:

```text
EndDate >= StartDate
Cost >= 0
DowntimeHours >= 0
```

---

## Fault Tracking

Business Rule:

```text
DowntimeHours >= 0
```

---

## Commercial Settlements

Business Rules:

```text
EnergySoldMWh >= 0
Revenue >= 0
Cost >= 0
```

---

## Generation Anomalies

Business Rules:

```text
ExpectedGeneration >= 0
ActualGeneration >= 0
-100 ≤ DeviationPct ≤ 100
```

Business Rule:

> Generation variance must remain within allowable percentage limits.

---

# Summary

The Nova360 Analytics Warehouse database uses a comprehensive set of data integrity controls to ensure:

✅ Data Quality

✅ Referential Integrity

✅ Business Rule Enforcement

✅ Relationship Consistency

✅ Duplicate Prevention

✅ Controlled Domain Values

✅ Enterprise Reporting Reliability

These controls provide a strong foundation for operational reporting, business intelligence solutions, SQL analytics, and future Power BI dashboard development.