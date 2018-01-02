module BetterMail
  module MailerPatch
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        before_filter :better_mail_prepend_mailer_view_path
        layout :better_mail_layout, only: [
          :issue_add, :issue_edit
        ]
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

      def better_mail_layout
        return 'mailer' unless better_mail_uses_mail_view?

        # plain text is not supported
        return 'mailer' if Setting.plain_text_mail?

        'better_mail_layout'
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
