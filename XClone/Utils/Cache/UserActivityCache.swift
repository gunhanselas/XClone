//
//  UserActivityCache.swift
//  XClone
//
//  Created by Stephan Dowless on 2/3/25.
//

import Firebase
import FirebaseAuth

class UserActivityCache {
    private var cache = NSCache<NSString, NSArray>()
    private var lastFetched = [String: Date]()
    
    private var refreshInterval: TimeInterval
    private let cacheIdentifier: String
    
    init(refreshInterval: TimeInterval, cacheIdentifier: String) {
        self.refreshInterval = refreshInterval
        self.cacheIdentifier = cacheIdentifier
        
        initializeCache()
    }
    
    func initializeCache() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if let lastFetchedTime = loadLastFetched(for: uid) {
            print("DEBUG: Last \(cacheIdentifier) fetched time for \(uid) is \(lastFetchedTime)")
            lastFetched[uid] = lastFetchedTime
        }
        
        loadCacheData()
    }
    
    func set(_ items: [String]) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        cache.setObject(items as NSArray, forKey: uid as NSString)
        saveToDisk(items, for: uid)
    }
    
    func update(_ item: String, didAdd: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard var items = cache.object(forKey: uid as NSString) as? [String] else { return }
        
        if didAdd {
            items.append(item)
        } else {
            items.removeAll(where: { $0 == item })
        }
        
        set(items)
    }
    
    func contains(_ item: String) -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        guard let items = cache.object(forKey: uid as NSString) else { return false }
        return items.contains(item)
    }
    
    func getData() -> [String] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        guard let items = cache.object(forKey: uid as NSString) as? [String] else { return [] }
        return items
    }
}

private extension UserActivityCache {
    func loadCacheData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if needsRefresh {
            Task {
                let ref = FirestoreConstants.UserCollection.document(uid).collection(cacheIdentifier)
                let snapshot = try await ref.getDocuments()
                let items = snapshot.documents.map { $0.documentID }
                set(items)
                saveLastFetched(for: uid, date: Date())
                print("DEBUG: Loaded \(cacheIdentifier) from database")
            }
        } else {
            loadCacheFromDisk(for: uid)
            print("DEBUG: Loaded post ids for \(cacheIdentifier) from disk")
        }
    }
}

private extension UserActivityCache {
    func saveToDisk(_ items: [String], for uid: String) {
        do {
            let fileName = fileName(for: uid)
            try DiskCache.save(items, to: fileName)
        } catch {
            print("DEBUG: Failed to save \(cacheIdentifier) to disk with error: \(error)")
        }
    }
    
    func loadCacheFromDisk(for uid: String) {
        do {
            let fileName = fileName(for: uid)
            let items = try DiskCache.load(fileName, as: [String].self)
            set(items)
        } catch {
            print("DEBUG: Failed to save \(cacheIdentifier) to disk with error: \(error)")
        }
    }
    
    func fileName(for uid: String) -> String {
        return "\(cacheIdentifier)_\(uid).json"
    }
}

private extension UserActivityCache {
    func saveLastFetched(for uid: String, date: Date) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(date, forKey: "lastFetched_\(uid)_\(cacheIdentifier)")
        lastFetched[uid] = date
    }
    
    func loadLastFetched(for uid: String) -> Date? {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "lastFetched_\(uid)_\(cacheIdentifier)") as? Date
    }
    
    var needsRefresh: Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        guard let lastFetched = lastFetched[uid] else { return true }
        return Date().timeIntervalSince(lastFetched) > refreshInterval
    }
}
