/*************************************** 13-09-17 **************************************/
(function() {
 if (window.$COMM == undefined || window.$COMM == null) window.$COMM = {};
 
 var STANDARD_STRING = "://params?";
 var callBackfunctionsHolder = [];
 var requestHolders = [];
 var customIndex = 0;
 
 
 /******************************** FUNCTIONS FOR THE INTERACTION WITH IOS *********************************************/
 
// Currently this method works with 4 input parameters and last one is callback method
 $COMM.requestDataForType = function(requestType, paramsString1,paramsString2,paramsString3,paramsString4, callbackFunction) {
 var lEventName = requestType.toLowerCase();
 
 if (callbackFunction != null) {
    callBackfunctionsHolder[lEventName] = callbackFunction;
 }
 
 var reqestObject = {
 
    ename: lEventName,
    param: paramsString1,
    param2: paramsString2,
    param3: paramsString3,
    param4: paramsString4,
    callBk: callbackFunction
 };
 requestHolders.push(reqestObject);
 
 if (customIndex == 0) {
 
    customIndex++;
    var redirectURL = requestType + STANDARD_STRING + paramsString1 + "*" + paramsString2 + "*" + paramsString3 + "*" + paramsString4;
    redirectToCustomUrlGiven(redirectURL);
    var requestObject = requestHolders.shift();
 
    setTimeout(function() {
            callMeToContinue();
            }, 100);
    }
 }
 
 /* Below function used to redirect the page to fake url to comunicate with client*/
 function redirectToCustomUrlGiven(customUrl, data) {
    if (customUrl.length > 0) {
 
    window.location.href = customUrl;
    }
 }
 
 function callMeToContinue() {
 
    if (requestHolders.length <= 0) {
    customIndex = 0;
    return;
 }
 
 
 var requestObject = requestHolders.shift();
 var requestType = requestObject.ename;
 var paramsString1 = requestObject.param;
 var paramsString2 = requestObject.param2;
 var paramsString3 = requestObject.param3;
 var paramsString4 = requestObject.param4;
 var redirectURL = requestType + STANDARD_STRING + paramsString1 + "*" + paramsString2 + "*" + paramsString3 + "*" + paramsString4;
 redirectToCustomUrlGiven(redirectURL);
 
 if (requestHolders.length > 0) {
 
    setTimeout(function() {
            callMeToContinue();
            }, 100);
    } else {
 
    customIndex = 0;
    }
 }
 
 /* Function to receive the data */
 $COMM.responseReceivedForEventName = function(eventName, contextData) {
 
    /* Change the event name to lowercase*/
    var lEventName = eventName.toLowerCase();
    var callBack = callBackfunctionsHolder[lEventName];
    var returnedData = callBack(lEventName,JSON.stringify(contextData));
    return returnedData;
 }
 
 
 $COMM.printLog = function(msg) {
 
  $COMM.requestDataForType("console", msg, null);
 }
 
 })();
function helper() {
    this.performClick = function(p, q, r, t) {
        
        $COMM.requestDataForType("performinsert", p, q, r, t, null);
        
    }
    this.displayDataToView = function(p, q, r, t,callb) {
        debugger
        $COMM.requestDataForType("performGet",p,q,r,t,function(eventName, contextData) {
                                 
                                 setTimeout(function(){ callb(eventName,contextData);},1);
                                 
                                 });
    }
    this.pushViewController = function() {
        $COMM.requestDataForType("pushController", "", "", "", "", null);
    }
}

var Android = new helper();
