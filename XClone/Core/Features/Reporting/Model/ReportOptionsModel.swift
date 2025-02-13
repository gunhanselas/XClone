//
//  ReportOptionsModel.swift
//  XClone
//
//  Created by Stephan Dowless on 2/12/25.
//


import Foundation

enum ReportOptionsModel: Int, CaseIterable, Codable {
    case dontLike
    case spam
    case nudity
    case hateSpeechOrSymbols
    case falseInformation
    case selfHarm
    case saleOfIllegalGoods
    case bullying
    
    var title: String {
        switch self {
        case .spam: return "It's spam"
        case .dontLike: return "I just don't like it"
        case .selfHarm: return "Suicide, self-injury or eating disorders"
        case .saleOfIllegalGoods: return "Sale of illegal or regulated goods"
        case .nudity: return "Nudity or sexual activity"
        case .hateSpeechOrSymbols: return "Hate speech or symbols"
        case .falseInformation: return "False information"
        case .bullying: return "Bullying or harassment"
        }
    }
    
}

extension ReportOptionsModel: Identifiable, Hashable {
    var id: Int { return self.rawValue }
}