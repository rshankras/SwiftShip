// import StoreKit is not allowed here (a comment, never counted)
@preconcurrency import CloudKit
import struct Foundation.URL

final class SyncService {
    let container = CKContainer.default()
    func fetch() async throws { _ = try await URLSession.shared.data(from: URL(string: "https://example.com")!) }
}
