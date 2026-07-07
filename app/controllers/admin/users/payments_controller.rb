# frozen_string_literal: true

module Admin
  module Users
    class PaymentsController < AdminController
      before_action :set_user

      def new
        # Initialize a new subscription in memory so the form has an object to work with
        @user.subscriptions.build
      end

      def create
        # Use a database transaction so that if anything fails, we roll back completely
        ActiveRecord::Base.transaction do
          # Convert to a plain hash so injected values aren't stripped by strong params
          attrs = user_params.to_h
          sub_attrs = attrs["subscriptions_attributes"]["0"]

          # Automatically calculate start and end dates and amount based on the selected plan
          sub_attrs["starts_at"] = Time.current
          if sub_attrs["plan"] == "monthly"
            sub_attrs["ends_at"] = 1.month.from_now
            sub_attrs["amount_cents"] = 5000
          else
            sub_attrs["ends_at"] = 1.year.from_now
            sub_attrs["amount_cents"] = 50000
          end
          sub_attrs["status"] = "active"
          sub_attrs["currency"] = "PKR"

          if @user.update(attrs)
            @user.update!(role: :premium)
            redirect_to admin_user_path(@user), notice: "Payment added and user promoted to Premium."
          else
            render :new, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        end
      end

      private

      def set_user
        @user = User.find(params[:user_id])
      end

      def user_params
        # We only permit the fields the admin should be filling out in the form
        params.require(:user).permit(
          subscriptions_attributes: [
            :plan, :amount_cents, :currency, :payment_method, :transaction_id
          ]
        )
      end
    end
  end
end
