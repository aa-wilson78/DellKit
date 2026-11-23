import SwiftUI

/// Figma: Code Input (six Code Cells). One hidden text field drives all cells,
/// so iOS one-time-code autofill from Messages/Mail works.
public struct DKCodeInput: View {
    @Binding private var code: String
    private let length: Int
    @FocusState private var isFocused: Bool

    public init(code: Binding<String>, length: Int = 6) {
        self._code = code
        self.length = length
    }

    public var body: some View {
        ZStack {
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .onChange(of: code) { newValue in
                    let digits = String(newValue.filter(\.isNumber).prefix(length))
                    if digits != newValue { code = digits }
                }

            HStack(spacing: DK.Metric.space3) {
                ForEach(0..<length, id: \.self) { index in
                    DKCodeCell(digit: digit(at: index), state: cellState(at: index))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Verification code")
        .accessibilityValue(code)
    }

    private func digit(at index: Int) -> String {
        let chars = Array(code)
        return index < chars.count ? String(chars[index]) : ""
    }

    private func cellState(at index: Int) -> DKCodeCell.CellState {
        if index < code.count { return .filled }
        if isFocused && index == code.count { return .focused }
        return .empty
    }
}

/// Figma: Code Cell (State = Empty | Filled | Focused)
public struct DKCodeCell: View {
    public enum CellState: Sendable { case empty, filled, focused }

    private let digit: String
    private let state: CellState

    public init(digit: String, state: CellState) {
        self.digit = digit
        self.state = state
    }

    public var body: some View {
        Text(digit)
            .font(DK.Typography.title3)
            .foregroundStyle(DK.Color.fieldValue)
            .frame(width: 44, height: 52)
            .overlay(
                RoundedRectangle(cornerRadius: DK.Metric.fieldRadius, style: .continuous)
                    .strokeBorder(state == .focused ? DK.Color.fieldBorderFocus : DK.Color.fieldBorder,
                                  lineWidth: state == .focused ? 2 : 1)
            )
    }
}

private struct CodeInputPreview: View {
    @State var code = "5321"
    var body: some View {
        DKCodeInput(code: $code).padding().background(DK.Color.bgPrimary)
    }
}

#Preview("Code Input") {
    CodeInputPreview().preferredColorScheme(.dark)
}
