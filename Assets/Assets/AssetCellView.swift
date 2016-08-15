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
	// textField -> assetName
	@IBOutlet var assetPathField : NSTextField!
	@IBOutlet var assetSizeField : NSTextField!
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
