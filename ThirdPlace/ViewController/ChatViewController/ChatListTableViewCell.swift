//
//  ChatListTableViewCell.swift
//  ThirdPlace
//
//  Created by 恵紙拓玖 on 2024/03/22.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadMessageBackgroundView: UIView!
    @IBOutlet weak var unreadMessageCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unreadMessageBackgroundView.layer.cornerRadius = unreadMessageBackgroundView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func generateCell(chat: Chat) {
        
        nameLabel.text = chat.receiverName
        lastMessageLabel.text = chat.lastMessage
        //文字の大きさを調整したい場合は下記をコメントアウト
//        lastMessageLabel.adjustsFontSizeToFitWidth = true
        
        if chat.unreadCounter != 0 {
            self.unreadMessageCountLabel.text = "\(chat.unreadCounter)"
            self.unreadMessageCountLabel.isHidden = false
            self.unreadMessageBackgroundView.isHidden = false
        } else {
            self.unreadMessageCountLabel.isHidden = true
            self.unreadMessageBackgroundView.isHidden = true
        }
        
        setAvatar(avatarLink: chat.avatarLink)
        dateLabel.text = timeElapsed(chat.date)
        //文字の大きさを調整したい場合は下記をコメントアウト
//        dateLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func setAvatar(avatarLink: String) {
        
        FileStorage.downloadImage(imageUrl: avatarLink) { avatarImage in
            if avatarImage != nil {
                self.avatarImageView.image = avatarImage?.circleMasked
            }
        }
    }

    func timeElapsed(_ date: Date) -> String {
        
        let seconds = Date().timeIntervalSince(date)
        print("seconds since last message", seconds)
        var dateText = ""
        
        if seconds < 60 {
            dateText = "いま"
        } else if seconds < 60 * 60 {
            let minutes = Int(seconds / 60)
            dateText = "\(minutes)分前"
        } else if seconds < 60 * 60 * 24 {
            let hours = Int(seconds / (60 * 60))
            dateText = "\(hours)時間前"
        } else if seconds < 60 * 60 * 24 * 7 {
            let days = Int(seconds / (60 * 60 * 24))
            dateText = "\(days)日前"
        } else if seconds < 60 * 60 * 24 * 7 * 4 {
            let weeks = Int(seconds / (60 * 60 * 24 * 7))
            dateText = "\(weeks)週間前"
        } else if seconds < 60 * 60 * 24 * 7 * 4 * 12 {
            let months = Int(seconds / (60 * 60 * 24 * 7 * 4))
            dateText = "\(months)ヶ月前"
        } else {
            let dateFormat = DateFormatter()
            dateFormat.dateStyle = .short
            dateFormat.timeStyle = .none
            dateText = dateFormat.string(from: date)
        }
        
        return dateText
    }
    
}
