class TraineesController < ApplicationController
  before_action :set_trainee, only: %i[show edit update destroy]

  NO_USER_NOTICE = "Not logged in."

  # GET /trainees
  def index
    return redirect_to root_path, notice: NO_USER_NOTICE if @current_user.blank?
    @trainees = Trainee.where user: @current_user
  end

  # GET /trainees/1
  def show
    @nil_nature_option = ["Nature", ""]
    @nature_options = YAML.load_file("data/natures.yml").keys.sort.map do |n|
      [n.capitalize, n]
    end
    @selected_nature = @nature_options.find { |o| o.last == @trainee.nature } ||
                       @nil_nature_option

    @items_options = YAML.load_file("data/items.yml").keys
  end

  # GET /trainees/new
  def new
    return redirect_to root_path, notice: NO_USER_NOTICE if @current_user.blank?
    @trainee = Trainee.new(user: @current_user)
    @trainee.save!
    redirect_to trainee_path(@trainee)
  end

  # PATCH/PUT /trainees/1
  def update
    respond_to do |format|
      @trainee.set_attributes params["trainee"]

      if @trainee.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("artwork", partial: "trainees/artwork",
                                locals: {trainee: @trainee}),
            turbo_stream.update("radar-chart", partial: "shared/radar_chart",
                                locals: {stats: @trainee.evs})
          ]
        end
      else
        puts "Error: Unable to save."
      end
    end
  end

  # DELETE /trainees/1 or /trainees/1.json
  def destroy
    @trainee.destroy

    respond_to do |format|
      format.html { redirect_to trainees_url, notice: "Trainee was successfully destroyed." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trainee
      @trainee = Trainee.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def trainee_params
      params.require(:trainee).permit(:user_id, :team_id, :species_id, :level, :pokerus, :start_stats, :trained_stats, :kills, :nature, :evs)
    end
end
