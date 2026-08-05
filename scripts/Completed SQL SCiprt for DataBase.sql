-- =============================================
-- NOVAGROUP ENTERPRISE DATABASE (FULL EXTENDED)
-- =============================================
USE master;
GO

IF DB_ID('NovaGroup') IS NOT NULL
BEGIN
    ALTER DATABASE NovaGroup SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NovaGroup;
END
GO

CREATE DATABASE NovaGroup;
GO

USE NovaGroup;
GO

-- =============================================
-- SCHEMAS
-- =============================================
CREATE SCHEMA Common;
GO
CREATE SCHEMA Banking;
GO
CREATE SCHEMA Retail;
GO
CREATE SCHEMA Energy;
GO

-- =============================================
-- COMMON SCHEMA
-- =============================================

CREATE TABLE Common.Customer (
    CustomerID BIGINT IDENTITY PRIMARY KEY,
    CustomerExternalRef NVARCHAR(50) NOT NULL,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    DateOfBirth DATE,
    Email NVARCHAR(255),
    PhoneNumber NVARCHAR(50),
    CustomerSinceDate DATE,
    RiskRating NVARCHAR(20),--low/medium/high
    VulnerabilityFlag BIT DEFAULT 0,
    VulnerabilityType NVARCHAR(100),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    UpdatedDate DATETIME2,
    CONSTRAINT UQ_Customer_ExternalRef UNIQUE (CustomerExternalRef),
    CONSTRAINT CK_Customer_RiskRating CHECK (RiskRating IN ('Low','Medium','High'))
);

CREATE TABLE Common.DateDim (
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    Day INT,
    Month INT,
    Year INT,
    Quarter INT,
    WeekNumber INT,
    IsWeekend BIT
);

CREATE TABLE Common.TimeDim (
    TimeKey INT PRIMARY KEY,
    Hour INT,
    Minute INT,
    Second INT,
    TimeBand NVARCHAR(20), 
    CONSTRAINT CK_TimeDim_TimeBand CHECK (TimeBand IN ('Night','Morning','Afternoon','Evening'))
);

-- =============================================
-- BANKING DIMENSIONS
-- =============================================

CREATE TABLE Banking.DimAccount (
    AccountID BIGINT IDENTITY PRIMARY KEY,
    CustomerID BIGINT NOT NULL,
    AccountNumber NVARCHAR(20) NOT NULL,
    SortCode NVARCHAR(10),
    AccountType NVARCHAR(20),
    OpenDate DATE,
    CloseDate DATE NULL,
    AccountStatus NVARCHAR(20),
    KYCLevel NVARCHAR(20),
    IsHighRiskFlag BIT DEFAULT 0,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES Common.Customer(CustomerID),
    CONSTRAINT UQ_Account UNIQUE (AccountNumber),
    CONSTRAINT CK_Account_Status CHECK (AccountStatus IN ('Active','Frozen','Closed')),
    CONSTRAINT CK_Account_DateLifecycle CHECK (CloseDate IS NULL OR CloseDate >= OpenDate)
);

CREATE TABLE Banking.DimBeneficiary (
    BeneficiaryID BIGINT IDENTITY PRIMARY KEY,
    CustomerID BIGINT,
    BeneficiaryName NVARCHAR(200),
    BeneficiaryAccountNumber NVARCHAR(20),
    BeneficiarySortCode NVARCHAR(10),
    BankName NVARCHAR(100),
    BankCountry NVARCHAR(50),
    IsInternalBank BIT,
    CreatedDate DATETIME2,
    FOREIGN KEY (CustomerID) REFERENCES Common.Customer(CustomerID)
);

CREATE TABLE Banking.DimDevice (
    DeviceID BIGINT IDENTITY PRIMARY KEY,
    CustomerID BIGINT,
    DeviceFingerprint NVARCHAR(255) UNIQUE,
    DeviceType NVARCHAR(20),
    OS NVARCHAR(50),
    Browser NVARCHAR(50),
    FirstSeenDate DATETIME2,
    IsTrustedDevice BIT,
    FOREIGN KEY (CustomerID) REFERENCES Common.Customer(CustomerID)
);

CREATE TABLE Banking.DimLocation (
    LocationID BIGINT IDENTITY PRIMARY KEY,
    IPAddress NVARCHAR(50),
    Country NVARCHAR(50),
    City NVARCHAR(50),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    IsHighRiskCountry BIT
);

CREATE TABLE Banking.DimTransactionStatus (
    TransactionStatusID INT IDENTITY PRIMARY KEY,
    StatusName NVARCHAR(50),
    CONSTRAINT CK_TransactionStatus CHECK (StatusName IN ('Pending','Completed','Blocked','Failed','Reversed'))
);

CREATE TABLE Banking.DimAlertRule (
    AlertRuleID INT IDENTITY PRIMARY KEY,
    RuleName NVARCHAR(100),
    RiskWeight INT,
    ThresholdValue DECIMAL(18,2),
    IsActive BIT,
    CreatedDate DATETIME2 DEFAULT GETDATE() 
);

CREATE TABLE Banking.DimInvestigator (
    InvestigatorID INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100),
    Team NVARCHAR(100),
    SeniorityLevel NVARCHAR(50),
    IsActive BIT
);

CREATE TABLE Banking.DimCasePriority (
    CasePriorityID INT IDENTITY PRIMARY KEY,
    PriorityName NVARCHAR(20),--Low/Medium/high
    SLAHours INT NOT NULL,
    CONSTRAINT CK_CasePriority CHECK (PriorityName IN ('Low','Medium','High','Critical'))
);

CREATE TABLE Banking.DimFraudType (
    FraudTypeID INT IDENTITY PRIMARY KEY,
    FraudTypeName NVARCHAR(100)
);

CREATE TABLE Banking.DimInterventionType (
    InterventionTypeID INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) 
);

-- =============================================
-- BANKING FACTS (FULL)
-- =============================================

