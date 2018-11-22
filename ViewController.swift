//
//  ViewController.swift
//  meme
//
//  Created by Ahmed Fahmy on 18/11/2018.
//  Copyright © 2018 Mohtaref. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    var memedImage: UIImage!
    var pickerController:UIImagePickerController!
    @IBOutlet weak var bottomNavBar: UIToolbar!
    @IBOutlet weak var topNavBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    let memeTextAttributes:[NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor:UIColor.black,
        NSAttributedString.Key.foregroundColor:UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth:-2
    ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        topText.textAlignment = .center
        bottomText.textAlignment = .center
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        topText.delegate = self
        bottomText.delegate = self
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.center
        
        let attributedString = NSMutableAttributedString(string: "Your String", attributes: [NSAttributedString.Key.paragraphStyle:paragraph])
        topText.attributedText = attributedString
        bottomText.attributedText = attributedString

        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        shareButton.isEnabled = imagePickerView.image != nil
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    @IBAction func pickAnImage(_ sender: Any) {
        pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
        pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.sourceType = .camera
        present(pickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imagePickerView.image = image
        }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
 
    // KeyBoard show and hide functions
    func subscribeToKeyboardNotifications() {
        
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self)
    }
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomText.isFirstResponder{
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomText.isFirstResponder{
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    struct Meme {
        var topText:String
        var bottomText:String
        var originalImage:UIImage
        var memedImage:UIImage
    }
    
    func save() {
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    
    func generateMemedImage() -> UIImage {
        bottomNavBar.isHidden = true
        topNavBar.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        bottomNavBar.isHidden = false
        topNavBar.isHidden = false
        return memedImage
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        let memeImage = generateMemedImage()
        let ac = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        
        ac.completionWithItemsHandler = {
            activity,success,items,error in
            if success{
                self.save()
                self.dismiss(animated: true, completion: nil);
            }
        }
        present(ac,animated: true)
    }

    @IBAction func cancelMeme(_ sender: Any) {
        clearView()
    }
    
    func clearView() {
        imagePickerView.image = nil
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        shareButton.isEnabled = false
    }
    
}

extension ViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if topText.isFirstResponder{
            textField.text = ""
        }else if bottomText.isFirstResponder{
            textField.text = ""
        }
        textField.returnKeyType = .done //set Return button in keyboard to Done
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //self.view.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
    
}
