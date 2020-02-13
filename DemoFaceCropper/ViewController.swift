//
//  ViewController.swift
//  DemoFaceCropper
//
//  Created by Apple on 03/02/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import FaceCropper

class ViewController: UIViewController {

    //MARK:- OUTLET
    @IBOutlet weak var imgview: UIImageView!
    @IBOutlet weak var clView: UICollectionView!
    
    //MARK:- VARIABLES
    // - Create Object of ImagePicker -
    var imagepicker : ImagePickerHelper!
    var faceArr     : [UIImage]?
    
    
    //MARK:- VIEW METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clView.dataSource = self
        
        // - Initialize ImagePicker Object -
        self.imagepicker = ImagePickerHelper(presentationController: self, delegate: self)
    }
    
    //MARK: - VOID METHODS
    func faceDetectinImages(image: UIImage){
        self.faceArr?.removeAll()
        image.face.crop { result in
              switch result {
              case .success(let faces):
                self.faceArr = faces
              case .notFound: break
              case .failure(let error):
                print("error::", error.localizedDescription)
                break
              }
            self.clView.reloadData()
        }
    }

    //MARK:- CLICKED EVENTS
    @IBAction func btnPickImageClicked(_ sender: UIButton) {
        // - Present UIPickerController -
        self.imagepicker.present(from: sender)
    }
}

//MARK:- EXTENSIONS
extension ViewController : ImagePickerDelegate {
    func didSelect(Image: UIImage?) {
        self.imgview.image = Image
        if let img = Image {
            self.faceDetectinImages(image: img)
        }
    }
}

//MARK:- Extension UICollectionView Datasource
extension ViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        faceArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomClsCell
        cell.imgView.image = self.faceArr?[indexPath.row]
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width / 3) , height: 100)
    }
}
