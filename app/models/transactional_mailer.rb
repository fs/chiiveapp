class TransactionalMailer < ActionMailer::Base
  
  # ADD TO PRINT email IN LOCAL
  # default_url_options[:host] = "dev.17feet.com"  

  def welcome(transaction_user)
    subject    'Welcome to Chiive!'
    recipients transaction_user.email
    from       'Chiive <info@chiive.com>'
    sent_on    Time.now 
    
    body       :user => transaction_user
  end

  def get_updates_thankyou(first_name, last_name, email)
    subject    'Thanks for signing up!'
    recipients email
    from       'Chiive <info@chiive.com>'
    sent_on    Time.now
    
    body       :first_name => first_name, :last_name => last_name, :email => email
  end

  def password_reset_instructions(transaction_user)  
    subject    "Password Reset Instructions for Chiive" 
    recipients transaction_user.email  
    from       'Chiive <info@chiive.com>'
    sent_on    Time.now  
    
    body       :user => transaction_user, :edit_password_reset_url => edit_password_reset_url(transaction_user.perishable_token)  
  end
end
