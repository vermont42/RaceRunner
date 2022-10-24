//
//  ShoesDelegate.swift
//  RaceRunner
//
//  Created by Josh Adams on 1/15/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import CoreData
import Foundation

protocol ShoesDelegate: AnyObject {
  func receiveShoes(_ shoes: Shoes, isNew: Bool)
  func makeNewIsCurrent(_ newIsCurrent: Shoes)
}
