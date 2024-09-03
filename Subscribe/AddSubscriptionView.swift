import SwiftUI
import CoreData

// 1. 구독 추가 화면 (CoreData 적용)
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
    }

    private func addSubscription() {
        let newSubscription = SubscriptionModel(context: viewContext)
        newSubscription.name = name
        newSubscription.price = Int64(price) ?? 0
        newSubscription.cycle = cycle
        newSubscription.date = date
        newSubscription.link = link
        newSubscription.category = category
        newSubscription.color = UIColor(color)

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    AddSubscriptionView()
}
