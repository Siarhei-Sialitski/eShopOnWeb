using Microsoft.Azure.Functions.Extensions.DependencyInjection;

[assembly: FunctionsStartup(typeof(OrderItemsReserver.Startup))]
namespace OrderItemsReserver
{

    public class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            //throw new NotImplementedException();
        }
    }
}
