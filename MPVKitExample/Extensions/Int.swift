//
//  Int.swift
//  AlienPlayer
//
//  Created by karelrooted on 11/9/23.
//

import Foundation



extension Int {

    func formattedAsReadableString() -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full

        return formatter.string(from: TimeInterval(self))!
    }
}
