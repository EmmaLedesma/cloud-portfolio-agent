import json
import base64
import logging
import functions_framework
from google.cloud import storage
from google.cloud import discoveryengine_v1 as discoveryengine

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

PROJECT_ID    = "emmanuel-portfolio-agent"
DATA_STORE_ID = "portfolio-docs-v2"
LOCATION      = "global"

@functions_framework.cloud_event
def ingest_document(cloud_event):
    """
    Se dispara via Pub/Sub cuando se sube un documento nuevo
    al bucket emmanuel-portfolio-agent-docs.

    El mensaje de Pub/Sub contiene:
    - bucket: nombre del bucket
    - name: path del archivo subido
    """
    try:
        pubsub_message = cloud_event.data.get("message", {})
        data = pubsub_message.get("data", "")
        if data:
            message_data = json.loads(base64.b64decode(data).decode("utf-8"))
        else:
            message_data = {}

        bucket_name = message_data.get("bucket", "emmanuel-portfolio-agent-docs")
        file_name   = message_data.get("name", "portfolio.jsonl")

        logger.info(f"Procesando documento: gs://{bucket_name}/{file_name}")

        # Solo procesar archivos .jsonl y .txt
        if not (file_name.endswith(".jsonl") or file_name.endswith(".txt")):
            logger.info(f"Archivo ignorado (no es .jsonl ni .txt): {file_name}")
            return

        # Reimportar documentos en Vertex AI Search
        client = discoveryengine.DocumentServiceClient()

        parent = (
            f"projects/{PROJECT_ID}/locations/{LOCATION}"
            f"/collections/default_collection"
            f"/dataStores/{DATA_STORE_ID}"
            f"/branches/default_branch"
        )

        gcs_uri = f"gs://{bucket_name}/{file_name}"

        request = discoveryengine.ImportDocumentsRequest(
            parent=parent,
            gcs_source=discoveryengine.GcsSource(
                input_uris=[gcs_uri],
                data_schema="document",
            ),
            reconciliation_mode=discoveryengine.ImportDocumentsRequest.ReconciliationMode.INCREMENTAL,
        )

        operation = client.import_documents(request=request)
        logger.info(f"Operacion de importacion iniciada: {operation.operation.name}")
        logger.info(f"Documento indexado exitosamente: {gcs_uri}")

    except Exception as e:
        logger.error(f"Error al indexar documento: {e}")
        raise