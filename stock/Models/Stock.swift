import Foundation

struct Stock: Identifiable {
    let id = UUID()
    let name: String
    let currentPrice: Double
    let changePercent: Double
    
    var isUp: Bool {
        changePercent > 0
    }
    
    var isDown: Bool {
        changePercent < 0
    }
} 