using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Azure.ServiceFabric.ASPNetCore.FriendsService.Configuration.EventFlow;

namespace Azure.ServiceFabric.ASPNetCore.FriendsService.Configuration
{
    public class EventFlowOptions
    {
        [JsonProperty("inputs")]
        public Input[] Inputs { get; set; }
        
        [JsonProperty("filters")]
        public Filter[] Filters { get; set; }

        [JsonProperty("outputs")]
        public Output[] Outputs { get; set; }

        [JsonProperty("schemaVersion")]
        public string SchemaVersion { get; set; }
    }

}