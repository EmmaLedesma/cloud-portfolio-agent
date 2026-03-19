# Emmanuel Ledesma — Portfolio Projects

## Project 1: YouTube Video Summarizer (yt-summarizer)
- **Status:** Live and deployed
- **Demo:** https://d21n43yg7hlxxz.cloudfront.net
- **Repo:** https://github.com/EmmaLedesma/youtube-summarizer
- **Cloud:** AWS
- **Type:** Serverless, AI-powered, full-stack

### Description
AI-powered YouTube video summarizer. The user pastes a URL, selects a language,
and Claude AI returns a structured summary with key points, topics and content type.
Results are cached in DynamoDB to avoid redundant API calls.

### Architecture
- AWS Bedrock (Claude 3.5 Haiku) via Converse API — LLM for summarization
- AWS Lambda — backend logic
- API Gateway — REST API endpoint
- DynamoDB — caching of results
- S3 + CloudFront — static frontend with CDN
- Supadata API — YouTube transcript extraction (browser-side)

### DevOps & IaC
- 100% Terraform IaC
- GitHub Actions CI/CD — automatic deploy on push (separate workflows for frontend and backend)
- CloudWatch Dashboard + Alarms as code — observability

### Key Features
- Language selector (Spanish, English, Portuguese and more)
- Structured summaries with key points, topics and content type
- CloudWatch monitoring with custom alarms
- Feature-branch + PR workflow for GitHub achievements

### Technologies
Python, AWS Bedrock, Claude 3.5 Haiku, Lambda, API Gateway, DynamoDB,
S3, CloudFront, Terraform, GitHub Actions, CloudWatch

---

## Project 2: Terraform Event Pipeline (terraform-event-pipeline)
- **Status:** Deployed
- **Repo:** https://github.com/EmmaLedesma/terraform-event-pipeline
- **Cloud:** AWS
- **Type:** Event-driven infrastructure, IaC

### Description
Event-driven AWS infrastructure provisioned 100% with Terraform.
A file upload to S3 triggers a Lambda that fans out events to SQS and SNS.
The entire infrastructure can be destroyed and recreated from scratch with a single command.

### Architecture
- S3 — file upload trigger
- Lambda — event processor
- SQS — message queue
- SNS — notification fanout
- IAM — least privilege roles

### DevOps & IaC
- Terraform modules: storage, messaging, compute
- Remote state: S3 backend + DynamoDB locking
- GitHub Actions CI/CD: terraform plan on PR, terraform apply on merge
- 11 AWS resources provisioned as code

### Technologies
Terraform, AWS Lambda, S3, SQS, SNS, IAM, GitHub Actions

---

## Project 3: Cloud File API (cloud-file-api)
- **Status:** Live and deployed
- **API:** http://3.84.95.162:3000/health
- **Repo:** https://github.com/EmmaLedesma/cloud-file-api
- **Cloud:** AWS
- **Type:** Containerized REST API, CI/CD

### Description
Containerized REST API with a full CI/CD pipeline to AWS ECS Fargate.
Manages files on S3 with automated build, test and deploy on every code change.
Uses keyless AWS authentication via OIDC — no stored credentials anywhere.

### Architecture
- Node.js/Express — REST API
- Docker multi-stage build — optimized container image
- AWS ECR — container registry
- AWS ECS Fargate — serverless container execution
- S3 — file storage
- OIDC — keyless authentication between GitHub Actions and AWS

### DevOps & IaC
- GitHub Actions CI: lint + test matrix (Node 18/20)
- GitHub Actions CD: build image → push to ECR → deploy to ECS Fargate
- LocalStack for zero-cost local development and testing

### Technologies
Node.js, Docker, GitHub Actions, AWS ECS Fargate, ECR, S3, OIDC, LocalStack

---

## Project 4: Shem 72 — Kabbalistic Angel Calculator
- **Status:** Live and deployed
- **App:** http://shem72-app.s3-website-us-east-1.amazonaws.com
- **Repo:** https://github.com/EmmaLedesma/calculadora-72-nombres
- **Cloud:** AWS
- **Type:** Full-stack serverless, personal passion project

### Description
Full-stack serverless application that calculates 3 guardian angels using the
Kabbalistic method of the 72 Names (Shem HaMephorash). Based on birth date,
the app computes the physical, emotional and intellectual guardian angels
using the Madirolas primary dates table.

### Architecture
- AWS Lambda — calculation backend
- API Gateway — REST API
- S3 — static frontend hosting
- SAM / CloudFormation — IaC
- Node.js/Express — custom REST API
- CloudFront — HTTPS distribution

### Special Features
- Auto-calculated gematria values
- Sephira matrix positions
- Abulafia vocalization
- Hebrew psalm text display
- Restructured shem72.json with 72 angels dataset

### Technologies
Node.js, AWS Lambda, API Gateway, S3, SAM, CloudFormation, REST API

---

## Project 5: Cloud Portfolio Agent (cloud-portfolio-agent) — THIS PROJECT
- **Status:** In development
- **Repo:** https://github.com/EmmaLedesma/cloud-portfolio-agent
- **Cloud:** GCP
- **Type:** Conversational AI agent, full-stack, RAG

### Description
A conversational AI agent deployed on GCP that answers questions about
Emmanuel's professional profile, portfolio projects and technical skills.
Recruiters and tech leads can chat with the agent and ask questions like:
"What projects does Emmanuel have with Terraform?"
"Does he know Docker and CI/CD?"
"What is his most complex project?"

The agent uses RAG (Retrieval Augmented Generation) over portfolio documents
to generate accurate, grounded responses — not hardcoded answers.

### Architecture
- Vertex AI Search — vector store and RAG grounding
- Vertex AI + Gemini — LLM for response generation
- Dialogflow CX — conversational flow management
- Cloud Run (Python) — backend orchestrator
- Cloud Functions — document ingestion pipeline
- Cloud Pub/Sub — event-driven re-indexing
- BigQuery — conversation analytics
- Cloud Storage — frontend and document storage
- Cloud Monitoring — observability
- Cloud IAM + Secret Manager — security

### DevOps & IaC
- 100% Terraform IaC (modular structure)
- GitHub Actions CI/CD with Workload Identity Federation (keyless)
- Remote state in GCS with versioning

### Technologies
Python, GCP, Vertex AI, Gemini, Dialogflow CX, Cloud Run, Cloud Functions,
Pub/Sub, BigQuery, Cloud Storage, Terraform, GitHub Actions