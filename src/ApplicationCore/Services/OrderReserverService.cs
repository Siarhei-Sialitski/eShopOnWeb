using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Json;
using System.Text;
using System.Threading.Tasks;
using Microsoft.eShopWeb.ApplicationCore.Entities.OrderAggregate;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using Newtonsoft.Json;

namespace Microsoft.eShopWeb.ApplicationCore.Services
{
    public class OrderReserverService : IOrderReserverService
    {
        private readonly OrderReserverConfiguration _configuration;
        private readonly DeliveryOrderReserverConfiguration _deliveryOrderReserverConfiguration;

        public OrderReserverService(OrderReserverConfiguration configuration, DeliveryOrderReserverConfiguration deliveryOrderReserverConfiguration)
        {
            _configuration = configuration;
            _deliveryOrderReserverConfiguration = deliveryOrderReserverConfiguration;
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

            await SendOrderToStockAsync(reserveList);
            await SendOrderToDeliveryAsync(reserveList, shippingAddress);
        }

        private async Task SendOrderToStockAsync(List<ReserveItem> reserveList)
        {
            var httpClient = new HttpClient()
            {
                BaseAddress = new Uri(_configuration.FunctionBaseUrl)
            };
            httpClient.DefaultRequestHeaders.Add("x-functions-key", _configuration.FunctionKey);
            await httpClient.PostAsync("reserveorder", JsonContent.Create(reserveList));
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
