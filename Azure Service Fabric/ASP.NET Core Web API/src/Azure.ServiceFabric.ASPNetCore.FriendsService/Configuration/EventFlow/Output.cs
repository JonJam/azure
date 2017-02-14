using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Azure.ServiceFabric.ASPNetCore.FriendsService.Configuration.EventFlow
{
    public class Output
    {
        [JsonProperty("type")]
        public string Type { get; set; }

        [JsonProperty("instrumentationKey")]
        public string InstrumentationKey { get; set; }
    }
}
