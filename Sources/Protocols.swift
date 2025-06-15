//
//  Protocols.swift
//  BipBop
//
//  Created by Duc Minh Nguyen on 5/2/22.
//

import UIKit

public protocol Executable {
    func execute() throws
}

public protocol Tappable {
    func tap()
}

@objc public protocol Searchable {
    func find(searchAssist: (Searchable) -> Bool) -> UIView?
    func find(identifier: String) -> UIView?
    @objc func identifier() -> String?
}

public protocol Typable {
    func placeholder() -> String?
    func text() -> String?
    func type(_ text: String)
}

public protocol AutomationComponent {
    func interactableComponents<K: UIView>(kind: K.Type) -> K?
}

protocol PropertyReflectable { }

extension PropertyReflectable {
    subscript(key: String) -> Any? {
        let m = Mirror(reflecting: self)
        for child in m.children {
            if child.label == key { return child.value }
        }
        return nil
    }
}
