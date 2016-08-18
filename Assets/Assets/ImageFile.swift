//
//  ImageFile.swift
//  Assets
//
//  Created by Arnaud Thiercelin on 8/12/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class ImageFile: NSObject, NSCoding {
	var fileName: String!
	var url: URL! {
		didSet {
			self.fileName = url.lastPathComponent
			self.image = NSImage(contentsOf: self.url)
		}
	}

	var image: NSImage!

	override init() { // NS_DESIGNATED_INITIALIZER
		
	}
	
	required public init?(coder aDecoder: NSCoder) {
		let url = aDecoder.decodeObject(forKey: "url")
		if url != nil {
			self.url = url as! URL
		}
	}
	
	public func encode(with aCoder: NSCoder) {
		if self.url != nil {
			aCoder.encode(self.url, forKey: "url")
		}
	}
	
}
