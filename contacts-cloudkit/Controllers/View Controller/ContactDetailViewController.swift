//
//  ContactDetailViewController.swift
//  contacts-cloudkit
//
//  Created by Jordan Furr on 4/3/20.
//  Copyright © 2020 Jordan Furr. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var numberLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    
    
    var contact: Contact? {
        didSet {
            DispatchQueue.main.async {
                self.loadViewIfNeeded()
                self.updateViews()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    func updateViews() {
        guard let contact = contact else {return}
        nameLabel.text = contact.name
        numberLabel.text = contact.number ?? ""
        emailLabel.text = contact.email ?? ""
    }
   
    @IBAction func saveTapped(_ sender: Any) {
        if let name = nameLabel.text {
            if name != "" {
                if let contact = contact {
                    contact.name = name
                    contact.number = numberLabel.text ?? ""
                    contact.email = emailLabel.text ?? ""
                    ContactController.shared.update(contact: contact) { (result) in
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                } else {
                    ContactController.shared.createContact(with: name, number: numberLabel.text ?? "", email: emailLabel.text ?? "") { (result) in
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
        resignFirstResponder()
    }
    
    
    @IBAction func deleteTapped(_ sender: Any) {
        if let contact = contact {
            ContactController.shared.delete(contact: contact) { (result) in
                switch result {
                case .success(let success):
                    if success {
                    guard let index = ContactController.shared.contacts.firstIndex(of: contact) else { return}
                     ContactController.shared.contacts.remove(at: index)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        navigationController?.popViewController(animated: true)
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameLabel.resignFirstResponder()
        numberLabel.resignFirstResponder()
        emailLabel.resignFirstResponder()
        return true
    }

}
