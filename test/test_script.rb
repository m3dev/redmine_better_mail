def test_email
    user = User.find(1)
    mail = Mailer.test_email(user).deliver
end

def issue_add
    issue = Issue.find(1)

    mail = Mailer.deliver_issue_add(issue)
end


def issue_edit
    journal = Journal.new(
      :journalized => Issue.find(1),
      :user => User.find(1),
      :created_on => Time.now)
    journal.details << JournalDetail.new(
      :property => 'relation',
      :prop_key => 'relates',
      :value => 2)
    Mailer.deliver_issue_edit(journal)
end

def issue_edit2
    issue = Issue.find(1)
    journal = issue.journals.find(20)
    Mailer.deliver_issue_edit(journal)
end

def test
  test_email
  issue_add
  issue_edit
  issue_edit2
end

Setting.default_language = 'ja'
test

Setting.default_language = 'en'
test

Setting.plain_text_mail = '1'
test

