import Foundation

struct PersonalData: Identifiable, Codable {
    let id: Int64
    let fullName: String
    let country: String
    let pfpUrl: String?
    let email: String
    let language: String?
    let theme: String?
}
