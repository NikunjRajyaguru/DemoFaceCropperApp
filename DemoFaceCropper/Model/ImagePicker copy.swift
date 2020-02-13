//
//  ImagePicker.swift
//  DemoFaceCropper
//
//  Created by Apple on 03/02/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

//MARK:- PROTOCOL ImagePickerDelegate -
public protocol ImagePickerDelegate : class {
    func didSelect(Image : UIImage?)
}


open class ImagePicker: NSObject {

    //MARK:- VARIABLES -
    private let pickerController            : UIImagePickerController
    private weak var presentationController : UIViewController?
    private weak var imageDelegate          : ImagePickerDelegate?
    
    private let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
    
    //MARK: - INITIALIZE & ASSIGN  -
    public init(presentationController : UIViewController, delegate : ImagePickerDelegate) {
        
        self.pickerController = UIImagePickerController()
        super.init()

        self.presentationController = presentationController
        self.imageDelegate = delegate
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    
    //MARK: - Check for Camera Access  -
    private func checkCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .authorized: break
        // - Prompt alert for Camera Access Initially -
        case .denied:
            self.showAlertController(title: "IMPORTANT", message: "Camera access required")
        // - Prompt alert if Camera Access is Not Determined  -
        case .notDetermined:
            self.showAlertController(title: "IMPORTANT", message: "Camera access required for capturing photos!", isforSetting: true)
        default:
            self.showAlertController(title: "IMPORTANT", message: "Camera access required")
        }
    }

    private func showAlertController(title: String, message: String, isforSetting : Bool = false){
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(cancelAction)
        if isforSetting {
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel) { alert in
                if AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: .front).devices.count > 0 {
                    AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                        DispatchQueue.main.async() {
                            self.checkCamera() } }
                }})
        }else{
            alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
                
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }))
        }
        self.presentationController?.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Check and Add SourceType if Available, Present PickerController  -
    private func action(for type : UIImagePickerController.SourceType, title : String) -> UIAlertAction? {
        
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            if type == .camera {
                self.checkCamera()
            }
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true, completion: nil)
        }
    }

    //MARK: - Init and Show ActionSheet -
    public func present(from sourceView : UIView) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        if let action = self.action(for: .camera, title: "Take Photo") {
            alertController.addAction(action)
        }
        
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        
        if let action = self.action(for: .photoLibrary, title: "Photo Library") {
            alertController.addAction(action)
        }
        
        alertController.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.presentationController?.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Dismiss Picker Controller
    private func pickerController(_ controller : UIImagePickerController, didSelect image:  UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        self.imageDelegate?.didSelect(Image: image)
    }
}

//MARK: - EXTENSIONS -
//MARK: - UIImagePickerController Delegate Method -
extension ImagePicker : UIImagePickerControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage]  as? UIImage else {
            return self.pickerController(picker, didSelect : nil)
        }
        self.pickerController(picker, didSelect : image)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect : nil)
    }
}

//MARK: - NavigationController Delegate Method -
extension ImagePicker : UINavigationControllerDelegate {
}
