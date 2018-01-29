//
//  ShoesBrowserVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 1/14/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import UIKit
import CoreData
import MGSwipeTableCell

class ShoesBrowserVC: ChildVC, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ShoesDelegate {
  @IBOutlet var viewControllerTitle: UILabel!
  @IBOutlet var showMenuButton: UIButton!
  @IBOutlet var reverseSortButton: UIButton!
  @IBOutlet var instructionsLabel: UILabel!
  @IBOutlet var tableView: UITableView!
  @IBOutlet var sortFieldButton: UIButton!
  @IBOutlet var sortFieldLabel: UILabel!
  @IBOutlet var showPickerButton: UIButton!
  @IBOutlet var pickerToolbar: UIToolbar!
  @IBOutlet var fieldPicker: UIPickerView!
  
  private static let rowHeight: CGFloat = 92.0
  private static let tapToAdd = "Tap + to add a pair of shoes."
  private static let delete = "Delete"
  private static let edit = "Edit"
  private var oldShoesSortField: Int!
  static let tapFontSize: CGFloat = 18.0
  
  private var shoesToEdit: Shoes?
  var pairs: [Shoes] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.allowsSelection = false
    fieldPicker.dataSource = self
    fieldPicker.delegate = self
    tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    pickerToolbar.isHidden = true
    fieldPicker.isHidden = true
    fieldPicker.selectRow(SettingsManager.getShoesSortField().pickerPosition(), inComponent: 0, animated: false)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if pairs.count == 0 {
      fetchPairs()
    }
    showPickerButton.setTitle(SettingsManager.getShoesSortField().asString(), for: UIControlState())
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    pairs.sort { ShoesSortField.compare($0, shoes2: $1) }
    tableView.reloadData()
  }
  
  private func fetchPairs() {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shoes")
    let context = CDManager.sharedCDManager.context!
    fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Shoes", in: context)
    let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]
    pairs = (try? context.fetch(fetchRequest)) as! [Shoes]
  }

  
  @IBAction func showMenu(_ sender: UIButton) {
    showMenu()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if pairs.count > 0 {
      return pairs.count
    }
    else {
      return 1
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if pairs.count > 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ShoesCell") as? ShoesCell
      
      let deleteButton = MGSwipeButton(title: ShoesBrowserVC.delete, backgroundColor: UiConstants.intermediate1Color, callback: {
          (sender: MGSwipeTableCell!) -> Bool in
        CDManager.sharedCDManager.context.delete(self.pairs[(indexPath as NSIndexPath).row])
        CDManager.saveContext()
        self.pairs.remove(at: (indexPath as NSIndexPath).row)
        self.tableView.reloadData()
        return true
      })
      deleteButton.titleLabel!.font = UIFont(name: UiConstants.globalFont, size: UiConstants.cellButtonTitleSize)!
      deleteButton.setTitleColor(UiConstants.darkColor, for: UIControlState())
      let editButton = MGSwipeButton(title: ShoesBrowserVC.edit, backgroundColor: UiConstants.intermediate2Color, callback: {
          (sender: MGSwipeTableCell!) -> Bool in
        self.shoesToEdit = self.pairs[(indexPath as NSIndexPath).row]
        self.performSegue(withIdentifier: "pan new shoes", sender: self)
        return true
      })
      editButton.titleLabel!.font = UIFont(name: UiConstants.globalFont, size: UiConstants.cellButtonTitleSize)!
      editButton.setTitleColor(UiConstants.darkColor, for: UIControlState())
      cell!.rightButtons = [deleteButton, editButton]
      cell!.rightSwipeSettings.transition = MGSwipeTransition.rotate3D
      cell?.displayShoes(pairs[(indexPath as NSIndexPath).row], shoesDelegate: self)
      instructionsLabel.isHidden = false
      sortFieldButton.isHidden = false
      sortFieldLabel.isHidden = false
      reverseSortButton.isHidden = false
      return cell!
    }
    else {
      let cell = UITableViewCell(style: .default, reuseIdentifier: "EmptyShoesCell")
      cell.textLabel?.textColor = UiConstants.intermediate1Color
      cell.textLabel?.font = UIFont(name: UiConstants.globalFont, size: ShoesBrowserVC.tapFontSize)
      cell.textLabel?.text = ShoesBrowserVC.tapToAdd
      cell.backgroundColor = UiConstants.darkColor
      instructionsLabel.isHidden = true
      sortFieldButton.isHidden = true
      sortFieldLabel.isHidden = true
      reverseSortButton.isHidden = true
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return ShoesBrowserVC.rowHeight
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "pan new shoes" {
      (segue.destination as! ShoesEditorVC).shoes = shoesToEdit
      shoesToEdit = nil
      (segue.destination as! ShoesEditorVC).shoesDelegate = self
    }
  }
  
  @IBAction func addShoes() {
    performSegue(withIdentifier: "pan new shoes", sender: self)
  }
  
  @IBAction func returnFromSegueActions(_ sender: UIStoryboardSegue) {}

  override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
    return UnwindPanSegue(identifier: identifier!, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
    })
  }
  
  func receiveShoes(_ shoes: Shoes, isNew: Bool) {
    if isNew {
      pairs.append(shoes)
    }
    if shoes.isCurrent.boolValue {
      makeNewIsCurrent(shoes)
    }
    else {
      tableView.reloadData()
    }
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return ShoesSortField.all().count;
  }
  
  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    return NSAttributedString(string: ShoesSortField.sortFieldForPosition(row).asString(), attributes: [NSAttributedStringKey.foregroundColor: UiConstants.intermediate3Color])
  }
  
  func makeNewIsCurrent(_ newIsCurrent: Shoes) {
    for shoes in pairs {
      if shoes != newIsCurrent && shoes.isCurrent.boolValue {
        shoes.isCurrent = false
      }
    }
    CDManager.saveContext()
    tableView.reloadData()
  }
  
  override var prefersStatusBarHidden : Bool {
    return true
  }
  
  @IBAction func reverseSort() {
    SettingsManager.setSortType(SortType.reverseSortType(SettingsManager.getSortType()))
    pairs.sort { ShoesSortField.compare($0, shoes2: $1) }
    tableView.reloadData()
  }
  
  
  @IBAction func showPicker() {
    pickerToolbar.isHidden = false
    fieldPicker.isHidden = false
    oldShoesSortField = fieldPicker.selectedRow(inComponent: 0)
  }
  
  
  @IBAction func dismissPicker(_ sender: UIBarButtonItem) {
    pickerToolbar.isHidden = true
    fieldPicker.isHidden = true
    let newShoesSortField = fieldPicker.selectedRow(inComponent: 0)
    if newShoesSortField != oldShoesSortField {
      SettingsManager.setShoesSortField(ShoesSortField.sortFieldForPosition(newShoesSortField))
      showPickerButton.setTitle(SettingsManager.getShoesSortField().asString(), for: UIControlState())
      pairs.sort { ShoesSortField.compare($0, shoes2: $1) }
      tableView.reloadData()
    }
  }
}
