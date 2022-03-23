//
//  NFXGenericController.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(OSX)
import Cocoa
#endif

class NFXGenericController: NFXViewController {
    
    var selectedModel: NFXHTTPModel = NFXHTTPModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if os(iOS)
        edgesForExtendedLayout = UIRectEdge.all
        view.backgroundColor = NFXColor.NFXGray95Color()
        #elseif os(OSX)
        view.wantsLayer = true
        view.layer?.backgroundColor = NFXColor.NFXGray95Color().cgColor
        #endif
    }
    
    func selectedModel(_ model: NFXHTTPModel) {
        selectedModel = model
    }

    
    @objc func reloadData() { }
}
