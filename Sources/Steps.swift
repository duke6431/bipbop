//
//  Steps.swift
//  BipBop
//
//  Created by Duc Minh Nguyen on 5/2/22.
//

import UIKit

public class WaitComponent: AutomationComponent {
    public func interactableComponents<K>(kind: K.Type) -> K? where K : UIView {
        return UIView() as? K
    }
}

public class FreeExecutionComponent: WaitComponent { }

public struct Step<T>: Executable where T: AutomationComponent {
    public enum Action {
        case searchAndExec(String? = nil, ((T) -> Bool)? = nil, (T) -> Void)
        case wait(TimeInterval)
        case freeExec(() -> Void)
    }
    var action: Action
    var retries: UInt8
    
    public init(action: Action, retries: UInt8 = 3) {
        self.action = action
        self.retries = retries
    }
    
    public func execute() throws {
        var retries: UInt8 = 0
        switch action {
        case .searchAndExec(let identifier, let searchAssist, let executable):
            guard let rootView = UIViewController.topMostViewController()?.view else {
                throw BipBop.ComponentError.rootViewNotFound
            }
            if let identifier = identifier {
                repeat {
                    if BipBop.enableLogging {
                        BipBop.logger.warning("Attempt number \(retries + 1)")
                    }
                    if retries >= self.retries {
                        throw BipBop.ComponentError.componentNotFound(name: identifier)
                    }
                    if let view = rootView.find(identifier: identifier) as? T {
                        executable(view)
                        break
                    } else {
                        if BipBop.enableLogging {
                            BipBop.logger.warning("\(BipBop.ComponentError.componentNotFound(name: identifier).localizedDescription)Retrying...")
                        }
                        retries += 1
                        Thread.sleep(forTimeInterval: 2)
                    }
                } while(true)
            } else if let searchAssist = searchAssist {
                repeat {
                    if BipBop.enableLogging {
                        BipBop.logger.warning("Attempt number \(retries + 1)")
                    }
                    if retries >= self.retries {
                        throw BipBop.ComponentError.componentNotFound(name: "search assist criteria")
                    }
                    if let view = rootView.find(searchAssist: { (component: Searchable) -> Bool in
                        guard let component = component as? T else {
                            return false
                        }
                        return searchAssist(component)
                    }) as? T {
                        executable(view)
                        break
                    } else {
                        if BipBop.enableLogging {
                            BipBop.logger.error("\(BipBop.ComponentError.componentNotFound(name: "search assist criteria").localizedDescription)Retrying...")
                        }
                        retries += 1
                        Thread.sleep(forTimeInterval: 2)
                    }
                } while(true)
            } else {
                throw BipBop.ComponentError.searchMethodNotProvided
            }
        case .wait(let timeInSeconds):
            if BipBop.enableLogging {
                BipBop.logger.trace("Sleeping for \(timeInSeconds) second(s)")
            }
            Thread.sleep(forTimeInterval: timeInSeconds)
        case .freeExec(let execution):
            execution()
        }
    }
}

public class StepGroup: Executable {
    public lazy private(set) var identifier: String = UUID().uuidString
    public let name: String
    public var completion: ((Bool) -> Void)?
    public var steps: [Executable] = [] { didSet { reloadStep() } }
    var alignedStep: [Executable] {
        var executables = [Executable]()
        steps.forEach {
            if let group = $0 as? StepGroup {
                executables.append(contentsOf: group.alignedStep)
            } else {
                executables.append($0)
            }
        }
        return executables
    }
    
    private lazy var stackableOperationsQueue: StackableOperationsConcurrentQueue = {
        let queue = DispatchQueue(label: "custom_queue", qos: .background,
                                  attributes: [.concurrent], autoreleaseFrequency: .workItem, target: nil)
        return StackableOperationsConcurrentQueue(queue: queue)
    }()
    
    public init(name: String, steps: [Executable] = [], completion: ((Bool) -> Void)? = nil) {
        self.name = name
        self.steps = steps
        self.completion = completion
        reloadStep()
    }
    
    private func add(isWait: Bool, closure: (() -> Void)?) {
        let operation = SerialQueueOperation(waitOperation: isWait, actualIfNotNil: self) { closure?() }
        stackableOperationsQueue.append(operation: operation)
    }
    
    public func execute() {
        if BipBop.enableLogging {
            BipBop.logger.trace("Executing group \(name)")
        }
        stackableOperationsQueue.execute()
    }
    
    private func reloadStep() {
        stackableOperationsQueue.clear()
        alignedStep.forEach { step in
            if case .wait = (step as? Step<WaitComponent>)?.action {
                add(isWait: true) { [weak self] in
                    do {
                        try step.execute()
                    } catch {
                        if BipBop.enableLogging {
                            BipBop.logger.error("\(error.localizedDescription)")
                        }
                        self?.stackableOperationsQueue.haltExecution = true
                    }
                }
            } else {
                add(isWait: false, closure: { [weak self] in
                    do {
                        try step.execute()
                    } catch {
                        if BipBop.enableLogging {
                            BipBop.logger.error("\(error.localizedDescription)")
                        }
                        self?.stackableOperationsQueue.haltExecution = true
                    }
                })
            }
        }
        self.stackableOperationsQueue.completion = completion
    }
}
