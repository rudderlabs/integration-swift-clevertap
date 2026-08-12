//
//  ContentView.swift
//  Example
//

import SwiftUI
import RudderStackAnalytics

struct ContentView: View {
    private var analyticsManager = AnalyticsManager.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // User Identity Section
                    VStack(spacing: 12) {
                        Text("User Identity")
                            .font(.headline)

                        Button("Identify User") {
                            analyticsManager.identifyUser()
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        Button("Identify User (Nested Traits)") {
                            analyticsManager.identifyUserWithNestedTraits()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                    // Track Events Section
                    VStack(spacing: 12) {
                        Text("Track Events")
                            .font(.headline)

                        Button("Track (With Properties)") {
                            analyticsManager.trackEventWithProperties()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Track (No Properties)") {
                            analyticsManager.trackEventWithoutProperties()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Order Completed") {
                            analyticsManager.trackOrderCompleted()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)

                    // Screen Events Section
                    VStack(spacing: 12) {
                        Text("Screen Events")
                            .font(.headline)

                        Button("Screen Event") {
                            analyticsManager.screenEvent()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)

                    // Queue Management Section
                    VStack(spacing: 12) {
                        Text("Queue Management")
                            .font(.headline)

                        Button("Reset") {
                            analyticsManager.resetUser()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Flush") {
                            analyticsManager.flush()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("CleverTap Example")
        }
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    ContentView()
}
