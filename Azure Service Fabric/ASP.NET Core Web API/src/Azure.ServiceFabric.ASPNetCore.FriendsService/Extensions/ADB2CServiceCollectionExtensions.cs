using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Azure.ServiceFabric.ASPNetCore.FriendsService.Configuration;

namespace Azure.ServiceFabric.ASPNetCore.FriendsService.Extensions
{
    public static class ADB2CServiceCollectionExtensions
    {
        public static IServiceCollection AddADB2CConfiguration(
            this IServiceCollection services,
            IConfigurationRoot configuration)
        {
            services.Configure<ADB2CAuthenticationOptions>(configuration.GetSection("ADB2CAuthentication"));

            return services;
        }

        public static IMvcBuilder AddADB2CFilters(
            this IMvcBuilder mvcBuilder)
        {
            mvcBuilder.AddMvcOptions(options =>
            {
                options.Filters.Add(new RequireHttpsAttribute());

                AuthorizationPolicy policy = new AuthorizationPolicyBuilder()
                   .RequireAuthenticatedUser()
                   .Build();

                options.Filters.Add(new AuthorizeFilter(policy));
            });

            return mvcBuilder;
        }
    }
}
