require 'net/http'
require 'net/https'
require 'openssl'
require 'xmlrpc/client'
module BmeXmlRpc
	class API
	
		 def initialize(username,password,apiurl)
			@server = XMLRPC::Client.new2(apiurl)			
			$status, result = @server.call2('login', username, password) 
			if $status
				@token = result				
			else
				puts "\n(From BmeXmlRpc module)\nSorry, but we could not log you in. Please check the following error message:\n"
				puts "Error Code: #{result.faultCode}"		
				puts "Error Description: #{result.faultString}\n\n"
			end
		 end 
		 
		 def retToken()
			return @token 
		 end
		 
		 def method_missing(api_method, *args)
			$status, result = @server.call2(api_method.to_s, @token, *args)
			return result			
		 end
	end
end	 


#Purpose of this module:
#	To initialize an xml-rpc object that connects to BME's API 
#	Allows the user to instantiate this module in another file (we will do it in the file "main.rb"), 
#	then upon a successful login they can begin to make API calls like listCreate(), listGet() etc. 

# Creating the remote XML-RPC object 
# - Line 9: new2() method takes in the url for the server we want to connect to. In this case it's the Benchmark Email
#			API server.

# Logging in to your Benchmark Email account  
# *NOTE: In order to make any API calls we need to first login and store the API token 
# - Line 10: Uses the values (parameters) passed in to login 
#			 If login was successful then the token gets stored to variable "token" 

# method_missing(api_method, *args) - Line 24
# Whenever we want to make an Benchmark Email API call to a method (in the main.rb file) we are invoking "method_missing()". 
# Method_missing() will take the name of the method we are trying to use (like listGet() or listCreate() )
# as the first parameter (api_method) and any other arguments we passed in as the 2nd parameter (*args).
# 
# After that, method_missing() will use the xml-rpc object we stored in "server" (line 10) to send the call to Benchmark Email using the 
# call2() method from the xmlrpc library.
# NOTE: In the main.rb file we do not pass along the token as a parameter! This automatically gets passed in on line 25 in the method_missing() method. 