//
//  User.swift
//  Ello
//
//  Created by Sean Dougherty on 12/1/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

import UIKit
import SwiftyJSON

let UserVersion: Int = 1

public final class User: JSONAble, NSCoding {
    public let version = UserVersion

    // active record
    public let id: String
    // required
    public let href: String
    public let username: String
    public let name: String
    public let experimentalFeatures: Bool
    public let relationshipPriority: Relationship
    // optional
    public var avatar: ImageAttachment? // required, but kinda optional due to it being nested in json
    public var identifiableBy: String?
    public var postsCount: Int?
    public var followersCount: String? // string due to this returning "∞" for the ello user
    public var followingCount: Int?
    public var formattedShortBio: String?
    public var externalLinks: String? // this will change to an object when incoming
    public var coverImage: ImageAttachment?
    public var backgroundPosition: String?
    // links
    public var posts: [Post]?
    public var mostRecentPost: Post?
    // computed
    public var atName: String { return "@\(username)"}
    public var avatarURL: NSURL? { return avatar?.url }
    public var coverImageURL: NSURL? { return coverImage?.url }
    public var isCurrentUser: Bool { return self.profile != nil }
    // profile
    public var profile: Profile?

    public init(id: String,
        href: String,
        username: String,
        name: String,
        experimentalFeatures: Bool,
        relationshipPriority: Relationship)
    {
        self.id = id
        self.href = href
        self.username = username
        self.name = name
        self.experimentalFeatures = experimentalFeatures
        self.relationshipPriority = relationshipPriority
        super.init()
    }

// MARK: NSCoding

    required public init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        // active record
        self.id = decoder.decodeKey("id")
        // required
        self.href = decoder.decodeKey("href")
        self.username = decoder.decodeKey("username")
        self.name = decoder.decodeKey("name")
        self.experimentalFeatures = decoder.decodeKey("experimentalFeatures")
        let relationshipPriorityRaw: String = decoder.decodeKey("relationshipPriorityRaw")
        self.relationshipPriority = Relationship(stringValue: relationshipPriorityRaw)
        // optional
        self.avatar = decoder.decodeOptionalKey("avatar")
        self.identifiableBy = decoder.decodeOptionalKey("identifiableBy")
        self.postsCount = decoder.decodeOptionalKey("postsCount")
        self.followersCount = decoder.decodeOptionalKey("followersCount")
        self.followingCount = decoder.decodeOptionalKey("followingCount")
        self.formattedShortBio = decoder.decodeOptionalKey("formattedShortBio")
        self.externalLinks = decoder.decodeOptionalKey("externalLinks")
        self.coverImage = decoder.decodeOptionalKey("coverImage")
        self.backgroundPosition = decoder.decodeOptionalKey("backgroundPosition")
        // links
        self.posts = decoder.decodeOptionalKey("posts")
        self.mostRecentPost = decoder.decodeOptionalKey("mostRecentPost")
        // profile
        self.profile = decoder.decodeOptionalKey("profile") 
    }

    public func encodeWithCoder(encoder: NSCoder) {
        // active record
        encoder.encodeObject(id, forKey: "id")
        // required
        encoder.encodeObject(href, forKey: "href")
        encoder.encodeObject(username, forKey: "username")
        encoder.encodeObject(name, forKey: "name")
        encoder.encodeBool(experimentalFeatures, forKey: "experimentalFeatures")
        encoder.encodeObject(relationshipPriority.rawValue, forKey: "relationshipPriorityRaw")
        // optional
        encoder.encodeObject(avatar, forKey: "avatar")
        encoder.encodeObject(identifiableBy, forKey: "identifiableBy")
        if let postsCount = self.postsCount {
            encoder.encodeInt64(Int64(postsCount), forKey: "postsCount")
        }
        encoder.encodeObject(followersCount, forKey: "followersCount")
        if let followingCount = self.followingCount {
            encoder.encodeInt64(Int64(followingCount), forKey: "followingCount")
        }
        encoder.encodeObject(formattedShortBio, forKey: "formattedShortBio")
        encoder.encodeObject(externalLinks, forKey: "externalLinks")
        encoder.encodeObject(coverImage, forKey: "coverImage")
        encoder.encodeObject(backgroundPosition, forKey: "backgroundPosition")
        // links
        encoder.encodeObject(posts, forKey: "posts")
        encoder.encodeObject(mostRecentPost, forKey: "mostRecentPost")
        // profile
        encoder.encodeObject(profile, forKey: "profile")
    }

// MARK: JSONAble

    override public class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)

        // create user
        var user = User(
            id: json["id"].stringValue,
            href: json["href"].stringValue,
            username: json["username"].stringValue,
            name: json["name"].stringValue,
            experimentalFeatures: json["experimental_features"].boolValue,
            relationshipPriority: Relationship(stringValue: json["relationship_priority"].stringValue)
            )

        // optional
        if let avatarObj = json["avatar"].object as? [String:[String:AnyObject]] {
            if let avatarPath = avatarObj["large"]?["url"] as? String {
                user.avatar = ImageAttachment(url: NSURL(string: avatarPath, relativeToURL: NSURL(string: ElloURI.baseURL)), height: 0, width: 0, imageType: "png", size: 0)
            }
            else if let originalPath = avatarObj["original"]?["url"] as? String {
                user.coverImage = ImageAttachment(url: NSURL(string: originalPath, relativeToURL: NSURL(string: ElloURI.baseURL)), height: 0, width: 0, imageType: "png", size: 0)
            }
        }
        user.identifiableBy = json["identifiable_by"].stringValue
        user.postsCount = json["posts_count"].int
        user.followersCount = json["followers_count"].stringValue
        user.followingCount = json["following_count"].int
        user.formattedShortBio = json["formatted_short_bio"].stringValue
        user.externalLinks = json["external_links"].stringValue
        if var coverImageObj = json["cover_image"].object as? [String:[String:AnyObject]] {
            if let hdpiPath = coverImageObj["hdpi"]?["url"] as? String {
                user.coverImage = ImageAttachment(url: NSURL(string: hdpiPath, relativeToURL: NSURL(string: ElloURI.baseURL)), height: 0, width: 0, imageType: "png", size: 0)
            }
            else if let optimizedPath = coverImageObj["optimized"]?["url"] as? String {
                user.coverImage = ImageAttachment(url: NSURL(string: optimizedPath, relativeToURL: NSURL(string: ElloURI.baseURL)), height: 0, width: 0, imageType: "png", size: 0)
            }
        }
        user.backgroundPosition = json["background_positiion"].stringValue
        // links
        if let linksNode = data["links"] as? [String: AnyObject] {
            let links = ElloLinkedStore.parseLinks(linksNode)
            user.posts = links["posts"] as? [Post]
            user.mostRecentPost = links["most_recent_post"] as? Post
        }
        // hack back in author
        if let posts = user.posts {
            for post in posts {
                post.author = user
            }
        }
        if let recentPost = user.mostRecentPost {
            recentPost.author = user
        }
        // profile
        if count(json["created_at"].stringValue) > 0 {
            user.profile = Profile.fromJSON(data) as? Profile
        }
        return user
    }
}

