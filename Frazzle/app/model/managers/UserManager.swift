//
// Copyright (c) 2016 Frazzle. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

class UserManager {

    private static let KEY_USER:String = "KEY_USER"
    private static let KEY_LOGGED_IN:String = "KEY_LOGGED_IN"

    private static let KEY_TOKEN:String = "KEY_TOKEN"
    private static let KEY_TOKEN_ID:String = "KEY_TOKEN_ID"

    private static let KEY_SHOPS_JSON:String = "KEY_SHOPS_JSON"
    private static let KEY_USERS_JSON:String = "KEY_USERS_JSON"

    private static let KEY_FOLLOWING_JSON:String = "KEY_FOLLOWING_JSON"
    private static let KEY_FOLLOWERS_JSON:String = "KEY_FOLLOWERS_JSON"

    private static let KEY_SEARCH_SHOPS_JSON:String = "KEY_SEARCH_SHOPS_JSON"
    private static let KEY_SEARCH_USERS_JSON:String = "KEY_SEARCH_USERS_JSON"

    private static var shopuserInfo : User!
    private static var searchQuery : String!
    
    static func loginUser(user:User){
        UserService.loginUser(user)
    }
    
    static func setShopUser(user:User){
        self.shopuserInfo = user
    }

    static func getShopUser()->User
    {
        return self.shopuserInfo
    }
    
    static func setSearchQuery (query : String) {
        self.searchQuery = query
    }
    
    static func getSearchQuery () -> String {
        let query = self.searchQuery
        if query.isEmpty {
            return ""
        }

        return self.searchQuery
    }
    
    static func logoutUser(){
        SimplePersistence.setBool(KEY_LOGGED_IN, value: false)
        SimplePersistence.setString(KEY_USER, value:"")
    }

    static func setLoginUser(user:User){
        SimplePersistence.setBool(KEY_LOGGED_IN, value: true)
        SimplePersistence.setString(KEY_USER, value:user.toJson())
    }

    static func isUserLoggedIn()->Bool{
        return SimplePersistence.getBool(KEY_LOGGED_IN)
    }

    static func getLoggedInUser()->User?{
        let key = DefaultsKey<String>(KEY_USER)

        if Defaults.hasKey(key) {
            return User.fromJson(Defaults[key])
        } else{
            let user = User()
            user.username = "franciscothompson"
            user.password = "pass1"
            return user
        }

    }

    static func setJson(type:C.UserType, json:String){
        var keyJson:String
        switch type {
        case C.UserType.USERS:
            keyJson = KEY_USERS_JSON
        case C.UserType.SHOPS:
            keyJson = KEY_SHOPS_JSON
        default:
            keyJson = KEY_USERS_JSON
        }

        SimplePersistence.setString(keyJson, value: json)
    }

    static func setJson(key:String, json:String){
        SimplePersistence.setString(key, value: json)
    }

    static func getJson(type:C.UserType)->String{
        var keyJson:String
        switch type {
        case C.UserType.USERS:
            keyJson = KEY_USERS_JSON
        case C.UserType.SHOPS:
            keyJson = KEY_SHOPS_JSON
        default:
            keyJson = KEY_USERS_JSON
        }

        return SimplePersistence.getString(keyJson)
    }

    static func getJsonAsList(type:C.UserType, json:String)->Array<User>{
        return try! User.fromJsonToList(json)
    }

    static func fetchUsersFromServer() {
        UserService.requestUsers()
    }

    static func searchUsersOnServer(query:String) {
        SearchService.usersSearch(query)
    }

    static func searchShopsOnServer(query:String) {
        SearchService.shopsSearch(query)
    }

    static func uploadToken() {
        TokenService.postToken()
    }

    static func followUser(user:User){
        UserService.postFollowing(user)
    }

    static func unFollowUser(user:User){
        UserService.deleteFollowing(user)
    }

    static func fetchFollowers(){
        UserService.requestFollowers()
    }

    static func fetchFollowing(){
        UserService.requestFollowing()
    }

    static func fetchShops(){
        UserService.requestShops()
    }


    static func setUsersSearchResults(items:Array<User>){
        UserManager.setJson(KEY_SEARCH_USERS_JSON, json: User.toJsonFromList(items))
    }

    static func setShopsSearchResults(items:Array<User>){
        print (User.toJsonFromList(items))
        UserManager.setJson(KEY_SEARCH_SHOPS_JSON, json: User.toJsonFromList(items))
    }

