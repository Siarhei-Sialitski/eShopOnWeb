using System;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;
using Azure.Storage.Blobs;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Polly;

namespace OrderItemsReserver
{
    public static class OrderItemsReserver
    {
        [FunctionName("OrderItemsReserver")]
        public async static Task Run([ServiceBusTrigger("sbq-orders-prod-westeurope", Connection = "ServiceBusConnection")]string myQueueItem, 
            [Blob("orders/{rand-guid}.json", FileAccess.ReadWrite, Connection = "AzureWebJobsStorage")] BlobContainerClient outputBlob,
            ILogger log)
        {
            log.LogInformation("--> Warehouse order process function.");
            log.LogInformation("Service bus message: {myQueueItem}", myQueueItem);
            
            var policy = Policy.Handle<Exception>().WaitAndRetry(3,
                attempt => TimeSpan.FromSeconds(0.1 * Math.Pow(2, attempt)),
                (exception, calculatedWaitDuration) =>
                {
                    log.LogInformation(exception, "Blob upload failed.");  
                });
            try
            {
                await policy.Execute(async () =>
                {
                    await outputBlob.CreateIfNotExistsAsync();
                    
                    string blobName = DateTime.Now.ToString("MM_dd_yyyy/H:mm:ss");
                    var state = await outputBlob.UploadBlobAsync(blobName, BinaryData.FromString(myQueueItem));
                    log.LogInformation("Blob uploaded {blobName}", blobName);
                    
                });        
            }
            catch (Exception)
            {
                if (!await ProcessOrderWithLogicApp(log, myQueueItem))
                {
                    throw;
                }
            }
            log.LogInformation("<-- Warehouse order process function.");
        }

        private static async Task<bool> ProcessOrderWithLogicApp(ILogger log, string queueItem)
        {
            log.LogInformation("Blob upload failed, attempt to use Logic App as alternate processor.");
            var logicAppEndpoint = Environment.GetEnvironmentVariable("LogicAppEndpoint");
            if (!string.IsNullOrEmpty(logicAppEndpoint))
            {
                var client = new HttpClient
                {
                    BaseAddress = new Uri(logicAppEndpoint)
                };
                var response = await client.PostAsync("", new StringContent(queueItem));
                if (response.IsSuccessStatusCode)
                {
                    log.LogInformation("Logic App used successfully");
                }
                else
                {
                    log.LogError("Logic App processing failed.");
                }
                return true;
            }
            else
            {
                log.LogError("Logic App endpoint not configured.");
                return false;
            }
        }

    }
}
