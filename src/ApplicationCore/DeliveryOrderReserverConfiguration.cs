using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.eShopWeb.ApplicationCore
{
    public class DeliveryOrderReserverConfiguration
    {
        public const string CONFIG_NAME = "DeliveryOrderReserverConfiguration";
        public string FunctionBaseUrl { get; set; }
        public string FunctionKey { get; set; }
    }
}
