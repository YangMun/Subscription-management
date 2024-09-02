import SwiftUI

// 색상 정의
struct AppColor {
    static let primary = Color(red: 0.2, green: 0.5, blue: 0.9)
    static let secondary = Color(red: 0.9, green: 0.3, blue: 0.5)
    static let background = Color(red: 0.95, green: 0.95, blue: 0.97)
    static let cardBackground = Color.white
    static let text = Color(red: 0.2, green: 0.2, blue: 0.2)
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
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [AppColor.primary, AppColor.secondary]), startPoint: .leading, endPoint: .trailing))
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
                VStack(spacing: 20) {
                    CustomTextField(icon: "pencil", placeholder: "구독 이름", text: $name)
                    CustomTextField(icon: "dollarsign.circle", placeholder: "가격", text: $price)
                        .keyboardType(.decimalPad)
                    
                    Picker("결제 주기", selection: $cycle) {
                        ForEach(cycles, id: \.self) { Text($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical)
                    
                    DatePicker("결제 날짜", selection: $date, displayedComponents: .date)
                        .padding(.vertical)
                    
                    CustomTextField(icon: "link", placeholder: "구독 링크", text: $link)
                    CustomTextField(icon: "tag", placeholder: "카테고리", text: $category)
                    
                    VStack(alignment: .leading) {
                        Text("카드 색상")
                            .font(.headline)
                        ColorPicker("", selection: $color)
                            .frame(height: 50)
                    }
                    .padding(.vertical)
                    
                    CustomButton(title: "구독 추가", action: addSubscription)
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
    @State private var showingAddSubscription = false

    var body: some View {
        ZStack {
            AppColor.background.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(subscriptions) { subscription in
                        NavigationLink(destination: EditSubscriptionView(subscription: binding(for: subscription))) {
                            SubscriptionCard(subscription: subscription)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle("내 구독", displayMode: .large)
        .navigationBarItems(trailing: Button(action: {
            showingAddSubscription = true
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(AppColor.primary)
        })
        .sheet(isPresented: $showingAddSubscription) {
            NavigationView {
                AddSubscriptionView(subscriptions: $subscriptions)
            }
        }
    }

    private func binding(for subscription: Subscription) -> Binding<Subscription> {
        guard let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) else {
            fatalError("Subscription not found")
        }
        return $subscriptions[index]
    }
}

// 구독 카드 뷰
struct SubscriptionCard: View {
    let subscription: Subscription
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(subscription.name)
                .font(.headline)
                .foregroundColor(.white)
            Text("\(subscription.price, specifier: "%.f")원")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(subscription.cycle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .padding()
        .background(subscription.color)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
    }
}

// 3. 구독 수정 화면
struct EditSubscriptionView: View {
    @Binding var subscription: Subscription
    @Environment(\.presentationMode) var presentationMode

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
                }
                .padding()
            }
        }
        .navigationBarTitle("구독 수정", displayMode: .inline)
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
        .navigationBarTitle("구독 통계", displayMode: .large)
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

// 메인 컨텐트 뷰
struct ContentView: View {
    @State private var subscriptions: [Subscription] = []

    var body: some View {
        NavigationView {
            TabView {
                SubscriptionListView(subscriptions: $subscriptions)
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("구독 목록")
                    }
                
                SubscriptionStatsView(subscriptions: subscriptions)
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("통계")
                    }
            }
            .accentColor(AppColor.primary)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
