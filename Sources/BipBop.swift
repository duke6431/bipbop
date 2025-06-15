//
//  BipBop.swift
//  BipBop
//
//  Created by Duc IT. Nguyen Minh on 17/03/2022.
//

import UIKit
import Logging

public struct BipBop {
    public static var enableLogging: Bool = false
    public static var delayTime: TimeInterval = 0.5
    public static let logger = Logger(label: "BipBopAutomation")
}

extension UIButton: Tappable {
    public func tap() {
        self.sendActions(for: .touchUpInside)
        if BipBop.enableLogging {
            BipBop.logger.info("Tapped button \(identifier() ?? "Empty")")
        }
    }
    
    @objc public override func identifier() -> String? {
        title(for: .normal)
    }
}

extension UIView: Searchable, PropertyReflectable, AutomationComponent {
    public func find(identifier: String) -> UIView? {
        if BipBop.enableLogging {
            BipBop.logger.trace("Identifier: \(self.identifier() ?? "Empty")")
        }
        if self.identifier()?.lowercased().contains(identifier.lowercased()) ?? false {
            return self
        }
        for subview in subviews {
            if BipBop.enableLogging {
                BipBop.logger.trace("Component type: \(type(of: subview))")
            }
            if let found = subview.find(identifier: identifier) {
                if BipBop.enableLogging {
                    BipBop.logger.trace("found")
                }
                return found
            }
        }
        return nil
    }
    
    public func find(searchAssist: (Searchable) -> Bool) -> UIView? {
        if searchAssist(self) { return self }
        for subview in subviews {
            if BipBop.enableLogging {
                BipBop.logger.trace("Component type: \(type(of: subview))")
            }
            if let view = subview.find(searchAssist: searchAssist) {
                return view
            }
        }
        return nil
    }
    
    public func identifier() -> String? {
        (self["text"] as? String)
    }
    
    public func interactableComponents<K>(kind: K.Type) -> K? where K : UIView {
        guard let superview = superview as? K else {
            return superview?.interactableComponents(kind: kind)
        }
        return superview
    }
}

extension UILabel {
    public override func identifier() -> String? {
        return text
    }
}

extension UITextField: Typable {
    public override func identifier() -> String? {
        placeholder
    }
    
    public func placeholder() -> String? {
        (self["placeholder"] as? String)
    }
    
    public func text() -> String? {
        (self["text"] as? String)
    }
    
    public func type(_ text: String) {
        self.insertText(text)
    }
}

extension UICollectionViewCell: Tappable {
    public func tap() {
        guard let collectionView = interactableComponents(kind: UICollectionView.self), let index = collectionView.indexPath(for: self) else {
            if BipBop.enableLogging {
                BipBop.logger.warning("Orphan collection view cell")
            }
            return
        }
        if BipBop.enableLogging {
            BipBop.logger.trace("Selecting cell")
        }
        collectionView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: index)
        })
    }
}

extension UITableViewCell: Tappable {
    public func tap() {
        guard let table = interactableComponents(kind: UITableView.self), let index = table.indexPath(for: self) else {
            if BipBop.enableLogging {
                BipBop.logger.warning("Orphan table view cell")
            }
            return
        }
        if BipBop.enableLogging {
            BipBop.logger.trace("Selecting cell")
        }
        table.selectRow(at: index, animated: false, scrollPosition: .none)
        table.delegate?.tableView?(table, didSelectRowAt: index)
    }
}
