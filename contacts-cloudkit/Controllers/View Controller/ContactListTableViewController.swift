//
//  ContactListTableViewController.swift
//  contacts-cloudkit
//
//  Created by Jordan Furr on 4/3/20.
//  Copyright © 2020 Jordan Furr. All rights reserved.
//

import UIKit

class ContactListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ContactController.shared.fetchContacts { (result) in
            self.updateViews()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContactController.shared.contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)

        let contact = ContactController.shared.contacts[indexPath.row]
        cell.textLabel?.text = contact.name
        cell.detailTextLabel?.text = contact.number ?? ""

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             let contactToDelete = ContactController.shared.contacts[indexPath.row]
             guard let index = ContactController.shared.contacts.firstIndex(of: contactToDelete) else { return }
            ContactController.shared.delete(contact: contactToDelete) { (result) in
                 switch result {
                 case .success(let success):
                     if success {
                         ContactController.shared.contacts.remove(at: index)
                         DispatchQueue.main.async {
                             tableView.deleteRows(at: [indexPath], with: .fade)
                         }
                     }
                 case .failure(let error):
                     print(error.errorDescription)
                 }
             }
         }
     }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                let destinationVC = segue.destination as? ContactDetailViewController else {return}
            let contactPoint = ContactController.shared.contacts[indexPath.row]
            destinationVC.contact = contactPoint
        }
    }
    

}