CREATE TABLE Banking.FactTransaction (
    TransactionID BIGINT IDENTITY PRIMARY KEY,
    DateKey INT,
    TimeKey INT,
    SenderAccountID BIGINT,
    ReceivingAccountID BIGINT NULL,
    BeneficiaryID BIGINT,
    Amount DECIMAL(18,2) NOT NULL,
    Currency CHAR(3) NOT NULL,
    TransactionType NVARCHAR(50), 
    Channel NVARCHAR(20),
    DeviceID BIGINT,
    LocationID BIGINT,
    TransactionStatusID INT,
    IsNewBeneficiary BIT,
    CoPResult NVARCHAR(50), 
    IsHighValue BIT,
    CreatedTimestamp DATETIME2 DEFAULT GETDATE(), 
    FOREIGN KEY (SenderAccountID) REFERENCES Banking.DimAccount(AccountID),
    FOREIGN KEY (ReceivingAccountID) REFERENCES Banking.DimAccount(AccountID),
    FOREIGN KEY (BeneficiaryID) REFERENCES Banking.DimBeneficiary(BeneficiaryID),
    FOREIGN KEY (DeviceID) REFERENCES Banking.DimDevice(DeviceID),
    FOREIGN KEY (LocationID) REFERENCES Banking.DimLocation(LocationID),
    FOREIGN KEY (TransactionStatusID) REFERENCES Banking.DimTransactionStatus(TransactionStatusID),
    FOREIGN KEY (DateKey) REFERENCES Common.DateDim(DateKey),
    FOREIGN KEY (TimeKey) REFERENCES Common.TimeDim(TimeKey),
    CONSTRAINT CK_Transaction_Amount CHECK (Amount > 0),
    CONSTRAINT CK_Transaction_Currency CHECK (Currency IN('GB','USD','EURO','PKR')),
    CONSTRAINT CK_CoP CHECK (CoPResult IN ('Match','No Match','Partial')),
    CONSTRAINT CK_TransactionType CHECK(TransactionType IN('Deposit','Withdrawal','Transfer','Payment', 'Refund', 'Others'))
);

CREATE TABLE Banking.FactTransactionEvent (
    EventID BIGINT IDENTITY PRIMARY KEY,
    TransactionID BIGINT,
    EventType NVARCHAR(50), 
    EventTimestamp DATETIME2,
    PerformedBy NVARCHAR(10) NOT NULL, 
    FOREIGN KEY (TransactionID) REFERENCES Banking.FactTransaction(TransactionID),
    CONSTRAINT CK_Event_PerformedBy CHECK (PerformedBy IN ('System','User')),
    CONSTRAINT CK_Event_Type CHECK (EventType IN ('Created','Authorised','Blocked','Released','Completed'))
);
CREATE TABLE Banking.FactDigitalSession (
    SessionID BIGINT IDENTITY PRIMARY KEY,
    CustomerID BIGINT NOT NULL,
    DeviceID BIGINT NOT NULL,
    LocationID BIGINT NOT NULL,
    LoginDateKey INT NOT NULL,
    LoginTimeKey INT NOT NULL,
    LogoutTimeKey INT NULL,
    IsSuccessfulLogin BIT NOT NULL,
    FailedAttemptsCount INT DEFAULT 0,
    SessionRiskScore DECIMAL(5,2),
    FOREIGN KEY (CustomerID)REFERENCES Common.Customer(CustomerID),
    FOREIGN KEY (DeviceID)REFERENCES Banking.DimDevice(DeviceID),
    FOREIGN KEY (LocationID)REFERENCES Banking.DimLocation(LocationID),
    FOREIGN KEY (LoginDateKey)REFERENCES Common.DateDim(DateKey),
    FOREIGN KEY (LoginTimeKey)REFERENCES Common.TimeDim(TimeKey),
    FOREIGN KEY (LogoutTimeKey)REFERENCES Common.TimeDim(TimeKey),
    CONSTRAINT CK_FailedAttempts CHECK (FailedAttemptsCount >= 0)
);
CREATE TABLE Banking.FactFraudAlert (
    AlertID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TransactionID BIGINT NOT NULL,
    AlertRuleID INT NOT NULL,
    AlertDateKey INT NOT NULL,
    AlertTimestamp DATETIME2 NOT NULL,
    RiskScore DECIMAL(5,2) NOT NULL,
    AlertStatus NVARCHAR(20) NOT NULL,
    CONSTRAINT FK_FactFraudAlert_Transaction FOREIGN KEY (TransactionID) REFERENCES Banking.FactTransaction(TransactionID),
    CONSTRAINT FK_FactFraudAlert_AlertRule FOREIGN KEY (AlertRuleID) REFERENCES Banking.DimAlertRule(AlertRuleID),
    CONSTRAINT FK_FactFraudAlert_Date FOREIGN KEY (AlertDateKey) REFERENCES Common.DateDim(DateKey),
    CONSTRAINT CK_FactFraudAlert_RiskScore CHECK (RiskScore BETWEEN 0 AND 100),
    CONSTRAINT CK_FactFraudAlert_Status CHECK (AlertStatus IN ('Open', 'Closed', 'Converted'))
);

