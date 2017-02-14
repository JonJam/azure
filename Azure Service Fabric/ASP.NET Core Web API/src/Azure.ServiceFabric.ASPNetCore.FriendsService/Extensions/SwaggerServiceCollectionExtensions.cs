using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.PlatformAbstractions;
using Swashbuckle.AspNetCore.Swagger;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace Azure.ServiceFabric.ASPNetCore.FriendsService.Extensions
{
    public static class SwaggerServiceCollectionExtensions
    {
        public static IServiceCollection AddSwagger<T>(this IServiceCollection services)
        {
            services.AddSwaggerGen(c =>
            {
                string versionNumber = "v1";

                string name = typeof(T).Name;

                c.SwaggerDoc(versionNumber, new Info { Title = $"{name} API", Version = versionNumber });

                string basePath = PlatformServices.Default.Application.ApplicationBasePath;
                string xmlPath = Path.Combine(basePath, $"{name}.xml");
                c.IncludeXmlComments(xmlPath);
            });

            return services;
        }
    }
}
