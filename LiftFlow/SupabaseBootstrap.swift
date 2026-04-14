import Foundation

#if canImport(Supabase)
import Supabase
#endif

enum SupabaseBootstrapError: LocalizedError {
    case missingValue(String)
    case invalidURL(String)

    var errorDescription: String? {
        switch self {
        case let .missingValue(key):
            return "Missing Info.plist value for \(key)"
        case let .invalidURL(value):
            return "Invalid Supabase URL: \(value)"
        }
    }
}

enum SupabaseBootstrap {
    static let urlKey = "SUPABASE_URL"
    static let publishableKeyKey = "SUPABASE_PUBLISHABLE_KEY"

    static func urlString(bundle: Bundle = .main) throws -> String {
        guard let value = bundle.object(forInfoDictionaryKey: urlKey) as? String,
              !value.isEmpty,
              value != "$(SUPABASE_URL)" else {
            throw SupabaseBootstrapError.missingValue(urlKey)
        }

        return value
    }

    static func publishableKey(bundle: Bundle = .main) throws -> String {
        guard let value = bundle.object(forInfoDictionaryKey: publishableKeyKey) as? String,
              !value.isEmpty,
              value != "$(SUPABASE_PUBLISHABLE_KEY)" else {
            throw SupabaseBootstrapError.missingValue(publishableKeyKey)
        }

        return value
    }

#if canImport(Supabase)
    static func makeClient(bundle: Bundle = .main) throws -> SupabaseClient {
        let urlValue = try urlString(bundle: bundle)

        guard let url = URL(string: urlValue) else {
            throw SupabaseBootstrapError.invalidURL(urlValue)
        }

        return SupabaseClient(
            supabaseURL: url,
            supabaseKey: try publishableKey(bundle: bundle)
        )
    }
#endif
}
