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

        public OrderReserverService(OrderReserverConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task ReserveAsync(List<OrderItem> orderItems)
        {
            var httpClient = new HttpClient()
            {
                BaseAddress = new Uri(_configuration.FuntionBaseUrl)
            };
            
            httpClient.DefaultRequestHeaders.Add("x-functions-key", _configuration.FunctionKey);
            await httpClient.PostAsync("reserveorder", JsonContent.Create(orderItems));
        }
    }
}
