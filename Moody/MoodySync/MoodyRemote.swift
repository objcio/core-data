//
//  MoodyRemote.swift
//  Moody
//
//  Created by Florian on 21/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreLocation
import MoodyModel


enum RemoteRecordChange<T: RemoteRecordType> {
    case Insert(T)
    case Update(T)
    case Delete(RemoteRecordID)
}

enum RemoteError {
    case Permanent([RemoteRecordID])
    case Temporary

    var isPermanent: Bool {
        switch self {
        case .Permanent: return true
        default: return false
        }
    }
}

protocol MoodyRemoteType {
    func setupMoodSubscription()
    func fetchLatestMoods(completion: ([RemoteMood]) -> ())
    func fetchNewMoods(completion: ([RemoteRecordChange<RemoteMood>], (success: Bool) -> ()) -> ())
    func uploadMoods(moods: [Mood], completion: ([RemoteMood], RemoteError?) -> ())
    func removeMoods(moods: [Mood], completion: ([RemoteRecordID], RemoteError?) -> ())
    func fetchUserID(completion: RemoteRecordID? -> ())
}

