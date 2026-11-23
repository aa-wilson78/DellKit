import SwiftUI

/// Figma: Device Card. Hero card for the primary device on the Dashboard.
public struct DKDeviceCard: View {
    private let title: String
    private let serviceTag: String
    private let image: Image?
    private let warranty: DKStatusBadge?
    private let showsArrow: Bool

    public init(
        _ title: String,
        serviceTag: String,
        image: Image? = nil,
        warranty: DKStatusBadge? = DKStatusBadge("Active Warranty", style: .inline),
        showsArrow: Bool = true
    ) {
        self.title = title
        self.serviceTag = serviceTag
        self.image = image
        self.warranty = warranty
        self.showsArrow = showsArrow
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DK.Metric.space3) {
            HStack(spacing: DK.Metric.space2) {
                Text(title).font(DK.Typography.headline).foregroundStyle(DK.Color.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if showsArrow { DKIcon.arrowRight.image.foregroundStyle(DK.Color.iconPrimary) }
            }
            DKProductMedia(image, size: .large)
            HStack(spacing: DK.Metric.space2) {
                Text(serviceTag).font(DK.Typography.footnote).foregroundStyle(DK.Color.textSecondary)
                if let warranty {
                    Text("|").font(DK.Typography.footnote).foregroundStyle(DK.Color.textTertiary)
                        .accessibilityHidden(true)
                    warranty
                }
            }
        }
        .padding(DK.Metric.cardPadding)
        .background(DK.Color.cardBackground, in: RoundedRectangle(cornerRadius: DK.Metric.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

/// Figma: Device List Item. Inventory row in the Owner devices list.
public struct DKDeviceListItem: View {
    private let name: String
    private let assigned: Int
    private let total: Int
    private let image: Image?
    private let warranty: DKStatusBadge?

    public init(
        _ name: String,
        assigned: Int,
        total: Int,
        image: Image? = nil,
        warranty: DKStatusBadge? = DKStatusBadge("Active Warranty", style: .inline)
    ) {
        self.name = name
        self.assigned = assigned
        self.total = total
        self.image = image
        self.warranty = warranty
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: DK.Metric.space3) {
                DKProductMedia(image, size: .medium)
                VStack(alignment: .leading, spacing: DK.Metric.space1) {
                    Text(name).font(DK.Typography.subheadline).foregroundStyle(DK.Color.textPrimary)
                    meta("Assigned Units", assigned)
                    meta("Total Units", total)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                DKIcon.arrowRight.image.foregroundStyle(DK.Color.iconPrimary)
            }
            .padding(DK.Metric.cardPadding)

            if let warranty {
                HStack { warranty; Spacer(minLength: 0) }
                    .padding(.horizontal, DK.Metric.cardPadding)
                    .padding(.vertical, DK.Metric.space2)
                    .overlay(alignment: .top) { Rectangle().fill(DK.Color.listRowDivider).frame(height: 1) }
            }
        }
        .background(DK.Color.cardBackground, in: RoundedRectangle(cornerRadius: DK.Metric.cardRadius, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: DK.Metric.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private func meta(_ label: String, _ value: Int) -> some View {
        HStack {
            Text(label).foregroundStyle(DK.Color.textSecondary)
            Spacer(minLength: DK.Metric.space2)
            Text("\(value)").foregroundStyle(DK.Color.textPrimary)
        }
        .font(DK.Typography.caption)
    }
}

/// Figma: Device Select Tile (State = Default | Selected). Grid tile on Assign PCs.
public struct DKDeviceSelectTile: View {
    private let name: String
    private let availability: String
    private let image: Image?
    private let selectedCount: Int
    private let action: () -> Void

    public init(_ name: String, availability: String, image: Image? = nil, selectedCount: Int = 0, action: @escaping () -> Void) {
        self.name = name
        self.availability = availability
        self.image = image
        self.selectedCount = selectedCount
        self.action = action
    }

    private var isSelected: Bool { selectedCount > 0 }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: DK.Metric.radiusSm, style: .continuous)
        Button(action: action) {
            VStack(spacing: 0) {
                VStack(spacing: DK.Metric.space2) {
                    DKProductMedia(image, size: .medium)
                    Text(name).font(DK.Typography.footnote).foregroundStyle(DK.Color.textPrimary)
                    Text(availability).font(DK.Typography.caption).foregroundStyle(DK.Color.textSecondary)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(DK.Metric.space3)

                Text(isSelected ? "Selected (\(selectedCount))" : "Select")
                    .font(DK.Typography.footnote)
                    .foregroundStyle(isSelected ? DK.Color.textOnPrimary : DK.Color.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DK.Metric.space2)
                    .background(isSelected ? DK.Color.buttonPrimaryBackground : DK.Color.actionPrimaryDisabled)
            }
            .background(DK.Color.cardBackground)
            .clipShape(shape)
            .overlay { if isSelected { shape.strokeBorder(DK.Color.borderFocus, lineWidth: 2) } }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Figma: Tip Card. Carousel card for "Tips for you".
public struct DKTipCard: View {
    private let number: Int
    private let title: String
    private let message: String
    private let image: Image?
    private let ctaTitle: String?
    private let cta: (() -> Void)?

    public init(number: Int, title: String, message: String, image: Image? = nil, ctaTitle: String? = "Learn more", cta: (() -> Void)? = nil) {
        self.number = number
        self.title = title
        self.message = message
        self.image = image
        self.ctaTitle = ctaTitle
        self.cta = cta
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(number)").font(DK.Typography.title1).foregroundStyle(DK.Color.textPrimary)
                .padding(.horizontal, DK.Metric.cardPadding).padding(.vertical, DK.Metric.space3)
            DKProductMedia(image, size: .large)
            VStack(alignment: .leading, spacing: DK.Metric.space2) {
                Text(title).font(DK.Typography.headline).foregroundStyle(DK.Color.textPrimary)
                Text(message).font(DK.Typography.footnote).foregroundStyle(DK.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                if let ctaTitle, let cta {
                    DKButton(ctaTitle, style: .outline, fullWidth: false, action: cta)
                }
            }
            .padding(DK.Metric.cardPadding)
        }
        .frame(width: 240)
        .background(DK.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DK.Metric.cardRadius, style: .continuous))
    }
}

#Preview("Device cards") {
    ScrollView {
        VStack(spacing: 16) {
            DKDeviceCard("XPS 13", serviceTag: "H7JK09K")
            DKDeviceListItem("Latitude 9420", assigned: 2, total: 4)
            HStack {
                DKDeviceSelectTile("Latitude 9420", availability: "7 Available") {}
                DKDeviceSelectTile("Latitude 9510", availability: "7 Available", selectedCount: 1) {}
            }
            DKTipCard(number: 1, title: "Keyboard Backlight", message: "Press F10 to cycle brightness.") {}
        }
        .padding()
    }
    .background(DK.Color.bgPrimary)
    .preferredColorScheme(.dark)
}
