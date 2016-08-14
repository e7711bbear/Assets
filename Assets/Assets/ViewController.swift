//
//  ViewController.swift
//  Assets
//
//  Created by Arnaud Thiercelin on 8/5/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
	
	@IBOutlet var projectURLField: NSTextField!
	@IBOutlet var chooseProjectURLButton: NSButton!
	@IBOutlet var designerURLField: NSTextField!
	@IBOutlet var assetsTableView: NSTableView!
	@IBOutlet var assetsStatusField: NSTextField!
	@IBOutlet var publishButton: NSButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		self.assetsStatusField.stringValue = ""
	}
	
	override var representedObject: AnyObject? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	var document: Document {
		get {
			return representedObject as! Document
		}
	}
	
	@IBAction func chooseProjectURL(_ sender: AnyObject) {
		let openPanel = NSOpenPanel()
		
		openPanel.canChooseDirectories = true
		openPanel.canChooseFiles = false
		openPanel.allowsMultipleSelection = false
		openPanel.title = NSLocalizedString("Choose Project URL", comment: "Open Panel title")
		openPanel.message = NSLocalizedString("Please select the root folder of your project", comment: "Open Panel Message")
		
		openPanel.beginSheetModal(for: self.view.window!, completionHandler: { [unowned self] (response: NSModalResponse) in
			if response == NSFileHandlingPanelOKButton {
				guard let rootDirectory = openPanel.url else {
					NSLog("Invalid root directory for project")
					return
				}
				
				self.projectURLField.stringValue = rootDirectory.path
				guard rootDirectory.startAccessingSecurityScopedResource() == true else {
					NSLog("Failed to start accessing rootDirectory in Sandbox environment.")
					return
				}
				
				// clear model here.
				// assign root directory value
				self.document.projectDirectoryURL = rootDirectory
				
				// trigger parsing of path.
				self.findAllAssets(inside: rootDirectory.path)
				
				// Update assets status Field
				let assetCount = self.document.assetsList.count
				self.assetsStatusField.stringValue = "\(assetCount) assets"
				
				DispatchQueue.main.async {
					let notification = NSUserNotification()
					notification.title = NSLocalizedString("Parsing Finished", comment: "NSUserNotification title")
					notification.informativeText = NSLocalizedString("\(assetCount) assets were found", comment: "NSUserNotification informativeText")
					notification.soundName = NSUserNotificationDefaultSoundName
					
					NSUserNotificationCenter.default.deliver(notification)
				}
			}
			})
	}
	
	
	@IBAction func chooseDesignerURL(_ sender: AnyObject) {
		NSOpenPanel().beginSheet(self.view.window!, completionHandler: { (response: NSModalResponse) in
			if response == NSFileHandlingPanelOKButton {
				
			}
		})
	}
	
	@IBAction func publish(_ sender: AnyObject) {
	}
	
	
	func findAllAssets(inside startingPath: String) -> Void {
		
		let fileManager = FileManager.default
		
		do {
			let content = try fileManager.contentsOfDirectory(atPath: startingPath)
			
			for elementName in content {
				let startingPathNSString = startingPath as NSString
				let elementPath = startingPathNSString.appendingPathComponent(elementName)
				
				var isDirectory: ObjCBool = ObjCBool(false)
				let fileExists = fileManager.fileExists(atPath: elementPath, isDirectory: &isDirectory)
				
				if fileExists && isDirectory.boolValue == true { // -- These are folder, we need to dive in eventually.
					// Skipping directories which can't be opened.
					if fileManager.isExecutableFile(atPath: elementPath) == false {
						continue;
					}
					
					// Skipping hidden folders
					let hiddenFolderRange = elementName.range(of: ".")
					if hiddenFolderRange?.isEmpty == false &&
						hiddenFolderRange?.lowerBound == elementName.startIndex {
						
					}
					
					// We open the folder and continue processing
					self.findAllAssets(inside: elementPath)
				} else { // -- These are files, we need to add if valid assets.
					let elementNSString = elementName as NSString
					let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, elementNSString.pathExtension, nil)?.takeRetainedValue()
					
					guard UTI != nil else {
						NSLog("Failed to create UTI for \(elementPath)")
						continue
					}
					
					if UTTypeConformsTo(UTI!, kUTTypeImage) {
						let newAssetsPair = AssetsPair()
						let newProjectImage = ImageFile()
						
						newProjectImage.url = NSURL(fileURLWithPath: elementPath)
						newAssetsPair.projectImageFile = newProjectImage
						
						self.document.addAssetPair(newAssetsPair)
					}
					//DispatchQueue.main.async {
					//	self.assetsTableView.reloadData()
					//}
				}
			}
			
		} catch {
			NSLog("Error during reading content of path \(startingPath): \(error)")
		}
	}
	
}

