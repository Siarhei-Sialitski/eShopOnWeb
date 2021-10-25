﻿using System;
using System.Collections.Generic;
using System.Text;
using Azure.Extensions.AspNetCore.Configuration.Secrets;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;

[assembly: FunctionsStartup(typeof(DeliveryOrder.Startup))]
namespace DeliveryOrder
{
    public class Startup : FunctionsStartup
    {
        private IConfiguration _configuration;

        public override void Configure(IFunctionsHostBuilder builder)
        {
        }

        public override void ConfigureAppConfiguration(IFunctionsConfigurationBuilder builder)
        {
            var context = builder.GetContext();
            var configurationBuilder = builder.ConfigurationBuilder;
            // Add the Key Vault:
            var configuration = configurationBuilder.Build();
            var keyVaultUri = $"https://{configuration["keyVaultName"]}.vault.azure.net/";
            configurationBuilder.AddAzureKeyVault(new SecretClient(new Uri(keyVaultUri), new DefaultAzureCredential()), new KeyVaultSecretManager());

            _configuration = configurationBuilder.Build();
        }
    }

    
}
