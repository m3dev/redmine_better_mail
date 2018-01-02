
Redmine::Plugin.register :redmine_better_mail do
  name 'Better Mail plugin'
  author 'tak'
  description 'This is a plugin to better Redmine mail'
  version '0.0.1'

  settings partial: 'settings/redmine_better_mail_settings',
           default: {
             'uses_mails_view' => true
           }
end


Rails.application.config.to_prepare do
  unless Mailer.included_modules.include?(BetterMail::MailerPatch)
    Mailer.send :include, BetterMail::MailerPatch
  end

  ActionView::Base.send(:include, BetterMailHelper)
end

