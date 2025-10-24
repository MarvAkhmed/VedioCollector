//  CustomTabBar.swift
//  Productab
//
//  Created by Marwa Awad on 15.10.2025.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                TabBarButton(
                    iconName: Icons.homeIcon,
                    isSelected: selectedTab == 0
                ) {
                    selectedTab = 0
                }
                
                TabBarButton(
                    iconName: Icons.bellIcon,
                    isSelected: selectedTab == 1
                ) {
                    selectedTab = 1
                }
                
                centerAddButton
                
                TabBarButton(
                    iconName: Icons.commentsIcon,
                    isSelected: selectedTab == 3
                ) {
                    selectedTab = 3
                }
                
                TabBarButton(
                    iconName: Icons.profileIcon,
                    isSelected: selectedTab == 4
                ) {
                    selectedTab = 4
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(red: 0.333, green: 0.333, blue: 0.333, opacity: 0.85))
            .cornerRadius(55)
            .padding(.horizontal, 16)
            .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom : 16)
        }
    }
    
    private var centerAddButton: some View {
        Button(action: {
            selectedTab = 2
        }) {
            ZStack {
                Image(uiImage: Icons.plusIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TabBarButton: View {
    let iconName: UIImage
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(uiImage: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(isSelected ? .white : .gray.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
