# 🤖 Cloud Portfolio Agent

**Agente conversacional de portfolio deployado en GCP — Responde preguntas sobre mi perfil profesional en español e inglés**

[![GCP](https://img.shields.io/badge/GCP-Cloud_Run-4285F4?style=flat-square&logo=google-cloud&logoColor=white)](https://cloud.google.com)
[![Terraform](https://img.shields.io/badge/Terraform-1.14+-7B42BC?style=flat-square&logo=terraform&logoColor=white)](https://terraform.io)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=flat-square&logo=python&logoColor=white)](https://python.org)
[![Gemini](https://img.shields.io/badge/Gemini-2.5_Flash-4285F4?style=flat-square&logo=google&logoColor=white)](https://cloud.google.com/vertex-ai)
[![Demo](https://img.shields.io/badge/demo-live-brightgreen?style=flat-square)](https://emmaledesma.github.io/cloud-portfolio-agent/)

🔗 **[Demo en vivo](https://emmaledesma.github.io/cloud-portfolio-agent/)** · [LinkedIn](https://www.linkedin.com/in/emmanuel-ledesmam) · [GitHub](https://github.com/EmmaLedesma)

---

## 📌 Concepto

Un recruiter o tech lead puede abrir el chat y preguntar directamente:

> *"¿Qué proyectos tiene Emmanuel con Terraform?"*
> *"Does he know Docker and CI/CD?"*
> *"¿Cuál es su proyecto más complejo?"*

El agente responde usando **RAG sobre documentos reales del portfolio** — no respuestas hardcodeadas. Cada respuesta es generada por Gemini con contexto real extraído de Vertex AI Search.

**El agente en sí ES la demo del proyecto.**

---

## 🏗️ Arquitectura
```
┌─────────────────────────────────────────────────────────────┐
│                     GitHub Pages                            │
│              Chat Widget (HTML/CSS/JS)                      │
└─────────────────────────┬───────────────────────────────────┘
                          │ HTTPS POST /chat
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  Cloud Run (Python/FastAPI)                 │
│                   Orquestador del agente                    │
│                                                             │
│  1. Recibe pregunta del usuario                             │
│  2. Busca contexto en Vertex AI Search (RAG)                │
│  3. Construye prompt con contexto recuperado                │
│  4. Llama a Gemini 2.5 Flash                                │
│  5. Loguea conversación en BigQuery                         │
│  6. Devuelve respuesta                                      │
└──────────┬──────────────────────────┬───────────────────────┘
           │                          │
           ▼                          ▼
┌──────────────────┐      ┌───────────────────────┐
│ Vertex AI Search │      │       BigQuery        │
│  portfolio-docs  │      │  analytics de         │
│  (RAG / Vector   │      │  conversaciones       │
│   Store)         │      └───────────────────────┘
└──────────────────┘
           ▲
           │ Re-indexa automáticamente
┌──────────────────────────────────────────────────┐
│              Cloud Pub/Sub                       │
│         Topic: new-document                      │
└──────────────────┬───────────────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────────────┐
│           Cloud Function (Python)                │
│    Ingesta documentos → Vertex AI Search         │
└──────────────────┬───────────────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────────────┐
│           Cloud Storage                          │
│    Bucket: portfolio-docs (profile, projects,    │
│    skills — actualizables sin tocar código)      │
└──────────────────────────────────────────────────┘
```

### Flujo de ingesta de documentos
```
Nuevo documento (.jsonl) subido al bucket
        │
        ▼
Cloud Pub/Sub publica evento
        │
        ▼
Cloud Function re-indexa en Vertex AI Search
        │
        ▼
Agente responde con información actualizada
```

---

## 🚀 Recursos GCP Provisionados

| Recurso | Nombre | Módulo Terraform |
|---------|--------|-----------------|
| Cloud Run Service | `portfolio-agent` | cloud_run |
| Vertex AI Data Store | `portfolio-docs-v2` | vertex_ai |
| Vertex AI Search Engine | `portfolio-search-v2` | vertex_ai |
| Cloud Function v2 | `ingest-documents` | cloud_functions |
| Cloud Storage (docs) | `emmanuel-portfolio-agent-docs` | storage |
| Cloud Storage (frontend) | `emmanuel-portfolio-agent-frontend` | storage |
| Cloud Storage (tfstate) | `emmanuel-portfolio-agent-tfstate` | — |
| Pub/Sub Topic | `new-document` | pubsub |
| Pub/Sub Subscription | `ingest-trigger` | pubsub |
| BigQuery Dataset | `portfolio_agent` | bigquery |
| BigQuery Table | `conversations` | bigquery |
| Cloud Monitoring Dashboard | `Portfolio Agent` | monitoring |
| Secret Manager | `gemini-api-key` | — |
| Workload Identity Pool | `github-actions-pool` | iam |
| Service Accounts (3) | `sa-cicd`, `sa-cloud-run`, `sa-ingestion` | iam |

**Total: 15+ recursos GCP gestionados como código**

---

## ✅ Features Implementadas

- **RAG real** — respuestas grounded en documentos del portfolio via Vertex AI Search
- **Bilingüe** — responde en español o inglés según el idioma de la pregunta
- **Chat widget** — frontend estático deployado en GitHub Pages
- **Ingesta automática** — Cloud Function re-indexa documentos vía Pub/Sub
- **Analytics** — cada conversación loggeada en BigQuery
- **Observabilidad** — Cloud Monitoring dashboard con métricas de Cloud Run
- **CI/CD keyless** — GitHub Actions con Workload Identity Federation (sin API keys)
- **IaC completo** — toda la infra como código con Terraform modular

---

## 🛠️ Stack Técnico

| Capa | Tecnología |
|------|-----------|
| Frontend | HTML + CSS + Vanilla JS |
| Hosting | GitHub Pages |
| Backend | Python 3.12 + FastAPI |
| Compute | GCP Cloud Run (serverless) |
| LLM | Gemini 2.5 Flash (Google AI) |
| RAG / Search | Vertex AI Search |
| Ingesta | Cloud Functions v2 |
| Mensajería | Cloud Pub/Sub |
| Analytics | BigQuery |
| Secrets | Secret Manager |
| IaC | Terraform 1.14 — módulos locales |
| CI/CD | GitHub Actions + Workload Identity |
| Monitoreo | Cloud Monitoring |

---

## 🔄 CI/CD con GitHub Actions

| Evento | Workflow | Acción |
|--------|----------|--------|
| PR con cambios en `infra/` | `tf-plan.yml` | Terraform plan |
| Push a `master` con cambios en `backend/` | `deploy.yml` | Build Docker → push ECR → deploy Cloud Run |
| Push a `master` con cambios en `frontend/` | `deploy.yml` | Upload a GCS |

Autenticación **keyless** via Workload Identity Federation — sin service account keys almacenadas.

---

## 🔐 Seguridad

- **Least privilege IAM** — 3 service accounts con roles mínimos necesarios
- **Workload Identity Federation** — CI/CD sin credenciales almacenadas
- **Secret Manager** — API keys nunca en código ni variables de entorno hardcodeadas
- **HTTPS** — Cloud Run y GitHub Pages fuerzan HTTPS

---

## 📁 Estructura del Proyecto
```
cloud-portfolio-agent/
├── .github/workflows/
│   ├── tf-plan.yml          # Terraform plan en PRs
│   └── deploy.yml           # Deploy backend + frontend
├── backend/
│   ├── main.py              # FastAPI — orquestador del agente
│   ├── requirements.txt
│   └── Dockerfile
├── docs/                    # Documentos base del RAG
│   ├── profile.md           # Perfil profesional
│   ├── projects.md          # Proyectos del portfolio
│   └── skills.md            # Skills y certificaciones
├── frontend/
│   ├── index.html           # Chat widget
│   └── style.css
├── functions/
│   └── ingest/
│       ├── main.py          # Cloud Function de ingesta
│       └── requirements.txt
└── infra/                   # Terraform — toda la infra GCP
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── backend.tf
    ├── envs/prod/
    └── modules/
        ├── iam/
        ├── storage/
        ├── pubsub/
        ├── bigquery/
        ├── vertex_ai/
        ├── cloud_run/
        ├── cloud_functions/
        └── monitoring/
```

---

## ⚡ Quick Start

### Requisitos
- Terraform >= 1.14
- Google Cloud CLI
- Python 3.12
- Docker
- Cuenta GCP con billing habilitado

### 1. Clonar el repo
```bash
git clone https://github.com/EmmaLedesma/cloud-portfolio-agent
cd cloud-portfolio-agent
```

### 2. Crear proyecto GCP y bucket de tfstate
```bash
gcloud projects create <PROJECT_ID>
gcloud config set project <PROJECT_ID>
gcloud billing projects link <PROJECT_ID> --billing-account=<BILLING_ID>
gcloud storage buckets create gs://<PROJECT_ID>-tfstate --location=us-central1
```

### 3. Deploy de infraestructura
```bash
cd infra
terraform init -backend-config="bucket=<PROJECT_ID>-tfstate"
terraform apply -var-file="envs/prod/terraform.tfvars"
```

### 4. Indexar documentos del portfolio
```bash
# Subir documentos al bucket
gcloud storage cp docs/portfolio.jsonl gs://<PROJECT_ID>-docs/portfolio.jsonl

# Importar a Vertex AI Search via API
```

### 5. Deploy del backend
```bash
cd backend
docker build -t us-central1-docker.pkg.dev/<PROJECT_ID>/portfolio-agent/agent:latest .
docker push us-central1-docker.pkg.dev/<PROJECT_ID>/portfolio-agent/agent:latest
gcloud run deploy portfolio-agent --image=... --region=us-central1
```

---

## 🧗 Decisiones Técnicas

**¿Por qué Cloud Run y no Cloud Functions para el backend?**
Cloud Run permite containers completos con FastAPI, manejo de estado de sesión y mayor control sobre el runtime. Para un agente conversacional con múltiples dependencias Python es más adecuado que Functions.

**¿Por qué Vertex AI Search para RAG y no solo prompt con contexto?**
Vertex AI Search escala automáticamente a miles de documentos y permite actualización incremental. El arquitecto puede agregar nuevos proyectos subiendo un archivo al bucket — sin tocar código ni redesployar.

**¿Por qué GitHub Pages para el frontend?**
URL limpia, HTTPS gratuito, deploy automático en push. Para un chat widget estático es la opción más simple y profesional.

**¿Por qué Workload Identity Federation?**
Elimina el riesgo de credenciales comprometidas. GitHub Actions obtiene tokens efímeros de GCP — el mismo patrón usado en producción en Google.

---

## 📊 Observabilidad

Cloud Monitoring Dashboard con métricas en tiempo real:
- Request count y latencia (p95)
- Error rate (5xx)
- Instance count de Cloud Run

BigQuery loguea cada conversación con: pregunta, respuesta, latencia, session_id y timestamp — permite analizar qué preguntan los recruiters y optimizar el agente.

---

## 🔮 Mejoras Futuras

- 🔒 Restricción de la API key de Gemini por dominio
- 📱 PWA — instalable en móvil
- 🌍 Soporte multiidioma completo en la UI
- 📈 Dashboard de BigQuery con análisis de conversaciones
- 🔄 Re-indexado automático via Pub/Sub al subir documentos

---

## 💼 Este Proyecto Demuestra

**GCP Cloud Engineering**
- Vertex AI Search, Gemini, Cloud Run, Cloud Functions, Pub/Sub, BigQuery, Secret Manager

**Infrastructure as Code**
- Terraform modular con remote state en GCS, módulos locales, lifecycle rules

**CI/CD Profesional**
- GitHub Actions con Workload Identity Federation keyless, path filters, deploy separado por componente

**AI/RAG en Producción**
- Pipeline completo: ingesta → indexado → búsqueda semántica → generación con grounding

---

## 📝 Licencia

Proyecto orientado al aprendizaje y desarrollo de portfolio profesional.

*Code made by Emmanuel Ledesma*
🔗 [linkedin.com/in/emmanuel-ledesmam](https://www.linkedin.com/in/emmanuel-ledesmam)

---

# English Version

# 🤖 Cloud Portfolio Agent

**Conversational portfolio agent deployed on GCP — Answers questions about my professional profile in English and Spanish**

[![GCP](https://img.shields.io/badge/GCP-Cloud_Run-4285F4?style=flat-square&logo=google-cloud&logoColor=white)](https://cloud.google.com)
[![Terraform](https://img.shields.io/badge/Terraform-1.14+-7B42BC?style=flat-square&logo=terraform&logoColor=white)](https://terraform.io)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=flat-square&logo=python&logoColor=white)](https://python.org)
[![Gemini](https://img.shields.io/badge/Gemini-2.5_Flash-4285F4?style=flat-square&logo=google&logoColor=white)](https://cloud.google.com/vertex-ai)
[![Demo](https://img.shields.io/badge/demo-live-brightgreen?style=flat-square)](https://emmaledesma.github.io/cloud-portfolio-agent/)

[![Demo](https://img.shields.io/badge/demo-live-brightgreen?style=flat-square)](https://emmaledesma.github.io/cloud-portfolio-agent/)

🔗 **[Live Demo](https://emmaledesma.github.io/cloud-portfolio-agent/)**

---

## 📌 Concept

A recruiter or tech lead can open the chat and ask directly:

> *"What projects does Emmanuel have with Terraform?"*
> *"Does he know Docker and CI/CD?"*
> *"What is his most complex project?"*

The agent responds using **RAG over real portfolio documents** — not hardcoded answers. Each response is generated by Gemini with real context extracted from Vertex AI Search.

**The agent itself IS the project demo.**

---

## 🏗️ Architecture

Same as Spanish version above.

---

## 💼 This Project Demonstrates

**GCP Cloud Engineering**
- Vertex AI Search, Gemini, Cloud Run, Cloud Functions, Pub/Sub, BigQuery, Secret Manager

**Infrastructure as Code**
- Modular Terraform with GCS remote state, local modules, lifecycle rules

**Professional CI/CD**
- GitHub Actions with keyless Workload Identity Federation, path filters, separate deploy per component

**AI/RAG in Production**
- Complete pipeline: ingestion → indexing → semantic search → grounded generation

---

*Code made by Emmanuel Ledesma*
🔗 [linkedin.com/in/emmanuel-ledesmam](https://www.linkedin.com/in/emmanuel-ledesmam)