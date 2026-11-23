import SwiftUI

/// Figma: Status Badge (Tone = Success | Warning | Error | Info | Neutral, Style = Pill | Inline)
public struct DKStatusBadge: View {
    public enum Tone: Sendable { case success, warning, error, info, neutral }
    public enum Style: Sendable { case pill, inline }

    /// Order states map onto tones through the order/* tokens.
    public enum OrderStatus: String, Sendable {
        case processing = "Processing", shipped = "Shipped", delivered = "Delivered"
        case delayed = "Delayed", cancelled = "Cancelled"

        var tone: Tone {
            switch self {
            case .processing, .shipped: return .info
            case .delivered: return .success
            case .delayed: return .warning
            case .cancelled: return .error
            }
        }
    }

    private let label: String
    private let tone: Tone
    private let style: Style
    private let icon: DKIcon?

    public init(_ label: String, tone: Tone = .success, style: Style = .pill, icon: DKIcon? = .shieldCheck) {
        self.label = label
        self.tone = tone
        self.style = style
        self.icon = icon
    }

    /// "Order: Shipped" pill with a truck icon.
    public init(order status: OrderStatus) {
        self.init("Order: \(status.rawValue)", tone: status.tone, style: .pill, icon: .truck)
    }

    public var body: some View {
        HStack(spacing: DK.Metric.space1) {
            if let icon {
                icon.image.imageScale(.small)
            }
            Text(label).font(DK.Typography.caption)
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, style == .pill ? DK.Metric.statusBadgePaddingX : 0)
        .padding(.vertical, style == .pill ? DK.Metric.statusBadgePaddingY : 0)
        .background {
            if style == .pill { Capsule().fill(background) }
        }
        .accessibilityElement(children: .combine)
    }

    private var foreground: Color {
        switch tone {
        case .success: return DK.Color.statusSuccess
        case .warning: return DK.Color.statusWarning
        case .error: return DK.Color.statusError
        case .info: return DK.Color.statusInfo
        case .neutral: return DK.Color.textSecondary
        }
    }

    private var background: Color {
        switch tone {
        case .success: return DK.Color.statusSuccessSubtle
        case .warning: return DK.Color.statusWarningSubtle
        case .error: return DK.Color.statusErrorSubtle
        case .info: return DK.Color.statusInfoSubtle
        case .neutral: return DK.Color.bgSecondary
        }
    }
}

/// Figma: Avatar (Size = Small | Medium | Large)
public struct DKAvatar: View {
    public enum Size: Sendable {
        case small, medium, large
        var diameter: CGFloat {
            switch self { case .small: return 24; case .medium: return 32; case .large: return 40 }
        }
        var font: Font {
            switch self { case .small: return DK.Typography.caption; case .medium: return DK.Typography.footnote; case .large: return DK.Typography.subheadline }
        }
    }

    private let initials: String
    private let image: Image?
    private let size: Size

    public init(initials: String, image: Image? = nil, size: Size = .medium) {
        self.initials = initials
        self.image = image
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle().fill(DK.Color.actionSecondaryDefault)
            if let image {
                image.resizable().scaledToFill()
            } else {
                Text(initials).font(size.font).foregroundStyle(DK.Color.textLink)
            }
        }
        .frame(width: size.diameter, height: size.diameter)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}

/// Figma: Product Media (Size = Large | Medium | Small). Placeholder shows until an image is supplied.
public struct DKProductMedia: View {
    public enum Size: Sendable { case large, medium, small }

    private let image: Image?
    private let size: Size

    public init(_ image: Image? = nil, size: Size = .large) {
        self.image = image
        self.size = size
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: size == .large ? DK.Metric.radiusMd : DK.Metric.radiusSm, style: .continuous)
        ZStack {
            shape.fill(DK.Color.bgSecondary)
            if let image {
                image.resizable().scaledToFit().padding(size == .large ? DK.Metric.space4 : DK.Metric.space1)
            } else {
                DKIcon.laptop.image
                    .font(.system(size: placeholderSize, weight: .light))
                    .foregroundStyle(DK.Color.iconSecondary)
            }
        }
        .frame(width: fixedWidth, height: height)
        .frame(maxWidth: size == .large ? .infinity : nil)
        .clipShape(shape)
    }

    private var fixedWidth: CGFloat? {
        switch size { case .large: return nil; case .medium: return 96; case .small: return 48 }
    }
    private var height: CGFloat {
        switch size { case .large: return 170; case .medium: return 64; case .small: return 48 }
    }
    private var placeholderSize: CGFloat {
        switch size { case .large: return 44; case .medium: return 26; case .small: return 18 }
    }
}

#Preview("Badges, Avatar, Media") {
    VStack(alignment: .leading, spacing: 16) {
        HStack {
            DKStatusBadge("Active Warranty")
            DKStatusBadge(order: .shipped)
        }
        DKStatusBadge("Expired", tone: .error, style: .inline)
        HStack { DKAvatar(initials: "BA", size: .small); DKAvatar(initials: "BA"); DKAvatar(initials: "BA", size: .large) }
        DKProductMedia()
        HStack { DKProductMedia(size: .medium); DKProductMedia(size: .small) }
    }
    .padding()
    .background(DK.Color.bgPrimary)
    .preferredColorScheme(.dark)
}
