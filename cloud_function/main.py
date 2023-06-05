import base64
import json
import os
import re

from google.cloud import logging, storage

logger = logging.Client().logger()


def move_object_to_quarantine(data, context):
    data_json = json.loads(base64.b64decode(data["data"]).decode("utf-8"))

    # Extract the bucket and object name from the event data
    bucket_name = data_json["bucket"]
    object_name = data_json["name"]

    # Define the regex pattern for object name validation
    regex_validation = os.environ["REGEX_VALIDATION"]

    # # Initialize the Cloud Storage client
    storage_client = storage.Client()

    # # Get the object metadata
    source_bucket = storage_client.get_bucket(bucket_name)
    source_blob = source_bucket.blob(object_name)

    # # Check if the object name matches the regex pattern
    if not re.match(regex_validation, object_name):
        # Move the object to the quarantine bucket
        quarantine_bucket_name = f"{bucket_name}-quarantine"
        quarantine_bucket = storage_client.bucket(quarantine_bucket_name)
        source_bucket.copy_blob(source_blob, quarantine_bucket, object_name)
        source_blob.delete()

        logger.warn(f"Object {object_name} moved to the quarantine bucket.")
