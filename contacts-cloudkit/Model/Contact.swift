//
//  Contact.swift
//  contacts-cloudkit
//
//  Created by Jordan Furr on 4/3/20.
//  Copyright © 2020 Jordan Furr. All rights reserved.
//

import Foundation
import CloudKit

//MARK: - Magic Strings struct

/**
 Creating a struct named ContactConstants containing the String values for keys used when setting the values for a CKRecord.
 */
struct ContactConstants {
    static let nameKey = "name"
    static let numberKey = "number"
    static let emailKey = "email"
    static let recordTypeKey = "Contact"
}

//MARK: - Class Declaration
class Contact {
    
    let name: String
    let number: String
    let email: String
    let ckRecordID: CKRecord.ID
    
    
    init(name: String, number: String, email: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.number = number
        self.email = email
        self.ckRecordID = ckRecordID
    }
}

// Convenience init to create CKRecord from Contact object
extension CKRecord {
   
    convenience init(contact: Contact) {
        self.init(recordType: ContactConstants.recordTypeKey, recordID: contact.ckRecordID)
        self.setValuesForKeys ([
            ContactConstants.nameKey : contact.name,
            ContactConstants.numberKey : contact.number,
            ContactConstants.emailKey : contact.email
        ])
    }
}

//Failable convenience init to init contact stored in cloudkit
extension Contact {
    
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[ContactConstants.nameKey] as? String,
            let number = ckRecord[ContactConstants.numberKey] as? String,
            let email = ckRecord[ContactConstants.emailKey] as? String
            else {return nil}
        
        self.init(name: name, number: number, email: email)
    }
}
