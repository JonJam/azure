Below is configuration required that cannot be done via automation:

Azure AD B2C
1. Create a Azure Active Directory Tenant (Manual)
2. Identity Providers (Manual)
	a. Microsoft
	b. Google
	c. Facebook
3. Register app  (Manual)
4. Create Policies (Manual)
	a. Sign Up
	b. Sign In
	c. Profile Editing
	d. Password Reset
5. Set up Password Reset for Local Accounts (Manual)
6. Customising tokens (Manual)
	a. Set No Expiry for "Refresh token sliding window days" for each policy
7. Styling B2C UI
	a. Configure field requirements i.e. optional / required
	b. Sign Up
	c. Sign In
	d. Profile Editing
	e. Password Reset
	f. Error


Azure CDN
- Ensure Compression is disabled.
- Disable Query-String Caching.
- Add CORS rule.

	IF: Request Header Regex
	Name: Origin
	Matches
	Value: https?:\/\/(login\.microsoftonline\.com)$
	Ignore Case: True

	Features:
		Modify Client Request Header
			Overwrite
			Access-Control-Allow-Origin
			%{http_origin}
		Modify Client Request Header
			Overwrite
			Access-Control-Allow-Headers
			*
		Modify Client Request Header
			Overwrite
			Access-Control-Allow-Methods
			GET, HEAD, OPTIONS
		Modify Client Request Header
			Overwrite
			Access-Control-Expose-Headers
			*