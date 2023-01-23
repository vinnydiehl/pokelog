class TraineesController < ApplicationController
  before_action :set_trainee, only: %i[update destroy]

  NO_USER_NOTICE = "Not logged in."

  # GET /trainees
  def index
    return redirect_to root_path, notice: NO_USER_NOTICE if @current_user.blank?
    @trainees = Trainee.where user: @current_user
  end

  # GET /trainees/1 or /trainees/1,2,3
  def show
    @trainees = Trainee.where id: params[:ids].split(",")

    @nil_nature_option = ["Nature", ""]
    @nature_options = YAML.load_file("data/natures.yml").keys.sort.map do |n|
      [n.capitalize, n]
    end

    @items_options = YAML.load_file("data/items.yml").keys

    @search_results = (query = params[:q]).present? ?
      Species.all.select { |pkmn| pkmn.name.downcase.include? query.downcase } :
      Species.all
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
    if @current_user.blank?
      return redirect_to trainee_path(@trainee), notice: NO_USER_NOTICE
    end

    respond_to do |format|
      @trainee.set_attributes params["trainee"]

      if @trainee.save
        titles = helpers.trainees_show_title(JSON.parse params[:trainees])
        radar_id = "radar-chart-#{helpers.dom_id @trainee}"

        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("title", html: titles[:title]),
            turbo_stream.update("title-mobile", html: titles[:mobile_title]),
            turbo_stream.update("artwork-#{helpers.dom_id @trainee}",
                                partial: "trainees/artwork", locals: {trainee: @trainee}),
            turbo_stream.update(radar_id, partial: "shared/radar_chart",
                                locals: {stats: @trainee.evs, id: radar_id}),
            turbo_stream.update("mobile-sprite-#{helpers.dom_id @trainee}", html:
                                @trainee.species ? @trainee.species.sprite : nil)
          ]
        end
      else
        puts "Error: Unable to save."
      end
    end
  end

  # DELETE /trainees/1
  def destroy
    if @current_user.blank?
      return redirect_to trainee_path(@trainee), notice: NO_USER_NOTICE
    end

    nickname = @trainee.nickname || "Trainee"

    @trainee.destroy

    respond_to do |format|
      format.html { redirect_to trainees_url, status: :see_other,
                      notice: "#{nickname} has been deleted." }
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
