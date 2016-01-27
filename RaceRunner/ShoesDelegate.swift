//
//  ShoesDelegate.swift
//  RaceRunner
//
//  Created by Joshua Adams on 1/15/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import Foundation
import CoreData

protocol ShoesDelegate: class {
  func receiveShoes(shoes: Shoes, isNew: Bool)
  func makeNewIsCurrent(newIsCurrent: Shoes)
}