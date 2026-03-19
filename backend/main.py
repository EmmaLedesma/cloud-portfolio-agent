import os
import uuid
import logging
from datetime import datetime, timezone
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from google.cloud import discoveryengine_v1 as discoveryengine
from google.cloud import bigquery
import vertexai
from vertexai.generative_models import GenerativeModel

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Portfolio Agent API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

PROJECT_ID       = os.environ["PROJECT_ID"]
REGION           = os.environ.get("REGION", "us-central1")
DATA_STORE_ID    = os.environ["DATA_STORE_ID"]
BIGQUERY_DATASET = os.environ["BIGQUERY_DATASET"]
BIGQUERY_TABLE   = os.environ["BIGQUERY_TABLE"]

vertexai.init(project=PROJECT_ID, location=REGION)
model = GenerativeModel("gemini-1.5-flash")
bq_client = bigquery.Client(project=PROJECT_ID)

class ChatRequest(BaseModel):
    message: str
    session_id: str = None
    language: str = "auto"

class ChatResponse(BaseModel):
    response: str
    session_id: str
    sources: list[str] = []

def search_rag(query: str) -> tuple[str, list[str]]:
    """Busca en Vertex AI Search y retorna contexto + fuentes."""
    client = discoveryengine.SearchServiceClient()

    serving_config = (
        f"projects/{PROJECT_ID}/locations/global"
        f"/collections/default_collection"
        f"/dataStores/{DATA_STORE_ID}"
        f"/servingConfigs/default_config"
    )

    request = discoveryengine.SearchRequest(
        serving_config=serving_config,
        query=query,
        page_size=5,
        query_expansion_spec=discoveryengine.SearchRequest.QueryExpansionSpec(
            condition=discoveryengine.SearchRequest.QueryExpansionSpec.Condition.AUTO
        ),
    )

    response = client.search(request)

    context_parts = []
    sources = []

    for result in response.results:
        doc = result.document
        if doc.derived_struct_data:
            snippets = doc.derived_struct_data.get("snippets", [])
            for snippet in snippets:
                if snippet.get("snippet"):
                    context_parts.append(snippet["snippet"])
            title = doc.derived_struct_data.get("title", "")
            if title:
                sources.append(title)

    context = "\n\n".join(context_parts) if context_parts else ""
    return context, sources

def build_prompt(question: str, context: str, language: str) -> str:
    """Construye el prompt para Gemini."""

    lang_instruction = (
        "Respond in the same language as the question."
        if language == "auto"
        else f"Respond in {language}."
    )

    return f"""You are an AI assistant representing Emmanuel Ledesma's professional portfolio.
Your role is to answer questions about Emmanuel's skills, experience, and projects accurately and professionally.
{lang_instruction}

Use the following context from Emmanuel's portfolio documents to answer the question.
If the context doesn't contain enough information, use what you know from the context
and be transparent about limitations.

Always be professional, specific, and highlight Emmanuel's real achievements.
Never invent information not present in the context.

CONTEXT:
{context}

QUESTION:
{question}

ANSWER:"""

def log_conversation(session_id: str, user_message: str,
                     agent_response: str, latency_ms: int, sources: list):
    """Loguea la conversación en BigQuery."""
    try:
        table_id = f"{PROJECT_ID}.{BIGQUERY_DATASET}.{BIGQUERY_TABLE}"
        rows = [{
            "conversation_id": str(uuid.uuid4()),
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "user_message": user_message,
            "agent_response": agent_response,
            "latency_ms": latency_ms,
            "sources_used": ", ".join(sources),
            "session_id": session_id,
        }]
        errors = bq_client.insert_rows_json(table_id, rows)
        if errors:
            logger.error(f"BigQuery insert errors: {errors}")
    except Exception as e:
        logger.error(f"Error logging to BigQuery: {e}")

@app.get("/health")
def health():
    return {"status": "ok", "service": "portfolio-agent"}

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    start_time = datetime.now(timezone.utc)
    session_id = request.session_id or str(uuid.uuid4())

    try:
        context, sources = search_rag(request.message)
        prompt = build_prompt(request.message, context, request.language)
        gemini_response = model.generate_content(prompt)
        answer = gemini_response.text

        latency_ms = int(
            (datetime.now(timezone.utc) - start_time).total_seconds() * 1000
        )
        log_conversation(session_id, request.message, answer, latency_ms, sources)

        return ChatResponse(
            response=answer,
            session_id=session_id,
            sources=sources
        )

    except Exception as e:
        logger.error(f"Error in chat endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))