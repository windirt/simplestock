import Foundation
import Combine

class StockService {
    static let shared = StockService()
    
    private init() {}
    
    func fetchStockPrices(for codes: [String]) -> AnyPublisher<[Stock], Error> {
        let urlString = "https://hq.sinajs.cn/list=\(codes.joined(separator: ","))"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.addValue("https://finance.sina.com.cn", forHTTPHeaderField: "Referer")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .tryMap { data -> [Stock] in
                let gbkEncoding: CFStringEncoding = CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)
                let encoding = CFStringConvertEncodingToNSStringEncoding(gbkEncoding)
                
                guard let content = String(data: data, encoding: String.Encoding(rawValue: encoding)) else {
                    throw URLError(.cannotDecodeContentData)
                }
                
                return try self.parseStockData(content)
            }
            .eraseToAnyPublisher()
    }
    
    private func parseStockData(_ content: String) throws -> [Stock] {
        let lines = content.components(separatedBy: "\n")
        return lines.compactMap { line -> Stock? in
            guard !line.isEmpty,
                  let quotePart = line.components(separatedBy: "\"").dropFirst().first,
                  !quotePart.isEmpty else {
                return nil
            }
            
            let fields = quotePart.components(separatedBy: ",")

            
            if line.contains("hf_CHA50CFD") {
                // Special handling for the new index
                guard fields.count >= 9,
                      let currentPrice = Double(fields[0]),
                      let yesterdayPrice = Double(fields[8]) else {
                    return nil
                }
                
                let changePercent = (currentPrice - yesterdayPrice) / yesterdayPrice * 100
                
                return Stock(
                    name: "A50期货",
                    currentPrice: currentPrice,
                    changePercent: changePercent
                )
            } else {
                // Existing stock handling
                guard fields.count >= 4,
                      let yesterdayPrice = Double(fields[2]),
                      let currentPrice = Double(fields[3]) else {
                    return nil
                }
                
                let changePercent = (currentPrice - yesterdayPrice) / yesterdayPrice * 100
                

                
                return Stock(
                    name: line.contains("sh510300") ? "300ETF":fields[0],
                    currentPrice: currentPrice,
                    changePercent: changePercent
                )
            }
        }
    }
}
