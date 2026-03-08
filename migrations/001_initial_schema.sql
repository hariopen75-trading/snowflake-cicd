-- Migration 001: Initial schema
-- Applied by: CI/CD pipeline on deploy
-- Run order : 001 (first)

USE ROLE DEVELOPER_ROLE;
USE DATABASE DEMO_DB;
USE SCHEMA DEMO_DB.RAW;

CREATE TABLE IF NOT EXISTS demo_db.raw.orders (
    order_id    NUMBER        NOT NULL,
    customer_id NUMBER,
    product_id  NUMBER,
    amount      FLOAT,
    status      VARCHAR(50),
    region      VARCHAR(50),
    order_date  DATE,
    created_at  TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT pk_orders PRIMARY KEY (order_id)
);

CREATE TABLE IF NOT EXISTS demo_db.raw.customers (
    customer_id NUMBER        NOT NULL,
    name        VARCHAR(200),
    email       VARCHAR(200),
    region      VARCHAR(50),
    created_at  TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT pk_customers PRIMARY KEY (customer_id)
);
