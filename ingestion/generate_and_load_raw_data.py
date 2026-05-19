import os
import random
from pathlib import Path
from datetime import datetime, timedelta

import pandas as pd
import snowflake.connector
from dotenv import load_dotenv


env_path = Path(__file__).resolve().parent.parent / ".env"
load_dotenv(dotenv_path=env_path)


NUM_CUSTOMERS = 500
NUM_POLICIES = 1000
NUM_PAYMENTS = 1500


def random_datetime(days_back: int = 365) -> datetime:
    return datetime.utcnow() - timedelta(days=random.randint(0, days_back))


def generate_customers() -> pd.DataFrame:
    first_names = ["Juan", "Maria", "Jose", "Ana", "Carlo", "Liza", "Mark", "Grace"]
    last_names = ["Santos", "Reyes", "Cruz", "Garcia", "Mendoza", "Torres", "Lim"]

    rows = []
    for i in range(1, NUM_CUSTOMERS + 1):
        customer_id = f"CUST_{i:05d}"
        first_name = random.choice(first_names)
        last_name = random.choice(last_names)

        rows.append({
            "customer_id": customer_id,
            "first_name": first_name,
            "last_name": last_name,
            "email": f"{first_name.lower()}.{last_name.lower()}{i}@example.com",
            "updated_at": random_datetime(180),
            "ingestion_time": datetime.utcnow(),
        })

    return pd.DataFrame(rows)


def generate_policies(customers_df: pd.DataFrame) -> pd.DataFrame:
    policy_types = ["AUTO", "HOME", "HEALTH", "LIFE", "TRAVEL"]
    statuses = ["ACTIVE", "LAPSED", "CANCELLED"]

    rows = []
    for i in range(1, NUM_POLICIES + 1):
        policy_id = f"POL_{i:05d}"
        policy_type = random.choice(policy_types)

        base_premium = {
            "AUTO": (800, 3500),
            "HOME": (1200, 6000),
            "HEALTH": (1500, 9000),
            "LIFE": (1000, 8000),
            "TRAVEL": (300, 2500),
        }[policy_type]

        rows.append({
            "policy_id": policy_id,
            "customer_id": random.choice(customers_df["customer_id"].tolist()),
            "policy_type": policy_type,
            "premium_amount": round(random.uniform(*base_premium), 2),
            "policy_status": random.choice(statuses),
            "updated_at": random_datetime(180),
            "ingestion_time": datetime.utcnow(),
        })

    return pd.DataFrame(rows)


def generate_payments(policies_df: pd.DataFrame) -> pd.DataFrame:
    rows = []

    for i in range(1, NUM_PAYMENTS + 1):
        policy = policies_df.sample(1).iloc[0]
        payment_date = datetime.utcnow().date() - timedelta(days=random.randint(0, 365))

        # payments roughly align to policy premium
        payment_amount = round(float(policy["premium_amount"]) / random.choice([1, 2, 4, 12]), 2)

        rows.append({
            "payment_id": f"PAY_{i:05d}",
            "policy_id": policy["policy_id"],
            "payment_amount": payment_amount,
            "payment_date": payment_date,
            "updated_at": random_datetime(180),
            "ingestion_time": datetime.utcnow(),
        })

    return pd.DataFrame(rows)


def get_connection():
    return snowflake.connector.connect(
        user=os.getenv("SNOWFLAKE_USER"),
        password=os.getenv("SNOWFLAKE_PASSWORD"),
        account=os.getenv("SNOWFLAKE_ACCOUNT"),
        warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
        database="INSURANCE_DW",
        schema="RAW",
        role=os.getenv("SNOWFLAKE_ROLE"),
    )


def load_dataframe(cur, df: pd.DataFrame, table_name: str):
    columns = list(df.columns)
    placeholders = ", ".join(["%s"] * len(columns))
    column_list = ", ".join(columns)

    sql = f"""
        INSERT INTO INSURANCE_DW.RAW.{table_name}
        ({column_list})
        VALUES ({placeholders})
    """

    rows = [tuple(row) for row in df.to_numpy()]
    cur.executemany(sql, rows)

    print(f"Loaded {len(rows)} rows into {table_name}")


def main():
    customers_df = generate_customers()
    policies_df = generate_policies(customers_df)
    payments_df = generate_payments(policies_df)

    conn = get_connection()
    cur = conn.cursor()

    try:
        load_dataframe(cur, customers_df, "CUSTOMERS_RAW")
        load_dataframe(cur, policies_df, "POLICIES_RAW")
        load_dataframe(cur, payments_df, "PAYMENTS_RAW")
        conn.commit()
        print("Synthetic raw data load completed.")
    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    main()