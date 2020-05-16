//
//  SearchableRecord.swift
//  Continuum
//
//  Created by Jimmy on 5/13/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matches(searchTerm: String) -> Bool
}
