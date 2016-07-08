//
//  GetVinylDiscImageUseCase.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 7/7/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import Foundation

class GetVinylDiscImageUseCase: NSObject {
    
    enum VinylCasesImageTitle:String {
        case KamaradaMusic = "activity_record_music_default"
        case EvilMusic = "activity_record_music_evilplan"
        case Lively = "activity_record_music_lively"
        case Wheels = "activity_record_music_wheels"
        case BreakTime = "activity_record_music_breaktime"
    }
    
    enum VinylSongSaved : String{
        case KamaradaMusic = "kamarada_audio"
        case EvilMusic = "EvilPlanFX"
        case Lively = "LivelyLumpsucker"
        case Wheels = "WagonWheel"
        case BreakTime = "Breaktime"
    }
    
    
    func getSongVinylImage(savedParameter:String) -> UIImage {
        
        switch savedParameter {
        case VinylSongSaved.KamaradaMusic.rawValue:
            return UIImage(named: VinylCasesImageTitle.KamaradaMusic.rawValue)!
        case VinylSongSaved.EvilMusic.rawValue:
            return UIImage(named: VinylCasesImageTitle.EvilMusic.rawValue)!
        case VinylSongSaved.Lively.rawValue:
            return UIImage(named: VinylCasesImageTitle.Lively.rawValue)!
        case VinylSongSaved.Wheels.rawValue:
            return UIImage(named: VinylCasesImageTitle.Wheels.rawValue)!
        case VinylSongSaved.BreakTime.rawValue:
            return UIImage(named: VinylCasesImageTitle.BreakTime.rawValue)!
        default:
            return UIImage(named: VinylCasesImageTitle.KamaradaMusic.rawValue)!
        }
        
    }
    
}