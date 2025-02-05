public with sharing class VM_CurrencyAPIService {
    
    public static void getExchangeRates(){
        //Callouts Only
        //prepare the http req
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://open.er-api.com/v6/latest/USD');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json'); //what the API returns and we accept
        req.setMethod('GET');
        //send the request
        Http h = new Http();

        try {
            HttpResponse res = h.send(req);
            System.debug('The resp from Callout   --   ' + res.getStatus() + '   ' + res.getStatusCode() + '   ' + res.getBody());
        } catch (System.CalloutException ce) {
            if(String.valueOf(ce).startsWith('System.CalloutException: Unauthorized endpoint')){
                System.debug('Authorize the callout endpoint via remote site settings');
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
    }
    
}