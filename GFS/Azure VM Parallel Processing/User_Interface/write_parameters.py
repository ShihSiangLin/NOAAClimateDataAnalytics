from azure.storage.blob import ContainerClient
import json
import argparse
from pathlib import Path

parser = argparse.ArgumentParser(description='Arguments for json file')
parser.add_argument("cycle")
parser.add_argument("YMD")

args = parser.parse_args()

cycle = args.cycle
ymd = args.YMD

# specify value for azure storage container
AZ_STORAGE_CONNECTION_STRING_PATH: Path = Path(__file__).parent.parent / "fewx-htf" / "fewxops" / "software" / "azure_storage_info.json"
with open(AZ_STORAGE_CONNECTION_STRING_PATH, "r") as f:
    info = json.loads(f.read())
 
azure_storage_connection_string: str = info["azure_storage_connection_string"]
container_name: str = info["container_name"]   

def write_json_file_to_blob(cycles: int, ymd: str):
    container_client  = ContainerClient.from_connection_string(azure_storage_connection_string, container_name)
    blob_client = container_client.get_blob_client("parameters.json")
    # Define your data as a Python dictionary
    data = {
        "date": ymd,
        "cycle": int(cycles)
    }
    # Write data to a JSON file
    with open("parameters.json", "w") as f:
        json.dump(data, f)

    # Upload the JSON file
    with open("parameters.json", "rb") as data:
        blob_client.upload_blob(data, overwrite=True)
    
    print("JSON file uploaded successfully to Azure Blob Storage.")

write_json_file_to_blob(cycle, ymd)