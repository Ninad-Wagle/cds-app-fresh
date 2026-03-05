var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("/health", () => Results.Json(new
{
    status = "Healthy",
    timestamp = DateTime.UtcNow,
    service = "cds-api",
    version = "0.1.0"
}));

app.Run();
