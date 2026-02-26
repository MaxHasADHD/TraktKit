# SwiftAPIClient: Automatic Token Refresh Feature

## Objective
Add support for automatic OAuth token refresh when tokens are about to expire or when 401 Unauthorized errors occur. This should work for any OAuth2 API.

## Overview
Implement a flexible, opt-in token refresh mechanism that supports both proactive refresh (before expiration) and reactive refresh (after 401 errors). This feature should be completely backward compatible with existing implementations.

---

## 1. Add Token Refresh Protocol

Create a new protocol that client implementations can conform to:

```swift
/// Protocol for handling OAuth token refresh
public protocol TokenRefreshHandler: Sendable {
    /// Called when tokens need to be refreshed
    /// - Parameter currentState: The current authentication state containing the refresh token
    /// - Returns: New authentication state with fresh access token
    /// - Throws: If token refresh fails
    func refreshToken(currentState: AuthenticationState) async throws -> AuthenticationState
}
```

**File:** Add to `APIAuthentication.swift` or create new `TokenRefreshHandler.swift`

---

## 2. Extend APIClient.Configuration

Add two new properties to the `Configuration` struct:

```swift
public struct Configuration: Sendable {
    // ... existing fields ...

    /// Time buffer before token expiration to trigger proactive refresh (in seconds)
    /// Default: 3600 (1 hour). Set to 0 to disable proactive refresh.
    public let tokenRefreshBuffer: TimeInterval

    /// Handler for refreshing tokens when they expire
    /// Set to nil to disable automatic token refresh (default)
    public let tokenRefreshHandler: (any TokenRefreshHandler)?

    public init(
        baseURL: URL,
        additionalHeaders: [String: String] = [:],
        paginationPageHeader: String = "x-pagination-page",
        paginationPageCountHeader: String = "x-pagination-page-count",
        responseHandler: any ResponseHandler = DefaultResponseHandler(),
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .custom(customDateDecodingStrategy),
        tokenRefreshBuffer: TimeInterval = 3600,
        tokenRefreshHandler: (any TokenRefreshHandler)? = nil
    ) {
        self.baseURL = baseURL
        self.additionalHeaders = additionalHeaders
        self.paginationPageHeader = paginationPageHeader
        self.paginationPageCountHeader = paginationPageCountHeader
        self.responseHandler = responseHandler
        self.dateDecodingStrategy = dateDecodingStrategy
        self.tokenRefreshBuffer = tokenRefreshBuffer
        self.tokenRefreshHandler = tokenRefreshHandler
    }
}
```

**File:** `APIClient.swift` (Configuration struct)

---

## 3. Add Helper Methods to APIClient

Add these private helper methods to the `APIClient` class:

```swift
/// Check if the current token expires within the configured buffer window
private func shouldRefreshToken() -> Bool {
    guard configuration.tokenRefreshBuffer > 0 else {
        return false
    }

    guard let expirationDate = cachedAuthState?.expirationDate else {
        return false
    }

    let bufferDate = Date().addingTimeInterval(configuration.tokenRefreshBuffer)
    return expirationDate < bufferDate
}

/// Perform token refresh using the configured handler
private func performTokenRefresh(using handler: any TokenRefreshHandler) async throws {
    guard let currentState = cachedAuthState else {
        throw AuthenticationError.noStoredCredentials
    }

    Self.logger.info("Refreshing authentication token")
    let newState = try await handler.refreshToken(currentState: currentState)

    // Update cached state
    authStateLock.withLock {
        cachedAuthState = newState
    }

    // Update storage
    if let authStorage {
        await authStorage.updateState(newState)
    }

    Self.logger.info("Token refresh completed successfully")
}
```

**File:** `APIClient.swift` (private methods section)

---

## 4. Modify fetchData() Method

Update the existing `fetchData()` method to implement both proactive and reactive token refresh:

```swift
public func fetchData(request: URLRequest, retryLimit: Int = 3) async throws -> (Data, URLResponse) {
    // PROACTIVE REFRESH: Check if token needs refresh before making request
    if let handler = configuration.tokenRefreshHandler,
       shouldRefreshToken() {
        Self.logger.info("Token expiring soon, proactively refreshing")
        try await performTokenRefresh(using: handler)
    }

    var retryCount = 0

    while true {
        do {
            let (data, response) = try await session.data(for: request)
            try handleResponse(response: response)
            return (data, response)
        } catch let error as APIError {
            // Handle APIError retry logic
            switch error {
            case .retry(let retryDelay):
                // Existing retry logic
                retryCount += 1
                if retryCount >= retryLimit {
                    throw error
                }
                Self.logger.info("Retrying after delay: \(retryDelay)")
                try await Task.sleep(for: .seconds(retryDelay))
                try Task.checkCancellation()

            case .unauthorized:
                // REACTIVE REFRESH: Handle 401 errors
                guard let handler = configuration.tokenRefreshHandler else {
                    // No handler configured, throw error
                    throw error
                }

                Self.logger.warning("Received 401 Unauthorized, attempting reactive token refresh")
                try await performTokenRefresh(using: handler)

                // Rebuild request with new token
                var newRequest = request
                if let accessToken = cachedAuthState?.accessToken {
                    newRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                } else {
                    throw AuthenticationError.noStoredCredentials
                }

                // Retry the request once with new token
                // Don't catch 401 again to avoid infinite loops
                Self.logger.info("Retrying request with refreshed token")
                let (data, response) = try await session.data(for: newRequest)
                try handleResponse(response: response)
                return (data, response)

            default:
                throw error
            }
        } catch {
            // For non-APIError types (custom errors from ResponseHandler), throw immediately
            throw error
        }
    }
}
```

