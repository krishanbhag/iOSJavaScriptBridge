//
//  JSExecuter.swift
//  JSIOSBridgeSwift
//
//  Created by Krishna Shanbhag on 13/09/17.
//  Copyright © 2017 WireCamp Interactive. All rights reserved.
//

import UIKit

protocol JSExecuterProtocol:class {
    
    func eventOccuredToSaveData(firstName:String, lastName:String)
    func eventOccuredToFetchData(subString:String,scheme:String)
    func eventOccuredToButtonAction()
    
}
class JSExecuter: NSObject,UIWebViewDelegate {
    
    var jsWebView:UIWebView!
    var codeSnippet:String?
    var parentView:UIView?
    weak var delegate:JSExecuterProtocol?
    
    // MARK: -  Initializer methods
    override init() {
        
        super.init()
    }
    convenience init?(newParentView:UIView, newCodeSnippet:String, newDelegate:Any, andFrame:CGRect) {
        
        self.init()
        self.codeSnippet =  newCodeSnippet
        self.delegate = newDelegate as? JSExecuterProtocol
        self.parentView = newParentView
        self.createWebViewWithFrame(newFrame: andFrame)
        
        if newCodeSnippet.characters.count > 3 {
            self.executeJavascriptCode(jsCodeSnippet: newCodeSnippet)
        }
    }
    
    // MARK: -  Private methods
    // MARK: -  Webview creation and loading
    func createWebViewWithFrame(newFrame:CGRect) {
        
        let webView:UIWebView = UIWebView(frame: newFrame)
        webView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.jsWebView = webView
        self.jsWebView.delegate = self
        self.parentView?.addSubview(self.jsWebView)
    }
    func executeJavascriptCode(jsCodeSnippet:String) {
        
        self.jsWebView.loadHTMLString(jsCodeSnippet, baseURL: Bundle.main.resourceURL)
    }
    func loadHTMLFileFromPath(htmlFilePath:String) {
        
        self.jsWebView.loadRequest(URLRequest(url: URL(fileURLWithPath: htmlFilePath)))
    }
    
    // MARK: - Utility methods
    func shouldContinueLoading(scheme:String) -> Bool {
        if scheme == "http" || scheme == "https" || scheme == "file" || scheme == "about" || scheme.characters.count <= 3 {
            return true
        }
        return false
    }
    func passEventToDelegate(absoluteUrl:URL, and scheme:String) {
        
        //We have created a dummy url with dummy scheme which is be handled here.
        let paramString:String = absoluteUrl.absoluteString.replacingOccurrences(of: String(format: "%@://params?", scheme), with: "")
        //let param:String = paramString.replacingPercentEscapes(using: .utf8)!
        
        let param:String = paramString.removingPercentEncoding!
        //Since we have created a url with parameters seopearated by *, we can get the parameteres by deviding string by using seperator "*"
        let parameterArray:Array<String> = param.components(separatedBy: "*")
        
        //Handling insertion of object from JS to Core data
        if scheme == "performinsert" {
            
            let firstName:String = parameterArray[0]
            let lastName:String = parameterArray[1]
            
            //2nd and 3rd object we are sending blak you can send any values here.
            //we can also send a json object from JS if the data set is huge.
            
            self.delegate?.eventOccuredToSaveData(firstName: firstName, lastName: lastName)
        }
        else if scheme == "performget" {
            
            var substring = ""
            substring = parameterArray[0]
            
            self.delegate?.eventOccuredToFetchData(subString: substring, scheme: scheme)
            
        }
        else if scheme == "pushcontroller" {
            self.delegate?.eventOccuredToButtonAction()
        }
    }
    func populateResponse(responseJsonString:String, forEvent name:String) -> String {
        
        let function = String(format: "$COMM.responseReceivedForEventName(\"%@\",%@)",name,responseJsonString)
        let result = self.jsWebView.stringByEvaluatingJavaScript(from: function)
        return result!
        
    }
    
    // MARK: - Webview delegate
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let scheme:String = (request.url?.scheme)!
        if !self.shouldContinueLoading(scheme: scheme) {
            
            self.passEventToDelegate(absoluteUrl: request.url!, and: scheme)
        }
        return self.shouldContinueLoading(scheme: scheme)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        //handle activity indicator
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //handle activity indicator
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print(error.localizedDescription)
    }
}
