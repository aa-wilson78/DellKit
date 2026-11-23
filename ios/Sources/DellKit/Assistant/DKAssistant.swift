import SwiftUI

/// Figma: _Assistant Avatar (private). The assistant's identity mark.
struct DKAssistantMark: View {
    var body: some View {
        DKIcon.chat.image
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(DK.Color.textOnPrimary)
            .frame(width: 32, height: 32)
            .background(DK.Color.actionPrimaryDefault, in: RoundedRectangle(cornerRadius: DK.Metric.radiusSm, style: .continuous))
            .accessibilityHidden(true)
    }
}

/// Figma: Chat Message (Sender = Assistant | User)
public struct DKChatMessage: View {
    public enum Sender: Sendable { case assistant, user }

    private let text: String
    private let sender: Sender
    private let userAvatar: DKAvatar?
    private let showsAvatar: Bool

    public init(_ text: String, sender: Sender, userAvatar: DKAvatar? = nil, showsAvatar: Bool = true) {
        self.text = text
        self.sender = sender
        self.userAvatar = userAvatar
        self.showsAvatar = showsAvatar
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: DK.Metric.space2) {
            if sender == .user { Spacer(minLength: 48) }
            if sender == .assistant && showsAvatar { DKAssistantMark() }

            Text(text)
                .font(DK.Typography.footnote)
                .foregroundStyle(sender == .user ? DK.Color.chatUserText : DK.Color.chatAssistantText)
                .padding(.horizontal, DK.Metric.chatBubblePadding)
                .padding(.vertical, DK.Metric.space2)
                .background(
                    sender == .user ? DK.Color.chatUserBubble : DK.Color.chatAssistantBubble,
                    in: RoundedRectangle(cornerRadius: DK.Metric.chatBubbleRadius, style: .continuous)
                )
                .frame(maxWidth: 240, alignment: sender == .user ? .trailing : .leading)

            if sender == .user && showsAvatar, let userAvatar { userAvatar }
            if sender == .assistant { Spacer(minLength: 0) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel((sender == .assistant ? "Assistant: " : "You: ") + text)
    }
}

/// Figma: Quick Replies. Tappable answers under an assistant message.
public struct DKQuickReplies: View {
    private let options: [String]
    private let onSelect: (String) -> Void

    public init(_ options: [String], onSelect: @escaping (String) -> Void) {
        self.options = options
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                DKButton(option, style: .text) { onSelect(option) }
            }
        }
        .padding(.leading, 40) // aligns with the assistant bubble
    }
}

/// Figma: Chat Product Option. A product choice in the assistant's "which product?" list.
public struct DKChatProductOption: View {
    private let name: String
    private let image: Image?
    private let action: () -> Void

    public init(_ name: String, image: Image? = nil, action: @escaping () -> Void) {
        self.name = name
        self.image = image
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DK.Metric.space3) {
                DKProductMedia(image, size: .small)
                Text(name).font(DK.Typography.footnote).foregroundStyle(DK.Color.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(DK.Metric.space2)
            .overlay(alignment: .bottom) { Rectangle().fill(DK.Color.listRowDivider).frame(height: 1) }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Figma: Article Card. A help article or video suggested by the assistant.
public struct DKArticleCard: View {
    private let title: String
    private let thumbnail: Image?
    private let action: () -> Void

    public init(_ title: String, thumbnail: Image? = nil, action: @escaping () -> Void) {
        self.title = title
        self.thumbnail = thumbnail
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DK.Metric.space3) {
                DKProductMedia(thumbnail, size: .small)
                Text(title).font(DK.Typography.footnote).foregroundStyle(DK.Color.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(DK.Metric.space2)
            .frame(maxWidth: 240)
            .background(DK.Color.cardBackground, in: RoundedRectangle(cornerRadius: DK.Metric.radiusSm, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

/// Figma: Feedback Button (Type = Up | Down, State = Default | Selected)
public struct DKFeedbackButton: View {
    public enum Kind: Sendable { case up, down }

    private let kind: Kind
    private let isSelected: Bool
    private let action: () -> Void

    public init(_ kind: Kind, isSelected: Bool, action: @escaping () -> Void) {
        self.kind = kind
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: DK.Metric.space1) {
                (kind == .up ? DKIcon.thumbsUp : DKIcon.thumbsDown).image
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? DK.Color.textOnPrimary : DK.Color.iconPrimary)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(isSelected ? DK.Color.buttonPrimaryBackground : DK.Color.cardBackground,
                                in: RoundedRectangle(cornerRadius: DK.Metric.radiusSm, style: .continuous))
                Text(kind == .up ? "Yes" : "No").font(DK.Typography.caption).foregroundStyle(DK.Color.textSecondary)
            }
            .frame(width: 96)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(kind == .up ? "Helpful" : "Not helpful")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// "Was this helpful?" Yes / No pair, the way the flows use Feedback Button.
public struct DKFeedbackPrompt: View {
    @Binding private var selection: DKFeedbackButton.Kind?

    public init(selection: Binding<DKFeedbackButton.Kind?>) {
        self._selection = selection
    }

    public var body: some View {
        HStack(spacing: DK.Metric.space3) {
            DKFeedbackButton(.up, isSelected: selection == .up) { selection = .up }
            DKFeedbackButton(.down, isSelected: selection == .down) { selection = .down }
        }
        .padding(.leading, 40)
    }
}
