import Foundation
import Combine

class StockListViewModel: ObservableObject {
    @Published var stocks: [Stock] = []
    @Published var error: String?
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        loadStockCodes()
        setupTimer()
    }
    
    private func loadStockCodes() {
        guard let path = Bundle.main.path(forResource: "stocklist", ofType: "txt"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            self.error = "无法读取股票代码文件"
            return
        }
        
        let codes = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        fetchStocks(codes: codes)
    }
    
    private func setupTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.loadStockCodes()
        }
    }
    
    private func fetchStocks(codes: [String]) {
        StockService.shared.fetchStockPrices(for: codes)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.error = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] stocks in
                    self?.stocks = stocks
                }
            )
            .store(in: &cancellables)
    }
    
    deinit {
        timer?.invalidate()
    }
} 