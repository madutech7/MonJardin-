import SwiftUI

public struct InfoRow: View {
    let icon: String
    let title: String
    let value: String

    public init(icon: String, title: String, value: String) {
        self.icon = icon
        self.title = title
        self.value = value
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}