**File:** `APIClient.swift` (replace existing `fetchData()` method)

---

## 5. Thread Safety Considerations

### Race Condition Prevention
When multiple requests occur simultaneously and all detect expired tokens, we should only refresh once. Consider adding:

```swift
// Add to APIClient properties:
private let refreshLock = NSLock()
nonisolated(unsafe)
private var isRefreshing = false

// Modify performTokenRefresh():
private func performTokenRefresh(using handler: any TokenRefreshHandler) async throws {
    // Check if already refreshing
    refreshLock.lock()
    if isRefreshing {
        refreshLock.unlock()
        // Wait a bit and assume refresh will complete
        try await Task.sleep(for: .seconds(0.5))
        return
    }
    isRefreshing = true
    refreshLock.unlock()

    defer {
        refreshLock.lock()
        isRefreshing = false
        refreshLock.unlock()
    }

    guard let currentState = cachedAuthState else {
        throw AuthenticationError.noStoredCredentials
    }

    Self.logger.info("Refreshing authentication token")
    let newState = try await handler.refreshToken(currentState: currentState)

    // Update cached state
    authStateLock.withLock {
        cachedAuthState = newState
    }

    // Update storage
    if let authStorage {
        await authStorage.updateState(newState)
    }

    Self.logger.info("Token refresh completed successfully")
}
```

**Note:** This prevents multiple simultaneous refreshes but subsequent requests will wait briefly. Consider using a Task/continuation approach for more sophisticated waiting.

---

## 6. Backward Compatibility

### Checklist
- ✅ New parameters have default values (`nil` and `3600`)
- ✅ Existing behavior unchanged when `tokenRefreshHandler` is `nil`
- ✅ No breaking changes to existing API
- ✅ All existing tests should pass without modification

---

## 7. Testing Strategy

### Test Cases to Consider

1. **Proactive Refresh:**
   - Token expires in > 1 hour → No refresh triggered
   - Token expires in < 1 hour → Refresh triggered before request
   - Token expires in < 1 hour but handler is nil → No refresh, request proceeds

2. **Reactive Refresh:**
   - Request returns 401 with handler configured → Refresh triggered, request retried
   - Request returns 401 without handler → Error thrown immediately
   - Refresh fails → Original error propagated

3. **Race Conditions:**
   - Multiple concurrent requests with expired token → Only one refresh occurs
   - Refresh in progress when another request checks → Wait for completion

4. **Edge Cases:**
   - Token refresh returns invalid token → Next request fails appropriately
   - Auth storage unavailable → Error thrown
   - Handler throws error → Error propagated to caller

---

## 8. Example Implementation (Reference Only)

This example shows how a client SDK would use this feature:

```swift
import SwiftAPIClient

class MyAPIClient: APIClient, TokenRefreshHandler {

    // Implement TokenRefreshHandler protocol
    public func refreshToken(currentState: AuthenticationState) async throws -> AuthenticationState {
        // Call your API's token refresh endpoint
        let refreshResponse = try await callRefreshEndpoint(
            refreshToken: currentState.refreshToken
        )

        // Return new authentication state
        return AuthenticationState(
            accessToken: refreshResponse.accessToken,
            refreshToken: refreshResponse.refreshToken,
            expirationDate: refreshResponse.expirationDate
        )
    }

    init(clientId: String, authStorage: any APIAuthentication) {
        let config = APIClient.Configuration(
            baseURL: URL(string: "https://api.example.com")!,
            additionalHeaders: ["X-Client-ID": clientId],
            tokenRefreshBuffer: 3600, // Refresh 1 hour before expiration
            tokenRefreshHandler: self
        )

        super.init(
            configuration: config,
            session: URLSession.shared,
            authStorage: authStorage
        )
    }

    private func callRefreshEndpoint(refreshToken: String) async throws -> RefreshResponse {
        // Implementation specific to your API
        // This would use the raw URLSession, not the APIClient's fetchData
        // to avoid recursive token refresh attempts
        fatalError("Implement your refresh endpoint call")
    }
}
```

---

## 9. Documentation Updates

### Update README.md or docs to include:

```markdown
## Automatic Token Refresh

SwiftAPIClient supports automatic OAuth token refresh out of the box:

### Setup

1. Conform your client to `TokenRefreshHandler`:

```swift
extension MyAPIClient: TokenRefreshHandler {
    func refreshToken(currentState: AuthenticationState) async throws -> AuthenticationState {
        // Call your refresh endpoint
        // Return new AuthenticationState
    }
}
```

2. Configure token refresh when creating your client:

```swift
let config = APIClient.Configuration(
    baseURL: myBaseURL,
    tokenRefreshBuffer: 3600, // Refresh 1 hour before expiration
    tokenRefreshHandler: self
)
```

### Behavior

- **Proactive Refresh:** Tokens are refreshed automatically when they expire within the configured buffer time
- **Reactive Refresh:** If a request fails with 401, the token is refreshed and the request is retried once
- **Opt-in:** Set `tokenRefreshHandler` to `nil` to disable (default behavior)
```

---

## 10. Success Criteria

✅ **Functionality:**
- Proactive refresh works when token expires within buffer
- Reactive refresh works on 401 errors
- Requests never fail with 401 when refresh token is valid
- Clear error messages when refresh fails

✅ **Compatibility:**
- No breaking changes
- All existing tests pass
- Works with existing client implementations

✅ **Quality:**
- Thread-safe implementation
- Proper logging for debugging
- Handles edge cases gracefully
- Race conditions prevented

✅ **Documentation:**
- Public API documented
- Usage examples provided
- Migration guide (if needed)

---

## Questions / Clarifications

If anything is unclear or you need different behavior, please ask before implementing!
