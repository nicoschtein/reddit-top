//
//  ViewController.swift
//  reddit
//
//  Created by Nicolas Schteinschraber on 10/05/2019.
//  Copyright © 2019 Schtein. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var networkManager:NetworkManager = NetworkManager()
    
    @IBOutlet weak var tableView: UITableView!
    var redditLinks:[Link] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshControl()
        fethNewData()
        
    }
    @objc func fethNewData() {
        
        setRrefreshControlTitle(title: "Refreshing Reddit Top...")
        
        networkManager.getTopListing {[weak self] (links, error) in
            if let error = error {
                print("There was an error: \(error)")
            } else if let links = links {
                self?.redditLinks = links
//                self?.redditLinks.append(contentsOf: links)
                DispatchQueue.main.async {
                    if let tbv = self?.tableView {
                        tbv.refreshControl?.endRefreshing()
                        self?.setRrefreshControlTitle(title: "Pull to refresh Reddit Top")
                        tbv.reloadData()
                    }
                }
            }
        }
    }
    func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fethNewData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        setRrefreshControlTitle(title: "Pull to refresh Reddit Top")
    }
    
    func setRrefreshControlTitle(title:String) {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: title, attributes: attributes)
        
    }
}


extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(redditLinks.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0 && redditLinks.count == 0) {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ZeroStateTableViewCell.cellIdentifier, for: indexPath) as? ZeroStateTableViewCell
            {
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: LinkTableViewCell.cellIdentifier, for: indexPath) as? LinkTableViewCell
            {
                cell.configureWith(link:redditLinks[indexPath.row], imageCompletion:{ (thumbImage) in
                    DispatchQueue.main.async {
                        if let visibleCell = tableView.cellForRow(at: indexPath) as? LinkTableViewCell {
                            visibleCell.setThumbnail(thumbImage ?? UIImage(named:"placeholder"))
                        }
                    }
                })
                
                return cell
            }
        }
        return UITableViewCell()
    }
    
}

extension Date {
    
    /// Returns the time passed since self til now, formatted as `X Y(s) ago`, if less than a minute ago then `Just now`
    func timeAgo() -> String {
        
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: Date())
        
        if let year = interval.year, year > 0 {
            return year == 1 ? "One year ago" :
                "\(year)" + " " + "years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "One month ago" :
                "\(month)" + " " + "months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "One day ago" :
                "\(day)" + " " + "days ago"
        } else if let hour = interval.hour, hour > 0 {
            return hour == 1 ? "One hour ago" :
                "\(hour)" + " " + "hours ago"
        } else if let minute = interval.minute, minute > 0 {
            return minute == 1 ? "One minute ago" :
                "\(minute)" + " " + "minutes ago"
        } else {
            return "Just now"
            
        }
        
    }
}
