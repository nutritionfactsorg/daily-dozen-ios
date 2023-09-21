//
//  Thread.swift
//  DailyDozen
//
//  Copyright © 2023 Nutritionfacts.org. All rights reserved.
//

import Foundation

extension Thread {
    
    var info: String {
        return """
        --- Thread Info ---
               queue name: \(self.infoQueueName)
              thread name: \(self.infoThreadName)
          thread priority: \(self.threadPriority)
        """
    }
    
    /// `OperationQueue` name
    var infoQueueName: String {
        if let queueName = String(validatingUTF8: __dispatch_queue_get_label(nil)) {
            return queueName
        } else if let operationQueueName = OperationQueue.current?.name, !operationQueueName.isEmpty {
            return operationQueueName
        } else if let dispatchQueueName = OperationQueue.current?.underlyingQueue?.label, !dispatchQueueName.isEmpty {
            return dispatchQueueName
        } else {
            return "-none-"
        }
    }
    
    /// `Thread` name
    var infoThreadName: String {
        if isMainThread {
            return "main"
        } else if let threadName = Thread.current.name, !threadName.isEmpty {
            return threadName
        } else {
            return description
        }
    }
    
}
