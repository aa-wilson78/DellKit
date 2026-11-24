import SwiftUI

/// Figma: Button (Style = Primary | Outline | Text, State = Default | Pressed | Disabled)
/// Pressed comes from the button's own press state; Disabled from `.disabled(_:)`.
public struct DKButton: View {
    public enum Style: Sendable { case primary, outline, text }

    private let title: String
    private let style: Style
    private let icon: DKIcon?
    private let fullWidth: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        style: Style = .primary,
        icon: DKIcon? = nil,
        fullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.icon = icon
        self.fullWidth = fullWidth
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DK.Metric.space2) {
                if let icon {
                    icon.image.imageScale(.medium)
                }
                Text(title).font(DK.Typography.headline)
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
        }
        .buttonStyle(DKButtonStyle(style: style))
    }
}

/// The visual treatment, usable on any `Button` or `NavigationLink`.
public struct DKButtonStyle: ButtonStyle {
    public let style: DKButton.Style
    @Environment(\.isEnabled) private var isEnabled

    public init(style: DKButton.Style) { self.style = style }

    public func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: DK.Metric.buttonRadius, style: .continuous)
        return configuration.label
            .foregroundStyle(foreground)
            .padding(.horizontal, DK.Metric.buttonPaddingX)
            .frame(minHeight: DK.Metric.buttonHeight)
            .background(background(pressed: configuration.isPressed), in: shape)
            .overlay {
                if style == .outline {
                    shape.strokeBorder(isEnabled ? DK.Color.buttonOutlineBorder : DK.Color.borderDefault, lineWidth: 1)
                }
            }
            .contentShape(shape)
    }

    private var foreground: Color {
        switch style {
        case .primary: return isEnabled ? DK.Color.buttonPrimaryForeground : DK.Color.buttonPrimaryForegroundDisabled
        case .outline: return isEnabled ? DK.Color.buttonOutlineForeground : DK.Color.textTertiary
        case .text: return isEnabled ? DK.Color.buttonTextForeground : DK.Color.textTertiary
        }
    }

    private func background(pressed: Bool) -> Color {
        switch style {
        case .primary:
            if !isEnabled { return DK.Color.buttonPrimaryBackgroundDisabled }
            return pressed ? DK.Color.buttonPrimaryBackgroundPressed : DK.Color.buttonPrimaryBackground
        case .outline, .text:
            return pressed ? DK.Color.buttonOutlineBackgroundPressed : .clear
        }
    }
}

#Preview("Button") {
    VStack(spacing: 16) {
        DKButton("Create Account") {}
        DKButton("Create Account") {}.disabled(true)
        DKButton("Sign in with Account ID", style: .outline, icon: .signIn) {}
        DKButton("Cancel", style: .text) {}
    }
    .padding()
    .background(DK.Color.bgPrimary)
    .preferredColorScheme(.dark)
}
