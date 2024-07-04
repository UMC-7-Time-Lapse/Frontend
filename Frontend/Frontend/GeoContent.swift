import SwiftUI
import MapKit
import PhotosUI

/// GeoContent 뷰는 사용자가 현재 위치를 기반으로 타임 캡슐을 생성하고, 사진 및 동영상을 선택할 수 있도록 하는 UI를 제공합니다.
struct GeoContent: View {
    /// Geofencing 클래스의 인스턴스. 위치 업데이트 및 지오펜싱을 관리합니다.
    @StateObject private var geofencing = Geofencing()
    
    /// 지도의 표시 영역을 정의하는 MKCoordinateRegion.
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334728, longitude: -122.008903),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    /// PhotosPicker가 표시되는지 여부를 제어하는 변수.
    @State private var isPickerPresented = false
    
    /// 사용자가 선택한 사진 또는 동영상 항목을 저장하는 변수 배열.
    @State private var selectedItems: [PhotosPickerItem] = []
    
    /// 선택된 미디어 데이터(사진 또는 동영상)를 저장하는 변수 배열.
    @State private var selectedMediaData: [Data] = []
    
    /// 글 작성 화면으로의 네비게이션 여부를 제어하는 변수.
    @State private var isWriteContentViewPresented = false
    
    var body: some View {
        NavigationView {
            VStack {
                /// 현재 위치와 지오펜싱 영역을 표시하는 Map 뷰.
                Map(coordinateRegion: $region, showsUserLocation: true)
                    .frame(height: 300)
                    .onChange(of: geofencing.userLocation) { newLocation in
                        // 사용자의 현재 위치가 업데이트되면 지도의 중심을 새 위치로 이동.
                        if let newLocation = newLocation {
                            region.center = newLocation
                        }
                    }
                
                /// 사용자가 지오펜싱 영역에 진입했는지 여부를 표시하는 텍스트.
                if geofencing.didEnterRegion {
                    Text("You have arrived at your time capsule location. Open it now!")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                } else {
                    Text("Moving towards your time capsule location...")
                        .padding()
                }
                
                /// 사용자가 사진/동영상을 선택할 수 있는 PhotosPicker를 표시하는 버튼.
                Button(action: {
                    isPickerPresented = true
                }) {
                    Text("캡슐 생성하기")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .photosPicker(isPresented: $isPickerPresented, selection: $selectedItems, matching: .any(of: [.images, .videos]))
                .onChange(of: selectedItems) { newItems in
                    // 사용자가 사진/동영상을 선택하거나 취소했을 때, 선택한 항목을 로드 또는 삭제.
                    Task {
                        var newData: [Data] = []
                        for item in newItems {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                newData.append(data)
                            }
                        }
                        // 선택된 미디어 데이터 배열을 업데이트
                        selectedMediaData = newData
                    }
                }
                
                /// 사용자가 선택한 사진/동영상이 있을 때만 표시되는 '다음' 버튼.
                if !selectedMediaData.isEmpty {
                    NavigationLink(destination: WriteContentView(selectedMediaData: selectedMediaData, geofencing: geofencing), isActive: $isWriteContentViewPresented) {
                        Button(action: {
                            isWriteContentViewPresented = true
                        }) {
                            Text("다음")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .onAppear {
                // 뷰가 나타날 때 didEnterRegion 변수를 초기화.
                geofencing.didEnterRegion = false
            }
        }
    }
}

struct GeoContent_Previews: PreviewProvider {
    static var previews: some View {
        GeoContent()
    }
}
