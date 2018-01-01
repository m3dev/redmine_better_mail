
Redmine::Plugin.register :readable_mail do
  name 'Readable mail plugin'
  author 'tak'
  description 'This is a plugin for Redmine readable mail'
  version '0.0.1'
  url ''
  author_url ''
end


Rails.application.config.to_prepare do
  unless Mailer.included_modules.include?(ReadableMail::MailerPatch)
    Mailer.send :include, ReadableMail::MailerPatch
  end

  ActionView::Base.send(:include, FineMailHelper)
end

