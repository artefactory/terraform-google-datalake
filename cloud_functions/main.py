import google.cloud.logging
from  google.cloud import storage
from dataclasses import dataclass
import json, base64, logging, re

client = google.cloud.logging.Client()
client.setup_logging()
storage_client = storage.Client()

QUARENTINE_BUCKET_NAME="quarentine" # The name of the bucket where all the object that don't match their regex are sent to

def main(data, context):
    object_metadatas=get_object_metadata(data)
    regex_pattern=re.compile(object_metadatas.bucket_object_regex)
    if not re.match(pattern=regex_pattern, string=object_metadatas.object_name):
        move_object_to_quarentine(bucket_name=object_metadatas.bucket_name, object_name=object_metadatas.object_name)

@dataclass
class ObjectMetadata:
    bucket_name: str
    object_name: str
    bucket_object_regex: str

def get_object_metadata(data : bytes) -> ObjectMetadata:
    body_json = get_pubsub_body_json(data)
    attributes = get_pubsub_attribute(data)
    return ObjectMetadata(bucket_name=body_json["bucket"], object_name=body_json["name"], bucket_object_regex=attributes["regex"])


def get_pubsub_body_json(data: bytes) -> any:
    pubsub_data = base64.b64decode(data["data"]).decode("utf-8")
    data_json = json.loads(pubsub_data)
    logging.info(data_json)
    return data_json

def get_pubsub_attribute(data: bytes) -> dict:
    return data["attributes"]

def move_object_to_quarentine(bucket_name : str, object_name : str ) -> None:
    logging.warn(f"Will move the object {object_name} to the quarentine bucket {destination_bucket} ")
    source_bucket = storage_client.get_bucket(bucket_name)
    source_object = source_bucket.blob(object_name)
    destination_bucket = get_quarentine_bucket() 
    source_bucket.copy_blob(source_object, destination_bucket, object_name)
    source_object.delete()
    logging.warn(f"successfully moved the object {object_name} to the quarentine bucket {destination_bucket} ")

def get_quarentine_bucket() -> str:
    """get_quarentine_bucket is used as a workaround to get the  quarentine bucket. Because the name of the quarentine bucket contains the id 
    of the gcp project and the field is NOT available in the json payload sent by pubsub"""
    buckets = storage_client.list_buckets()
    for bucket in buckets:
        if QUARENTINE_BUCKET_NAME in bucket.name:
            return storage_client.bucket(bucket.name) # Note: this is used because there is only one quarentine bucket per project

if __name__ == '__main__':
    print("hello world")