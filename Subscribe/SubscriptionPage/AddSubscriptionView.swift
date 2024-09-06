import SwiftUI
import CoreData


// 구독 서비스 모델
struct SubscriptionService: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String // SF Symbols 이름
}

// 구독 서비스 목록
let subscriptionServices: [SubscriptionService] = [
    SubscriptionService(name: "Netflix", imageName: "Netflix"),
    SubscriptionService(name: "Spotify", imageName: "Spotify"),
    SubscriptionService(name: "Apple Music", imageName: "AppleWhite"),
    SubscriptionService(name: "Disney+", imageName: "Disney"),
    SubscriptionService(name: "YouTube Premium", imageName: "youtube"),
    SubscriptionService(name: "Naver", imageName: "naver"),
    // 필요에 따라 더 많은 서비스를 추가할 수 있습니다.
]

struct SubscriptionServiceView: View {
    let service: SubscriptionService
    
    var body: some View {
        VStack {
            Image(service.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            Text(service.name)
                .font(.caption)
        }
    }
}

// 구독 서비스 선택 뷰
struct SubscriptionSelectionView: View {
    @Binding var selectedService: String
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State private var searchText = ""

    var filteredServices: [SubscriptionService] {
        if searchText.isEmpty {
            return subscriptionServices
        } else {
            return subscriptionServices.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppColor.background.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    searchBar
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(filteredServices) { service in
                                serviceButton(for: service)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle("구독 서비스 선택", displayMode: .inline)
            .navigationBarItems(trailing: cancelButton)
        }
    }
    
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColor.subtext)
            TextField("서비스 검색", text: $searchText)
                .foregroundColor(AppColor.text)
        }
        .padding()
        .background(AppColor.cardBackground)
        .cornerRadius(15)
        .padding()
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    func serviceButton(for service: SubscriptionService) -> some View {
        Button(action: {
            selectedService = service.name
            presentationMode.wrappedValue.dismiss()
        }) {
            VStack {
                Image(service.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .padding(10)
                    .background(AppColor.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                Text(service.name)
                    .font(.caption)
                    .foregroundColor(AppColor.text)
                    .lineLimit(1)
            }
            .frame(height: 120)
            .padding()
            .background(AppColor.cardBackground)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    var cancelButton: some View {
        Button("취소") {
            presentationMode.wrappedValue.dismiss()
        }
        .foregroundColor(AppColor.primary)
    }
}


struct AddSubscriptionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    @State private var name = ""
    @State private var price = ""
    @State private var cycle = "월별"
    @State private var date = Date()
    @State private var link = ""
    @State private var category = "Independent"
    @State private var color = Color.blue
    @State private var showingSubscriptionPicker = false

    @State private var showAlert = false
    @State private var alertMessage = ""

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
                        
                        Button(action: {
                            showingSubscriptionPicker = true
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(AppColor.primary)
                                Text(name.isEmpty ? "구독 서비스 선택" : name)
                                    .foregroundColor(AppColor.text)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(AppColor.text)
                            }
                            .padding()
                            .background(AppColor.cardBackground)
                            .cornerRadius(15)
                            .shadow(color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(colorScheme == .dark ? AppColor.text.opacity(0.1) : Color.clear, lineWidth: 1)
                            )
                        }
                        .sheet(isPresented: $showingSubscriptionPicker) {
                            SubscriptionSelectionView(selectedService: $name)
                        }
                        
                        CustomTextField(icon: "dollarsign.circle", placeholder: "가격", text: $price)
                            .keyboardType(.numberPad)
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
        .alert(isPresented: $showAlert) {
            Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
    }

    private func addSubscription() {
        // Validate input
        guard !name.isEmpty, let priceValue = Int64(price), priceValue > 0 else {
            alertMessage = "모든 필드를 올바르게 입력해주세요."
            showAlert = true
            return
        }

        // Create and save new subscription
        let newSubscription = SubscriptionModel(context: viewContext)
        newSubscription.name = name
        newSubscription.price = priceValue
        newSubscription.cycle = cycle
        newSubscription.date = date
        newSubscription.link = link
        newSubscription.category = category
        newSubscription.color = UIColor(color)

        do {
            try viewContext.save()
            verifyData(newSubscription)
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            alertMessage = "저장 중 오류가 발생했습니다: \(nsError.localizedDescription)"
            showAlert = true
        }
    }

    private func verifyData(_ subscription: SubscriptionModel) {
        // Fetch the newly added subscription to verify
        let fetchRequest: NSFetchRequest<SubscriptionModel> = SubscriptionModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", subscription.name ?? "")

        do {
            let results = try viewContext.fetch(fetchRequest)
            if let savedSubscription = results.first {
                // Successfully saved and fetched the subscription, now you can validate the fields
                print("Subscription saved: \(savedSubscription.wrappedName), \(savedSubscription.price), \(savedSubscription.wrappedColor)")
                // You can add more validation or logging as needed
            } else {
                alertMessage = "구독을 저장하는 데 실패했습니다."
                showAlert = true
            }
        } catch {
            alertMessage = "저장된 데이터를 확인하는 동안 오류가 발생했습니다."
            showAlert = true
        }
    }
}


// Preview
struct SubscriptionSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SubscriptionSelectionView(selectedService: .constant(""))
                .preferredColorScheme(.light)
            
            SubscriptionSelectionView(selectedService: .constant(""))
                .preferredColorScheme(.dark)
        }
    }
}
