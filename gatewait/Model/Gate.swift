//
//  Gate.swift
//  gatewait
//
//  Created by Danil on 13.10.2019.
//  Copyright © 2019 Danil Chernyshev. All rights reserved.
//

import Foundation
import RealmSwift

class Gate: Object {
    @objc dynamic var id = ""
    @objc dynamic var amount = 0
    @objc dynamic var flight = ""
    @objc dynamic var airport = ""
}
