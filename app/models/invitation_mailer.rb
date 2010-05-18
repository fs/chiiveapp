class InvitationMailer < ActionMailer::Base
  

  def thankyou(invitation_request)
    subject    'Thanks from Chiive!'
    recipients invitation_request.email
    from       'Chiive <info@chiive.com>'
    sent_on    Time.now 
    
    body       :greeting => 'Hi,', :req => invitation_request
  end

  def sent(invitation_request)
    subject    'InviteMailer#sent'
    recipients 'arrel@arrelgray.com'
    from       'info@chiive.com'
    sent_on    Time.now
    
    body       :greeting => 'Hi,'
  end

end
