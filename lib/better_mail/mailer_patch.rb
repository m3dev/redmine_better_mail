module BetterMail
  module MailerPatch
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        before_filter :better_mail_prepend_mailer_view_path
      end
    end

    module InstanceMethods
      def better_mail_prepend_mailer_view_path
        return unless better_mail_uses_mail_view?

        prepend_view_path File.join(
          better_mail_plugin.directory,
          'app', 'better_mail_patched_views'
        )
      end

      private

      def better_mail_plugin
        Redmine::Plugin.find(:redmine_better_mail)
      end

      def better_mail_uses_mail_view?
        (Setting.plugin_redmine_better_mail || {})['uses_mails_view']
      end
    end
  end
end
