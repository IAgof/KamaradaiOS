//
//  DetailTextPresenter.swift
//  Videona
//
//  Created by Alejandro Arjonilla Garcia on 9/6/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation

class DetailTextPresenter: NSObject,DetailTextPresenterInterface {
    var wireframe: DetailTextWireframe?
    var controller: DetailTextInterface?
    var interactor: DetailTextInteractorInterface?
    
    
    func pushBack() {
        wireframe?.goPrevController()
    }
    
    func setTextOnView(text:String) {
        let textToView = interactor?.getTextFromInternalMemory(text)
        controller?.setTextToTextView(textToView!)
    }
}