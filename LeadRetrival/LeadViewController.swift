//
//  LeadViewController.swift
//  LeadRetrival
//
//  Created by Kimani Walters on 21/01/2016.
//  Copyright © 2016 DiveChronicles. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class LeadViewController: UIViewController {
    
    // MARK: - Properties
    
    let leadTypes = ["Attendee", "Exhibitor", "VIP"]
    var actionButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    var activeField: UITextField?
    var editTemplateType: TemplateType!
    var managedObjectContext: NSManagedObjectContext? = nil
    var currentLead: Lead!
    var currentIndexPath = IndexPath(row: 0, section: 0)
    var _cachedFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    // MARK: - Computed Properties
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _cachedFetchedResultsController == nil {
            _cachedFetchedResultsController = prepareFetchedResultsController()
        }
        
        return _cachedFetchedResultsController!
    }
    
    var numberOfLeads: Int {
        if let sections = fetchedResultsController.sections, sections.count > 0 {
            return sections[0].numberOfObjects
        }
        
        return 0
    }
    
    var templates: [Template] {
        let context = managedObjectContext!
        
        if let templates = Template.findAll(context) as? [Template], templates.count > 0 {
            return templates
        }
        
        let templateTypes: [TemplateType] = [.email, .sms]
        let templateNames = ["Template 1", "Template 2", "Template 3"]
        for templateType in templateTypes {
            for templateName in templateNames {
                let date = Date()
                
                let newTemplate = NSEntityDescription.insertNewObject(forEntityName: "Template", into: context) as! Template
                newTemplate.templateName = templateName
                newTemplate.templateSubject = ""
                newTemplate.templateBody = ""
                newTemplate.templateType = NSNumber(value: templateType.rawValue as UInt16)
                newTemplate.dateCreated = date
                newTemplate.dateUpdated = date
                
                do {
                    try context.save()
                } catch {
                    print("Unresolved error \(error)")
                    abort()
                }
            }
        }
        
        
        return Template.findAll(context) as! [Template]
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var firstNameTextField: ErrorTextField!
    @IBOutlet weak var lastNameTextField: ErrorTextField!
    @IBOutlet weak var emailTextField: ErrorTextField!
    @IBOutlet weak var postalCodeTextField: ErrorTextField!
    @IBOutlet weak var phoneNumberTextField: ErrorTextField!
    @IBOutlet weak var typeTextField: ErrorTextField!
    @IBOutlet weak var companyTextField: ErrorTextField!
    @IBOutlet weak var paginationInfoLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var companyLabel: UILabel!
    
    // MARK: - Actions
    
    func didClickPickerDoneButton() {
        typeTextField.resignFirstResponder()
        
        if let text = typeTextField.text, text == "Exhibitor" {
            companyTextField.isHidden = false
            companyLabel.isHidden = false
        } else {
            companyTextField.isHidden = true
            companyTextField.error = nil
            companyTextField.text = ""
            companyLabel.isHidden = true
        }
    }
    
    func didClickDoneButton(_ sender: UIBarButtonItem) {
        activeField?.resignFirstResponder()
    }
    
    func didClickEditTemplate(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "Edit Template", message: "Choose Template Type", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Text", style: .default) { alert in
            self.editTemplateType = .sms
            self.performSegue(withIdentifier: "showTemplates", sender: self)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Email", style: .default) { alert in
            self.editTemplateType = .email
            self.performSegue(withIdentifier: "showTemplates", sender: self)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) { alert in })
        
        if let popover = actionSheet.popoverPresentationController, let view = sender.value(forKey: "view") as? UIView {
            popover.sourceView = view
            popover.sourceRect = view.bounds
            popover.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func didClickNewLead(_ sender: UIButton) {
        saveChagnes()
        addNewBlankLead()
    }
    
    @IBAction func didClickSaveChanges(_ sender: UIButton) {
        saveChagnes()
    }
    
    @IBAction func didClickPrev(_ sender: UIButton) {
        if currentIndexPath.row > 0 {
            currentIndexPath = IndexPath(row: currentIndexPath.row - 1, section: 0)
        } else {
            currentIndexPath = IndexPath(row: numberOfLeads - 1, section: 0)
        }
        
        currentLead = fetchedResultsController.object(at: currentIndexPath) as! Lead
        reloadForm()
    }
    
    @IBAction func didClickNext(_ sender: UIButton) {
        if currentIndexPath.row < (numberOfLeads - 1) {
            currentIndexPath = IndexPath(row: currentIndexPath.row + 1, section: 0)
        } else {
            currentIndexPath = IndexPath(row: 0, section: 0)
        }
        
        currentLead = fetchedResultsController.object(at: currentIndexPath) as! Lead
        reloadForm()
    }
    
    @IBAction func didClickDelete(_ sender: UIButton) {
        let context = fetchedResultsController.managedObjectContext
        context.delete(currentLead)
        
        do {
            try context.save()
        } catch {
            print("Unresolved error \(error)")
            abort()
        }
    }
    
    func showActionSheet(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: "Badge Generator Options", preferredStyle: .actionSheet)
    
        actionSheet.addAction(UIAlertAction(title: "Email All Leads", style: .default) { alert in
            guard
                MFMailComposeViewController.canSendMail(),
                let leads = self.fetchedResultsController.fetchedObjects as? [Lead]
                else { return }
            
            let csvString = Lead.toCSV(leads) as NSString
            guard let attachmentData = csvString.data(using: String.Encoding.utf8.rawValue) else { return }
            
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
            composer.setSubject("Bade Generator Contacts")
            composer.setMessageBody("Attached is a CSV file with a list of Leads.", isHTML: false)
            composer.addAttachmentData(attachmentData, mimeType: "text/csv", fileName: "leads.csv")
        })
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) { alert in })
        
        if let popover = actionSheet.popoverPresentationController, let view = sender.value(forKey: "view") as? UIView {
            popover.sourceView = view
            popover.sourceRect = view.bounds
            popover.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        
        present(actionSheet, animated: true, completion: nil)
    }

    @IBAction func didClickSendText1(_ sender: UIButton) { sendText(1) }
    @IBAction func didClickSendText2(_ sender: UIButton) { sendText(2) }
    @IBAction func didClickSendText3(_ sender: UIButton) { sendText(3) }
    
    @IBAction func didClickSendEmail1(_ sender: UIButton) { sendEmail(1) }
    @IBAction func didClickSendEmail2(_ sender: UIButton) { sendEmail(2) }
    @IBAction func didClickSendEmail3(_ sender: UIButton) { sendEmail(3) }
    
    func sendText(_ template: Int) {
        guard let phoneNumber = phoneNumberTextField.text, MFMessageComposeViewController.canSendText() else { return }
        
        let template = templates.filter({$0.templateType!.uint16Value == TemplateType.sms.rawValue})[template - 1]
        
        let composer = MFMessageComposeViewController()
        composer.messageComposeDelegate = self
        composer.recipients = [phoneNumber]
        composer.subject = template.templateSubject
        composer.body = template.templateBody
        
        self.present(composer, animated: true, completion: nil)
    }
    
    func sendEmail(_ template: Int) {
        guard let email = emailTextField.text, MFMailComposeViewController.canSendMail() else { return }
        
        let template = templates.filter({$0.templateType!.uint16Value == TemplateType.email.rawValue})[template - 1]
        
        let composer = MFMailComposeViewController()
        composer.setToRecipients([email])
        composer.mailComposeDelegate = self
        composer.setSubject(template.templateSubject ?? "")
        composer.setMessageBody(template.templateBody ?? "", isHTML: true)
        
        self.present(composer, animated: true, completion: nil)
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: "didClickDoneButton:")
        actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: "showActionSheet:")
        let editTemplate = UIBarButtonItem(title: "Templates", style: .done, target: self, action: Selector("didClickEditTemplate:"))
        navigationItem.leftBarButtonItem = editTemplate
        navigationItem.rightBarButtonItem = actionButton
        
        if numberOfLeads == 0 {
            addNewBlankLead()
        }
        
        currentLead = fetchedResultsController.object(at: currentIndexPath) as! Lead
        reloadForm()
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        phoneNumberTextField.delegate = self
        postalCodeTextField.delegate = self
        typeTextField.delegate = self
        companyTextField.delegate = self
        
        let statePicker = UIPickerView(frame: CGRect(x: 0, y: 50, width: view.frame.width, height: 150))
        statePicker.delegate = self
        statePicker.dataSource = self
        typeTextField.inputView = statePicker
        
        let inputAccessoryView = LRTextFieldAccessoryView(frame: CGRect(x: 0, y: 50, width: view.frame.width, height: 70))
        inputAccessoryView.backgroundColor = UIColor.darkGray
        inputAccessoryView.doneButton.addTarget(self, action: Selector("didClickPickerDoneButton"), for: .touchUpInside)
        typeTextField.inputAccessoryView = inputAccessoryView
    }
    
    func addNewBlankLead()  {
        let context = managedObjectContext!
        let newLead = NSEntityDescription.insertNewObject(forEntityName: "Lead", into: context) as! Lead
        newLead.firstName = ""
        newLead.lastName = ""
        newLead.email = ""
        newLead.phoneNumber = ""
        newLead.postalCode = ""
        newLead.leadType = "Attendee"
        newLead.compnayName = ""
        
        let date = Date()
        newLead.dateCreated = date
        newLead.dateUpdated = date
        
        do {
            try context.save()
        } catch {
            print("Unresolved error \(error)")
            abort()
        }
    }
    
    // MARK: - Form Methods
    
    func saveChagnes() {
        guard let context = managedObjectContext, isValid() else { return }
        
        currentLead.firstName = firstNameTextField.text
        currentLead.lastName = lastNameTextField.text
        currentLead.email = emailTextField.text
        currentLead.phoneNumber = phoneNumberTextField.text?.cleanPhoneNumber
        currentLead.postalCode = postalCodeTextField.text
        currentLead.leadType = typeTextField.text
        currentLead.compnayName = companyTextField.text
        currentLead.dateUpdated = Date()
        
        do {
            try context.save()
        } catch {
            print("Unresolved error \(error)")
            abort()
        }
    }
    
    func isValid() -> Bool {
        // Clean fields
        firstNameTextField.strip()
        lastNameTextField.strip()
        emailTextField.strip()
        phoneNumberTextField.strip()
        postalCodeTextField.strip()
        typeTextField.strip()
        companyTextField.strip()
        
        // Clear fields
        firstNameTextField.error = nil
        lastNameTextField.error = nil
        emailTextField.error = nil
        phoneNumberTextField.error = nil
        postalCodeTextField.error = nil
        typeTextField.error = nil
        companyTextField.error = nil
        
        var isValid = true
        
        if firstNameTextField.isEmpty {
            firstNameTextField.error = "First Name is required"
            isValid = false
        }
        
        if lastNameTextField.isEmpty {
            lastNameTextField.error = "Last Name is required"
            isValid = false
        }
        
        if emailTextField.isEmpty {
            emailTextField.error = "Email is required"
            isValid = false
        } else if !emailTextField.text!.isEmail {
            emailTextField.error = "Email is invalid"
            isValid = false
        }
        
        if !phoneNumberTextField.isEmpty && !phoneNumberTextField.text!.isPhoneNumber {
            phoneNumberTextField.error = "Phone Number is invalid"
            isValid = false
        }
        
        if postalCodeTextField.isEmpty {
            postalCodeTextField.error = "Postal Code is required"
            isValid = false
        } else if !postalCodeTextField.text!.isPostalCode {
            postalCodeTextField.error = "Postal Code is invalid"
            isValid = false
        }
        
        if typeTextField.isEmpty {
            typeTextField.error = "Type is required"
            isValid = false
        }
        
        if typeTextField.text! == "Exhibitor" && companyTextField.isEmpty {
            companyTextField.error = "Company is required"
            isValid = false
        }
        
        return isValid
    }
    
    func reloadForm() {
        firstNameTextField.text = currentLead.firstName
        lastNameTextField.text = currentLead.lastName
        emailTextField.text = currentLead.email
        postalCodeTextField.text = currentLead.postalCode
        phoneNumberTextField.text = currentLead.phoneNumber?.formatedPhoneNumber
        typeTextField.text = currentLead.leadType
        companyTextField.text = currentLead.compnayName
        paginationInfoLabel.text = "\(currentIndexPath.row + 1) of \(numberOfLeads) Leads"
    }
    
    // MARK: - Segues and Dismissals
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showScanViewController" {
            let controller = (segue.destination as! UINavigationController).topViewController as! QRScanViewController
            controller.deleget = self
        }
        
        if segue.identifier == "showTemplates" {
            let controller = segue.destination as! TemplateViewController
            controller.delegate = self
        }
    }
    
    func dismissQRScanViewController(_ info: LeadQRCInfo? = nil) {
        dismiss(animated: true, completion: nil)
        
        guard let info = info else { return }
        
        // Save any changes that might have been made to current record and add a new record
        saveChagnes()
        addNewBlankLead()
        
        firstNameTextField.text = info.firstName
        lastNameTextField.text = info.lastName
        emailTextField.text = info.email
        postalCodeTextField.text = info.postalCode
        phoneNumberTextField.text = info.phoneNumber.formatedPhoneNumber
        
        saveChagnes()
    }
}

