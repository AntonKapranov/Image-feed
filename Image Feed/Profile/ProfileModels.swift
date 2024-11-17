import UIKit

struct ProfileResults: Codable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String
    
}

struct Profile {
    let firstName: String
    let lastName: String
    let fullName: String
    let username: String
    let bio: String
    
    init(profile: ProfileResults) {
        username = profile.username
        firstName = profile.firstName
        lastName = profile.lastName
        fullName = "\(firstName) \(lastName)"
        bio = profile.bio
    }
}

//MARK: Image fetch
struct ProfileImage: Codable {
    let small: String?
    let medium: String?
    let large: String?
}

struct UserResult: Codable {
    let profileImage: ProfileImage?
}
