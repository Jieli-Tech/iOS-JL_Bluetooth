//
//  JLEcObserver.swift
//  JLUsefulTools
//
//  Created by EzioChan on 2021/8/31.
//

import Foundation

public protocol AnyObserver: AnyObject {
    func remove()
}

public struct ObserverOptions: OptionSet {
    public typealias RawValue = Int
    public var rawValue: Int
    public static let Coalescing = ObserverOptions(rawValue: 1)
    public static let FireSynchronously = ObserverOptions(rawValue: 1 << 1)
    public static let FireImmediately = ObserverOptions(rawValue: 1 << 2)
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

// MARK: Observer

public class Observer<Value> {
    public typealias ActionType = (_ oldValue: Value, _ newValue: Value) -> Void
    let action: ActionType
    let queue: OperationQueue
    let options: ObserverOptions
    fileprivate var coalescedOldValue: Value?
    fileprivate var fireCount = 0
    fileprivate weak var observable: Observable<Value>?

    public init(queue: OperationQueue = OperationQueue.main,
                options: ObserverOptions = [.Coalescing],
                action: @escaping ActionType)
    {
        self.action = action
        self.queue = queue

        var optionsCopy = options
        if optionsCopy.contains(ObserverOptions.FireSynchronously) {
            optionsCopy.remove(.Coalescing)
        }
        self.options = optionsCopy
    }

    public func fire(_ oldValue: Value, newValue: Value) {
        fireCount += 1
        let count = fireCount
        if options.contains(.Coalescing), coalescedOldValue == nil {
            coalescedOldValue = oldValue
        }

        let operation = BlockOperation(block: { () in
            if self.options.contains(.Coalescing) {
                guard count == self.fireCount else { return }
                self.action(self.coalescedOldValue ?? oldValue, newValue)
                self.coalescedOldValue = nil
            } else {
                self.action(oldValue, newValue)
            }
        })
        queue.addOperations([operation], waitUntilFinished: options.contains(.FireSynchronously))
    }
}

extension Observer: AnyObserver {
    public func remove() {
        observable?.removeObserver(self)
    }
}

public protocol ObservableType {
    associatedtype ValueType
    var value: ValueType { get }
    func addObserver(_ observer: Observer<ValueType>)
    func removeObserver(_ observer: Observer<ValueType>)
}

public extension ObservableType {
    @discardableResult func onSet(_ options: ObserverOptions = [.Coalescing],
                                  action: @escaping (ValueType, ValueType) -> Void) -> Observer<ValueType>
    {
        let observer = Observer<ValueType>(options: options, action: action)
        addObserver(observer)
        return observer
    }
}

public class Observable<Value> {
    public var value: Value {
        didSet {
            privateQueue.async {
                for observer in self.observers {
                    observer.fire(oldValue, newValue: self.value)
                }
            }
        }
    }

    fileprivate let privateQueue = DispatchQueue(label: "Observable Global Queue", attributes: [])
    fileprivate var observers: [Observer<Value>] = []
    public init(_ value: Value) {
        self.value = value
    }
}

extension Observable: ObservableType {
    public typealias ValueType = Value
    public func addObserver(_ observer: Observer<ValueType>) {
        privateQueue.sync {
            self.observers.append(observer)
        }
        if observer.options.contains(.FireImmediately) {
            observer.fire(value, newValue: value)
        }
    }

    public func removeObserver(_ observer: Observer<ValueType>) {
        privateQueue.sync {
            guard let index = self.observers.firstIndex(where: { observer === $0 }) else { return }
            self.observers.remove(at: index)
        }
    }
}
