public class BulkAPIGenerateErrorLogs {
/*public String BulkAPIResponse = '<?xml version="1.0" encoding="UTF-8"?>';
    BulkAPIResponse +='<results xmlns="http://www.force.com/2009/06/asyncapi/dataload">';
    BulkAPIResponse +='  <result>';
    BulkAPIResponse +='    <id>001D000000ISUr3IAH</id>';
    BulkAPIResponse +='    <success>true</success>';
    BulkAPIResponse +='    <created>true</created>';
    BulkAPIResponse +='  </result>';
    BulkAPIResponse +='  <result>';
    BulkAPIResponse +='    <id>001D000000ISUr4IAH</id>';
    BulkAPIResponse +='    <success>true</success>';
    BulkAPIResponse +='    <created>true</created>';
    BulkAPIResponse +='  </result>';
    BulkAPIResponse +='</results>';*/
    
    
    public class ErrorLog {
        Integer location;
        String errorMess;
    }
    
    public void executeRestCall(String jobID) {
        String strErrorLogs = 'Job Id, Batch Id, Location, Error Message \n';
        //Retrieve Batch IDs
        XmlStreamReader xsrBatch = new XmlStreamReader(retrieveBatchIds(jobID));
        List<String> batchIDs = parseXMLGenerateBatchIds(xsrBatch);
        
        //Process Batch IDs
        if(!batchIds.isEmpty()) {
            for(String bID : batchIDs) {
                XmlStreamReader xsr = new XmlStreamReader(retrieveBatchResultResponse(bID, jobID));
                strErrorLogs += parseXML(xsr, bID,jobId);
            }
        }
           
        createLogDocument(strErrorLogs,jobID);
        
    }
    
    //Retrieve Batch IDs based from JobID
    public String retrieveBatchIds(String jobID) {
        HttpRequest request= new HttpRequest();
        //request.setEndpoint('https://cs21-api.salesforce.com/services/async/34.0/job/750q0000001nVmw/batch/'+batchID+'/result');
        request.setEndpoint(Label.Bulk_API_Endpoint + 'job/'+jobID+'/batch/');
        request.setMethod('GET');
        request.setHeader('X-SFDC-Session',UserInfo.getSessionId());
        request.setHeader('Content-Type', 'application/xml');
        request.setTimeout(100000);
        
        Http http = new Http();
        
        HttpResponse response = http.send(request);
        system.debug('statusCode =======>'+response.getStatusCode());
        system.debug('statusMessage =======>'+response.getStatus());
        system.debug('Result =======>'+response.getBody());
        return response.getBody();
        
    }
    
