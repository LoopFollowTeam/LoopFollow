// LoopFollow
// Chart.swift

import DGCharts
import UIKit
import CoreGraphics
import Foundation

@objc(OverrideFillFormatter)
public final class OverrideFillFormatter: NSObject, FillFormatter {
    public func getFillLinePosition(
        dataSet: LineChartDataSetProtocol,
        dataProvider: LineChartDataProvider
    ) -> CGFloat {
        CGFloat(dataSet.entryForIndex(0)?.y ?? 0)
    }
}

@objc(BasalFillFormatter)
public final class BasalFillFormatter: NSObject, FillFormatter {
    public func getFillLinePosition(
        dataSet: LineChartDataSetProtocol,
        dataProvider: LineChartDataProvider
    ) -> CGFloat { 0 }
}

@objc(ChartXValueFormatter)
public final class ChartXValueFormatter: NSObject, AxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let df = DateFormatter()
        if dateTimeUtils.is24Hour() {
            df.setLocalizedDateFormatFromTemplate("HH:mm")
        } else {
            df.setLocalizedDateFormatFromTemplate("hh:mm")
        }
        return df.string(from: Date(timeIntervalSince1970: value))
    }
}

@objc(ChartYDataValueFormatter)
public final class ChartYDataValueFormatter: NSObject, ValueFormatter {
    public func stringForValue(
        _ value: Double,
        entry: ChartDataEntry,
        dataSetIndex: Int,
        viewPortHandler: ViewPortHandler?
    ) -> String {
        if let s = entry.data as? String { return s }
        return ""
    }
}

@objc(ChartYOverrideValueFormatter)
public final class ChartYOverrideValueFormatter: NSObject, ValueFormatter {
    public func stringForValue(
        _ value: Double,
        entry: ChartDataEntry,
        dataSetIndex: Int,
        viewPortHandler: ViewPortHandler?
    ) -> String {
        if let s = entry.data as? String { return s }
        return ""
    }
}

@objc(ChartYMMOLValueFormatter)
public final class ChartYMMOLValueFormatter: NSObject, AxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        Localizer.toDisplayUnits(String(value))
    }
}

public final class PillMarker: MarkerImage {
    private(set) var color: UIColor
    private(set) var font: UIFont
    private(set) var textColor: UIColor
    private var labelText: String = ""
    private var attrs: [NSAttributedString.Key: Any]

    public static let formatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.minute, .second]
        f.unitsStyle = .short
        return f
    }()

    public init(color: UIColor, font: UIFont, textColor: UIColor) {
        self.color = color
        self.font = font
        self.textColor = textColor
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        self.attrs = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: textColor,
            .baselineOffset: NSNumber(value: -4)
        ]
        super.init()
    }

    public override func draw(context: CGContext, point: CGPoint) {
        let labelSize = (labelText as NSString).size(withAttributes: attrs)
        let labelWidth = labelSize.width + 10
        let labelHeight = labelSize.height + 4

        var rect = CGRect(x: point.x - labelWidth / 2.0, y: point.y, width: labelWidth, height: labelHeight)
        var spacing: CGFloat = 20
        if point.y < 300 { spacing = -40 }
        rect.origin.y -= rect.height + spacing

        let path = UIBezierPath(roundedRect: rect, cornerRadius: 6).cgPath
        context.addPath(path)
        context.setFillColor(UIColor.secondarySystemBackground.cgColor)
        context.setStrokeColor(UIColor.label.cgColor)
        context.drawPath(using: .fillStroke)

        (labelText as NSString).draw(with: rect, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
    }

    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        if let s = entry.data as? String {
            labelText = s
        } else {
            labelText = String(entry.y)
        }
    }

    private func customString(_ value: Double) -> String {
        PillMarker.formatter.string(from: TimeInterval(value)) ?? ""
    }
}
