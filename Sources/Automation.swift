//
//  Automation.swift
//  Automation
//
//  Created by Duc IT. Nguyen Minh on 17/03/2022.
//

import UIKit
#if canImport(Logger)
import Logger
#endif
public struct Automation {
    public static var delayTime: TimeInterval = 0.5
}

extension UIButton: Tappable {
    public func tap() {
        self.sendActions(for: .touchUpInside)
#if canImport(Logger)
        Logger.default.info("Tapped button \(identifier() ?? "Empty")")
#endif
    }
    
    @objc public override func identifier() -> String? {
        title(for: .normal)
    }
}

extension UIView: Searchable, PropertyReflectable, AutomationComponent {
    public func find(identifier: String) -> UIView? {
#if canImport(Logger)
        Logger.default.debug("Identifier: \(self.identifier() ?? "Empty")")
#endif
        if self.identifier()?.lowercased().contains(identifier.lowercased()) ?? false {
            return self
        }
        for subview in subviews {
#if canImport(Logger)
            Logger.default.verbose("Component type: \(type(of: subview))")
#endif
            if let found = subview.find(identifier: identifier) {
#if canImport(Logger)
                Logger.default.verbose("found")
#endif
                return found
            }
        }
        return nil
    }
    
    public func find(searchAssist: (Searchable) -> Bool) -> UIView? {
        if searchAssist(self) { return self }
        for subview in subviews {
#if canImport(Logger)
            Logger.default.verbose("Component type: \(type(of: subview))")
#endif
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
#if canImport(Logger)
            Logger.default.warning("Orphan collection view cell")
#endif
            return
        }
#if canImport(Logger)
        Logger.default.debug("Selecting cell")
#endif
        collectionView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: index)
        })
    }
}

extension UITableViewCell: Tappable {
    public func tap() {
        guard let table = interactableComponents(kind: UITableView.self), let index = table.indexPath(for: self) else {
#if canImport(Logger)
            Logger.default.warning("Orphan table view cell")
#endif
            return
        }
#if canImport(Logger)
        Logger.default.debug("Selecting cell")
#endif
        table.selectRow(at: index, animated: false, scrollPosition: .none)
        table.delegate?.tableView?(table, didSelectRowAt: index)
    }
}
