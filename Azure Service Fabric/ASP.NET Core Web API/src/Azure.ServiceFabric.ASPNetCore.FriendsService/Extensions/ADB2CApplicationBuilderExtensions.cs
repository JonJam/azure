using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Options;
using System.Threading.Tasks;
using Azure.ServiceFabric.ASPNetCore.FriendsService.Configuration;

namespace Azure.ServiceFabric.ASPNetCore.FriendsService.Extensions
{
    public static class ADB2CApplicationBuilderExtensions
    {
        public static IApplicationBuilder UseADB2C(
            this IApplicationBuilder app,
            IOptions<ADB2CAuthenticationOptions> authenticationOptions)
        {
            app.UseJwtBearerAuthentication(new JwtBearerOptions
            {
                AutomaticAuthenticate = true,
                AutomaticChallenge = true,

                MetadataAddress = authenticationOptions.Value.MetadataAddress,
                Audience = authenticationOptions.Value.Audience,

                Events = new JwtBearerEvents
                {
                    OnAuthenticationFailed = ctx =>
                    {
                        ctx.SkipToNextMiddleware();

                        return Task.FromResult(0);
                    }
                }
            });

            return app;
        }
    }
}
