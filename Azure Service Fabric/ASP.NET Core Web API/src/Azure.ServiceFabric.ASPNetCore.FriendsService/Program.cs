using Microsoft.Diagnostics.EventFlow;
using Microsoft.Diagnostics.EventFlow.ServiceFabric;
using Microsoft.ServiceFabric.Services.Runtime;
using System;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;

using System.Linq;
using System.IO;
using System.Reflection;
using Newtonsoft.Json;
using Azure.ServiceFabric.ASPNetCore.FriendsService.Configuration;
using System.Fabric;

namespace Azure.ServiceFabric.ASPNetCore.FriendsService
{
    internal static class Program
    {
        public static DiagnosticPipeline DiagnosticsPipeline
        {
            get;
            private set;
        }

        /// <summary>
        /// This is the entry point of the service host process.
        /// </summary>
        private static void Main()
        {
            try
            {
                Program.UpdateEventFlowConfiguration();

                using (Program.DiagnosticsPipeline = ServiceFabricDiagnosticPipelineFactory.CreatePipeline("Azure.ServiceFabric.ASPNetCore.FriendsService"))
                {
                    ServiceRuntime.RegisterServiceAsync("FriendsServiceType", context => new FriendsService(context)).GetAwaiter().GetResult();

                    ServiceEventSource.Current.ServiceTypeRegistered(Process.GetCurrentProcess().Id, typeof(FriendsService).Name);

                    // Prevents this host process from terminating so services keeps running. 
                    Thread.Sleep(Timeout.Infinite);
                }
            }
            catch (Exception e)
            {
                ServiceEventSource.Current.ServiceHostInitializationFailed(e.ToString());
                throw;
            }
        }

        private static void UpdateEventFlowConfiguration()
        {
            string appInsightsKey = Environment.GetEnvironmentVariable("EventFlow:ApplicationInsightsKey");
            string logFilter = Environment.GetEnvironmentVariable("EventFlow:LogFilter");

            CodePackageActivationContext activationContext = FabricRuntime.GetActivationContext();
            ConfigurationPackage configPackage = activationContext.GetConfigurationPackageObject("Config");
            string configFilePath = Path.Combine(configPackage.Path, "eventFlowConfig.json");
            string content = File.ReadAllText(configFilePath);

            EventFlowOptions options = JsonConvert.DeserializeObject<EventFlowOptions>(content);
            options.Outputs[0].InstrumentationKey = appInsightsKey;
            options.Filters[0].Include = logFilter;

            File.WriteAllText(configFilePath, JsonConvert.SerializeObject(options));
        }
    }
}
