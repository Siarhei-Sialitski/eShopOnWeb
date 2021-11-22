using System;
using System.Net.Http;
using System.Threading.Tasks;
using BlazorAdmin.Services;
using Blazored.LocalStorage;
using BlazorShared;
using BlazorShared.Models;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace BlazorAdmin;

public class Program
{
    public static async Task Main(string[] args)
    {
        var builder = WebAssemblyHostBuilder.CreateDefault(args);
        builder.RootComponents.Add<App>("#admin");

            var baseUrlConfig = new BaseUrlConfiguration();
            baseUrlConfig.ApiBase = builder.Configuration.GetSection("apiBase").Value;
            baseUrlConfig.WebBase = builder.Configuration.GetSection("webBase").Value;
            builder.Services.AddScoped<BaseUrlConfiguration>(sp => baseUrlConfig);

        builder.Services.AddScoped(sp => new HttpClient() { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) });

        builder.Services.AddScoped<ToastService>();
        builder.Services.AddScoped<HttpService>();

        builder.Services.AddBlazoredLocalStorage();

        builder.Services.AddAuthorizationCore();
        builder.Services.AddScoped<AuthenticationStateProvider, CustomAuthStateProvider>();
        builder.Services.AddScoped(sp => (CustomAuthStateProvider)sp.GetRequiredService<AuthenticationStateProvider>());

        builder.Services.AddBlazorServices();

        builder.Logging.AddConfiguration(builder.Configuration.GetSection("Logging"));

        await ClearLocalStorageCache(builder.Services);

        await builder.Build().RunAsync();
    }

    private static async Task ClearLocalStorageCache(IServiceCollection services)
    {
        var sp = services.BuildServiceProvider();
        var localStorageService = sp.GetRequiredService<ILocalStorageService>();

        await localStorageService.RemoveItemAsync(typeof(CatalogBrand).Name);
        await localStorageService.RemoveItemAsync(typeof(CatalogType).Name);
    }
}
