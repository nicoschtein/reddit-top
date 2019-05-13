//
//  ImageViewController.swift
//  reddit
//
//  Created by Nicolas Schteinschraber on 13/05/2019.
//  Copyright © 2019 Schtein. All rights reserved.
//

import UIKit
import WebKit
import Photos

class ImageViewController: UIViewController {
    
    var imageUrl: String?
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var saveButton: UIButton!
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
    
    
    func showNoPermissionAlert() {
        DispatchQueue.main.async {
            self.present(UIAlertController(title: "Error", message: "No permission to save image!", preferredStyle: UIAlertController.Style.alert), animated: true, completion: {self.perform(#selector(self.dismissAlert), with: nil, afterDelay: 2.0)})
        }
    }
    @objc func dismissAlert() {
        self.dismiss(animated: true, completion: nil)
    }
    func showErrorAlert() {
        DispatchQueue.main.async {
            
            self.present(UIAlertController(title: "Error", message: "The photo has not been saved to camera roll!", preferredStyle: UIAlertController.Style.alert), animated: true, completion: {self.perform(#selector(self.dismissAlert), with: nil, afterDelay: 2.0)})
        }
    }
    func showSuccessAlert() {
        DispatchQueue.main.async {
            self.present(UIAlertController(title: "Photo saved", message: "Photo has been saved to camera roll!", preferredStyle: UIAlertController.Style.alert), animated: true, completion: {self.perform(#selector(self.dismissAlert), with: nil, afterDelay: 2.0)})
        }
    }

    func saveImage() {
        if let imageUrl = self.imageUrl {
            NetworkManager.loadImageFromWeb(url: imageUrl) { [weak self](image) in
                if let strongSelf = self {
                    if let image = image {
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAsset(from: image)
                        }, completionHandler: { success, error in
                            if let strongSelf = self {
                                if success {
                                    // Saved successfully!
                                    strongSelf.showSuccessAlert()
                                } else {
                                    strongSelf.showErrorAlert()
                                }
                                strongSelf.saveButton.isEnabled = true
                                
                            }
                            
                        })
                    } else {
                        strongSelf.showErrorAlert()
                        strongSelf.saveButton.isEnabled = true
                    }
                }
            }
        } else {
            self.showErrorAlert()
            saveButton.isEnabled = true
        }

    }
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveButton.isEnabled = false
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            switch status {
            case .authorized:
                self?.saveImage()
            default:
                if let strongSelf = self {
                    strongSelf.showNoPermissionAlert()
                    strongSelf.saveButton.isEnabled = true
                }
                break
            }
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
