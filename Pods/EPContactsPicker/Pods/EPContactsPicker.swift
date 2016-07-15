//
//  EPContactsPicker.swift
//  EPContacts
//
//  Created by Prabaharan Elangovan on 12/10/15.
//  Copyright © 2015 Prabaharan Elangovan. All rights reserved.
//

import UIKit
import Contacts

struct MyVariables3 {
    static var hola = []
}

@objc public protocol EPPickerDelegate {
    optional    func epContactPicker(_: EPContactsPicker, didContactFetchFailed error: NSError)
    optional    func epContactPicker(_: EPContactsPicker, didCancel error: NSError)
    optional    func epContactPicker(_: EPContactsPicker, didSelectContact contact: EPContact)
    optional    func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact])

}

typealias ContactsHandler = (contacts : [CNContact] , error : NSError?) -> Void

public enum SubtitleCellValue{
    case PhoneNumer
    case Email
    case Birthday
    case Organization
}

var holamundo2 = "";



public class EPContactsPicker: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    // MARK: - Properties
   
    
    public var contactDelegate: EPPickerDelegate?
    var contactsStore: CNContactStore?
    var resultSearchController = UISearchController()
    var orderedContacts = [String: [CNContact]]() //Contacts ordered in dicitonary alphabetically
    var sortedContactKeys = [String]()
    
    var selectedContacts = [EPContact]()
    var filteredContacts = [CNContact]()
    
    var subtitleCellValue = SubtitleCellValue.PhoneNumer
    var multiSelectEnabled: Bool = false //Default is single selection contact
    
    // MARK: - Lifecycle Methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
    

        self.title = EPGlobalConstants.Strings.contactsTitle

        let nib = UINib(nibName: "EPContactCell", bundle: NSBundle(forClass: EPContactsPicker.self))
        tableView.registerNib(nib, forCellReuseIdentifier: "Cell")
        
        inititlizeBarButtons()
        initializeSearchBar()
        reloadContacts()
       // self.tableView.separatorColor = UIColor.redColor()
      //  let appDelegate  = UIApplication.sharedApplication().delegate as AppDelegate
      //  let viewController = appDelegate.window!.rootViewController as YourViewController
        
        
    }
    
    func initializeSearchBar() {
        self.resultSearchController = ( {
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.delegate = self
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        
    }
    
    func inititlizeBarButtons() {
       // let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "onTouchCancelButton")
        let testButton = UIBarButtonItem(title: "Atrás", style: .Plain, target: self, action: "onTouchCancelButton")
        self.navigationItem.leftBarButtonItem = testButton
        
        if multiSelectEnabled {
          //  let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "onTouchDoneButton")
            let doneButton = UIBarButtonItem(title: "Siguiente", style: .Plain, target: self, action: "onTouchDoneButton")
            self.navigationItem.rightBarButtonItem = doneButton
            
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.  :Selector("buttonAction:")  onTouchDoneButton
    }

    // MARK: - Initializers
  
    convenience public init(delegate: EPPickerDelegate?) {
        self.init(delegate: delegate, multiSelection: false)
    }
    
    convenience public init(delegate: EPPickerDelegate?, multiSelection : Bool) {
        self.init(style: .Plain)
        self.multiSelectEnabled = multiSelection
        contactDelegate = delegate
    }

    convenience public init(delegate: EPPickerDelegate?, multiSelection : Bool, subtitleCellType: SubtitleCellValue) {
        self.init(style: .Plain)
        self.multiSelectEnabled = multiSelection
        contactDelegate = delegate
        subtitleCellValue = subtitleCellType
    }
    
    
    // MARK: - Contact Operations
  
      public func reloadContacts() {
        getContacts( {(contacts, error) in
            if (error == nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
        })
      }
  
    func getContacts(completion:  ContactsHandler) {
        if contactsStore == nil {
            //ContactStore is control for accessing the Contacts
            contactsStore = CNContactStore()
        }
        let error = NSError(domain: "EPContactPickerErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "No Contacts Access"])
        
        switch CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts) {
            case CNAuthorizationStatus.Denied, CNAuthorizationStatus.Restricted: break
                //User has denied the current app to access the contacts.
                
         /*     */  let productName = NSBundle.mainBundle().infoDictionary!["CFBundleName"]!
                
                let alert = UIAlertController(title: "Unable to access contacts", message: "\(productName) does not have access to contacts. Kindly enable it in privacy settings ", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {  action in
                    self.contactDelegate?.epContactPicker!(self, didContactFetchFailed: error)
                    completion(contacts: [], error: error)
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                alert.addAction(okAction)
                self.presentViewController(alert, animated: true, completion: nil)
            
            case CNAuthorizationStatus.NotDetermined:
                //This case means the user is prompted for the first time for allowing contacts
                contactsStore?.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (granted, error) -> Void in
                    //At this point an alert is provided to the user to provide access to contacts. This will get invoked if a user responds to the alert
                    if  (!granted ){
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completion(contacts: [], error: error!)
                        })
                    }
                    else{
                        self.getContacts(completion)
                    }
                })
            
            case  CNAuthorizationStatus.Authorized:
                //Authorization granted by user for this app.
                
                
                
                
                
                
                var contactsArray = [CNContact]()
                
                let contactFetchRequest = CNContactFetchRequest(keysToFetch: allowedContactKeys())
                
                do {
                    try contactsStore?.enumerateContactsWithFetchRequest(contactFetchRequest, usingBlock: { (contact, stop) -> Void in
                        //Ordering contacts based on alphabets in firstname
                        contactsArray.append(contact)
                        var key: String = "#"
                        //If ordering has to be happening via family name change it here.
                        if let firstLetter = contact.givenName[0..<1] where firstLetter.containsAlphabets() {
                            key = firstLetter.uppercaseString
                        }
                        var contacts = [CNContact]()
                        
                        if let segregatedContact = self.orderedContacts[key] {
                            contacts = segregatedContact
                        }
                        contacts.append(contact)
                        self.orderedContacts[key] = contacts //
                      ///  self.orderedContacts[key] = MyVarialbles
                        
                    

                    })
                    self.sortedContactKeys = Array(self.orderedContacts.keys).sort(<)
                    if self.sortedContactKeys.first == "#" {
                        self.sortedContactKeys.removeFirst()
                        self.sortedContactKeys.append("#")
                    }
                    completion(contacts: contactsArray, error: nil)
                    print("sortedcontactKeys: \(sortedContactKeys)")
                    print("orderedContacts: \(orderedContacts)")
                    print("COontactsArray : \(contactsArray)")
                }
                //Catching exception as enumerateContactsWithFetchRequest can throw errors
                catch let error as NSError {
                    print(error.localizedDescription)
                }
            
            
            
            
              // TODO: 
            
                var contactos1: [CNContact] = {
                    let contactStore = CNContactStore()
                    let keysToFetch = [
                        CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
                        CNContactEmailAddressesKey,
                        CNContactPhoneNumbersKey,
                        CNContactImageDataAvailableKey,
                        CNContactThumbnailImageDataKey]
                    
                    // Get all the containers
                    var allContainers: [CNContainer] = []
                    do {
                        allContainers = try contactStore.containersMatchingPredicate(nil)
                    } catch {
                        print("Error fetching containers")
                    }
                    
                    var results: [CNContact] = []
                    
                    // Iterate all containers and append their contacts to our results array
                    for container in allContainers {
                        let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
                        
                        do {
                            let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                            results.appendContentsOf(containerResults)
                        } catch {
                            print("Error fetching results for container")
                        }
                    }
                    
                    return results
                    print("results: \(results)")
            }()
            
            // termina
                print("contactos1: \(contactos1)")
            
        }
    }
    
    func allowedContactKeys() -> [CNKeyDescriptor]{
        //We have to provide only the keys which we have to access. We should avoid unnecessary keys when fetching the contact. Reducing the keys means faster the access.
        return [CNContactNamePrefixKey,
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactOrganizationNameKey,
            CNContactBirthdayKey,
            CNContactImageDataKey,
            CNContactThumbnailImageDataKey,
            CNContactImageDataAvailableKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
        ]
    }
    
    // MARK: - Table View DataSource
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if resultSearchController.active { return 1 }
        return sortedContactKeys.count
        
        //return 4
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.active { return filteredContacts.count }
        if let contactsForSection = orderedContacts[sortedContactKeys[section]] {
            return contactsForSection.count
        }
        return 0
    }

    // MARK: - Table View Delegates

    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EPContactCell
        cell.accessoryType = UITableViewCellAccessoryType.None
        //Convert CNContact to EPContact
        var contact = EPContact()
        
        if resultSearchController.active {
            contact = EPContact(contact: filteredContacts[indexPath.row])
            
        } else {
            if let contactsForSection = orderedContacts[sortedContactKeys[indexPath.section]] {
                contact =  EPContact(contact: contactsForSection[indexPath.row])
            }
        }
        if multiSelectEnabled  && selectedContacts.contains({ $0.contactId == contact.contactId }) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        cell.updateContactsinUI(contact, indexPath: indexPath, subtitleType: subtitleCellValue)
        return cell
    }
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! EPContactCell
        let selectedContact =  cell.contact!
        if multiSelectEnabled {
            //Keeps track of enable=ing and disabling contacts
            if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
                cell.accessoryType = UITableViewCellAccessoryType.None
                selectedContacts = selectedContacts.filter(){
                    return selectedContact.contactId != $0.contactId
                }
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                print(selectedContact.onlyPhoneNumbers)
                selectedContacts.append(selectedContact)
            }
        }
        else {
            //Single selection code
            contactDelegate?.epContactPicker!(self, didSelectContact: selectedContact)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    override public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if resultSearchController.active { return 0 }
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: index), atScrollPosition: UITableViewScrollPosition.Top , animated: false)        
        return EPGlobalConstants.Arrays.alphabets.indexOf(title)!
    }
    
    override  public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if resultSearchController.active { return nil }
        return sortedContactKeys
    }

    override public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if resultSearchController.active { return nil }
        return sortedContactKeys[section]
    }
    
    // MARK: - Button Actions
    
    func onTouchCancelButton() {
        //contactDelegate?.epContactPicker!(self, didCancel: NSError(domain: "EPContactPickerErrorDomain", code: 2, userInfo: [ NSLocalizedDescriptionKey: "User Canceled Selection"]))
        //dismissViewControllerAnimated(true, completion: nil)
        
        self.searchForContactUsingPhoneNumber("(888)555-1212")
    }
    
  /**/  override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        func onTouchDoneButton(sender:UIButton!) {
            contactDelegate?.epContactPicker!(self, didSelectMultipleContacts: selectedContacts)
            
            var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var vc: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("TestViewController") as! UINavigationController
            
            self.presentViewController(vc, animated: true, completion: nil)
            
            // let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:true, subtitleCellType: SubtitleCellValue.Email)
            // let navigationController = UINavigationController(rootViewController: contactPickerScene)
            // self.presentViewController(navigationController, animated: true, completion: nil)
            
            // let testViewScene = TestViewCon
            
            //presentViewController(nextViewController, animated: true, completion: nil)
            
            //presentViewController(, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
            //self.performSegueWithIdentifier("jumpToMap", sender: nil)
            //self(NumberVies, animated: true, completion: nil)
            
            dismissViewControllerAnimated(true, completion: nil)
        }

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
                            message = "No contacts were found matching the given phone number."
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
                            print("contacts$:  \(contacts)") // Will print all contact info for each contact (multiple line is, for example, there are multiple phone numbers or email addresses)
                            
                            let contact = contacts[0] // For just the first contact (if two contacts had the same phone number)
                            print("contact givenNAme$: \(contact.givenName)")
                            print(contact.givenName) // Print the "first" name
                            print(contact.phoneNumbers) // Print the "last" name
                            if contact.isKeyAvailable(CNContactImageDataKey) {
                                if let contactImageData = contact.imageData {
                                    print(UIImage(data: contactImageData)) // Print the image set on the contact
                                }
                            } else {
                                // No Image available
                                
                            }
                        })
                    }
                }
            }
        })
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    func onTouchDoneButton() {
        contactDelegate?.epContactPicker!(self, didSelectMultipleContacts: selectedContacts)
        
        print("Ggggggggg")
        
        var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //var vc: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("TestViewController") as! UINavigationController
       // let vc: UINavigationController = segue.destinationViewController as! UINavigationController
        let vc: UIViewController = storyboard.instantiateViewControllerWithIdentifier("TestViewController") as! UIViewController
        
        self.presentViewController(vc, animated: true, completion: nil)
        
       // var vc: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("TestViewController") as! UINavigationController
        
       // self.presentViewController(vc, animated: true, completion: nil)
        
        
        
       

        
       // let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:true, subtitleCellType: SubtitleCellValue.Email)
       // let navigationController = UINavigationController(rootViewController: contactPickerScene)
       // self.presentViewController(navigationController, animated: true, completion: nil)
        
       // let testViewScene = TestViewCon
    
        //presentViewController(nextViewController, animated: true, completion: nil)
        
        //presentViewController(, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
        //self.performSegueWithIdentifier("jumpToMap", sender: nil)
        //self(NumberVies, animated: true, completion: nil)
        
      //  dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Search Actions
    
    public func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        if let searchText = resultSearchController.searchBar.text where searchController.active {
            
            let predicate: NSPredicate
            if searchText.characters.count > 0 {
                predicate = CNContact.predicateForContactsMatchingName(searchText)
            } else {
                predicate = CNContact.predicateForContactsInContainerWithIdentifier(contactsStore!.defaultContainerIdentifier())
            }
            
            let store = CNContactStore()
            do {
                filteredContacts = try store.unifiedContactsMatchingPredicate(predicate,
                    keysToFetch: allowedContactKeys())
                print("\(filteredContacts.count) count")
                self.tableView.reloadData()
            }
            catch {
                print("Handle the error please")
            }
        }
    }
    
    public func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
}
