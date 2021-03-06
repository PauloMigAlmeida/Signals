import Foundation

public func take<T, E>(count: Int)(signal: Signal<T, E>) -> Signal<T, E> {
    return Signal { subscriber in
        let counter = Atomic(value: 0)
        return signal.start(next: { next in
            var passthrough = false
            var complete = false
            counter.modify { value in
                let updatedCount = value + 1
                passthrough = updatedCount <= count
                complete = updatedCount == count
                return updatedCount
            }
            if passthrough {
                subscriber.putNext(next)
            }
            if complete {
                subscriber.putCompletion()
            }
        }, error: { error in
            subscriber.putError(error)
        }, completed: {
            subscriber.putCompletion()
        })
    }
}
