# Moya 15.1.0 (Lightweight Fork)

[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

A lightweight fork of [Moya](https://github.com/Moya/Moya) with native async/await support and minimal dependencies.

## What Changed from Upstream

- **Added native async/await** with proper Task cancellation support
- **Removed RxSwift & ReactiveSwift** — only Alamofire remains as a dependency
- **Removed dev dependencies** — consumers no longer fetch Quick, Nimble, OHHTTPStubs, or Rocket
- **Updated platforms** to iOS 18 / macOS 15 / tvOS 18 / watchOS 11
- **Updated swift-tools-version** to 6.0

### Dependency Comparison

| | Upstream Moya | This Fork |
|---|---|---|
| Packages fetched | 13 | 2 (Moya + Alamofire) |
| Sub-dependencies | RxSwift, ReactiveSwift, Quick, Nimble, + 8 more | None |

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
.package(url: "https://github.com/SwifAI/Moya.git", from: "15.1.0")
```

Or in Xcode: File → Add Package Dependencies → `https://github.com/SwifAI/Moya.git`

## Usage

### Async/Await (New)

```swift
let provider = MoyaProvider<MyAPI>()

// Simple request
let response = try await provider.request(.getUser(id: 1))
let user = try response.map(User.self)

// With progress (uploads/downloads)
for try await progress in provider.requestWithProgress(.uploadFile(data)) {
    if let response = progress.response {
        // Request completed
    } else {
        print("Progress: \(progress.progress)")
    }
}
```

Task cancellation is fully supported — cancelling a Task cancels the underlying network request.

### Callback-based (Original)

```swift
provider.request(.getUser(id: 1)) { result in
    switch result {
    case .success(let response):
        let user = try? response.map(User.self)
    case .failure(let error):
        print(error)
    }
}
```

### Combine

CombineMoya is still available:

```swift
provider.requestPublisher(.getUser(id: 1))
    .sink(receiveCompletion: { _ in }, receiveValue: { response in
        // handle response
    })
```

## Features

Everything from Moya still works:

- **TargetType** — define API endpoints as Swift enums
- **Plugins** — logging, auth tokens, credentials, network activity
- **Stubbing** — mock responses for testing
- **Alamofire** — SSL pinning, retry, interceptors, session management

## Syncing with Upstream

This is a proper GitHub fork. To pull upstream fixes:

```bash
git fetch upstream
git merge upstream/master
```

## License

Moya is released under an MIT license. See [License.md](License.md) for more information.
