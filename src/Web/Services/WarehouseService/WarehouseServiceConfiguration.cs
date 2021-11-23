namespace Microsoft.eShopWeb.Web.Services.WarehouseService;

public class WarehouseServiceConfiguration
{
    public const string CONFIG_NAME = "WarehouseServiceConfiguration";
    public string ConnectionString { get; set; }
    public string QueueName { get; set; }
}
