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

// 1. 구독 추가 화면
struct AddSubscriptionView: View {
    @State private var name = ""
    @State private var price = ""
    @State private var cycle = "월별"
    @State private var date = Date()
    @State private var link = ""
    @State private var category = ""
    @State private var color = Color.blue
    @Binding var subscriptions: [Subscription]
    @Environment(\.presentationMode) var presentationMode

    let cycles = ["월별", "분기별", "연별"]

    var body: some View {
        ZStack {
            AppColor.background.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("구독 정보")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColor.text)
                        CustomTextField(icon: "pencil", placeholder: "구독 이름", text: $name)
                        CustomTextField(icon: "dollarsign.circle", placeholder: "가격", text: $price)
                            .keyboardType(.decimalPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("결제 정보")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColor.text)
                        
                        Picker("결제 주기", selection: $cycle) {
                            ForEach(cycles, id: \.self) { Text($0) }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 5)
                        
                        DatePicker("결제 날짜", selection: $date, displayedComponents: .date)
                            .padding(.vertical, 5)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("추가 정보(선택)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColor.text)
                        CustomTextField(icon: "link", placeholder: "구독 링크", text: $link)
                        CustomTextField(icon: "tag", placeholder: "카테고리", text: $category)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("카드 색상")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColor.text)
                        ColorPicker("", selection: $color)
                            .frame(height: 50)
                    }
                    
                    CustomButton(title: "구독 추가", action: addSubscription)
                        .padding(.top, 20)
                }
                .padding()
            }
        }
        .navigationBarTitle("새 구독 추가", displayMode: .inline)
    }

    func addSubscription() {
        guard let priceValue = Double(price) else { return }
        let newSubscription = Subscription(name: name, price: priceValue, cycle: cycle, date: date, link: link, category: category, color: color)
        subscriptions.append(newSubscription)
        presentationMode.wrappedValue.dismiss()
    }
}

// 2. 구독 목록 화면
struct SubscriptionListView: View {
    @Binding var subscriptions: [Subscription]

    var body: some View {
        ZStack {
            AppColor.background.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(subscriptions) { subscription in
                        NavigationLink(destination: EditSubscriptionView(subscription: binding(for: subscription), subscriptions: $subscriptions)) {
                            SubscriptionCard(subscription: subscription)
                        }
                    }
                    .onDelete(perform: deleteSubscription)
                }
                .padding()
            }
        }
    }

    private func binding(for subscription: Subscription) -> Binding<Subscription> {
        guard let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) else {
            fatalError("Subscription not found")
        }
        return $subscriptions[index]
    }

    private func deleteSubscription(at offsets: IndexSet) {
        subscriptions.remove(atOffsets: offsets)
    }
}

// 구독 카드 뷰
struct SubscriptionCard: View {
    let subscription: Subscription
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(subscription.color)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(subscription.name.prefix(1).uppercased())
                        .font(.title2.bold())
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(subscription.name)
                    .font(.headline)
                    .foregroundColor(AppColor.text)
                Text(subscription.category)
                    .font(.subheadline)
                    .foregroundColor(AppColor.text.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text("\(subscription.price, specifier: "%.f")원")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppColor.primary)
                Text(subscription.cycle)
                    .font(.caption)
                    .foregroundColor(AppColor.text.opacity(0.7))
            }
        }
        .padding()
        .background(AppColor.cardBackground)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

// 3. 구독 수정 화면
struct EditSubscriptionView: View {
    @Binding var subscription: Subscription
    @Binding var subscriptions: [Subscription]
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false

    let cycles = ["월별", "분기별", "연별"]

    var body: some View {
        ZStack {
            AppColor.background.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    CustomTextField(icon: "pencil", placeholder: "구독 이름", text: $subscription.name)
                    CustomTextField(icon: "dollarsign.circle", placeholder: "가격", text: Binding(
                        get: { String(format: "%.f", self.subscription.price) },
                        set: { if let value = Double($0) { self.subscription.price = value } }
                    ))
                    .keyboardType(.decimalPad)
                    
                    Picker("결제 주기", selection: $subscription.cycle) {
                        ForEach(cycles, id: \.self) { Text($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical)
                    
                    DatePicker("결제 날짜", selection: $subscription.date, displayedComponents: .date)
                        .padding(.vertical)
                    
                    CustomTextField(icon: "link", placeholder: "구독 링크", text: $subscription.link)
                    CustomTextField(icon: "tag", placeholder: "카테고리", text: $subscription.category)
                    
                    VStack(alignment: .leading) {
                        Text("카드 색상")
                            .font(.headline)
                        ColorPicker("", selection: $subscription.color)
                            .frame(height: 50)
                    }
                    .padding(.vertical)
                    
                    CustomButton(title: "변경 사항 저장") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    
                    CustomButton(title: "구독 삭제", action: {
                        showingDeleteAlert = true
                    }, color: AppColor.deleteRed)
                }
                .padding()
            }
        }
        .navigationBarTitle("구독 수정", displayMode: .inline)
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("구독 삭제"),
                message: Text("정말로 이 구독을 삭제하시겠습니까?"),
                primaryButton: .destructive(Text("삭제")) {
                    deleteSubscription()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func deleteSubscription() {
        if let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) {
            subscriptions.remove(at: index)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// 검색 바
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("구독 검색", text: $text)
                .foregroundColor(AppColor.text)
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(AppColor.cardBackground)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

// 4. 구독 통계 화면
struct SubscriptionStatsView: View {
    let subscriptions: [Subscription]

    var totalMonthly: Double {
        subscriptions.reduce(0) { $0 + $1.price }
    }

    var body: some View {
        ZStack {
            AppColor.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                        .foregroundColor(AppColor.secondary)
                    
                    Circle()
                        .trim(from: 0.0, to: 0.75)
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .foregroundColor(AppColor.primary)
                        .rotationEffect(Angle(degrees: 270.0))
                    
                    VStack {
                        Text("총 월간 지출")
                            .font(.headline)
                            .foregroundColor(AppColor.text)
                        Text("\(totalMonthly, specifier: "%.f")원")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColor.primary)
                    }
                }
                .frame(height: 250)
                .padding()
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    StatCard(title: "총 구독 수", value: "\(subscriptions.count)")
                    StatCard(title: "가장 비싼 구독", value: String(format: "%.f원", subscriptions.max(by: { $0.price < $1.price })?.price ?? 0))
                    StatCard(title: "가장 저렴한 구독", value: String(format: "%.f원", subscriptions.min(by: { $0.price < $1.price })?.price ?? 0))
                    StatCard(title: "평균 구독 비용", value: String(format: "%.f원", subscriptions.isEmpty ? 0 : totalMonthly / Double(subscriptions.count)))
                }
                .padding()
            }
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

// ContentView 수정
struct ContentView: View {
    @State private var subscriptions: [Subscription] = []
    @State private var selectedTab = 0
    @State private var showingAddSubscription = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationView {
                    SubscriptionListView(subscriptions: $subscriptions)
                }
                .tabItem { EmptyView() }
                .tag(0)
                
                NavigationView {
                    SubscriptionStatsView(subscriptions: subscriptions)
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
                AddSubscriptionView(subscriptions: $subscriptions)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