CREATE TABLE Banking.FactCase (
    CaseID BIGINT IDENTITY(1,1) PRIMARY KEY,
    -- Link to fraud alert
    AlertID BIGINT NOT NULL,
    -- Investigation ownership
    InvestigatorID INT NOT NULL,
    -- Case priority and SLA
    CasePriorityID INT NOT NULL,
    -- Case open date/time
    CaseOpenDateKey INT NOT NULL,
    CaseOpenTimestamp DATETIME2 NOT NULL,
    -- Case close date/time - nullable because active cases may still be open
    CaseCloseDateKey INT NULL,
    CaseCloseTimestamp DATETIME2 NULL,
    -- Case lifecycle status
    CaseStatus NVARCHAR(20) NOT NULL,
    -- Investigation result
    FraudConfirmedFlag BIT NULL,
    -- Fraud classification
    FraudTypeID INT NULL,
    -- Financial loss
    LossAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    -- SLA tracking
    SLADeadlineTimestamp DATETIME2 NOT NULL,
    IsSLABreached BIT NOT NULL DEFAULT 0,
        -- Foreign Keys
    CONSTRAINT FK_FactCase_FraudAlert FOREIGN KEY (AlertID) REFERENCES Banking.FactFraudAlert(AlertID),
    CONSTRAINT FK_FactCase_Investigator FOREIGN KEY (InvestigatorID) REFERENCES Banking.DimInvestigator(InvestigatorID),
    CONSTRAINT FK_FactCase_CasePriority FOREIGN KEY (CasePriorityID) REFERENCES Banking.DimCasePriority(CasePriorityID),
    CONSTRAINT FK_FactCase_CaseOpenDate FOREIGN KEY (CaseOpenDateKey) REFERENCES Common.DateDim(DateKey),
    CONSTRAINT FK_FactCase_CaseCloseDate FOREIGN KEY (CaseCloseDateKey) REFERENCES Common.DateDim(DateKey),
    CONSTRAINT FK_FactCase_FraudType FOREIGN KEY (FraudTypeID) REFERENCES Banking.DimFraudType(FraudTypeID),
    -- Business rule constraints
    CONSTRAINT CK_FactCase_CaseStatus CHECK (CaseStatus IN ('Open', 'Closed', 'Reopened')),
    CONSTRAINT CK_FactCase_LossAmount CHECK (LossAmount >= 0),
    CONSTRAINT CK_FactCase_CloseAfterOpen CHECK (CaseCloseTimestamp IS NULL OR CaseCloseTimestamp >= CaseOpenTimestamp)
);

CREATE TABLE Banking.FactIntervention (
    InterventionID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseID BIGINT NOT NULL,
    InterventionTypeID INT NOT NULL,
    InterventionDateKey INT NOT NULL,
    InterventionTimestamp DATETIME2 NOT NULL,
    Outcome NVARCHAR(20) NOT NULL,
    CustomerResponse NVARCHAR(20) NOT NULL,
    CONSTRAINT FK_FactIntervention_Case FOREIGN KEY (CaseID) REFERENCES Banking.FactCase(CaseID),
    CONSTRAINT FK_FactIntervention_InterventionType FOREIGN KEY (InterventionTypeID) REFERENCES Banking.DimInterventionType(InterventionTypeID),
    CONSTRAINT FK_FactIntervention_Date FOREIGN KEY (InterventionDateKey) REFERENCES Common.DateDim(DateKey),
    CONSTRAINT CK_FactIntervention_Outcome CHECK (Outcome IN ('Successful', 'Failed', 'Ignored')),
    CONSTRAINT CK_FactIntervention_CustomerResponse CHECK (CustomerResponse IN ('Accepted', 'Rejected', 'Ignored'))
);
CREATE TABLE Banking.FactReimbursement (
    ReimbursementID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseID BIGINT NOT NULL,
    AmountRequested DECIMAL(18,2) NOT NULL,
    AmountReimbursed DECIMAL(18,2) NOT NULL DEFAULT 0,
    DecisionDateKey INT NOT NULL,
    DecisionTimestamp DATETIME2 NOT NULL,
    ReimbursementStatus NVARCHAR(20) NOT NULL,
    ReasonCode NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_FactReimbursement_Case FOREIGN KEY (CaseID) REFERENCES Banking.FactCase(CaseID),
    CONSTRAINT FK_FactReimbursement_Date FOREIGN KEY (DecisionDateKey) REFERENCES Common.DateDim(DateKey),
    CONSTRAINT CK_FactReimbursement_Amounts CHECK (AmountRequested >= 0 AND AmountReimbursed >= 0 AND AmountReimbursed <= AmountRequested),
    CONSTRAINT CK_FactReimbursement_Status CHECK (ReimbursementStatus IN ('Approved','Rejected','Partial')      )
);
CREATE TABLE Banking.FactFundRecovery (
    RecoveryID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseID BIGINT NOT NULL,
    ReceivingBankName NVARCHAR(200) NOT NULL,
    AmountRequested DECIMAL(18,2) NOT NULL,
    AmountRecovered DECIMAL(18,2) NOT NULL DEFAULT 0,
    RecoveryDateKey INT NOT NULL,
    RecoveryTimestamp DATETIME2 NOT NULL,
    RecoveryStatus NVARCHAR(20) NOT NULL,
    CONSTRAINT FK_FactFundRecovery_Case FOREIGN KEY (CaseID) REFERENCES Banking.FactCase(CaseID),
    CONSTRAINT FK_FactFundRecovery_Date FOREIGN KEY (RecoveryDateKey) REFERENCES Common.DateDim(DateKey),
    CONSTRAINT CK_FactFundRecovery_Amounts CHECK (AmountRequested >= 0 AND AmountRecovered >= 0 AND AmountRecovered <= AmountRequested),
    CONSTRAINT CK_FactFundRecovery_Status CHECK (RecoveryStatus IN('Pending','Partial','Completed','Failed'))
);
CREATE TABLE Banking.FactRiskFeature (
    FeatureID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CustomerID BIGINT NOT NULL,
    AccountID BIGINT NOT NULL,
    FeatureDateKey INT NOT NULL,
    PaymentVelocity_1H INT NOT NULL DEFAULT 0,
    PaymentVelocity_24H INT NOT NULL DEFAULT 0,
    NewBeneficiaryCount_24H INT NOT NULL DEFAULT 0,
    UniqueBeneficiaries_7D INT NOT NULL DEFAULT 0,
    DeviceChangeFlag BIT NOT NULL DEFAULT 0,
    LocationChangeFlag BIT NOT NULL DEFAULT 0,
    AvgTransactionAmount_30D DECIMAL(18,2) NOT NULL DEFAULT 0,
    MaxTransactionAmount_30D DECIMAL(18,2) NOT NULL DEFAULT 0,
    RiskScoreDerived DECIMAL(5,2) NOT NULL,
    CONSTRAINT FK_FactRiskFeature_Customer FOREIGN KEY (CustomerID) REFERENCES Common.Customer(CustomerID),
    CONSTRAINT FK_FactRiskFeature_Account FOREIGN KEY (AccountID) REFERENCES Banking.DimAccount(AccountID),
    CONSTRAINT FK_FactRiskFeature_Date FOREIGN KEY (FeatureDateKey) REFERENCES Common.DateDim(DateKey),
    CONSTRAINT CK_FactRiskFeature_RiskScore CHECK (RiskScoreDerived BETWEEN 0 AND 100),
    CONSTRAINT CK_FactRiskFeature_Velocity CHECK (PaymentVelocity_1H >= 0 AND PaymentVelocity_24H >= 0),
    CONSTRAINT CK_FactRiskFeature_Beneficiaries CHECK (NewBeneficiaryCount_24H >= 0 AND UniqueBeneficiaries_7D >= 0),
    CONSTRAINT CK_FactRiskFeature_Amounts CHECK (AvgTransactionAmount_30D >= 0 AND MaxTransactionAmount_30D >= 0 AND MaxTransactionAmount_30D >= AvgTransactionAmount_30D)
);
--One feature snapshot per account per day:
ALTER TABLE Banking.FactRiskFeature
ADD CONSTRAINT UQ_FactRiskFeature
UNIQUE (AccountID, FeatureDateKey);

