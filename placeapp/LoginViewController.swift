//
//  LoginViewController.swift
//  placeapp
//
//  Created by david on 10/05/16.
//  Copyright © 2016 david. All rights reserved.
//


import UIKit
import QuartzCore
import Alamofire

var userId = String();

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Outlets for UI Elements.
    @IBOutlet weak var usernameField:   UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var imageView:       UIImageView!
    @IBOutlet weak var passwordField:   UITextField!
    @IBOutlet weak var loginButton:     UIButton!
    var acceso = 0;
    var cargando = UIActivityIndicatorView()
    let headers = ["token" : "key123" ]
    
    
    //MARK: Global Variables for Changing Image Functionality.
    private var idx: Int = 0
    private let backGroundArray = [UIImage(named: "img1.jpg"),UIImage(named:"img2.jpg"), UIImage(named: "img3.jpg"), UIImage(named: "img4.jpg")]
    
    //MARK: View Controller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.alpha = 0;
        passwordField.alpha = 0;
        loginButton.alpha   = 0;
        
        
        UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.usernameField.alpha = 1.0
            self.passwordField.alpha = 1.0
            self.loginButton.alpha   = 0.9
            }, completion: nil)
        
        // Notifiying for Changes in the textFields
        usernameField.addTarget(self, action: "textFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
        passwordField.addTarget(self, action: "textFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
        
        
        // Visual Effect View for background
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark)) as UIVisualEffectView
        visualEffectView.frame = self.view.frame
        visualEffectView.alpha = 0.5
        imageView.image = UIImage(named: "img1.jpg")
        imageView.addSubview(visualEffectView)
        
        
        NSTimer.scheduledTimerWithTimeInterval(6, target: self, selector: "changeImage", userInfo: nil, repeats: true)
        self.loginButton(false)
        
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
        //username.resignFirstResponder()
        
    }
    // func put another color to Register Button when users fill all textFields
    func loginButton(enabled: Bool) -> () {
        
        func enable(){
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.loginButton.backgroundColor = UIColor.colorWithHex("#33CC00", alpha: 1)
                }, completion: nil)
            loginButton.enabled = true
        }
        func disable(){
            loginButton.enabled = false
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.loginButton.backgroundColor = UIColor.colorWithHex("#333333",alpha :1)
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
        if usernameField.text!.isEmpty || passwordField.text!.isEmpty
        {
            self.loginButton(false)
        }
        else
        {
            self.loginButton(true)
        }
    }
    

    
    /**
     This func works when, Register Button is pressed and it star to req to server.
     :params: username, email & password
     
     :returns: Allow user register on the app or reject his requeriment.
     */
    @IBAction func buttonPressed(sender: AnyObject) {
        
        var error = "";
    
        
        if self.usernameField.text == "" || self.emailField.text == "" {
            error = "la contraseña o el email no ha sido ingresado"
        }else{
            print("usuario registrado")
    
            cargando.center = self.view.center
            cargando.hidesWhenStopped = true
            cargando.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            cargando.startAnimating()
            self.view.addSubview(cargando)
            UIApplication.sharedApplication().beginIgnoringInteractionEvents() //acrodarme de quitar el cargando pra que mi app pueda de nuevo recibir eventos
            
            
            Alamofire.request(.POST, "https://placego-rest.herokuapp.com/create/", parameters: ["username": self.usernameField.text!, "email":self.emailField.text!, "password":self.passwordField.text!], headers: headers)
                .validate()
                .response { request, response, data, error in
                    print("request: \(request)")
                    print("response: \(response)")
                   /* do {
                        if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                           print("json : \(json["data"]!["id"])")
                        }
                            
                    }catch{
                        print(error)
                    }*/
                    do {
                        if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                            print("json : \(json.valueForKey("data")?.valueForKey("id")!)")
                            //var x = json.valueForKey("data")?.objectAtIndex(0)["id"]!
                            var x = json.valueForKey("data")?.objectAtIndex(0).valueForKey("id")!
                            print("data: \(x)")
                            
                            print("x! : \(x!)")
                            userId = x! as! String
                            
                        }
                        
                    }catch{
                        print(error)
                    }
                   // var dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                   // print("data: \(dataString)")
                   /* if let dataFromString = dataString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false){
                        let json = JSON(data: dataFromString)
                        if let testo = json.string {
                            print("test: \(testo)")
                        }
                    }*/
                    //print("id: \(dataString["data"])")
                    print("error: \(error)")
                    self.acceso = (response?.statusCode)!
                    
                    if((response?.statusCode)! == 200){
                        self.cargando.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents();
                        SweetAlert().showAlert("Estás en place!", subTitle: "Más cerca de tus amigos", style: AlertStyle.Success)
                       // self.performSegueWithIdentifier("jumpNumber", sender: self)
                    }else if((response?.statusCode)! == 409) {
                        self.cargando.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents();                    SweetAlert().showAlert("Email inválido!", subTitle: "intenta de nuevo", style: AlertStyle.Warning)
                    }else {
                        self.cargando.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents();
                        SweetAlert().showAlert("No te hemos podido registrar!")
                        
                    }
                    
            }

        }
       
        
    }

}

//Extension for Color to take Hex Values
extension UIColor{
    
    class func colorWithHex(hex: String, alpha: CGFloat = 1.0) -> UIColor {
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
}






