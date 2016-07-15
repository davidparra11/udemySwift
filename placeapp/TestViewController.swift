//
//  TestViewController.swift
//  placeapp
//
//  Created by david on 28/03/16.
//  Copyright © 2016 david. All rights reserved.
//
import UIKit
import Alamofire
import UIKit


class TestViewController: UIViewController {

    @IBOutlet weak var holaLabel: UILabel!
    
    let headers = ["token" : "key123" ]
   
   // let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
  //  let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("GameOverView") as! GameOverView
   // self.presentViewController(nextViewController, animated:true, completion:nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //GET Request With URL-Encoded Parameters
        Alamofire.request(.GET, "https://placego-rest.herokuapp.com/users/", parameters: ["var":"test"], headers: headers)
        .responseJSON { (rspuesta) in
            print(rspuesta.request)
            print(rspuesta.response)
            print(rspuesta.data)
            print(rspuesta.result)
            
            if let JSON = rspuesta.result.value {
                print("JSON: \(JSON)")
            }
        }
//settimeout and callbaacks
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
//#import "UIImageView+AFNetworking.h"
//AFHTTPRequestOperationManager()
/*
func application(application: UIApplication, didFinshLaunchingWithOpstion launchOptions: [NSObject: AnyObject]?)->
    Bool {
        let manager = AFHTTPReques
        manager.GET("https://placego-rest.herokuapp.com/users/", parameters: nil, sucess: {(operation, responseObject) -> Void in
            print (responseObject)
            print("succes")
            }, failure: nil)
        return true
}
 
 
 let manager = AFHTTPSessionManager()
 
 manager.GET("https://placego-rest.herokuapp.com/users/", parameters: nil, success: { (operation: NSURLSessionDataTask, responseObject:AnyObject) in
 <#code#>
 }, failure: <#T##((NSURLSessionDataTask?, NSError) -> Void)?##((NSURLSessionDataTask?, NSError) -> Void)?##(NSURLSessionDataTask?, NSError) -> Void#>)
 
 NSURL *URL = []
 
 
 
 AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]]
 
 AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
 [manager GET:@"http://example.com/resources.json" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
 NSLog(@"JSON: %@", responseObject);
 } failure:^(NSURLSessionTask *operation, NSError *error) {
 NSLog(@"Error: %@", error);
 }];
 
 
 
 */