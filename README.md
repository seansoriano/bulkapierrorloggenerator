# bulkapierrorloggenerator
Generates Error Logs from Bulk API Jobs

Pre Requisites -
1. Create new Document Folder form Documents Tab - this is where your logs will be stored when executed
2. Create the following custom labels: 
    a.Bulk API Endpoint - 	https://[instance]-api.salesforce.com/services/async/34.0/
    b. Error Log Document ID - Id of the document folder that you've created from step  1
3. Setup remote site settings for your Bulk API Endpoint


Here’s the steps on how to use it: 
1.	Open up developer console 
2.	Open Execute Anonymous Window from Console under Debug menu or press CTRL + E
3.	Input code snippet below, in which uses the job id as a parameter to generate error logs for all batch included in that Bulk API Job
BulkAPIGenerateErrorLogs ba = new BulkAPIGenerateErrorLogs();
ba.executeRestCall(<Job Id>);
4.	Then execute
5.	This will generate an error log with a time stamp on the documents tabs within the Bulk API Error Logs folder
 
6.	The columns included in the error log file are the following: 
a.	Job ID
b.	Batch ID
c.	Location – in which will be used for xpath to determine the failed record from the request file
d.	Error Message
NOTE: Make sure you filter the file by Batch IDs first before using the location since the location is based from the Batch Response file which varies for each batch job. 



