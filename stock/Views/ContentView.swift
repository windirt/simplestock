import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StockListViewModel()
    
    var body: some View {
        VStack {
            if let error = viewModel.error {
                ErrorView(message: error)
            } else {
                StockListView(stocks: viewModel.stocks)
            }
        }
        .frame(width: 180)
        .padding(0)
        .background(Color(white:0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onAppear {
            if let window = NSApplication.shared.windows.first {
                window.level = .floating
                // Set window style to be borderless but allow resizing
                window.styleMask = [.borderless, .resizable]
                window.backgroundColor = .clear
                window.setContentSize(NSSize(width: 180, height: window.frame.height))
                window.minSize = NSSize(width: 180, height: 100) // Set minimum height
                window.maxSize = NSSize(width: 180, height: CGFloat.infinity)
                window.isMovableByWindowBackground = true
                
                // Add resize and move capability
                if let contentView = window.contentView {
                    contentView.wantsLayer = true
                }

            }
        }
    }
}

struct StockListView: View {
    let stocks: [Stock]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List(stocks.indices, id: \.self) { index in
                StockRow(stock: stocks[index], isEvenRow: index % 2 == 0)
            }
            .listStyle(PlainListStyle()) // Use a plain list style
            .listRowInsets(EdgeInsets()) // Remove default padding
            .scrollContentBackground(.hidden)
            .background(Color(white:0.1))
            .padding(0)
        }
    }
}

//struct HeaderRow: View {
//    var body: some View {
//        HStack {
//            Text("股票名称")
//                .frame(width: 100, alignment: .leading)
//            Text("当前价格")
//                .frame(width: 100, alignment: .trailing)
//            Text("涨跌幅")
//                .frame(width: 100, alignment: .trailing)
//        }
//        .font(.headline)
//        .foregroundColor(.white)
//    }
//}

struct StockRow: View {
    let stock: Stock
    let isEvenRow: Bool
    
    var body: some View {
        HStack(spacing: 0) { // Ensure no spacing in HStack
            Text(stock.name)
                .frame(width: 55, alignment: .leading)
                .foregroundColor(stock.isUp ? .red : stock.isDown ? .green : .white)
            Text(String(format: stock.name.contains("ETF") ? "%.3f" : "%.2f", stock.currentPrice))
                .frame(width: 60, alignment: .trailing)
                .foregroundColor(stock.isUp ? .red : stock.isDown ? .green : .white)
            Text(String(format: "%+.2f%%", stock.changePercent))
                .frame(width: 55, alignment: .trailing)
                .foregroundColor(stock.isUp ? .red : stock.isDown ? .green : .white)
        }
        .listRowBackground(isEvenRow ? Color(white:0.1) : Color(white: 0.2))
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .foregroundColor(.red)
            .padding()
    }
}
