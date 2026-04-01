import Foundation

// MARK: - Async/Await Support

/// Thread-safe box for holding a Cancellable reference across concurrency domains.
private final class CancellableBox: @unchecked Sendable {
    private let lock = NSLock()
    private var _cancellable: Cancellable?

    var cancellable: Cancellable? {
        get { lock.lock(); defer { lock.unlock() }; return _cancellable }
        set { lock.lock(); defer { lock.unlock() }; _cancellable = newValue }
    }

    func cancel() { cancellable?.cancel() }
}

public extension MoyaProvider {

    /// Performs a request and returns the response asynchronously.
    ///
    ///     let response = try await provider.request(.getUser(id: 1))
    ///     let user = try response.map(User.self)
    ///
    /// Supports Task cancellation — cancelling the Task cancels the underlying network request.
    func request(_ target: Target, callbackQueue: DispatchQueue? = .none) async throws -> Response {
        let box = CancellableBox()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                box.cancellable = self.request(target, callbackQueue: callbackQueue, progress: nil) { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        } onCancel: {
            box.cancel()
        }
    }

    /// Performs a request and delivers progress updates through an `AsyncThrowingStream`.
    ///
    ///     for try await progress in provider.requestWithProgress(.uploadFile(data)) {
    ///         if let response = progress.response {
    ///             // Request completed
    ///         } else {
    ///             print("Progress: \(progress.progress)")
    ///         }
    ///     }
    ///
    /// Errors are thrown through the stream. Supports Task cancellation.
    func requestWithProgress(_ target: Target, callbackQueue: DispatchQueue? = .none) -> AsyncThrowingStream<ProgressResponse, Error> {
        AsyncThrowingStream { continuation in
            let cancellable = self.request(target, callbackQueue: callbackQueue, progress: { progress in
                continuation.yield(progress)
            }) { result in
                switch result {
                case .success(let response):
                    continuation.yield(ProgressResponse(response: response))
                    continuation.finish()
                case .failure(let error):
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { @Sendable _ in
                cancellable.cancel()
            }
        }
    }
}