// MARK: - Fetched results controller

extension LeadViewController: NSFetchedResultsControllerDelegate {
    func prepareFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        let context = self.managedObjectContext!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "Lead", in: context)
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "Lead")
        aFetchedResultsController.delegate = self
        
        do {
            try aFetchedResultsController.performFetch()
        } catch {
            print("Unresolved error \(error)")
            abort()
        }
        
        return aFetchedResultsController
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            currentIndexPath = newIndexPath!
            currentLead = fetchedResultsController.object(at: currentIndexPath) as! Lead
            reloadForm()
            
        case .delete:
            if numberOfLeads == 0 {
                addNewBlankLead()
            } else {
                if currentIndexPath.row >= numberOfLeads {
                    currentIndexPath = IndexPath(row: currentIndexPath.row - 1, section: 0)
                }
                
                currentLead = fetchedResultsController.object(at: currentIndexPath) as! Lead
                reloadForm()
            }
            
        default: break
        }
    }
}

// MARK: - Mail Compose View Controller Delegate

extension LeadViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case MFMailComposeResult.cancelled:
            print("Mail cancelled")
        case MFMailComposeResult.saved:
            print("Mail saved")
        case MFMailComposeResult.sent:
            print("Mail sent")
        case MFMailComposeResult.failed:
            print("Mail sent failure: \(error?.localizedDescription)")
        default:
            break
        }
        
        self.dismiss(animated: false, completion: nil)
    }
}

