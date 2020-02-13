//
//  ImagePickerHelper.swift
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


open class ImagePickerHelper: NSObject {

    //MARK:- ENUM -
    private enum actionsKeys : String {
        case takephoto      = "Take Photos"
        case cameraroll     = "Camera Roll"
        case photolibrary   = "Photo Librabry"
        case cancel         = "Cancel"
        case okay           = "Okay"
        case allowcamera    = "Allow Camera"
    }
    
    private struct alertTitleMsgs {
        static let title      = "IMPORTANT!"
        static let message    = "Camera access required"
    }
    
    //MARK:- VARIABLES -
    private let pickerController            : UIImagePickerController
    private weak var presentationController : UIViewController?
    private weak var imageDelegate          : ImagePickerDelegate?
    
    private let cancelAction = UIAlertAction(title: actionsKeys.cancel.rawValue, style: UIAlertAction.Style.cancel, handler: nil)
    
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
        // - Prompt alert if Camera Access is Not Determined  -
        case .notDetermined: self.showAlertController(title: alertTitleMsgs.title, message: alertTitleMsgs.message, isforSetting: true)
        // - Prompt alert for Camera Access Initially -
        default: self.showAlertController(title: alertTitleMsgs.title, message: alertTitleMsgs.message)
        }
    }
    
    private func showAlertController(title: String, message: String, isforSetting : Bool = false){
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        
        if isforSetting {
            alert.addAction(UIAlertAction(title: inputString(.okay), style: .cancel) { alert in
                if AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: .front).devices.count > 0 {
                    AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                        DispatchQueue.main.async() {
                            self.checkCamera() } }
                }})
        }else{
            alert.addAction(cancelAction)
            alert.addAction(UIAlertAction(title: inputString(.allowcamera), style: .default, handler: { (alert) -> Void in
                
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
        
        if let action = self.action(for: .camera, title: inputString(.takephoto)) {
            alertController.addAction(action)
        }
        
        if let action = self.action(for: .savedPhotosAlbum, title: inputString(.cameraroll)) {
            alertController.addAction(action)
        }
        
        if let action = self.action(for: .photoLibrary, title: inputString(.photolibrary)) {
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
    
    private func inputString(_ action : actionsKeys) -> String {
        return action.rawValue
    }
}

//MARK: - EXTENSIONS -
//MARK: - UIImagePickerController Delegate Method -
extension ImagePickerHelper : UIImagePickerControllerDelegate {
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
extension ImagePickerHelper : UINavigationControllerDelegate {
}
