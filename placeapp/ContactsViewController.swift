//
//  ContactsViewController.swift
//  
//
//  Created by david on 27/05/16.
//
//

import UIKit
import EPContactsPicker
import DigitsKit
import Contacts


var contactsGlobal = [CNContact]()

struct MyVariables1 {
    static var hola = []
}


public class MainVar {
    var name:String
    init(name:String) {
        self.name = name
    }
}
var mainInstance = MainVar(name:"My Global Class")



class ContactsViewController: UIViewController,EPPickerDelegate {

    @IBAction func arrayButtonContacts(sender: AnyObject) {
        
        
        self.searchForContactUsingPhoneNumber("(888)555-1213")
        
        
    }
    
    let names = ["Anna", "Alex", "Brian", "Jack","(888)555-1212"]
    
    var array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
  public  struct MyVariables {
        static var hola = []
    }
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        for number in names {
            self.searchForContactUsingPhoneNumber(number)
            print("\(number) array")
            
        
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - App Logic
    func showMessage(message: String) {
        // Create an Alert
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Add an OK button to dismiss
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
        }
        alertController.addAction(dismissAction)
        
        // Show the Alert
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func requestForAccess(completionHandler: (accessGranted: Bool) -> Void) {
        // Get authorization
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        // Find out what access level we have currently
        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)
            
        case .Denied, .NotDetermined:
            CNContactStore().requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(accessGranted: access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            self.showMessage(message)
                        })
                    }
                }
            })
            
        default:
            completionHandler(accessGranted: false)
        }
    }
    
    
        
        
    
    
    func searchForContactUsingPhoneNumber(phoneNumber: String) {
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), { () -> Void in
            self.requestForAccess { (accessGranted) -> Void in
                if accessGranted {
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataKey, CNContactPhoneNumbersKey]
                    var contacts = [CNContact]()
                    var message: String!
                    
                    let contactsStore = CNContactStore()
                    do {
                        try contactsStore.enumerateContactsWithFetchRequest(CNContactFetchRequest(keysToFetch: keys)) {
                            (contact, cursor) -> Void in
                            if (!contact.phoneNumbers.isEmpty) {
                                let phoneNumberToCompareAgainst = phoneNumber.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
                                //print("phoneNumberToCompareAgainst: \(phoneNumberToCompareAgainst) phoneNumberToCompareAgainst")
                                for phoneNumber in contact.phoneNumbers {
                                    if let phoneNumberStruct = phoneNumber.value as? CNPhoneNumber {
                                        let phoneNumberString = phoneNumberStruct.stringValue
                                        let phoneNumberToCompare = phoneNumberString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
                                        if phoneNumberToCompare == phoneNumberToCompareAgainst {
                                            contacts.append(contact)
                                        }
                                    }
                                }
                            }
                        }
                        
                        if contacts.count == 0 {
                           // message = "No contacts were found matching the given phone number."
                            print("No contacts were found matching the given phone number.")
                        }
                    }
                    catch {
                        message = "Unable to fetch contacts."
                    }
                    
                    if message != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.showMessage(message)
                        })
                    }
                    else {
                        // Success
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // Do someting with the contacts in the main queue, for example
                            /*
                             self.delegate.didFetchContacts(contacts) <= which extracts the required info and puts it in a tableview
                             */
                            if contacts.count != 0 {
                                
                                let contact = contacts[0]
                                contactsGlobal.append(contact)
                                
                            }else{
                                
                                print("contacs \(contacts)")
                            }
                           // print(contacts) // Will print all contact info for each contact (multiple line is, for example, there are multiple phone numbers or email addresses)
                           // print("contacs \(contacts)")
                           // let contact = contacts[0]
                           // contactsGlobal.append(contact)
                          
                          /*  let contact = contacts[0] // For just the first contact (if two contacts had the same phone number)
                            
                            print(contact.givenName) // Print the "first" name
                            print(contact.familyName) // Print the "last" name
                            if contact.isKeyAvailable(CNContactImageDataKey) {
                                if let contactImageData = contact.imageData {
                                    print(UIImage(data: contactImageData)) // Print the image set on the contact
                                }
                            } else {
                                // No Image available
                                
                            }*/
                        })
                    }
                }
            }
        })
    }
    

    
    
    @IBAction func onTouchShowMeContactsButton(sender: AnyObject) {
        
        
     
        let digits = Digits.sharedInstance()
        digits.logOut()
        
         let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:true, subtitleCellType: SubtitleCellValue.Email)
        
         let navigationController = UINavigationController(rootViewController: contactPickerScene)
       // var controller: UINavigationController
       // controller = self.storyboard?.instantiateViewControllerWithIdentifier("NavigationVCIdentifierFromStoryboard") as! UINavigationController
        //controller.yourTableViewArray = "testing..."
         self.presentViewController(navigationController, animated: true, completion: nil)
         
         }
         
         //MARK: EPContactsPicker delegates
         func epContactPicker(_: EPContactsPicker, didContactFetchFailed error : NSError)
         {
         print("Failed with error \(error.description)")
         }
         
         func epContactPicker(_: EPContactsPicker, didSelectContact contact : EPContact)
         {
         print("Contact \(contact.displayName()) has been selected")
         }
         
         func epContactPicker(_: EPContactsPicker, didCancel error : NSError)
         {
         print("User canceled the selection");
         }
         
         func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact]) {
         print("The following contacts are selected")
         for contact in contacts {
         print("\(contact.displayName())")
         }
         }
    
    

    

}


