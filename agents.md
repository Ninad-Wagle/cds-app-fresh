Agents
This document defines the autonomous and semi‑autonomous agents used in the project. Each agent has a clear role, responsibilities, inputs, outputs, and collaboration patterns. These agents are designed to operate inside a VS Code agentic workflow.

Overview
The system uses a multi‑agent workflow to plan, implement, validate, and deploy features for the CDS micro‑SaaS. Each agent specialises in a domain (planning, backend, frontend, ML, DevOps, QA) and collaborates through structured tasks and shared context files.

Goals and Non-Goals
Goals

- Automate repetitive engineering tasks.
- Maintain architectural consistency across backend, frontend, ML, and DevOps.
- Enable continuous development with minimal manual intervention.
- Improve code quality through automated review and validation.
- Support rapid prototyping and iteration.

Non-Goals

- Replace human judgment for regulatory or compliance decisions.
- Automatically deploy to production without human approval.
- Generate legal or customs advice.

Agent Types
Planner Agent — breaks down features into tasks and acceptance criteria.

Backend Agent — implements .NET API, HMRC integration, validation logic.

Frontend Agent — implements Blazor UI, forms, inline help, PWA behaviour.

ML Agent — builds and maintains HS classifier and OCR mapping logic.

DevOps Agent — manages Dockerfiles, CI/CD, GitOps manifests, IaC.

QA Agent — writes tests, validates flows, checks compliance with architecture.

Planner Agent
Responsibilities

- Convert user stories into technical tasks.
- Maintain sprint backlog and prioritisation.
- Ensure tasks align with `architecture.md`.

Inputs

- Feature requests, `architecture.md`, roadmap.

Outputs

- `task.md` files, acceptance criteria, dependency graphs.

Backend Agent
Responsibilities

- Implement .NET API endpoints.
- Build HMRC OAuth2 client and CDS submit/amend/status flows.
- Implement validation engine and audit logging.
- Integrate with SQL, Blob Storage, and Key Vault.

Inputs

- Planner tasks, `architecture.md`, `hmrc-integration.md`.

Outputs

- C# code, tests, API schemas.

Frontend Agent
Responsibilities

- Build Blazor WebAssembly UI.
- Implement guided forms, inline help, and validation messages.
- Handle invoice upload and display ML suggestions.
- Provide status tracking and audit views.

Inputs

- Planner tasks, backend API contracts.

Outputs

- Razor components, CSS, PWA manifest.

ML Agent
Responsibilities

- Build ML.NET HS classifier.
- Manage training data, synthetic generation, and model versioning.
- Integrate OCR outputs into structured line items.
- Expose inference via REST/gRPC microservice.

Inputs

- Training data, planner tasks, `architecture.md`.

Outputs

- Model files, inference service code, evaluation reports.

DevOps Agent
Responsibilities

- Maintain Dockerfiles and container images.
- Configure GitHub Actions CI pipelines.
- Manage GitOps manifests for Argo CD or Flux.
- Configure Azure Container Apps/AKS deployments.
- Implement observability (OpenTelemetry, dashboards).

Inputs

- `architecture.md`, infra requirements.

Outputs

- YAML pipelines, Helm charts, Terraform/Bicep files.

QA Agent
Responsibilities

- Write unit, integration, and E2E tests.
- Validate HMRC sandbox flows.
- Ensure compliance with architecture and security requirements.
- Perform regression testing on ML outputs.

Inputs

- Planner tasks, backend/frontend code.

Outputs

- Test suites, QA reports, bug tickets.

Collaboration Model

- Planner creates tasks → Backend/Frontend/ML/DevOps agents execute → QA validates.
- Agents communicate through shared markdown files and task folders.
- `architecture.md` acts as the single source of truth.
- DevOps agent ensures all agents’ outputs are buildable and deployable.

Task Lifecycle

- Planner creates task with acceptance criteria.
- Implementer agent (backend/frontend/ML/DevOps) picks up task.
- Code generated and committed to repo.
- QA agent validates functionality.
- DevOps agent ensures deployment readiness.
- Human approves production deployment.

Security and Compliance

- Agents must not generate or modify HMRC credentials.
- Sensitive data must remain in Key Vault and never appear in code.
- All agents must respect audit logging requirements.
- ML agent must not auto‑deploy new models without QA validation.

Operational Concerns

- Agents run locally in VS Code or remotely via orchestrator.
- All generated code must be container‑ready.
- GitOps ensures reproducible deployments.
- Observability is mandatory for all agent‑generated services.

Risks and Mitigations

- Risk: Agents generating inconsistent code.
	- Mitigation: `architecture.md` as authoritative reference.
- Risk: ML model drift.
	- Mitigation: versioning, evaluation reports, QA approval.
- Risk: Incorrect HMRC payloads.
	- Mitigation: schema validation and sandbox testing.
- Risk: DevOps misconfiguration.
	- Mitigation: GitOps with review gates.

Open Questions

- Should agents be allowed to refactor existing code automatically?
- Should ML agent run training jobs locally or via Azure ML?
- Should DevOps agent manage secrets rotation?

References

- `architecture.md`
- `hmrc-integration.md`
- `sprint-backlog.md`
- Azure and HMRC documentation
