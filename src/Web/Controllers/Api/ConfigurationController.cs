using BlazorShared;
using Microsoft.AspNetCore.Mvc;

namespace Microsoft.eShopWeb.Web.Controllers.Api
{
    [ApiController]
    [Route("[controller]")]
    public class ConfigurationController : ControllerBase
    {
        private readonly BaseUrlConfiguration _baseUrlConfiguration;

        public ConfigurationController(BaseUrlConfiguration baseUrlConfiguration)
        {
            _baseUrlConfiguration = baseUrlConfiguration;
        }

        [HttpGet]
        public ActionResult GetConfiguration()
        {
            return Ok(_baseUrlConfiguration);
        }
    }
}
