#Import file to create xml-rpc object 
require_relative 'bmexmlrpc'
require 'xmlrpc/client' 

#Variables used to login
$userName = '<USERNAME>'; 
$passWord = '<PASSWORD>'; 
$apiURL = 'http://api.benchmarkemail.com/1.0/';


####### Method Definitions #######

# getListID() - Method to return the ID of the last created mailing list from your Benchmark Email account
# Pre-requisites - Must have connected to Benchmark Email's API and logged in. See section below under "Logging In"  
# @Return - (String) The ID of the last created mailing list  
def getListID()
	#The following variables will server as parameters for the listGet() method 
	$filter = ""
	$pageNumber = 1
	$pageSize = 100
	$orderBy = ""
	$sortOrder = ""
	
	
	$tempListID = ""
	$buffer = ""
	
	# listGet(): Retrieve a list of mailing lists from your Benchmark Email account
			# Pre-requisites: 
			# 	- Must have logged in to their Benchmark Email account. See section below under "Logging In" 
			# @param filter: if you want to search for a specific list, type in the name here (filters the results by the string you pass in) 
			# @param pageNumber: the page of results that you want to view (for now we pass 1 to view the first page of results) 
			# @param pageSize: the number of mailing lists per page
			# @param orderBy: we have 3 options, either:
			# 		 1) name - alphabetical order
			# 		 2) date - by date created 
			# 		 3) "" empty (which defaults to by date) 
			# @param sortOrder: sort the results either by 3 options:
			# 		 1) asc - for ascending order (oldest mailing list first)
			# 		 2) desc - for descending order (latest created mailing list first)
			# 		 3) "" - defaults to descending order 
			# @Return: An array of mailing lists from the Benchmark Email account 
	$buffer =  BMEAPI.listGet( $filter, $pageNumber, $pageSize, $orderBy, $sortOrder)
	
	tempListID = $buffer[0]['id'];
	
	return tempListID
end

# createList() - Creates a mailing list in your Benchmark Email account
# Pre-requisites - Must have connected to Benchmark Email's API and logged in. See section below under "Logging In"
# @Return - N/A 
def createList()
	# Name of the list we will add 
	$listName = "Old Clients";
	$buffer = ""
	
	
	# listCreate(): Create the list in the Benchmark Email account associated with the token passed in 
	#Pre-requisites - Must have connected to Benchmark Email's API and logged in. See section below under "Logging In"
	# @param listName: The name of the list we are creating. Every list name must have its own unique name (BME does not allow duplicates) 
	# @Return: The list ID of the newly created list OR if an error occurred the method will return the fault code and fault string describing the error
	$buffer = BMEAPI.listCreate($listName);
	
	if $status
		puts "Created new list: #{$listName} \n#{$listName}'s ID: #{$buffer}\n\n"
	else
		puts "Error from createList(): Error code (#{$buffer.faultCode}) - #{$buffer.faultString}\n\n"
	end
end

# addContacts() - Add contacts to a specific mailing list in your Benchmark Email account 
# Pre-requisites - Must have connected to Benchmark Email's API and logged in. See section below under "Logging In"
# @Return - N/A 
def addContacts()
	#Will hold the number of contacts added 
	$contactsAdded = 0
	
	#First, we need to retrieve a list ID to add contacts to (for this example we'll get the latest ID)
	$listID = getListID();
	
	puts "list ID we will add to: #{$listID}"
	
	#Second, we need to prepare the information of contacts that will be added to the list 
	#We will create an array that will hold contact's information 
	#A contact MUST have an email in order to be added successfully. The other fields (like first name) are optional 
	$contactInfo = [
			{:email => "ruby@rubies.com", :firstname => "Red", :lastname => "Ruby"},
			{:email => "agent@smith.com", :firstname => "Agent", :lastname => "Smith"}
		]
	
	#Third, make the API call to add contacts
	
	# listAddContacts(): Add our array of contacts to the specified mailing list 
	#Pre-requisites - 
	#	- Must have connected to Benchmark Email's API and logged in. See section below under "Logging In"
	#	- Must have prepared an array with at least one email for a contact to add 
	# @param listID: The ID of the list we want to add contacts to 
	# @param contactInfo : The array of contacts we are adding to the mailing list 
	# @Return: (Integer) The number of contacts that were added to the mailing list 
	$contactsAdded = BMEAPI.listAddContacts($listID, $contactInfo);
	
	#Display how many (if any) contacts were added. Remember that Benchmark Email does not allow duplicate contacts within the same list! 
	#If you try to add a duplicate contact they will not be added to the mailing list 
	if($contactInfo.length == $contactsAdded)
		puts "All #{$contactsAdded} contact(s) were added successfully!\n\n"
	elsif($contactsAdded < 1)
		puts "Looks like not all contacts were added: 0 of #{$contactInfo.length} contact(s) were added.\n\n"
	elsif($contactInfo.length > $contactsAdded)
		puts "Looks like not all contacts were added: Only #{$contactsAdded} of #{$contactInfo.length} contact(s) were added.\n\n"
	end
end

####### End Method Definitions #######



# Logging In 
# By instantiating the API class found in the "BmeXmlRpc" module we accomplish 2 things in one step: 
# (1) We connect to the Benchmark Email API server. This will also give us the following instance variables:
# 	- token : Holds the token from your BME account
#	- server: The xml-rpc object created, used to make BME API calls within the 'method_missing' method

# (2) We use the username and password passed in to retrieve the token associated with that Benchmark Email account 

BMEAPI = BmeXmlRpc::API.new($userName, $passWord, $apiURL)

#If we logged in successfully then continue
if $status

	#Display your Benchmark Email token 
	puts "\nWelcome! Your token is: #{BMEAPI.retToken}\n\n"
	
	#Retrieve the ID of the last created mailing list, then display it 
	latestListID = getListID();
	puts "The ID of your latest list is: #{latestListID}\n\n"
	
	#Create a new mailing list 
	createList();
	
	#Add contacts to the last created mailing list 
	#(in this case we are adding contacts to the list we just created above) 
	addContacts();
	
end

puts "Goodbye!"
