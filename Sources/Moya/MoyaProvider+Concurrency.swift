import Foundation

// MARK: - Async/Await Support

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension MoyaProvider {

    /// Performs a request and returns the response asynchronously.
    ///
    ///     let response = try await provider.request(.getUser(id: 1))
    ///     let user = try response.map(User.self)
    ///
    func request(_ target: Target, callbackQueue: DispatchQueue? = .none) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            self.request(target, callbackQueue: callbackQueue, progress: nil) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Performs a request and delivers progress updates through an `AsyncStream`.
    ///
    ///     for await progress in provider.requestWithProgress(.uploadFile(data)) {
    ///         if let response = progress.response {
    ///             // Request completed
    ///         } else {
    ///             print("Progress: \(progress.progress)")
    ///         }
    ///     }
    ///
    func requestWithProgress(_ target: Target, callbackQueue: DispatchQueue? = .none) -> AsyncStream<ProgressResponse> {
        AsyncStream { continuation in
            let cancellable = self.request(target, callbackQueue: callbackQueue, progress: { progress in
                continuation.yield(progress)
            }) { result in
                switch result {
                case .success(let response):
                    continuation.yield(ProgressResponse(response: response))
                case .failure:
                    break
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}
