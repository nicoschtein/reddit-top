//
//  ImageViewController.swift
//  reddit
//
//  Created by Nicolas Schteinschraber on 13/05/2019.
//  Copyright © 2019 Schtein. All rights reserved.
//

import UIKit
import WebKit

class ImageViewController: UIViewController {

    var imageUrl: String?
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            webView.load(URLRequest.init(url: url))
        } else {
            webView.stopLoading()
            dismiss(animated: true, completion: nil)
        }
    }
    

    @IBAction func backButtonTapped(_ sender: Any) {
        webView.stopLoading()
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    static var identifier:String {
        return "ImageViewController"
    }
}
