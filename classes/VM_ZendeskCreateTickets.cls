public with sharing class VM_ZendeskCreateTickets implements Queueable, Database.AllowsCallouts{

    String zendeskJobId; //Zendesk job Id that's r4eceived when POST is done
    VM_ZendeskUtil.ticketsBodyWrapper tbw; //Tickets data that we have to POST onto zendesk
    Boolean isFirstCalloutDone = false; //checking whether we should POST callout, or just GET the job status

    //constructor for trigger to provide the tickets data wrapper
    public VM_ZendeskCreateTickets(VM_ZendeskUtil.ticketsBodyWrapper tbw){ 
        this.tbw = tbw;
    }

    //Constructor for requeueing, so that we store the Zendesk Job Id, and the fact that the POST is done
    public VM_ZendeskCreateTickets(String zendeskJobId, Boolean isFirstCalloutDone){
        this.zendeskJobId = zendeskJobId;
        this.isFirstCalloutDone = isFirstCalloutDone;
    }

    //@future(Callout=true)
    //public static void createTicketFromCase(VM_ZendeskUtil.ticketsBodyWrapper tbw){
    public void execute(QueueableContext qc){
        if(isFirstCalloutDone == false){
            /*for(VM_ZendeskUtil.cls_tickets tbwTicket: tbw.tickets){
                System.debug(tbwTicket); //Logging the tickets to be created
            }*/
            
            //Create HTTP Callout Request
            HttpRequest req = new HttpRequest();
                //set endpoint
                req.setEndpoint(System.Label.VM_Zendesk_APIBaseURL + System.Label.VM_Zendesk_APIEndpoint_Create_Many_Tickets);
                //set headers
                req.setHeader('Content-Type', 'application/json'); // format of the request data
                req.setHeader('Accept', 'application/json'); //desired format of the response from external system
                //set method
                req.setMethod('POST');
                //add authentication
                Blob utoken = Blob.valueOf(System.Label.VM_ZendeskUsername + '/token:' + System.Label.VM_ZendeskAPIToken);
                req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(utoken));
                //Create request body
                //req.setBody(testBodyString); //only for testing while developing
                req.setBody(JSON.serialize(tbw)); //Convert Body Wrapper Object instance into serialized JSON
            //send request & handle response
            Http h = new Http();
            try {
                HttpResponse res = h.send(req);
                System.debug(res.getBody());
                if(res.getStatusCode() == 200){ //check if POST is done
                    //if done, deserialize the JSON response into a response wrapper
                    VM_ZendeskUtil.ticketsResponseWrapper trw = (VM_ZendeskUtil.ticketsResponseWrapper)JSON.deserialize(res.getBody(), VM_ZendeskUtil.ticketsResponseWrapper.class);
                    Integer totalJobsProgress = trw.job_status.progress != null ? Integer.valueOf(trw.job_status.progress) : 0;
                    System.debug('resp==>   ' + totalJobsProgress +'  |||  '+ trw.job_status.status +'  |||  '+ trw.job_status.total);
                    ID queueJobId = System.enqueueJob(new VM_ZendeskCreateTickets(trw.job_status.id, true), 1);
                    System.debug('enqueued job id==>   ' + queueJobId);
                    if(queueJobId != null){
                        isFirstCalloutDone = true;
                    }
                } else {
                    CalloutException ce = new CalloutException();
                    ce.setMessage(String.valueOf(res.getStatusCode()));
                    throw ce;
                }
            } catch (CalloutException ce) {
                System.debug(ce.getMessage());           
            } catch (Exception e) {
                System.debug(e.getMessage());           
            }
        }
        else {
            //POST callout has already happened, so we just GET the status of Zendesk job
            getZendeskQueuedTicketsStatus();
        }   
    }

    //POST callout has already happened, so we just GET the status of Zendesk job Id
    public void getZendeskQueuedTicketsStatus(){
        System.debug('INSIDE getZendeskQueuedTicketsStatus    '+ zendeskJobId + ' ' + isFirstCalloutDone);
        if(zendeskJobId != null){
            HttpRequest req = new HttpRequest();
                //set endpoint
                req.setEndpoint(System.Label.VM_Zendesk_APIBaseURL + '/api/v2/job_statuses/'+zendeskJobId);
                //set headers
                //req.setHeader('Content-Type', 'application/json'); // format of the request data // not required for get call
                req.setHeader('Accept', 'application/json'); //desired format of the response from external system
                //set method
                req.setMethod('GET');
                //add authentication
                Blob utoken = Blob.valueOf(System.Label.VM_ZendeskUsername + '/token:' + System.Label.VM_ZendeskAPIToken);
                req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(utoken));
                //Create request body
                //req.setBody(testBodyString); //not required for get call
            //send request & handle response
            Http h = new Http();
            try {
                HttpResponse res = h.send(req);
                System.debug(res.getBody());
                if(res.getStatusCode() == 200){ //checking for success
                    //Now that we have received the response, we convert it to a response wrapper instance
                    VM_ZendeskUtil.ticketsResponseWrapper trw = (VM_ZendeskUtil.ticketsResponseWrapper)JSON.deserialize(res.getBody(), VM_ZendeskUtil.ticketsResponseWrapper.class);

                    System.debug(trw.job_status.results);
                    if(trw.job_status.status != 'completed'){
                    //if(Integer.valueOf(trw.job_status.total) != Integer.valueOf(trw.job_status.progress)){ //if the progress is not complete
                        System.enqueueJob(new VM_ZendeskCreateTickets(trw.job_status.id, null), 4); //requeue the callout since the process is not complete yet
                    } else {
                        Integer totalJobsProgress = Integer.valueOf(trw.job_status.progress);
                        //logging the complete progress here
                        System.debug('resp==>   ' + totalJobsProgress +'  |||  '+ trw.job_status.status +'  |||  '+ trw.job_status.total);
                    }
                } else {
                    CalloutException ce = new CalloutException();
                    ce.setMessage(String.valueOf(res.getStatusCode()));
                    throw ce;
                }
            } catch (CalloutException ce) {
                System.debug(ce.getMessage());           
            } catch (Exception e) {
                System.debug(e.getMessage());           
            }
        }else{ //if somehow the ID is missing, we log that
            System.debug('Zendesk Job Id is missing, Error on 3rd party system');
        }
    }

    //test json string
    static String testBodyString=		'{'+
		'    "tickets": ['+
		'        {'+
		'            "status": "open",'+
		'            "tags": ['+
		'                "order",'+
		'                "test",'+
		'                "created_via_SF"'+
		'            ],'+
		'            "comment": {'+
		'                "body": "The smoke is very colorful."'+
		'            },'+
		'            "priority": "urgent",'+
		'            "subject": "My Scanner5 is on fire!",'+
		'            "requester": {'+
		'                "locale_id": 8,'+
		'                "name": "Pablo",'+
		'                "email": "pablito@example.org"'+
		'            }'+
		'        },'+
		'        {'+
		'            "status": "open",'+
		'            "tags": ['+
		'                "order",'+
		'                "test",'+
		'                "created_via_SF"'+
		'            ],'+
		'            "comment": {'+
		'                "body": "The smoke is very colorful."'+
		'            },'+
		'            "priority": "urgent",'+
		'            "subject": "My Scanner6 is on fire!",'+
		'            "requester": {'+
		'                "locale_id": 8,'+
		'                "name": "Pablo",'+
		'                "email": "pablito@example.org"'+
		'            }'+
		'        }'+
		'    ]'+
		'}';
}