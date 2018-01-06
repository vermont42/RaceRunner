//
//  ShoesEditorVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 1/15/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import UIKit
import CoreData

class ShoesEditorVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  @IBOutlet var viewControllerTitle: UILabel!
  @IBOutlet var name: UITextField!
  @IBOutlet var currentMileage: UITextField!
  @IBOutlet var maximumMileage: UITextField!
  @IBOutlet var doneButton: UIButton!
  @IBOutlet var thumbnail: UIImageView!
  @IBOutlet var isCurrent: UIImageView!
  @IBOutlet var currentMileageLabel: UILabel!
  @IBOutlet var maximumMileageLabel: UILabel!
  private let imagePicker = UIImagePickerController()
  var shoes: Shoes?
  weak var shoesDelegate: ShoesDelegate!
  
  private static let imperialMileageLabel = "Current Mileage:"
  private static let imperialMaxMileageLabel = "Maximum Mileage:"
  private static let metricMileageLabel = "Current Klicks:"
  private static let metricMaxMileageLabel = "Maximum Klicks:"
  private static let editShoes = "Edit Shoes"
  private static let newShoes = "New Shoes"
  private var choosingThumbnail = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    name.delegate = self
    currentMileage.delegate = self
    maximumMileage.delegate = self
    imagePicker.delegate = self
    thumbnail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShoesEditorVC.chooseThumbnail)))
    thumbnail.isUserInteractionEnabled = true
    isCurrent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShoesEditorVC.toggleIsCurrent)))
    isCurrent.isUserInteractionEnabled = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if !choosingThumbnail {
      if SettingsManager.getUnitType() == .Imperial {
        currentMileageLabel.text = ShoesEditorVC.imperialMileageLabel
        maximumMileageLabel.text = ShoesEditorVC.imperialMaxMileageLabel
      }
      else {
        currentMileageLabel.text = ShoesEditorVC.metricMileageLabel
        maximumMileageLabel.text = ShoesEditorVC.metricMaxMileageLabel
      }
      if let shoes = shoes {
        name.text = shoes.name
        currentMileage.text = Converter.stringifyKilometers(shoes.kilometers.floatValue)
        maximumMileage.text = Converter.stringifyKilometers(shoes.maxKilometers.floatValue)
        if shoes.isCurrent.boolValue {
          isCurrent.image = Shoes.checked
        }
        else {
          isCurrent.image = Shoes.unchecked
        }
        thumbnail.image = UIImage(data: shoes.thumbnail as Data)
        viewControllerTitle.text = ShoesEditorVC.editShoes
      }
      else {
        name.text = Shoes.defaultName
        currentMileage.text = Converter.stringifyKilometers(Shoes.defaultKilometers)
        maximumMileage.text = Converter.stringifyKilometers(Shoes.defaultMaxKilometers)
        isCurrent.image = Shoes.checked
        thumbnail.image = Shoes.defaultThumbnail
        viewControllerTitle.text = ShoesEditorVC.newShoes
        disableDoneButton()
      }
      viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    }
  }
  
  override func didReceiveMemoryWarning() {
    LowMemoryHandler.handleLowMemory(self)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
    super.touchesBegan(touches, with: event)
  }
  
  @IBAction func cancel() {
    performSegue(withIdentifier: "unwind pan", sender: self)
  }
  
  @IBAction func done() {
    var isNew = false
    if shoes == nil {
      shoes = NSEntityDescription.insertNewObject(forEntityName: "Shoes", into: CDManager.sharedCDManager.context) as? Shoes
      isNew = true
    }
    shoes!.name = name.text!
    shoes!.kilometers = NSNumber(value: Converter.floatifyMileage(currentMileage.text!))
    shoes!.maxKilometers = NSNumber(value: Converter.floatifyMileage(maximumMileage.text!))
    if isCurrent.image!.isEqual(Shoes.checked) {
      shoes!.isCurrent = true
    }
    else {
      shoes!.isCurrent = false
    }
    shoes!.thumbnail = UIImagePNGRepresentation(thumbnail.image!)!
    CDManager.saveContext()
    shoesDelegate.receiveShoes(shoes!, isNew: isNew)
    performSegue(withIdentifier: "unwind pan", sender: self)
  }
  
  override var prefersStatusBarHidden : Bool {
    return true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField == currentMileage || textField == maximumMileage {
      if let _ = Int(string) , textField.text!.count < Shoes.maxNumberLength + 1 {
        return true
      }
      else {
        return false
      }
    }
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if name.text! != "" && currentMileage.text! != "" && maximumMileage.text! != "" {
      enableDoneButton()
    }
    else {
      disableDoneButton()
    }
    textField.resignFirstResponder()
    return true
  }
      
  func disableDoneButton() {
    doneButton.alpha = UiConstants.notDoneAlpha
    doneButton.isEnabled = false
  }
  
  func enableDoneButton() {
    doneButton.alpha = 1.0
    doneButton.isEnabled = true
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    dismiss(animated: true, completion: { self.choosingThumbnail = false })
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      thumbnail.image = pickedImage
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: { self.choosingThumbnail = false })
  }
      
  @IBAction func chooseThumbnail() {
    choosingThumbnail = true
    present(imagePicker, animated: true, completion: nil)
  }
  
  @objc func toggleIsCurrent() {
    if isCurrent.image!.isEqual(Shoes.checked) {
      isCurrent.image = Shoes.unchecked
    }
    else {
      isCurrent.image = Shoes.checked
    }
  }
}
