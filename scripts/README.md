Start-dev scripts

This folder contains helper scripts to start the API and frontend in development.

Files

- `start-dev.ps1` — PowerShell script for Windows. Prompts to kill the process using the API port if needed, then starts API and frontend using `dotnet run`.
- `start-dev.sh` — POSIX shell script for macOS / Linux / Git Bash. Similar behaviour: starts API on port 5010 by default and the frontend, logging output to `logs/`.

Usage

Windows (PowerShell):

```powershell
cd <repo-root>
powershell -ExecutionPolicy Bypass -File .\scripts\start-dev.ps1
```

Unix-like (bash):

```bash
cd <repo-root>
./scripts/start-dev.sh [API_PORT]
```

Notes

- The scripts assume the repository layout created by the scaffold: `src/api` and `src/frontend` projects.
- The shell script creates `logs/` output files. Ensure you have write permissions.
