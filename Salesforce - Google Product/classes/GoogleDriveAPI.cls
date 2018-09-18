public class GoogleDriveAPI {
    Public Static String allFiles { get; set; }
    
    public static void doListAllFiles(){
        List<Google_Token__c> tokenList = new List<Google_Token__c>();
        tokenList = [Select Id, Name, Access_Token__c, Refresh_Token__c, Expires_In_Seconds__c, Expires_In__c
                     from Google_Token__c Where Name='Google Product'];
        String accessToken = tokenList[0].Access_Token__c;
        String endPoint = 'https://www.googleapis.com/drive/v2/files';
        
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse HttpRes = new HttpResponse();
        
        httpReq.setEndpoint(endpoint);
        httpReq.setMethod('GET');
        //httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Authorization','Bearer '+accessToken);
        try{
            HttpRes = http.send(httpReq);
            if(httpRes.getStatusCode() == 200){
                System.debug('#### HtteRes '+HttpRes.getBody());
                allFiles = HttpRes.getBody();
                ApexPages.addmessage(new ApexPages.message(
                    ApexPages.severity.CONFIRM,'File List Retrieved Successfully '));
            }else{
                String errorMessage = 'Unexpected Error while communicating with Google Drive API. '
                    +'Status '+HttpRes.getStatus()+' and Status Code '+HttpRes.getStatuscode();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
            }
        }catch(System.Exception e){
            System.debug('#### Exception Executed '+e.getStackTraceString() +'  '+e.getMessage());
        }
    }
    public static void doListAllYoutube(){
        List<Google_Token__c> tokenList = new List<Google_Token__c>();
        tokenList = [Select Id, Name, Access_Token__c, Refresh_Token__c, Expires_In_Seconds__c, Expires_In__c
                     from Google_Token__c Where Name='Google Product'];
        String accessToken = tokenList[0].Access_Token__c;
        String endPoint = 'https://www.googleapis.com/youtube/v3/channels?part=contentDetails&mine=true';
        
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
                System.debug('#### HtteRes '+HttpRes.getBody());
                allFiles = HttpRes.getBody();
                ApexPages.addmessage(new ApexPages.message(
                    ApexPages.severity.CONFIRM,'File List Retrieved Successfully '));
            }else{
                String errorMessage = 'Unexpected Error while communicating with YouTube API. '
                    +'Status '+HttpRes.getStatus()+' and Status Code '+HttpRes.getStatuscode();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
            }
        }catch(System.Exception e){
            System.debug('#### Exception Executed '+e.getStackTraceString() +'  '+e.getMessage());
        }
    }
}