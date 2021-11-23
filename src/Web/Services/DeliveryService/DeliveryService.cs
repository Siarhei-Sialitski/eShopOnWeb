using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using Microsoft.eShopWeb.ApplicationCore.Entities.OrderAggregate;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using Microsoft.eShopWeb.Web.Services.DeliveryService.Dtos;
using Microsoft.eShopWeb.Web.Services.WarehouseService;
using Microsoft.Extensions.Logging;

namespace Microsoft.eShopWeb.Web.Services.DeliveryService;

public class DeliveryService : IDeliveryService
{
    private readonly HttpClient _httpClient;
    private readonly DeliveryServiceConfiguration _deliveryOrderReserverConfiguration;
    private readonly ILogger<DeliveryService> _logger;

    public DeliveryService(HttpClient httpClient,
        DeliveryServiceConfiguration deliveryOrderReserverConfiguration,
        ILogger<DeliveryService> logger)
    {
        _httpClient = httpClient;
        _deliveryOrderReserverConfiguration = deliveryOrderReserverConfiguration;
        _logger = logger;
    }

    public async Task ProcessOrderAsync(Order order)
    {
        if (IsServiceConfigured)
        {
            var deliveryOrder = new DeliveryServiceSaveOrderDto()
            {
                ShippingAddress = order.ShipToAddress.ToString(),
                Price = order.Total(),
                OrderItems = new System.Collections.Generic.List<DeliveryOrderItemDto>()
            };
            foreach (var item in order.OrderItems)
            {
                deliveryOrder.OrderItems.Add(new DeliveryOrderItemDto
                {
                    ItemName = item.ItemOrdered.ProductName,
                    Amount = item.Units
                });
            }
            _httpClient.DefaultRequestHeaders.Add("x-functions-key", _deliveryOrderReserverConfiguration.FunctionKey);
            await _httpClient.PostAsync("deliveryorder", JsonContent.Create(deliveryOrder));
        }
        else
        {
            _logger.LogError("Delivery Service is not configured.");
        }
    }

    private bool IsServiceConfigured
    {
        get
        {
            return !(string.IsNullOrWhiteSpace(_deliveryOrderReserverConfiguration.FunctionBaseUrl)
                || string.IsNullOrWhiteSpace(_deliveryOrderReserverConfiguration.FunctionKey));
        }
    }
}
