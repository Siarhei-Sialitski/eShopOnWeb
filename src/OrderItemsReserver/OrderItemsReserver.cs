using System;
using System.Globalization;
using System.IO;
using System.Threading.Tasks;
using Azure.Storage.Blobs;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace OrderItemsReserver
{
    public static class OrderItemsReserver
    {
        [FunctionName("OrderItemsReserver")]
        public async static Task Run([ServiceBusTrigger("%QueueName%", Connection = "ServiceBusConnection")]string myQueueItem, 
            [Blob("orders/{rand-guid}.json", FileAccess.ReadWrite, Connection = "AzureWebJobsStorage")] BlobContainerClient outputBlob,
            ILogger log)
        {
            log.LogInformation($"C# ServiceBus queue trigger function processed message: {myQueueItem}");

            await outputBlob.CreateIfNotExistsAsync();
            
            string blobName = DateTime.Now.ToString(CultureInfo.InvariantCulture);
            var state = await outputBlob.UploadBlobAsync(blobName, BinaryData.FromString(myQueueItem));
            log.LogInformation($"Order reserved: {myQueueItem}");
        }
    }
}
