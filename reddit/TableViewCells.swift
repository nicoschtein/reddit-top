//
//  LinkTableViewCell.swift
//  reddit
//
//  Created by Nicolas Schteinschraber on 10/05/2019.
//  Copyright © 2019 Schtein. All rights reserved.
//

import UIKit

class LinkTableViewCell: UITableViewCell {

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentsButton: UIButton!

    func configureWith(link:Link, imageCompletion:@escaping (_ thumbImage:UIImage?)->()) {
        titleLabel.text = link.title
        authorLabel.text = link.author
        commentsButton.setTitle("\(link.num_comments) comments", for: UIControl.State.normal)
        timeAgoLabel.text = link.created?.timeAgo() ?? ""

        loadThumbnailFromWeb(url: link.thumbnail, completionHandler:imageCompletion)
    }
    func setThumbnail(_ image:UIImage?) {
        DispatchQueue.main.async { [weak self] in
            self?.thumbnailImageView.image = image
            self?.setNeedsLayout()
        }
    }
    func loadThumbnailFromWeb(url:String?, completionHandler:@escaping (_ thumbImage:UIImage?)->()) {
        guard let url = url else {
            completionHandler(nil)
            return
        }
        NetworkManager.loadImageFromWeb(url: url) {(image) in
            completionHandler(image)
        }
    }

    @IBAction func commentsButtonTapped(_ sender: Any) {
        
    }
    
    static var cellIdentifier:String {
        return "LinkTableViewCell"
    }
}

class ZeroStateTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    static var cellIdentifier:String {
        return "ZeroStateTableViewCell"
    }
}
