module TraineesHelper
  def multi_trainee_path(trainees)
    trainee_path trainees.map(&:id).join(",")
  end
end
