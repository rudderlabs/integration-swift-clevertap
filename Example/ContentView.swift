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

                        Button("Identify (User Id Only)") {
                            analyticsManager.identifyUserIdOnly()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Identify (Company Traits)") {
                            analyticsManager.identifyUserWithCompanyTraits()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Identify (Female Gender)") {
                            analyticsManager.identifyUserWithFemaleGender()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Identify (Birthday Out Of Range)") {
                            analyticsManager.identifyUserWithOutOfRangeBirthday()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Identify (Birthday Malformed)") {
                            analyticsManager.identifyUserWithMalformedBirthday()
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

                        Button("Track (Nested Properties)") {
                            analyticsManager.trackEventWithNestedProperties()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)

                    // Order Completed Section
                    VStack(spacing: 12) {
                        Text("Order Completed")
                            .font(.headline)

                        Button("No Properties") {
                            analyticsManager.orderCompletedWithoutProperties()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("No Products") {
                            analyticsManager.orderCompletedWithoutProducts()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("With Order Id") {
                            analyticsManager.orderCompletedWithOrderId()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Single Product") {
                            analyticsManager.orderCompletedWithSingleProduct()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Single Product + Order Id") {
                            analyticsManager.orderCompletedWithSingleProductAndOrderId()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Multiple Products") {
                            analyticsManager.orderCompletedWithMultipleProducts()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Non Numeric Revenue") {
                            analyticsManager.orderCompletedWithNonNumericRevenue()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)

                    // Screen Events Section
                    VStack(spacing: 12) {
                        Text("Screen Events")
                            .font(.headline)

                        Button("Screen (With Properties)") {
                            analyticsManager.screenEventWithProperties()
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Button("Screen (No Properties)") {
                            analyticsManager.screenEventWithoutProperties()
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
