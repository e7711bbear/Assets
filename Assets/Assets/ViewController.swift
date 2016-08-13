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
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
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
				// trigger parsing of path.

				// Update assets status Field
				let assetCount = 123
				self.assetsStatusField.stringValue = "\(assetCount) assets."
				
				let notification = NSUserNotification()
				notification.title = NSLocalizedString("Parsing Finished", comment: "NSUserNotification title")
				notification.informativeText = NSLocalizedString("\(assetCount) assets were found.", comment: "NSUserNotification informativeText")
				notification.soundName = NSUserNotificationDefaultSoundName
				
				NSUserNotificationCenter.default.deliver(notification)
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
	
}

