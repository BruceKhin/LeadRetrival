//
//  TemplateViewController.swift
//  LeadRetrival
//
//  Created by Kimani Walters on 22/01/2016.
//  Copyright © 2016 DiveChronicles. All rights reserved.
//

import UIKit
import CoreData

protocol TemplateViewControllerDelegate {
    var editTemplateType: TemplateType! { get set }
    var managedObjectContext: NSManagedObjectContext? { get set }
    func templateViewControllerTemplates() -> [Template]
}

class TemplateViewController: UIViewController {
    
    // MARK: - Properties
    var activeRect: CGRect?
    var doneButton: UIBarButtonItem!
    var saveButton: UIBarButtonItem!
    var delegate: TemplateViewControllerDelegate? = nil
    
    // MARK: - Outlets
    
    @IBOutlet weak var templateSegmentControl: UISegmentedControl!
    @IBOutlet weak var templateSubjectTextField: UITextField!
    @IBOutlet weak var templateBodyTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Actions
    
    @IBAction func didClickTemplateSegmentControl(_ sender: UISegmentedControl) {
        guard let selectedTemplate = delegate?.templateViewControllerTemplates()[sender.selectedSegmentIndex] else { return }
        
        templateSubjectTextField.text = selectedTemplate.templateSubject
        templateBodyTextView.text = selectedTemplate.templateBody
    }
    
    func didClickSave(_ sender: UIBarButtonItem) {
        guard
            let context = delegate?.managedObjectContext,
            let templates = delegate?.templateViewControllerTemplates()
        else { return }
        
        let selectedTemplate = templates[templateSegmentControl.selectedSegmentIndex]
        selectedTemplate.templateSubject = templateSubjectTextField.text
        selectedTemplate.templateBody = templateBodyTextView.text
        
        do {
            try context.save()
        } catch {
            print("Unresolved error \(error)")
            abort()
        }
    }
    
    func didClickDone(_ sender: UIBarButtonItem) {
        view.endEditing(true)
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        templateSubjectTextField.delegate = self
        templateBodyTextView.delegate = self
        
        if let templateType = delegate?.editTemplateType {
            if templateType == .email {
                navigationItem.title = "Email Templates"
            }
            
            if templateType == .sms {
                navigationItem.title = "Text Templates"
            }
        }
        
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(TemplateViewController.didClickDone(_:)))
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(TemplateViewController.didClickSave(_:)))
        navigationItem.rightBarButtonItem = saveButton
        
        guard let templates = delegate?.templateViewControllerTemplates() else { return }
        
        let segmentCount = templateSegmentControl.numberOfSegments
        for i in 0..<segmentCount {
            templateSegmentControl.setTitle(templates[i].templateName, forSegmentAt: i)
        }
        
        templateSubjectTextField.text = templates.first?.templateSubject
        templateBodyTextView.text = templates.first?.templateBody
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        registerForKeyboardNotification()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unregisterForKeyboardNotification()
    }
    
    // MARK: - Track Keyboard
    
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(TemplateViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TemplateViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unregisterForKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(_ notification: Notification) {
        guard let activeRect = activeRect else { return }
        
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]  {
            let kbSize = (keyboardFrame as AnyObject).cgRectValue.size
            
            let contentInsets =  UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            var rect = self.view.frame
            rect.size.height -= kbSize.height
            
            if !rect.contains(activeRect.origin) {
                self.scrollView.scrollRectToVisible(activeRect, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
}

// MARK: - Text Field Delegate

extension TemplateViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeRect = textField.frame
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeRect = nil
        navigationItem.rightBarButtonItem = saveButton
    }
}

// MARK: - Text View Delegate

extension TemplateViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeRect = textView.frame
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeRect = textView.frame
        navigationItem.rightBarButtonItem = saveButton
    }
}
