//
//  Game.swift
//  PictIonis
//
//  Created by Agnieszka Niewiadomski on 02/10/2020.
//  Copyright © 2020 niewiajuzain_ad. All rights reserved.
//

import Foundation

class Game {
    var id: String
    var name: String
    var date: String

    init(id: String, name: String, date: String) {
        self.id = id
        self.name = name
        self.date = date
    }
}
