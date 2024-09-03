import SwiftUI
import CoreData

struct AddSubscriptionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var price = ""
    @State private var cycle = "월별"
    @State private var date = Date()
    @State private var link = ""
    @State private var category = "Independent"
    @State private var color = Color.blue

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
                        CustomTextField(icon: "pencil", placeholder: "구독 이름", text: $name)
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
