//
//  AssetsPair.swift
//  Assets
//
//  Created by Arnaud Thiercelin on 8/12/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class AssetsPair: NSObject, NSCoding {
	var projectAsset: ImageFile!
	var designerAsset: ImageFile!
	
	override init() { // NS_DESIGNATED_INITIALIZER
		
	}
	
	required public init?(coder aDecoder: NSCoder) {
		let projectAsset = aDecoder.decodeObject(forKey: "projectAsset")
		if projectAsset != nil {
			self.projectAsset = projectAsset as! ImageFile
		}
		
		let designerAsset = aDecoder.decodeObject(forKey: "designerAsset")
		if designerAsset != nil {
			self.designerAsset = designerAsset as! ImageFile
		}
	}

	public func encode(with aCoder: NSCoder) {
		if self.projectAsset != nil {
			aCoder.encode(self.projectAsset, forKey: "projectAsset")
		}
		
		if self.designerAsset != nil {
			aCoder.encode(self.designerAsset, forKey: "designerAsset")
		}
	}
	
	
}
