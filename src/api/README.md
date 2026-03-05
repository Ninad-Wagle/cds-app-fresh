cds-api (minimal)
===================

Minimal .NET 8 Web API providing a `/health` endpoint used by the backend agent.

Build & run (requires .NET 8 SDK):

```powershell
cd src/api
dotnet build CdsApi.csproj
dotnet run --project CdsApi.csproj --urls "http://localhost:5000"
```

Health endpoint

```
GET http://localhost:5000/health

Response: 200 { "status":"Healthy", "timestamp":"...", "service":"cds-api", "version":"0.1.0" }
```

Notes

- This is intentionally minimal — swap in health checks for DB/HMRC when services are available.
- To produce a container image, add a Dockerfile and build with `docker build`.
