import SwiftUI
import CoreData

// 3. 구독 수정 화면 (CoreData 적용)
struct EditSubscriptionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var subscription: SubscriptionModel
    @State private var showingDeleteAlert = false

    let cycles = ["월별", "분기별", "연별"]

    var body: some View {
        ZStack {
            AppColor.background.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    CustomTextField(icon: "pencil", placeholder: "구독 이름", text: Binding(
                        get: { self.subscription.wrappedName },
                        set: { self.subscription.name = $0 }
                    ))
                    CustomTextField(icon: "dollarsign.circle", placeholder: "가격", text: Binding(
                        get: { String(self.subscription.price) },
                        set: { if let value = Int64($0) { self.subscription.price = value } }
                    ))
                    .keyboardType(.numberPad)
                    
                    Picker("결제 주기", selection: Binding(
                        get: { self.subscription.wrappedCycle },
                        set: { self.subscription.cycle = $0 }
                    )) {
                        ForEach(cycles, id: \.self) { Text($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical)
                    
                    DatePicker("결제 날짜", selection: Binding(
                        get: { self.subscription.date ?? Date() },
                        set: { self.subscription.date = $0 }
                    ), displayedComponents: .date)
                        .padding(.vertical)
                    
                    CustomTextField(icon: "link", placeholder: "구독 링크", text: Binding(
                        get: { self.subscription.wrappedLink },
                        set: { self.subscription.link = $0 }
                    ))
                    CustomTextField(icon: "tag", placeholder: "카테고리", text: Binding(
                        get: { self.subscription.wrappedCategory },
                        set: { self.subscription.category = $0 }
                    ))
                    
                    VStack(alignment: .leading) {
                        Text("카드 색상")
                            .font(.headline)
                        ColorPicker("", selection: Binding(
                            get: { self.subscription.wrappedColor },
                            set: { self.subscription.color = UIColor($0) }
                        ))
                            .frame(height: 50)
                    }
                    .padding(.vertical)
                    
                    CustomButton(title: "변경 사항 저장") {
                        saveChanges()
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

    private func saveChanges() {
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func deleteSubscription() {
        // Attempt to delete the subscription from the context
        viewContext.delete(subscription)
        
        do {
            // Attempt to save the context to persist the deletion
            try viewContext.save()
            print("Subscription deleted successfully: \(subscription.wrappedName)")
            
            // Dismiss the view after successful deletion
            presentationMode.wrappedValue.dismiss()
        } catch {
            // Print error details if saving fails
            let nsError = error as NSError
            print("Failed to delete the subscription: \(nsError), \(nsError.userInfo)")
        }
    }

}
