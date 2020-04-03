//
//  ContactController.swift
//  contacts-cloudkit
//
//  Created by Jordan Furr on 4/3/20.
//  Copyright © 2020 Jordan Furr. All rights reserved.
//

import Foundation
import CloudKit

class ContactController {
    
    //singleton
    static let shared = ContactController()
    
    //source of truth
    var contacts: [Contact] = []
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    //MARK: - CRUD
    
    //create contact and use save function to save contact to cloudkit
    func createContact(with name: String, number: String, email: String, completion: @escaping (Result<Contact?, ContactError>) ->Void){
        let newcontact = Contact(name: name, number: number, email: email)
        save(contact: newcontact, completion: completion)
    }
    
    func save(contact: Contact, completion: @escaping (Result<Contact?, ContactError>) -> Void){
        //init ckrecord from contact object
        let contactRecord = CKRecord(contact: contact)
        privateDB.save(contactRecord) { (record, error) in
            
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
                return
            }
            
            //check and unwrap ckrecord that was saved adn recreate contact object
            guard let record = record,
            let savedContact = Contact(ckRecord: record)
                else { completion(.failure(.couldNotUnwrap)); return}
            print("new contact saved")
            self.contacts.insert(savedContact, at: 0)
            completion(.success(savedContact))
        }
    }
    
    func update(contact: Contact, completion: @escaping (Result<Contact?, ContactError>) -> Void) {
        //create record to save
        let record = CKRecord(contact: contact)
        //create operation
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        //properties for operation
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInitiated
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = records?.first,
            let contact = Contact(ckRecord: record)
                else {return completion(.failure(.couldNotUnwrap)) }
            print(("Updated \(record.recordID.recordName) successfully in CloudKit"))
                completion(.success(contact))
        }
        privateDB.add(operation)
    }
    
    func delete(contact: Contact, completion: @escaping (Result<Bool, ContactError>) -> Void) {
        
        //create operation
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [contact.ckRecordID])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            if records?.count == 0 {
                print("Deleted record from CloudKit")
                completion(.success(true))
            } else {
                return completion(.failure(.unexpectedRecords))
            }
        }
        privateDB.add(operation)
    }
    
    func fetchContacts(completion: @escaping (Result<[Contact], ContactError>) -> Void) {
        //predicate for cloudkit query
        let contactPredicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ContactConstants.recordTypeKey, predicate: contactPredicate)
        
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
            }
            
            guard let records = records else { completion(.failure(.couldNotUnwrap)); return}
            print("successfully fetched contacts")
            //map through all records and transform them with Contact(ckRecord: ) convenience init to transform them into contact objects
            let contacts = records.compactMap({Contact(ckRecord: $0) })
            self.contacts = contacts
            completion(.success(contacts))
        }
    }
}
