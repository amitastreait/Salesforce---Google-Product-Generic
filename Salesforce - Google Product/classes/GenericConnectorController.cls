public class GenericConnectorController {
    public String authScope 						{ get; set; }
    public String pageName  						{ get; set; }
    public List<Google_Credential__mdt> googleCred  { get; set; }
    public String code 								{ get; set; }
    public GenericConnectorController(){
        authScope = 'https://www.googleapis.com/auth/calendar';
        code = ApexPages.currentPage().getParameters().get('code');
        pageName = 'Calendar';
        if(googleCred == null)
            googleCred = new List<Google_Credential__mdt>();
        googleCred = [Select Id, MasterLabel, Access_Type__c, Client_Key__c,Client_Secret__c, grant_type__c,
                      include_granted_scopes__c, OAuth_EndPoint__c, prompt__c, Redirect_URI__c, Token_EndPoint__c
                      From Google_Credential__mdt];
    }
    public void setAuthScope(){
        System.debug('#### authScope '+authScope);
        System.debug('#### pageName '+pageName);
        authScope+= ' https://www.googleapis.com/auth/yt-analytics-monetary.readonly https://www.googleapis.com/auth/youtube.readonly';
        authScope+= ' https://www.googleapis.com/auth/youtubepartner https://www.googleapis.com/auth/yt-analytics.readonly';
    }
    
    public pageReference doGetAuthorizationCode(){
        String requestBody = '';
        if(googleCred != null && googleCred.size() > 0){
            requestBody = googleCred[0].OAuth_EndPoint__c+'?scope='+authScope+'&';
            requestBody+= 'client_id='+googleCred[0].Client_Key__c+'&redirect_uri='+googleCred[0].Redirect_URI__c;
            requestBody+= '&access_type='+googleCred[0].Access_Type__c+'&state=64235635373';
            requestBody+= '&include_granted_scopes=true';
            requestBody+= '&prompt='+googleCred[0].prompt__c+'&response_type=code';
        }
        PageReference pageRef = new PageReference(requestBody);
        pageRef.setRedirect(true);
        return pageRef;
    }
    public PageReference doGetAccessToken(){
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        String errorMessage = '';
        if(googleCred != null && googleCred.size() > 0 && code != null){
            httpReq.setMethod('POST');
            httpReq.setEndpoint(googleCred[0].Token_EndPoint__c);
            httpReq.setHeader('Host', 'www.googleapis.com');
            httpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            httpReq.setTimeout(12000);
            String requestBody = 'code='+code+'&client_id='+googleCred[0].Client_Key__c+'&redirect_uri='+googleCred[0].Redirect_URI__c;
            requestBody+= '&client_secret='+googleCred[0].Client_Secret__c+'&grant_type='+googleCred[0].grant_type__c;
            
            httpReq.setBody(requestBody);
            try{
                httpRes = (new Http()).send(httpReq);
                if(httpRes.getStatusCode() == 200){
                    String response = httpRes.getBody();
                    Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
                    List<Google_Token__c> tokenList = new List<Google_Token__c>();
                    tokenList = [Select Id, Name, Access_Token__c, Refresh_Token__c, Expires_In_Seconds__c, Expires_In__c
                                 from Google_Token__c Where Name='Google Product'];
                    IF(tokenList !=null && tokenList.size() > 0){
                        tokenList[0].Access_Token__c = (String)responseMap.get('access_token');
                        tokenList[0].Refresh_Token__c = (String)responseMap.get('refresh_token');
                        tokenList[0].Expires_In_Seconds__c = (Integer)responseMap.get('expires_in');
                        DateTime dtTime = System.now().addSeconds(Integer.valueOf(tokenList[0].Expires_In_Seconds__c));
                        tokenList[0].Expires_In__c = dtTime;
                    }else{
                        Google_Token__c token = new Google_Token__c();
                        token.Name = 'Google Product';
                        token.Access_Token__c = (String)responseMap.get('access_token');
                        token.Refresh_Token__c = (String)responseMap.get('refresh_token');
                        token.Expires_In_Seconds__c = (Integer)responseMap.get('expires_in');
                        DateTime dtTime = System.now().addSeconds(Integer.valueOf(token.Expires_In_Seconds__c));
                        token.Expires_In__c = dtTime;
                        tokenList.add(token);
                    }
                    if(tokenList != null && tokenList.size() > 0){
                        upsert tokenList;
                        PageReference pageRef;
                        IF(pageName == 'Calendar'){
                          pageRef = new PageReference('/apex/GoogleCalendarActions');
                        }else if(pageName == 'Drive'){
                            pageRef = new PageReference('/apex/GoogleDriveActions');
                        }
                        pageRef.setRedirect(true);
                        return pageRef;
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Successfully Authenticated'));
                    }
                    
                }else{
                    errorMessage = 'Unexpected Error while communicating with Google API. '
                        +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
                    return null;
                }
            }catch(Exception e){
                if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                    errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
                        +' Remote Site Setting and add '+' '+ 'https://www.googleapis.com/' +' Endpoint';
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
                    return null;
                }else{
                    errorMessage = 'Unexpected Error while communicating with Google API. '
                        +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
                    return null;
                }
            }
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'No Google Settings Found OR Invalid Code!. Please check and try again.')); 
            return null;
        }
        return null;
    }
    public void doRefreshToken(){
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        String errorMessage = '';
        googleCred = [Select Id, MasterLabel, Access_Type__c, Client_Key__c,Client_Secret__c, grant_type__c,
                      include_granted_scopes__c, OAuth_EndPoint__c, prompt__c, Redirect_URI__c, Token_EndPoint__c
                      From Google_Credential__mdt LIMIT 1];
        List<Google_Token__c> tokenList = new List<Google_Token__c>();
        tokenList = [Select Id, Name, Access_Token__c, Refresh_Token__c, Expires_In_Seconds__c, Expires_In__c
                     from Google_Token__c Where Name='Google Product' LIMIT 1];
        if(googleCred != null && googleCred.size() > 0 && tokenList.size() > 0){
            httpReq.setMethod('POST');
            httpReq.setEndpoint(googleCred[0].Token_EndPoint__c);
            httpReq.setHeader('Host', 'www.googleapis.com');
            httpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            httpReq.setTimeout(12000);
            String requestBody = 'refresh_token='+tokenList[0].Refresh_Token__c+'&client_id='+googleCred[0].Client_Key__c+'&client_secret='+googleCred[0].Client_Secret__c;
            requestBody+= '&grant_type=refresh_token';
            System.debug('#### requestBody '+requestBody);
            httpReq.setBody(requestBody);
            try{
                httpRes = (new Http()).send(httpReq);
                if(httpRes.getStatusCode() == 200){
                    String response = httpRes.getBody();
                    Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
                    
                    IF(tokenList !=null && tokenList.size() > 0){
                        tokenList[0].Access_Token__c = (String)responseMap.get('access_token');
                        //tokenList[0].Refresh_Token__c = (String)responseMap.get('refresh_token');
                        tokenList[0].Expires_In_Seconds__c = (Integer)responseMap.get('expires_in');
                        DateTime dtTime = System.now().addSeconds(Integer.valueOf(tokenList[0].Expires_In_Seconds__c));
                        tokenList[0].Expires_In__c = dtTime;
                    }
                    if(tokenList != null && tokenList.size() > 0){
                        update tokenList;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Successfully Authenticated'));
                    }
                    
                }else{
                    errorMessage = 'Unexpected Error while communicating with Google API. '
                        +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
                }
            }catch(Exception e){
                if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                    errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
                        +' Remote Site Setting and add '+' '+ 'https://www.googleapis.com/' +' Endpoint';
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
                }else{
                    errorMessage = 'Unexpected Error while communicating with Google API. '
                        +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
                }
            }
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'No Google Settings Found OR Invalid Code!. Please check and try again.')); 
        }
    }
}