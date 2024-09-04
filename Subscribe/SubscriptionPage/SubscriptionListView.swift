import SwiftUI
import CoreData


// 2. 구독 목록 화면 (CoreData 적용)
struct SubscriptionListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SubscriptionModel.name, ascending: true)],
        animation: .default)
    private var subscriptions: FetchedResults<SubscriptionModel>
    @State private var refreshID = UUID()
    
    var body: some View {
        ZStack {
            AppColor.background.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(subscriptions) { subscription in
                        NavigationLink(destination: EditSubscriptionView(subscription: subscription, refreshID: $refreshID)) {
                            SubscriptionCard(subscription: subscription)
                        }
                    }
                    .onDelete(perform: deleteSubscription)
                }
                .padding()
            }
            .id(refreshID)
        }
    }

    private func deleteSubscription(at offsets: IndexSet) {
        offsets.map { subscriptions[$0] }.forEach(viewContext.delete)

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

// 구독 카드 뷰 (CoreData 적용)
struct SubscriptionCard: View {
    let subscription: SubscriptionModel
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(subscription.wrappedColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(subscription.wrappedName.prefix(1).uppercased())
                        .font(.title2.bold())
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(subscription.wrappedName)
                    .font(.headline)
                    .foregroundColor(AppColor.text)
                Text(subscription.wrappedCategory)
                    .font(.subheadline)
                    .foregroundColor(AppColor.text.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text("\(subscription.price)원")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppColor.primary)
                Text(subscription.wrappedCycle)
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

#Preview {
    SubscriptionListView()
}
