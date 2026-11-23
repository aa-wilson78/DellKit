import UIKit
import SwiftUI

// Figma's Navigation Bar and Tab Bar map onto system chrome rather than custom views:
// NavigationStack + toolbar for the top bar, TabView for the bottom bar. That keeps back
// gestures, large-title behaviour, VoiceOver and safe areas native.

/// Figma: Navigation Bar. Centered title with optional subtitle (e.g. "Dell Virtual Assistant / 24*7 Support Chat").
public struct DKNavigationBarModifier: ViewModifier {
    let title: String
    let subtitle: String?

    public func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text(title).font(DK.Typography.headline).foregroundStyle(DK.Color.textPrimary)
                        if let subtitle {
                            Text(subtitle).font(DK.Typography.caption).foregroundStyle(DK.Color.textSecondary)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(.isHeader)
                }
            }
            .toolbarBackground(DK.Color.bgPrimary, for: .navigationBar)
    }
}

/// Figma: Tab Bar + Tab Item. Applies DellKit colors to a system `TabView`.
public struct DKTabBarModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .tint(DK.Color.tabBarActive)
            .toolbarBackground(DK.Color.tabBarBackground, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .onAppear(perform: Self.applyInactiveColor)
    }

    /// SwiftUI has no API for the unselected tab color yet, so set it through UIKit appearance once.
    private static func applyInactiveColor() {
        let inactive = UIColor(DK.Color.tabBarInactive)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(DK.Color.tabBarBackground)
        for layout in [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance] {
            layout.normal.iconColor = inactive
            layout.normal.titleTextAttributes = [.foregroundColor: inactive]
        }
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

public extension View {
    /// Figma: Navigation Bar
    func dkNavigationBar(_ title: String, subtitle: String? = nil) -> some View {
        modifier(DKNavigationBarModifier(title: title, subtitle: subtitle))
    }

    /// Figma: Tab Bar. Apply to the `TabView`.
    func dkTabBarStyle() -> some View {
        modifier(DKTabBarModifier())
    }
}

/// Figma: Tab Item. `Label` for a `TabView` tab using a DellKit icon.
public struct DKTabLabel: View {
    private let title: String
    private let icon: DKIcon

    public init(_ title: String, icon: DKIcon) {
        self.title = title
        self.icon = icon
    }

    public var body: some View {
        Label(title, systemImage: icon.rawValue)
    }
}
