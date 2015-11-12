class CourseMailer < ApplicationMailer
  default from: 'noreply@coachup.herokuapp.com'

  def user_application(course, user, has_left=false)
    @fullname = user.username
    #TODO: Add realname to fullname once the model let us get it
    @course = course
    @places_left = course.max_participants - course.subscriptions.length
    @verb = has_left ? 'left' : 'joined'

    mail(to: course.coach.email,
         subject: 'CoachUP! - Someone has applied to one of your courses')
  end
end
