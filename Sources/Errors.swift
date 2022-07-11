//
//  Error.swift
//  Automation
//
//  Created by Duc Minh Nguyen on 5/2/22.
//

import Foundation

extension Automation {
    public enum ComponentError: Error {
        case componentNotFound(name: String)
        case rootViewNotFound
        case searchMethodNotProvided
    }
}

extension Automation.ComponentError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .componentNotFound(let name):
            return "Component with \(name) cannot be found!"
        case .rootViewNotFound:
            return "Root view cannot be found!"
        case .searchMethodNotProvided:
            return "Search method is not provided!"
        }
    }
}
