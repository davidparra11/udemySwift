//
//  RegisterViewController.swift
//  placeapp
//
//  Created by david on 24/05/16.
//  Copyright © 2016 david. All rights reserved.
//

import UIKit
import QuartzCore
import Alamofire



class RegisterViewController: UIViewController, UITextFieldDelegate {
    let headers = ["token" : "key123"]
    //MARK: Outlets for UI Elements.
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var loginButton:     UIButton!
    
     var cargando = UIActivityIndicatorView()

    
    //MARK: Global Variables for Changing Image Functionality.
    private var idx: Int = 0
    private let backGroundArray = [UIImage(named: "img1.jpg"),UIImage(named:"img2.jpg"), UIImage(named: "img3.jpg"), UIImage(named: "img4.jpg")]
    
    //MARK: View Controller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        username.delegate = self
        password.delegate = self
        
        username.alpha = 0;
        password.alpha = 0;
        //loginButton.alpha   = 0;
        
        UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.username.alpha = 1.0
            self.password.alpha = 1.0
            self.loginButton.alpha   = 0.9
            }, completion: nil)
        
        // Notifiying for Changes in the textFields
        username.addTarget(self, action: "textFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
        password.addTarget(self, action: "textFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
        
        
        // Visual Effect View for background
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark)) as UIVisualEffectView
        visualEffectView.frame = self.view.frame
        visualEffectView.alpha = 0.5
        imageView.image = UIImage(named: "img1.jpg")
        imageView.addSubview(visualEffectView)
        
        
        NSTimer.scheduledTimerWithTimeInterval(6, target: self, selector: "changeImage", userInfo: nil, repeats: true)
        self.loginButton(false)
        
    }
  /* */ override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
        username.resignFirstResponder()
        
    }

    
    func loginButton(enabled: Bool) -> () {
        
        func enable(){
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.loginButton.backgroundColor = UIColor.colorWithHexs("#33CC00", alpha: 1)
                }, completion: nil)
            loginButton.enabled = true
        }
        func disable(){
            loginButton.enabled = false
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.loginButton.backgroundColor = UIColor.colorWithHexs("#333333",alpha :1)
                }, completion: nil)
        }
        return enabled ? enable() : disable()
        
    }
    
    func changeImage(){
        if idx == backGroundArray.count-1{
            idx = 0
        }
        else{
            idx++
        }
        var toImage = backGroundArray[idx];
        UIView.transitionWithView(self.imageView, duration: 3, options: .TransitionCrossDissolve, animations: {self.imageView.image = toImage}, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func textFieldDidChange() {
        if username.text!.isEmpty || password.text!.isEmpty
        {
            self.loginButton(false)
        }
        else
        {
            self.loginButton(true)
        }
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {

        var error = ""
        
        // SweetAlert().showAlert("Here's a message!")
        
        if self.username.text == "" || self.password.text == "" {
            error = "la contraseña o el email no ha sido ingresado"
            //self.infoLabel.hidden = false
            
        }else{
            print("usuario logueado")
            
            cargando.center = self.view.center
            cargando.hidesWhenStopped = true
            cargando.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            cargando.startAnimating()
            self.view.addSubview(cargando)
            UIApplication.sharedApplication().beginIgnoringInteractionEvents() //acrodarme de quitar el cargando pra que mi app pueda de nuevo recibir eventos
            
            
            Alamofire.request(.POST, "https://placego-rest.herokuapp.com/login/", parameters: ["username": self.username.text!, "password":self.password.text!], headers: headers)
                .validate()
                .response { request, response, data, error in
                    print("request: \(request)")
                    print("response: \(response?.statusCode)")
                    print("data: \(data)")
                    /*do {
                        if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                            print("json : \(json)")
                            var x = json["data"]!;
                            print("x: \(x.objectAtIndex(0)["id"]!)")
                            //var y = x.objectAtIndex(0)["id"]!;
                            //userId = x.(0)["id"]!;
                            
                        }
                        
                    }catch{
                        print(error)
                    }

                    print("error: \(error)")
                    */
                    do {
                        if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                            print("json : \(json.valueForKey("data")?.valueForKey("id")!)")
                            //var x = json.valueForKey("data")?.objectAtIndex(0)["id"]!
                            var x = json.valueForKey("data")?.objectAtIndex(0).valueForKey("id")!
                            print("data: \(x)")
                          //  let z = try NSJSONSerialization.dataWithJSONObject(x!, options: NSJSONWritingOptions.PrettyPrinted)
                          //  let y = NSString(data: z, encoding: NSUTF8StringEncoding)
                           // print("x: \(x.objectAtIndex(0)["id"]!!.stringValue)")     json["data"]!.stringValue;
                            //var y = x.objectAtIndex(0)["id"]!;
                            //userId = x.(0)["id"]!;
                           // userId = y!
                            print("x! : \(x!)")
                            
                        }
                        
                    }catch{
                        print(error)
                    }
                    
                    print("error: \(error)")
                    if((response?.statusCode)! == 200){
                        self.cargando.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents();
                        SweetAlert().showAlert("Estas en place!", subTitle: "Más cerca de tus amigos", style: AlertStyle.Success)
                        //self.performSegueWithIdentifier("jumpNumber", sender: self)
                    }else if((response?.statusCode)! == 409) {
                        self.cargando.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents();
                        SweetAlert().showAlert("Email inválido!", subTitle: "intenta de nuevo", style: AlertStyle.Warning)
                    }else {
                        self.cargando.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents();
                        SweetAlert().showAlert("Error!", subTitle: "intenta de nuevo", style: AlertStyle.Warning)
                        
                    }
            }

            
            var username = self.username.text
            var password = self.password.text
        }

        
    }

    
}

//Extension for Color to take Hex Values
extension UIColor{
    
    class func colorWithHexs(hex: String, alpha: CGFloat = 1.0) -> UIColor {
        var rgb: CUnsignedInt = 0;
        let scanner = NSScanner(string: hex)
        
        if hex.hasPrefix("#") {
            // skip '#' character
            scanner.scanLocation = 1
        }
        scanner.scanHexInt(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0xFF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}/**/






