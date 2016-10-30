//
//  Products.swift
//  RaceRunner
//
//  Created by Joshua Adams on 2/14/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

public enum Products {
  
  fileprivate static let Prefix = "biz.joshadams.RaceRunner."
  public static let runningHorse = Prefix + "runninghorse"
  public static let broadcastRuns = Prefix + "broadcastruns"
  fileprivate static let productIdentifiers: Set<ProductIdentifier> = [Products.runningHorse, Products.broadcastRuns]
  public static let store = IapHelper(productIdentifiers: Products.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
  return productIdentifier.components(separatedBy: ".").last
}
