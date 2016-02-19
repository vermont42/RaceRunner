//
//  Products.swift
//  RaceRunner
//
//  Created by Joshua Adams on 2/14/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

public enum Products {
  
  private static let Prefix = "biz.joshadams.RaceRunner."
  public static let runningHorse = Prefix + "runninghorse"
  public static let broadcastRuns = Prefix + "broadcastruns"
  public static let NightlyRage         = Prefix + "nightlyrage"
  public static let Updog               = Prefix + "updog"
  private static let productIdentifiers: Set<ProductIdentifier> = [Products.runningHorse, Products.broadcastRuns]
  public static let store = IapHelper(productIdentifiers: Products.productIdentifiers)
}

func resourceNameForProductIdentifier(productIdentifier: String) -> String? {
  return productIdentifier.componentsSeparatedByString(".").last
}