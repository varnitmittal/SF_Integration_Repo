public class VM_ZendeskUtil {

    

    //Request Wrappers
    public class ticketsBodyWrapper{
        public cls_tickets[] tickets;
    }
    public class cls_tickets {
        public String status;	//open
        public String[] tags;
        public cls_comment comment;
        public String priority;	//urgent
        public String subject;	//My Scanner1 is on fire!
        public cls_requester requester;
    }
    public class cls_comment {
        public cls_comment(String body){
            this.body = body;
        }
        String body {get; set;}	//The smoke is very colorful.
    }
    public class cls_requester {
        public Integer locale_id;	//8
        public String name;	//Pablo
        public String email;	//pablito@example.org
        public String details;
    }

    
    //Response Wrappers
    public class ticketsResponseWrapper{
        public cls_job_status job_status;
    }
    public class cls_job_status {
        //public String id;	//V3-48176613ac9f15e3a5db66fbc59eb08d
        public String Id;
        public String job_type;	//Bulk Create Ticket
        public String url;	//https://nobody947.zendesk.com/api/v2/job_statuses/V3-48176613ac9f15e3a5db66fbc59eb08d.json
        public Integer total;	//2
        public String progress;
        public String status;	//queued
        public String message;
        public cls_results[] results;
    }
    public class cls_results {
		public Integer index;	//0
		public Integer id;	//12
		public Integer account_id;	//24113602
	}
}