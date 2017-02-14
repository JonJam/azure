﻿using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Azure.ServiceFabric.ASPNetCore.FriendsService.Configuration.EventFlow
{
    public class Filter
    {
        [JsonProperty("type")]
        public string Type { get; set; }

        [JsonProperty("include")]
        public string Include { get; set; }
    }

}
