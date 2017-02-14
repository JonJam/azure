using System;
using Xunit;
using Azure.ServiceFabric.ASPNetCore.FriendsService.Controllers;

namespace Azure.ServiceFabric.ASPNetCore.FriendsService.Tests.Integration
{
    [Trait("Category", "Integration")]
    public class FriendsControllerTests
    {
        [Fact]
        public void Test1()
        {
            FriendsController x = new FriendsController();

            var y = x.Get();

            Assert.NotNull(y);
        }
    }
}
