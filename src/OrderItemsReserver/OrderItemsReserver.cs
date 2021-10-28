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
        public async static Task Run([ServiceBusTrigger("OrderItems", Connection = "ServiceBusConnection")]string myQueueItem, 
            [Blob("orders/{rand-guid}.json", FileAccess.ReadWrite, Connection = "AzureWebJobsStorage")] BlobContainerClient outputBlob,
            ILogger log)
        {
            log.LogInformation($"C# ServiceBus queue trigger function processed message: {myQueueItem}");
            
            var policy = Policy.Handle<Exception>().WaitAndRetry(3,
                attempt => TimeSpan.FromSeconds(0.1 * Math.Pow(2, attempt)),
                (exception, calculatedWaitDuration) =>
                {
                    log.LogInformation($"exception: {exception.Message}");  
                });
            try
            {
                await policy.Execute(async () =>
                {
                    await outputBlob.CreateIfNotExistsAsync();

                    throw new Exception("Manual exception");
                    string blobName = DateTime.Now.ToString("MM_dd_yyyy/H:mm:ss");
                    var state = await outputBlob.UploadBlobAsync(blobName, BinaryData.FromString(myQueueItem));
                    log.LogInformation($"Order reserved: {myQueueItem} under {blobName}");
                    
                });        
            }
            catch (Exception e)
            {
                // Can't recover at this point
                log.LogInformation($"critical error: {e.Message}");
                var logicAppEndpoint = Environment.GetEnvironmentVariable("LogicAppEndpoint");
                if (!string.IsNullOrEmpty(logicAppEndpoint))
                {
                    var client = new HttpClient();
                    client.BaseAddress = new Uri(logicAppEndpoint);
                    await client.PostAsync("", new StringContent(myQueueItem));
                }
                else
                {
                    throw;
                }
            }
        }
    }
}
