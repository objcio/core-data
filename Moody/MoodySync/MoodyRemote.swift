//
//  MoodyRemote.swift
//  Moody
//
//  Created by Florian on 21/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreLocation
import MoodyModel


enum RemoteRecordChange<T: RemoteRecord> {
    case insert(T)
    case update(T)
    case delete(RemoteRecordID)
}

enum RemoteError {
    case permanent([RemoteRecordID])
    case temporary

    var isPermanent: Bool {
        switch self {
        case .permanent: return true
        default: return false
        }
    }
}

protocol MoodyRemote {
    func setupMoodSubscription()
    func fetchLatestMoods(completion: @escaping ([RemoteMood]) -> ())
    func fetchNewMoods(completion: @escaping ([RemoteRecordChange<RemoteMood>], @escaping (_ success: Bool) -> ()) -> ())
    func upload(_ moods: [Mood], completion: @escaping ([RemoteMood], RemoteError?) -> ())
    func remove(_ moods: [Mood], completion: @escaping ([RemoteRecordID], RemoteError?) -> ())
    func fetchUserID(completion: @escaping (RemoteRecordID?) -> ())
}


