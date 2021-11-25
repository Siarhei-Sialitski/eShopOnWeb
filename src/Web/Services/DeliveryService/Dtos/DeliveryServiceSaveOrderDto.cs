using System.Collections.Generic;

namespace Microsoft.eShopWeb.Web.Services.DeliveryService.Dtos;

public class DeliveryServiceSaveOrderDto
{
    public string ShippingAddress { get; set; }
    public decimal Price { get; set; }
    public List<DeliveryOrderItemDto> OrderItems { get; set; }
}

public class DeliveryOrderItemDto
{
    public string ItemName { get; set; }
    public int Amount { get; set; }
}
