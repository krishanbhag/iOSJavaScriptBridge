//
//  ViewController.swift
//  JSIOSBridgeSwift
//
//  Created by Krishna Shanbhag on 13/09/17.
//  Copyright © 2017 WireCamp Interactive. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,JSExecuterProtocol {
    
    var executer:JSExecuter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load the home page of the site. (Home/index.html) in our case its sample.html
        let pathString:String = Bundle.main.path(forResource: "sample", ofType: "html")!
        let pathUrl:URL = URL(fileURLWithPath: pathString)
        
        var htmlContent = ""
        do {
            htmlContent = try String(contentsOf: pathUrl, encoding: String.Encoding.ascii)
        }
        catch {
            print("Error getting contents")
        }
        
        //if you have automatic script on the view and you want to run it without Ui then set the frame to CGRectZero.
        self.executer = JSExecuter(newParentView: self.view, newCodeSnippet: htmlContent, newDelegate: self, andFrame: self.view.frame)
        self.executer?.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - JSExecuter protocol implementation
    func eventOccuredToSaveData(firstName:String, lastName:String) {
        
        guard firstName.characters.count > 0 && lastName.characters.count > 0 else {
            
            let alert:UIAlertController = UIAlertController(title: "Error!", message: "Please enter valid input and try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: {
                
            })
            
            return
        }
        self.save(name: firstName, lastName: lastName)
        
    }
    func eventOccuredToFetchData(subString:String,scheme:String) {
        
        let resultArray = self.fetchUserName(subString: subString)
        if resultArray.count > 0 {
            
            //We need to send the array which we got from the coredata (we already converted it into dictionary)
            //the dictioary is again converted into JSON so that it will be easy to show up in JS
            
            var jsonData:Data?
            do {
                jsonData = try JSONSerialization.data(withJSONObject: resultArray, options: .init(rawValue: 0))
            }
            catch {
                print("Error converting to json data")
            }
            if (jsonData != nil) {
                let stringInJson = String(data: jsonData!, encoding: String.Encoding.utf8)
                _ = self.executer?.populateResponse(responseJsonString: stringInJson!, forEvent: scheme)
            }
        }
    }
    func eventOccuredToButtonAction() {
        self.performSegue(withIdentifier: "DemoViewSegue", sender: self)
    }
    
    
    // MARK: - Core data save and retrieve menthod
    
    func save(name:String, lastName:String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        
        let user = User(entity: entity!, insertInto: context)
        user.name = name
        user.lastName = lastName
        
        do {
            try context.save()
        }
        catch let error as NSError {
            print ("Could not save \(error)" )
        }
        
        _ = fetchUserName(subString: "")
        
        
    }
    func fetchUserName(subString:String) -> Array<Dictionary<String,String>>{
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchReq:NSFetchRequest = User.fetchRequest()
        fetchReq.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        if(subString.characters.count > 0) {
            fetchReq.predicate = NSPredicate(format: "(name CONTAINS[cd] %@) OR (lastName CONTAINS[cd] %@)", subString,subString)
        }
        var userArray:[User] = [];
        
        //to send data to javascript, the data should be in JSON format.
        //we can convert the data in dictiory or array easily into json.
        var dictArray: Array<Dictionary<String,String>> = []
        
        do {
            userArray = try (context.fetch(fetchReq))
        }
        catch let error as NSError {
            print ("Could not retrieve \(error)" )
        }
        
        for user:User in userArray {
            
            var dict:Dictionary<String,String> = Dictionary()
            dict["name"] = user.name
            dict["lastName"] = user.lastName
            dictArray.append(dict)
        }
        
        
        return dictArray
    }

}