CREATE TABLE Banking.FactAccountNetwork (
    NetworkID BIGINT IDENTITY(1,1) PRIMARY KEY,
    AccountID BIGINT NOT NULL,
    ConnectedAccountID BIGINT NOT NULL,
    ConnectionType NVARCHAR(20) NOT NULL,
    FirstSeenDate DATE NOT NULL,
    ConnectionStrengthScore DECIMAL(5,2) NOT NULL,
    CONSTRAINT FK_FactAccountNetwork_Account FOREIGN KEY (AccountID)REFERENCES Banking.DimAccount(AccountID),
    CONSTRAINT FK_FactAccountNetwork_ConnectedAccount FOREIGN KEY (ConnectedAccountID)REFERENCES Banking.DimAccount(AccountID),
    CONSTRAINT CK_FactAccountNetwork_Type CHECK (ConnectionType IN('Sender','Receiver','SharedDevice')),
    CONSTRAINT CK_FactAccountNetwork_Streng CHECK (ConnectionStrengthScore BETWEEN 0 AND 100),
    CONSTRAINT CK_FactAccountNetwork_NoSelfLink CHECK (AccountID <> ConnectedAccountID)
);
--Prevent duplicate network relationships:
ALTER TABLE Banking.FactAccountNetwork
ADD CONSTRAINT UQ_FactAccountNetwork UNIQUE (
    AccountID,
    ConnectedAccountID,
    ConnectionType
);
-- =============================================
-- RETAIL DIMENSIONS (FULL)
-- =============================================

CREATE TABLE Retail.DimProduct (
    ProductKey INT IDENTITY PRIMARY KEY,
    ProductName NVARCHAR(200),
    SKU NVARCHAR(50) NOT NULL,
    Category NVARCHAR(100),
    SubCategory NVARCHAR(100),
    Brand NVARCHAR(100),
    UnitCost DECIMAL(18,2) NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    IsActive BIT DEFAULT 1,
    IsPerishable BIT DEFAULT 0,
	ShelfLifeDays INT NULL,
    CONSTRAINT UQ_Product_SKU UNIQUE (SKU),
    CONSTRAINT CK_Product_Price CHECK (UnitPrice >= 0),
    CONSTRAINT CK_Product_Cost CHECK (UnitCost >= 0),
    CONSTRAINT CK_Product_Margin CHECK (UnitPrice >= UnitCost),
    CONSTRAINT CK_Product_ShelfLife CHECK (ShelfLifeDays IS NULL OR ShelfLifeDays >= 0)
);

CREATE TABLE Retail.DimLocation (
    LocationKey INT IDENTITY PRIMARY KEY,
    LocationName NVARCHAR(200) NOT NULL,
    LocationType NVARCHAR(50),
    Region NVARCHAR(100),
    City NVARCHAR(100),
    Country NVARCHAR(100),
    IsOnlineFulfilment BIT DEFAULT 0,
	IsActive BIT DEFAULT 1,
    CONSTRAINT CK_Location_Type Check(LocationType IN('Store','Warehouse','Fulfilment Centre'))
);

CREATE TABLE Retail.DimSupplier (
    SupplierKey INT IDENTITY PRIMARY KEY,
    SupplierName NVARCHAR(200) NOT NULL,
    Country NVARCHAR(100),
    LeadTimeDays INT,
	ReliabilityScore DECIMAL(5,2),
	IsActive BIT DEFAULT 1,
    CONSTRAINT CK_Supplier_LeadTime CHECK (LeadTimeDays >= 0),
    CONSTRAINT CK_Supplier_Reliability CHECK (ReliabilityScore BETWEEN 0 AND 100)
);

CREATE TABLE Retail.Bridge_ProductSupplier (
    ProductKey INT NOT NULL,
    SupplierKey INT NOT NULL,
    ContractCost DECIMAL(18,2) NOT NULL,
    IsPrimarySupplier BIT DEFAULT 0,
    PRIMARY KEY (ProductKey, SupplierKey),
    FOREIGN KEY (ProductKey) REFERENCES Retail.DimProduct(ProductKey),
    FOREIGN KEY (SupplierKey) REFERENCES Retail.DimSupplier(SupplierKey),
    CONSTRAINT CK_ContractCost CHECK (ContractCost > 0)
);

CREATE TABLE Retail.DimChannel (
    ChannelKey INT IDENTITY PRIMARY KEY,
    ChannelName NVARCHAR(50) NOT NULL,
    CONSTRAINT CK_Channel CHECK (ChannelName IN ('Store','Online','Mobile','Marketplace'))
);

