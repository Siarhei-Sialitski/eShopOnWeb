using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using Microsoft.eShopWeb.ApplicationCore.Entities.OrderAggregate;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using Microsoft.eShopWeb.Web.Services.WarehouseService.Dtos;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace Microsoft.eShopWeb.Web.Services.WarehouseService;

public class WarehouseService : IWarehouseService
{
    private readonly WarehouseServiceConfiguration _orderItemsReserverConfiguration;
    private readonly ILogger<WarehouseService> _logger;
    private readonly ServiceBusClient _serviceBusClient;

    public WarehouseService(
        WarehouseServiceConfiguration orderItemsReserverConfiguration,
        ILogger<WarehouseService> logger, 
        ServiceBusClient serviceBusClient)
    {
        _orderItemsReserverConfiguration = orderItemsReserverConfiguration;
        _logger = logger;
        _serviceBusClient = serviceBusClient;
    }

    public async Task ProcessOrderAsync(Order order)
    {
        var warehouseItems = new List<WarehouseOrderItemDto>();
        foreach (var item in order.OrderItems)
        {
            warehouseItems.Add(new WarehouseOrderItemDto
            {
                Name = item.ItemOrdered.ProductName,
                Amount = item.Units
            });
        }
        _logger.LogInformation("-->Reserve order items: {items}", JsonConvert.SerializeObject(warehouseItems));

        await ReserveOrderItemsInWarehouse(warehouseItems);
    }

    private async Task ReserveOrderItemsInWarehouse(List<WarehouseOrderItemDto> reserveList)
    {
        if (IsServiceConfigured)
        {
            var sender = _serviceBusClient.CreateSender(_orderItemsReserverConfiguration.QueueName);
            try
            {
                var messageBody = JsonConvert.SerializeObject(reserveList);
                var message = new ServiceBusMessage(messageBody);

                await sender.SendMessageAsync(message);
            }
            catch (Exception exception)
            {
                _logger.LogError(exception, "Warehouse order reserve finished with exception.");
            }
        }
        else
        {
            _logger.LogError("Warehouse Service is not configured.");
        }
    }

    private bool IsServiceConfigured
    {
        get
        {
            return !(string.IsNullOrWhiteSpace(_orderItemsReserverConfiguration.ConnectionString)
                || string.IsNullOrWhiteSpace(_orderItemsReserverConfiguration.QueueName));
        }
    }

}
