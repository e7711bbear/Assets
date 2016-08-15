//
//  ImageFile.swift
//  Assets
//
//  Created by Arnaud Thiercelin on 8/12/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class ImageFile: NSObject {
	var fileName: String!
	var url: URL! {
		didSet {
			self.fileName = url.lastPathComponent
			self.image = NSImage(contentsOf: self.url)
		}
	}
	
	
	var image: NSImage!

}
