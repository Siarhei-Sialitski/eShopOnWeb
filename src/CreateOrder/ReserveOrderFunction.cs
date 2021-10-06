using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Storage.Blob;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;

namespace CreateOrder
{
    public static class ReserveOrderFunction
    {
        [FunctionName("ReserveOrder")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            [Blob("orders/{rand-guid}.json", FileAccess.ReadWrite, Connection = "AzureWebJobsStorage")] CloudBlockBlob outputBlob,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");
            

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            
            await outputBlob.UploadTextAsync(requestBody);
            var responseMessage = $"Order information was successfully reserved";
            log.LogInformation($"Order reserved: {requestBody}");

            return new OkObjectResult(responseMessage);
        }
    }
}
