using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Azure.ServiceFabric.ASPNetCore.FriendsService.Configuration.EventFlow
{
    public class Source
    {
        [JsonProperty("providerName")]
        public string ProviderName { get; set; }
    }
}
