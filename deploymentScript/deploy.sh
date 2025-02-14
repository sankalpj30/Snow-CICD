#!/bin/bash

# Check if environment parameter is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

ENVIRONMENT=$1

# Map environment to corresponding database and schema
case "$ENVIRONMENT" in
    dev)
        DB="DEV_DB_CICD"
        SCHEMA="DEV_SCHEMA"
        ;;
    qa)
        DB="QA_DB_CICD"
        SCHEMA="QA_SCHEMA"
        ;;
    pre-prod)
        DB="PREPROD_DB_CICD"
        SCHEMA="PREPROD_SCHEMA"
        ;;
    prod)
        DB="PROD_DB_CICD"
        SCHEMA="PROD_SCHEMA"
        ;;
    *)
        echo "Invalid environment: $ENVIRONMENT. Must be one of dev, qa, pre-prod, prod."
        exit 1
        ;;
esac

echo "🚀 Deploying to Snowflake Environment: $ENVIRONMENT"
echo "Using Database: $DB and Schema: $SCHEMA"

# Set database and schema for the current session
echo "Setting database and schema..."
snow sql -q "USE DATABASE $DB; USE SCHEMA $SCHEMA;"

# Define the directory that contains the SQL scripts for the given environment
SQL_DIR="sql/$ENVIRONMENT"

if [ ! -d "$SQL_DIR" ]; then
    echo "❌ Error: SQL directory '$SQL_DIR' not found."
    exit 1
fi

echo "📂 Deploying SQL scripts from directory: $SQL_DIR"

# Recursively find and execute all .sql files in the SQL directory and its subdirectories
find "$SQL_DIR" -type f -name "*.sql" | sort | while read -r sqlfile; do
    echo "📜 Executing $sqlfile..."
    snow sql -f "$sqlfile"
    if [ $? -ne 0 ]; then
        echo "❌ Error executing $sqlfile"
        exit 1
    fi
done

echo "🎉 Deployment to $ENVIRONMENT completed successfully."
