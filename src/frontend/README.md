cds-frontend (minimal Blazor WASM)
=================================

This is a minimal Blazor WebAssembly front-end with a `Health` page that calls the backend API `/health` endpoint and displays the returned JSON.

Build & run (requires .NET 8 SDK):

```powershell
cd src/frontend
dotnet build CdsFrontend.csproj
dotnet run --project CdsFrontend.csproj
```

Notes
- The `Health` page calls `http://localhost:5000/health` by default; change this if your API runs on a different host/port.
- This is a small starter app; integrate into your existing frontend or expand with authentication and real config as needed.