    static  func getUsersSearchResults()->Array<User>{
        return try! User.fromJsonToList(SimplePersistence.getString(KEY_SEARCH_USERS_JSON))
    }

    static func getShopsSearchResults()->Array<User>{
        print (SimplePersistence.getString(KEY_SEARCH_SHOPS_JSON))
        return try! User.fromJsonToList(SimplePersistence.getString(KEY_SEARCH_SHOPS_JSON))
    }

    static func setUsersByType(items:Array<User>){
        var shops = Array<User>()
        var users = Array<User>()

        let loggedIn = UserManager.isUserLoggedIn()
        var user:User?
        if(loggedIn){
            user = UserManager.getLoggedInUser()
        }

        for item in items {
            switch item.userRoleId {
            case "DISPENSARIES":
                shops.append(item)
            case "MERCHANT":
                shops.append(item)
            case "SHOPS":
                shops.append(item)
            default:
                if(loggedIn){
                    if(user!.username != item.username){
                        users.append(item)
                    }
                }else {
                    users.append(item)
                }
            }
        }


        UserManager.setJson(C.UserType.SHOPS,json:User.toJsonFromList(shops))
        UserManager.setJson(C.UserType.USERS,json:User.toJsonFromList(users))
    }

    static func getUsersByType(type:C.UserType)->Array<User>{
        print ("userJson : ", UserManager.getJson(type))
        
        return UserManager.getJsonAsList(type, json:UserManager.getJson(type))
    }

    static func getUserByID(id:String)->User?{
        var list = getUsersByType(C.UserType.USERS)

        for user:User in list {
            if(user.username == id){
                return user
            }
        }

        list = getUsersByType(C.UserType.SHOPS)

        for user:User in list {
            if(user.username == id){
                return user
            }
        }

        return nil
    }

    static func getFollowing()->Array<User>{
        return getUsers(KEY_FOLLOWING_JSON)
    }

    static func getFollowers()->Array<User>{
        return getUsers(KEY_FOLLOWERS_JSON)
    }

    static func getUsers(stringKey:String)->Array<User>{
        return try! User.fromJsonToList(SimplePersistence.getString(stringKey))
    }

    static func setFollowing(following:Array<User>){
        setUsers(following,stringKey:KEY_FOLLOWING_JSON)
    }

    static func setFollowers(followers:Array<User>){
        setUsers(followers,stringKey:KEY_FOLLOWERS_JSON)
    }

    static func setUsers(users:Array<User>, stringKey:String){
        SimplePersistence.setString(stringKey, value: User.toJsonFromList(users))
    }

    static func setToken(token:String){
        SimplePersistence.setString(KEY_TOKEN, value: token)
    }

    static func setTokenId(tokenId:String){
        SimplePersistence.setString(KEY_TOKEN_ID, value: tokenId)
    }

    static func getToken()->String{
        return SimplePersistence.getString(KEY_TOKEN)
    }

    static func getTokenId()->String{
        return SimplePersistence.getString(KEY_TOKEN_ID)
    }

    static func getFollowingAsDict()->Dictionary<String,User>{
        return getUsersAsDict(KEY_FOLLOWING_JSON)
    }


    static func getUsersAsDict(stringKey:String)->Dictionary<String,User>{
        var dict = [String : User]()

        for var user:User in getUsers(stringKey) {
            dict[user.username] = user
        }

        return dict

    }

    static func addUserToFollowing(user:User){
        var users = getFollowing()
        users.append(user)
        setFollowing(users)
    }

    static func removeUserFromFollowing(user:User){
        var users = getFollowing()
        var index:Int = 0
        for var localUser:User in users {
            if(user.username == localUser.username){
                users.removeAtIndex(index)
                setFollowing(users)
                break
            }
            index += 1
        }
    }

    static func seachOnServer(query:String) {
        SearchService.usersSearch(query)
        SearchService.shopsSearch(query)
    }


    static func getUsersFromSearch()->Array<User>{
        return try! User.fromJsonToList(SimplePersistence.getString(KEY_SEARCH_USERS_JSON))
    }

    static func setUsersFromSearch(users:Array<User>){
        return SimplePersistence.setString(KEY_SEARCH_USERS_JSON, value: User.toJsonFromList(users))
    }
    
    static func getShopsFromSearch()->Array<User>{
        return try! User.fromJsonToList(SimplePersistence.getString(KEY_SEARCH_SHOPS_JSON))
    }

    static func setShopsFromSearch(users:Array<User>){
        return SimplePersistence.setString(KEY_SEARCH_SHOPS_JSON, value: User.toJsonFromList(users))
    }
}
