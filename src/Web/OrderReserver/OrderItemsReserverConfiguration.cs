namespace Microsoft.eShopWeb.Web.OrderReserver
{
    public class OrderItemsReserverConfiguration
    {
        public const string CONFIG_NAME = "OrderItemsReserverConfig";
        public string ConnectionString { get; set; }
        public string QueueName { get; set; }
    }
}
