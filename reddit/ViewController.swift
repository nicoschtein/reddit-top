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
        fethInitialData()
        
    }
    @objc func fethInitialData() {
        setRrefreshControlTitle(title: "Refreshing Reddit Top...")
        
        networkManager.getTopListing(paginate:false) {[weak self] (links, error) in
            if let error = error {
                print("There was an error: \(error)")
            } else if let links = links {
                self?.redditLinks = links
                DispatchQueue.main.async {
                    if let strongSelf = self {
                        strongSelf.tableView.refreshControl?.endRefreshing()
                        strongSelf.setRrefreshControlTitle(title: "Pull to refresh Reddit Top")
                        strongSelf.tableView.reloadData()
                    }
                }
            }
        }
    }
    func fethNewData() {

        networkManager.getTopListing(paginate:true) {[weak self] (links, error) in
            if let error = error {
                print("There was an error: \(error)")
            } else if let links = links {
                self?.redditLinks.append(contentsOf: links)
                DispatchQueue.main.async {
                    if let strongSelf = self {
                        let indexPathsToInsert = strongSelf.calculateIndexPathsToReload(from: links)
                        strongSelf.tableView.insertRows(at: indexPathsToInsert, with: UITableView.RowAnimation.automatic)
                    }
                }
            }
        }

    }
    func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fethInitialData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        setRrefreshControlTitle(title: "Pull to refresh Reddit Top")
    }
    
    func setRrefreshControlTitle(title:String) {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: title, attributes: attributes)
        
    }
}


extension ViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return max(redditLinks.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            if (networkManager.fetching && (indexPath.row == redditLinks.count || indexPath.row == redditLinks.count+1)) {
                if let cell = tableView.dequeueReusableCell(withIdentifier: LoadingStateTableViewCell.cellIdentifier, for: indexPath) as? LoadingStateTableViewCell
                {
                    return cell
                }
            }
        } else {
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
            }
            return UITableViewCell()
        }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Dismiss"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            redditLinks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        redditLinks[indexPath.row].app_user_read = true
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if redditLinks.count>0 && !networkManager.fetching {
            DispatchQueue.main.async { [weak self] in
                if let strongSelf = self, let _ = tableView.cellForRow(at: IndexPath(row: strongSelf.redditLinks.count - 1, section: 0)) {
                    self?.fethNewData()
                }
            }
        }
    }
    private func calculateIndexPathsToReload(from newLinks: [Link]) -> [IndexPath] {
        let startIndex = redditLinks.count - newLinks.count
        let endIndex = startIndex + newLinks.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
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
