import argparse
import uuid
from pathlib import Path
from datetime import datetime, timezone

import pandas as pd
import snowflake.connector

from ingestion.config import SNOWFLAKE_CONFIG
from ingestion.validate import validate_claims


TARGET_COLUMNS = [
    "CLAIM_ID",
    "POLICY_ID",
    "CUSTOMER_ID",
    "CLAIM_AMOUNT",
    "CLAIM_STATUS",
    "EVENT_DATE",
    "UPDATED_AT",
    "BATCH_ID",
    "INGESTION_TIME",
    "SOURCE_FILE_NAME",
]


def load_dataframe_to_snowflake(df: pd.DataFrame, table_name: str):
    if df.empty:
        return 0

    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)

    try:
        cursor = conn.cursor()
        placeholders = ", ".join(["%s"] * len(TARGET_COLUMNS))
        column_list = ", ".join(TARGET_COLUMNS)

        insert_sql = f'''
            INSERT INTO {table_name} ({column_list})
            VALUES ({placeholders})
        '''

        rows = [tuple(row[col] for col in TARGET_COLUMNS) for _, row in df.iterrows()]
        cursor.executemany(insert_sql, rows)
        conn.commit()

        return len(rows)

    finally:
        conn.close()


def ingest_claims(file_path: str):
    file_path = Path(file_path)
    batch_id = str(uuid.uuid4())
    ingestion_time = datetime.now(timezone.utc).replace(tzinfo=None)

    df = pd.read_csv(file_path)
    good_records, bad_records = validate_claims(df)

    good_records["batch_id"] = batch_id
    good_records["ingestion_time"] = ingestion_time
    good_records["source_file_name"] = file_path.name

    good_records["event_date"] = good_records["event_date"].astype(str)
    good_records["updated_at"] = good_records["updated_at"].astype(str)
    good_records["ingestion_time"] = good_records["ingestion_time"].astype(str)

    good_records.columns = [col.upper() for col in good_records.columns]

    rows_loaded = load_dataframe_to_snowflake(good_records, table_name="CLAIMS_RAW")

    Path("logs").mkdir(exist_ok=True)

    if not bad_records.empty:
        bad_records.to_csv(f"logs/bad_claims_{batch_id}.csv", index=False)

    print({
        "batch_id": batch_id,
        "source_file": str(file_path),
        "rows_extracted": len(df),
        "rows_loaded": rows_loaded,
        "rows_rejected": len(bad_records),
    })


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--file", required=True, help="Path to claims CSV file")
    args = parser.parse_args()

    ingest_claims(args.file)
