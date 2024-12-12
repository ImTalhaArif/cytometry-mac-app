import SwiftUI
import Charts

struct HistogramOverlayView: View {
    var data: [Double]
    var body: some View {
        Chart {
            ForEach(data.indices, id: \.self) { index in
                BarMark(x: .value("Time", index),
                        y: .value("Value", data[index]))
            }
        }
        .frame(height: 300)
    }
}
