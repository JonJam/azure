using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(Azure.ApplicationInsights.WebApp.Startup))]
namespace Azure.ApplicationInsights.WebApp
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
