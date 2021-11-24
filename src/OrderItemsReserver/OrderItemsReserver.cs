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
    public class OrderItemsReserver
    {
        private readonly IAlternateOrderProcessor _alternateOrderProcessor;

        public OrderItemsReserver(IAlternateOrderProcessor alternateOrderProcessor)
        {
            _alternateOrderProcessor = alternateOrderProcessor;
        }

        [FunctionName("OrderItemsReserver")]
        public async Task Run([ServiceBusTrigger("%QueueName%sbq-orders-prod-westeurope", Connection = "ServiceBusConnection")]string myQueueItem, 
            [Blob("orders/{rand-guid}.json", FileAccess.ReadWrite, Connection = "AzureWebJobsStorage")] BlobContainerClient outputBlob,
            ILogger log)
        {
            log.LogWarning("--> Warehouse order process function.");
            log.LogWarning("--> Service bus message: {myQueueItem}", myQueueItem);
            
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
                    log.LogWarning("Blob uploaded {blobName}", blobName);
                    
                });        
            }
            catch (Exception)
            {
                if (!await _alternateOrderProcessor.ProcessAsync(myQueueItem))
                {
                    throw;
                }
            }
            log.LogWarning("<-- Warehouse order process function.");
        }

    }
}
