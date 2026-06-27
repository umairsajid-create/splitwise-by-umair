# frozen_string_literal: true

puts "🌱 Seeding database..."

# ============================================
# 1. Create Users
# ============================================
puts "  Creating users..."

admin = User.create!(
  email: "admin@splitwise.com",
  password: "password123",
  password_confirmation: "password123",
  username: "admin_user",
  role: :admin,
  daily_expense_limit: 0,
  daily_settlement_limit: 0,
  default_currency: "PKR"
)

premium = User.create!(
  email: "premium@splitwise.com",
  password: "password123",
  password_confirmation: "password123",
  username: "premium_user",
  role: :premium,
  daily_expense_limit: 0,
  daily_settlement_limit: 0,
  default_currency: "PKR"
)

simple1 = User.create!(
  email: "user1@example.com",
  password: "password123",
  password_confirmation: "password123",
  username: "simple_user1",
  role: :simple,
  default_currency: "PKR"
)

simple2 = User.create!(
  email: "user2@example.com",
  password: "password123",
  password_confirmation: "password123",
  username: "simple_user2",
  role: :simple,
  default_currency: "PKR"
)

simple3 = User.create!(
  email: "user3@example.com",
  password: "password123",
  password_confirmation: "password123",
  username: "simple_user3",
  role: :simple,
  default_currency: "USD"
)

puts "  ✅ Created #{User.count} users"

# ============================================
# 2. Create Groups
# ============================================
puts "  Creating groups..."

home_group = Group.create!(
  creator: premium,
  name: "Apartment Expenses",
  group_type: :home
)

trip_group = Group.create!(
  creator: premium,
  name: "Islamabad Trip 2026",
  group_type: :trip
)

couple_group = Group.create!(
  creator: admin,
  name: "Family Budget",
  group_type: :couple
)

puts "  ✅ Created #{Group.count} groups"

# ============================================
# 3. Add Group Members
# ============================================
puts "  Adding group members..."

# Home group — 4 members
[ premium, simple1, simple2, simple3 ].each do |user|
  GroupMember.create!(
    group: home_group,
    user: user,
    invited_by: premium,
    role: user == premium ? :admin : :member,
    joined_at: Time.current - rand(1..30).days
  )
end

# Trip group — 3 members
[ premium, simple1, admin ].each do |user|
  GroupMember.create!(
    group: trip_group,
    user: user,
    invited_by: premium,
    role: user == premium ? :admin : :member,
    joined_at: Time.current - rand(1..10).days
  )
end

# Couple group — 2 members
[ admin, simple1 ].each do |user|
  GroupMember.create!(
    group: couple_group,
    user: user,
    invited_by: admin,
    role: user == admin ? :admin : :member,
    joined_at: Time.current - rand(1..5).days
  )
end

puts "  ✅ Created #{GroupMember.count} group memberships"

# ============================================
# 4. Create Expenses
# ============================================
puts "  Creating expenses..."

categories = %i[food transport entertainment utilities rent shopping]

# Home group expenses
8.times do |i|
  expense = Expense.create!(
    group: home_group,
    created_by: [ premium, simple1, simple2 ].sample,
    record_type: :expense,
    category: categories.sample,
    title: [ "Groceries", "Electricity Bill", "Internet", "Dinner Out", "Gas Bill",
            "House Cleaning", "Netflix Subscription", "Water Bill" ][i],
    total_amount_cents: rand(500..50000),
    currency: "PKR",
    split_type: :equal,
    expense_date: Date.current - rand(0..30).days,
    status: :active
  )

  # Create equal splits for all home group members
  members = home_group.members
  per_person = expense.total_amount_cents / members.count
  payer = expense.created_by

  members.each do |member|
    ExpenseSplit.create!(
      expense: expense,
      user: member,
      owed_amount_cents: per_person,
      paid_amount_cents: member == payer ? expense.total_amount_cents : 0
    )
  end
end

