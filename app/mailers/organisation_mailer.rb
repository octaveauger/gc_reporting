class OrganisationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  default from: "contact@antilope.io"

  # Send a request for access to the granter
  def welcome(organisation)
    @organisation = organisation

    if !@organisation.email.nil? and ['en', 'fr'].include? @organisation.locale
      I18n.with_locale(@organisation.locale) do
        mail(to: @organisation.email, subject: t('emails.welcome.subject')) do |format|
          format.html { render layout: 'email_simple.html.erb' }
          format.text
        end
      end
    end
  end
end
