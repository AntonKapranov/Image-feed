import UIKit
/*
 {
   "id": "pXhwzz1JtQU",
   "updated_at": "2016-07-10T11:00:01-05:00",
   "username": "jimmyexample",
   "name": "James Example",
   "first_name": "James",
   "last_name": "Example",
   "instagram_username": "instantgrammer",
   "twitter_username": "jimmy",
   "portfolio_url": null,
   "bio": "The user's bio",
 */
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
    let nickname: String
    let bio: String
    
    init(profile: ProfileResults) {
        nickname = profile.username
        firstName = profile.firstName
        lastName = profile.lastName
        fullName = "\(firstName) \(lastName)"
        bio = profile.bio
    }
}
