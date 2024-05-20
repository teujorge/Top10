//
//  Styles.swift
//  Top10
//
//  Created by Matheus Jorge on 5/20/24.
//

import SwiftUI

// MARK: CustomTextFieldStyle

struct CustomTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
    }
}
