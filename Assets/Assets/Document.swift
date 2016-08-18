//
//  Document.swift
//  Assets
//
//  Created by Arnaud Thiercelin on 8/5/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class Document: NSDocument {

	var projectDirectoryURL: URL!
	var designerDirectoryURL: URL!
	var assetsList = [AssetsPair]()
	
	override init() {
	    super.init()
		// Add your subclass-specific initialization here.
	}

	override class func autosavesInPlace() -> Bool {
		return true
	}

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: "Document Window Controller") as! NSWindowController
		
		self.addWindowController(windowController)
		
		let viewController = windowController.contentViewController as! ViewController
		viewController.representedObject = self
	}

	override func data(ofType typeName: String) throws -> Data {

		var rootObject = [String : Any]()
		if self.projectDirectoryURL != nil {
			rootObject["projectDirectoryURL"] = projectDirectoryURL
		}
		if  self.designerDirectoryURL != nil {
			rootObject["designerDirectoryURL"] = designerDirectoryURL
		}
		rootObject["assetsList"] = assetsList
		let data = NSKeyedArchiver.archivedData(withRootObject: rootObject)
		
		return data
	}

	override func read(from data: Data, ofType typeName: String) throws {		
		guard let unarchivedObject = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String : Any]? else {
			NSLog("Error loading the unarchived Object")
			return;
		}
		
		self.projectDirectoryURL = unarchivedObject["projectDirectoryURL"] as? URL
		self.designerDirectoryURL = unarchivedObject["designerDirectoryURL"] as? URL
		self.assetsList = unarchivedObject["assetsList"] as! [AssetsPair]
		
	}

	// MARK: - Data 
	
	func addAssetPair(_ assetPair: AssetsPair) {
		// TODO: Thread safety here
		self.assetsList.append(assetPair)
	}
	
	func resetAllData() {
		self.projectDirectoryURL = nil
		self.designerDirectoryURL = nil
		self.assetsList.removeAll()
	}
}

