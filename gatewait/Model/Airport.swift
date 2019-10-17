//
//  Airport.swift
//  gatewait
//
//  Created by Danil on 13.10.2019.
//  Copyright © 2019 Danil Chernyshev. All rights reserved.
//

import Foundation
import RealmSwift

class Airport: Object {
    @objc dynamic var id: String?
    @objc dynamic var city: String?
    let lat = RealmOptional<Double>()
    let lng = RealmOptional<Double>()
}