// MARK: - Message Compose View Controller Delegate

extension LeadViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case MessageComposeResult.cancelled :
            print("Text cancelled")
        case MessageComposeResult.sent:
            print("Text sent")
        case MessageComposeResult.failed:
            print("Text sent failure")
        default:
            break
        }
        
        dismiss(animated: false, completion: nil)
    }
}

// MARK: - Template View Controller Delegate

extension LeadViewController: TemplateViewControllerDelegate {
    func templateViewControllerTemplates() -> [Template] {
        return templates.filter({$0.templateType!.uint16Value == editTemplateType.rawValue})
    }
}

// MARK: - Text Field Delegate

extension LeadViewController: UITextFieldDelegate {
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: Selector("keyboardWasShown:"), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: Selector("keyboardWillBeHidden:"), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unregisterForKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.registerForKeyboardNotification()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.unregisterForKeyboardNotification()
    }
    
    func keyboardWasShown(_ notification: Notification) {
        guard let activeField = activeField else { return }
        
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]  {
            let kbSize = (keyboardFrame as AnyObject).cgRectValue.size
            
            let contentInsets =  UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            var rect = self.view.frame
            rect.size.height -= kbSize.height
            
            if !rect.contains(activeField.frame.origin) {
                self.scrollView.scrollRectToVisible(self.activeField!.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeField = textField
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeField = nil
        navigationItem.rightBarButtonItem = actionButton
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == phoneNumberTextField else { return true }
        guard string.isDigit || string.isEmpty else { return false }
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let components = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
        
        let decimalString = components.joined(separator: "") as NSString
        let length = decimalString.length
        
        if length == 0 || length > 10 {
            let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
            
            return (newLength > 10) ? false : true
        }
        
        var index = 0 as Int
        let formattedString = NSMutableString()
        
        if (length - index) > 3 {
            let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
            formattedString.appendFormat("%@-", areaCode)
            index += 3
        }
        
        if length - index > 3 {
            let prefix = decimalString.substring(with: NSMakeRange(index, 3))
            formattedString.appendFormat("%@-", prefix)
            index += 3
        }
        
        let remainder = decimalString.substring(from: index)
        formattedString.append(remainder)
        textField.text = formattedString as String
        
        return false
    }
}

extension LeadViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return leadTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return leadTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeTextField.text = leadTypes[row]
    }
    
}
