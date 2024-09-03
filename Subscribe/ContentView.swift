import SwiftUI

// 색상 정의
struct AppColor {
    static let primary = Color(red: 0.2, green: 0.5, blue: 0.9)
    static let secondary = Color(red: 0.9, green: 0.3, blue: 0.5)
    static let background = Color(red: 0.95, green: 0.95, blue: 0.97)
    static let cardBackground = Color.white
    static let text = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let deleteRed = Color.red
}

// 구독 모델
struct Subscription: Identifiable {
    let id = UUID()
    var name: String
    var price: Double
    var cycle: String
    var date: Date
    var link: String
    var category: String
    var color: Color
}

// 커스텀 텍스트 필드
struct CustomTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppColor.primary)
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(AppColor.cardBackground)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

// UIColor를 Data로 변환하는 확장
extension UIColor {
    func encode() -> Data? {
        try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}


// 커스텀 버튼
struct CustomButton: View {
    var title: String
    var action: () -> Void
    var color: Color = AppColor.primary
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
        }
    }
}

struct StatCard: View {
    var title: String
    var value: String
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColor.text)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColor.primary)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColor.cardBackground)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct CustomTabItem: View {
    let imageName: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: imageName)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? AppColor.primary : .gray)
            Text(title)
                .font(.caption2)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? AppColor.primary : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let addAction: () -> Void
    
    var body: some View {
        ZStack {
            // 메인 탭바 배경
            RoundedRectangle(cornerRadius: 30)
                .fill(AppColor.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                .frame(height: 70)
            
            HStack(spacing: 0) {
                CustomTabItem(imageName: "list.bullet.rectangle", title: "구독", isSelected: selectedTab == 0)
                    .onTapGesture { selectedTab = 0 }
                
                Spacer()
                
                // 중앙 플러스 버튼
                Button(action: addAction) {
                    ZStack {
                        Circle()
                            .fill(AppColor.primary)
                            .shadow(color: AppColor.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -30)
                
                Spacer()
                
                CustomTabItem(imageName: "chart.pie.fill", title: "통계", isSelected: selectedTab == 1)
                    .onTapGesture { selectedTab = 1 }
            }
            .padding(.horizontal, 30)
        }
    }
}

// ContentView 수정 (CoreData 적용)
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0
    @State private var showingAddSubscription = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationView {
                    SubscriptionListView()
                        .environment(\.managedObjectContext, viewContext)
                }
                .tabItem { EmptyView() }
                .tag(0)
                
                NavigationView {
                    SubscriptionStatsView()
                        .environment(\.managedObjectContext, viewContext)
                }
                .tabItem { EmptyView() }
                .tag(1)
            }
            .accentColor(AppColor.primary)
            
            CustomTabBar(selectedTab: $selectedTab) {
                showingAddSubscription = true
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showingAddSubscription) {
            NavigationView {
                AddSubscriptionView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        return ContentView()
            .environment(\.managedObjectContext, context)
    }
}
