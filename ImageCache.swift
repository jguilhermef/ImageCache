//
//  ImageCache.swift
//  DesafioiOS
//
//  Created by José Guilherme de Lima Freitas on 21/07/2018.
//  Copyright © 2018 JG. All rights reserved.
//

import UIKit

class ImageCache {
    static var shared = ImageCache()
    
    private var imageQueue = DispatchQueue(label: "ImageFetchQueue", attributes: .concurrent)
    private var images: [URL: UIImage] = [:] {
        didSet {
            if images.count >= poolSize {
                print("Limit is gone")
            }
        }
    }
    private var poolSize: Int
    
    init(poolSize: Int = 50) {
        self.poolSize = poolSize
    }
    
    func fetchImage(with url: URL, completion: @escaping (UIImage?) -> Void) {
        if let image = images[url] {
            completion(image)
            return
        }
        
        if Thread.isMainThread {
            imageQueue.async {
                self.handleTask(with: url, completion: completion)
            }
        } else {
            handleTask(with: url, completion: completion)
        }
    }
    
    private func handleTask(with url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            if error != nil {
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            guard let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            self.images[url] = image
            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()
    }
}

extension UIImageView {
    func loadImage(with url: URL) {
        ImageCache.shared.fetchImage(with: url) { (image) in
            if let image = image {
                self.image = image
            }
        }
    }
}
