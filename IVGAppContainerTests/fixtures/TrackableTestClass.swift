//
//  TrackableTestClass.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/19/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

protocol TrackableTestClassType {
    var trackerLog:[(String,Date)] { get }
    var tracker:[String:[Date]] { get }
    var trackerKeys:Set<String> { get }
    var trackerCount:Int { get }

    func track(_ key:String)
}

protocol TrackableTestClassProxy : TrackableTestClassType {
    var trackableTestClass: TrackableTestClass { get }
}

extension TrackableTestClassProxy {
    var trackerLog:[(String,Date)] {
        return trackableTestClass.trackerLog
    }
    var tracker:[String:[Date]] {
        return trackableTestClass.tracker
    }
    var trackerKeys:Set<String> {
        return trackableTestClass.trackerKeys
    }
    var trackerCount:Int {
        return trackableTestClass.trackerCount
    }

    func track(_ key:String) {
        trackableTestClass.track(key)
    }
}

class TrackableTestClass : TrackableTestClassType {
    var trackerLog:[(String,Date)] = []
    var tracker:[String:[Date]] = [:]
    var trackerKeys:Set<String> {
        return Set(tracker.keys)
    }
    var trackerCount:Int {
        return tracker.values.reduce(0,{$0 + $1.count})
    }

    func track(_ key:String) {
        let timestamp = Date()

        var timestamps:[Date] = tracker[key] ?? []
        timestamps.append(timestamp)
        tracker[key] = timestamps
        trackerLog.append((key,timestamp))
    }
    
}

