//
//  ContactError.swift
//  contacts-cloudkit
//
//  Created by Jordan Furr on 4/3/20.
//  Copyright © 2020 Jordan Furr. All rights reserved.
//

import Foundation

enum ContactError: LocalizedError {
    case ckError(Error)
    case couldNotUnwrap
    case unexpectedRecords
}
