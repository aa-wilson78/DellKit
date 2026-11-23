import SwiftUI

/// Figma: Section Header
public struct DKSectionHeader: View {
    private let title: String
    private let count: Int?
    private let actionIcon: DKIcon?
    private let actionLabel: String
    private let action: (() -> Void)?

    public init(
        _ title: String,
        count: Int? = nil,
        actionIcon: DKIcon? = .plusCircle,
        actionLabel: String = "Add",
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.count = count
        self.actionIcon = actionIcon
        self.actionLabel = actionLabel
        self.action = action
    }

    public var body: some View {
        HStack(spacing: DK.Metric.space2) {
            Text(title)
                .font(DK.Typography.title3)
                .foregroundStyle(DK.Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            if let count {
                Text("\(count)").font(DK.Typography.footnote).foregroundStyle(DK.Color.textSecondary)
            }
            Spacer(minLength: 0)
            if let actionIcon, let action {
                Button(action: action) {
                    actionIcon.image.foregroundStyle(DK.Color.iconPrimary)
                        .frame(width: DK.Metric.sizeTouchTarget, height: DK.Metric.sizeTouchTarget)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(actionLabel)
            }
        }
    }
}

/// Figma: List Row (Trailing = Arrow | Value | Radio | Selected)
/// Wrap in a `Button` or `NavigationLink` to make it tappable.
public struct DKListRow: View {
    public enum Trailing: Equatable, Sendable {
        case arrow
        case value(String)
        case radio(isSelected: Bool)
        case none
    }

    private let label: String
    private let icon: DKIcon?
    private let trailing: Trailing

    public init(_ label: String, icon: DKIcon? = nil, trailing: Trailing = .arrow) {
        self.label = label
        self.icon = icon
        self.trailing = trailing
    }

    public var body: some View {
        HStack(spacing: DK.Metric.space3) {
            if let icon {
                icon.image.foregroundStyle(DK.Color.iconSecondary)
            }
            Text(label)
                .font(DK.Typography.subheadline)
                .foregroundStyle(DK.Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            trailingView
        }
        .padding(.horizontal, DK.Metric.listRowPaddingX)
        .padding(.vertical, DK.Metric.listRowPaddingY)
        .frame(minHeight: DK.Metric.listRowMinHeight)
        .background(DK.Color.cardBackground, in: RoundedRectangle(cornerRadius: DK.Metric.radiusSm, style: .continuous))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder private var trailingView: some View {
        switch trailing {
        case .arrow:
            DKIcon.arrowRight.image.foregroundStyle(DK.Color.iconPrimary)
        case .value(let value):
            Text(value).font(DK.Typography.footnote).foregroundStyle(DK.Color.textSecondary)
        case .radio(let selected):
            (selected ? DKIcon.checkCircle : DKIcon.radio).image
                .foregroundStyle(selected ? DK.Color.iconBrand : DK.Color.iconSecondary)
        case .none:
            EmptyView()
        }
    }

    private var isSelected: Bool { trailing == .radio(isSelected: true) }
}

/// Figma: Timeline Item (State = Complete | Upcoming). Used for order tracking and device history.
public struct DKTimelineItem: View {
    private let date: String
    private let time: String?
    private let detail: String
    private let isComplete: Bool
    private let showsLine: Bool

    public init(date: String, time: String? = nil, detail: String, isComplete: Bool = true, showsLine: Bool = true) {
        self.date = date
        self.time = time
        self.detail = detail
        self.isComplete = isComplete
        self.showsLine = showsLine
    }

    public var body: some View {
        HStack(alignment: .top, spacing: DK.Metric.space3) {
            VStack(spacing: 0) {
                Circle()
                    .fill(isComplete ? DK.Color.actionPrimaryDefault : DK.Color.bgPrimary)
                    .overlay(Circle().strokeBorder(isComplete ? .clear : DK.Color.borderStrong, lineWidth: 2))
                    .frame(width: 10, height: 10)
                    .padding(.top, 4)
                if showsLine {
                    Rectangle()
                        .fill(isComplete ? DK.Color.actionPrimaryDefault : DK.Color.borderDefault)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            VStack(alignment: .leading, spacing: DK.Metric.space1) {
                Text(date).font(DK.Typography.footnote)
                    .foregroundStyle(isComplete ? DK.Color.textPrimary : DK.Color.textSecondary)
                if let time {
                    Text(time).font(DK.Typography.caption).foregroundStyle(DK.Color.textSecondary)
                }
                Text(detail).font(DK.Typography.caption).foregroundStyle(DK.Color.textSecondary)
            }
            .padding(.bottom, DK.Metric.space4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Rows") {
    VStack(spacing: 12) {
        DKSectionHeader("Your Laptop") {}
        DKListRow("Track shipment", icon: .truck)
        DKListRow("Warranty", icon: .shieldCheck, trailing: .value("Premium Support Plus"))
        DKListRow("HYD7I3S", trailing: .radio(isSelected: true))
        DKTimelineItem(date: "Jun 12, 2020", time: "12:11 PM", detail: "Left FedEx origin facility, Middletown, PA")
        DKTimelineItem(date: "Jun 17, 2020", detail: "Estimated arrival date", isComplete: false, showsLine: false)
    }
    .padding()
    .background(DK.Color.bgPrimary)
    .preferredColorScheme(.dark)
}
