# frozen_string_literal: true

# This migration:
# 1. Copies existing User records with role=2 (admin) into the new admins table
# 2. Demotes those users to :simple (role=0) so FK constraints remain intact
#    They will no longer be treated as admins in the app (User enum has no :admin)
class MigrateAdminUserAndRemoveAdminRole < ActiveRecord::Migration[8.1]
  def up
    # Copy every admin user → admins table, preserving email, username, password hash
    execute <<~SQL
      INSERT INTO admins (username, email, encrypted_password, created_at, updated_at)
      SELECT username, email, encrypted_password, NOW(), NOW()
      FROM users
      WHERE role = 2
    SQL

    # Demote to :simple (role=0) — keeps FK references intact.
    # These users can still log in as regular users but are no longer admins.
    execute "UPDATE users SET role = 0 WHERE role = 2"
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
      "Cannot automatically restore admin role. Update users SET role = 2 WHERE email = '<email>' manually."
  end
end
