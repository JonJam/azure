using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Options;
using Swashbuckle.AspNetCore.Swagger;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Azure.ServiceFabric.ASPNetCore.FriendsService.Configuration;

namespace Azure.ServiceFabric.ASPNetCore.FriendsService.Extensions
{
    public static class SwaggerApplicationBuilderExtensions
    {
        public static IApplicationBuilder UseSwagger<T>(
            this IApplicationBuilder app,
            IHostingEnvironment env)
        {
            string serviceName = typeof(T).Name;
            string routePrefix = $"swagger/{serviceName}";

            // Enable Swagger as a JSON endpoint.
            app.UseSwagger(options =>
            {
                options.RouteTemplate = $"{routePrefix}/{{documentName}}/swagger.json";
                options.PreSerializeFilters.Add(SwaggerApplicationBuilderExtensions.AddHostAndSchemes);
            });

            if (env.IsDevelopment())
            {
                // Enable Swagger UI.
                app.UseSwaggerUi(c =>
                {
                    c.RoutePrefix = routePrefix;
                    c.SwaggerEndpoint($"/{routePrefix}/v1/swagger.json", $"{nameof(FriendsService)} API");
                });
            }

            return app;
        }

        private static void AddHostAndSchemes(SwaggerDocument swaggerDoc, HttpRequest httpReq)
        {
            swaggerDoc.Host = httpReq.Host.Value;
            swaggerDoc.Schemes = new List<string>()
            {
                "https"
            };
        }
    }
}
