import os
import sys
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential

STORAGE_ACCOUNT = "sluicedata"
CONTAINER       = "raw"
DATA_DIR        = "data"

FILES = [
    "crm_50000_customers_dirty_v3.csv",
]

def main():
    credential = DefaultAzureCredential()

    blob_service = BlobServiceClient(
        account_url=f"https://{STORAGE_ACCOUNT}.blob.core.windows.net",
        credential=credential
    )

    container = blob_service.get_container_client(CONTAINER)

    for filename in FILES:
        filepath = os.path.join(DATA_DIR, filename)

        if not os.path.exists(filepath):
            print(f"File not found: {filepath}")
            sys.exit(1)

        print(f"Uploading {filename}...")
        with open(filepath, "rb") as f:
            container.upload_blob(filename, f, overwrite=True)
        print(f"  done: {filename}")

if __name__ == "__main__":
    main()