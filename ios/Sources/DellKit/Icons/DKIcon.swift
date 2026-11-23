import SwiftUI

/// DellKit icon set. Each case mirrors a Figma component on the Icons page
/// ("Icon/Chevron Right" -> `.chevronRight`) and renders the closest SF Symbol,
/// so icons follow Dynamic Type and the system weight automatically.
public enum DKIcon: String, CaseIterable, Sendable {
    case chevronRight = "chevron.right"
    case chevronLeft = "chevron.left"
    case chevronDown = "chevron.down"
    case chevronUp = "chevron.up"
    case arrowRight = "arrow.right"
    case arrowLeft = "arrow.left"
    case plus = "plus"
    case plusCircle = "plus.circle"
    case close = "xmark"
    case check = "checkmark"
    case checkCircle = "checkmark.circle"
    case radio = "circle"
    case search = "magnifyingglass"
    case bell = "bell"
    case eye = "eye"
    case eyeOff = "eye.slash"
    case shieldCheck = "checkmark.shield"
    case laptop = "laptopcomputer"
    case monitor = "display"
    case mouse = "computermouse"
    case home = "house"
    case user = "person"
    case users = "person.2"
    case devices = "laptopcomputer.and.iphone"
    case info = "info.circle"
    case wrench = "wrench.and.screwdriver"
    case book = "book"
    case support = "headphones"
    case truck = "box.truck"
    case package = "shippingbox"
    case chat = "text.bubble"
    case thumbsUp = "hand.thumbsup"
    case thumbsDown = "hand.thumbsdown"
    case moreVertical = "ellipsis"
    case mail = "envelope"
    case signIn = "rectangle.portrait.and.arrow.right"
    case clock = "clock"

    public var image: Image { Image(systemName: rawValue) }
}
