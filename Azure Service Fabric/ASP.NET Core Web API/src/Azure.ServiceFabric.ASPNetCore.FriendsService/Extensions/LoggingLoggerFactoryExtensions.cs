using Microsoft.AspNetCore.Hosting;
using Microsoft.Diagnostics.EventFlow;
using Microsoft.Diagnostics.EventFlow.Inputs;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace Azure.ServiceFabric.ASPNetCore.FriendsService.Extensions
{
    public static class LoggingLoggerFactoryExtensions
    {
        public static ILoggerFactory UseLogging(
            this ILoggerFactory loggerFactory,
            IHostingEnvironment env,
            DiagnosticPipeline diagnosticPipeline)
        {
            if (env.IsDevelopment())
            {
                // Logs to VS Debug window.
                loggerFactory.AddDebug();
            }

            loggerFactory.AddEventFlow(diagnosticPipeline);

            return loggerFactory;
        }
    }
}
