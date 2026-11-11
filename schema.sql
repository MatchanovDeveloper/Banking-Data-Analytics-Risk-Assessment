-- Bank loyihasi: PostgreSQL schema va yuklash skripti
-- CSV fayllar "data" papkasida. psql orqali ishga tushiring (\copy mijoz tomonida ishlaydi).

DROP TABLE IF EXISTS loan_payments, loans, transactions, accounts, customers, branches CASCADE;

CREATE TABLE branches (
    branch_id     INT PRIMARY KEY,
    branch_name   VARCHAR(100) NOT NULL,
    region        VARCHAR(50)  NOT NULL,
    opened_date   DATE
);

CREATE TABLE customers (
    customer_id         INT PRIMARY KEY,
    first_name          VARCHAR(50),
    last_name           VARCHAR(50),
    gender              CHAR(1),
    birth_date          DATE,
    occupation          VARCHAR(50),
    monthly_income_uzs  BIGINT,
    segment             VARCHAR(20),
    registration_date   DATE,
    branch_id           INT REFERENCES branches(branch_id),
    phone               VARCHAR(20),
    status              VARCHAR(20)
);

CREATE TABLE accounts (
    account_id    INT PRIMARY KEY,
    customer_id   INT REFERENCES customers(customer_id),
    account_type  VARCHAR(20),
    opened_date   DATE,
    balance       NUMERIC(18,2),
    currency      CHAR(3),
    status        VARCHAR(20)
);

CREATE TABLE transactions (
    transaction_id    INT PRIMARY KEY,
    account_id        INT REFERENCES accounts(account_id),
    transaction_date  TIMESTAMP,
    transaction_type  VARCHAR(20),
    amount            NUMERIC(18,2),
    currency          CHAR(3),
    merchant          VARCHAR(100),
    category          VARCHAR(50),
    channel           VARCHAR(30),
    location          VARCHAR(50),
    status            VARCHAR(20)
);

CREATE TABLE loans (
    loan_id          INT PRIMARY KEY,
    customer_id      INT REFERENCES customers(customer_id),
    branch_id        INT REFERENCES branches(branch_id),
    loan_type        VARCHAR(30),
    loan_amount_uzs  BIGINT,
    interest_rate    NUMERIC(5,2),
    term_months      INT,
    issue_date       DATE,
    status           VARCHAR(20)
);

CREATE TABLE loan_payments (
    payment_id      INT PRIMARY KEY,
    loan_id         INT REFERENCES loans(loan_id),
    installment_no  INT,
    due_date        DATE,
    paid_date       DATE,
    amount_due      NUMERIC(18,2),
    amount_paid     NUMERIC(18,2),
    payment_status  VARCHAR(20)
);



SELECT 'branches' AS jadval, COUNT(*) FROM branches
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL SELECT 'loans', COUNT(*) FROM loans
UNION ALL SELECT 'loan_payments', COUNT(*) FROM loan_payments;

