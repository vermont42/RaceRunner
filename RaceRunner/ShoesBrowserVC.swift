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
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    pickerToolbar.hidden = true
    fieldPicker.hidden = true
    fieldPicker.selectRow(SettingsManager.getShoesSortField().pickerPosition(), inComponent: 0, animated: false)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if pairs.count == 0 {
      fetchPairs()
    }
    showPickerButton.setTitle(SettingsManager.getShoesSortField().asString(), forState: .Normal)
    viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
    pairs.sortInPlace { ShoesSortField.compare($0, shoes2: $1) }
    tableView.reloadData()
  }
  
  private func fetchPairs() {
    let fetchRequest = NSFetchRequest()
    let context = CDManager.sharedCDManager.context
    fetchRequest.entity = NSEntityDescription.entityForName("Shoes", inManagedObjectContext: context)
    let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]
    pairs = (try? context.executeFetchRequest(fetchRequest)) as! [Shoes]
  }

  
  @IBAction func showMenu(sender: UIButton) {
    showMenu()
  }
      
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if pairs.count > 0 {
      return pairs.count
    }
    else {
      return 1
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if pairs.count > 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier("ShoesCell") as? ShoesCell
      
      let deleteButton = MGSwipeButton(title: ShoesBrowserVC.delete, backgroundColor: UiConstants.intermediate1Color, callback: {
          (sender: MGSwipeTableCell!) -> Bool in
        CDManager.sharedCDManager.context.deleteObject(self.pairs[indexPath.row])
        CDManager.saveContext()
        self.pairs.removeAtIndex(indexPath.row)
        self.tableView.reloadData()
        return true
      })
      deleteButton.titleLabel!.font = UIFont(name: UiConstants.globalFont, size: UiConstants.cellButtonTitleSize)!
      deleteButton.setTitleColor(UiConstants.darkColor, forState: .Normal)
      let editButton = MGSwipeButton(title: ShoesBrowserVC.edit, backgroundColor: UiConstants.intermediate2Color, callback: {
          (sender: MGSwipeTableCell!) -> Bool in
        self.shoesToEdit = self.pairs[indexPath.row]
        self.performSegueWithIdentifier("pan new shoes", sender: self)
        return true
      })
      editButton.titleLabel!.font = UIFont(name: UiConstants.globalFont, size: UiConstants.cellButtonTitleSize)!
      editButton.setTitleColor(UiConstants.darkColor, forState: .Normal)
      cell!.rightButtons = [deleteButton, editButton]
      cell!.rightSwipeSettings.transition = MGSwipeTransition.Rotate3D
      cell?.displayShoes(pairs[indexPath.row], shoesDelegate: self)
      instructionsLabel.hidden = false
      sortFieldButton.hidden = false
      sortFieldLabel.hidden = false
      reverseSortButton.hidden = false
      return cell!
    }
    else {
      let cell = UITableViewCell(style: .Default, reuseIdentifier: "EmptyShoesCell")
      cell.textLabel?.textColor = UiConstants.intermediate1Color
      cell.textLabel?.font = UIFont(name: UiConstants.globalFont, size: ShoesBrowserVC.tapFontSize)
      cell.textLabel?.text = ShoesBrowserVC.tapToAdd
      cell.backgroundColor = UiConstants.darkColor
      instructionsLabel.hidden = true
      sortFieldButton.hidden = true
      sortFieldLabel.hidden = true
      reverseSortButton.hidden = true
      return cell
    }
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return ShoesBrowserVC.rowHeight
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "pan new shoes" {
      (segue.destinationViewController as! ShoesEditorVC).shoes = shoesToEdit
      shoesToEdit = nil
      (segue.destinationViewController as! ShoesEditorVC).shoesDelegate = self
    }
  }
  
  @IBAction func addShoes() {
    performSegueWithIdentifier("pan new shoes", sender: self)
  }
  
  @IBAction func returnFromSegueActions(sender: UIStoryboardSegue) {}

  override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
    return UnwindPanSegue(identifier: identifier!, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
    })
  }
  
  func receiveShoes(shoes: Shoes, isNew: Bool) {
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
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return ShoesSortField.all().count;
  }
  
  func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    return NSAttributedString(string: ShoesSortField.sortFieldForPosition(row).asString(), attributes: [NSForegroundColorAttributeName: UiConstants.intermediate3Color])
  }
  
  func makeNewIsCurrent(newIsCurrent: Shoes) {
    for shoes in pairs {
      if shoes != newIsCurrent && shoes.isCurrent.boolValue {
        shoes.isCurrent = false
      }
    }
    CDManager.saveContext()
    tableView.reloadData()
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  @IBAction func reverseSort() {
    SettingsManager.setSortType(SortType.reverse(SettingsManager.getSortType()))
    pairs.sortInPlace { ShoesSortField.compare($0, shoes2: $1) }
    tableView.reloadData()
  }
  
  
  @IBAction func showPicker() {
    pickerToolbar.hidden = false
    fieldPicker.hidden = false
    oldShoesSortField = fieldPicker.selectedRowInComponent(0)
  }
  
  
  @IBAction func dismissPicker(sender: UIBarButtonItem) {
    pickerToolbar.hidden = true
    fieldPicker.hidden = true
    let newShoesSortField = fieldPicker.selectedRowInComponent(0)
    if newShoesSortField != oldShoesSortField {
      SettingsManager.setShoesSortField(ShoesSortField.sortFieldForPosition(newShoesSortField))
      showPickerButton.setTitle(SettingsManager.getShoesSortField().asString(), forState: .Normal)
      pairs.sortInPlace { ShoesSortField.compare($0, shoes2: $1) }
      tableView.reloadData()
    }
  }
}