import SwiftUI

// The same three review screens that live in the Figma file, built from DellKit views.
// Drop `DKCatalog()` into any app target to browse the system on a device.

public struct DKCatalog: View {
    public init() {}

    public var body: some View {
        TabView {
            NavigationStack { DashboardScreen() }
                .tabItem { DKTabLabel("Home", icon: .home) }
            NavigationStack { CreateAccountScreen() }
                .tabItem { DKTabLabel("Sign Up", icon: .user) }
            NavigationStack { AssistantScreen() }
                .tabItem { DKTabLabel("Assistant", icon: .chat) }
        }
        .dkTabBarStyle()
        .preferredColorScheme(.dark)
    }
}

/// Figma: Review — Dashboard
struct DashboardScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DK.Metric.space3) {
                DKListRow("Track shipments (2 devices)", icon: .truck)
                DKSectionHeader("Your Laptop") {}
                DKDeviceCard("XPS 13", serviceTag: "H7JK09K")
                DKListRow("Transfer files to your new PC")
                DKListRow("Warranty", icon: .shieldCheck, trailing: .value("Premium Support Plus"))
                DKSectionHeader("Your Accessories") {}
                DKDeviceListItem("Dell UltraSharp 38 Curved USB-C Hub Monitor", assigned: 1, total: 1)
                DKSectionHeader("Tips for you", actionIcon: nil)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DK.Metric.space3) {
                        DKTipCard(number: 1, title: "Keyboard Backlight", message: "Turn on the keyboard backlight to work comfortably in low light. Press F10 to cycle brightness.") {}
                        DKTipCard(number: 2, title: "Windows Ink Workspace", message: "Open pen apps such as Screen Sketch and Sticky Notes with one press of the pen button.") {}
                    }
                }
            }
            .padding(.horizontal, DK.Metric.space4)
            .padding(.bottom, DK.Metric.space6)
        }
        .background(DK.Color.bgPrimary)
        .dkNavigationBar("Dashboard")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {} label: { DKIcon.bell.image.foregroundStyle(DK.Color.iconPrimary) }
                    .accessibilityLabel("Notifications")
            }
        }
    }
}

/// Figma: Review — Create Account
struct CreateAccountScreen: View {
    @State private var first = "Sophie"
    @State private var last = "Johnson"
    @State private var email = "sophie.johnson@"
    @State private var password = ""
    @State private var confirm = ""
    @State private var code = "5321"

    private var emailError: String? {
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty else { return "Enter a valid email address" }
        let domain = parts[1]
        let valid = domain.contains(".") && !domain.hasPrefix(".") && !domain.hasSuffix(".")
        return valid ? nil : "Enter a valid email address"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DK.Metric.space4) {
                Text("Create your account").font(DK.Typography.title2).foregroundStyle(DK.Color.textPrimary)
                Text("Manage your Dell devices, warranties and support in one place.")
                    .font(DK.Typography.footnote).foregroundStyle(DK.Color.textSecondary)
                DKTextField("First Name*", text: $first)
                DKTextField("Last Name*", text: $last)
                DKTextField("Email Address*", text: $email, error: emailError)
                DKTextField("Password*", text: $password, isSecure: true)
                DKTextField("Confirm Password*", text: $confirm, isSecure: true)
                Text("By using the app, I agree to the Terms of use and Privacy policy")
                    .font(DK.Typography.caption).foregroundStyle(DK.Color.textSecondary)
                    .frame(maxWidth: .infinity).multilineTextAlignment(.center)
                    .padding(.top, DK.Metric.space6)
                DKButton("Create Account") {}.disabled(emailError != nil || password.isEmpty || password != confirm)
                DKCodeInput(code: $code).frame(maxWidth: .infinity)
                DKButton("Verify") {}.disabled(code.count < 6)
                DKButton("Sign in with Dell ID", style: .outline, icon: .signIn) {}
            }
            .padding(DK.Metric.space6)
        }
        .background(DK.Color.bgPrimary)
    }
}

/// Figma: Review — Virtual Assistant
struct AssistantScreen: View {
    @State private var feedback: DKFeedbackButton.Kind? = .up
    private let me = DKAvatar(initials: "SJ")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DK.Metric.space3) {
                DKChatMessage("Hello Sophie! Please select which product you need support for.", sender: .assistant)
                VStack(spacing: 0) {
                    DKChatProductOption("XPS 13") {}
                    DKChatProductOption("Dell Premium Wireless Keyboard and Mouse") {}
                    DKChatProductOption("Dell UltraSharp 38 Curved USB-C Hub Monitor") {}
                }
                .frame(maxWidth: 240).padding(.leading, 40)
                DKChatMessage("XPS 13", sender: .user, userAvatar: me)
                DKChatMessage("Please select the applicable option for your device", sender: .assistant)
                DKQuickReplies(["Keyboard is not working", "Charging issue", "Display issue", "Damaged device", "Other issues"]) { _ in }
                DKChatMessage("Display issue", sender: .user, userAvatar: me)
                DKChatMessage("Here are some related articles and videos that might help you", sender: .assistant)
                VStack(alignment: .leading, spacing: DK.Metric.space2) {
                    DKArticleCard("How to Fix a Boot Problem (Official Dell problem solving)") {}
                    DKArticleCard("Dell XPS 13 9310 Review - The 13\" Laptop I'd Use") {}
                }
                .padding(.leading, 40)
                DKChatMessage("Was this helpful?", sender: .assistant)
                DKFeedbackPrompt(selection: $feedback)
                DKChatMessage("Thanks for the feedback! Can I assist you with anything else?", sender: .assistant)
            }
            .padding(DK.Metric.space4)
        }
        .background(DK.Color.bgPrimary)
        .dkNavigationBar("Dell Virtual Assistant", subtitle: "24*7 Support Chat")
    }
}

#Preview("Catalog") {
    DKCatalog()
}
