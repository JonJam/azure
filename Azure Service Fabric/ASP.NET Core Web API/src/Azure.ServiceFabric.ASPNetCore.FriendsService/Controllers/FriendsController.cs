using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace Azure.ServiceFabric.ASPNetCore.FriendsService.Controllers
{
    public class FriendsController : BaseController
    {
        /// <summary>
        /// Retreives a list of the user's friends.
        /// </summary>
        /// <remarks>
        /// Implementation notes
        /// </remarks>
        /// <returns>Returns the user's friends.</returns>
        /// <response code="200">Returns the user's friends.</response>
        /// <response code="401">If the request is not authorized.</response>
        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<string>), 200)]
        [ProducesResponseType(401)]
        public IEnumerable<string> Get()
        {
            return new string[] { "value1", "value2" };
        }
    }
}