CREATE TABLE Retail.DimPromotion (
    PromotionKey INT IDENTITY PRIMARY KEY,
    PromotionName NVARCHAR(200),
    DiscountType NVARCHAR(20),
    DiscountValue DECIMAL(10,2),
    StartDate DATE,
    EndDate DATE,
    CONSTRAINT CK_DiscountType CHECK (DiscountType IN ('Percent','Amount')),
    CONSTRAINT CK_DiscountValue CHECK (DiscountValue >= 0),
    CONSTRAINT CK_Promo_Date CHECK (EndDate IS NULL OR EndDate >= StartDate)
);

CREATE TABLE Retail.DimReturnReason (
    ReturnReasonKey INT IDENTITY PRIMARY KEY,
    ReasonName NVARCHAR(200) NOT NULL
);

CREATE TABLE Retail.DimInventoryMovementType (
    MovementTypeKey INT IDENTITY PRIMARY KEY,
    MovementTypeName NVARCHAR(100),
    CONSTRAINT CK_MovementType CHECK (MovementTypeName IN ('Sale','Return','Receipt','Transfer','Adjustment','Damage','Waste'))
);

-- =============================================
-- RETAIL FACTS (FULL)
-- =============================================

CREATE TABLE Retail.FactSalesLine (
    SalesLineID BIGINT IDENTITY PRIMARY KEY,
    DateKey INT NOT NULL,
    TimeKey INT NOT NULL,
    ProductKey INT NOT NULL,
    LocationKey INT NOT NULL,
    CustomerID BIGINT NOT NULL,
    ChannelKey INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    DiscountAmount DECIMAL(18,2) DEFAULT 0,
    NetSalesAmount DECIMAL(18,2) NOT NULL,
    CostAmount DECIMAL(18,2) NOT NULL,
    GrossProfit DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (DateKey) REFERENCES Common.DateDim(DateKey),
    FOREIGN KEY (TimeKey) REFERENCES Common.TimeDim(TimeKey),
    FOREIGN KEY (ProductKey) REFERENCES Retail.DimProduct(ProductKey),
    FOREIGN KEY (LocationKey) REFERENCES Retail.DimLocation(LocationKey),
    FOREIGN KEY (CustomerID) REFERENCES Common.Customer(CustomerID),
    FOREIGN KEY (ChannelKey) REFERENCES Retail.DimChannel(ChannelKey),
    -- Business Rules
    CONSTRAINT CK_Sales_Qty CHECK (Quantity > 0),
    CONSTRAINT CK_Sales_Amounts CHECK (NetSalesAmount >= 0 AND CostAmount >= 0)
);

CREATE TABLE Retail.FactInventorySnapshot (
    SnapshotID BIGINT IDENTITY PRIMARY KEY,
    DateKey INT NOT NULL,
    ProductKey INT NOT NULL,
    LocationKey INT NOT NULL,
    OnHandQty INT,
    AvailableQty INT,
    ReservedQty INT,
    DamagedQty INT,
    InventoryValue DECIMAL(18,2),
    FOREIGN KEY (DateKey) REFERENCES Common.DateDim(DateKey),
    FOREIGN KEY (ProductKey) REFERENCES Retail.DimProduct(ProductKey),
    FOREIGN KEY (LocationKey) REFERENCES Retail.DimLocation(LocationKey),
    CONSTRAINT UQ_Inventory UNIQUE (ProductKey, LocationKey, DateKey),
    CONSTRAINT CK_Inventory_Qty CHECK (OnHandQty >= 0 AND AvailableQty >= 0 AND ReservedQty >= 0 AND DamagedQty >= 0),
    CONSTRAINT CK_Inventory_Availability CHECK (AvailableQty <= OnHandQty)
);

CREATE TABLE Retail.FactInventoryMovement (
    MovementID BIGINT IDENTITY PRIMARY KEY,
    DateKey INT NOT NULL,
    ProductKey INT NOT NULL,
    FromLocationKey INT NULL,
    ToLocationKey INT NULL,
    MovementTypeKey INT NOT NULL,
    Quantity INT,
    UnitCost DECIMAL(18,2),
    FOREIGN KEY (DateKey) REFERENCES Common.DateDim(DateKey),
    FOREIGN KEY (ProductKey) REFERENCES Retail.DimProduct(ProductKey),
    FOREIGN KEY (FromLocationKey) REFERENCES Retail.DimLocation(LocationKey),
    FOREIGN KEY (ToLocationKey) REFERENCES Retail.DimLocation(LocationKey),
    FOREIGN KEY (MovementTypeKey) REFERENCES Retail.DimInventoryMovementType(MovementTypeKey),
    CONSTRAINT CK_Movement_Qty CHECK (Quantity > 0),
    CONSTRAINT CK_Movement_Location CHECK (FromLocationKey IS NOT NULL OR ToLocationKey IS NOT NULL)
);

CREATE TABLE Retail.FactOnlineOrderLine (
    OrderLineID BIGINT IDENTITY PRIMARY KEY,
    DateKey INT NOT NULL,
    ProductKey INT NOT NULL,
    FulfilmentLocationKey INT NOT NULL,
    CustomerID BIGINT NOT NULL,
    OrderedQty INT,
    FulfilledQty INT,
    CancelledQty INT,
    SubstitutedQty INT,
    OrderStatus NVARCHAR(50),
    DeliveryDateKey INT,
    FOREIGN KEY (ProductKey) REFERENCES Retail.DimProduct(ProductKey),
    FOREIGN KEY (FulfilmentLocationKey) REFERENCES Retail.DimLocation(LocationKey),
    FOREIGN KEY (CustomerID) REFERENCES Common.Customer(CustomerID),
    FOREIGN KEY (DateKey) REFERENCES Common.DateDim(DateKey),
    FOREIGN KEY (DeliveryDateKey) REFERENCES Common.DateDim(DateKey),
    CONSTRAINT CK_Order_Qty
    CHECK (OrderedQty >= 0 AND FulfilledQty >= 0 AND CancelledQty >= 0 AND SubstitutedQty >= 0 AND FulfilledQty <= OrderedQty AND CancelledQty <= OrderedQty AND SubstitutedQty <= OrderedQty)
);

