# Three-Environment CI/CD Demo

## Pipeline: develop → uat → main

| Branch | Environment | Workflow |
|--------|-------------|----------|
| develop | DEV_DB | Deploy to DEV |
| uat | UAT_DB | Deploy to UAT |
| main | PROD_DB | Deploy to PROD |

### Snowflake Notebooks
- DEV_DB.ANALYTICS.DEV_PIPELINE_NB
- UAT_DB.ANALYTICS.UAT_PIPELINE_NB
- PROD_DB.ANALYTICS.PROD_PIPELINE_NB
