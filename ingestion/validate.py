import pandas as pd

REQUIRED_COLUMNS = [
    "claim_id",
    "policy_id",
    "customer_id",
    "claim_amount",
    "claim_status",
    "event_date",
    "updated_at",
]

VALID_STATUSES = {"PENDING", "APPROVED", "REJECTED", "CLOSED"}


def validate_claims(df: pd.DataFrame):
    missing_cols = set(REQUIRED_COLUMNS) - set(df.columns)
    if missing_cols:
        raise ValueError(f"Missing required columns: {missing_cols}")

    df = df[REQUIRED_COLUMNS].copy()

    df["claim_amount"] = pd.to_numeric(df["claim_amount"], errors="coerce")
    df["event_date"] = pd.to_datetime(df["event_date"], errors="coerce").dt.date
    df["updated_at"] = pd.to_datetime(df["updated_at"], errors="coerce")

    valid_mask = (
        df["claim_id"].notna()
        & (df["claim_id"].astype(str).str.strip() != "")
        & df["policy_id"].notna()
        & df["customer_id"].notna()
        & df["claim_amount"].notna()
        & (df["claim_amount"] >= 0)
        & df["claim_status"].isin(VALID_STATUSES)
        & df["event_date"].notna()
        & df["updated_at"].notna()
    )

    good_records = df[valid_mask].copy()
    bad_records = df[~valid_mask].copy()

    return good_records, bad_records
