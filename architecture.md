Architecture
Use this document to capture the high-level architecture, decisions, diagrams, and rationale.

Overview
cds-app-fresh is a cloud-native micro‑SaaS that enables UK SMEs, exporters, and freight forwarders to create, validate, submit, and amend Customs Declaration Service (CDS) declarations via HMRC REST APIs. Key features: guided forms, smart prefill from invoices (OCR), ML-based HS code suggestions, immutable audit trails, and amendment workflows. Core technology choices: C# .NET 8, Blazor WebAssembly frontend, Azure SQL, Azure Functions, ML.NET, containerised services on Azure.

Goals and Non-Goals
Goals
- Fast, simple CDS declaration workflow for SMEs and forwarders.
- Reduce errors through strong validation, inline help, and ML suggestions.
- Support declaration submit, amend, and status tracking with HMRC.
- Enable continuous deployment and rapid iteration (containers, CI/CD, GitOps).
- Maintain auditable trails and compliance with HMRC/UK data protection.

Non-Goals
- Full customs brokerage automation or legal advice.
- Support for all declaration types at MVP (target a subset — see MVP scope).
- NCTS transit workflows in MVP.
- Multi-jurisdiction customs outside the UK.

Constraints and Assumptions
Technical constraints
- Use HMRC Developer Hub APIs (OAuth2 client_credentials for CDS submission where required).
- Host on Azure: Azure SQL, Blob, Functions, Container Apps or AKS, Key Vault.
- Backend: C# .NET 8; ML inference: ML.NET (containerised) or optionally online inference service.
- Must comply with HMRC integration rules and UK data protection (DPA/GDPR).

Assumptions
- HMRC sandbox available for dev/integration testing.
- Users have valid EORI numbers and authority to submit declarations.
- Initial ML models trained on synthetic/limited data; accuracy improves over time.

Stakeholders
Primary stakeholders and their concerns
- Exporters/SMEs — fast, error-minimised declarations and simple UX.
- Freight forwarders — bulk processing, amendment workflows, and visibility.
- Customs brokers — accuracy, compliance, and integration options.
- Engineering — maintainable, modular, observable, secure services.
- HMRC / Regulators — correct API usage, traceability, secure PII handling.

System Context
The system sits between end-users (exporters, brokers) and HMRC CDS REST APIs. It uses Azure services for storage, async processing, ML inference, and secrets management.

High-level ASCII diagram

        +------------------+        +-----------------------+
        |   End Users      | <----> | Blazor WebAssembly   |
        | (SMEs, Brokers)  |        |        Frontend       |
        +------------------+        +-----------+-----------+
                                                                           |
                                                                           v
                                                        +----------+-----------+
                                                        |     .NET API         |
                                                        |  Auth, CDS client,   |
                                                        |  validation, audit   |
                                                        +----------+-----------+
                                                                           |
        +---------------+--------+----------+---------------+---------------+
        |               |        |          |               |               |
        v               v        v          v               v               v
 Azure SQL     Azure Blob  Azure  Azure Functions  ML.NET service  API Mgmt / AD
 (declarations) (documents)  Cache  (polling, jobs)  (HS suggestions)  (ingress)
                                                                           |
                                                                           v
                                                        +---------------------------+
                                                        | HMRC CDS REST API (OAuth) |
                                                        +---------------------------+
Key Scenarios / Use Cases
- Create & submit: user fills guided form → client-side validation → API stores draft → submit to HMRC → store correlation ID → poll for status.
- Invoice prefill: user uploads invoice → OCR job extracts fields → mapping to form fields → user verifies and submits.
- HS suggestions: ML service returns top‑N HS codes with confidence and provenance metadata.
- Amend declaration: user opens amendable draft → edits → API submits amendment to HMRC and logs action.
- Audit & compliance: every action stored in immutable AuditLog with user, timestamp, and HMRC correlation IDs.

High-Level Components
- Blazor WebAssembly: UI, guided forms, PWA, client pre-validation.
- .NET Backend API: business logic, validation, HMRC integration, audit.
- Azure SQL: declarations, line items, audit logs, tenancy metadata.
- Azure Blob Storage: invoices, documents, OCR outputs.
- Azure Functions: async processing, OCR orchestration, HMRC polling.
- ML.NET inference service: containerised HS classification (server-side inference with confidence scores).
- Azure API Management: ingress, rate limiting, request tracing.
- Azure Key Vault: secrets, certificates, encryption keys.

Component Interaction / Sequence Flows (summary)
1. User completes form → frontend validates → API stores draft.
2. On submit: API obtains HMRC OAuth token (client_credentials or delegated flow, see Auth section) → sends CDS payload → persists correlation ID and logs.
3. Azure Function polls HMRC for status → updates SQL and notifies user via SignalR or polling.
4. Invoice upload: blob store receives file → OCR function runs → mapping service proposes prefill → user verifies.
5. ML service invoked on demand for HS suggestions; results attached to LineItem metadata.

Data Model / Storage
Primary stores
- Azure SQL for relational, transactional consistency, FK constraints, and reporting.
- Azure Blob for binary documents, OCR outputs, and generated PDFs.

Core entities (summary)
- Company (1‑many Users, 1‑many Declarations)
- User (belongs to Company)
- Declaration (1‑many LineItems, 1‑many Documents)
- LineItem (HS code metadata, ML suggestions, value/qty)
- Document (blob ref, type, checksum)
- AuditLog (immutable action records)

Example minimal schemas (suggested)

