using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Diagnostics.EventFlow;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Azure.ServiceFabric.ASPNetCore.FriendsService.Configuration;
using Azure.ServiceFabric.ASPNetCore.FriendsService.Extensions;

namespace Azure.ServiceFabric.ASPNetCore.FriendsService
{
    public class Startup
    {
        public Startup(IHostingEnvironment env)
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(env.ContentRootPath)
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
                .AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true)
                .AddEnvironmentVariables();

            this.Configuration = builder.Build();
        }

        private IConfigurationRoot Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            // Adds configuration options.
            services.AddOptions();
            services.AddADB2CConfiguration(this.Configuration);

            // Add framework services.
            services.AddMvc()
                .AddADB2CFilters();

            services.AddSwagger<FriendsService>();

            services.AddSingleton(typeof(DiagnosticPipeline), Program.DiagnosticsPipeline);
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(
            IApplicationBuilder app,
            IHostingEnvironment env,
            ILoggerFactory loggerFactory,
            IOptions<ADB2CAuthenticationOptions> authenticationOptions,
            DiagnosticPipeline diagnosticsPipeline)
        {
            loggerFactory.UseLogging(env, diagnosticsPipeline);

            app.UseADB2C(authenticationOptions);
            app.UseMvc();
            app.UseSwagger<FriendsService>(env);
        }
    }
}
