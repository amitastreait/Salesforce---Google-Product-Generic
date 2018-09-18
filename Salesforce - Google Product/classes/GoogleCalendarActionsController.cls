public class GoogleCalendarActionsController {
    public static String Summary { get; set; }
    Public Static String allCalendars { get; set; }
    public Static Boolean isListCalendars { get; set; }
    
    public static void doListAllCalendar(){
        List<Google_Token__c> tokenList = new List<Google_Token__c>();
        tokenList = [Select Id, Name, Access_Token__c, Refresh_Token__c, Expires_In_Seconds__c, Expires_In__c
                     from Google_Token__c Where Name='Google Product'];
        String accessToken = tokenList[0].Access_Token__c;
        String endPoint = 'https://www.googleapis.com/calendar/v3/users/me/calendarList';
        
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse HttpRes = new HttpResponse();
        
        httpReq.setEndpoint(endpoint);
        httpReq.setMethod('GET');
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Authorization','Bearer '+accessToken);
        try{
            HttpRes = http.send(httpReq);
            if(httpRes.getStatusCode() == 200){
                isListCalendars = true;
                System.debug('#### HtteRes '+HttpRes.getBody());
                allCalendars = HttpRes.getBody();
                ApexPages.addmessage(new ApexPages.message(
                    ApexPages.severity.CONFIRM,'Calendar List Retrieved Successfully '));
            }else{
                String errorMessage = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+HttpRes.getStatus()+' and Status Code '+HttpRes.getStatuscode();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
            }
        }catch(System.Exception e){
            System.debug('#### Exception Executed '+e.getStackTraceString() +'  '+e.getMessage());
        }
    }
    
    public static void doCreateNewCalendar(){
        List<Google_Token__c> tokenList = new List<Google_Token__c>();
        tokenList = [Select Id, Name, Access_Token__c, Refresh_Token__c, Expires_In_Seconds__c, Expires_In__c
                     from Google_Token__c Where Name='Google Product'];
        String accessToken = tokenList[0].Access_Token__c;
        if(Summary == null || Summary == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Calendar Title!'));
            return ;
        }
        String requestBody = '{'+
            '"summary":'+'"'+ Summary+'"'+
            '}';
        System.debug('#### requestBody '+requestBody);
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse HttpRes = new HttpResponse();
        
        httpReq.setEndpoint('https://www.googleapis.com/calendar/v3/calendars');
        httpReq.setMethod('POST');
        httpReq.setBody(requestBody);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Authorization','Bearer '+accessToken);
        try{
            HttpRes = http.send(httpReq);
            if(HttpRes.getStatusCode() == 200){
                isListCalendars = false;
                allCalendars = '';
                ApexPages.addmessage(new ApexPages.message(
                    ApexPages.severity.CONFIRM,'Calendar Created Successfully  '+'\n'+' '+
                    HttpRes.getBody()));
            }else{
                String errorMessage = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+HttpRes.getStatus()+' and Status Code '+HttpRes.getStatuscode();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
            }
        }catch(System.Exception e){
            System.debug('#### Exception Executed : '+e.getMessage() + '  '+e.getStackTraceString() + ' '+e.getLineNumber());
        }
    }
    
    public static void doCreateNewCalendarEvent(){
        List<Google_Token__c> tokenList = new List<Google_Token__c>();
        tokenList = [Select Id, Name, Access_Token__c, Refresh_Token__c, Expires_In_Seconds__c, Expires_In__c
                     from Google_Token__c Where Name='Google Product'];
        String accessToken = tokenList[0].Access_Token__c;
        //String accessToken = tokenList[0].Access_Token__c;
        
        String createEventEndPoint = 'https://www.googleapis.com/calendar/v3/calendars/'+ 'cse.amitallenhouse@gmail.com' +'/events?sendNotifications=true';
        
        String createEventBody =  '{' +
            '"attendees": ['+
            '{'+
            '"email": "amit.singh1@puresoftware.com"'+ 
            '},'+
            '{'+
            '"email": "amitsfdcdev@gmail.com"'+
            '}'+
            '],'+
            '"attachments": ['+
            '{'+
            '"fileUrl": ""'+
            '}'+
            '],'+
            '"end": {'+
            '"dateTime": "2017-11-11T03:30:00-07:00"'+
            '},'+
            '"reminders": {'+
            '"useDefault": true'+
            '},'+
            '"start": {'+
            '"dateTime": "2017-11-11T03:30:00-06:00"'+
            '},'+
            '"summary": "This is Test Event Using Calendar API ",'+
            '"location": "B 24 Noida Sec 65"'+
            '}';
        System.debug('#### createEventBody  '+createEventBody );
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse HttpRes = new HttpResponse();
        
        httpReq.setEndpoint(createEventEndPoint);
        httpReq.setMethod('POST');
        httpReq.setBody(createEventBody );
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Authorization','Bearer '+accessToken);
        try{
            HttpRes = http.send(httpReq);
            if(HttpRes.getStatusCode() == 200){
                ApexPages.addmessage(new ApexPages.message(
                    ApexPages.severity.CONFIRM,'Calendar Event Successfully  '+'\n'+' '+
                    HttpRes.getBody()));
            }else{
                String errorMessage = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+HttpRes.getStatus()+' and Status Code '+HttpRes.getStatuscode();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
            }
        }catch(System.Exception e){
            System.debug('#### Exception Executed : '+e.getMessage() + '  '+e.getStackTraceString() + ' '+e.getLineNumber());
        }
    }
}