# Trip group expenses
5.times do |i|
  expense = Expense.create!(
    group: trip_group,
    created_by: [ premium, simple1, admin ].sample,
    record_type: :expense,
    category: [ :food, :transport, :entertainment ].sample,
    title: [ "Hotel Room", "Bus Tickets", "Lunch at Monal", "Faisal Mosque Taxi", "Souvenirs" ][i],
    total_amount_cents: rand(1000..100000),
    currency: "PKR",
    split_type: :equal,
    expense_date: Date.current - rand(0..14).days,
    status: :active
  )

  members = trip_group.members
  per_person = expense.total_amount_cents / members.count
  payer = expense.created_by

  members.each do |member|
    ExpenseSplit.create!(
      expense: expense,
      user: member,
      owed_amount_cents: per_person,
      paid_amount_cents: member == payer ? expense.total_amount_cents : 0
    )
  end
end

puts "  ✅ Created #{Expense.count} expenses with #{ExpenseSplit.count} splits"

# ============================================
# 5. Create a Settlement
# ============================================
puts "  Creating settlement..."

settlement = Expense.create!(
  group: home_group,
  created_by: simple1,
  record_type: :settlement,
  category: :general,
  title: "Settlement: #{simple1.username} → #{premium.username}",
  total_amount_cents: 5000,
  currency: "PKR",
  split_type: :exact,
  expense_date: Date.current,
  status: :active
)

# simple1 paid 5000 to premium
ExpenseSplit.create!(expense: settlement, user: simple1, paid_amount_cents: 5000, owed_amount_cents: 0)
ExpenseSplit.create!(expense: settlement, user: premium, paid_amount_cents: 0, owed_amount_cents: 5000)

puts "  ✅ Created 1 settlement"

# ============================================
# 6. Create Notifications
# ============================================
puts "  Creating notifications..."

3.times do
  expense = Expense.where(record_type: :expense).order("RANDOM()").first
  notification = Notification.create!(
    actor: expense.created_by,
    notifiable: expense,
    notification_type: :expense_added,
    title: "New expense: #{expense.title}",
    body: "#{expense.created_by.username} added \"#{expense.title}\" for #{expense.total_amount / 100.0} #{expense.currency}"
  )

  # Send to all group members except the actor
  expense.group.members.where.not(id: expense.created_by_id).each do |member|
    NotificationRecipient.create!(notification: notification, recipient: member)
  end
end

puts "  ✅ Created #{Notification.count} notifications with #{NotificationRecipient.count} recipients"

# ============================================
# 7. Create Subscription
# ============================================
puts "  Creating subscription..."

Subscription.create!(
  user: premium,
  plan: :monthly,
  status: :active,
  amount_cents: 99900,
  currency: "PKR",
  payment_method: :credit_card,
  transaction_id: "TXN-#{SecureRandom.hex(8).upcase}",
  starts_at: 15.days.ago,
  ends_at: 15.days.from_now
)

puts "  ✅ Created #{Subscription.count} subscription"

# ============================================
# 8. Create a Pending Invitation
# ============================================
puts "  Creating invitation..."

GroupInvitation.create!(
  group: trip_group,
  invited_by: premium,
  email: "newuser@example.com",
  status: :pending,
  expires_at: 7.days.from_now
)

puts "  ✅ Created #{GroupInvitation.count} invitation"

# ============================================
# Done!
# ============================================
puts ""
puts "🎉 Seed complete!"
puts "   Users: #{User.count}"
puts "   Groups: #{Group.count}"
puts "   Members: #{GroupMember.count}"
puts "   Expenses: #{Expense.count} (#{Expense.expenses_only.count} expenses + #{Expense.settlements_only.count} settlements)"
puts "   Splits: #{ExpenseSplit.count}"
puts "   Notifications: #{Notification.count} → #{NotificationRecipient.count} recipients"
puts "   Subscriptions: #{Subscription.count}"
puts "   Invitations: #{GroupInvitation.count}"
puts ""
puts "📧 Login credentials (all passwords: 'password123'):"
puts "   Admin:   admin@splitwise.com"
puts "   Premium: premium@splitwise.com"
puts "   User 1:  user1@example.com"
puts "   User 2:  user2@example.com"
puts "   User 3:  user3@example.com"
