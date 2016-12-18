//
//  ConsoleRemote.swift
//  Moody
//
//  Created by Florian on 22/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import MoodyModel


final class ConsoleRemote: MoodyRemote {

    fileprivate func log(_ str: String) {
        print("--- Dummy network adapter logging to console; See README for instructions to enable CloudKit ---\n* ", str)
    }

    func setupMoodSubscription() {
        log("Setting up subscription")
    }

    func fetchLatestMoods(completion: @escaping ([RemoteMood]) -> ()) {
        log("Fetching latest moods")
        completion([])
    }

    func fetchNewMoods(completion: @escaping ([RemoteRecordChange<RemoteMood>], @escaping (_ success: Bool) -> ()) -> ()) {
        log("Fetching new moods")
        completion([], { _ in })
    }

    func upload(_ moods: [Mood], completion: @escaping ([RemoteMood], RemoteError?) -> ()) {
        log("Uploading \(moods.count) moods")
        let remoteMoods = moods.map { RemoteMood(mood: $0) }.flatMap { $0 }
        completion(remoteMoods, nil)
    }

    func remove(_ moods: [Mood], completion: @escaping ([RemoteRecordID], RemoteError?) -> ()) {
        log("Deleting \(moods.count) moods")
        let ids = moods.map { $0.remoteIdentifier }.flatMap { $0 }
        completion(ids, nil)
    }

    func fetchUserID(completion: @escaping (RemoteRecordID?) -> ()) {
        log("Fetching ID of logged in user")
        completion(nil)
    }

}


extension RemoteMood {
    fileprivate init?(mood: Mood) {
        self.id = "__dummyId__"
        self.creatorID = nil
        self.date = mood.date
        self.location = mood.location
        self.colors = mood.colors
        self.isoCountry = mood.country?.iso3166Code ?? .unknown
    }
}


