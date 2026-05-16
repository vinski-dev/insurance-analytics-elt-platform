from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator

PROJECT_ROOT = "/opt/airflow/project"
DBT_PROJECT_DIR = f"{PROJECT_ROOT}/dbt_project"

with DAG(
    dag_id="insurance_claims_elt_pipeline",
    start_date=datetime(2026, 5, 1),
    schedule="@daily",
    catchup=False,
    tags=["insurance", "snowflake", "dbt"],
) as dag:

    ingest_claims = BashOperator(
        task_id="ingest_claims_to_snowflake",
        bash_command=(
            f"cd {PROJECT_ROOT} && "
            "python -m ingestion.load_claims "
            "--file data/claims_batch_01_initial.csv"
        ),
    )

    dbt_run = BashOperator(
        task_id="run_dbt_models",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt run",
    )

    dbt_test = BashOperator(
        task_id="run_dbt_tests",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt test",
    )

    ingest_claims >> dbt_run >> dbt_test