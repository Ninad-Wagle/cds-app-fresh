HMRC Rate-Limit & Backoff Runbook

Purpose

Provide concise guidance for handling HMRC CDS rate limits, throttling, and transient errors.

Immediate handling

- Inspect HMRC response headers for rate-limit or retry-after values.
- If `429` (Too Many Requests):
  - Read `Retry-After` header (seconds) and defer retries accordingly.
  - Increment backoff window: use exponential backoff with jitter (e.g., base 2s, max 120s).
  - Enqueue the payload to a durable queue (Azure Storage Queue / Service Bus) with retry metadata.
- If `5xx` transient errors:
  - Apply exponential backoff with capped retries (e.g., 5 attempts).
  - After retry exhaustion, mark submission for manual review and notify on-call.

Retry strategy

- Use exponential backoff with decorrelated jitter (full-jitter):
  - sleep = random_uniform(0, min(cap, base * 2^attempt))
- Respect `Retry-After` if present; set next attempt = now + Retry-After.
- Persist retry metadata (attempt count, last error, next scheduled attempt) in SQL or queue message.

Queueing and durability

- Use durable queue for submissions: store original payload + metadata + correlation id.
- Worker functions poll queue and attempt submission with backoff logic.
- Support manual requeue/rescue for items moved to dead-letter after retry exhaustion.

Observability & alerts

- Metrics:
  - Submission attempts, successes, failures, retries, throttled count (429s).
  - Average retry latency and queue depth.
- Alerts:
  - High rate of 5xx or 429 (>X/minute) → page on-call.
  - Growing queue depth or sustained retry exhaustion.

Operational runbook

1. On alert, check Application Insights for recent 429/5xx spikes and request traces.
2. Inspect queue depth and sample messages from the queue or dead-letter queue.
3. If HMRC reports a system incident, pause automated retries and switch to manual review mode.
4. Notify stakeholders (ops, engineering, product) with correlation ids for affected submissions.
5. For prolonged HMRC outages, escalate to account manager at HMRC (use established contacts) and implement a communication plan for customers.

Post-incident

- Gather failed submission samples, error codes and timestamps.
- Run root-cause analysis and update backoff parameters or code as needed.
- Add replay scripts to re-submit queued payloads once HMRC recovers.
