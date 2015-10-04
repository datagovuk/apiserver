# TODO

* ~~Make the API calls work~~
* ~~SQL interface per theme~~
* Add more manifests and themes
* ~~OTP app with DB connection pools~~
* Implement paging somehow/somewhere.



## Fixing manifests ...


What we actually want from a manifest:

* A theme title 
* A theme description
* A theme logo?
* Database connection settings
* A list of endpoints
	* An endpoint title 
	* An endpoint description
	* A theme icon?
	* [A JSON table schema](http://dataprotocols.org/json-table-schema/)
	* A list of pre-defined queries, with title and description
	* A list of fields that can be filtered

	
## Fixing URL naming.

Currently everything is under /theme, but there is also /api/theme/endpoint.  Perhaps we should have a page at /theme/endpoint which would be a lot less cluttered.

Should we them have each endpoint as a choosable item on the theme page?