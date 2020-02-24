//
//  MemoModel.swift
//  MemoAppWithImages
//
//  Created by Seok on 18/02/2020.
//  Copyright © 2020 swift. All rights reserved.
//

// realm 출처 https://realm.io

import Foundation
import RealmSwift

class MemoModel: Object {
    @objc dynamic var title: String?
    @objc dynamic var content: String?
    @objc dynamic var directory: String?
    var urls = List<String>()
    
    
}
