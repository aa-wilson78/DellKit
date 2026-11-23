import SwiftUI

/// Figma: Text Field (State = Default | Filled | Focused | Error)
/// Default/Filled follow the text, Focused follows keyboard focus, Error follows `error`.
public struct DKTextField: View {
    private let placeholder: String
    @Binding private var text: String
    private let isSecure: Bool
    private let helper: String?
    private let error: String?

    @FocusState private var isFocused: Bool
    @State private var isRevealed = false

    public init(
        _ placeholder: String,
        text: Binding<String>,
        isSecure: Bool = false,
        helper: String? = nil,
        error: String? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.helper = helper
        self.error = error
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DK.Metric.space1) {
            HStack(spacing: DK.Metric.space2) {
                field
                    .font(DK.Typography.subheadline)
                    .foregroundStyle(DK.Color.fieldValue)
                    .focused($isFocused)
                if isSecure {
                    Button { isRevealed.toggle() } label: {
                        (isRevealed ? DKIcon.eyeOff : DKIcon.eye).image
                            .foregroundStyle(DK.Color.iconSecondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
                }
            }
            .padding(.horizontal, DK.Metric.fieldPaddingX)
            .frame(minHeight: DK.Metric.fieldHeight)
            .overlay(
                RoundedRectangle(cornerRadius: DK.Metric.fieldRadius, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: (error != nil || isFocused) ? 2 : 1)
            )

            if let message = error ?? helper {
                Text(message)
                    .font(DK.Typography.footnote)
                    .foregroundStyle(error != nil ? DK.Color.statusError : DK.Color.textSecondary)
            }
        }
    }

    @ViewBuilder private var field: some View {
        if isSecure && !isRevealed {
            SecureField("", text: $text, prompt: prompt)
        } else {
            TextField("", text: $text, prompt: prompt)
        }
    }

    private var prompt: Text {
        Text(placeholder).foregroundColor(DK.Color.fieldPlaceholder)
    }

    private var borderColor: Color {
        if error != nil { return DK.Color.fieldBorderError }
        return isFocused ? DK.Color.fieldBorderFocus : DK.Color.fieldBorder
    }
}

/// Figma: Search Field
public struct DKSearchField: View {
    private let placeholder: String
    @Binding private var text: String

    public init(_ placeholder: String = "Search by Service Tag", text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        HStack(spacing: DK.Metric.space2) {
            DKIcon.search.image.foregroundStyle(DK.Color.iconSecondary)
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(DK.Color.fieldPlaceholder))
                .font(DK.Typography.subheadline)
                .foregroundStyle(DK.Color.fieldValue)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, DK.Metric.fieldPaddingX)
        .frame(minHeight: DK.Metric.fieldHeight)
        .background(DK.Color.bgElevated, in: RoundedRectangle(cornerRadius: DK.Metric.fieldRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DK.Metric.fieldRadius, style: .continuous)
                .strokeBorder(DK.Color.fieldBorder, lineWidth: 1)
        )
    }
}

private struct TextFieldPreview: View {
    @State var first = "Sophie"
    @State var email = "sophie@"
    @State var password = ""
    @State var query = ""
    var body: some View {
        VStack(spacing: 16) {
            DKTextField("First Name*", text: $first)
            DKTextField("Email Address*", text: $email, error: "Enter a valid email address")
            DKTextField("Password*", text: $password, isSecure: true)
            DKSearchField(text: $query)
        }
        .padding()
        .background(DK.Color.bgPrimary)
    }
}

#Preview("Text Field") {
    TextFieldPreview().preferredColorScheme(.dark)
}
