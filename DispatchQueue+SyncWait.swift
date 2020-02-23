//
//  Created by Song, Yue on 2020/2/22.
//  Copyright © 2020 StubHub. All rights reserved.
//

import Foundation

extension DispatchQueue {
    public func syncWait<T>(execute work: @escaping () -> T, timeOut t:DispatchTime, onTimeOut callback: () -> () ) -> T? {
        let sem = DispatchSemaphore(value: 0)
        var result: T? = nil

        self.async {
            result = work()
            sem.signal()
        }

        //Spurious wakeup handled in GCD: "src/shims/lock.c" in https://github.com/apple/swift-corelibs-libdispatch
        let waitResult = sem.wait(timeout: t)
        if waitResult == DispatchTimeoutResult.timedOut {
            callback()
        }
        return result
    }

    public static func syncWaitToMainQueue<T>(execute work: @escaping () -> T, timeOut t:DispatchTime, onTimeOut callback: () -> () ) -> T? {
        if Thread.isMainThread {
            return work()
        } else {
            return self.main.syncWait(execute: work, timeOut: t, onTimeOut: callback)
        }
    }
}
