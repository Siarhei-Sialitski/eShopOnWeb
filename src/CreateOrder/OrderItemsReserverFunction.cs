using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Storage.Blob;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace OrderItemsReserver
{
    public static class OrderItemsReserverFunction
    {
        [FunctionName("ReserveOrder")]
        public static async Task<IActionResult> Run(
            //[HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            [ServiceBusTrigger("%QueueName%", Connection = "ServiceBusConnection")] string queueItem,
            [Blob("orders/{rand-guid}.json", FileAccess.ReadWrite, Connection = "AzureWebJobsStorage")] CloudBlockBlob outputBlob,
            ILogger log)
        {
            log.LogInformation("Service Bus trigger function processed a request.");
            

            string requestBody = await new StreamReader(queueItem).ReadToEndAsync();
            
            await outputBlob.UploadTextAsync(queueItem);
            var responseMessage = $"Order information was successfully reserved";
            log.LogInformation($"Order reserved: {requestBody}");

            return new OkObjectResult(responseMessage);
        }
    }
}
