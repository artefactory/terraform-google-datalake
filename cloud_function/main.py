import base64
import json
import logging
import os
import re

import google.cloud.logging
from google.cloud import storage

client = google.cloud.logging.Client()
client.setup_logging()


def main(data, context):
    if data['attributes']['eventType'] == "OBJECT_FINALIZE":
        logging.info("Function triggered, starting validation.")
        data_json = json.loads(base64.b64decode(data['data']).decode("utf-8"))

        source_bucket_name = data_json["bucket"]
        object_name = data_json["name"]
        regex_validation = os.environ.get("REGEX_VALIDATION")

        if not re.match(regex_validation, object_name):
            move_object_to_quarantine(source_bucket_name, object_name)



def move_object_to_quarantine(source_bucket_name: str, object_name: str):
    logging.warning(f"Object {object_name} does not match the regex, moving to quarantine bucket.")
    storage_client = storage.Client()

    quarantine_bucket_name = f"{source_bucket_name}-quarantine"

    source_bucket = storage_client.get_bucket(source_bucket_name)
    quarantine_bucket = storage_client.bucket(quarantine_bucket_name)

    source_object = source_bucket.blob(object_name)
    source_bucket.copy_blob(source_object, quarantine_bucket, object_name)
    source_object.delete()

    logging.info(f"Object {object_name} moved to the quarantine bucket.")
