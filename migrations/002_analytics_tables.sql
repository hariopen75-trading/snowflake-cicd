-- Migration 002: Analytics layer tables
-- Applied by: CI/CD pipeline on deploy
-- Depends on: 001_initial_schema.sql


CREATE TABLE IF NOT EXISTS DEMO_DB.ANALYTICS.cicd_run_log (
    run_id        NUMBER AUTOINCREMENT PRIMARY KEY,
    run_time      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    completed_at  TIMESTAMP_NTZ,
    branch        VARCHAR(100)  DEFAULT 'main',
    notebook_path VARCHAR(500),
    triggered_by  VARCHAR(100)  DEFAULT CURRENT_USER(),
    commit_sha    VARCHAR(40),
    status        VARCHAR(20),
    error_message VARCHAR(2000),
    duration_sec  NUMBER AS (DATEDIFF('second', run_time, completed_at))
);

CREATE TABLE IF NOT EXISTS DEMO_DB.ANALYTICS.customer_summary (
    customer_id   NUMBER,
    customer_name VARCHAR(200),
    region        VARCHAR(50),
    total_orders  NUMBER   DEFAULT 0,
    total_spent   FLOAT    DEFAULT 0.0,
    last_order_dt DATE,
    updated_at    TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

