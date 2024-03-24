//
//  UserCard.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/11.
//

import Foundation
import Shuffle

class UserCard: SwipeCard {
        
    func configure(withModel model: UserCardModel) {
        content = UserCardContentView(withImage: model.image)
        footer = UserCardFooterView(withTitle: model.name, subTitle: "性格　\(model.personality)\n悩み　\(model.worry)")
    }
}
