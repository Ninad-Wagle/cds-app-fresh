HMRC Incident Playbook

Purpose

Detailed operational playbook for HMRC CDS incidents, prolonged rate-limiting, or integration outages.

Roles & contacts

- On-call engineer: investigates alerts, triages, coordinates mitigation.
- Engineering lead: decision-maker for escalation and customer comms.
- Product owner: customer notifications and business impact assessment.
- Account manager (HMRC): escalation contact for prolonged HMRC outages.

Severity levels

- Sev1 (Critical): CDS submissions failing at scale (majority of submissions 5xx/429) or data-loss risk.
- Sev2 (High): Elevated throttling or partial outages affecting significant customers.
- Sev3 (Medium): Intermittent failures affecting small number of submissions.

Immediate actions (first 15 minutes)

1. Acknowledge alert and assign on-call engineer.
2. Capture scope: time window, affected endpoints, error codes (429/5xx), queue depth, and recent correlation ids.
3. If 429s dominate: check `Retry-After` headers and HMRC status pages or support channels.
4. Pause automated aggressive replays; ensure exponential backoff is applied.
5. Notify stakeholders (ops, engineering lead, product) with initial summary.

Containment (15–60 minutes)

- Reduce retry aggressiveness: increase backoff cap, respect `Retry-After` headers strictly.
- Throttle client activity where possible (UI rate-limits, limit bulk imports) to reduce load.
- Switch to manual review mode for queued items (move to 'blocked' state visible to ops UI).

Recovery (60+ minutes)

- If HMRC recovers, resume controlled replay of queued messages (small batches), monitoring error rates.
- Validate a sample set of successful re-submissions (check HMRC correlation ids and business outcomes).
- If persistent failure: escalate to HMRC account manager with sample correlation ids and timestamps.

Communication

- Internal: update incident channel every 30 minutes with status, recent metrics, and next steps.
- External: if customers affected, prepare a short notification explaining impact and expected timeline. Keep tone factual and include mitigation steps.

Post-incident actions

- Root cause analysis: gather traces, failed payloads, headers, and timestamps.
- Update backoff and retry parameters and the incident runbook as needed.
- Add synthetic tests to detect similar issues earlier.
- Consider implementing pre-warming or staggered submission windows for large-batch brokers.

Tools and scripts

- `scripts/replay-queued.ps1` (ops only): safe replay tool that reads queued messages and submits in small batches with backoff.
- `scripts/convert_svgs.ps1`: converts architecture diagrams to PNG.

Appendix: Sample escalation message to HMRC

Subject: Urgent - CDS API high 429/5xx rate affecting [Company]

Body:
- Time range (UTC): 2026-03-05T09:00Z - 2026-03-05T09:27Z
- Impact: ~X submissions returned 429/5xx; system currently queued Y messages.
- Example correlation ids: [id1, id2, id3]
- Request: Please confirm whether there is a known issue or rate-limit change and advise on expected ETA for recovery.

Include any contractual or account reference numbers as needed when contacting HMRC support.
