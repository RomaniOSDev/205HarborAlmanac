import Foundation

enum AppExternalLinks: String {
    case privacyPolicy = "https://harboralmanac205.site/privacy/239"
    case termsOfUse = "https://harboralmanac205.site/terms/239"

    var url: URL? {
        URL(string: rawValue)
    }
}
