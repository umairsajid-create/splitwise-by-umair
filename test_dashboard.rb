require_relative 'config/environment'
Rails.application.config.hosts.clear
app = ActionDispatch::Integration::Session.new(Rails.application)
admin = AdminUser.first
app.post '/admin/sign_in', params: { admin_user: { email: admin.email, password: "password" } }
app.get '/admin/analytics'
File.write('output.html', app.response.body)