CREATE TABLE Retail.FactPurchaseOrderLine (
    PurchaseOrderLineID BIGINT IDENTITY PRIMARY KEY,
    ProductKey INT NOT NULL,
    SupplierKey INT NOT NULL,
    DestinationLocationKey INT NOT NULL,
    OrderDateKey INT,
    ExpectedDeliveryDateKey INT,
    OrderedQty INT,
    UnitCost DECIMAL(18,2),
    FOREIGN KEY (ProductKey) REFERENCES Retail.DimProduct(ProductKey),
    FOREIGN KEY (SupplierKey) REFERENCES Retail.DimSupplier(SupplierKey),
    FOREIGN KEY (DestinationLocationKey) REFERENCES Retail.DimLocation(LocationKey),
    FOREIGN KEY (OrderDateKey) REFERENCES Common.DateDim(DateKey),
    FOREIGN KEY (ExpectedDeliveryDateKey) REFERENCES Common.DateDim(DateKey),
    CONSTRAINT CK_PO_Qty CHECK (OrderedQty > 0)
);

CREATE TABLE Retail.FactGoodsReceipt (
    ReceiptID BIGINT IDENTITY PRIMARY KEY,
    PurchaseOrderLineID BIGINT,
    ProductKey INT,
    LocationKey INT,
    ReceiptDateKey INT,
    ReceivedQty INT,
    FOREIGN KEY (PurchaseOrderLineID) REFERENCES Retail.FactPurchaseOrderLine(PurchaseOrderLineID),
    FOREIGN KEY (ProductKey) REFERENCES Retail.DimProduct(ProductKey),
    FOREIGN KEY (LocationKey) REFERENCES Retail.DimLocation(LocationKey),
    FOREIGN KEY (ReceiptDateKey) REFERENCES Common.DateDim(DateKey),
    CONSTRAINT CK_Receipt_Qty CHECK (ReceivedQty > 0)
);

CREATE TABLE Retail.FactStockTransfer (
    TransferLineID BIGINT IDENTITY PRIMARY KEY,
    ProductKey INT NOT NULL,
    FromLocationKey INT NOT NULL,
    ToLocationKey INT NOT NULL,
    TransferDateKey INT,
    Quantity INT,
    TransferStatus NVARCHAR(50),
    FOREIGN KEY (ProductKey) REFERENCES Retail.DimProduct(ProductKey),
    FOREIGN KEY (FromLocationKey) REFERENCES Retail.DimLocation(LocationKey),
    FOREIGN KEY (ToLocationKey) REFERENCES Retail.DimLocation(LocationKey),
    FOREIGN KEY (TransferDateKey) REFERENCES Common.DateDim(DateKey),
    CONSTRAINT CK_Transfer_Qty CHECK (Quantity > 0),
    CONSTRAINT CK_Transfer_NoSelf CHECK (FromLocationKey <> ToLocationKey),
    CONSTRAINT CK_Transfer_Status CHECK (TransferStatus IN ('Pending','Approved','In Transit','Completed','Cancelled','Failed'))
);

CREATE TABLE Retail.FactReturnLine (
    ReturnLineID BIGINT IDENTITY PRIMARY KEY,
    SalesLineID BIGINT,
    ProductKey INT NOT NULL,
    LocationKey INT NOT NULL,
    ReturnDateKey INT NOT NULL,
    ReturnReasonKey INT NOT NULL,
    ReturnedQty INT,
    RefundAmount DECIMAL(18,2),
    IsResalable BIT,
    FOREIGN KEY (SalesLineID) REFERENCES Retail.FactSalesLine(SalesLineID),
    FOREIGN KEY (ProductKey) REFERENCES Retail.DimProduct(ProductKey),
    FOREIGN KEY (LocationKey) REFERENCES Retail.DimLocation(LocationKey),
    FOREIGN KEY (ReturnReasonKey) REFERENCES Retail.DimReturnReason(ReturnReasonKey),
    FOREIGN KEY (ReturnDateKey) REFERENCES Common.DateDim(DateKey),
    CONSTRAINT CK_Return_Qty CHECK (ReturnedQty > 0)
);

CREATE TABLE Retail.FactPromotionPerformance (
    PromoPerfID BIGINT IDENTITY PRIMARY KEY,
    ProductKey INT NOT NULL,
    LocationKey INT NOT NULL,
    PromotionKey INT NOT NULL,
    BaselineSalesQty INT,
    ActualSalesQty INT,
    IncrementalSalesQty INT,
    FOREIGN KEY (ProductKey) REFERENCES Retail.DimProduct(ProductKey),
    FOREIGN KEY (LocationKey) REFERENCES Retail.DimLocation(LocationKey),
    FOREIGN KEY (PromotionKey) REFERENCES Retail.DimPromotion(PromotionKey),
    CONSTRAINT CK_Baseline_SalesQty CHECK(BaselineSalesQty > 0 ),
    CONSTRAINT CK_Actual_SalesQty CHECK( ActualSalesQty > 0 )
);

CREATE TABLE Retail.FactForecast (
    ForecastID BIGINT IDENTITY PRIMARY KEY,
    ProductKey INT NOT NULL,
    LocationKey INT NOT NULL,
    DateKey INT NOT NULL,
    ForecastQty INT,
    ForecastValue DECIMAL(18,2),
    FOREIGN KEY (ProductKey) REFERENCES Retail.DimProduct(ProductKey),
    FOREIGN KEY (LocationKey) REFERENCES Retail.DimLocation(LocationKey),
    FOREIGN KEY (DateKey) REFERENCES Common.DateDim(DateKey)
);

-- =============================================
-- ENERGY DIMENSIONS (FULL)
-- =============================================
CREATE TABLE Energy.DimRegion (
    RegionKey INT IDENTITY PRIMARY KEY,
    RegionName NVARCHAR(100) NOT NULL,
    Country NVARCHAR(100),
    GridOperator NVARCHAR(100),
    MarketZone NVARCHAR(100)
);

