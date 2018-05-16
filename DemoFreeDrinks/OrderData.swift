//
//  OrderData.swift
//  DemoFreeDrinks
//
//  Created by Chao Shin on 2018/5/8.
//  Copyright © 2018 Chao Shin. All rights reserved.
//

import Foundation

struct OrderTeaData {
    var name: String
    var tea: String
    var size: String
    var sugar: SugarInformation
    var ice: IceInformation 
    var extra: String
    var note: String
    var price: String
    var index: String
    var password: String
    
    init() {
        name = ""
        tea = "冰茉香綠茶"
        size = "大杯"
        sugar = .regular
        ice = .regular
        extra = "不需加購"
        note = ""
        price = "40"
        index = "0"
        password = ""
        
    }
}

struct TeaInfomation {
    var name: String
    var price: Int
    var isHot: Bool
}

enum SugarInformation: String {
    case regular = "正常", lessSuger = "少糖", halfSuger = "半糖", quarterSuger = "微糖", sugerFree = "無糖"
}

enum IceInformation: String {
    case regular = "正常", moreIce = "多冰", easyIce = "少冰", iceFree = "去冰", hot = "熱飲"
}


struct OrderInformation {
    var name: String
    var tea: String
    var size: String
    var sugar: String
    var ice: String
    var extra: String    
    var note: String
    var price: String
    var index: String
    
    init?(json: [String : Any]) {
        guard let name = json["name"] as? String,
            let tea = json["tea"] as? String,
            let size = json["size"] as? String,
            let sugar = json["sugar"] as? String,
            let ice = json["ice"] as? String,
            let extra = json["extra"] as? String,
            let note = json["note"] as? String,
            let price = json["price"] as? String,
            let index = json["index"] as? String
            
            else {
                return nil
        }
        self.name = name
        self.tea = tea
        self.size = size
        self.sugar = sugar
        self.ice = ice
        self.extra = extra
        self.note = note
        self.price = price
        self.index = index
    }
    
}
