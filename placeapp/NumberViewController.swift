//
//  ViewController.swift
//  placeapp
//
//  Created by david on 27/03/16.
//  Copyright © 2016 david. All rights reserved.
//

import UIKit
import DigitsKit
import Alamofire


class NumberViewController: UIViewController {
    
    let headers = ["token" : "key123" ]

    @IBAction func login(sender: AnyObject) {
        // TODO: associate the session userID with your user model & Make back button
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var prueba: ContactsViewController
        
        let authButton = DGTAuthenticateButton(authenticationCompletion: { (session: DGTSession?, error: NSError?) in
            if (session != nil) {
                //let digits = Digits.sharedInstance()
                //digits.logOut()
                var id = userId
                print("id: \(id)")
                Alamofire.request(.POST, "https://placego-rest.herokuapp.com/phoneNumber/", parameters: ["id": userId, "phoneNumber":session!.phoneNumber], headers: self.headers)
                    .validate()
                    .response { request, response, data, error in
                        print("request: \(request)")
                        print("response: \(response)")
                        print("data: \(data)")
                        print("error: \(error)")
                      //  self.acceso = (response?.statusCode)!
                        
                        if((response?.statusCode)! == 200){
                       //     self.cargando.stopAnimating()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents();
                            SweetAlert().showAlert("Estás en place!", subTitle: "Más cerca de tus amigos", style: AlertStyle.Success)
                            self.performSegueWithIdentifier("jumpNumber", sender: self)
                        }else if((response?.statusCode)! == 409) {
                        //    self.cargando.stopAnimating()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents();                    SweetAlert().showAlert("Email inválido!", subTitle: "intenta de nuevo", style: AlertStyle.Warning)
                        }else {
                        //    self.cargando.stopAnimating()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents();
                            SweetAlert().showAlert("No te hemos podido registrar!")
                            
                        }
                        
                }
                
                
                self.performSegueWithIdentifier("jumpToTest", sender: self)
                // TODO: associate the session userID with your user model
                let message = "Phone number: \(session!.phoneNumber)"
                let alertController = UIAlertController(title: "You are logged in!", message: message, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: .None))
                
                self.presentViewController(alertController, animated: true, completion: .None)
                
            } else {
                NSLog("Authentication error: %@", error!.localizedDescription)
            }
        })
        authButton.center = self.view.center
        self.view.addSubview(authButton)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

