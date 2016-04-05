//
//  DetailPhotoViewController.swift
//  Virtual Tourist - HoffSilva
//
//  Created by Hoff Henry Pereira da Silva on 25/03/16.
//  Copyright © 2016 Hoff Silva. All rights reserved.
//

import UIKit

class DetailPhotoViewController: UIViewController {
    
    @IBOutlet weak var imageView_DetailedPhoto: UIImageView!
    
    @IBOutlet weak var label_DetailedPhotoTitle: UILabel!
    
    var photo : Photo!
    
    override func viewWillAppear(animated: Bool) {
        print(photo.jpgName!)
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! + "/" + self.photo.jpgName!
        imageView_DetailedPhoto.image = UIImage(contentsOfFile: path)
        label_DetailedPhotoTitle.text = photo.titulo!
    }
    
}
