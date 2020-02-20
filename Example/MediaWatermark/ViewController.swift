//
//  ViewController.swift
//  MediaWatermark
//
//  Created by Sergei on 03/05/2017.
//  Copyright © 2017 rubygarage. All rights reserved.
//

import UIKit
import MobileCoreServices
import MediaWatermark
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    
    var imagePickerController: UIImagePickerController! = nil
    var player: AVPlayer! = nil
    var playerLayer: AVPlayerLayer! = nil
    
    enum ActionType {
        case watermark, merge
    }
    
    private var type: ActionType!
    
    // MARK: - view controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // MARK: - setup
    func setup() {
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
    }
    
    // MARK: - actions
    @IBAction func openMediaButtonDidTap(_ sender: Any) {
        type = .watermark
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func openMediaForMerge(_ sender: Any) {
        type = .merge
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[.mediaType] as! String
        picker.dismiss(animated: true, completion: nil)
        
        if (mediaType == kUTTypeVideo as String) || (mediaType == kUTTypeMovie as String) {
            let videoUrl = info[.mediaURL] as! URL
            type == .watermark ? watermarkVideo(url: videoUrl):mergeVideo(url: videoUrl)
        } else {
            let image = info[.originalImage] as? UIImage
            watermarkImage(image: image!)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - processing
    func watermarkImage(image: UIImage) {
        playerLayer?.removeFromSuperlayer()

        resultImageView.image = nil
        resultImageView.subviews.forEach({$0.removeFromSuperview()})
        
        let item = MediaItem(image: image)
        
        let logoImage = UIImage(named: "logo")
        
        let firstElement = MediaElement(image: logoImage!)
        firstElement.frame = CGRect(x: 0, y: 0, width: logoImage!.size.width, height: logoImage!.size.height)
        
        let secondElement = MediaElement(image: logoImage!)
        secondElement.frame = CGRect(x: 100, y: 100, width: logoImage!.size.width, height: logoImage!.size.height)
        
        item.add(elements: [firstElement, secondElement])
        
        let mediaProcessor = MediaProcessor()
        mediaProcessor.processElements(item: item) { [weak self] (result, error) in
            self?.resultImageView.image = result.image
        }
    }
    
    func watermarkVideo(url: URL) {
        resultImageView.image = nil
        
        if let item = MediaItem(url: url) {
            let logoImage = UIImage(named: "rglogo")
            
            let firstElement = MediaElement(image: logoImage!)
            firstElement.frame = CGRect(x: 0, y: 0, width: logoImage!.size.width, height: logoImage!.size.height)
            
            let secondElement = MediaElement(image: logoImage!)
            secondElement.frame = CGRect(x: 150, y: 150, width: logoImage!.size.width, height: logoImage!.size.height)
            
            item.add(elements: [firstElement, secondElement])
            
            let mediaProcessor = MediaProcessor()
            mediaProcessor.processElements(item: item) { [weak self] (result, error) in
                DispatchQueue.main.async {
                    self?.playVideo(url: result.processedUrl!, view: (self?.resultImageView)!)
                }
            }
        }
    }
    
    func mergeVideo(url: URL) {
        progress.isHidden = false
        
        NativeEditor.vStack(urls: [url, url]) { [weak self] result in
            guard let _ws = self else { return }
            DispatchQueue.main.async {
                _ws.progress.isHidden = true
                
                switch result {
                case .success(let url):
                    _ws.playVideo(url: url, view: _ws.resultImageView)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func playVideo(url: URL, view: UIView) {
        playerLayer?.removeFromSuperlayer()
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        
        view.layer.addSublayer(playerLayer)
        
        player.play()
    }
}