CREATE TABLE Energy.DimAsset (
    AssetKey INT IDENTITY PRIMARY KEY,
    AssetName NVARCHAR(200) NOT NULL,
    AssetType NVARCHAR(50) NOT NULL,
    ParentAssetKey INT NULL,
    Technology NVARCHAR(100),
    CapacityMW DECIMAL(10,2) NOT NULL,
    CommissionDate DATE,
    DecommissionDate DATE NULL,
    RegionKey INT NOT NULL,
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (RegionKey) REFERENCES Energy.DimRegion(RegionKey),
    FOREIGN KEY (ParentAssetKey) REFERENCES Energy.DimAsset(AssetKey),
    -- ✅ Lifecycle rule
    CONSTRAINT CK_Asset_Dates CHECK (DecommissionDate IS NULL OR DecommissionDate >= CommissionDate),
    CONSTRAINT CK_Asset_Type CHECK (AssetType IN ('Wind','Solar','Battery')),
    -- Capacity must be positive
    CONSTRAINT CK_Asset_Capacity CHECK (CapacityMW > 0),
);
CREATE TABLE Energy.DimWeatherStation (
    WeatherStationKey INT IDENTITY PRIMARY KEY,
    StationName NVARCHAR(200),
    RegionKey INT,
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    FOREIGN KEY (RegionKey) REFERENCES Energy.DimRegion(RegionKey)
);
CREATE TABLE Energy.DimMarket (
    MarketKey INT IDENTITY PRIMARY KEY,
    MarketName NVARCHAR(100),
    Currency NVARCHAR(10)
);

CREATE TABLE Energy.DimMarketService (
    ServiceKey INT IDENTITY PRIMARY KEY,
    ServiceName NVARCHAR(100) NOT NULL
);
CREATE TABLE Energy.DimCurtailmentReason (
    CurtailmentReasonKey INT IDENTITY PRIMARY KEY,
    ReasonName NVARCHAR(200)
);
CREATE TABLE Energy.DimOutageReason (
    OutageReasonKey INT IDENTITY PRIMARY KEY,
    ReasonName NVARCHAR(200)
);
CREATE TABLE Energy.DimMaintenanceType (
    MaintenanceTypeKey INT IDENTITY PRIMARY KEY,
    TypeName NVARCHAR (100)
);
CREATE TABLE Energy.DimAssetComponent (
    ComponentKey INT IDENTITY PRIMARY KEY,
    AssetKey INT NOT NULL,
    ComponentName NVARCHAR(200),
    ComponentType NVARCHAR(100),
    Manufacturer NVARCHAR(100),
    InstallDate DATE,
    FOREIGN KEY (AssetKey) REFERENCES Energy.DimAsset(AssetKey),
);
CREATE TABLE Energy.DimCounterparty (
    CounterpartyKey INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(200),
    Type NVARCHAR(100)
);
-- =============================================
-- ENERGY FACTS (FULL)
-- =============================================

CREATE TABLE Energy.FactEnergyInterval (
    IntervalID BIGINT IDENTITY PRIMARY KEY,
    AssetKey INT NOT NULL,
    DateKey INT NOT NULL,
    TimeKey INT NOT NULL,

    ActualGenerationMWh DECIMAL(18,4),
    ForecastGenerationMWh DECIMAL(18,4),
    CurtailmentMWh DECIMAL(18,4),

    DemandMWh DECIMAL(18,4),
    MarketPrice DECIMAL(18,4),

    BatteryChargeMWh DECIMAL(18,4),
    BatteryDischargeMWh DECIMAL(18,4),
    StateOfChargePct DECIMAL(5,2),

    AvailabilityPct DECIMAL(5,2),
    CarbonIntensity DECIMAL(10,4),
    DegradationCost DECIMAL(18,4),
    FOREIGN KEY (AssetKey) REFERENCES Energy.DimAsset(AssetKey),
    FOREIGN KEY (DateKey) REFERENCES Common.DateDim(DateKey),
    FOREIGN KEY (TimeKey) REFERENCES Common.TimeDim(TimeKey),
    -- ✅ Business rules
    CONSTRAINT CK_Energy_Positive CHECK (
    ActualGenerationMWh >= 0 AND
    ForecastGenerationMWh >= 0 AND
    CurtailmentMWh >= 0 AND
    DemandMWh >= 0 AND
    BatteryChargeMWh >= 0 AND
    BatteryDischargeMWh >= 0 AND
    DegradationCost >= 0),
    CONSTRAINT CK_SOC CHECK (StateOfChargePct BETWEEN 0 AND 100),
    CONSTRAINT CK_AvailabilityPct CHECK (AvailabilityPct BETWEEN 0 AND 100)
);

CREATE TABLE Energy.FactCurtailmentEvent (
    CurtailmentEventID BIGINT IDENTITY PRIMARY KEY,
    AssetKey INT NOT NULL,
    StartTimestamp DATETIME2,
    EndTimestamp DATETIME2,

    CurtailmentReasonKey INT,

    EnergyLostMWh DECIMAL(18,4),
    EstimatedRevenueLoss DECIMAL(18,2),

    ConstraintRegionKey INT,
    ConstraintMW DECIMAL(18,4),

    FOREIGN KEY (AssetKey) REFERENCES Energy.DimAsset(AssetKey),
    FOREIGN KEY (CurtailmentReasonKey) REFERENCES Energy.DimCurtailmentReason(CurtailmentReasonKey),
    FOREIGN KEY (ConstraintRegionKey) REFERENCES Energy.DimRegion(RegionKey),
    -- Time logic
    CONSTRAINT CK_Curtailment_Time CHECK (EndTimestamp IS NULL OR EndTimestamp >= StartTimestamp),
    -- Energy + constraint logic
    CONSTRAINT CK_Curtailment_Values CHECK (EnergyLostMWh >= 0 AND ConstraintMW >= 0)
);

