using System;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection;

[assembly: FunctionsStartup(typeof(OrderItemsReserver.Startup))]
namespace OrderItemsReserver
{

    public class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            builder.Services.AddHttpClient<IAlternateOrderProcessor, SendEmailAlternateOrderProcessor>(c =>
            {
                c.BaseAddress = new Uri(Environment.GetEnvironmentVariable("LogicAppEndpoint"));
            });
        }
    }
}
