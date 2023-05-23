//
//  ContentView.swift
//  Low Profile
//
//  Created by Nindi Gill on 2/3/2022.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.openURL)
    var openURL: OpenURLAction
    @State private var profiles: [Profile] = []
    @State private var selectedProfile: Profile?
    @State private var selectedPayload: Payload?
    @State private var searchString: String = ""
    @State private var refreshing: Bool = false
    private var filteredProfiles: [Profile] {
        searchString.isEmpty ? profiles : profiles.filter { $0.name.lowercased().contains(searchString.lowercased()) }
    }
    private let sidebarWidth: CGFloat = 250
    private let width: CGFloat = 1_080
    private let height: CGFloat = 720

    var body: some View {
        NavigationSplitView {
            List(filteredProfiles, selection: $selectedProfile) { profile in
                NavigationLink(value: profile) {
                    SidebarProfileRow(profile: profile)
                }
            }
            .frame(minWidth: sidebarWidth)
        } content: {
            if let profile: Profile = selectedProfile {
                List(profile.payloads, selection: $selectedPayload) { payload in
                    NavigationLink(value: payload) {
                        SidebarPayloadRow(payload: payload)
                    }
                }
                .frame(minWidth: sidebarWidth)
            } else {
                EmptyView()
                    .frame(width: sidebarWidth)
            }
        } detail: {
            if let profile: Profile = selectedProfile {
                if let payload: Payload = selectedPayload {
                    Detail(payload: payload, certificates: profile.certificates)
                } else {
                    Text("Select a Payload to view its contents 🙂")
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Select a Profile to view its contents 🙂")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
        }
        .searchable(text: $searchString)
        .toolbar {
            ToolbarItemGroup {
                Button {
                    refreshProfiles()
                } label: {
                    Label("Refresh Profiles", systemImage: "arrow.clockwise")
                        .foregroundColor(.accentColor)
                }
                .help("Refresh Profiles")
                Button {
                    homepage()
                } label: {
                    Label("Visit Website", systemImage: "questionmark.circle")
                        .foregroundColor(.accentColor)
                }
                .help("Visit Website")
            }
        }
        .frame(minWidth: width, minHeight: height)
        .sheet(isPresented: $refreshing) {
            RefreshView()
        }
        .onAppear {
            refreshProfiles()
        }
    }

    func refreshProfiles() {

        refreshing = true

        Task {
            let profiles: [Profile] = ProfileHelper.shared.getProfiles()
            self.profiles = profiles
            selectedProfile = profiles.first
            selectedPayload = selectedProfile?.payloads.first
            refreshing = false
        }
    }

    private func homepage() {

        guard let url: URL = URL(string: .repositoryURL) else {
            return
        }

        openURL(url)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
