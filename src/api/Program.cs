var builder = WebApplication.CreateBuilder(args);

// Configure CORS for local frontend development
var allowLocalOrigins = "AllowLocalOrigins";
builder.Services.AddCors(options =>
{
    options.AddPolicy(name: allowLocalOrigins, policy =>
    {
        policy.WithOrigins("http://localhost:5000", "https://localhost:5001", "http://localhost:5010")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

app.UseCors(allowLocalOrigins);

app.MapGet("/health", () => Results.Json(new
{
    status = "Healthy",
    timestamp = DateTime.UtcNow,
    service = "cds-api",
    version = "0.1.0"
}));

app.Run();