    public List<String> parseXMLGenerateBatchIds(XMLStreamReader reader) {
        List<String> batchIDs = new List<String>();
        Boolean isSafeToGetNextXmlElement = true;
        
        while(isSafeToGetNextXmlElement) {
            
            if(reader.getEventType() == XmlTag.START_ELEMENT) {
                String batchID = '';
                if(reader.getLocalName() =='batchInfo') {
                    batchId = parseResult(reader);
                    if(batchId != null && batchID != '') {
                    	batchIds.add(batchID);
                    }
                    //batchID = parseResult(reader);
                } 
            }
            
            
            if(reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        
        return batchIDs;
        
    }
    
    String parseResult(XMLStreamReader reader) {
        String batchID = '';
        Integer numberOfFailedRecords = 0;
                
        boolean isSafeToGetNextElement = true;
        while(isSafeToGetNextElement){
            if(reader.getLocalName() == 'batchInfo' && reader.getEventType() == XmlTag.END_ELEMENT) {
                break;
            } else if(reader.getLocalName() == 'id' && reader.getEventType() == XmlTag.START_ELEMENT) {
                reader.next();
                if(reader.getEventType() == XMLTag.CHARACTERS && reader.getText() != null) {
                	batchID = reader.getText();    
                }
            } else if(reader.getLocalName() == 'numberRecordsFailed' && reader.getEventType() == XmlTag.START_ELEMENT) {
                reader.next();
                if(reader.getEventType() == XMLTag.CHARACTERS && reader.getText() != null) {
                	numberOfFailedRecords = integer.valueOf(reader.getText());
                }
            }
            
            if(reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextElement = false;
                break;
            }
        }
        system.debug('##FAILED RECORDS' + numberOfFailedRecords);
        system.debug('##BATCHID RECORDS' + batchID);
        if(numberOfFailedRecords > 0 ) {
        	return batchID;    
        } else {
            return null;
        }
        
    }
    
    //Batch RESULTS
    public String retrieveBatchResultResponse(String batchID, String jobID) {
        HttpRequest request= new HttpRequest();
        //request.setEndpoint('https://cs21-api.salesforce.com/services/async/34.0/job/750q0000001nVmw/batch/'+batchID+'/result');
        request.setEndpoint(Label.Bulk_API_Endpoint + 'job/'+jobID+'/batch/'+batchID+'/result');
        request.setMethod('GET');
        request.setHeader('X-SFDC-Session',UserInfo.getSessionId());
        request.setHeader('Content-Type', 'application/xml');
        request.setTimeout(100000);
        
        Http http = new Http();
        
        HttpResponse response = http.send(request);
        system.debug('statusCode =======>'+response.getStatusCode());
        system.debug('statusMessage =======>'+response.getStatus());
        system.debug('Result =======>'+response.getBody());
        return response.getBody();
    }
        
    public String parseXML(XMLStreamReader reader,string batchID, String jobID) {
        List<ErrorLog> errLogs = new List<ErrorLog>();
        
        Boolean isSafeToGetNextXmlElement = true;
       	Integer resultCounter = 0;
        while(isSafeToGetNextXmlElement) {
           
            if(reader.getEventType() == XmlTag.START_ELEMENT) {
                if('result' == reader.getLocalName()) {
                    resultCounter += 1;
                    ErrorLog errLog = parseError(reader);
                    errLog.Location = resultCounter;
                    
                    if(errLog.errorMess != null) {
                        errLogs.add(errLog);
                    }
                    /*errorCounter =+ 1;
                    system.debug('Result Local Name');
                    ErrorLog errLog = parseError(reader);
                    errLog.Location = errorCounter;
                    errLogs.add(errLog);*/
                }
            }
            
            if(reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        system.debug('##RESULT: ' + errLogs);
        String strErrorLogs = '';
        for(ErrorLog el : errLogs) {
            strErrorLogs += jobId + ','+batchID +','+ el.location + ',' + el.errorMess + '\n';
        }
        system.debug(strErrorLogs);
        
        //createLogDocument(strErrorLogs,batchID);
            
        return strErrorLogs;
    }
    
    ErrorLog parseError(XMLStreamReader reader) {
        ErrorLog errLog = new ErrorLog();
        //errLog.errorMess = reader.getText();
        
        boolean isSafeToGetNextElement = true;
        while(isSafeToGetNextElement){            
            if(reader.getLocalName() == 'result' && reader.isEndElement()) {
                break;
            } else if(reader.getLocalName() == 'errors' && reader.isStartElement()) {
                reader.next();
				//Next Node - Message
                if(reader.getLocalName() == 'message' && reader.isStartElement()) {
                    reader.next();
                    if(reader.isCharacters() && reader.getText() != null) {
                        errLog.errorMess = reader.getText();
                    }
                }
            }
            
            if(reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextElement = false;
                break;
            }
        }

        return errLog;
    }

    public void createLogDocument(String errLog, String jobID) {
        
        Document doc = new Document();
        
        doc.FolderId = Label.Error_Log_Document_Folder_ID;
        
        doc.Body = Blob.valueOf(errLog);
        
        doc.Name = 'BatchJobErrorLogs' +jobID+'-'+ string.valueOf(system.now()) + '.csv';
        
        
        Database.insert(doc);
        
    }
}