CREATE TABLE Energy.FactDispatchInstruction (
    DispatchID BIGINT IDENTITY PRIMARY KEY,
    AssetKey INT NOT NULL,
    ServiceKey INT,

    InstructionTimestamp DATETIME2,
    InstructionType NVARCHAR(50),

    RequestedMW DECIMAL(18,4),
    DeliveredMW DECIMAL(18,4),

    FOREIGN KEY (AssetKey) REFERENCES Energy.DimAsset(AssetKey),
    FOREIGN KEY (ServiceKey) REFERENCES Energy.DimMarketService(ServiceKey),
    CONSTRAINT CK_Dispatch CHECK (RequestedMW >= 0 AND DeliveredMW >= 0 AND DeliveredMW <= RequestedMW),
    CONSTRAINT CK_Dispatch_Type CHECK (InstructionType IN ('Charge','Discharge','Curtail','Increase','Decrease'))
);

CREATE TABLE Energy.FactWeatherObservation (
    WeatherObsID BIGINT IDENTITY PRIMARY KEY,
    WeatherStationKey INT,
    DateKey INT NOT NULL,
    TimeKey INT NOT NULL,

    WindSpeed DECIMAL(10,4),
    SolarIrradiance DECIMAL(10,4),
    Temperature DECIMAL(10,2),

    FOREIGN KEY (WeatherStationKey) REFERENCES Energy.DimWeatherStation(WeatherStationKey),
    FOREIGN KEY (DateKey) REFERENCES Common.DateDim(DateKey),
    FOREIGN KEY (TimeKey) REFERENCES Common.TimeDim(TimeKey),
    CONSTRAINT CK_Weather_Positive CHECK (WindSpeed >= 0 AND SolarIrradiance >= 0 AND Temperature > -100 AND Temperature < 100)
);

CREATE TABLE Energy.FactAssetAvailability (
    AvailabilityID BIGINT IDENTITY PRIMARY KEY,
    AssetKey INT NOT NULL,
    DateKey INT NOT NULL,

    AvailableHours DECIMAL(10,2),
    TotalHours DECIMAL(10,2),
    AvailabilityPct DECIMAL(5,2),

    FOREIGN KEY (AssetKey) REFERENCES Energy.DimAsset(AssetKey),
    FOREIGN KEY (DateKey) REFERENCES Common.DateDim(DateKey),
    CONSTRAINT CK_Availability CHECK (AvailableHours >= 0 AND TotalHours > 0 AND AvailableHours <= TotalHours AND AvailabilityPct BETWEEN 0 AND 100)
);

CREATE TABLE Energy.FactMaintenanceWorkOrder (
    WorkOrderID BIGINT IDENTITY PRIMARY KEY,
    AssetKey INT NOT NULL,
    ComponentKey INT,
    MaintenanceTypeKey INT,

    StartDate DATE,
    EndDate DATE,

    Cost DECIMAL(18,2),
    DowntimeHours DECIMAL(10,2),

    FOREIGN KEY (AssetKey) REFERENCES Energy.DimAsset(AssetKey),
    FOREIGN KEY (ComponentKey) REFERENCES Energy.DimAssetComponent(ComponentKey),
    FOREIGN KEY (MaintenanceTypeKey) REFERENCES Energy.DimMaintenanceType(MaintenanceTypeKey),
    CONSTRAINT CK_Maintenance_Time CHECK (EndDate IS NULL OR EndDate >= StartDate),
    CONSTRAINT CK_Maintenance_Values CHECK (Cost >= 0 AND DowntimeHours >= 0)
);
CREATE TABLE Energy.FactAssetFault (
    FaultID BIGINT IDENTITY PRIMARY KEY,
    AssetKey INT NOT NULL,
    ComponentKey INT,

    FaultTimestamp DATETIME2,
    OutageReasonKey INT,
    DowntimeHours DECIMAL(10,2),

    FOREIGN KEY (AssetKey) REFERENCES Energy.DimAsset(AssetKey),
    FOREIGN KEY (ComponentKey) REFERENCES Energy.DimAssetComponent(ComponentKey),
    FOREIGN KEY (OutageReasonKey) REFERENCES Energy.DimOutageReason(OutageReasonKey),
    CONSTRAINT CK_Fault_Values CHECK (DowntimeHours >= 0)
);

CREATE TABLE Energy.FactCommercialSettlement (
    SettlementID BIGINT IDENTITY PRIMARY KEY,
    AssetKey INT NOT NULL,
    MarketKey INT,
    CounterpartyKey INT,
    DateKey INT NOT NULL,

    EnergySoldMWh DECIMAL(18,4),
    Revenue DECIMAL(18,2),
    Cost DECIMAL(18,2),
    NetProfit DECIMAL(18,2),

    FOREIGN KEY (AssetKey) REFERENCES Energy.DimAsset(AssetKey),
    FOREIGN KEY (MarketKey) REFERENCES Energy.DimMarket(MarketKey),
    FOREIGN KEY (CounterpartyKey) REFERENCES Energy.DimCounterparty(CounterpartyKey),
    FOREIGN KEY (DateKey) REFERENCES Common.DateDim(DateKey),
    CONSTRAINT CK_Commercial_Positive CHECK ( EnergySoldMWh >= 0 AND Revenue >= 0 AND Cost >= 0)
);

CREATE TABLE Energy.FactGenerationAnomaly (
    AnomalyID BIGINT IDENTITY PRIMARY KEY,
    AssetKey INT NOT NULL,
    DateKey INT NOT NULL,
    TimeKey INT NOT NULL,

    ExpectedGeneration DECIMAL(18,4),
    ActualGeneration DECIMAL(18,4),
    DeviationPct DECIMAL(5,2),

    RevenueImpact DECIMAL(18,2),
    CarbonImpact DECIMAL(18,4),

    FOREIGN KEY (AssetKey) REFERENCES Energy.DimAsset(AssetKey),
    FOREIGN KEY (DateKey) REFERENCES Common.DateDim(DateKey),
    FOREIGN KEY (TimeKey) REFERENCES Common.TimeDim(TimeKey),
    CONSTRAINT CK_Anomaly_Deviation CHECK (DeviationPct BETWEEN -100 AND 100),
    CONSTRAINT CK_Anomaly_Values CHECK (ExpectedGeneration >= 0 AND ActualGeneration >= 0)
);

-- =============================================
-- END OF FULL ENTERPRISE SCRIPT
-- =============================================
