//
//  Operation.swift
//  Automation
//
//  Created by Duc IT. Nguyen Minh on 17/03/2022.
//

import Foundation
#if canImport(Logger)
import Logger
#endif
class StackableOperationsQueue {
    private let executionQueue = DispatchQueue(label: "custom_queue_\(UUID().uuidString)", qos: .background,
                                               attributes: [.concurrent], autoreleaseFrequency: .workItem, target: nil)
    private let semaphore = DispatchSemaphore(value: 1)
    private lazy var operations = [QueueOperation]()
    private lazy var isExecuting = false
    lazy var haltExecution = false
    var completion: ((Bool) -> Void)?
    public var delayTime: TimeInterval = Automation.delayTime
    
    fileprivate func _append(operation: QueueOperation) {
        semaphore.wait()
        operations.append(operation)
#if canImport(Logger)
        Logger.default.debug("Operation added")
#endif
        semaphore.signal()
    }
    
    func append(operation: QueueOperation) { _append(operation: operation) }
    func clear() {
        semaphore.wait()
        operations = []
#if canImport(Logger)
        Logger.default.debug("Operation cleared")
#endif
        semaphore.signal()
    }
    
    func execute() {
        executionQueue.async { [weak self] in self?._execute() }
    }
    
    func _execute() {
        guard !haltExecution else {
#if canImport(Logger)
            Logger.default.warning("Stopping automate execution")
#endif
            completion?(false)
            return
        }
        semaphore.wait()
        guard !operations.isEmpty, !isExecuting else {
#if canImport(Logger)
            Logger.default.debug("Operation is empty or is executing")
            Logger.default.debug("Operation count: \(operations.count)")
            Logger.default.debug("Executing: \(isExecuting)")
#endif
            if operations.isEmpty { completion?(true) }
            semaphore.signal()
            return
        }
        let operation = operations.removeFirst()
        isExecuting = true
        semaphore.signal()
#if canImport(Logger)
        Logger.default.debug("Running on main thread: \(Thread.isMainThread)")
#endif
        if operation.waitOperation {
            operation.perform()
        } else {
            DispatchQueue.main.async {
                operation.perform()
            }
        }
#if canImport(Logger)
        Logger.default.debug("Performing call")
#endif
        semaphore.wait()
        isExecuting = false
        if delayTime > 0 {
            Thread.sleep(forTimeInterval: delayTime)
        }
        semaphore.signal()
        executionQueue.async { [weak self] in
            self?._execute()
        }
    }
}

// MARK: - StackableOperationsCuncurentQueue performs functions from the stack one by one (serial performing) but in cuncurent queue

class StackableOperationsConcurentQueue: StackableOperationsQueue {
    private var queue: DispatchQueue
    init(queue: DispatchQueue) { self.queue = queue }
    override func append(operation: QueueOperation) {
        queue.async { [weak self] in self?._append(operation: operation) }
    }
}

// MARK: QueueOperation interface

protocol QueueOperation: AnyObject {
    var сlosure: (() -> Void)? { get }
    var waitOperation: Bool { get }
    var actualityCheckingClosure: (() -> Bool)? { get }
    init(waitOperation: Bool, actualityCheckingClosure: (() -> Bool)?, serialClosure: (() -> Void)?)
    func perform()
}

extension QueueOperation {
    // MARK: - Can queue perform the operation `сlosure: (() -> Void)?` or not
    var isActual: Bool {
        guard   let actualityCheckingClosure = self.actualityCheckingClosure,
                self.сlosure != nil else { return false }
        return actualityCheckingClosure()
    }
    func perform() { if isActual { сlosure?() } }
    
    init(waitOperation: Bool = false, actualIfNotNil object: AnyObject?, serialClosure: (() -> Void)?) {
        self.init(waitOperation: waitOperation, actualityCheckingClosure: { return object != nil }, serialClosure: serialClosure)
    }
}

class SerialQueueOperation: QueueOperation {
    let сlosure: (() -> Void)?
    let waitOperation: Bool
    let actualityCheckingClosure: (() -> Bool)?
    required init(waitOperation: Bool = false, actualityCheckingClosure: (() -> Bool)?, serialClosure: (() -> Void)?) {
        self.waitOperation = waitOperation
        self.actualityCheckingClosure = actualityCheckingClosure
        self.сlosure = serialClosure
    }
}
