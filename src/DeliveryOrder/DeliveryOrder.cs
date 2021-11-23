using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;

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
            log.LogInformation("--> Delivery Order Function");
            

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();

            await documentsOut.AddAsync(new
            {
                id = System.Guid.NewGuid().ToString(),
                body = requestBody
            });
            
            var responseMessage = $"Order information was successfully saved to delivery database.";

            log.LogInformation("Order saved to delivery database: {requestBody}", requestBody);
            log.LogInformation("<-- Delivery Order Function");

            return new OkObjectResult(responseMessage);
        }
    }
}
