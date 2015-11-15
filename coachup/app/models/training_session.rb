class TrainingSession < ActiveRecord::Bas
  belongs_to :course
  serialize :schedule


  def schedule=(new_schedule)
    write_attribute(:schedule, RecurringSelect.dirty_hash_to_rule(new_schedule).to_yaml)
  end

  def retrieve_schedule
    schedule = IceCube::Schedule.new(self.starts_at)
    schedule.add_recurrence_rule(IceCube::Schedule.from_yaml(self.schedule))
    schedule
  end
end
