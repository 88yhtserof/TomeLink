//
//  KakaoNetworkError.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/30/25.
//

import Foundation

enum KakaoNetworkError: LocalizedError {
    case badRequest         // 400: 잘못된 요청
    case unauthorized       // 401: 인증 오류 (토큰 관련)
    case forbidden          // 403: 권한 없음
    case tooManyRequests    // 429: 요청 한도 초과
    case internalServerError // 500: 내부 서버 오류
    case badGateway         // 502: 게이트웨이 오류
    case serviceUnavailable // 503: 서비스 점검 중
    case unknown(statusCode: Int) // 알 수 없는 오류
    
    /// HTTP 상태 코드에 따라 해당하는 오류를 반환하는 초기화 메서드
    init(statusCode: Int) {
        switch statusCode {
        case 400: self = .badRequest
        case 401: self = .unauthorized
        case 403: self = .forbidden
        case 429: self = .tooManyRequests
        case 500: self = .internalServerError
        case 502: self = .badGateway
        case 503: self = .serviceUnavailable
        default: self = .unknown(statusCode: statusCode)
        }
    }
    
    /// 오류 메시지를 반환하는 메서드
    var errorMessage: String {
        switch self {
        case .badRequest:
            return "잘못된 요청입니다. 필수 파라미터를 확인하세요."
        case .unauthorized:
            return "인증 오류가 발생했습니다. 토큰을 확인하세요."
        case .forbidden:
            return "권한이 없습니다. 접근 권한을 확인하세요."
        case .tooManyRequests:
            return "요청 한도를 초과했습니다. 잠시 후 다시 시도하세요."
        case .internalServerError:
            return "서버 내부 오류가 발생했습니다."
        case .badGateway:
            return "잘못된 게이트웨이 응답이 발생했습니다."
        case .serviceUnavailable:
            return "현재 서비스 점검 중입니다."
        case .unknown(let statusCode):
            return "알 수 없는 오류가 발생했습니다. (HTTP \(statusCode))"
        }
    }
}
