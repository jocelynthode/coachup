class CourseMailer < ApplicationMailer
  default from: 'noreply@coachup.herokuapp.com'

  def user_application(course, user, has_left = false)
    @fullname = user.username
    # TODO: Add realname to fullname once the model let us get it
    @course = course
    @places_left = course.max_participants - course.subscriptions.length
    @verb = has_left ? 'left' : 'joined'

    mail(to: course.coach.email,
         subject: "CoachUP! - Someone has #{@verb} one of your courses")
  end

  def session_reminder(sub)
    @course = sub.course
    @user = sub.user
    next_session = @course.retrieve_schedule.next_occurrence 1.day.from_now
    @time = next_session.time.to_s :time
    @date = next_session.time.strftime '%a, %d %b %Y'
    mail(to: @user.email,
         subject: 'CoachUP! - Reminder for your training session')
  end

  def details_update(course)
    @course = course
    recipients = course.subscriptions.map do |sub|
      sub.user.email
    end
    mail(to: recipients,
         subject: 'CoachUP! - One of your courses has been updated')
  end

  # we pass subscriptions here as the course is already removed at this stage
  def course_deleted(removed_course, subscriptions)
    @course = removed_course
    recipients = subscriptions.map do |sub|
      sub.user.email
    end
    mail(to: recipients,
         subject: 'CoachUP! - One of your courses has been deleted')
  end
end
