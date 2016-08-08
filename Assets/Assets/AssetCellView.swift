//
//  AssetCellView.swift
//  Assets
//
//  Created by Arnaud Thiercelin on 8/7/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class AssetCellView: NSTableCellView {

	// imageView -> image
	// textField -> imageName
	@IBOutlet var imagePathField : NSTextField!
	@IBOutlet var imageSizeField : NSTextField!
	
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
