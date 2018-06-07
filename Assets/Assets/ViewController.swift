//
//  ViewController.swift
//  Assets
//
//  Created by Arnaud Thiercelin on 8/5/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate{
	
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
		self.assetsTableView.delegate = self
		self.assetsTableView.dataSource = self
		self.assetsTableView.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: kUTTypeFileURL as String)])
		// TODO: For 10.13 use below
		//		self.assetsTableView.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
	}
	
	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	var document: Document! {
		get {
			return representedObject as? Document
		}
	}
	
	override func viewWillAppear() {
		if self.document != nil {
			if self.document.projectDirectoryURL != nil {
				self.projectURLField.stringValue = self.document.projectDirectoryURL.path.replacingOccurrences(of: NSHomeDirectory(), with: "~")
			}
			if self.document.designerDirectoryURL != nil {
				self.designerURLField.stringValue = self.document.designerDirectoryURL.path.replacingOccurrences(of: NSHomeDirectory(), with: "~")
			}
		self.assetsTableView.reloadData()
		}
	}
	
	@IBAction func chooseProjectURL(_ sender: AnyObject) {
		let openPanel = NSOpenPanel()
		
		openPanel.canChooseDirectories = true
		openPanel.canChooseFiles = false
		openPanel.allowsMultipleSelection = false
		openPanel.title = NSLocalizedString("Choose Project URL", comment: "Open Panel title")
		openPanel.message = NSLocalizedString("Please select the root folder of your project", comment: "Open Panel Message")
		
		openPanel.beginSheetModal(for: self.view.window!, completionHandler: { [unowned self] (response: NSApplication.ModalResponse) in
			if response.rawValue == NSFileHandlingPanelOKButton {
				guard let rootDirectory = openPanel.url else {
					NSLog("Invalid root directory for project")
					return
				}
				
				self.projectURLField.stringValue = rootDirectory.path.replacingOccurrences(of: NSHomeDirectory(), with: "~")
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
				self.assetsTableView.reloadData()
				
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
		var hasOnePair = false
		
		for assetPair in self.document.assetsList {
			if assetPair.projectAsset != nil &&
				assetPair.designerAsset != nil {
				hasOnePair = true
				break
			}
		}

		let alert = NSAlert()

		// We give proper notice to the user about the upcoming behaviors.
		if hasOnePair == false { // we tell the user we will parse and match.
			alert.messageText = NSLocalizedString("You have at least one matching pair of assets", comment: "Choose designer folder Alert Message")
			alert.informativeText = NSLocalizedString("Choosing a designer directory in this state will rebase your current designer assets. Do you wish to proceed?", comment: "Choose designer folder alert informative message")
			alert.addButton(withTitle: NSLocalizedString("OK", comment: "Alert at Choose designer folder OK Button"))
			alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Alert at choose designer folder cancel button"))
			let returnValue = alert.runModal()

			if returnValue == NSApplication.ModalResponse.cancel {
				return
			}
			
		} else { // we replace the root dir for the assets.
			alert.messageText = NSLocalizedString("You have no matching pair of assets", comment: "Choose designer folder Alert Message")
			alert.informativeText = NSLocalizedString("Choosing a designer directory in this state will look for assets in the chosen folder and try to auto match. Do you wish to proceed?", comment: "Choose designer folder alert informative message")
			alert.addButton(withTitle: NSLocalizedString("OK", comment: "Alert at Choose designer folder OK Button"))
			alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Alert at choose designer folder cancel button"))
			let returnValue = alert.runModal()
			
			if returnValue == NSApplication.ModalResponse.cancel {
				return
			}
		}
		
		let openPanel = NSOpenPanel()
		
		openPanel.canChooseDirectories = true
		openPanel.canChooseFiles = false
		openPanel.allowsMultipleSelection = false
		openPanel.title = NSLocalizedString("Choose Project URL", comment: "Open Panel title")
		openPanel.message = NSLocalizedString("Please select the root folder of your project", comment: "Open Panel Message")
		
		openPanel.beginSheetModal(for: self.view.window!, completionHandler: { [unowned self] (response: NSApplication.ModalResponse) in
			if response.rawValue == NSFileHandlingPanelOKButton {
				if hasOnePair == false { // if we have nothing, parse and automatch.
					
				} else { // if we have something, even 1 image, simple change the root folder of the assets.
					
				}
			}
		})
	}
	
	@IBAction func publish(_ sender: AnyObject) {
		let fileManager = FileManager.default
		
		if self.document.projectDirectoryURL == nil {
			NSLog("Error publishing, no project directory")
		} else {
			var isDirectory: ObjCBool = ObjCBool(false)

			if fileManager.fileExists(atPath: self.document.projectDirectoryURL.path, isDirectory: &isDirectory) {
				if isDirectory.boolValue {
					let overwriteAlert = NSAlert()
					overwriteAlert.messageText = NSLocalizedString("You are about to publish your changes.", comment: "Overwrite Alert at Publish message")
					overwriteAlert.informativeText = NSLocalizedString("This will overwrite all the files within your project. Are you sure you wish to proceed?", comment: "Overwrite Alert at Publish informative text")
					overwriteAlert.addButton(withTitle: NSLocalizedString("OK", comment: "Overwrite Alert at Publish OK Button"))
					overwriteAlert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Overwrite Alert at Publish cancel button"))

					let returnValue = overwriteAlert.runModal()
					
					if returnValue == NSApplication.ModalResponse.cancel {
						NSLog("User canceled publishing")
						return
					}
					
					for assetPair in self.document.assetsList {
						if assetPair.designerAsset == nil {
							continue;
						}
						
						guard let projectAssetURL = assetPair.projectAsset.url, let designerAssetURL = assetPair.designerAsset.url else {
							NSLog("Publishing Error: projectAssetURL or designerAssetURL nil")
							continue;
						}

						
						do {
							try fileManager.removeItem(at: projectAssetURL)
							
							do {
								try fileManager.copyItem(at: designerAssetURL, to: projectAssetURL)
							} catch {
								NSLog("Error copying new asset at \(projectAssetURL) to old asset at \(projectAssetURL)")
								// FIXME: Add a notification to user
							}
						} catch {
							NSLog("Error removing old asset at \(projectAssetURL)")
							// FIXME: Add a notification to user
						}
					}
				} else {
					let overwriteAlert = NSAlert()
					overwriteAlert.messageText = NSLocalizedString("Error Publishing", comment: "Invalid Directory Alert at Publish message")
					overwriteAlert.informativeText = NSLocalizedString("Can't publish, root directory is not a folder, risk of errors", comment: "Invalid Directory Alert at Publish informative text")
					overwriteAlert.addButton(withTitle: NSLocalizedString("OK", comment: "Invalid Directory Alert at Publish OK Button"))
					
					overwriteAlert.runModal()
					NSLog("Can't publish, projectDirectory is not a directory")
				}
			}
			DispatchQueue.main.async {
				let notification = NSUserNotification()
				notification.title = NSLocalizedString("Publish Finished", comment: "NSUserNotification title")
				notification.informativeText = NSLocalizedString("Your new assets have been moved to their new location", comment: "NSUserNotification informativeText")
				notification.soundName = NSUserNotificationDefaultSoundName
				
				NSUserNotificationCenter.default.deliver(notification)

				self.assetsTableView.reloadData()
			}
		}
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
					let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, elementNSString.pathExtension as CFString, nil)?.takeRetainedValue()
					
					guard UTI != nil else {
						NSLog("Failed to create UTI for \(elementPath)")
						continue
					}
					
					if UTTypeConformsTo(UTI!, kUTTypeImage) {
						let newAssetsPair = AssetsPair()
						let newProjectImage = ImageFile()
						
						newProjectImage.url = URL(fileURLWithPath: elementPath)
						newAssetsPair.projectAsset = newProjectImage
						
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

	// MARK: - NSTableViewDataSource & NSTableViewDelegate

	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return self.document != nil ? self.document.assetsList.count : 0
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "AssetCellView"), owner: self) as! AssetCellView
		let assetPair = self.document.assetsList[row]
		
		let assetFile = (tableColumn?.identifier)!.rawValue == "project_asset" ? assetPair.projectAsset : assetPair.designerAsset
		
		if assetFile != nil {
			cellView.textField?.stringValue = assetFile!.fileName
			cellView.assetPathField.stringValue = assetFile!.url.path.replacingOccurrences(of: NSHomeDirectory(), with: "~")
			cellView.imageView?.image = assetFile!.image
			cellView.assetSizeField.stringValue = String(format:"%.0fx%.0f", assetFile!.image.size.width, assetFile!.image.size.height)
		} else {
			cellView.textField?.stringValue = ""
			cellView.assetPathField.stringValue = ""
			cellView.assetSizeField.stringValue = ""
			cellView.imageView?.image = nil
		}
		return cellView
	}
	
	// MARK: Drag and Drop
	
	func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
		return false
	}
	
	func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
		//get the file URLs from the pasteboard
		let pasteBoard = info.draggingPasteboard
		
		//list the file type UTIs we want to accept
		let acceptedTypes = [kUTTypeImage]
		
		guard let urls = pasteBoard.readObjects(forClasses: [NSURL.self],
		                                  options: [NSPasteboardURLReadingFileURLsOnlyKey : true,
		                                            NSPasteboardURLReadingContentsConformToTypesKey : acceptedTypes]) else {
														NSLog("Error accepting the drop")
														return []
		}
	
		//only allow drag if there is exactly one file
		if urls.count != 1 || dropOperation != NSTableViewDropOperation.on {
			return [] //NSDragOperationNone in Swift 3.0
		}
		
		return NSDragOperation.copy
		
	}
	
	
	internal func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
	//get the file URLs from the pasteboard
		let pasteBoard = info.draggingPasteboard
		
		//list the file type UTIs we want to accept
		let acceptedTypes = [kUTTypeImage]
		
		guard let urls = pasteBoard.readObjects(forClasses: [NSURL.self],
		                                  options: [NSPasteboardURLReadingFileURLsOnlyKey : true,
		                                            NSPasteboardURLReadingContentsConformToTypesKey : acceptedTypes]) else {
														NSLog("Error accepting the drop")
														return false
		}
		
		//only allow drag if there is exactly one file
		if urls.count != 1 || dropOperation != NSTableViewDropOperation.on {
			return false
		}

		let draggedFileURL = urls[0] as! NSURL
		let imagePair = self.document.assetsList[row]
		let newDesignerImage = ImageFile()
		newDesignerImage.url = draggedFileURL as URL

		imagePair.designerAsset = newDesignerImage
		
		DispatchQueue.main.async {
			self.assetsTableView.reloadData()
		}
	
		return true
	}

}

