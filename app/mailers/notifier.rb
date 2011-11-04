class Notifier < ActionMailer::Base
  layout 'notification'
  default :from => AppConfig.notification_email

  helper :application

  def new_question(user, group, question, topic)
    @user = user
    @group = group
    @question = question
    @domain = group.domain
    @topic = topic
    @disable_link = topic_url(@topic)

    scope = "mailers.notifications.new_question"

    subject = I18n.t("subject",
                     :scope => scope,
                     :topic => @topic.title)

    mail(:to => user.email, :subject => subject)
  end

  def new_answer(user, group, answer, following = false)
    @user = user     #question creator
    @group = group
    @answer = answer #answer.user
    @following = following

    @domain = group.domain
    @question = @answer.question

    scope = "mailers.notifications.new_answer"

    if user == answer.question.user
      subject = I18n.t("subject_owner",
                       :scope => scope,
                       :title => answer.question.title,
                       :name => answer.user.name)
    elsif following
      subject = I18n.t("subject_friend",
                       :scope => scope,
                       :title => answer.question.title,
                       :name => answer.user.name)
    else
      subject = I18n.t("subject_other",
                       :scope => scope,
                       :title => answer.question.title,
                       :name => answer.user.name)
    end

    mail(:to => user.email, :subject => subject)
  end

  def new_search_result(user, group, search_result)
    @user = user
    @group = group
    @search_result = search_result
    @following = true

    @domain = group.domain
    @question = @search_result.question

    subject = if user == search_result.question.user
                I18n.t('subject_owner',
                       :scope => [:mailers, :notifications, :new_search_result],
                       :title => search_result.question.title,
                       :name => search_result.user.name)
              else
                I18n.t('subject_other',
                       :scope => [:mailers, :notifications, :new_search_result],
                       :title => search_result.question.title,
                       :name => search_result.user.name)
              end

    mail(:to => user.email, :subject => subject)
  end

  def new_comment(comment, params)
    @comment = comment
    @user = params[:recipient]
    @question = comment.find_question
    @group = @question.group

    mail(:to => @user.email,
         :subject => t(:subject,
                       :scope => [:mailers, :notifications, :new_comment],
                       :question => @question.title))
  end

  def new_feedback(user, title, content, email, ip)
    @user = user
    @title = title
    @content = content
    @email = email
    @ip = ip

    recipients = AppConfig.exception_notification["exception_recipients"]
    subject = "feedback: #{title}"

    mail(:to => recipients, :subject => subject)
  end

  def user_accepted_suggestion(origin, user, entry)
    @user, @origin, @entry, @domain = user, origin, entry, AppConfig.domain

    subject = I18n.t(
      'mailers.notifications.user_accepted_suggestion',
      :user => user.name, :entry => entry.title)

    mail(:to => origin.email, :subject => subject)
  end

  def new_user_suggestion(user, origin, entry)
    @user, @origin, @entry, @domain = user, origin, entry, AppConfig.domain

    subject = I18n.t(
      'mailers.notifications.new_user_suggestion',
      :origin => origin.name, :entry => entry.title)

    mail(:to => user.email, :subject => subject)
  end

  def follow(user, followed)
    @user = user
    @followed = followed

    subject = I18n.t("mailers.notifications.follow.subject",
                     :name => user.name, :app => AppConfig.application_name)

    mail(:to => followed.email, :subject => subject)
  end

  def favorited(user, group, question)
    @user = user
    @group = group
    @question = question

    subject = I18n.t("mailers.notifications.favorited.subject",
                     :name => user.name)

    mail(:to => question.user.email, :subject => subject)
  end

  def report(user, report)
    @user = user
    @report = report

    subject = I18n.t("mailers.notifications.report.subject",
                     :group => report.group.name,
                     :app => AppConfig.application_name)

    mail(:to => user.email, :subject => subject)
  end

  def signup(affiliation)
    @affiliation_token = affiliation.affiliation_token
    mail(:to => affiliation.email, :subject => t("mailers.notifications.signup.subject"))
  end

  def wait(waiting_user)
    @open_universities = University.open_for_signup
    @email = waiting_user.email
    mail(:to => waiting_user.email, :subject => t("mailers.notifications.closed_for_signup.subject"))
  end

  def survey(user)
    @user = user
    SentSurveyMail.create(:user_id => user.id)
    mail(:to => user.email,
         :subject => t(:subject, :scope => [:notifier, :survey]))
  end
end
