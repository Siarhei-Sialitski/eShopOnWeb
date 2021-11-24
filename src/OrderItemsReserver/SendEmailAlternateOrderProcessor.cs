using System;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace OrderItemsReserver
{
    internal class SendEmailAlternateOrderProcessor : IAlternateOrderProcessor
    {
        private readonly ILogger _log;
        private readonly HttpClient _httpClient;

        public SendEmailAlternateOrderProcessor(HttpClient httpClient,
            ILogger<SendEmailAlternateOrderProcessor> log)
        {
            _log = log;
            _httpClient = httpClient;
        }

        public async Task<bool> ProcessAsync(string queueItem)
        {
            _log.LogWarning("Blob upload failed, attempt to use Logic App as alternate processor.");
            var logicAppEndpoint = Environment.GetEnvironmentVariable("LogicAppEndpoint");
            if (!string.IsNullOrEmpty(logicAppEndpoint))
            {
                var messageBody = $"Blob upload failed.{Environment.NewLine}{queueItem}";
                var response = await _httpClient.PostAsync("", new StringContent(messageBody));
                if (response.IsSuccessStatusCode)
                {
                    _log.LogWarning("Logic App used successfully");
                }
                else
                {
                    _log.LogError("Logic App processing failed.");
                }
                return true;
            }
            else
            {
                _log.LogError("Logic App endpoint not configured.");
                return false;
            }
        }
    }
}
