import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Text("카메라 움직임")
            
            Image(systemName: "circle.fill")
            
            Text("카메라를 눌러 오늘의 추억을 저장하세요")
            
            Text("오늘 올라온 추억들이에요")
        }
    }
}

#Preview {
    MainView()
}
