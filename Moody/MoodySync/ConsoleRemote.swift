//
//  ConsoleRemote.swift
//  Moody
//
//  Created by Florian on 22/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import MoodyModel


struct ConsoleRemote: MoodyRemoteType {

    private func log(str: String) {
        print("--- Dummy network adapter logging to console; See README for instructions to enable CloudKit ---\n* ", str)
    }

    func setupMoodSubscription() {
        log("Setting up subscription")
    }

    func fetchLatestMoods(completion: ([RemoteMood]) -> ()) {
        log("Fetching latest moods")
        completion([])
    }

    func fetchNewMoods(completion: ([RemoteRecordChange<RemoteMood>], (success: Bool) -> ()) -> ()) {
        log("Fetching new moods")
        completion([], { _ in })
    }

    func uploadMoods(moods: [Mood], completion: ([RemoteMood], RemoteError?) -> ()) {
        log("Uploading \(moods.count) moods")
        let remoteMoods = moods.map { RemoteMood(mood: $0) }.flatMap { $0 }
        completion(remoteMoods, nil)
    }

    func removeMoods(moods: [Mood], completion: ([RemoteRecordID], RemoteError?) -> ()) {
        log("Deleting \(moods.count) moods")
        let ids = moods.map { $0.remoteIdentifier }.flatMap { $0 }
        completion(ids, nil)
    }

    func fetchUserID(completion: RemoteRecordID? -> ()) {
        log("Fetching ID of logged in user")
        completion(nil)
    }

}


extension RemoteMood {
    private init?(mood: Mood) {
        self.id = "__dummyId__"
        self.creatorID = nil
        self.date = mood.date
        self.location = mood.location
        self.colors = mood.colors
        self.isoCountry = mood.country?.iso3166Code ?? .Unknown
    }
}