Declaration
```json
{
        "DeclarationId": "guid",
        "CompanyId": "guid",
        "Status": "Draft|Submitted|Amended|Accepted|Rejected",
        "HMRCCorrelationId": "string|null",
        "CreatedAt": "datetime",
        "UpdatedAt": "datetime"
}
```

LineItem
```json
{
        "LineItemId": "guid",
        "DeclarationId": "guid",
        "HSCode": "string|null",
        "MLSuggestions": [{ "Code":"0101", "Confidence":0.82 }],
        "Quantity": 0,
        "Value": 0.0
}
```

AuditLog
```json
{
        "AuditId": "guid",
        "EntityType": "Declaration|LineItem|Document",
        "EntityId": "guid",
        "Action": "Create|Update|Submit|Amend",
        "UserId": "guid|null",
        "Timestamp": "datetime",
        "Details": {}
}
```

APIs and Contracts
- Internal REST JSON API: /api/v1/declarations, /line-items, /documents, /ml/suggestions.
- External integration: HMRC CDS REST endpoints (use HMRC payloads per spec).
- ML service: REST gRPC-compatible endpoint returning ranked HS codes + confidence.

Versioning
- Internal API versions (/api/v1, /api/v2) and contract tests.
- Feature flags (launch darkly or config) for HMRC schema transitions.

Security and Compliance
- User auth: Azure AD B2C (interactive user sign-in, roles: Exporter, Broker, Admin).
- HMRC integration: backend uses a managed identity or a secure client_credentials flow stored in Key Vault for server-to-server calls.
- Role-based access control (RBAC) enforced in API and UI.
- PII encrypted at rest (Transparent Data Encryption + column/field encryption for sensitive fields) and TLS in transit.
- Secrets in Azure Key Vault; access via managed identities.
- Explicit user confirmation and consent UI before final HMRC submission.
- Immutable AuditLog entries retained per retention policy and immutable storage options where required.

Data subject requests & retention
- Document expected retention policy and data deletion/portability flows (DSR handling).

Operational Concerns
Deployment & scaling
- Containerised services on Azure Container Apps or AKS. Use GitOps (Argo CD / Flux) for deployments.
- Autoscale based on HTTP load and queue depth (KEDA where applicable).

Monitoring & SRE
- OpenTelemetry traces + Application Insights for spans, distributed tracing, and metrics.
- Alerts, SLOs, and on-call runbook for critical flows (submission failures, HMRC outages).

Backups & Recovery
- Automated SQL backups and point-in-time restore. Blob lifecycle policies and cross-region replication for critical data.
- Deployment patterns: canary/blue-green with automated rollback.

Cost & runbook
- Provide high-level expected cost drivers: SQL DTUs/vCores, container instances, OCR/ML inference, data egress to HMRC.
- Create an operational runbook for HMRC rate-limit events and submission error handling.

Testing & CI/CD
- Unit tests: validation, mapping, ML wrappers.
- Integration tests: HMRC sandbox (isolated), SQL interactions, OCR pipeline (mocked/minimal integration).
- E2E tests: guided form -> submit -> status flow against staging environment connected to sandbox.
- Load tests: submission throughput and ML latency profiling in pre-prod.
- CI/CD: pipeline(s) for build, tests, container image publish, and GitOps-driven deploy to dev/stage/prod with gates for integration tests.

Example pipelines
- `ci.yml`: build, unit tests, static analysis.
- `cd.yml`: push image, run integration tests in staging, promote via GitOps.

Deployment Diagram
Environments: dev, stage, prod with separate subscriptions/resource groups and GitOps promotion.

Network & access
- Private endpoints for SQL and Blob; API Management or Application Gateway as ingress.
- Managed Identity for service-to-service access and Key Vault access control.

Risks and Mitigations
- HMRC API changes: contract tests, schema versioning, feature flags, and graceful degradation.
- OCR inaccuracies: user verification UI and progressive improvement; fallback manual entry.
- ML misclassification: display top-N candidates with confidence and allow user override.
- Sandbox/Prod differences: resilience in error handling and extensive staging tests.
- Data compliance: encryption, audit logs, and documented DSR flows.

Open Questions
- Which declaration types are MVP (e.g., Single Administrative Reference (SAR) subset)?
- ML inference: server-side by default; consider WASM client-side ranking only for offline suggestions.
- Broker features: require multi-company switching in MVP or post-MVP?
- GitOps choice: Argo CD vs Flux — prefer team's operational familiarity.

Next actions / Suggestions
- See included assets for diagrams and runbook:
        - System diagram: [assets/system-diagram.svg](assets/system-diagram.svg)
        - ERD: [assets/erd.svg](assets/erd.svg)
        - OAuth flow: [assets/oauth-flow.svg](assets/oauth-flow.svg)
        - HMRC rate-limit runbook: [docs/hmrc-rate-limit-runbook.md](docs/hmrc-rate-limit-runbook.md)
        - Sequence diagram (submit/amend): [assets/sequence-submit-amend.svg](assets/sequence-submit-amend.svg)
        - Incident playbook: [docs/hmrc-incident-playbook.md](docs/hmrc-incident-playbook.md)
- Finalise MVP scope (exact declaration types and broker features) and NFR targets (latency, availability, retention).
- Review and adapt runbook parameters (backoff caps, alert thresholds) to on-call capacity.

References
- HMRC Developer Hub (CDS API documentation)
- Azure architecture guidelines
- Internal ML training notes
- Project roadmap and sprint backlog