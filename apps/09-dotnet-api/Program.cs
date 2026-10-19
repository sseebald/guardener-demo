var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/healthz", () => Results.Ok(new { status = "ok", service = "billing" }));

app.MapGet("/api/invoices", () => Results.Ok(new
{
    invoices = new[]
    {
        new { id = "INV-4410", account = "northwind-retail", amount = 1820.00m, status = "open" },
        new { id = "INV-4411", account = "northwind-freight", amount = 640.25m, status = "paid" }
    }
}));

app.Run();
