import SwiftUI
import CoreData

// 3. 구독 수정 화면 (CoreData 적용)
struct EditSubscriptionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var subscription: SubscriptionModel
    @State private var showingDeleteAlert = false
    @Binding var refreshID: UUID

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

    // 변경 사항을 저장하는 함수
    private func saveChanges() {
        // 변경된 정보를 CoreData에 저장
        do {
            try viewContext.save()
            print("변경 사항이 저장되었습니다: \(subscription.wrappedName), 가격: \(subscription.price), 결제 주기: \(subscription.wrappedCycle), 결제 날짜: \(subscription.date ?? Date()), 링크: \(subscription.wrappedLink), 카테고리: \(subscription.wrappedCategory), 색상: \(subscription.wrappedColor)")
            
            refreshID = UUID()
            
            presentationMode.wrappedValue.dismiss()
            
        } catch {
            // 에러 발생 시 로그 출력
            let nsError = error as NSError
            print("변경 사항 저장 실패: \(nsError), \(nsError.userInfo)")
        }
    }

    // 구독을 삭제하는 함수
    private func deleteSubscription() {
        // CoreData에서 해당 구독 삭제 시도
        viewContext.delete(subscription)
        
        do {
            // 삭제 후 컨텍스트 저장
            try viewContext.save()
            print("구독이 성공적으로 삭제되었습니다: \(subscription.wrappedName)")
            refreshID = UUID()
            
            // 삭제 후 뷰 종료
            presentationMode.wrappedValue.dismiss()
        } catch {
            // 저장 실패 시 로그 출력
            let nsError = error as NSError
            print("구독 삭제 실패: \(nsError), \(nsError.userInfo)")
        }
    }

}
