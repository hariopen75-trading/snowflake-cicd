# Snowflake × GitHub CI/CD

## Architecture
```
GitHub Push
    │
    ▼
GitHub Actions (.github/workflows/snowflake_cicd.yml)
    │
    ├── Job 1: Lint SQL + validate notebooks
    ├── Job 2: Run data quality tests vs Snowflake
    └── Job 3: Deploy (main branch only)
              │
              ▼
         Snowflake REST API
              │
              ├── ALTER GIT REPOSITORY ... FETCH   ← sync latest commit
              ├── EXECUTE NOTEBOOK snowflake_cicd_notebook()
              └── EXECUTE TASK cicd_manual_deploy

Snowflake Side (running independently every hour):
    cicd_hourly_deploy TASK
         │
         └── CALL run_cicd_notebook()
                   │
                   ├── Fetch GitHub → Snowflake Git Repository
                   ├── Run migrations/ SQL files
                   ├── Data quality tests
                   ├── Refresh Dynamic Tables
                   └── Log to cicd_run_log table
```

## Snowflake Objects Created
| Object | Type | Location |
|--------|------|----------|
| `snowflake_github_integration` | API Integration | Account |
| `snowflake_cicd_repo` | Git Repository | DEMO_DB.ANALYTICS |
| `cicd_run_log` | Table | DEMO_DB.ANALYTICS |
| `run_cicd_notebook` | Stored Procedure | DEMO_DB.ANALYTICS |
| `cicd_hourly_deploy` | Task (scheduled) | DEMO_DB.ANALYTICS |
| `cicd_manual_deploy` | Task (on-demand) | DEMO_DB.ANALYTICS |
| `snowflake_cicd_notebook` | Notebook | DEMO_DB.ANALYTICS |
| `cicd_stage` | Internal Stage | DEMO_DB.ANALYTICS |

## GitHub Repo Structure
```
snowflake-cicd/
├── .github/
│   └── workflows/
│       └── snowflake_cicd.yml   ← GitHub Actions CI/CD
├── notebooks/
│   └── cicd_pipeline.ipynb      ← Main CI/CD Notebook
├── migrations/
│   ├── 001_initial_schema.sql
│   └── 002_analytics_tables.sql
├── sql/
│   └── (additional SQL scripts)
└── README.md
```

## Setup Steps

### 1. Create GitHub Repository
```bash
# Create repo: github.com/hariopen75/snowflake-cicd
gh repo create hariopen75/snowflake-cicd --public --description "Snowflake CI/CD"
```

### 2. Push files
```bash
cd /tmp/snowflake-cicd   # or wherever you want the repo
git init
git remote add origin https://github.com/hariopen75/snowflake-cicd.git

# Copy files from local snowwork/cicd/
cp -r /path/to/snowwork/cicd/notebooks ./
cp -r /path/to/snowwork/cicd/migrations ./
cp /path/to/snowwork/cicd/github-actions/snowflake_cicd.yml .github/workflows/

git add .
git commit -m "Initial CI/CD setup"
git push -u origin main
```

### 3. Add GitHub Secrets
GitHub → Repo → Settings → Secrets and variables → Actions → New secret:
| Secret Name | Value |
|-------------|-------|
| `SNOWFLAKE_ACCOUNT` | `vnmuivc-fjc24794` |
| `SNOWFLAKE_USER` | `HARIOPEN75` |
| `SNOWFLAKE_PASSWORD` | `SnowDemo2026Admin` |
| `SNOWFLAKE_WAREHOUSE` | `DEMO_WH` |
| `SNOWFLAKE_DATABASE` | `DEMO_DB` |
| `SNOWFLAKE_SCHEMA` | `ANALYTICS` |
| `SNOWFLAKE_ROLE` | `DEVELOPER_ROLE` |

### 4. Connect GitHub Repo to Snowflake Git Integration
Once the GitHub repo exists, run in Snowflake:
```sql
USE ROLE ACCOUNTADMIN;
ALTER API INTEGRATION snowflake_github_integration SET ENABLED = TRUE;

CREATE OR REPLACE GIT REPOSITORY demo_db.analytics.snowflake_cicd_repo
    API_INTEGRATION = snowflake_github_integration
    ORIGIN          = 'https://github.com/hariopen75/snowflake-cicd';

ALTER GIT REPOSITORY demo_db.analytics.snowflake_cicd_repo FETCH;
```

### 5. Open the Notebook in Snowflake Workspace
- Snowsight → Notebooks → `snowflake_cicd_notebook`
- Or navigate: https://app.snowflake.com/us-east-1/cjc98824/#/notebooks

## Triggering a Deploy
```bash
# Option A: Push to GitHub main branch (triggers Actions)
git push origin main

# Option B: Manual trigger in Snowflake
EXECUTE TASK demo_db.analytics.cicd_manual_deploy;

# Option C: GitHub Actions → Run workflow (manual dispatch)
# GitHub → Actions → Snowflake CI/CD → Run workflow

# Option D: REST API call
curl -X POST \
  -H "Authorization: Bearer $SNOWFLAKE_TOKEN" \
  "https://vnmuivc-fjc24794.snowflakecomputing.com/api/v2/tasks/demo_db.analytics.cicd_manual_deploy/execute"
```

## Monitor
```sql
-- View recent CI/CD runs
SELECT * FROM demo_db.analytics.cicd_run_log ORDER BY run_time DESC LIMIT 10;

-- Task run history
SELECT NAME, STATE, SCHEDULED_TIME, COMPLETED_TIME, ERROR_MESSAGE
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(TASK_NAME => 'CICD_HOURLY_DEPLOY'));

-- Current task status
SHOW TASKS IN SCHEMA demo_db.analytics;
```
