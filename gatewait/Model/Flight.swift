//
//  Flight.swift
//  gatewait
//
//  Created by Danil on 13.10.2019.
//  Copyright © 2019 Danil Chernyshev. All rights reserved.
//

import Foundation
import RealmSwift

class Flight: Object {
    @objc dynamic var airline = ""
    @objc dynamic var airport = ""
    @objc dynamic var id = ""
}
