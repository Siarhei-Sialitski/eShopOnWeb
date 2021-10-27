using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Json;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Azure.ServiceBus;
using Microsoft.eShopWeb.ApplicationCore.Entities.OrderAggregate;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace Microsoft.eShopWeb.Web.OrderReserver
{
    public class OrderReserverService : IOrderReserverService
    {
        private readonly OrderItemsReserverConfiguration _orderItemsReserverConfiguration;
        private readonly DeliveryOrderReserverConfiguration _deliveryOrderReserverConfiguration;
        private readonly ILogger<OrderReserverService> _logger;
        private IQueueClient _orderItemsReserverQueueClient;

        public OrderReserverService(
            OrderItemsReserverConfiguration orderItemsReserverConfiguration, 
            DeliveryOrderReserverConfiguration deliveryOrderReserverConfiguration,
            ILogger<OrderReserverService> _logger)
        {
            _orderItemsReserverConfiguration = orderItemsReserverConfiguration;
            _deliveryOrderReserverConfiguration = deliveryOrderReserverConfiguration;
            this._logger = _logger;
        }

        public async Task ReserveAsync(List<OrderItem> orderItems, string shippingAddress)
        {
            var reserveList = new List<ReserveItem>();
            foreach (var orderItem in orderItems)
            {
                reserveList.Add(new ReserveItem()
                {
                    ItemId = orderItem.ItemOrdered.CatalogItemId,
                    Quantity = orderItem.Units,
                    Price = orderItem.UnitPrice
                });
            }

            await ReserverOrderItemsInWarehouse(reserveList);
            //await SendOrderToDeliveryAsync(reserveList, shippingAddress);
        }

        private async Task ReserverOrderItemsInWarehouse(List<ReserveItem> reserveList)
        {
            _orderItemsReserverQueueClient = new QueueClient(_orderItemsReserverConfiguration.ConnectionString, _orderItemsReserverConfiguration.QueueName);
            try
            {
                var messageBody = JsonConvert.SerializeObject(reserveList);
                var message = new Message(Encoding.UTF8.GetBytes(messageBody));

                _logger.LogWarning(messageBody);
                
                await _orderItemsReserverQueueClient.SendAsync(message);

            }
            catch (Exception exception)
            {
                _logger.LogError($"Logger during queue item sending. :: Exception: {exception.Message}");
            }

            await _orderItemsReserverQueueClient.CloseAsync();
        }

        private async Task SendOrderToDeliveryAsync(List<ReserveItem> reserveList, string shippingAddress)
        {
            decimal finalPrice = 0;
            foreach (var reserveItem in reserveList)
            {
                finalPrice += reserveItem.Price * reserveItem.Quantity;
            }

            var httpClient = new HttpClient()
            {
                BaseAddress = new Uri(_deliveryOrderReserverConfiguration.FunctionBaseUrl)
            };
            httpClient.DefaultRequestHeaders.Add("x-functions-key", _deliveryOrderReserverConfiguration.FunctionKey);
            await httpClient.PostAsync("deliveryorder", JsonContent.Create(new
            {
                ShippingAddress = shippingAddress,
                FinalPrice = finalPrice,
                ItemsList = reserveList.ToArray()
            }));
        }

        class ReserveItem
        {
            public int ItemId { get; set; }
            public int Quantity { get; set; }
            public decimal Price { get; set; }
        }
    }
}
