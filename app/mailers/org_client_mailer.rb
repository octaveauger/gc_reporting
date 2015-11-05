class OrgClientMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  default from: "contact@antilope.io"

  # Send a request for access to the granter
  def mandate_request(client)
    @client = client

    if !@client.email.nil? and ['en', 'fr'].include? @client.locale
      I18n.with_locale(@client.locale) do
        mail(to: @client.email, subject: t('emails.mandate_request.subject', org_name: @client.organisation.display_name)) do |format|
          format.html { render layout: 'email_simple.html.erb' }
          format.text
        end
      end
    end
  end
end
