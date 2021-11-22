using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace DeliveryOrder
{
    public static class DeliveryOrder
    {
        [FunctionName("DeliveryOrder")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            [CosmosDB(databaseName: "DeliveryOrders", collectionName: "orders", ConnectionStringSetting = "CosmosDbConnectionString")]IAsyncCollector<dynamic> documentsOut,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");
            

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();

            await documentsOut.AddAsync(new
            {
                id = System.Guid.NewGuid().ToString(),
                body = requestBody
            });
            
            var responseMessage = $"Order information was successfully saved to delivery database";
            log.LogInformation($"Order saved to delivery database: {requestBody}");

            return new OkObjectResult(responseMessage);
        }
    }
}
