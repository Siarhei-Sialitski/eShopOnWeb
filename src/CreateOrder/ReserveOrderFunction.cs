using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.Storage.Blob;
using Newtonsoft.Json;

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
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            var orderInformation = data?.OrderInformation;

            string responseMessage = String.Empty;

            if (string.IsNullOrEmpty(Convert.ToString(orderInformation)))
            {
                responseMessage =
                    "This HTTP triggered function executed successfully. Pass an order information in the request body to put data to blob.";
            }
            else
            {
                await outputBlob.UploadTextAsync(Convert.ToString(orderInformation));
                responseMessage = $"Order information was successfully reserved";
            }

            return new OkObjectResult(responseMessage);
        }
    }
}
