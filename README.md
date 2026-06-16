# Sluice: Customer 360 Data Refinery

A domain-separated, ELT-style data platform that lands a dirty multi-domain dataset into Snowflake, conforms and models it with layered SQL, and serves a unified customer view. Built as an architecture-first learning and portfolio artifact: the reasoning behind each boundary matters as much as the running system.

Stack: Python, Azure Blob Storage, Snowflake, Apache Airflow, Terraform, Docker. `dbt` is deliberately excluded so the mechanics it hides (conformance SQL, idempotent rebuilds, grant management) are exercised directly.

## Architecture

Data flows in one direction through four Snowflake schemas. Each component owns one concern and is constrained by what it must not do.

```
source CSVs ──(Python: bytes + structure)──▶ Azure Blob (landing)
                                                  │
                                          (Snowflake COPY)
                                                  ▼
   RAW ──▶ STAGING ──▶ MODELED ──▶ CUSTOMER_360
 (fidelity) (conform)  (star)      (serving view, READER boundary)
```

| Component | Owns | Must NOT do |
|-----------|------|-------------|
| **Azure Blob** | Transient landing zone for source files | Be a lake (flat namespace is intentional) |
| **Snowflake** | Compute and the data platform (`COPY` + all transforms) | n/a |
| **Python** | The thin ingress edge: moves bytes into Blob plus minimum structural pre-flight (encoding, line endings, parseability) | Move rows, load the warehouse, transform, or orchestrate |
| **Airflow** | Orchestration only: dependency graph, timing, retries | Hold data, transform, or provision |
| **Terraform** | The boundary: platform, security, RAW table contracts, and its own remote state | Own row data, transform logic, orchestration, or runtime provisioning |
| **Docker** | Local runtime substrate (Airflow + Python execution) | n/a |
| **CI** | Enforces every boundary as a build-failing invariant | n/a |

### Snowflake layers

- **RAW**: ingestion fidelity. Permissive, accepts everything as-is. Never interprets, types, or cleans. (Terraform owns this DDL.)
- **STAGING**: conformance. Typing, categorical standardisation, mixed-date parsing, invalid-value handling, dedup, and the deterministic email/phone customer consolidation.
- **MODELED**: star schema. `DIM_CUSTOMERS`, `DIM_PRODUCTS`, `FACT_ORDERS` (order grain), `FACT_EVENTS`, `FACT_SUPPORT`.
- **CUSTOMER_360**: the unified customer view and the READER access boundary. Not a general mart.

STAGING / MODELED / CUSTOMER_360 table structure is owned by the SQL that builds it (`CREATE OR REPLACE TABLE AS SELECT`), not by Terraform.

## Repository layout

```
terraform/        platform, security, RAW DDL (foundation / security / data_model)
ingestion/        load_to_blob.py: source files to Blob + structural pre-flight
transformations/  staging/ -> modeled/ -> customer_360/  (standalone .sql)
airflow/          dags/ + docker-compose (local: postgres + scheduler + webserver)
tests/fixtures/   committed tiny sample CSVs for smoke tests
.github/workflows pr-checks (fmt/validate/lint/secret-scan) + gated deploy
data/             gitignored: full source CSVs (input to the upload step)
```

## Non-negotiable invariants

- **Future grants, never `COPY GRANTS`.** Read access is granted via `GRANT SELECT ON FUTURE TABLES ... TO READER`. CI fails the build if `COPY GRANTS` appears in any SQL.
- **Never silently drop data.** Every RAW row stays accountable downstream (present, quarantined, or flagged).
- **Idempotency via full rebuild.** Every interior table is a deterministic `CREATE OR REPLACE TABLE AS SELECT`.
- **Gated apply.** Terraform `apply` is never automatic (the storage integration carries `prevent_destroy`).

## Local run

```sh
make help          # list targets
make fmt           # terraform fmt
make validate      # terraform validate (no backend)
make lint          # tflint
make upload        # push source CSVs from data/ to Azure Blob
make airflow-up    # start local Airflow (docker compose)
make airflow-down  # stop local Airflow
```

Terraform `apply` is intentionally not a one-shot target; the storage integration requires a manual Azure admin consent handoff between `plan` and `apply`.

## Build status

Trunk-based, one PR per vertical slice. Current state: scaffold (step 1). The vertical slice (customers end to end) precedes fanning out the remaining domains.
