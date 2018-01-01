module ReadableMail
  module MailerPatch
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        before_filter :readable_mail_prepend_mailer_view_path
        layout :readable_mail_layout, only: [
          :issue_add, :issue_edit
        ]
      end
    end

    module InstanceMethods
      def readable_mail_prepend_mailer_view_path
        prepend_view_path File.join(
          Redmine::Plugin.find(:readable_mail).directory,
          'app', 'readable_mail_pached_views'
        )
      end

      def readable_mail_layout
        # plain text is not supported
        return 'mailer' if Setting.plain_text_mail?

        'readable_mail_layout'
      end
    end
  end
end

